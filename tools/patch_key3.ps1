$ErrorActionPreference = 'Stop'

$p    = 'D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
$gbk  = [System.Text.Encoding]::GetEncoding(936)
$utf8 = New-Object System.Text.UTF8Encoding($false)
$bakDir = 'D:\codex\bak_key3_20261021'
New-Item -ItemType Directory -Force -Path $bakDir | Out-Null
Copy-Item $p (Join-Path $bakDir 'main.c') -Force
Copy-Item $p 'D:\codex\main.c.bak_key3_20261021' -Force

$txt  = [System.IO.File]::ReadAllText($p, $gbk)
$orig = $txt

$f1 = [System.IO.File]::ReadAllText('D:\codex\frag_keycycle.txt', $utf8)
$f2 = [System.IO.File]::ReadAllText('D:\codex\frag_stopcar.txt',  $utf8)

function NormFrag([string]$s, [string]$nl) {
    $b = $s.Replace("`r`n", "`n")
    if ($b.EndsWith("`n")) { $b = $b.Substring(0, $b.Length - 1) }
    return $b.Replace("`n", $nl)
}

# ---------- patch 1 : KeyFlag block (comment + body) ----------
$a1 = '        /* ---- PA5 '
$a2 = '        if (BlueSerial_CmdFlag)'
$i1 = $txt.IndexOf($a1)
$i2 = $txt.IndexOf($a2)
if ($i1 -lt 0) { throw 'anchor1 head not found' }
if ($i2 -lt 0) { throw 'anchor1 tail not found' }
if ($i2 -le $i1) { throw 'anchor1 order wrong' }
$head  = $txt.Substring(0, $i1)
$tail  = $txt.Substring($i2)
if     ($head.EndsWith("`r`n")) { $nl = "`r`n" }
elseif ($head.EndsWith("`n"))   { $nl = "`n" }
else                            { throw 'nl detect failed (patch1)' }
$b1    = NormFrag $f1 $nl
$txt   = $head + $b1 + $nl + $tail
Write-Host ("patch1 OK  nl={0}  block={1} lines" -f ($(if($nl -eq "`r`n"){'CRLF'}else{'LF'})), ($b1 -split "`n").Count)

# ---------- patch 2 : StopCar body ----------
$a3 = '    CarState  = ST_IDLE;'
$k  = $txt.IndexOf($a3)
if ($k -lt 0) { throw 'anchor2 not found' }
if ($txt.IndexOf($a3, $k + 1) -ge 0) { throw 'anchor2 not unique' }
$k2 = $k + $a3.Length
while ($k2 -lt $txt.Length -and $txt[$k2] -ne "`n") { $k2++ }
if ($k2 -ge $txt.Length) { throw 'anchor2 has no EOL' }
$k2++
$head2 = $txt.Substring(0, $k2)
$tail2 = $txt.Substring($k2)
if     ($head2.EndsWith("`r`n")) { $nl2 = "`r`n" }
elseif ($head2.EndsWith("`n"))   { $nl2 = "`n" }
else                             { throw 'nl detect failed (patch2)' }
$b2   = NormFrag $f2 $nl2
$txt  = $head2 + $b2 + $nl2 + $tail2
Write-Host ("patch2 OK  nl={0}  block={1} lines" -f ($(if($nl2 -eq "`r`n"){'CRLF'}else{'LF'})), ($b2 -split "`n").Count)

# ---------- GBK round-trip guard ----------
if ($gbk.GetString($gbk.GetBytes($txt)) -ne $txt) { throw 'GBK round-trip lost data' }
[System.IO.File]::WriteAllText($p, $txt, $gbk)
Write-Host 'written.'

# ---------- reverse-patch proof ----------
$back = [System.IO.File]::ReadAllText($p, $gbk)
$j1 = $back.IndexOf($a1)
$j2 = $back.IndexOf($a2)
$r  = $back.Substring(0, $j1) + $back.Substring($j2)
$m  = $r.IndexOf($a3)
$m2 = $m + $a3.Length
while ($r[$m2] -ne "`n") { $m2++ }
$m2++
$r = $r.Substring(0, $m2) + $r.Substring($m2 + $b2.Length + $nl2.Length)
Write-Host ("reverse-patch == original : {0}" -f ($r -eq $orig))

# ---------- stats ----------
$b = [System.IO.File]::ReadAllBytes($p)
$crlf = 0; $lf = 0; $bare = 0
for ($i = 0; $i -lt $b.Length; $i++) {
    if ($b[$i] -eq 10) { $lf++; if ($i -gt 0 -and $b[$i-1] -eq 13) { $crlf++ } else { $bare++ } }
}
$ob = [System.IO.File]::ReadAllBytes((Join-Path $bakDir 'main.c'))
$ocrlf = 0; $olf = 0; $obare = 0
for ($i = 0; $i -lt $ob.Length; $i++) {
    if ($ob[$i] -eq 10) { $olf++; if ($i -gt 0 -and $ob[$i-1] -eq 13) { $ocrlf++ } else { $obare++ } }
}
Write-Host ("bytes   : {0} -> {1}" -f $ob.Length, $b.Length)
Write-Host ("LF/CRLF/bare : {0}/{1}/{2} -> {3}/{4}/{5}" -f $olf, $ocrlf, $obare, $lf, $crlf, $bare)
Write-Host ("BOM     : {0:X2} {1:X2} {2:X2}" -f $b[0], $b[1], $b[2])
$lines  = [System.IO.File]::ReadAllLines($p, $gbk)
$olines = [System.IO.File]::ReadAllLines((Join-Path $bakDir 'main.c'), $gbk)
Write-Host ("lines   : {0} -> {1}  (delta {2})" -f $olines.Count, $lines.Count, ($lines.Count - $olines.Count))
Write-Host ("last    : {0}" -f $lines[$lines.Count - 1])
Write-Host ("FFFD    : {0}" -f ([regex]::Matches($txt, [char]0xFFFD)).Count)
