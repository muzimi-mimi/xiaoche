$ErrorActionPreference = 'Stop'
$p   = 'D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
$bak = 'D:\codex\main.c.bak_oled_20261017'
$enc = [System.Text.Encoding]::GetEncoding(936)

$bytes = [System.IO.File]::ReadAllBytes($p)
[System.IO.File]::WriteAllBytes($bak, $bytes)
$s = $enc.GetString($bytes)

function Rx([string]$t, [string]$pat, [string]$rep, [string]$tag) {
    $m = [regex]::Matches($t, $pat)
    if ($m.Count -ne 1) { throw "$tag : expected 1 match, got $($m.Count)" }
    return [regex]::Replace($t, $pat, $rep)
}

# R1 插入三轴共用灵敏度别名（放在 YAW_LSB_PER_DPS 之后、YAW_BIAS_DPS 之前）
$s = Rx $s ([regex]::Escape('#define YAW_BIAS_DPS')) `
          "#define GYRO_LSB_PER_DPS  YAW_LSB_PER_DPS  /* 三轴共用灵敏度(±2000°/s)：GX/GZ 屏显换算 */`r`n#define YAW_BIAS_DPS" `
          'R1'

# R2 Yaw 改成 2 位小数（x=60 起 11 字符 = 66px，落在 60..125）
$s = Rx $s ([regex]::Escape('"Yaw:%+05.0f"')) '"Yaw:%+07.2f"' 'R2'

# R3 GX 屏显改为 °/s（整行含注释一起重写，避免依赖旧中文注释的字节）
$s = Rx $s '"GX%\+05d", GX\)[ \t]*//[^\r\n]*' `
          '"GX%+05.1f", GX / GYRO_LSB_PER_DPS)  /* X轴角速度(°/s)：静止应为 0 */' `
          'R3'

# R4 GZ 屏显改为 °/s
$s = Rx $s '"GZ%\+05d", GZ\)[ \t]*//[^\r\n]*' `
          '"GZ%+05.1f", GZ / GYRO_LSB_PER_DPS)  /* Z轴角速度(°/s)：静止读数即 YAW_BIAS_DPS */' `
          'R4'

# R5/R6 位置微调：GX(0..41) GZ(42..83) S(84..125)
$s = Rx $s ([regex]::Escape('OLED_Printf(43, 56,')) 'OLED_Printf(42, 56,' 'R5'
$s = Rx $s ([regex]::Escape('OLED_Printf(86, 56,')) 'OLED_Printf(84, 56,' 'R6'

if ($s -eq $enc.GetString($bytes)) { throw 'no change produced' }

[System.IO.File]::WriteAllBytes($p, $enc.GetBytes($s))

$L = [System.IO.File]::ReadAllLines($p, $enc)
"OK  lines=$($L.Count)"
'--- 103..112 ---'
103..112 | ForEach-Object { '{0,4}: {1}' -f $_, $L[$_ - 1] }
'--- 543..556 ---'
543..556 | ForEach-Object { '{0,4}: {1}' -f $_, $L[$_ - 1] }
