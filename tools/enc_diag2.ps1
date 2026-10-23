$ErrorActionPreference = 'Continue'
$gbk  = [System.Text.Encoding]::GetEncoding(936)
$utf8 = New-Object System.Text.UTF8Encoding($false)
$p    = 'D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'

Write-Host "=== timestamps ==="
Get-Item $p | Select-Object Name, Length, LastWriteTime | Format-List
Get-ChildItem 'D:\codex' -File | Where-Object { $_.Name -like 'main.c.bak*' } |
  Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize

Write-Host "=== D:\codex contents (looking for my patch scripts) ==="
Get-ChildItem 'D:\codex' -File | Sort-Object LastWriteTime -Descending |
  Select-Object -First 25 Name, Length, LastWriteTime | Format-Table -AutoSize

Write-Host "=== line counts ==="
$newTxt = [System.IO.File]::ReadAllText($p, $utf8)
$newL = $newTxt -split "`r`n|`n"
"current main.c (UTF-8 read) lines = $($newL.Count)"

foreach ($bak in @('main.c.bak_yaw_20261017','main.c.bak_oled_20261017','main.c.bak_yawbias_20261017')) {
  $bp = "D:\codex\$bak"
  $t  = [System.IO.File]::ReadAllText($bp, $gbk)
  $l  = $t -split "`r`n|`n"
  "$bak (GBK read) lines = $($l.Count)"
}

Write-Host ""
Write-Host "=== first 6 lines of current main.c ==="
0..5 | ForEach-Object { "  [$($_+1)] $($newL[$_])" }

Write-Host ""
Write-Host "=== first 6 lines of yawbias backup, read as GBK ==="
$oldTxt = [System.IO.File]::ReadAllText('D:\codex\main.c.bak_yawbias_20261017', $gbk)
$oldL   = $oldTxt -split "`r`n|`n"
0..5 | ForEach-Object { "  [$($_+1)] $($oldL[$_])" }

Write-Host ""
Write-Host "=== diff : yawbias backup(GBK->text)  vs  current(UTF8) ==="
$n = [Math]::Max($oldL.Count, $newL.Count)
$d = 0
for ($i = 0; $i -lt $n; $i++) {
  $a = if ($i -lt $oldL.Count) { $oldL[$i] } else { '<EOF>' }
  $b = if ($i -lt $newL.Count) { $newL[$i] } else { '<EOF>' }
  if ($a -ne $b) {
    $d++
    if ($d -le 30) { "  L$($i+1)"; "    OLD| $a"; "    NEW| $b" }
  }
}
"  --- total differing line positions: $d  (old=$($oldL.Count) new=$($newL.Count))"
