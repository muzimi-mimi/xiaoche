$ErrorActionPreference = 'Continue'
Write-Host "PSVersion : $($PSVersionTable.PSVersion)  Edition: $($PSVersionTable.PSEdition)"

# --- GBK decoder (may or may not be available) ---
$gbk = $null
try { $gbk = [System.Text.Encoding]::GetEncoding(936) } catch {
  try {
    [System.Text.Encoding]::RegisterProvider([System.Text.CodePagesEncodingProvider]::Instance)
    $gbk = [System.Text.Encoding]::GetEncoding(936)
  } catch { $gbk = $null }
}
Write-Host "GBK decoder available: $($gbk -ne $null)"
Write-Host ""

$strict = New-Object System.Text.UTF8Encoding($false, $true)

function Get-FileEnc([string]$p) {
  $b = [System.IO.File]::ReadAllBytes($p)
  $bom = 'none'
  if ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) { $bom = 'UTF8-BOM' }
  elseif ($b.Length -ge 2 -and $b[0] -eq 0xFF -and $b[1] -eq 0xFE) { $bom = 'UTF16LE' }
  elseif ($b.Length -ge 2 -and $b[0] -eq 0xFE -and $b[1] -eq 0xFF) { $bom = 'UTF16BE' }
  $hi = 0
  for ($i = 0; $i -lt $b.Length; $i++) { if ($b[$i] -ge 0x80) { $hi++ } }
  $ok = $true
  try { [void]$strict.GetString($b) } catch { $ok = $false }
  [pscustomobject]@{ Name = (Split-Path $p -Leaf); Size = $b.Length; BOM = $bom; HiBytes = $hi; ValidUTF8 = $ok }
}

Write-Host "=== PID Core source files ==="
$list = @()
foreach ($d in @('D:\Users\huang\Desktop\keil\PID\Core\Src', 'D:\Users\huang\Desktop\keil\PID\Core\Inc')) {
  if (Test-Path -LiteralPath $d) {
    $list += Get-ChildItem -LiteralPath $d -File | Where-Object { $_.Extension -in '.c', '.h' } | Sort-Object Name
  }
}
$list | ForEach-Object { Get-FileEnc $_.FullName } | Format-Table -AutoSize

Write-Host "=== Backups in D:\codex ==="
Get-ChildItem 'D:\codex' -File | Where-Object { $_.Name -like '*.bak*' } | ForEach-Object {
  $e = Get-FileEnc $_.FullName
  "{0,-42} size={1,-8} bom={2,-9} hi={3,-7} utf8={4}" -f $e.Name, $e.Size, $e.BOM, $e.HiBytes, $e.ValidUTF8
}
