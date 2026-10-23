$ErrorActionPreference = 'Stop'
$root = 'D:\Users\huang\Desktop\keil\PID'
$bak  = 'D:\Users\huang\Desktop\keil\PID_bak_ansi_20261013_224656'
$gbk  = [System.Text.Encoding]::GetEncoding(936)
$sb   = New-Object System.Text.StringBuilder
function W([string]$s) { [void]$sb.AppendLine($s) }

function Split-Lines([byte[]]$b) {
    $l = New-Object 'System.Collections.Generic.List[byte[]]'
    $c = New-Object 'System.Collections.Generic.List[byte]'
    foreach ($x in $b) { if ($x -eq 10) { $l.Add($c.ToArray()); $c.Clear() } else { $c.Add($x) } }
    if ($c.Count -gt 0) { $l.Add($c.ToArray()) }
    return $l
}
function Is-Ascii([byte[]]$l) { foreach ($x in $l) { if ($x -ge 128) { return $false } } return $true }
function Bytes-Equal([byte[]]$a, [byte[]]$b) {
    if ($a.Length -ne $b.Length) { return $false }
    for ($i = 0; $i -lt $a.Length; $i++) { if ($a[$i] -ne $b[$i]) { return $false } }
    return $true
}

$files = @(
    'Core\Inc\OLED.h', 'Core\Inc\OLED_Data.h', 'Core\Inc\OLED_Font.h', 'Core\Inc\pid.h',
    'Core\Src\main.c', 'Core\Src\MPU6050.c', 'Core\Src\pid.c', 'Core\Src\TB6612.c',
    'Core\Src\OLED.c', 'Core\Src\OLED_Data.c'
)

$fail = 0
W '########## INTEGRITY: old (backup) vs new (converted) ##########'
W ''
foreach ($rel in $files) {
    $ol = Split-Lines ([System.IO.File]::ReadAllBytes((Join-Path $bak $rel)))
    $nl = Split-Lines ([System.IO.File]::ReadAllBytes((Join-Path $root $rel)))

    $lineCountOk = ($ol.Count -eq $nl.Count)
    $changed = 0; $badAscii = 0; $changedAllComment = $true
    $min = [Math]::Min($ol.Count, $nl.Count)

    for ($i = 0; $i -lt $min; $i++) {
        $o = $ol[$i]; $n = $nl[$i]
        $oa = Is-Ascii $o; $na = Is-Ascii $n
        if ($oa -and $na) {
            if (-not (Bytes-Equal $o $n)) { $badAscii++; if ($badAscii -le 3) { W ("   !! line $($i+1)) ASCII LINE CHANGED: " + $gbk.GetString($n).Trim()) } }
        } else {
            $changed++
            # every changed line must contain a comment marker
            $s = $gbk.GetString($n)
            if ($s -notmatch '//|/\*|\*') { $changedAllComment = $false; W "   !! line $($i+1) changed but has NO comment marker: $s" }
        }
    }
    if ($badAscii -gt 0 -or -not $lineCountOk -or -not $changedAllComment) { $fail++ }

    W ("{0,-26} lines old={1,-5} new={2,-5} {3}  changedLines={4,-4} asciiLinesAltered={5}  {6}" -f `
        $rel, $ol.Count, $nl.Count, $(if ($lineCountOk) { 'countOK' } else { 'COUNT-MISMATCH' }), `
        $changed, $badAscii, $(if ($badAscii -eq 0 -and $lineCountOk -and $changedAllComment) { 'PASS' } else { 'FAIL' }))
}
W ''
W $(if ($fail -eq 0) { 'RESULT: PASS - every pure-ASCII line is byte-identical; all changed lines are comments.' }
    else { "RESULT: *** $fail FILE(S) FAILED ***" })

[System.IO.File]::WriteAllText('D:\codex\integrity_report.txt', $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
Write-Output 'integrity report written'
