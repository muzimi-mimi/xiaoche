param(
    [int]$Seconds     = 24,
    [int]$HoldSec     = 3,
    [int]$SendMs      = 100,
    [int]$WaitSeconds = 180,
    [int]$GraceSec    = 5,
    [switch]$Erect,
    [string]$Tag      = (Get-Date -Format 'yyyyMMdd_HHmmss')
)
$ErrorActionPreference = 'Stop'
$OutCsv = "D:\codex\cap_$Tag.csv"
$OutRaw = "D:\codex\cap_$Tag.raw"

# Values deliberately avoid the digits 0/1 and letters T/t, because firmware treats
# those as bare commands when a packet's leading '[' is ever lost (BlueSerial.c:87).
# 2 => dead-zoned to 0 inside firmware (straight); +/-66 => full steering rate (66/60 = 1.10)
$STRAIGHT = 2; $TURNP = 66; $TURNN = -66
$RX = '\[plot:(-?[0-9.]+),(-?[0-9.]+),(-?\d+),(-?\d+),(-?\d+),(-?[0-9.]+)'
$RX2 = 'plot:(-?[0-9.]+),(-?[0-9.]+),(-?\d+),(-?\d+),(-?\d+),(-?[0-9.]+)'

function Try-Open($n) {
    $sp = New-Object System.IO.Ports.SerialPort $n, 9600, 'None', 8, 'One'
    $sp.WriteTimeout = 500; $sp.ReadTimeout = 500
    try { $sp.Open(); return $sp } catch { $sp.Dispose(); return $null }
}

'waiting for COM7 (up to {0} s) - disconnect it in VOFA+ now...' -f $WaitSeconds
$port = $null; $dl = (Get-Date).AddSeconds($WaitSeconds)
while ($null -eq $port -and (Get-Date) -lt $dl) { $port = Try-Open 'COM7'; if ($null -eq $port) { Start-Sleep -Milliseconds 500 } }
if ($null -eq $port) { 'TIMEOUT: COM7 still held by VOFA+.'; exit 1 }

# schedule: straight, +turn, straight, -turn, repeated
$TotalSec = $GraceSec + $Seconds
$nSeg = [Math]::Ceiling($Seconds / $HoldSec)
$sched = 0..($nSeg - 1) | ForEach-Object { @(,$STRAIGHT + ,$TURNP + ,$STRAIGHT + ,$TURNN)[$_%4] }

'COM7 acquired. {0} s straight grace + {1} s of steering steps ({2} s each, {3} ms TX period), total {4} s:' -f $GraceSec, $Seconds, $HoldSec, $SendMs, $TotalSec
($sched | ForEach-Object { if ($_ -eq $TURNP) {'+66'} elseif ($_ -eq $TURNN) {'-66'} else {'straight'} }) -join ' | '
if ($Erect) { 'sending bare "1" to self-erect -- CAR WILL MOVE, clear the floor' } else { 'NOT auto-erecting; stand the car yourself' }

$rows = New-Object System.Collections.ArrayList
$raw  = New-Object System.Text.StringBuilder
$t0 = Get-Date; $tEnd = $t0.AddSeconds($TotalSec); $nextTx = $t0; $segIdx = 0; $curRh = $STRAIGHT
try {
    if ($Erect) { Start-Sleep -Milliseconds 500; $port.Write('1') }
    while ((Get-Date) -lt $tEnd) {
        $now = Get-Date
        if ($now -ge $nextTx) {
            $el = ($now - $t0).TotalSeconds
            if ($el -lt $GraceSec) {
                $segIdx = -1; $curRh = $STRAIGHT          # grace: dead-stop, lets you confirm it is stable
            } else {
                $segIdx = [int][Math]::Floor(($el - $GraceSec) / $HoldSec)
                if ($segIdx -ge $nSeg) { $segIdx = $nSeg - 1 }
                $curRh = $sched[$segIdx]
            }
            $port.Write("[joystick,2,2,$curRh,2]")
            $nextTx = $now.AddMilliseconds($SendMs)
        }
        try { $n = $port.BytesToRead; if ($n -gt 0) { $s = $port.ReadExisting(); [void]$raw.Append($s)
            foreach ($mm in [regex]::Matches($s, $RX2)) {
                [void]$rows.Add([pscustomobject]@{
                    ms = ($now - $t0).TotalMilliseconds
                    seg = $segIdx; rh = $curRh
                    tgt = [double]$mm.Groups[1].Value; act = [double]$mm.Groups[2].Value
                    l = [int]$mm.Groups[3].Value; r = [int]$mm.Groups[4].Value
                    dif = [int]$mm.Groups[5].Value; ang = [double]$mm.Groups[6].Value })
            } } } catch {}
        Start-Sleep -Milliseconds 20
    }
    $port.Write("[joystick,2,2,$STRAIGHT,2]")   # always finish pointing straight
} finally { $port.Close(); $port.Dispose() }

