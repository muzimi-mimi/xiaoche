param(
    [int]$Seconds = 30,
    [int]$WaitSeconds = 180,
    [string]$Out = ("D:\codex\raw_{0}.txt" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
)
$ErrorActionPreference = 'Stop'

# 6 channels, format is  "[plot:%f,%f,%d,%d,%d,%f\n]"  (note: \n sits BEFORE the ']' in firmware)
$RX = '\[plot:(-?[0-9.]+),(-?[0-9.]+),(-?\d+),(-?\d+),(-?\d+),(-?[0-9.]+)'

function Get-Stats($vals) {
    $m = $vals | Measure-Object -Minimum -Maximum -Average
    $var = (($vals | ForEach-Object { ($_ - $m.Average) * ($_ - $m.Average) } | Measure-Object -Sum).Sum) / $vals.Count
    [pscustomobject]@{ Min = $m.Minimum; Max = $m.Maximum; Avg = $m.Average; Sd = [Math]::Sqrt($var) }
}

function Try-Open($portName) {
    $sp = New-Object System.IO.Ports.SerialPort $portName, 9600, 'None', 8, 'One'
    $sp.ReadTimeout = 500
    try { $sp.Open(); return $sp } catch { $sp.Dispose(); return $null }
}

'waiting for COM7 to be released by VOFA+ (up to {0} s)...' -f $WaitSeconds
$sp = $null
$deadline = (Get-Date).AddSeconds($WaitSeconds)
while ($null -eq $sp -and (Get-Date) -lt $deadline) {
    $sp = Try-Open 'COM7'
    if ($null -eq $sp) { Start-Sleep -Milliseconds 500 }
}
if ($null -eq $sp) { 'TIMEOUT: COM7 still busy. Disconnect it in VOFA+ first.'; exit 1 }
'COM7 acquired -> capturing {0} s -> {1}' -f $Seconds, $Out

$buf = New-Object System.Text.StringBuilder
$capEnd = (Get-Date).AddSeconds($Seconds)
try {
    while ((Get-Date) -lt $capEnd) {
        try { $n = $sp.BytesToRead; if ($n -gt 0) { [void]$buf.Append($sp.ReadExisting()) } } catch {}
        Start-Sleep -Milliseconds 50
    }
} finally { $sp.Close(); $sp.Dispose() }

$txt = $buf.ToString()
Set-Content -Path $Out -Value $txt -Encoding ASCII -NoNewline
$m = [regex]::Matches($txt, $RX)
if ($m.Count -eq 0) { 'NO FRAMES PARSED. bytes={0}' -f $txt.Length; '--- head ---'; $txt.Substring(0, [Math]::Min(200, $txt.Length)); exit 1 }

$Tgt = $m | ForEach-Object { [double]$_.Groups[1].Value }   # TurnTargetRamp
$Act = $m | ForEach-Object { [double]$_.Groups[2].Value }   # DifSpeedFilter
$L   = $m | ForEach-Object { [int]  $_.Groups[3].Value }
$R   = $m | ForEach-Object { [int]  $_.Groups[4].Value }
$Dif = $m | ForEach-Object { [int]  $_.Groups[5].Value }
$Ang = $m | ForEach-Object { [double]$_.Groups[6].Value }

$sT = Get-Stats $Tgt; $sA = Get-Stats $Act; $sD = Get-Stats $Dif; $sG = Get-Stats $Ang

'=== raw saved: {0}  ({1} bytes) ===' -f $Out, $txt.Length
'frames={0}  parsed={1:N1}%  rate={2:N1} Hz  (expected ~18 Hz at 9600 baud w/ 6ch)' -f `
    $m.Count, (100.0 * $m.Count / ([regex]::Matches($txt, '\[plot:')).Count), ($m.Count / $Seconds)

''
'--- 1) DifPWM saturation (clamp +/-50) : the jitter suspect ---'
$satD = ($Dif | Where-Object { [Math]::Abs($_) -ge 49 }).Count
'min={0} max={1} avg={2:N1} sd={3:N1}   SATURATED(|.|>=49) = {4} frames = {5:N1}%' -f `
    $sD.Min, $sD.Max, $sD.Avg, $sD.Sd, $satD, (100.0 * $satD / $Dif.Count)
$signflip = 0; for ($i = 1; $i -lt $Dif.Count; $i++) { if ($Dif[$i] * $Dif[$i-1] -lt 0) { $signflip++ } }
'sign flips (DifPWM + <-> -) = {0}  ({1:N2} per s)  <- limit-cycle chatter indicator' -f $signflip, ($signflip / $Seconds)

''
'--- 2) Target slew ramp (TURN_SLEW=0.2 per 50ms) ---'
$maxStep = 0.0; for ($i = 1; $i -lt $Tgt.Count; $i++) { $d = [Math]::Abs($Tgt[$i] - $Tgt[$i-1]); if ($d -gt $maxStep) { $maxStep = $d } }
'target min={0:N3} max={1:N3}   biggest single-frame jump = {2:N3}' -f $sT.Min, $sT.Max, $maxStep
if ($maxStep -le 0.30) { '  OK: ramp is limiting (no step to full rate)' } else { '  WARNING: step {0:N2} looks like the old hard jump' -f $maxStep }

''
'--- 3) Slip check: commanded rate vs measured rate ---'
'target  avg={0:N3} |actual avg={1:N3}' -f $sT.Avg, $sA.Avg
$big = 0
for ($i = 0; $i -lt $Tgt.Count; $i++) { if ([Math]::Abs($Tgt[$i]) -ge 0.5 -and [Math]::Abs($Act[$i]) -lt 0.15) { $big++ } }
'frames with |target|>=0.5 but |actual|<0.15 (wheel slip / not turning) = {0} ({1:N1}%)' -f $big, (100.0 * $big / $Tgt.Count)

''
'--- 4) Balance loop jitter (Angle) ---'
'angle avg={0:N3} sd={1:N3} peak-to-peak={2:N3} deg' -f $sG.Avg, $sG.Sd, ($sG.Max - $sG.Min)
$satL = ($L | Where-Object { [Math]::Abs($_) -ge 79 }).Count; $satR = ($R | Where-Object { [Math]::Abs($_) -ge 79 }).Count
'LeftPWM  min={0} max={1}  clamped(|.|>=79)={2:N1}%' -f (($L | Measure-Object -Minimum).Minimum), (($L | Measure-Object -Maximum).Maximum), (100.0 * $satL / $L.Count)
'RightPWM min={0} max={1}  clamped(|.|>=79)={2:N1}%' -f (($R | Measure-Object -Minimum).Minimum), (($R | Measure-Object -Maximum).Maximum), (100.0 * $satR / $R.Count)
''
'COM7 released. You can reconnect VOFA+ now.'
