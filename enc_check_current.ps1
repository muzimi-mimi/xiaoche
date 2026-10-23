$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Probe([string]$label, [string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { Write-Output "MISSING: $path"; return }
  $bytes = [System.IO.File]::ReadAllBytes($path)
  Write-Output "=================================================================="
  Write-Output "FILE : $label"
  Write-Output "PATH : $path"
  Write-Output ("SIZE : {0} bytes" -f $bytes.Length)
  Write-Output ("HEAD : {0}" -f (($bytes[0..([Math]::Min(7,$bytes.Length-1))] | ForEach-Object { $_.ToString('X2') }) -join ' '))
  $nonAscii = 0; foreach ($b in $bytes) { if ($b -gt 0x7F) { $nonAscii++ } }
  Write-Output ("NON-ASCII BYTES : {0}" -f $nonAscii)

  $u8 = New-Object System.Text.UTF8Encoding($false, $true)
  $u8ok = $true; $u8text = ''
  try { $u8text = $u8.GetString($bytes) } catch { $u8ok = $false }
  Write-Output ("UTF8-STRICT : {0}" -f $(if ($u8ok) { 'VALID UTF-8' } else { 'INVALID' }))

  $gbk = [System.Text.Encoding]::GetEncoding(936)
  $gt = $gbk.GetString($bytes)
  $gff = ([regex]::Matches($gt, [char]0xFFFD)).Count

  if ($u8ok) {
    $uff = ([regex]::Matches($u8text, [char]0xFFFD)).Count
    $ucjk = ([regex]::Matches($u8text, '[\u4e00-\u9fff]')).Count
    Write-Output ("  as UTF-8 : lines={0}  U+FFFD={1}  CJK={2}" -f (($u8text -split "`n").Count), $uff, $ucjk)
  }
  $gcjk = ([regex]::Matches($gt, '[\u4e00-\u9fff]')).Count
  Write-Output ("  as GBK   : lines={0}  U+FFFD={1}  CJK={2}" -f (($gt -split "`n").Count), $gff, $gcjk)

  Write-Output "--- first 4 lines, decoded as GBK ---"
  ($gt -split "`r?`n")[0..3] | ForEach-Object { '  | ' + $_ }
  if ($u8ok) {
    Write-Output "--- first 4 lines, decoded as UTF-8 ---"
    ($u8text -split "`r?`n")[0..3] | ForEach-Object { '  | ' + $_ }
  }
  Write-Output ""
}

Probe 'CURRENT main.c' 'D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
Probe 'PIDs main.c.bak_before_recomment_20261016_231810' 'D:\Users\huang\Desktop\keil\PID\main.c.bak_before_recomment_20261016_231810'
Probe 'latest bak in Core\Src' 'D:\Users\huang\Desktop\keil\PID\Core\Src\main.c.bak_tipreset_20261015_225146'
