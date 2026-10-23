param([string]$A, [string]$B)
$ErrorActionPreference = 'Stop'

function Strip([string]$s) {
    $sb = New-Object System.Text.StringBuilder
    $i = 0; $n = $s.Length; $st = 0
    while ($i -lt $n) {
        $c = $s[$i]
        $c2 = [char]0
        if ($i + 1 -lt $n) { $c2 = $s[$i + 1] }
        if ($st -eq 0) {
            if ($c -eq '/' -and $c2 -eq '/') { $st = 1; $i += 2 }
            elseif ($c -eq '/' -and $c2 -eq '*') { $st = 2; $i += 2 }
            elseif ($c -eq '"') { $st = 3; [void]$sb.Append($c); $i++ }
            elseif ($c -eq "'") { $st = 4; [void]$sb.Append($c); $i++ }
            else { [void]$sb.Append($c); $i++ }
        }
        elseif ($st -eq 1) {
            if ($c -eq "`n") { $st = 0; [void]$sb.Append("`n") }
            $i++
        }
        elseif ($st -eq 2) {
            if ($c -eq '*' -and $c2 -eq '/') { $st = 0; $i += 2 } else { $i++ }
        }
        elseif ($st -eq 3) {
            [void]$sb.Append($c)
            if ($c -eq '\' -and $i + 1 -lt $n) { [void]$sb.Append($s[$i + 1]); $i += 2 }
            elseif ($c -eq '"') { $st = 0; $i++ }
            else { $i++ }
        }
        else {
            [void]$sb.Append($c)
            if ($c -eq '\' -and $i + 1 -lt $n) { [void]$sb.Append($s[$i + 1]); $i += 2 }
            elseif ($c -eq "'") { $st = 0; $i++ }
            else { $i++ }
        }
    }
    return $sb.ToString()
}

function Norm([string]$p, [string]$enc) {
    $bytes = [System.IO.File]::ReadAllBytes($p)
    if ($enc -eq 'gbk') { $e = [System.Text.Encoding]::GetEncoding(936) }
    else { $e = New-Object System.Text.UTF8Encoding($false) }
    $t = Strip ($e.GetString($bytes))
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($ln in ($t -split "`r?`n")) {
        $x = ($ln -replace '[^\x20-\x7E]', '')
        $x = ($x -replace '\s+', ' ').Trim()
        if ($x.Length -gt 0) { $out.Add($x) }
    }
    return $out
}

$a = Norm $A 'gbk'
$b = Norm $B 'utf8'
"backup (GBK 18:22) code lines : {0}" -f $a.Count
"current (UTF8 19:07) code lines: {0}" -f $b.Count
$cmp = Compare-Object $a $b -SyncWindow 40
"differing entries: {0}" -f $cmp.Count
$i = 0
foreach ($x in $cmp) {
    if ($i -ge 40) { "... truncated"; break }
    "{0} {1}" -f $x.SideIndicator, ($x.InputObject.Substring(0,[Math]::Min(220,$x.InputObject.Length)))
    $i++
}
