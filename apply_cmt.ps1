$ErrorActionPreference='Stop'
$MAIN='D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
$gbk=[System.Text.Encoding]::GetEncoding(936)
$MARK=[char]0x951F
$APPLY=($env:CMT_APPLY -eq '1')

function Is-Pure([string]$s){
  $t=$s.Trim()
  if($t.Length -eq 0){ return $false }
  return ($t.StartsWith('/*') -or $t.StartsWith('*') -or $t.StartsWith('//'))
}
function Split-Comment([string]$s){
  $i1=$s.IndexOf('//'); $i2=$s.IndexOf('/*')
  if($i1 -ge 0 -and $i2 -ge 0){ return [Math]::Min($i1,$i2) }
  if($i1 -ge 0){ return $i1 }
  if($i2 -ge 0){ return $i2 }
  return -1
}
function StripCode([string]$text){
  $sb=New-Object System.Text.StringBuilder
  $i=0; $n=$text.Length; $st=0   # 0=code 1=line 2=block 3=str 4=chr
  while($i -lt $n){
    $c=$text[$i]; $c2=if($i+1 -lt $n){$text[$i+1]}else{[char]0}
    if($st -eq 0){
      if($c -eq '/' -and $c2 -eq '/'){ $st=1; $i+=2; continue }
      if($c -eq '/' -and $c2 -eq '*'){ $st=2; $i+=2; continue }
      if($c -eq '"'){ $st=3; [void]$sb.Append($c); $i++; continue }
      if($c -eq "'"){ $st=4; [void]$sb.Append($c); $i++; continue }
      [void]$sb.Append($c); $i++; continue
    }
    if($st -eq 1){ if($c -eq "`n"){ $st=0; [void]$sb.Append($c) }; $i++; continue }
    if($st -eq 2){ if($c -eq '*' -and $c2 -eq '/'){ $st=0; $i+=2; continue } $i++; continue }
    if($st -eq 3){
      [void]$sb.Append($c)
      if($c -eq '\'){ if($i+1 -lt $n){ [void]$sb.Append($text[$i+1]) }; $i+=2; continue }
      if($c -eq '"'){ $st=0 }
      $i++; continue
    }
    if($st -eq 4){
      [void]$sb.Append($c)
      if($c -eq '\'){ if($i+1 -lt $n){ [void]$sb.Append($text[$i+1]) }; $i+=2; continue }
      if($c -eq "'"){ $st=0 }
      $i++; continue
    }
  }
  return $sb.ToString()
}

$lines=New-Object 'System.Collections.Generic.List[string]'
foreach($l in [System.IO.File]::ReadAllLines($MAIN,$gbk)){ $lines.Add($l) }
$origTotal=$lines.Count

$ops=New-Object 'System.Collections.ArrayList'
foreach($f in $args){
  $raw=[System.IO.File]::ReadAllText($f,(New-Object System.Text.UTF8Encoding($false)))
  foreach($ln in ($raw -split "`r`n|`n")){
    if($ln.Trim().Length -eq 0){ continue }
    $p=$ln -split "`t"
    $op=$p[0]
    if($p.Count -eq 3 -and $op -eq 'S'){
      $s=[int]$p[1]; $e=$s; $txt=$p[2] -replace '\\n',"`n"
    } elseif($p.Count -ge 4){
      $s=[int]$p[1]; $e=[int]$p[2]
      $txt=($p[3..($p.Count-1)] -join "`t") -replace '\\n',"`n"
    } else { throw "bad record in $f : $ln" }
    [void]$ops.Add([pscustomobject]@{op=$op;s=$s;e=$e;txt=$txt;src=(Split-Path $f -Leaf)})
  }
}
"records: $($ops.Count)  (apply=$APPLY)"

$errors=New-Object 'System.Collections.ArrayList'
foreach($o in $ops){
  if($o.s -lt 1 -or $o.e -gt $lines.Count -or $o.s -gt $o.e){ [void]$errors.Add("range out of file: $($o.op) $($o.s)-$($o.e)"); continue }
  $first=$lines[$o.s-1]
  if($o.op -eq 'B'){
    for($j=$o.s;$j -le $o.e;$j++){
      if(-not (Is-Pure $lines[$j-1])){ [void]$errors.Add("B $($o.s)-$($o.e): line $j not pure -> $($lines[$j-1])"); break }
    }
    $pl=($o.txt -split "`n") | Where-Object { $_.Trim().Length -gt 0 }
    $allSlash=$true; foreach($x in $pl){ if(-not $x.Trim().StartsWith('//')){ $allSlash=$false; break } }
    if(-not $allSlash -and -not $o.txt.TrimEnd().EndsWith('*/')){
      [void]$errors.Add("B $($o.s)-$($o.e): payload is neither all-// nor ends with */")
    }
  } elseif($o.op -eq 'F'){
    if(Is-Pure $first){ [void]$errors.Add("F $($o.s)-$($o.e): first line is pure comment") }
    if((Split-Comment $first) -lt 0){ [void]$errors.Add("F $($o.s): no comment delimiter on first line") }
    for($j=$o.s+1;$j -le $o.e;$j++){
      if(-not (Is-Pure $lines[$j-1])){ [void]$errors.Add("F $($o.s)-$($o.e): line $j not pure"); break }
    }
    if(-not $o.txt.TrimEnd().EndsWith('*/')){ [void]$errors.Add("F $($o.s)-$($o.e): payload does not end with */") }
  } elseif($o.op -eq 'S'){
    if($o.e -ne $o.s){ [void]$errors.Add("S $($o.s): e<>s") }
    if((Split-Comment $first) -lt 0){ [void]$errors.Add("S $($o.s): no comment delimiter") }
    if(-not ($o.txt.StartsWith('//') -or $o.txt.StartsWith('/*'))){ [void]$errors.Add("S $($o.s): payload must start with // or /*") }
  } else { [void]$errors.Add("unknown op $($o.op)") }
}
$sorted=$ops | Sort-Object s
for($k=1;$k -lt $sorted.Count;$k++){
  if($sorted[$k].s -le $sorted[$k-1].e){ [void]$errors.Add("overlap: $($sorted[$k-1].op) $($sorted[$k-1].s)-$($sorted[$k-1].e) vs $($sorted[$k].op) $($sorted[$k].s)-$($sorted[$k].e)") }
}
if($errors.Count -gt 0){ "VALIDATION FAILED:"; $errors | ForEach-Object { "  $_" }; exit 1 }
"validation OK"

$new=New-Object 'System.Collections.Generic.List[string]'
foreach($l in $lines){ $new.Add($l) }
foreach($o in ($ops | Sort-Object s -Descending)){
  $s=$o.s-1; $e=$o.e-1
  $payload=$o.txt -split "`n"
  if($o.op -eq 'B'){
    $origIndent = 0
    $tmp=$new[$s]; while($origIndent -lt $tmp.Length -and $tmp[$origIndent] -eq ' '){ $origIndent++ }
    $contIndent = -1
    if($payload.Count -gt 1){
      $m=[regex]::Match($payload[1],'^( +)\*')
      if($m.Success){ $contIndent = $m.Groups[1].Length }
    }
    if($contIndent -ge 0){
      $shift = ($origIndent + 1) - $contIndent
      $out=New-Object 'System.Collections.Generic.List[string]'
      $out.Add((' ' * $origIndent) + $payload[0].TrimStart())
      for($k=1;$k -lt $payload.Count;$k++){
        $ln=$payload[$k]
        if($shift -gt 0){ $out.Add((' ' * $shift) + $ln) }
        elseif($shift -lt 0){
          $d=[Math]::Min(-$shift, $ln.Length - $ln.TrimStart().Length)
          $out.Add($ln.Substring($d))
        } else { $out.Add($ln) }
      }
      $payload=$out.ToArray()
    } else {
      $payload[0]=(' ' * $origIndent) + $payload[0].TrimStart()
    }
    $new.RemoveRange($s,$e-$s+1); $new.InsertRange($s,$payload)
  } elseif($o.op -eq 'S'){
    $idx=Split-Comment $new[$s]
    $new[$s]=$new[$s].Substring(0,$idx)+$o.txt
  } elseif($o.op -eq 'F'){
    $idx=Split-Comment $new[$s]
    $pre=$new[$s].Substring(0,$idx)
    $contIndent = -1
    if($payload.Count -gt 1){
      $m=[regex]::Match($payload[1],'^( +)\*')
      if($m.Success){ $contIndent = $m.Groups[1].Length }
    }
    $shift = 0
    if($contIndent -ge 0){ $shift = ($idx + 1) - $contIndent }
    $repl=New-Object 'System.Collections.Generic.List[string]'
    $repl.Add($pre+$payload[0])
    for($k=1;$k -lt $payload.Count;$k++){
      $ln=$payload[$k]
      if($shift -gt 0){ $repl.Add((' ' * $shift) + $ln) }
      elseif($shift -lt 0){
        $d=[Math]::Min(-$shift, $ln.Length - $ln.TrimStart().Length)
        $repl.Add($ln.Substring($d))
      } else { $repl.Add($ln) }
    }
    $new.RemoveRange($s,$e-$s+1); $new.InsertRange($s,$repl)
  }
}

$cover=New-Object 'bool[]' ($lines.Count+2)
foreach($o in $ops){ for($j=$o.s;$j -le $o.e;$j++){ $cover[$j]=$true } }
$left=0; $leftList=New-Object 'System.Collections.ArrayList'
for($i=0;$i -lt $lines.Count;$i++){
  if($lines[$i].IndexOf($MARK) -ge 0 -and -not $cover[$i+1]){ $left++; [void]$leftList.Add(($i+1)) }
}
"lines: $origTotal -> $($new.Count)"
"uncovered damaged lines (original numbering): $left"
if($left -gt 0){
  $grp=@(); $prev=-99
  foreach($x in $leftList){ if($x -ne $prev+1){ $grp += "$x" } else { $grp[-1]="$($grp[-1])-$x" }; $prev=$x }
  "  at: " + ($grp -join ',')
}

# ---- code equality check (comments and whitespace removed) ----
$a=(StripCode ($lines -join "`n")) -replace '\s',''
$b=(StripCode ($new   -join "`n")) -replace '\s',''
"code chars: $($a.Length) vs $($b.Length)"
if($a -ceq $b){ "CODE IDENTICAL (comments/whitespace stripped) : YES" }
else {
  "CODE IDENTICAL : NO"
  $m=[Math]::Min($a.Length,$b.Length); $d=-1
  for($i=0;$i -lt $m;$i++){ if($a[$i] -ne $b[$i]){ $d=$i; break } }
  if($d -lt 0){ $d=$m }
  "  first diff at char $d"
  $s0=[Math]::Max(0,$d-60)
  "  OLD: " + $a.Substring($s0,[Math]::Min(140,$a.Length-$s0))
  "  NEW: " + $b.Substring($s0,[Math]::Min(140,$b.Length-$s0))
}

if($APPLY){
  [System.IO.File]::WriteAllText($MAIN, (($new -join "`r`n")+"`r`n"), $gbk)
  "written GBK: $((Get-Item $MAIN).Length) bytes"
} else {
  "dry run: nothing written"
}
