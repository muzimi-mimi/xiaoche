$ErrorActionPreference='Stop'
$p='D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
$gbk=[System.Text.Encoding]::GetEncoding(936)
$lines=[System.IO.File]::ReadAllLines($p,$gbk)
$n=$lines.Count
$fixes=New-Object System.Collections.ArrayList
for($i=0;$i -lt $n-1;$i++){
  $t=$lines[$i].TrimStart()
  if(-not $t.StartsWith('/*')){ continue }
  if($t.EndsWith('*/')){ continue }
  $nx=$lines[$i+1]
  $m=[regex]::Match($nx,'^( +)\*')
  if(-not $m.Success){ continue }
  $contIndent=$m.Groups[1].Length + 1      # indent of the '/'
  $curIndent=$lines[$i].Length - $t.Length
  if($curIndent -lt $contIndent){
    [void]$fixes.Add([pscustomobject]@{line=($i+1);cur=$curIndent;want=$contIndent})
  }
}
"misaligned blocks: $($fixes.Count)"
foreach($f in $fixes){ "  line $($f.line): indent $($f.cur) -> $($f.want)" }
if($fixes.Count -gt 0){
  foreach($f in ($fixes | Sort-Object line -Descending)){
    $s=$f.line-1
    $pad=' ' * ($f.want-$f.cur)
    # find end of block
    $e=$s
    while($e -lt $n -and -not $lines[$e].TrimEnd().EndsWith('*/')){ $e++ }
    for($j=$s;$j -le $e;$j++){ if($lines[$j].Length -gt 0){ $lines[$j]=$pad+$lines[$j] } }
  }
  [System.IO.File]::WriteAllText($p, (($lines -join "`r`n")+"`r`n"), $gbk)
  "rewritten: $((Get-Item $p).Length) bytes"
} else { "nothing to do" }
