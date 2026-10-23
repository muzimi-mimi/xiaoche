param([int]$WaitSeconds = 25, [int]$GapMs = 20)
$ErrorActionPreference = 'Stop'
$RX2 = 'plot:(-?[0-9.]+),(-?[0-9.]+),(-?\d+),(-?\d+),(-?\d+),(-?[0-9.]+)'
function Try-Open($n) {
    $sp = New-Object System.IO.Ports.SerialPort $n, 9600, 'None', 8, 'One'
    $sp.WriteTimeout = 1000; $sp.ReadTimeout = 500
    try { $sp.Open(); return $sp } catch { $sp.Dispose(); return $null }
}
$port = $null; $dl = (Get-Date).AddSeconds($WaitSeconds)
while ($null -eq $port -and (Get-Date) -lt $dl) { $port = Try-Open 'COM7'; if ($null -eq $port) { Start-Sleep -Milliseconds 400 } }
if ($null -eq $port) { Write-Host 'COM7 BUSY'; exit 1 }

$tr = New-Object System.Collections.ArrayList
function Drain($p, $mark) {
    try { $n = $p.BytesToRead
        if ($n -gt 0) { $s = $p.ReadExisting()
            foreach ($m in [regex]::Matches($s, $RX2)) {
                [void]$script:tr.Add([pscustomobject]@{
                    i=$script:tr.Count; ms=[Math]::Round(((Get-Date)-$script:t0).TotalMilliseconds,1)
                    ang=[double]$m.Groups[6].Value; dif=[int]$m.Groups[5].Value; mark=$mark }) } } } catch {}
}
function Send-Spaced($p, [string]$s, $mark) {
    foreach ($c in $s.ToCharArray()) {
        $p.Write([string]$c)
        $t=(Get-Date).AddMilliseconds($GapMs); while((Get-Date) -lt $t){ Drain $p $mark; Start-Sleep -Milliseconds 5 }
    }
}
function Span($p,$sec,$mark){ $e=(Get-Date).AddSeconds($sec); while((Get-Date) -lt $e){ Drain $p $mark; Start-Sleep -Milliseconds 20 } }

$script:t0 = Get-Date
Write-Host ('per-frame trace test, {0} ms byte spacing. Watching for an INSTANTANEOUS Angle jump (the loop then cancels it).' -f $GapMs)
try {
    Span $port 1.5 'pre'
    Send-Spaced $port '[slider,G,4]' 'send-G4'
    Span $port 3 'hold-G4'
    Send-Spaced $port '[slider,G,0]' 'send-G0'
    Span $port 2.5 'post'
} finally { $port.Close(); $port.Dispose(); Write-Host 'COM7 released' }

if ($tr.Count -lt 20) { Write-Host 'too few frames'; exit 1 }
$tr | Export-Csv -Path 'D:\codex\rx_trace.csv' -NoTypeInformation
Write-Host ('frames={0}  saved -> D:\codex\rx_trace.csv' -f $tr.Count)
Write-Host ''
Write-Host '=== biggest frame-to-frame Angle jumps ==='
$maxUp=0.0; $maxUpI=0; $maxDn=0.0; $maxDnI=0
for ($i=1; $i -lt $tr.Count; $i++) {
    $d = $tr[$i].ang - $tr[$i-1].ang
    if ($d -gt $maxUp) { $maxUp=$d; $maxUpI=$i }
    if ($d -lt $maxDn) { $maxDn=$d; $maxDnI=$i }
}
'  biggest RISE  = {0,6:N2} deg at frame {1} (t={2} ms, mark={3})' -f $maxUp, $maxUpI, $tr[$maxUpI].ms, $tr[$maxUpI].mark
'  biggest DROP  = {0,6:N2} deg at frame {1} (t={2} ms, mark={3})' -f $maxDn, $maxDnI, $tr[$maxDnI].ms, $tr[$maxDnI].mark
Write-Host ''
Write-Host '=== Angle trace around the [slider,G,4] send ==='
$firstG4 = ($tr | Where-Object { $_.mark -eq 'send-G4' } | Select-Object -First 1).i
if ($null -ne $firstG4) {
    $lo = [Math]::Max(1, $firstG4 - 4); $hi = [Math]::Min($tr.Count-1, $firstG4 + 14)
    for ($i=$lo; $i -le $hi; $i++) { '  f{0,3} t={1,7} ang={2,7:N2}  d={3,6:N2}  [{4}]' -f $i,$tr[$i].ms,$tr[$i].ang,($tr[$i].ang-$tr[$i-1].ang),$tr[$i].mark }
}
Write-Host ''
if ($maxUp -gt 2.5) { Write-Host ('RX WORKS: instantaneous +{0:N2} deg step proves the packet arrived. (settled mean was misleading because the balance loop cancels a G offset)' -f $maxUp) }
else { Write-Host 'No instantaneous step >= 2.5 deg anywhere -> RX genuinely not receiving.' }
