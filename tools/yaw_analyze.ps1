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

$win = @(
    @(6, 180, "W1 start-static"),
    @(268, 330, "W2 after-rot1"),
    @(438, 540, "W3 after-return1"),
    @(750, 936, "W4 final")
)
$rows = New-Object System.Collections.ArrayList
[void]$rows.Add("window            dur_s   GZmean  GZsd   resid_dps   dYaw   drift_dpm  nodz_dpm  esc")
foreach ($w in $win) {
    $a = $w[0]; $b = $w[1]; $cnt = 0; $s = 0.0; $s2 = 0.0; $esc = 0
    for ($j = $a; $j -le $b; $j++) {
        $cnt++
        $s += $gz[$j]
        $s2 += $gz[$j] * $gz[$j]
        $v = ($gz[$j] - $BIAS) / $LSB
        if ([math]::Abs($v) -gt $DZ) { $esc++ }
    }
    $mean = $s / $cnt
    $sd = [math]::Sqrt($s2 / $cnt - $mean * $mean)
    $res = ($mean - $BIAS) / $LSB
    $dur = $cnt * $TP
    $d = $yw[$b] - $yw[$a]
    [void]$rows.Add(("{0,-16} {1,6:F1} {2,8:F2} {3,6:F2} {4,10:F4} {5,7:F2} {6,10:F3} {7,9:F2} {8,5}/{9}" -f `
                $w[2], $dur, $mean, $sd, $res, $d, ($d / $dur * 60), ($res * 60), $esc, $cnt))
}
$rows -join "`n"
Write-Host ""
Write-Host ("samples {0}   print interval {1:F2} ms   total {2:F1} s" -f $TOT, ($TP * 1000), ($TOT * $TP))
$e = 0
for ($j = 0; $j -lt $TOT; $j++) { if ([math]::Abs(($gz[$j] - $BIAS) / $LSB) -gt $DZ) { $e++ } }
Write-Host ("samples escaping deadzone: {0}/{1} = {2:F1}%" -f $e, $TOT, ($e / $TOT * 100))
Write-Host ""
Write-Host "=== timeline ==="
$pts = @(@(6, "start"), @(180, "before rot1"), @(250, "after rot1"), @(430, "after ret1"), @(672, "after rot2"), @(936, "final"))
foreach ($q in $pts) { Write-Host ("  idx {0,4}  Yaw = {1,9:F2}   {2}" -f $q[0], $yw[$q[0]], $q[1]) }
