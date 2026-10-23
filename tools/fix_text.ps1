$ErrorActionPreference='Stop'
$p='D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
$gbk=[System.Text.Encoding]::GetEncoding(936)
$lines=[System.IO.File]::ReadAllLines($p,$gbk)
$raw=[System.IO.File]::ReadAllText('D:\codex\fix_text.json',(New-Object System.Text.UTF8Encoding($false)))
$pairs=$raw | ConvertFrom-Json
foreach($pr in $pairs){
  $hits=0
  for($i=0;$i -lt $lines.Count;$i++){
    if($lines[$i].Contains($pr.old)){ $lines[$i]=$lines[$i].Replace($pr.old,$pr.new); $hits++ }
  }
  "replaced [$($pr.old)] -> hits=$hits"
}
[System.IO.File]::WriteAllText($p, (($lines -join "`r`n")+"`r`n"), $gbk)
"written: $((Get-Item $p).Length) bytes / $($lines.Count) lines"
