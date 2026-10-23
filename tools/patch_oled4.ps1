$ErrorActionPreference = 'Stop'
$p   = 'D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
$bak = 'D:\codex\main.c.bak_oled_20261017'
$enc = [System.Text.Encoding]::GetEncoding(936)

# 从备份还原（备份是补丁前的原始字节），保证可重复执行
[System.IO.File]::WriteAllBytes($p, [System.IO.File]::ReadAllBytes($bak))

$s  = [string]$enc.GetString([System.IO.File]::ReadAllBytes($p))
$s0 = $s

function Rx([string]$t, [string]$pat, [string]$rep, [string]$tag) {
    $m = [regex]::Matches($t, $pat)
    if ($m.Count -ne 1) { throw "$tag : expected 1 match, got $($m.Count)" }
    Write-Host ("  {0} matched: {1}" -f $tag, $m[0].Value)
    return [regex]::Replace($t, $pat, $rep)
}

$s = Rx $s ([regex]::Escape('#define YAW_BIAS_DPS')) `
          "#define GYRO_LSB_PER_DPS  YAW_LSB_PER_DPS  /* 三轴共用灵敏度(±2000°/s)：GX/GZ 屏显换算 */`r`n#define YAW_BIAS_DPS" `
          'R1'
$s = Rx $s ([regex]::Escape('"Yaw:%+05.0f"')) '"Yaw:%+07.2f"' 'R2'
$s = Rx $s '"GX%\+05d", GX\);[ \t]*//[^\r\n]*' `
          '"GX%+05.1f", GX / GYRO_LSB_PER_DPS);  /* X轴角速度(°/s)：静止应为 0 */' 'R3'
$s = Rx $s '"GZ%\+05d", GZ\);[ \t]*//[^\r\n]*' `
          '"GZ%+05.1f", GZ / GYRO_LSB_PER_DPS);  /* Z轴角速度(°/s)：静止读数即 YAW_BIAS_DPS */' 'R4'
$s = Rx $s ([regex]::Escape('OLED_Printf(43, 56,')) 'OLED_Printf(42, 56,' 'R5'
$s = Rx $s ([regex]::Escape('OLED_Printf(86, 56,')) 'OLED_Printf(84, 56,' 'R6'

# ---- 写回前自检 ----
if ($s -isnot [string]) { throw "TYPE: `$s is $($s.GetType().Name), not String" }
if ($s -eq $s0)         { throw 'NOCHANGE: nothing was replaced' }
$L  = $s  -split "`r`n"
$L0 = $s0 -split "`r`n"
if ($L[0] -ne '/* USER CODE BEGIN Header */') { throw "LINE1 CORRUPT: [$($L[0])]" }
if ($L.Count -ne $L0.Count + 1) { throw "LINECOUNT: $($L.Count), expected $($L0.Count + 1)" }
[System.IO.File]::WriteAllBytes($p, $enc.GetBytes($s))
"OK written: lines=$($L.Count - 1)  firstline=[$($L[0])]  lastline=[$($L[$L.Count-2])]"
