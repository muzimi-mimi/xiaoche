$ErrorActionPreference = 'Stop'
$p   = 'D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
$bak = 'D:\codex\bak_key3_20261021\main.c'
$gbk = [System.Text.Encoding]::GetEncoding(936)
$utf8 = New-Object System.Text.UTF8Encoding($false)

$orig = [System.IO.File]::ReadAllText($bak, $gbk)
$txt  = [System.IO.File]::ReadAllText($p,   $gbk)

$f1 = [System.IO.File]::ReadAllText('D:\codex\frag_keycycle.txt', $utf8).Replace("`r`n","`n").TrimEnd("`n").Replace("`n","`r`n")
$f2 = [System.IO.File]::ReadAllText('D:\codex\frag_stopcar.txt',  $utf8).Replace("`r`n","`n").TrimEnd("`n").Replace("`n","`r`n")

$a1 = '        /* ---- PA5 '
$a2 = '        if (BlueSerial_CmdFlag)'
$a3 = '    CarState  = ST_IDLE;'

# --- rebuild what the file would be if we put the ORIGINAL span back and drop frag2 ---
$o1 = $orig.IndexOf($a1); $o2 = $orig.IndexOf($a2)
$n1 = $txt.IndexOf($a1);  $n2 = $txt.IndexOf($a2)
$oldSpan = $orig.Substring($o1, $o2 - $o1)
$r = $txt.Substring(0, $n1) + $oldSpan + $txt.Substring($n2)

$m = $r.IndexOf($a3) + $a3.Length
while ($r[$m] -ne "`n") { $m++ }
$m++
$r = $r.Substring(0, $m) + $r.Substring($m + $f2.Length + 2)

Write-Host ("reverse-patch == original : {0}" -f ($r -eq $orig))
if ($r -ne $orig) {
    $i = 0; $lim = [Math]::Min($r.Length, $orig.Length)
    while ($i -lt $lim -and $r[$i] -eq $orig[$i]) { $i++ }
    Write-Host ("first diff at char {0} / lens {1} vs {2}" -f $i, $r.Length, $orig.Length)
    Write-Host ("  orig: [{0}]" -f $orig.Substring([Math]::Max(0,$i-40), 80).Replace("`r","<CR>").Replace("`n","<LF>"))
    Write-Host ("  new : [{0}]" -f $r.Substring([Math]::Max(0,$i-40), 80).Replace("`r","<CR>").Replace("`n","<LF>"))
}

# --- does the new file contain the fragments verbatim, exactly once each ---
Write-Host ("frag1 occurrences : {0}" -f ([regex]::Matches($txt, [regex]::Escape($f1))).Count)
Write-Host ("frag2 occurrences : {0}" -f ([regex]::Matches($txt, [regex]::Escape($f2))).Count)

# --- only 2 regions differ? walk line by line on the CRLF-normalised view ---
$ol = ($orig -split "`n"); $nl2 = ($txt -split "`n")
Write-Host ("orig lines {0} / new lines {1}" -f $ol.Count, $nl2.Count)

$L = [System.IO.File]::ReadAllLines($p, $gbk)
Write-Host '--- patched region 1 (around PA5 comment) ---'
for ($i = 0; $i -lt $L.Count; $i++) {
    if ($L[$i] -like '*---- PA5 *') { for ($j = $i; $j -lt [Math]::Min($i + 60, $L.Count); $j++) { "{0,5}| {1}" -f ($j + 1), $L[$j] }; break }
}
Write-Host '--- StopCar ---'
for ($i = 0; $i -lt $L.Count; $i++) {
    if ($L[$i] -match '^void StopCar\(void\)') { for ($j = $i; $j -lt [Math]::Min($i + 18, $L.Count); $j++) { "{0,5}| {1}" -f ($j + 1), $L[$j] }; break }
}
