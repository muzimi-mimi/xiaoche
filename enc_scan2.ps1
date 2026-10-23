$ErrorActionPreference = 'Stop'
$root   = 'D:\Users\huang\Desktop\keil\PID'
$strict = New-Object System.Text.UTF8Encoding($false, $true)
$gbk    = [System.Text.Encoding]::GetEncoding(936)
$sb     = New-Object System.Text.StringBuilder

function W([string]$s) { [void]$sb.AppendLine($s) }

# Tolerant UTF-8 walker.
# Returns: Ok (structure is UTF-8), Corrupt (list of byte offsets where 3rd byte was 0x3F),
#          Text (decoded, corrupt bytes shown as [?])
function Walk-Utf8([byte[]]$lb) {
    $i = 0; $ok = $true; $len = $lb.Length
    $corrupt = New-Object 'System.Collections.Generic.List[int]'
    $out = New-Object System.Text.StringBuilder
    while ($i -lt $len) {
        $b = $lb[$i]
        if ($b -lt 0x80) { [void]$out.Append([char]$b); $i++; continue }
        if ($b -ge 0xC2 -and $b -le 0xDF) {
            if ($i + 1 -lt $len -and $lb[$i+1] -ge 0x80 -and $lb[$i+1] -le 0xBF) {
                [void]$out.Append([char]((($b -band 0x1F) -shl 6) -bor ($lb[$i+1] -band 0x3F))); $i += 2; continue
            }
            $ok = $false; break
        }
        if ($b -ge 0xE0 -and $b -le 0xEF) {
            if ($i + 2 -lt $len -and $lb[$i+1] -ge 0x80 -and $lb[$i+1] -le 0xBF) {
                $b3 = $lb[$i+2]
                if ($b3 -ge 0x80 -and $b3 -le 0xBF) {
                    [void]$out.Append([char]((($b -band 0x0F) -shl 12) -bor (($lb[$i+1] -band 0x3F) -shl 6) -bor ($b3 -band 0x3F)))
                    $i += 3; continue
                }
                if ($b3 -eq 0x3F) {
                    $corrupt.Add($i + 2)
                    [void]$out.Append('[').Append([char]0x3F).Append(']')
                    $i += 3; continue
                }
            }
            $ok = $false; break
        }
        $ok = $false; break
    }
    return [PSCustomObject]@{ Ok = $ok; Corrupt = $corrupt; Text = $out.ToString() }
}

$files = @(
    'Core\Inc\OLED.h', 'Core\Inc\OLED_Data.h', 'Core\Inc\OLED_Font.h', 'Core\Inc\PID.h',
    'Core\Src\main.c', 'Core\Src\MPU6050.c', 'Core\Src\pid.c', 'Core\Src\TB6612.c',
    'Core\Src\OLED.c', 'Core\Src\OLED_Data.c',
    'Core\Src\_bak_oled_20261010\OLED.c', 'Core\Src\_bak_oled_20261010\OLED_Data.c',
    '_bak_sm_20261012_230516\Core\Src\main.c'
)

$grandCorrupt = 0
foreach ($rel in $files) {
    $p = Join-Path $root $rel
    if (-not (Test-Path -LiteralPath $p)) { continue }
    $bytes = [System.IO.File]::ReadAllBytes($p)
    $lines = New-Object 'System.Collections.Generic.List[byte[]]'
    $cur   = New-Object 'System.Collections.Generic.List[byte]'
    foreach ($b in $bytes) { if ($b -eq 10) { $lines.Add($cur.ToArray()); $cur.Clear() } else { $cur.Add($b) } }
    if ($cur.Count -gt 0) { $lines.Add($cur.ToArray()) }

    $nAscii = 0; $nClean = 0; $nCorrupt = 0; $nGbk = 0
    $corruptLines = New-Object 'System.Collections.Generic.List[string]'
    $totalCorrupt = 0

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lb = $lines[$i]
        $hi = $false
        foreach ($b in $lb) { if ($b -ge 128) { $hi = $true; break } }
        if (-not $hi) { $nAscii++; continue }

        $r = Walk-Utf8 $lb
        if ($r.Ok) {
            if ($r.Corrupt.Count -eq 0) { $nClean++ }
            else {
                $nCorrupt++; $totalCorrupt += $r.Corrupt.Count
                $corruptLines.Add(('{0,4}| corrupt={1} | {2}' -f ($i + 1), $r.Corrupt.Count, $r.Text.TrimEnd("`r").Trim()))
            }
        } else { $nGbk++ }
    }
    $grandCorrupt += $totalCorrupt

    W '================================================================'
    W "FILE : $rel"
    W "LINES: ascii=$nAscii  cleanUTF8=$nClean  CORRUPTED-UTF8=$nCorrupt  gbk=$nGbk"
    W "CORRUPT BYTE COUNT: $totalCorrupt"
    W ''
    if ($nCorrupt -gt 0) {
        W "---- corrupted UTF-8 lines ($nCorrupt) ----"
        foreach ($s in $corruptLines) { W $s }
        W ''
    }
    W ''
}
W "GRAND TOTAL CORRUPTED BYTES ACROSS ALL FILES: $grandCorrupt"

[System.IO.File]::WriteAllText('D:\codex\enc_report2.txt', $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
Write-Output 'report2 written'
