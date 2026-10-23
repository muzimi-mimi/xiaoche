param([int]$WaitSeconds = 15, [int]$PostSec = 8)
$ErrorActionPreference = 'Stop'
$RX2 = 'plot:(-?[0-9.]+),(-?[0-9.]+),(-?\d+),(-?\d+),(-?\d+),(-?[0-9.]+)'
function Try-Open($n) {
    $sp = New-Object System.IO.Ports.SerialPort $n, 9600, 'None', 8, 'One'
    $sp.WriteTimeout = 1000; $sp.ReadTimeout = 500
    try { $sp.Open(); return $sp } catch { $sp.Dispose(); return $null }
}
$port = $null; $dl = (Get-Date).AddSeconds($WaitSeconds)
while ($null -eq $port -and (Get-Date) -lt $dl) { $port = Try-Open 'COM7'; if ($null -eq $port) { Start-Sleep -Milliseconds 400 } }
if ($null -eq $port) { Write-Host 'COM7 IS BUSY - VOFA+ still holds it. Disconnect it in VOFA+ first; a single process can own this port.'; exit 1 }

$tr = New-Object System.Collections.ArrayList; $script:t0 = Get-Date
function Drain($p, $mark) {
    try { $n = $p.BytesToRead; if ($n -gt 0) { $s = $p.ReadExisting()
        foreach ($m in [regex]::Matches($s, $RX2)) { [void]$script:tr.Add([pscustomobject]@{
            ms=[Math]::Round(((Get-Date)-$script:t0).TotalMilliseconds,1)
            tgt=[double]$m.Groups[1].Value; act=[double]$m.Groups[2].Value
            l=[int]$m.Groups[3].Value; r=[int]$m.Groups[4].Value
            dif=[int]$m.Groups[5].Value; ang=[double]$m.Groups[6].Value; mark=$mark }) } } } catch {}
}
function Span($p,$sec,$mark){ $e=(Get-Date).AddSeconds($sec); while((Get-Date) -lt $e){ Drain $p $mark; Start-Sleep -Milliseconds 20 } }
function Stat($mark){
    $g = @($script:tr | Where-Object { $_.mark -eq $mark })
    if ($g.Count -eq 0) { return $null }
    [pscustomobject]@{ n=$g.Count
        L=($g.l|Measure-Object -Average).Average; R=($g.r|Measure-Object -Average).Average
        Dif=($g.dif|Measure-Object -Average).Average; Ang=($g.ang|Measure-Object -Average).Average
        AbsTgt=($g.tgt|ForEach-Object{[Math]::Abs($_)}|Measure-Object -Average).Average
        Move=($g | ForEach-Object { [Math]::Abs($_.l)+[Math]::Abs($_.r) } | Measure-Object -Average).Average }
}
Write-Host 'port acquired. baseline 3 s, then ONE bare "t" (toggles tracking), then' $PostSec 's of observation.'
try {
    Span $port 3 'pre'
    $port.Write('t')
    Write-Host '  sent single byte "t"  (no burst -> overrun cannot be blamed for losing it)'
    Span $port $PostSec 'post'
} finally { $port.Close(); $port.Dispose(); Write-Host '  COM7 released' }

$a = Stat 'pre'; $b = Stat 'post'
if ($null -eq $a -or $null -eq $b) { Write-Host 'missing frames'; exit 1 }
Write-Host ''
'{0,-6} {1,5} {2,8} {3,8} {4,9} {5,8} {6,9} {7,9}' -f 'phase','n','Lavg','Ravg','|L|+|R|','DifAvg','AngAvg','|tgt|Avg'
'{0,-6} {1,5} {2,8:N1} {3,8:N1} {4,9:N1} {5,8:N1} {6,8:N2} {7,9:N3}' -f 'before',$a.n,$a.L,$a.R,$a.Move,$a.Dif,$a.Ang,$a.AbsTgt
'{0,-6} {1,5} {2,8:N1} {3,8:N1} {4,9:N1} {5,8:N1} {6,8:N2} {7,9:N3}' -f 'after',$b.n,$b.L,$b.R,$b.Move,$b.Dif,$b.Ang,$b.AbsTgt
Write-Host ''
$dMove = $b.Move - $a.Move
$dTgt  = $b.AbsTgt - $a.AbsTgt
Write-Host ('wheel-drive change |L|+|R|: {0:N1} -> {1:N1}  (delta {2:N1})' -f $a.Move, $b.Move, $dMove)
Write-Host ('steering-target change |tgt|: {0:N3} -> {1:N3}  (delta {2:N3})' -f $a.AbsTgt, $b.AbsTgt, $dTgt)
if ($dMove -gt 8 -or $dTgt -gt 0.05) {
    Write-Host 'RX WORKS. The "t" landed and tracking mode changed the control behaviour.'
    Write-Host '=> downlink is alive; earlier ignored packets were a framing/burst problem, not a dead link.'
} else {
    Write-Host 'No measurable reaction to a single "t".'
    Write-Host 'Either (a) RX was already killed by my earlier 13-byte bursts -> POWER-CYCLE the car and let this "t" be the very first inbound byte, or'
    Write-Host '       (b) the car is not sitting on a line, so tracking-on only gives ~1 s of creep before the lost-line rule stops it.'
}
