# AGENTS.md — `D:\codex` 仓库级工作规则

> 本文件是**仓库级**指令，只对 `D:\codex` 这个工作区生效。
> `$DSH_HOME/AGENTS.md`（环境级）与本文件并存；冲突时以**本文件**为准（更具体）。

## 0. 这个仓库是什么

| 项 | 值 |
|---|---|
| 仓库根 | `D:\codex` |
| 远程 | `origin` = `https://github.com/muzimi-mimi/xiaoche.git` |
| 分支 | `main` |
| 主体 | 智能车（摄像头循迹 + 自平衡）固件源码、Keil 工程、调参日志 |

### ★ 固件源码就在这里，不要去桌面找

| 内容 | 路径 |
|---|---|
| 源码 | `keil_PID/Core/Src/*.c`、`keil_PID/Core/Inc/*.h` |
| 入口 | **`keil_PID/Core/Src/main.c`** —— 约 **602 行**：全局变量定义、PA5 按键回调、`main()`、CubeMX 生成段 |
| 实时控制 | `keil_PID/Core/Src/tim3_pid.c` —— TIM3 中断里的 10ms 姿态/平衡、50ms 速度/转向、起立/停车/PID 复位 |
| 循迹与路口 | `keil_PID/Core/Src/Ccd_Frame.c` —— CCD 采帧、循迹纠偏、直角/T 字状态机 |
| 蓝牙下行 | `keil_PID/Core/Src/Blue_ProcessPackets.c` |
| 状态屏 | `keil_PID/Core/Src/OLED_RenderStatus.c` |
| 共享层 | `keil_PID/Core/Src/car.h` + 每模块一个 `.h`（参数宏压在各自 `.c` 顶部） |
| Keil 工程 | `keil_PID/MDK-ARM/*.uvprojx` |
| **编译产物（被 git 跟踪）** | `keil_PID/MDK-ARM/PID/PID.hex`、`PID.map`、`PID.build_log.htm` |

历史：固件原先在 `C:\Users\huang\Desktop\keil\PID`，**2026-10-24 已整体迁入 `keil_PID/`**（commit `7e98c1a`）；
**2026-10-29 又从 1868 行的单文件 main.c 拆成上面这 4 个模块 + 头文件**。
桌面那个目录已经不存在，去那里找源码只会得到一个空结果——不要把它误判成"那里不是 git 仓库"。

## 1. ★ 开工第一条：先读 .md，再体检 git

任何"改代码 / 调参数 / 排查"动作之前，这两步都要做，**顺序不能颠倒**。

### 1.1 先读规则（落实全局 `G0`）

| 必读 | 路径 | 内容 |
|---|---|---|
| 环境级 | `$DSH_HOME/AGENTS.md` | dpx 环境约束 + `G0`（行动前读 .md）/ `G1`（改动后提交推送） |
| 仓库级 | `D:\codex\AGENTS.md` | 本文件：编码、提交、多 agent 协作守则 |

用户当轮点名、`@` 引用或作为附件给出的其它 `.md` 也一并读。**冲突时本文件优先**（更具体者胜）。

```bash
sha256sum "$DSH_HOME/AGENTS.md" D:/codex/AGENTS.md
```

- 哈希与上次读过的一致 → 可复用上下文里那份
- **哈希变了，或拿不到上次哈希（新会话 / 上下文被压缩）→ 全文重读再动手**

> 为什么不能信上下文：本仓库有多个 agent 并行（见 §7），规则文件随时会被别人改，
> 且**改了不会有通知**。已发生 4 次改动互相覆盖事故，其中就有"照旧快照干活"的直接后果。

### 1.2 再体检 git

**第一条 git 命令必须是**：

```bash
git -C D:/codex status -sb
git -C D:/codex log -3 --format='%h %ad %s' --date=short
```

必须看清三件事：

1. **目标文件是否已有未提交的改动** —— 有就先停、先问用户，**绝对不要直接覆盖**
2. **`main.c` 与 `PID.hex` 是否成对** —— 只有 `main.c` 变、`hex` 没变 = **源码改了但没重编，车上跑的还是旧固件**
3. `[ahead N]` / `[behind N]` —— 本地有没有没推上去或没拉下来的东西

> 反例（真实踩过）：曾在 `keil_PID/Core/Src/main.c` 里连续改了 3 天、改了 11 KB，一次 `git status` 都没敲，
> 全程用 `bak_*/` 目录手工做版本管理；还把"桌面目录已不存在"误判成"那里不是 git 仓库"。
> 结果：报给用户的行号、行数、结论全部过期。

