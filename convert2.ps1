$ErrorActionPreference = 'Stop'
$root   = 'D:\Users\huang\Desktop\keil\PID'
$gbk    = [System.Text.Encoding]::GetEncoding(936)
$sb     = New-Object System.Text.StringBuilder
function W([string]$s) { [void]$sb.AppendLine($s) }

# ---- table 1: corrupt-3F lines, marker-based ([?] + trailing '?') ----
$raw1 = [System.IO.File]::ReadAllText('D:\codex\repairs.txt', [System.Text.Encoding]::UTF8)
$repairs = @{}
foreach ($ln in ($raw1 -split "`r?`n")) {
    if ($ln.Trim() -eq '') { continue }
    $p = $ln -split '\|'
    $repairs[[int]$p[0]] = @($p[1..($p.Count - 1)])
}
# ---- table 2: U+FFFD lines, exact substring replace ({U} = U+FFFD) ----
$raw2 = [System.IO.File]::ReadAllText('D:\codex\repairs2.txt', [System.Text.Encoding]::UTF8)
$repairs2 = @{}
foreach ($ln in ($raw2 -split "`r?`n")) {
    if ($ln.Trim() -eq '') { continue }
    $p = $ln -split '\|'
    $repairs2[[int]$p[0]] = @($p[1], $p[2])
}
W "table1 (corrupt-3F): $($repairs.Count) lines ; table2 (U+FFFD): $($repairs2.Count) lines"

$U = [char]0xFFFD

function Walk([byte[]]$lb) {
    $i = 0; $ok = $true; $len = $lb.Length; $nC = 0; $nU = 0
    $out = New-Object System.Text.StringBuilder
    while ($i -lt $len) {
        $b = $lb[$i]
        if ($b -lt 0x80) { [void]$out.Append([char]$b); $i++; continue }
        if ($b -ge 0xC2 -and $b -le 0xDF) {
            if ($i + 1 -lt $len -and $lb[$i+1] -ge 0x80 -and $lb[$i+1] -le 0xBF) {
                [void]$out.Append([char]((($b -band 0x1F) -shl 6) -bor ($lb[$i+1] -band 0x3F))); $i += 2; continue }
            $ok = $false; break
        }
        if ($b -ge 0xE0 -and $b -le 0xEF) {
            if ($i + 2 -lt $len -and $lb[$i+1] -ge 0x80 -and $lb[$i+1] -le 0xBF) {
                $b3 = $lb[$i+2]
                if ($b -eq 0xEF -and $lb[$i+1] -eq 0xBF -and $b3 -eq 0xBD) { $nU++; [void]$out.Append($U); $i += 3; continue }
                if ($b3 -ge 0x80 -and $b3 -le 0xBF) {
                    [void]$out.Append([char]((($b -band 0x0F) -shl 12) -bor (($lb[$i+1] -band 0x3F) -shl 6) -bor ($b3 -band 0x3F)))
                    $i += 3; continue }
                if ($b3 -eq 0x3F) { $nC++; [void]$out.Append('[?]'); $i += 3; continue }
            }
            $ok = $false; break
        }
        $ok = $false; break
    }
    return [PSCustomObject]@{ Ok = $ok; N = $nC; NU = $nU; Text = $out.ToString() }
}

$files = @(
    'Core\Inc\OLED.h', 'Core\Inc\OLED_Data.h', 'Core\Inc\OLED_Font.h', 'Core\Inc\pid.h',
    'Core\Src\main.c', 'Core\Src\MPU6050.c', 'Core\Src\pid.c', 'Core\Src\TB6612.c',
    'Core\Src\OLED.c', 'Core\Src\OLED_Data.c'
)

