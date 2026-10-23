# D:\codex 工作区

围绕 **STM32F103 智能车项目**(TSL1401 线性 CCD 巡线 + PID)的工具场与归档场。
实际 Keil 工程在 `D:\Users\huang\Desktop\keil\`,本仓库保存历次改动的源码快照、
构建日志、反汇编核对、补丁脚本、串口联调数据和参考资料。

2026-10-23 起纳入 git 管理:`95b963a` 为整理前原貌快照,`5542401` 为分类归档,
所有移动均为纯重命名,历史可追溯。

## 目录地图

### 活跃/进行中
| 目录 | 内容 |
|---|---|
| `gmr_tmp/` | 赛道数据分析 + PPT 制作(build.js / build_ppt.js / base.pptx),10-22~10-23 主线 |
| `work/` | 最新 main_utf8.c 快照与快速图片输出 |

### 智能车项目归档(按物料类型)
| 目录 | 内容 |
|---|---|
| `src_archive/` | 历次改动的源码快照:`main.c.bak_*`、`*_utf8.c`、`cur_*`/`mine_*` 对照、PID_full 完整备份 zip |
| `build_logs/` | ~50 个 Keil UV4 编译日志,对应每次改动(oled/yaw/key/拐角/注释等) |
| `disasm/` | 反汇编与编译器汇编输出核对(dis*.txt、PID_gpio.dis、yawcost-O*.s 等) |
| `firmware/` | flash 镜像(pid_flash.bin、bin_A/B/FINAL/OUT*.bin) |
| `tools/` | 补丁/编码/校验脚本(apply_*.ps1、enc_diag*.ps1、codediff、pdf 提取工具、gm-*.mjs)与补丁载荷 |
| `serial_capture/` | COM7 串口联调脚本与采集数据(cap_*.csv/raw、rx_trace、track_log) |
| `reports/` | 编码诊断/完整性校验报告(enc_report、integrity_report、verify_report 等) |

### 参考资料与文档
| 目录 | 内容 |
|---|---|
| `docs/` | 会话压缩总结(2026-10-05,含 CCD 问题诊断)、TSL1401 数据手册、考核 PDF 提取文本与图片 |
| `CCD控制舵机-解读/` | 板卡接口图:J2 CCD 口、J3 舵机口、U1 主控、U2 电机驱动 |
| `_ref_balance/` | 平衡车参考工程(control.c/tim.c 等) |
| `_pid_utf8/` | PID 工程 UTF-8 转码副本 |
| `_port_ab/` | 移植 A/B 前后对照源码与 hex |
| `_bt_snippets/` | 蓝牙片段笔记 |

### 独立支线
| 目录 | 内容 |
|---|---|
| `PortalAutoLogin/` | 校园网门户自动登录(PowerShell + VBS)。**含明文口令,勿推送到公共远程** |
| `dsh-routing-suite/` | git submodule,远程 `github.com/yjh051108/dsh-routing-suite` |
| `bak_*/`、`PID_backup_*/` | 各阶段整目录备份(cmt/corner/cornerspeed/key/key3/key4/track) |
| `.dsh-*/`、`.acl-recovery/` | dsh 套件与 ACL 相关的历史备份 |

## 未入库(见 .gitignore)
- `.ps7-install/` — PowerShell 7.6.8 安装介质与探针(118MB,2026-10-23 晚)
- `*.msi`、`_probe*.bin`、`_sp_trace.txt`

## 备注
- 仓库身份为本地占位(`huang <huang@local>`),如需正式身份请改 `git config`。
- 外部 Keil 工程(`D:\Users\huang\Desktop\keil`)尚未纳入版本控制,仍靠手工 `bak_*`。
