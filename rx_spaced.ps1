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
if ($null -eq $port) { Write-Host 'COM7 BUSY -> disconnect it in VOFA+ first.'; exit 1 }

$ang = New-Object System.Collections.ArrayList

function Drain($p) {
    try { $n = $p.BytesToRead
        if ($n -gt 0) { $s = $p.ReadExisting()
            foreach ($m in [regex]::Matches($s, $RX2)) { [void]$script:ang.Add([double]$m.Groups[6].Value) } } } catch {}
}
function Send-Spaced($p, [string]$s) {
    foreach ($c in $s.ToCharArray()) {
        $p.Write([string]$c)
        $t = (Get-Date).AddMilliseconds($GapMs)
        while ((Get-Date) -lt $t) { Drain $p; Start-Sleep -Milliseconds 5 }
    }
}
function Collect($p, $sec, $tag) {
    $t0 = Get-Date; $e = $t0.AddSeconds($sec); $before = $script:ang.Count
    while ((Get-Date) -lt $e) { Drain $p; Start-Sleep -Milliseconds 20 }
    if ($script:ang.Count -le $before) { Write-Host ('  {0,-8} ZERO frames' -f $tag); return $null }
    $seg = @($script:ang[$before..($script:ang.Count-1)])
    $half = [int]($seg.Count * 0.5)
    if ($half -ge $seg.Count) { $half = $seg.Count - 1 }
    $tl = @($seg[$half..($seg.Count-1)]) | Measure-Object -Average
    Write-Host ('  {0,-8} n={1,4}  settled Angle={2,7:N2}' -f $tag, $seg.Count, $tl.Average)
    return $tl.Average
}

Write-Host ('byte-spaced TX test: [slider,G,4] one char at a time, {0} ms apart (never two bytes pending -> cannot overrun)' -f $GapMs)
try {
    $a = Collect $port 2 'A base'
    Send-Spaced $port '[slider,G,4]'
    Write-Host '  packet sent'
    $b = Collect $port 3 'B G=4'
    Send-Spaced $port '[slider,G,0]'
    $c = Collect $port 2 'C G=0'
} finally { $port.Close(); $port.Dispose(); Write-Host '  COM7 released' }

Write-Host ''
Write-Host ('total frames seen this run: {0}' -f $ang.Count)
if ($null -eq $a -or $null -eq $b -or $null -eq $c) { Write-Host 'inconclusive (a phase had no frames)'; exit 1 }
$d = $b - $a
Write-Host ('step from [slider,G,4] = {0:N2} deg   (expect ~+4 if it arrived intact); restore check C-A = {1:N2}' -f $d, ($c - $a))
if ([Math]::Abs($d) -gt 2.0) {
    Write-Host 'LINK IS ALIVE -> root cause CONFIRMED = burst overrun, not hardware.'
    Write-Host ('  workaround right now: send packets byte-spaced (~{0} ms).' -f $GapMs)
    Write-Host '  real fix: HAL_UART_ErrorCallback that clears ORE and re-arms HAL_UART_Receive_IT, and/or lower TIM3 priority below USART3.'
} else {
    Write-Host 'STILL DEAD with spacing -> bytes never reach the MCU => link/hardware direction issue, not ISR timing.'
}
