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

'RX decisive test: shift angle-offset G by +4 deg via [slider,G,4], then restore to 0.'
'Expected: channel6 Angle steps by ~4 deg and STAYS stepped for the whole phase B.'
$ph = @{}
function Sniff($port, $name, $sec) {
    $t0 = Get-Date; $e = $t0.AddSeconds($sec); $a = New-Object System.Collections.ArrayList
    while ((Get-Date) -lt $e) {
        try { $n = $port.BytesToRead; if ($n -gt 0) { $s = $port.ReadExisting()
            foreach ($m in [regex]::Matches($s, $RX2)) { [void]$a.Add([double]$m.Groups[6].Value) } } } catch {}
        Start-Sleep -Milliseconds 30
    }
    if ($a.Count -eq 0) { $script:ph[$name] = $null; '  {0}: ZERO FRAMES' -f $name; return }
    $st = $a | Measure-Object -Average -Minimum -Maximum
    # use the last 60% of the phase, so the step itself is not averaged in
    $tail = $a[[int]($a.Count*0.4)..($a.Count-1)] | Measure-Object -Average
    $script:ph[$name] = [pscustomobject]@{ n=$a.Count; avg=$st.Average; tail=$tail.Average; min=$st.Minimum; max=$st.Maximum }
    '  {0,-3} n={1,4}  avg={2,7:N2}  settled={3,7:N2}  range=[{4:N2} .. {5:N2}]' -f $name,$a.Count,$st.Average,$tail.Average,$st.Minimum,$st.Maximum
}
try {
    Sniff $port 'A' 2
    $port.Write('[slider,G,4]');   '  sent [slider,G,4]'
    Sniff $port 'B' 3
    $port.Write('[slider,G,0]');   '  sent [slider,G,0]  (restored)'
    Sniff $port 'C' 2
} finally { $port.Close(); $port.Dispose() }

''
if ($null -eq $ph.A -or $null -eq $ph.B -or $null -eq $ph.C) { 'inconclusive (missing frames)'; exit 1 }
$dB = $ph.B.tail - $ph.A.tail
$stepOK = [Math]::Abs($dB) -gt 2.0
'return-to-baseline check: C.settled - A.settled = {0:N2} deg (should be ~0 if restore worked)' -f ($ph.C.tail - $ph.A.tail)
if ($stepOK) {
    'RX WORKS. G step produced {0:N2} deg on channel 6 (expected ~+4). PC->MCU is alive.' -f $dB
    '=> so the joystick frames DID arrive but were ignored. Next suspect: TrackMode is still ON.'
} else {
    'RX IS DEAD. Sending [slider,G,4] moved the reported angle by only {0:N2} deg.' -f $dB
    '=> bytes are leaving the PC but nothing changes in the MCU. Prime suspect: UART overrun with no HAL_UART_ErrorCallback re-arm.'
}
