param([int]$WaitSeconds = 40, [int]$GapMs = 20)
$ErrorActionPreference = 'Stop'
$RX2 = 'plot:(-?[0-9.]+),(-?[0-9.]+),(-?\d+),(-?\d+),(-?\d+),(-?[0-9.]+)'
function Try-Open($n) {
    $sp = New-Object System.IO.Ports.SerialPort $n, 9600, 'None', 8, 'One'
    $sp.WriteTimeout = 1000; $sp.ReadTimeout = 500
    try { $sp.Open(); return $sp } catch { $sp.Dispose(); return $null }
}
$port = $null; $dl = (Get-Date).AddSeconds($WaitSeconds)
while ($null -eq $port -and (Get-Date) -lt $dl) { $port = Try-Open 'COM7'; if ($null -eq $port) { Start-Sleep -Milliseconds 400 } }
if ($null -eq $port) { Write-Host 'COM7 BUSY -> disconnect it in VOFA+ first.'; exit 1 }

$tr = New-Object System.Collections.ArrayList
$script:t0 = Get-Date
function Drain($p, $mark) {
    try { $n = $p.BytesToRead
        if ($n -gt 0) { $s = $p.ReadExisting()
            foreach ($m in [regex]::Matches($s, $RX2)) { [void]$script:tr.Add([pscustomobject]@{
                i=$script:tr.Count; ms=[Math]::Round(((Get-Date)-$script:t0).TotalMilliseconds,1)
                ang=[double]$m.Groups[6].Value; l=[int]$m.Groups[3].Value; r=[int]$m.Groups[4].Value; mark=$mark }) } } } catch {}
}
function Send-Spaced($p,[string]$s,$mark){ foreach($c in $s.ToCharArray()){ $p.Write([string]$c)
    $t=(Get-Date).AddMilliseconds($GapMs); while((Get-Date) -lt $t){ Drain $p $mark; Start-Sleep -Milliseconds 5 } } }
function Span($p,$sec,$mark){ $e=(Get-Date).AddSeconds($sec); while((Get-Date) -lt $e){ Drain $p $mark; Start-Sleep -Milliseconds 20 } }

Write-Host 'LAY THE CAR DOWN ON ITS SIDE first. Then I send bare "1" (StartErect) byte-spaced.'
Write-Host 'Waiting for COM7...'
try {
    $pre = Span $port 2 'pre'
    $a0 = $tr[-1].ang
    Write-Host ('  baseline: Angle={0:N1} deg, L={1}, R={2}   (|Angle| should be large if it is lying down)' -f $a0, $tr[-1].l, $tr[-1].r)
    if ([Math]::Abs($a0) -lt 30) { Write-Host '  |Angle| < 30 deg -> car does NOT look like it is lying down. Aborting before sending 1.'; $script:abort=1 }
    else {
        Send-Spaced $port '1' 'send-1'
        Write-Host '  sent bare "1"'
        Span $port 8 'erecting'
    }
} finally { $port.Close(); $port.Dispose(); Write-Host '  COM7 released' }

if ($script:abort) { exit 1 }
$tr | Export-Csv -Path 'D:\codex\rx_erect.csv' -NoTypeInformation
Write-Host ''
Write-Host '=== Angle and PWM every ~0.5 s after sending "1" ==='
$seg = $tr | Where-Object { $_.mark -eq 'erecting' }
if (-not $seg) { Write-Host 'no post-send frames'; exit 1 }
$seg | Group-Object { [int]([Math]::Floor($_.ms / 500)) } | ForEach-Object {
    $g = $_.Group
    '  +{0,4} ms  Angle={1,7:N1} deg   L={2,5}  R={3,5}  (n={4})' -f ([int]$_.Name * 500), `
        (($g.ang | Measure-Object -Average).Average), (($g.l | Measure-Object -Average).Average), (($g.r | Measure-Object -Average).Average), $g.Count
}
Write-Host ''
$amin = ($seg.ang | Measure-Object -Minimum).Minimum; $amax = ($seg.ang | Measure-Object -Maximum).Maximum
$moved = [Math]::Min([Math]::Abs($amin), [Math]::Abs($amax))
Write-Host ('|Angle| range after "1": {0:N1} .. {1:N1} deg  (baseline was {2:N1})' -f $amin, $amax, $a0)
if ($moved -lt ([Math]::Abs($a0) * 0.5)) {
    Write-Host 'RX WORKS - the car responded to "1" and its tilt changed a lot. PC->MCU is alive.'
    Write-Host '=> then the ignored joystick frames must be a protocol/format issue inside the packet, not the link.'
} else {
    Write-Host 'RX IS DEAD - "1" produced no reaction at all (tilt essentially unchanged).'
    Write-Host '=> bytes leave the PC but never reach PB11. Suspect the BT module direction / pairing, not firmware.'
}
