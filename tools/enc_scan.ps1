$ErrorActionPreference = 'Stop'
$root   = 'D:\Users\huang\Desktop\keil\PID'
$strict = New-Object System.Text.UTF8Encoding($false, $true)
$gbk    = [System.Text.Encoding]::GetEncoding(936)
$sb     = New-Object System.Text.StringBuilder

function W([string]$s) { [void]$sb.AppendLine($s) }

$files = @(
    'Core\Inc\OLED.h',
    'Core\Inc\OLED_Data.h',
    'Core\Inc\OLED_Font.h',
    'Core\Inc\PID.h',
    'Core\Src\main.c',
    'Core\Src\MPU6050.c',
    'Core\Src\pid.c',
    'Core\Src\TB6612.c',
    'Core\Src\OLED.c',
    'Core\Src\OLED_Data.c',
    'Core\Src\_bak_oled_20261010\OLED.c',
    'Core\Src\_bak_oled_20261010\OLED_Data.c',
    '_bak_sm_20261012_230516\Core\Src\main.c'
)

foreach ($rel in $files) {
    $p = Join-Path $root $rel
    if (-not (Test-Path -LiteralPath $p)) { W "MISSING: $rel"; continue }
    $bytes = [System.IO.File]::ReadAllBytes($p)

    # split on LF, keeping CR inside each line so bytes round-trip exactly
    $lines = New-Object 'System.Collections.Generic.List[byte[]]'
    $cur   = New-Object 'System.Collections.Generic.List[byte]'
    foreach ($b in $bytes) {
        if ($b -eq 10) { $lines.Add($cur.ToArray()); $cur.Clear() }
        else           { $cur.Add($b) }
    }
    if ($cur.Count -gt 0) { $lines.Add($cur.ToArray()) }

    $nAscii = 0; $nU8 = 0; $nGbk = 0; $nBad = 0
    $u8List  = New-Object 'System.Collections.Generic.List[string]'
    $gbkList = New-Object 'System.Collections.Generic.List[string]'
    $badList = New-Object 'System.Collections.Generic.List[string]'

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lb = $lines[$i]
        $hi = $false
        foreach ($b in $lb) { if ($b -ge 128) { $hi = $true; break } }
        if (-not $hi) { $nAscii++; continue }

        $okU = $true; $sU = ''
        try { $sU = $strict.GetString($lb) } catch { $okU = $false }
        $sG = $gbk.GetString($lb)

        if ($okU) {
            $nU8++
            $u8List.Add(('{0,4}| {1}' -f ($i + 1), $sU.TrimEnd("`r").Trim()))
        } elseif ($sG.IndexOf([char]0xFFFD) -lt 0) {
            $nGbk++
            $gbkList.Add(('{0,4}| {1}' -f ($i + 1), $sG.TrimEnd("`r").Trim()))
        } else {
            $nBad++
            $badList.Add(('{0,4}| {1}' -f ($i + 1), $sG.TrimEnd("`r").Trim()))
        }
    }

    W '================================================================'
    W "FILE : $rel"
    W "SIZE : $($bytes.Length) bytes, $($lines.Count) lines"
    W "SPLIT: ascii=$nAscii  utf8=$nU8  gbk=$nGbk  UNDECODABLE=$nBad"

    if ($nBad -eq 0 -and $nU8 -gt 0 -and $nGbk -eq 0) { W 'CLASS: pure UTF-8  -> simple whole-file convert' }
    elseif ($nBad -eq 0 -and $nU8 -eq 0 -and $nGbk -gt 0) { W 'CLASS: pure GBK    -> already ANSI, leave alone' }
    elseif ($nBad -eq 0 -and $nU8 -gt 0 -and $nGbk -gt 0) { W 'CLASS: MIXED       -> per-line convert (UTF-8 lines only)' }
    else { W 'CLASS: *** NEEDS MANUAL REVIEW ***' }
    W ''

    if ($nU8 -gt 0 -and $nGbk -gt 0) {
        W "---- UTF-8 lines ($nU8) ----"
        foreach ($s in $u8List) { W $s }
        W ''
        W "---- GBK lines ($nGbk) ----"
        foreach ($s in $gbkList) { W $s }
        W ''
    }
    if ($nBad -gt 0) {
        W "---- UNDECODABLE ($nBad) ----"
        foreach ($s in $badList) { W $s }
        W ''
    }
    W ''
}

[System.IO.File]::WriteAllText('D:\codex\enc_report.txt', $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
Write-Output 'report written to D:\codex\enc_report.txt'
Write-Output ("length = " + $sb.Length)
