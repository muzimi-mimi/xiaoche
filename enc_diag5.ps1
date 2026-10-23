$ErrorActionPreference = 'Continue'
$gbk = [System.Text.Encoding]::GetEncoding(936)
$dirs = @('D:\Users\huang\Desktop\keil\PID\Core\Src', 'D:\Users\huang\Desktop\keil\PID\Core\Inc')

Write-Host "=== GBK trail-byte 0x5C hazard scan ==="
Write-Host "(a GBK char whose 2nd byte is 0x5C = a backslash to the C compiler)"
Write-Host ""

$files = @()
foreach ($d in $dirs) {
  if (Test-Path -LiteralPath $d) {
    $files += Get-ChildItem -LiteralPath $d -File | Where-Object { $_.Extension -in '.c', '.h' }
  }
}

$total = 0
foreach ($f in $files) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  # only scan files that really are GBK
  $strict = New-Object System.Text.UTF8Encoding($false, $true)
  $isUtf8 = $true
  try { [void]$strict.GetString($bytes) } catch { $isUtf8 = $false }
  $tag = if ($isUtf8) { 'UTF8' } else { 'GBK ' }

  $txt = $gbk.GetString($bytes)
  $lines = $txt -split "`r`n|`n"
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $ln = $lines[$i]
    $chars = $ln.ToCharArray()
    for ($k = 0; $k -lt $chars.Length; $k++) {
      if ([int]$chars[$k] -gt 127) {
        $b = $gbk.GetBytes([string]$chars[$k])
        if ($b.Count -eq 2 -and $b[1] -eq 0x5C) {
          $total++
          $atEnd = ($k -eq $chars.Length - 1)
          $flag = if ($atEnd) { '  <<< AT END OF LINE  *** DANGEROUS ***' } else { '' }
          Write-Host ("  [{0}] {1}:{2}  col {3}  U+{4}  gbk={5:X2}{6:X2}{7}" -f `
            $tag, $f.Name, ($i + 1), ($k + 1), [int]$chars[$k], $b[0], $b[1], $flag)
        }
      }
    }
  }
}
Write-Host ""
Write-Host "total 0x5C-trailing GBK chars found: $total"

Write-Host ""
Write-Host "=== how many project files are GBK vs UTF8 ==="
$g = 0; $u = 0
foreach ($f in $files) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  $strict = New-Object System.Text.UTF8Encoding($false, $true)
  $hasHi = $false
  foreach ($x in $bytes) { if ($x -ge 0x80) { $hasHi = $true; break } }
  if (-not $hasHi) { continue }
  try { [void]$strict.GetString($bytes); $u++ } catch { $g++ }
}
Write-Host "  GBK  (non-ASCII files): $g"
Write-Host "  UTF8 (non-ASCII files): $u"
