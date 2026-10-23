param([int]$WaitSeconds = 15, [int]$PostSec = 6)
$ErrorActionPreference = 'Stop'
$RX2 = 'plot:(-?[0-9.]+),(-?[0-9.]+),(-?\d+),(-?\d+),(-?\d+),(-?[0-9.]+)'
function Try-Open($n) {
    $sp = New-Object System.IO.Ports.SerialPort $n, 9600, 'None', 8, 'One'
    $sp.WriteTimeout = 1000; $sp.ReadTimeout = 500
    try { $sp.Open(); return $sp } catch { $sp.Dispose(); return $null }
}
$port = $null; $dl = (Get-Date).AddSeconds($WaitSeconds)
while ($null -eq $port -and (Get-Date) -lt $dl) { $port = Try-Open 'COM7'; if ($null -eq $port) { Start-Sleep -Milliseconds 400 } }
if ($null -eq $port) { Write-Host 'COM7 BUSY - disconnect VOFA+ first.'; exit 1 }
$tr = New-Object System.Collections.ArrayList; $script:t0 = Get-Date
function Drain($p,$mark){ try{ $n=$p.BytesToRead; if($n -gt 0){ $s=$p.ReadExisting()
    foreach($m in [regex]::Matches($s,$RX2)){ [void]$script:tr.Add([pscustomobject]@{
      ms=[Math]::Round(((Get-Date)-$script:t0).TotalMilliseconds,1)
      tgt=[double]$m.Groups[1].Value; l=[int]$m.Groups[3].Value; r=[int]$m.Groups[4].Value
      dif=[int]$m.Groups[5].Value; ang=[double]$m.Groups[6].Value; mark=$mark }) } } }catch{} }
function Span($p,$sec,$mark){ $e=(Get-Date).AddSeconds($sec); while((Get-Date) -lt $e){ Drain $p $mark; Start-Sleep -Milliseconds 20 } }
function Abs($mark){ $g=@($script:tr|Where-Object{$_.mark -eq $mark}); if($g.Count -eq 0){return $null}
  ($g.tgt|ForEach-Object{[Math]::Abs($_)}|Measure-Object -Average).Average }

Write-Host 'confirming current state, then sending ONE "t" to switch tracking back ON.'
try {
    Span $port 2.5 'pre'
    $p1 = Abs 'pre'
    Write-Host ('  |tgt| before = {0:N3}   (near 0 => tracking is currently OFF, as expected)' -f $p1)
    $port.Write('t'); Write-Host '  sent "t"'
    Span $port $PostSec 'post'
} finally { $port.Close(); $port.Dispose(); Write-Host '  COM7 released - you can reconnect VOFA+ now.' }
$p2 = Abs 'post'
Write-Host ''
Write-Host ('|tgt|  {0:N3}  ->  {1:N3}' -f $p1, $p2)
if ($p2 -gt 0.05 -and $p2 -gt $p1 * 3) {
    Write-Host 'TRACKING IS ON. The CCD is writing the steering target again.'
    Write-Host 'Note: a single byte always gets through; multi-byte packets are what kill RX. Keep that in mind for any further TX.'
} elseif ($p2 -lt 0.01 -and $p1 -gt 0.05) {
    Write-Host 'turning tracking OFF did not take - unexpected'
} else {
    Write-Host 'inconclusive: |tgt| stayed low. If the car is NOT on a line, tracking-on leaves the target at 0 anyway (lost-line branch keeps it), so this cannot distinguish. Check the OLED TRK character.'
}
