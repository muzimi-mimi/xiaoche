#requires -Version 5.1
$ErrorActionPreference = 'Stop'
$gbk = [System.Text.Encoding]::GetEncoding(936)
$utf8 = New-Object System.Text.UTF8Encoding($false)
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backupDir = 'D:\codex'

$root = [System.IO.File]::ReadAllText('D:\codex\patch_edits.json', $utf8) | ConvertFrom-Json

foreach ($f in $root.files) {
    $path = $f.path
    $name = [System.IO.Path]::GetFileName($path)
    Write-Output "==================== $name"

    # --- backup (same dir + D:\codex) ---
    $bk1 = Join-Path (Split-Path $path -Parent) ("$name.bak_before_adsfix_$stamp")
    $bk2 = Join-Path $backupDir ("$name.bak_before_adsfix_$stamp")
    Copy-Item -LiteralPath $path -Destination $bk1 -Force
    Copy-Item -LiteralPath $path -Destination $bk2 -Force
    Write-Output ("  backup -> {0} ({1} B)" -f $bk1, (Get-Item -LiteralPath $bk1).Length)

    $orig = [System.IO.File]::ReadAllText($path, $gbk)
    $lines = [System.Collections.ArrayList]::new()
    foreach ($l in ($orig -split "`r`n")) { [void]$lines.Add($l) }
    $origCount = $lines.Count
    Write-Output ("  lines in = {0}" -f $origCount)

    # --- edits are already in descending order of s ---
    $edits = $f.edits | Sort-Object -Property s -Descending
    foreach ($e in $edits) {
        $s = [int]$e.s
        $oc = $e.old.Count
        $nc = $e.new.Count
        if (($s + $oc) -gt $lines.Count) {
            throw "EDIT OUT OF RANGE: s=$s old=$oc total=$($lines.Count)"
        }
        # verify expected content (trailing-whitespace tolerant)
        for ($k = 0; $k -lt $oc; $k++) {
            $actual = $lines[$s + $k].TrimEnd()
            $expect = ([string]$e.old[$k]).TrimEnd()
            if ($actual -ne $expect) {
                throw "MISMATCH $name s=$s k=$k`n  expect >$expect<`n  actual >$actual<"
            }
        }
        $lines.RemoveRange($s, $oc)
        for ($k = 0; $k -lt $nc; $k++) { $lines.Insert($s + $k, [string]$e.new[$k]) }
        Write-Output ("  patched s={0,-4} old={1,-3} new={2,-3} -> lines now {3}" -f $s, $oc, $nc, $lines.Count)
    }

    $text = ($lines -join "`r`n")
    [System.IO.File]::WriteAllText($path, $text, $gbk)

    # --- verify ---
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $chk = $gbk.GetString($bytes)
    $rt = [Convert]::ToBase64String($gbk.GetBytes($chk)) -eq [Convert]::ToBase64String($bytes)
    $crlf = ([regex]::Matches($chk, "`r`n")).Count
    $lf = ([regex]::Matches($chk, "`n")).Count
    $fffd = ([regex]::Matches($chk, [string][char]0xFFFD)).Count
    Write-Output ("  bytes={0} lines={1} CRLF={2} LF={3} GBKroundtrip={4} U+FFFD={5}" -f `
        $bytes.Length, $lines.Count, $crlf, $lf, $rt, $fffd)
    if (-not $rt) { throw "GBK ROUNDTRIP FAILED: $name" }
    if ($fffd -ne 0) { throw "U+FFFD FOUND: $name" }
    if ($crlf -ne $lf) { throw "MIXED LINE ENDINGS: $name" }
}
Write-Output "ALL DONE"
