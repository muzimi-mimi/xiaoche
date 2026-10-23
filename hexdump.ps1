$ErrorActionPreference = 'Stop'
$p      = 'D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
$strict = New-Object System.Text.UTF8Encoding($false, $true)
$gbk    = [System.Text.Encoding]::GetEncoding(936)

$bytes = [System.IO.File]::ReadAllBytes($p)
$lines = New-Object 'System.Collections.Generic.List[byte[]]'
$cur   = New-Object 'System.Collections.Generic.List[byte]'
foreach ($b in $bytes) {
    if ($b -eq 10) { $lines.Add($cur.ToArray()); $cur.Clear() } else { $cur.Add($b) }
}
if ($cur.Count -gt 0) { $lines.Add($cur.ToArray()) }

$sb = New-Object System.Text.StringBuilder
foreach ($n in @(73, 74, 89, 90, 233, 236, 336, 340, 350, 493)) {
    $lb  = $lines[$n - 1]
    $hex = (($lb | ForEach-Object { $_.ToString('X2') }) -join ' ')
    $sU  = ''
    try { $sU = $strict.GetString($lb) } catch { $sU = '<<UTF8 FAIL>>' }
    $sG  = $gbk.GetString($lb)
    [void]$sb.AppendLine("LINE $n   ($($lb.Length) bytes)")
    [void]$sb.AppendLine("  HEX : $hex")
    [void]$sb.AppendLine("  UTF8: $sU")
    [void]$sb.AppendLine("  GBK : $sG")
    [void]$sb.AppendLine('')
}
[System.IO.File]::WriteAllText('D:\codex\hexdump.txt', $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
Write-Output 'hexdump written'
