$ErrorActionPreference = 'Stop'
$root   = 'D:\Users\huang\Desktop\keil\PID'
$bak    = 'D:\Users\huang\Desktop\keil\PID_bak_ansi_20261013_224656'
$gbk    = [System.Text.Encoding]::GetEncoding(936)
$strict = New-Object System.Text.UTF8Encoding($false, $true)
$sb     = New-Object System.Text.StringBuilder
function W([string]$s) { [void]$sb.AppendLine($s) }

$files = @(
    'Core\Inc\OLED.h', 'Core\Inc\OLED_Data.h', 'Core\Inc\OLED_Font.h', 'Core\Inc\pid.h',
    'Core\Src\main.c', 'Core\Src\MPU6050.c', 'Core\Src\pid.c', 'Core\Src\TB6612.c',
    'Core\Src\OLED.c', 'Core\Src\OLED_Data.c'
)
$repaired = @(89,90,92,105,107,110,112,113,114,117,123,124,126,127,128,139,141,142,143,152,154,155,156,
              233,336,338,342,343,349,358,362,364,365,432,437,451,464,466,538,543,596,609,
              91,130,131,496,497,498)

W '############ PER-FILE VERIFICATION ############'
W ''
$allReplLines = New-Object 'System.Collections.Generic.List[string]'
foreach ($rel in $files) {
    $p = Join-Path $root $rel
    $nb = [System.IO.File]::ReadAllBytes($p)
    $ob = [System.IO.File]::ReadAllBytes((Join-Path $bak $rel))

    $nFffd = 0
    $hasHigh = $false
    foreach ($b in $nb) { if ($b -ge 128) { $hasHigh = $true; break } }
    $utf8StillOk = $true
    try { [void]$strict.GetString($nb) } catch { $utf8StillOk = $false }
    # count U+FFFD produced by GBK decoding
    $txt = $gbk.GetString($nb)
    foreach ($ch in $txt.ToCharArray()) { if ($ch -eq [char]0xFFFD) { $nFffd++ } }

    # GBK 0x5C trail-byte hazard: lead 0x81-0xFE followed by 0x5C
    $haz = 0
    for ($i = 0; $i + 1 -lt $nb.Length; $i++) {
        if ($nb[$i] -ge 0x81 -and $nb[$i] -le 0xFE -and $nb[$i+1] -eq 0x5C) { $haz++; $i++ }
    }

    $verdict = ''
    if (-not $hasHigh) { $verdict = 'pure ASCII' }
    elseif ($nFffd -gt 0) { $verdict = '** HAS U+FFFD **' }
    elseif ($utf8StillOk) { $verdict = 'WARNING: still valid UTF-8?' }
    else { $verdict = 'OK: valid GBK (ANSI)' }

    W ("{0,-26} {1,-7} -> {2,-7} bytes  U+FFFD={3}  backslashTrail={4}  {5}" -f `
        $rel, $ob.Length, $nb.Length, $nFffd, $haz, $verdict)

    if ($rel -eq 'Core\Src\main.c') {
        $lines = New-Object 'System.Collections.Generic.List[byte[]]'
        $cur = New-Object 'System.Collections.Generic.List[byte]'
        foreach ($b in $nb) { if ($b -eq 10) { $lines.Add($cur.ToArray()); $cur.Clear() } else { $cur.Add($b) } }
        if ($cur.Count -gt 0) { $lines.Add($cur.ToArray()) }
        foreach ($n in $repaired) {
            if ($n -le $lines.Count) {
                $allReplLines.Add(('{0,4}| {1}' -f $n, $gbk.GetString($lines[$n-1]).TrimEnd("`r").Trim()))
            }
        }
    }
}

W ''
W '############ THE 48 REPAIRED LINES (decoded as GBK) ############'
W ''
foreach ($s in $allReplLines) { W $s }

[System.IO.File]::WriteAllText('D:\codex\verify_report.txt', $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
Write-Output 'verify report written'