Set-Content -Path $OutRaw -Value $raw.ToString() -Encoding ASCII -NoNewline
if ($rows.Count -eq 0) { 'NO FRAMES. Is the car powered and Bluetooth still linked?'; exit 1 }
$rows | Export-Csv -Path $OutCsv -NoTypeInformation
'frames={0}  rate={1:N1} Hz  raw->{2}  csv->{3}' -f $rows.Count, ($rows.Count / $TotalSec), $OutRaw, $OutCsv

'=== per-segment (tgt=TurnTargetRamp  act=DifSpeedFilter) ==='
'{0,-4} {1,-8} {2,5} {3,8} {4,8} {5,8} {6,8} {7,7} {8,7}' -f 'seg','cmd','n','tgtAvg','actAvg','difAvg','difSAT%','angSD','angP2P'
$rows | Group-Object seg | ForEach-Object {
    $g = $_.Group; $d = $g.dif; $a = $g.ang
    $sat = 100.0 * (@($d | Where-Object { [Math]::Abs($_) -ge 49 })).Count / $d.Count
    $avg = ($a | Measure-Object -Average).Average
    $sd  = [Math]::Sqrt(((($a | ForEach-Object { ($_ - $avg) * ($_ - $avg) } | Measure-Object -Sum).Sum) / $a.Count))
    $cmd = if ($g[0].rh -eq $TURNP) {'+66'} elseif ($g[0].rh -eq $TURNN) {'-66'} else {'straight'}
    '{0,-4} {1,-8} {2,5} {3,8:N3} {4,8:N3} {5,8:N1} {6,8:N1} {7,7:N2} {8,7:N1}' -f `
        $_.Name, $cmd, $d.Count, (($g.tgt | Measure-Object -Average).Average), (($g.act | Measure-Object -Average).Average), `
        (($d | Measure-Object -Average).Average), $sat, $sd, (($a | Measure-Object -Maximum).Maximum - ($a | Measure-Object -Minimum).Minimum)
}

''
'=== whole-run verdict numbers ==='
$maxStep = 0.0; $maxRate = 0.0
for ($i=1; $i -lt $rows.Count; $i++) {
    $v = [Math]::Abs($rows[$i].tgt - $rows[$i-1].tgt)
    if ($v -gt $maxStep) { $maxStep = $v }
    $dt = ($rows[$i].ms - $rows[$i-1].ms)
    if ($dt -gt 1) { $r = $v / ($dt / 1000.0); if ($r -gt $maxRate) { $maxRate = $r } }   # rev/s
}
$satAll = 100.0 * (@($rows.dif | Where-Object { [Math]::Abs($_) -ge 49 })).Count / $rows.Count
$flip = 0; for ($i=1; $i -lt $rows.Count; $i++) { if ($rows[$i].dif * $rows[$i-1].dif -lt 0) { $flip++ } }
$slip = 0; foreach ($x in $rows) { if ([Math]::Abs($x.tgt) -ge 0.5 -and [Math]::Abs($x.act) -lt 0.15) { $slip++ } }
'target peak          = {0:N3} rev/s   (PIVOT_RATE=1.0, RH66/60=1.10)' -f (($rows.tgt | Measure-Object -Maximum).Maximum)
'max ramp step/frame  = {0:N3}   (print period ~81ms spans 1-2 ramp ticks, so not a verdict on its own)' -f $maxStep
'PEAK TARGET SLEW     = {0:N2} rev/s   (spec = 0.2 per 50ms = 4.0;  <=4.5 ramp works,  >6 old fw w/ hard step)' -f $maxRate
'DifPWM saturated     = {0:N1} %       (was the +-50 pin that caused the shake)' -f $satAll
'DifPWM sign flips    = {0} ({1:N2}/s) (limit-cycle chatter indicator)' -f $flip, ($flip/$TotalSec)
'slip frames          = {0}            (|tgt|>=0.5 but |act|<0.15 => wheels spinning, car not turning)' -f $slip
''
'COM7 released - reconnect VOFA+ now.'
