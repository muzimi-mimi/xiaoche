$ErrorActionPreference = 'Continue'
$gbk  = [System.Text.Encoding]::GetEncoding(936)
$utf8 = New-Object System.Text.UTF8Encoding($false)

$A = ([System.IO.File]::ReadAllText('D:\codex\main.c.bak_yawbias_20261017', $gbk)) -split "`r`n|`n"
$B = ([System.IO.File]::ReadAllText('D:\Users\huang\Desktop\keil\PID\Core\Src\main.c', $utf8)) -split "`r`n|`n"

Write-Host "OLD (22:35 backup, GBK): $($A.Count) lines"
Write-Host "NEW (23:00 on disk, UTF8): $($B.Count) lines"
Write-Host ""
Write-Host "=== aligned diff ==="

$i = 0; $j = 0; $guard = 0; $ops = 0
while (($i -lt $A.Count -or $j -lt $B.Count) -and $guard++ -lt 20000) {
  if ($i -lt $A.Count -and $j -lt $B.Count -and $A[$i] -eq $B[$j]) { $i++; $j++; continue }

  $foundB = -1
  for ($k = $j + 1; $k -lt [Math]::Min($j + 14, $B.Count); $k++) { if ($B[$k] -eq $A[$i]) { $foundB = $k; break } }
  $foundA = -1
  for ($k = $i + 1; $k -lt [Math]::Min($i + 14, $A.Count); $k++) { if ($A[$k] -eq $B[$j]) { $foundA = $k; break } }

  if ($foundB -ge 0 -and ($foundA -lt 0 -or ($foundB - $j) -le ($foundA - $i))) {
    $ops++
    Write-Host "ADD  old-line $i -> new L$($j+1)..L$foundB  ($($foundB-$j) lines)"
    for ($k = $j; $k -lt $foundB; $k++) { Write-Host "   + $($B[$k])" }
    $j = $foundB
  } elseif ($foundA -ge 0) {
    $ops++
    Write-Host "DEL  old L$($i+1)..L$foundA -> new-line $j  ($($foundA-$i) lines)"
    for ($k = $i; $k -lt $foundA; $k++) { Write-Host "   - $($A[$k])" }
    $i = $foundA
  } else {
    $ops++
    Write-Host "CHG  old L$($i+1) -> new L$($j+1)"
    Write-Host "   - $($A[$i])"
    Write-Host "   + $($B[$j])"
    $i++; $j++
  }
}
Write-Host ""
Write-Host "total edit operations: $ops"
