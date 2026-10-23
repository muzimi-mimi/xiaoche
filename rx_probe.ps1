param([int]$WaitSeconds = 25)
$ErrorActionPreference = 'Stop'
$RX2 = 'plot:(-?[0-9.]+),(-?[0-9.]+),(-?\d+),(-?\d+),(-?\d+),(-?[0-9.]+)'
function Try-Open($n) {
    $sp = New-Object System.IO.Ports.SerialPort $n, 9600, 'None', 8, 'One'
    $sp.WriteTimeout = 500; $sp.ReadTimeout = 500
    try { $sp.Open(); return $sp } catch { $sp.Dispose(); return $null }
}
$port = $null; $dl = (Get-Date).AddSeconds($WaitSeconds)
while ($null -eq $port -and (Get-Date) -lt $dl) { $port = Try-Open 'COM7'; if ($null -eq $port) { Start-Sleep -Milliseconds 400 } }
if ($null -eq $port) { 'COM7 BUSY -> disconnect it in VOFA+ first.'; exit 1 }

'RX probe. Phase A 2s baseline (no TX) | send "t" | Phase B 2.5s | send "t" again | Phase C 2s'
'If PC->MCU works the car should creep forward during phase B and LeftPWM/RightPWM will shift.'
$phase = New-Object System.Collections.ArrayList
function Sniff($port, $name, $sec, $out) {
    $t0 = Get-Date; $e = $t0.AddSeconds($sec); $rows = New-Object System.Collections.ArrayList
    while ((Get-Date) -lt $e) {
        try { $n = $port.BytesToRead; if ($n -gt 0) { $s = $port.ReadExisting()
            foreach ($m in [regex]::Matches($s, $RX2)) { [void]$rows.Add([pscustomobject]@{
                l=[int]$m.Groups[3].Value; r=[int]$m.Groups[4].Value; dif=[int]$m.Groups[5].Value; ang=[double]$m.Groups[6].Value }) } } } catch {}
        Start-Sleep -Milliseconds 30
    }
    $obj = [pscustomobject]@{ phase=$name; n=$rows.Count
        L= if($rows.Count){[Math]::Round(($rows.l|Measure-Object -Average).Average,1)}else{'-'}
        R= if($rows.Count){[Math]::Round(($rows.r|Measure-Object -Average).Average,1)}else{'-'}
        Dif= if($rows.Count){[Math]::Round(($rows.dif|Measure-Object -Average).Average,1)}else{'-'}
        Ang= if($rows.Count){[Math]::Round(($rows.ang|Measure-Object -Average).Average,2)}else{'-'} }
    $out.Add($obj) | Out-Null
    '  {0,-6} n={1,4}  L={2,7}  R={3,7}  DifPWM={4,6}  Angle={5,6}' -f $obj.phase,$obj.n,$obj.L,$obj.R,$obj.Dif,$obj.Ang
}
try {
    Sniff $port 'A' 2 $phase
    $port.Write('t'); '  sent bare "t" (toggle tracking ON)'
    Sniff $port 'B' 2.5 $phase
    $port.Write('t'); '  sent bare "t" (toggle tracking back OFF)'
    Sniff $port 'C' 2 $phase
} finally { $port.Close(); $port.Dispose() }
''
$A = $phase[0]; $B = $phase[1]
if ($A.n -eq 0 -or $B.n -eq 0) { 'no frames in a phase; inconclusive' }
elseif ([Math]::Abs($B.L - $A.L) -gt 3 -or [Math]::Abs($B.R - $A.R) -gt 3) {
    'RX WORKS: phase B PWM moved by dL={0} dR={1} -> PC->MCU is alive, so the joystick frames are the problem' -f ($B.L-$A.L), ($B.R-$A.R)
} else {
    'RX IS DEAD: "t" produced no PWM change at all -> PC->MCU bytes are not reaching the MCU (ORE / no re-arm is the prime suspect)'
}