$tConv = 0; $tRep1 = 0; $tRep2 = 0; $tPass = 0; $tBad = 0
foreach ($rel in $files) {
    $p = Join-Path $root $rel
    $bytes = [System.IO.File]::ReadAllBytes($p)
    $endsLF = ($bytes.Length -gt 0 -and $bytes[$bytes.Length - 1] -eq 10)

    $lines = New-Object 'System.Collections.Generic.List[byte[]]'
    $cur = New-Object 'System.Collections.Generic.List[byte]'
    foreach ($b in $bytes) { if ($b -eq 10) { $lines.Add($cur.ToArray()); $cur.Clear() } else { $cur.Add($b) } }
    if ($cur.Count -gt 0) { $lines.Add($cur.ToArray()) }

    $outLines = New-Object 'System.Collections.Generic.List[byte[]]'
    $nConv = 0; $nR1 = 0; $nR2 = 0; $nPass = 0
    $bad = New-Object 'System.Collections.Generic.List[string]'

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lb = $lines[$i]
        $hi = $false
        foreach ($b in $lb) { if ($b -ge 128) { $hi = $true; break } }
        if (-not $hi) { $outLines.Add($lb); continue }

        $r = Walk $lb
        if (-not $r.Ok) { $outLines.Add($lb); $nPass++; continue }
        $text = $r.Text
        $lineNo = $i + 1

        if ($r.N -gt 0) {
            if (-not $repairs.ContainsKey($lineNo)) { throw "no table1 entry: $rel line $lineNo" }
            $repl = $repairs[$lineNo]
            $ms = [regex]::Matches($text, '\[\?\]\?*')
            if ($ms.Count -ne $repl.Count) { throw "table1 mismatch $rel line $lineNo markers=$($ms.Count) repl=$($repl.Count)" }
            $sbT = New-Object System.Text.StringBuilder; $pos = 0
            for ($k = 0; $k -lt $ms.Count; $k++) {
                [void]$sbT.Append($text.Substring($pos, $ms[$k].Index - $pos))
                [void]$sbT.Append($repl[$k])
                $pos = $ms[$k].Index + $ms[$k].Length
            }
            [void]$sbT.Append($text.Substring($pos)); $text = $sbT.ToString(); $nR1++
        }

        if ($r.NU -gt 0) {
            if (-not $repairs2.ContainsKey($lineNo)) { throw "no table2 entry: $rel line $lineNo" }
            $find = $repairs2[$lineNo][0].Replace('{U}', [string]$U)
            $repl = $repairs2[$lineNo][1]
            $idx = $text.IndexOf($find)
            if ($idx -lt 0) { throw "table2 find not found: $rel line $lineNo" }
            $text = $text.Substring(0, $idx) + $repl + $text.Substring($idx + $find.Length)
            $nR2++
        }

        $enc = $gbk.GetBytes($text)
        if ($gbk.GetString($enc) -ne $text) {
            $bad.Add(('line {0}: NOT GBK-REPRESENTABLE -> {1}' -f $lineNo, $text.Trim()))
        }
        $outLines.Add($enc); $nConv++
    }

    $ms2 = New-Object System.IO.MemoryStream
    for ($i = 0; $i -lt $outLines.Count; $i++) {
        $lb = $outLines[$i]
        $ms2.Write($lb, 0, $lb.Length)
        if ($i -lt $outLines.Count - 1 -or $endsLF) { $ms2.WriteByte(10) }
    }
    [System.IO.File]::WriteAllBytes($p, $ms2.ToArray()); $ms2.Dispose()

    $tConv += $nConv; $tRep1 += $nR1; $tRep2 += $nR2; $tPass += $nPass; $tBad += $bad.Count
    W ("{0,-28} lines={1,-5} conv={2,-4} rep3F={3,-4} repFFFD={4,-3} gbkPassthru={5,-4} {6} -> {7} bytes" -f `
        $rel, $lines.Count, $nConv, $nR1, $nR2, $nPass, $bytes.Length, (Get-Item $p).Length)
    foreach ($s in $bad) { W "   !! $s" }
}
W ''
W "TOTALS: converted=$tConv rep3F=$tRep1 repFFFD=$tRep2 gbkPassthru=$tPass unrepresentable=$tBad"

[System.IO.File]::WriteAllText('D:\codex\convert_report2.txt', $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
Write-Output 'convert2 done'
