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
| 主文件 | **`keil_PID/Core/Src/main.c`** —— 约 **1702 行 / 77841 字节**，绝大部分逻辑在这一个文件里 |
| Keil 工程 | `keil_PID/MDK-ARM/*.uvprojx` |
| **编译产物（被 git 跟踪）** | `keil_PID/MDK-ARM/PID/PID.hex`、`PID.map`、`PID.build_log.htm` |

历史：固件原先在 `C:\Users\huang\Desktop\keil\PID`，**2026-10-24 已整体迁入 `keil_PID/`**（commit `7e98c1a`）。
**那个桌面目录已经不存在**，去那里找源码只会得到一个空结果——不要把它误判成"那里不是 git 仓库"。

## 1. ★ 开工第一条：先体检 git

任何"改代码 / 调参数 / 排查"动作之前，**第一条命令必须是**：

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

## 2. ★★ 编码：`main.c` 是 **GBK**，不是 UTF-8

```
$ file keil_PID/Core/Src/main.c
main.c: ISO-8859 text, with CRLF line terminators     # 实为 GBK/CP936 + CRLF
```

**这是本仓库最容易出不可逆损坏的地方。** 文件里大量中文注释，用 UTF-8 直写会把它们变成乱码；
仓库根目录的 `main.c.GBK_GOOD_*`、`main.c.bak_brokenutf8_*` 就是此前踩坏后留下的现场。

规则：

- 编辑 `main.c` **必须保持 GBK + CRLF**，不得顺手转成 UTF-8 / LF
- **编辑完立刻用 git 验编码**：

  ```bash
  git -C D:/codex diff --numstat -- keil_PID/Core/Src/main.c
  ```

  **判据：若增删行数远大于你实际改动，或 diff 里出现整片无关的中文注释变化 → 编码已坏，
  立即 `git checkout -- keil_PID/Core/Src/main.c` 回滚，换一种编辑方式重做。**

- 想确认文件当前是否还是好的：`python -c "open('keil_PID/Core/Src/main.c',encoding='gbk').read()"` 不抛异常即为 GBK 完好
- 本文件（`AGENTS.md`）和其它文档用 **UTF-8 无 BOM**

## 3. 改动 → 提交 → 推送

| 时机 | 动作 |
|---|---|
| 改文件前 | `git status -- <目标文件>` 确认干净；不干净先问 |
| 改完 | `git diff --stat -- <目标文件>` 自查改了哪些行，**不靠记忆报行号** |
| 提交 | `git add -- <具体路径>`，只加相关文件；**不用 `-A` 裸提交** |
| 提交信息 | 中文一句话讲清「改了什么 + 为什么」，必要时附现象/日志摘要 |
| 推送 | 先 `git fetch`，再 `git push`；失败如实报告网络错误，不要反复重试到超时 |

**固件改动必须成对提交**：`main.c`（源码）+ `PID.hex` / `PID.map`（重编后产物）+ `PID.build_log.htm`。
三样齐了才算一次"可以烧进车"的提交。

**Keil 编译无法在本 shell 内完成**（机器上找不到 `UV4.exe`）。改完源码后必须：
提示用户在 Keil 里 Build → **核对 `PID.hex` 时间戳比 `main.c` 新** → 才能说"修好了"。

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
| `USART3` 是 **9600 波特**，`[plot:...]` 一帧约 **21 ms**（源码注释 `main.c:105` 自己写着）| 发送是阻塞的 |
| `OLED_Update()` 刷 1024 字节，约 **23 ms** | 与串口叠加，**主循环最坏约 44.6 ms ≈ 22 Hz**（同一条注释） |
| 所以 VOFA+ 里 `Δt` 必须按实测填（≈45~100 ms）| 默认 `Δt=1 ms` 会把横轴**压缩 45~100 倍**，看到的"高频抖动"其实只有 1~2 Hz |
| `ERECT_START_ANG = 55.0f`（`main.c:398`）| 车身倾斜 8~13° **不会触发保护停车**，抖动会一直持续 |
| 转向输出 = `TurnPID.Out + TURN_FF × Target`，`TURN_FF = 18.0f`（`main.c:204`）| 前馈权重远大于反馈，**大转向时差速顶在限幅上，此时调 `TurnPID.Kp` 无效** |

当前转向/平衡相关宏（每次改动请自行复核，勿引用本表旧值）：

```
TURN_FF            18.0f    main.c:204
TURN_FB_SIGN       (-1)     main.c:227   ← 极性曾长期接反
PIVOT_RATE          0.6f    main.c:299
PIVOT_MIN_DEG      45.0f    main.c:306
PIVOT_TIMEOUT_MS   3000     main.c:310
CORNER_SIDE_SIGN   (+1)     main.c:338
ERECT_START_ANG    55.0f    main.c:398
```

## 6. 交付定义：改完 ≠ 改对

报结果前至少做一次**产物级核验**，不要只信退出码：

- 改了源码 → `PID.hex` 已重编、时间戳更新、`build_log` 是 **0 Error**
- 改了某个宏 → `grep -n` 确认该宏在文件里**没有残留的第二处定义**
- 报了行号 → 用 `git diff` / `grep -n` 重新确认，**不用记忆**
- 报了数字（行数、字节数、采样率）→ 用 `wc` / `file` / `grep` 现算，**不用印象**

> 反例（真实踩过）：凭记忆报 `main.c` 是 1584 行，实测 **1702 行**；
> 报仓库"4 次提交、HEAD `f37983c`"，实测 **7 次、HEAD `7a3c6bc`**。

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

### 7.5 小步提交，不留大片未提交改动

一次逻辑改动（一个 bug 修复 / 一个功能）= 一次 编译验证 + 一次成对提交。
**禁止**把 1500 行的未提交改动攒在手里过夜——那既是对别人的地雷（见 7.1），
也是对自己的一锤子买卖（覆盖后无法找回）。