## 2. ★★ 编码：全工程 **UTF-8**（部分带 BOM）+ CRLF

```
$ file keil_PID/Core/Src/main.c
main.c: Unicode text, UTF-8 text, with CRLF line terminators
```

**2026-10-30 起源码已从 GBK 统一改为 UTF-8**（`main.c`/`tim3_pid.c`/`Ccd_Frame.c`/`Blue_ProcessPackets.c`/
`OLED_RenderStatus.c`/`car.h` 及四个模块头，部分文件带 BOM）。
仓库根目录的 `main.c.GBK_GOOD_*`、`main.c.bak_brokenutf8_*` 是当年 GBK↔UTF-8 互相踩坏留下的现场。

规则：

- 编辑任何 `.c/.h` **保持 UTF-8 + CRLF**，**不要用 iconv 转回 GBK** —— 转了 Keil 里全是乱码
- **改完立刻验两件事**：

  ```bash
  iconv -f UTF-8 -t UTF-8 <文件> > /dev/null      # 不报错 = 是合法 UTF-8
  perl -ne '$n += () = /\xEF\xBF\xBD/g; END{print $n+0,"\n"}' <文件>   # 必须是 0
  ```

  `U+FFFD`（替换字符）出现 = **中文已不可逆丢失**，先从备份恢复，再查是哪个编辑器保存导致的。

- 中文是否还在：`grep -c "循迹" <文件>` 应非 0
- 本文件（`AGENTS.md`）和其它文档用 **UTF-8 无 BOM**

## 3. 改动 → 提交 → 推送

| 时机 | 动作 |
|---|---|
| 改文件前 | `git status -- <目标文件>` 确认干净；不干净先问 |
| 改完 | `git diff --stat -- <目标文件>` 自查改了哪些行，**不靠记忆报行号** |
| 提交 | `git add -- <具体路径>`，只加相关文件；**不用 `-A` 裸提交** |
| 提交信息 | 中文一句话讲清「改了什么 + 为什么」，必要时附现象/日志摘要 |
| 推送 | **必须推，不是可选**（见 7.5）。先 `git fetch`，再 `git push`；失败如实报告，不要反复重试到超时 |
| 验推送 | `rev-parse HEAD` 与 `ls-remote origin refs/heads/main` 哈希一致才算真的上传；`ahead N` 就是没推上去 |

**固件改动必须成对提交**：改动到的 `.c/.h`（源码）+ `PID.hex` / `PID.map`（重编后产物）+ `PID.build_log.htm`。
三样齐了才算一次"可以烧进车"的提交。**改了头文件也算改源码**（模块头会影响所有 .c）。

**Keil 编译无法在本 shell 内完成**（机器上找不到 `UV4.exe`，也没有 `STM32_Programmer_CLI` / `openocd`）。
改完源码后必须：提示用户在 Keil 里 Build → **核对 `PID.hex` 时间戳比所有改过的源文件新** → 才能说"修好了"。
**编译错误只能由用户粘回来**，所以改动要小步、可回退，别一次性重写多个文件。

## 4. 不入库的东西（`git status` 里不该看见）

| 路径 | 原因 |
|---|---|
| `keil_PID/MDK-ARM/PID/*`（hex/map/build_log 除外）| Keil 中间产物，体积大 |
| `keil_PID - 副本/` | 整份工程拷贝（旧） |
| `gmr_tmp/` | 上千个临时 pptx/docx |
| `*.bak`、`*.bak-*`、`*.bak_*`、`main.c.GBK_GOOD_*`、`main_K.c`、`main_T.c` | 手工备份与草稿 |
| `.zcode/` | 会话临时目录 |

**不要再用新目录做一份"备份工程"** —— 版本控制已经在这里了。
需要留现场时用 `git stash` 或临时分支，不要再造 `bak_xxx_日期/`。

## 5. 调试硬事实（都是踩过的）

