$ErrorActionPreference = 'Stop'
$bak    = 'D:\Users\huang\Desktop\keil\PID_bak_ansi_20261013_224656\Core\Src\main.c'
$strict = New-Object System.Text.UTF8Encoding($false, $true)
$sb     = New-Object System.Text.StringBuilder

$bytes = [System.IO.File]::ReadAllBytes($bak)
$lines = New-Object 'System.Collections.Generic.List[byte[]]'
$cur   = New-Object 'System.Collections.Generic.List[byte]'
foreach ($b in $bytes) { if ($b -eq 10) { $lines.Add($cur.ToArray()); $cur.Clear() } else { $cur.Add($b) } }
if ($cur.Count -gt 0) { $lines.Add($cur.ToArray()) }

foreach ($n in @(91, 130, 131, 496, 497, 498)) {
    $lb  = $lines[$n - 1]
    $hex = (($lb | ForEach-Object { $_.ToString('X2') }) -join ' ')
    $s   = $strict.GetString($lb)
    # mark U+FFFD explicitly
    $marked = $s -replace [char]0xFFFD, '<U+FFFD>'
    [void]$sb.AppendLine("LINE $n   ($($lb.Length) bytes)")
    [void]$sb.AppendLine("  HEX   : $hex")
    [void]$sb.AppendLine("  UTF8  : $marked")
    [void]$sb.AppendLine('')
}

# global census of U+FFFD across the whole project source set
[void]$sb.AppendLine('=== U+FFFD census across all .c/.h under PID (live tree) ===')
$root = 'D:\Users\huang\Desktop\keil\PID_bak_ansi_20261013_224656'
$files = Get-ChildItem -Path $root -Recurse -File -Include *.c,*.h |
    Where-Object { $_.FullName -notmatch '\\(Objects|Listings|RTE|DebugConfig)\\' }
foreach ($f in $files) {
    $b = [System.IO.File]::ReadAllBytes($f.FullName)
    $n = 0
    for ($i = 0; $i + 2 -lt $b.Length; $i++) {
        if ($b[$i] -eq 0xEF -and $b[$i+1] -eq 0xBF -and $b[$i+2] -eq 0xBD) { $n++ }
    }
    if ($n -gt 0) { [void]$sb.AppendLine(('{0,-60} U+FFFD x {1}' -f $f.FullName.Substring($root.Length + 1), $n)) }
}

[System.IO.File]::WriteAllText('D:\codex\fffd_report.txt', $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
Write-Output 'fffd report written'
