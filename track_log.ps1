param([int]$Seconds = 40, [int]$WaitSeconds = 60, [string]$Tag = (Get-Date -Format 'yyyyMMdd_HHmmss'))
$ErrorActionPreference = 'Stop'
$RX2 = 'plot:(-?[0-9.]+),(-?[0-9.]+),(-?\d+),(-?\d+),(-?\d+),(-?[0-9.]+)'
$Csv = "D:\codex\track_$Tag.csv"
function Try-Open($n) {
    $sp = New-Object System.IO.Ports.SerialPort $n, 9600, 'None', 8, 'One'
    $sp.ReadTimeout = 500
    try { $sp.Open(); return $sp } catch { $sp.Dispose(); return $null }
}
$port = $null; $dl = (Get-Date).AddSeconds($WaitSeconds)
while ($null -eq $port -and (Get-Date) -lt $dl) { $port = Try-Open 'COM7'; if ($null -eq $port) { Start-Sleep -Milliseconds 400 } }
if ($null -eq $port) { Write-Host 'COM7 BUSY -> disconnect it in VOFA+ first.'; exit 1 }
Write-Host ('read-only capture {0} s, sending NOTHING. Put the car on the line and start it from the button.' -f $Seconds)

$tr = New-Object System.Collections.ArrayList
$script:t0 = Get-Date
try {
    $e = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $e) {
        try { $n = $port.BytesToRead
            if ($n -gt 0) { $s = $port.ReadExisting()
                foreach ($m in [regex]::Matches($s, $RX2)) { [void]$tr.Add([pscustomobject]@{
                    ms=[Math]::Round(((Get-Date)-$t0).TotalMilliseconds,1)
                    tgt=[double]$m.Groups[1].Value; act=[double]$m.Groups[2].Value
                    l=[int]$m.Groups[3].Value; r=[int]$m.Groups[4].Value
                    dif=[int]$m.Groups[5].Value; ang=[double]$m.Groups[6].Value }) } } } catch {}
        Start-Sleep -Milliseconds 20
    }
} finally { $port.Close(); $port.Dispose(); Write-Host 'COM7 released' }

if ($tr.Count -lt 20) { Write-Host 'too few frames'; exit 1 }
$tr | Export-Csv -Path $Csv -NoTypeInformation
Write-Host ('frames={0} rate={1:N1} Hz  csv->{2}' -f $tr.Count, ($tr.Count/$Seconds), $Csv)

# "stopped" = both wheels near zero AND no steering effort, for >=3 consecutive frames
$stopThr = 6
$runs = @(); $i = 0
while ($i -lt $tr.Count) {
    if ([Math]::Abs($tr[$i].l) -lt $stopThr -and [Math]::Abs($tr[$i].r) -lt $stopThr -and [Math]::Abs($tr[$i].dif) -lt $stopThr) {
        $j = $i; while ($j -lt $tr.Count -and [Math]::Abs($tr[$j].l) -lt $stopThr -and [Math]::Abs($tr[$j].r) -lt $stopThr -and [Math]::Abs($tr[$j].dif) -lt $stopThr) { $j++ }
        $dur = $tr[$j-1].ms - $tr[$i].ms
        if ($dur -gt 300) { $runs += [pscustomobject]@{ start=$tr[$i].ms; dur=$dur; frames=($j-$i) } }
        $i = $j
    } else { $i++ }
}
Write-Host ''
if ($runs.Count -eq 0) {
    Write-Host ('NO stop episodes (>=300 ms with |L|,|R|,|Dif| < {0}) -> the stutter is not a full stop; look at PWM dip instead.' -f $stopThr)
} else {
    $d = $runs.dur
    $st = $d | Measure-Object -Average -Minimum -Maximum
    Write-Host ('=== {0} stop episodes (wheels+steering all near zero) ===' -f $runs.Count)
    $runs | ForEach-Object { '  at t={0,8:N0} ms  held {1,7:N0} ms  ({2} frames)' -f $_.start, $_.dur, $_.frames }
    Write-Host ''
    Write-Host ('stop duration: avg={0:N0} ms min={1:N0} max={2:N0}' -f $st.Average, $st.Minimum, $st.Maximum)
    if ($runs.Count -gt 1) {
        $gaps = @(); for ($k=1; $k -lt $runs.Count; $k++) { $gaps += ($runs[$k].start - $runs[$k-1].start) }
        $gs = $gaps | Measure-Object -Average -Minimum -Maximum
        Write-Host ('gap between stops: avg={0:N0} ms min={1:N0} max={2:N0}   <- if tight spread, it is a limit cycle, not random loss' -f $gs.Average, $gs.Minimum, $gs.Maximum)
        Write-Host ('duty cycle stopped: {0:N1} %' -f (100.0 * ($d | Measure-Object -Sum).Sum / ($Seconds*1000)))
    }
    Write-Host ''
    Write-Host '=== is the stop the lost-line rule? signature: tgt AND dif both driven to 0 just before stopping ==='
    $sig = 0
    foreach ($rp in $runs) {
        $k = ($tr | Where-Object { $_.ms -le $rp.start } | Select-Object -Last 1)
        if ($null -ne $k -and [Math]::Abs($k.tgt) -lt 0.05 -and [Math]::Abs($k.dif) -lt 3) { $sig++ }
    }
    Write-Host ('  {0} of {1} stops were preceded by target~0 AND dif~0 (that is exactly what TrackLostCnt>=25 does)' -f $sig, $runs.Count)
}