| 事实 | 后果 |
|---|---|
| `USART3` 是 **115200 波特**，7 通道 `[plot:...]` 一帧约 **4.8 ms** | 串口已不是瓶颈，主循环变成 OLED 主导 |
| `OLED_Update()` 刷 1024 字节，约 **23 ms** | **主循环最坏约 28 ms ≈ 35 Hz** |
| 所以 VOFA+ 里 `Δt` 必须按实测填（≈28 ms）| 默认 `Δt=1 ms` 会把横轴**压缩约 28 倍**，看到的"高频抖动"其实只有 1~2 Hz |
| 编码器 44 线 × 30 减速比 × 50ms 采样，1 脉冲 = 0.0152 转/秒 | 速度目标低于 ~0.08 转/秒时量化误差 >9%，会明显抖 |
| **下行链路只有单字节可靠**：`1`/`0`/`T`/`t` 能进；多字节包（`[joystick,...]`）会被 UART 溢出打死，而工程**没有 `HAL_UART_ErrorCallback`**，溢出一次接收就永久哑 | 排查命令类问题时先发一个裸字节 `t` 验证链路，再谈包 |
| **`Angle` 只建模俯仰**：陀螺用 `GX`，加速度用 `−atan2(AY,AZ)`；滚转（侧翻）产生的是 `GY`，而 `AX` 从未参与判断 | 车**侧向倒下时 `Angle` 读不出来**（α=0.001，时间常数 10s），会一直显示 ±10° 左右 |
| 摔倒判据 `fabsf(Angle) > ERECT_START_ANG` | 因为上一条，**侧翻不会触发停车** → 车躺在地上仍满力空转。要补侧翻判据只能另用 `|AX|/|g|` |
| 转向输出 = `TurnPID.Out + TURN_FF × Target`，`TURN_FF = 18.0f` | 前馈权重远大于反馈，**大转向时差速顶在限幅上，此时调 `TurnPID.Kp` 无效** |
| 实测打滑门槛：`DifPWM≈12` 时交付 ~47%（平滑）；`≈23` 时交付掉到 **1.3%**（粘滑极限环）| 往 `DifPWM` 限幅里塞超过 ~16~18 的值只会变成抖动 |

当前关键宏（**行号会漂，用 `grep -n` 复核，不要照抄本表**）：

```
TURN_FF            18.0f    tim3_pid.c:150
TURN_FB_SIGN       (+1)     tim3_pid.c:171   ← 2026-10-30 又翻回 +1（曾长期 -1）
PITCH_BIAS_ENABLE     1     tim3_pid.c:78
ERECT_START_ANG    55.0f    tim3_pid.c:185
PIVOT_RATE          0.9f    Ccd_Frame.c:80
PIVOT_MIN_DEG      40.0f    Ccd_Frame.c:88
PIVOT_USE_CCD_STOP    0     Ccd_Frame.c:109   ← 0 = 固定角度停转
PIVOT_FIXED_DEG    84.0f    Ccd_Frame.c:110
CORNER_SIDE_SIGN   (+1)     Ccd_Frame.c:136
TRACK_GAIN          1.2f    Ccd_Frame.c:36
TRACK_SPEED         0.1f    Ccd_Frame.h:17
CORNER_SPEED        0.0f    Ccd_Frame.h:111
PIVOT_TIMEOUT_MS   3000     Ccd_Frame.h:58
InnerLockMode         1     main.c:177       ← 0=关 1=只钳弱反转段 2=内轮钳0(会把平衡权限腰斩)
```

## 6. 交付定义：改完 ≠ 改对

报结果前至少做一次**产物级核验**，不要只信退出码：

- 改了源码 → `PID.hex` 已重编、时间戳更新、`build_log` 是 **0 Error**
- 改了某个宏 → `grep -n` 确认该宏在文件里**没有残留的第二处定义**
- 报了行号 → 用 `git diff` / `grep -n` 重新确认，**不用记忆**
- 报了数字（行数、字节数、采样率）→ 用 `wc` / `file` / `grep` 现算，**不用印象**

> 反例（真实踩过）：凭记忆报 `main.c` 是 1584 行，实测 **1702 行**（当时还没拆分）；
> 报仓库"4 次提交、HEAD `f37983c`"，实测 **7 次、HEAD `7a3c6bc`**。
> 现状（2026-10-31 实测）：`main.c` **602 行**（`wc -l` 现算）。
> 提交数与 HEAD **每提交一次就变**，所以本行**不写死数字** —— 用 `git rev-list --count HEAD` 与 `git log -1` 现算。

## 7. ★★ 多 Agent 协作守则（本仓库有多个 agent 并行工作）

本仓库同时有**多个 AI agent / 会话**在改固件。2026-10-24 ~ 10-31 期间已发生 **4 次**
"我的改动被另一个会话的保存覆盖"事故（含一次把已验证的摔车保护修复整个冲掉）。
以下规则的目的只有一个：**任何 agent 的任何一次保存，都不允许无声地毁掉别人的工作。**

### 7.1 认领锁：动固件前先占坑

写 `keil_PID/` 下任何文件之前，先检查并写入租约文件：

