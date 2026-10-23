$ErrorActionPreference = 'Stop'
$root   = 'D:\Users\huang\Desktop\keil\PID'
$gbk    = [System.Text.Encoding]::GetEncoding(936)
$strict = New-Object System.Text.UTF8Encoding($false, $true)
$sb     = New-Object System.Text.StringBuilder
function W([string]$s) { [void]$sb.AppendLine($s) }

# ---- load repair table (UTF-8, explicit) ----
$repairRaw = [System.IO.File]::ReadAllText('D:\codex\repairs.txt', [System.Text.Encoding]::UTF8)
$repairs = @{}
foreach ($ln in ($repairRaw -split "`r?`n")) {
    if ($ln.Trim() -eq '') { continue }
    $parts = $ln -split '\|'
    $repairs[[int]$parts[0]] = @($parts[1..($parts.Count - 1)])
}
W "repair table: $($repairs.Count) lines loaded"

# ---- tolerant UTF-8 walker: corrupt 3rd byte (0x3F) becomes marker [?] ----
function Walk([byte[]]$lb) {
    $i = 0; $ok = $true; $len = $lb.Length; $nCorrupt = 0
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
                if ($b3 -eq 0x3F) { $nCorrupt++; [void]$out.Append('[?]'); $i += 3; continue }
            }
            $ok = $false; break
        }
        $ok = $false; break
    }
    return [PSCustomObject]@{ Ok = $ok; N = $nCorrupt; Text = $out.ToString() }
}

# the 10 files the compiler actually consumes, that contain non-ASCII
$files = @(
    'Core\Inc\OLED.h', 'Core\Inc\OLED_Data.h', 'Core\Inc\OLED_Font.h', 'Core\Inc\pid.h',
    'Core\Src\main.c', 'Core\Src\MPU6050.c', 'Core\Src\pid.c', 'Core\Src\TB6612.c',
    'Core\Src\OLED.c', 'Core\Src\OLED_Data.c'
)

$totConverted = 0; $totRepaired = 0; $totPassthru = 0
foreach ($rel in $files) {
    $p = Join-Path $root $rel
    $bytes = [System.IO.File]::ReadAllBytes($p)
    $endsLF = ($bytes.Length -gt 0 -and $bytes[$bytes.Length - 1] -eq 10)

    $lines = New-Object 'System.Collections.Generic.List[byte[]]'
    $cur = New-Object 'System.Collections.Generic.List[byte]'
    foreach ($b in $bytes) { if ($b -eq 10) { $lines.Add($cur.ToArray()); $cur.Clear() } else { $cur.Add($b) } }
    if ($cur.Count -gt 0) { $lines.Add($cur.ToArray()) }

    $outLines = New-Object 'System.Collections.Generic.List[byte[]]'
    $nConv = 0; $nRep = 0; $nPass = 0; $bad = New-Object 'System.Collections.Generic.List[string]'

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lb = $lines[$i]
        $hi = $false
        foreach ($b in $lb) { if ($b -ge 128) { $hi = $true; break } }
        if (-not $hi) { $outLines.Add($lb); continue }

        $r = Walk $lb
        if (-not $r.Ok) { $outLines.Add($lb); $nPass++; continue }   # genuine GBK: byte-identical passthrough

        $text = $r.Text
        if ($r.N -gt 0) {
            $lineNo = $i + 1
            if (-not $repairs.ContainsKey($lineNo)) { throw "NO REPAIR for $rel line $lineNo" }
            $repl = $repairs[$lineNo]
            $ms = [regex]::Matches($text, '\[\?\]\?*')
            if ($ms.Count -ne $repl.Count) { throw "repair count mismatch $rel line $lineNo : markers=$($ms.Count) repl=$($repl.Count)" }
            $sbT = New-Object System.Text.StringBuilder
            $pos = 0
            for ($k = 0; $k -lt $ms.Count; $k++) {
                [void]$sbT.Append($text.Substring($pos, $ms[$k].Index - $pos))
                [void]$sbT.Append($repl[$k])
                $pos = $ms[$k].Index + $ms[$k].Length
            }
            [void]$sbT.Append($text.Substring($pos))
            $text = $sbT.ToString()
            $nRep++
        }

        $enc = $gbk.GetBytes($text)
        # round-trip guard: GBK must reproduce the exact string
        if ($gbk.GetString($enc) -ne $text) {
            $bad.Add(('line {0}: NOT GBK-REPRESENTABLE -> {1}' -f ($i + 1), $text.Trim()))
        }
        $outLines.Add($enc)
        $nConv++
    }

    $ms2 = New-Object System.IO.MemoryStream
    for ($i = 0; $i -lt $outLines.Count; $i++) {
        $lb = $outLines[$i]
        $ms2.Write($lb, 0, $lb.Length)
        if ($i -lt $outLines.Count - 1 -or $endsLF) { $ms2.WriteByte(10) }
    }
    [System.IO.File]::WriteAllBytes($p, $ms2.ToArray())
    $ms2.Dispose()

    $totConverted += $nConv; $totRepaired += $nRep; $totPassthru += $nPass
    W ("{0,-28} lines={1,-5} converted={2,-5} repaired={3,-4} gbkPassthru={4,-4} bytes {5} -> {6}" -f `
        $rel, $lines.Count, $nConv, $nRep, $nPass, $bytes.Length, (Get-Item $p).Length)
    foreach ($s in $bad) { W "   !! $s" }
}
W ''
W "TOTALS: converted=$totConverted  repairedLines=$totRepaired  gbkPassthru=$totPassthru"

[System.IO.File]::WriteAllText('D:\codex\convert_report.txt', $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
Write-Output 'convert done'
