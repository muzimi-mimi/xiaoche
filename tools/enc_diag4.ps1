$ErrorActionPreference = 'Continue'
$gbk  = [System.Text.Encoding]::GetEncoding(936)
$utf8 = New-Object System.Text.UTF8Encoding($false)
$cur  = 'D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
$bak  = 'D:\codex\main.c.bak_yawbias_20261017'

function Dump([byte[]]$b, [int]$from, [int]$len) {
  $s = ''
  for ($i = $from; $i -lt [Math]::Min($from + $len, $b.Length); $i++) { $s += ('{0:X2} ' -f $b[$i]) }
  $s
}

$curBytes = [System.IO.File]::ReadAllBytes($cur)
$bakBytes = [System.IO.File]::ReadAllBytes($bak)

# locate line 74 (1-based) in current file, line 73 in backup
function Get-LineBytes([byte[]]$b, [int]$n) {
  $line = 1; $start = 0
  for ($i = 0; $i -lt $b.Length; $i++) {
    if ($b[$i] -eq 0x0A) {
      if ($line -eq $n) { return @($start, $i - $start) }
      $line++; $start = $i + 1
    }
  }
  return @($start, $b.Length - $start)
}

$c = Get-LineBytes $curBytes 74
$o = Get-LineBytes $bakBytes 73
Write-Host "=== current main.c  line 74  (offset $($c[0]), $($c[1]) bytes) ==="
Write-Host (Dump $curBytes $c[0] $c[1])
Write-Host ""
Write-Host "=== backup main.c   line 73  (offset $($o[0]), $($o[1]) bytes) ==="
Write-Host (Dump $bakBytes $o[0] $o[1])
Write-Host ""

Write-Host "=== U+FFFD (EF BF BD) occurrences in current main.c ==="
$t = [System.IO.File]::ReadAllText($cur, $utf8)
$fffd = ([regex]::Matches($t, [char]0xFFFD)).Count
Write-Host "  count = $fffd"
Write-Host ""

Write-Host "=== RECOVERY TEST ==="
Write-Host "  current text -> UTF8 bytes -> decode as GBK -> compare with backup"
$recovered = $gbk.GetString($utf8.GetBytes($t))
$rl = $recovered -split "`r`n|`n"
$bl = ([System.IO.File]::ReadAllText($bak, $gbk)) -split "`r`n|`n"
$same = 0; $tot = [Math]::Min($rl.Count, $bl.Count)
for ($i = 0; $i -lt $tot; $i++) { if ($rl[$i] -eq $bl[$i]) { $same++ } }
Write-Host "  identical lines after round-trip : $same / $tot"

Write-Host ""
Write-Host "=== sample: recovered line 74 vs backup line 73 ==="
Write-Host "  RECOVERED| $($rl[73])"
Write-Host "  BACKUP   | $($bl[72])"
Write-Host ""
Write-Host "=== sample: recovered line 107 vs backup line 106 (the bias line) ==="
Write-Host "  RECOVERED| $($rl[106])"
Write-Host "  BACKUP   | $($bl[105])"
