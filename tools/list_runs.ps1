$ErrorActionPreference='Stop'
$p='D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
$gbk=[System.Text.Encoding]::GetEncoding(936)
$lines=[System.IO.File]::ReadAllLines($p,$gbk)
$MARK=[char]0x951F   # 'kun' - marker of UTF8->GBK mojibake
function Is-Pure([string]$s){
  $t=$s.Trim()
  if($t.Length -eq 0){ return $false }
  return ($t.StartsWith('/*') -or $t.StartsWith('*') -or $t.StartsWith('//'))
}
$runs=New-Object System.Collections.ArrayList
$i=0
while($i -lt $lines.Count){
  if(Is-Pure $lines[$i]){
    $s=$i
    while($i -lt $lines.Count -and (Is-Pure $lines[$i])){ $i++ }
    [void]$runs.Add(@($s,($i-1)))
  } else { $i++ }
}
"runs total: $($runs.Count)"
$k=0
foreach($r in $runs){
  $s=[int]$r[0]; $e=[int]$r[1]
  $has=$false
  for($j=$s;$j -le $e;$j++){ if($lines[$j].IndexOf($MARK) -ge 0){ $has=$true; break } }
  if($has){
    $k++
    $first=$lines[$s].Trim()
    if($first.Length -gt 60){ $first=$first.Substring(0,60) }
    "{0,4}] {1,5}-{2,5} n={3,2} | {4}" -f $k,($s+1),($e+1),($e-$s+1),$first
  }
}
"damaged runs: $k"