```bash
# 开工：先看有没有别人占着（mtime 距今 < 2 小时视为有效租约）
cat /d/codex/.agent-lease 2>/dev/null

# 没有冲突再占坑：一行 = agent标识 | 时间 | 认领的文件
echo "zcode-session-X | $(date '+%m-%d %H:%M') | keil_PID/Core/Src/main.c" > /d/codex/.agent-lease

# 收工（编译+提交完成后）立刻释放
rm /d/codex/.agent-lease
```

- 租约存在且未过期 → **不要动那些文件**，先问用户协调； emergency 除外（如正在行驶的安全问题）
- 租约是软锁：它防的是"不知情"，不是恶意。过期（>2h）可以接管，接管时在租约里写一行"接管记录"
- `.agent-lease` 不入库（已在 `.gitignore`）

### 7.2 单写者纪律：禁止用内存副本覆写磁盘

1. **每次 Edit 前必须重新 Read 磁盘上的最新版本**——哪怕 5 分钟前刚读过。
   你的上下文里那份"文件内容"随时可能已被另一个 agent 重写；
2. 遇到 `File has been modified since read` 报错 → 重读、重新核对你要改的位置是否还存在，**禁止盲改**；
3. 大段搬移/重构后，**先编译通过再保存最后一版**，中间状态不要停在外部编辑器的缓冲区里过夜。

### 7.3 被覆盖后的正确恢复姿势

发现自己的改动消失时：

1. `git log --oneline -5` + `git reflog` 找是谁、哪次提交/保存覆盖的；
2. **禁止把旧版本整文件翻回去**——那会把对方的新工作冲掉，进入互相覆盖死循环；
3. 正确做法：基于**当前 HEAD** 把自己的改动**重新施加**（小补丁形式），并在提交信息里注明
   "恢复被 <commit> 覆盖的 X"；
4. 丢失的是**行为级修复**（保护逻辑、符号位、阈值）时，恢复后必须重新编译 + 成对提交（第 3 节）。

### 7.4 行为级改动必须留痕

改以下任何一项，必须留下"依据"，形式 = 提交信息写明实测数据来源，或在第 5 节登记：

- 符号位（`TURN_FB_SIGN` / `TRACK_DIR` / `CORNER_SIDE_SIGN` / `ENC_YAW_SIGN` 等）
- 保护阈值（`ERECT_START_ANG` 等）
- 电机/编码器通道映射（TB6612 通道、htim2/htim4）

> 反例（真实踩过）：`TURN_FB_SIGN` 在 2026-10-25 由数据翻案改为 -1，10-28 又因电机通道
> 对调翻回 +1——两次翻转各有依据但没登记，下一个 agent 只看注释就会把"正确值"改回"错误值"。

### 7.5 ★★ 每次改动后必须提交并推送（不是"小步提交"就够了）

**一次逻辑改动（一个 bug 修复 / 一个功能 / 一批相关编辑）= 编译验证 + 成对提交 + 推送成功。**
三步缺一不可；**只 commit 不 push 等于没做**（同一规则的全局版本见 `$DSH_HOME/AGENTS.md` 的 G1）。

**为什么必须推送**：本仓库有多个 agent / 会话。未推送的改动对别人等于不存在；
**未跟踪（untracked）的新文件最致命** —— `car.h` / `tim3_pid.c` / `Ccd_Frame.c` 这类模块文件
只躺在工作区却没 `git add` 时，别人 clone 下来 `main.c` 的 `#include "car.h"` 直接断，**工程根本编译不过**，
比"看不到你的改动"更糟。

**判据不能是"commit 成功"**，必须是哈希一致：

```bash
git -C D:/codex rev-parse HEAD
git -C D:/codex ls-remote origin refs/heads/main
# 两个哈希相等 = 真的推上去了
```

`ahead N` 且远程哈希不同 = **没推上去**，报告里必须写明「本地已提交、远程未同步」。

**推送连不上时先试这一条**（本机已实测，是目前唯一有效的配置）：

```bash
git -C D:/codex config --local http.sslBackend schannel
```

症状特征：`curl https://github.com` 返回 **200**，但 `git push` 报
`Recv failure: Connection was reset` 或 `Failed to connect to github.com:443`。
这是 **git 的 TLS 后端（OpenSSL）** 与这条链路的差异，**不是网络不通** ——
不要再按"开代理 / 检查端口"的思路排查（曾据此误判 4 天）。

**禁止**把 1500 行的未提交改动攒在手里过夜——那既是对别人的地雷（见 7.1），
也是对自己的一锤子买卖（覆盖后无法找回）。
