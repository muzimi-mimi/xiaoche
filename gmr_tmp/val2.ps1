Add-Type -AssemblyName System.IO.Compression.FileSystem
$p=(Resolve-Path "check.docx").Path
$z=[System.IO.Compression.ZipFile]::OpenRead($p)
$names=@{}; $xmls=@{}
foreach($e in $z.Entries){ $names[$e.FullName]=1
  if($e.FullName -like "*.xml" -or $e.FullName -like "*.rels"){ $sr=New-Object System.IO.StreamReader($e.Open(),[System.Text.Encoding]::UTF8); $xmls[$e.FullName]=$sr.ReadToEnd(); $sr.Close() } }
$z.Dispose()
$bad=0
foreach($k in $xmls.Keys){ try{ [xml]$d=$xmls[$k]; Write-Output ("OK   {0}" -f $k) } catch{ $bad++; Write-Output ("FAIL {0} :: {1}" -f $k,$_.Exception.Message) } }
$doc=$xmls["word/document.xml"]
$ids=[regex]::Matches($doc,'r:embed="(rId\d+)')|%{$_.Groups[1].Value} | Sort-Object -Unique
$relIds=[regex]::Matches($xmls["word/_rels/document.xml.rels"],'Id="(rId\d+)')|%{$_.Groups[1].Value}
foreach($i in $ids){ if($relIds -notcontains $i){$bad++; Write-Output "MISSING REL $i"} }
Write-Output ("image refs: {0} rels: {1}" -f $ids.Count,$relIds.Count)
foreach($m in ([regex]::Matches($xmls["word/_rels/document.xml.rels"],'Target="(media/[^"]+)')|%{$_.Groups[1].Value})){ if(-not $names["word/$m"]){$bad++; Write-Output "MISSING PART $m"} }
$t=([regex]::Matches($doc,"<w:tbl>")).Count; $te=([regex]::Matches($doc,"</w:tbl>")).Count
$p1=([regex]::Matches($doc,"<w:p>")).Count; $p2=([regex]::Matches($doc,"<w:p/>")).Count; $p3=([regex]::Matches($doc,"</w:p>")).Count
Write-Output ("tbl open/close: $t/$te   p open/close: $p1+$p2/$p3")
Write-Output ("RESULT bad=$bad")
