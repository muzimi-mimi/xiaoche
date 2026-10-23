param([int]$Seconds = 6, [int]$WaitSeconds = 25)
$ErrorActionPreference = 'Stop'
$RX2 = 'plot:(-?[0-9.]+),(-?[0-9.]+),(-?\d+),(-?\d+),(-?\d+),(-?[0-9.]+)'

function Try-Open($n) {
    $sp = New-Object System.IO.Ports.SerialPort $n, 9600, 'None', 8, 'One'
    $sp.ReadTimeout = 500
    try { $sp.Open(); return $sp } catch { $sp.Dispose(); return $null }
}
$port = $null; $dl = (Get-Date).AddSeconds($WaitSeconds)
while ($null -eq $port -and (Get-Date) -lt $dl) { $port = Try-Open 'COM7'; if ($null -eq $port) { Start-Sleep -Milliseconds 400 } }
if ($null -eq $port) { 'COM7 STILL BUSY -> VOFA+ has not actually released it.'; exit 1 }
'COM7 IS FREE (VOFA+ released it). Read-only sniff {0} s, sending nothing...' -f $Seconds

$rows = New-Object System.Collections.ArrayList
try {
    $t0 = Get-Date; $end = $t0.AddSeconds($Seconds)
    while ((Get-Date) -lt $end) {
        try { $n = $port.BytesToRead; if ($n -gt 0) { $s = $port.ReadExisting()
            foreach ($m in [regex]::Matches($s, $RX2)) {
                [void]$rows.Add([pscustomobject]@{
                    tgt=[double]$m.Groups[1].Value; act=[double]$m.Groups[2].Value
                    l=[int]$m.Groups[3].Value; r=[int]$m.Groups[4].Value
                    dif=[int]$m.Groups[5].Value; ang=[double]$m.Groups[6].Value }) } } } catch {}
        Start-Sleep -Milliseconds 30
    }
} finally { $port.Close(); $port.Dispose() }

if ($rows.Count -eq 0) { 'PORT WAS FREE BUT ZERO FRAMES -> car not powered / BT link down / not sending.'; exit 1 }
$a = $rows.ang
$avg = ($a | Measure-Object -Average).Average
$sd = [Math]::Sqrt(((($a | ForEach-Object { ($_ - $avg) * ($_ - $avg) } | Measure-Object -Sum).Sum) / $a.Count))
'frames={0}  rate={1:N1} Hz   -> 6-channel format parses OK' -f $rows.Count, ($rows.Count / $Seconds)
''
'{0,-10} {1,9} {2,9} {3,9} {4,9}' -f 'channel','min','max','avg','sd'
'{0,-10} {1,9:N3} {2,9:N3} {3,9:N3} {4,9:N3}' -f 'Angle', (($a|Measure-Object -Minimum).Minimum), (($a|Measure-Object -Maximum).Maximum), $avg, $sd
'{0,-10} {1,9:N3} {2,9:N3} {3,9:N3}' -f 'TgtRamp', (($rows.tgt|Measure-Object -Minimum).Minimum), (($rows.tgt|Measure-Object -Maximum).Maximum), (($rows.tgt|Measure-Object -Average).Average)
'{0,-10} {1,9:N3} {2,9:N3} {3,9:N3}' -f 'ActDifSp', (($rows.act|Measure-Object -Minimum).Minimum), (($rows.act|Measure-Object -Maximum).Maximum), (($rows.act|Measure-Object -Average).Average)
'{0,-10} {1,9} {2,9} {3,9}' -f 'DifPWM', (($rows.dif|Measure-Object -Minimum).Minimum), (($rows.dif|Measure-Object -Maximum).Maximum), (($rows.dif|Measure-Object -Average).Average)
'{0,-10} {1,9} {2,9}' -f 'LeftPWM', (($rows.l|Measure-Object -Minimum).Minimum), (($rows.l|Measure-Object -Maximum).Maximum)
'{0,-10} {1,9} {2,9}' -f 'RightPWM', (($rows.r|Measure-Object -Minimum).Minimum), (($rows.r|Measure-Object -Maximum).Maximum)
''
'verdict: |Angle| avg = {0:N1} deg -> {1}' -f ([Math]::Abs($avg)), $(if ([Math]::Abs($avg) -lt 12) { 'UPRIGHT / balanced (ok to steer)' } elseif ([Math]::Abs($avg) -gt 45) { 'LYING ON ITS SIDE (stand it up first)' } else { 'tilted, not settled - hold it upright' })
