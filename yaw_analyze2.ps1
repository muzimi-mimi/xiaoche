$p = "D:\Users\huang\Desktop\keil\PID\新建 文本文档.txt"
$txt = [System.IO.File]::ReadAllText($p)
$m = [regex]::Matches($txt, '\[plot,\s*(-?\d+),\s*(-?[\d.]+)\]')
$TOT = $m.Count
$gz = New-Object 'double[]' $TOT
$yw = New-Object 'double[]' $TOT
for ($i = 0; $i -lt $TOT; $i++) {
    $gz[$i] = [double]$m[$i].Groups[1].Value
    $yw[$i] = [double]$m[$i].Groups[2].Value
}
$BIAS = 41.124; $LSB = 16.384; $DZ = 0.5
$K = 4.46; $TP = $K * 0.01
# session bias = mean GZ over clean static windows
$statIdx = @()
foreach ($w in @(@(6, 180), @(268, 330), @(438, 540), @(750, 936))) { $statIdx += $w[0]..$w[1] }
$s = 0.0; foreach ($j in $statIdx) { $s += $gz[$j] }
$SB = $s / $statIdx.Count
$RES = ($SB - $BIAS) / $LSB
Write-Host ("session static mean GZ = {0:F2} LSB   stored bias = 41.124   -> residual = {1:F4} deg/s" -f $SB, $RES)
Write-Host ("deadzone margin = {0:F1}x`n" -f ($DZ / [math]::Abs($RES)))

$ph = @(
    @(180, 250, "rot1  +90nom"),
    @(250, 430, "ret1  -90nom"),
    @(430, 672, "rot2  +90nom"),
    @(672, 936, "ret2  -90nom")
)
$rows = New-Object System.Collections.ArrayList
[void]$rows.Add("phase          dur_s  dz_s   sumRate  dYaw_raw  k     dzLoss  dYaw_corr  |err|%")
foreach ($q in $ph) {
    $a = $q[0]; $b = $q[1]; $cnt = 0; $esc = 0; $sr = 0.0
    for ($j = $a; $j -le $b; $j++) {
        $cnt++
        $r = ($gz[$j] - $BIAS) / $LSB
        $sr += $r
        if ([math]::Abs($r) -gt $DZ) { $esc++ }
    }
    $dur = $cnt * $TP
    $dzT = ($cnt - $esc) * $TP
    $d = $yw[$b] - $yw[$a]
    $kk = $d / ($sr * 0.01)
    $loss = $RES * $dzT
    $corr = $d - $loss
    [void]$rows.Add(("{0,-13} {1,6:F1} {2,6:F1} {3,8:F1} {4,9:F2} {5,6:F3} {6,7:F2} {7,10:F2} {8,8:F2}" -f `
                $q[2], $dur, $dzT, $sr, $d, $kk, $loss, $corr, ([math]::Abs([math]::Abs($corr) - 90) / 90 * 100)))
}
$rows -join "`n"
Write-Host ""
Write-Host "dYaw_raw  = firmware accumulated angle over the phase"
Write-Host "dzLoss    = angle NOT integrated because deadzone zeroed slow samples (residual x deadzoned time)"
Write-Host "dYaw_corr = dYaw_raw - dzLoss  (best estimate of TRUE rotated angle)`n"

# closure
$c1 = $yw[430] - $yw[180]
$c2 = $yw[936] - $yw[430]
Write-Host ("closure trip1 (idx180->430): {0:F2} deg" -f $c1)
Write-Host ("closure trip2 (idx430->936): {0:F2} deg" -f $c2)
Write-Host ("closure total (idx180->936): {0:F2} deg over 360 deg travel = {1:F2}%" -f ($yw[936] - $yw[180]), ([math]::Abs($yw[936] - $yw[180]) / 360 * 100))
# total absolute travel
$ta = 0.0; for ($j = 0; $j -lt $TOT; $j++) { $ta += [math]::Abs(($gz[$j] - $BIAS) / $LSB) * $TP }
Write-Host ("total absolute angular travel = {0:F0} deg" -f $ta)
Write-Host ("peak |GZ| = {0:F0} LSB = {1:F1} deg/s   (full scale 32768 -> no saturation)" -f (($gz | ForEach-Object { [math]::Abs($_) } | Measure-Object -Maximum).Maximum), (($gz | ForEach-Object { [math]::Abs($_) } | Measure-Object -Maximum).Maximum / $LSB))
