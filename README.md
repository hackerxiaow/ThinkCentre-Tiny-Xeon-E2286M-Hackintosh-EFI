# ThinkCentre Tiny (Xeon E-2286M) Hackintosh OpenCore EFI

适用于 **联想 ThinkCentre Tiny（M720q / M920q / P330 Tiny 等微型主机）** 搭载 **Intel Xeon E-2286M 魔改 CPU** 的完整 macOS OpenCore 引导配置。

---

## 💻 硬件配置概要

| 组件 | 规格参数 | 驱动/补丁支持 |
| :--- | :--- | :--- |
| **设备型号** | 联想 ThinkCentre Tiny 微型主机 | 仿冒机型：`Macmini8,1` |
| **处理器** | Intel Xeon E-2286M (8C/16T, 2.4~5.0GHz) | `RestrictEvents.kext` + `SMCProcessor` |
| **核心显卡** | Intel UHD Graphics 630 (`0x3E9B`) | `WhateverGreen.kext` (DP/HDMI 输出) |
| **板载声卡** | Realtek ALC294 (`0x10EC0294`) | `AppleALC.kext` (alcid=12, alcverbs=1) |
| **有线网卡** | Intel I219-LM2 PCI-E 千兆网卡 | `IntelMausiEthernet.kext` |
| **引导工具** | OpenCore 1.0.7 正式版 | 支持 macOS Ventura 13.x / Sonoma 14.x |

---

## 🔊 核心专题一：机箱内置小喇叭无声与修复

### 1. 现象与底层原理剖析
- **现象**：在 Windows 下小喇叭完全正常；在 macOS 下插 3.5mm 耳机正常有声音，但拔掉耳机后，机箱自带的小喇叭完全静音。
- **根本原因**：
  1. 耳机输出由 ALC294 芯片直接驱动，因此插上耳机能够正常发声；
  2. 机箱内置扬声器需要经过主板上的独立微型功放（Class-D 放大器）。在 macOS 下，由于缺少专有驱动控制，芯片内部被锁死在省电休眠模式（寄存器 `COEF Index 0x10 = 0x8420`，Bit 10 为 Power-Down 锁定），且板载 GPIO 供电引脚输出电平为 0V，导致小喇叭完全拿不到电流；
  3. **为什么不能只写在 EFI 阶段？** macOS 原生音频驱动（AppleHDA）在音频播放结束、插拔耳机或睡眠唤醒时，会自动执行一次 Codec 硬件复位，导致芯片再次回到休眠状态。因此必须通过系统级服务进行动态保活。

### 2. 解决方案：一键安装保活服务
仓库已内置完整的全自动修复工具包 `Audio-Fix`。

#### 一键安装步骤：
克隆或下载本仓库后，在终端中直接运行：
```bash
cd Audio-Fix
bash install.sh
```

#### 安装后效果：
- 自动部署 `alc-verb` 底层工具与唤醒脚本至 `~/bin/`；
- 自动注册 macOS 原生 LaunchAgent（`~/Library/LaunchAgents/com.user.alc294speaker.plist`）；
- 开机登录系统 0.01 秒自动唤醒小喇叭；每 30 秒自动守护一次供电（即使睡眠唤醒也能持续保持小喇叭发声）；
- 系统原生接管，CPU 与内存占用为 0%。

---

## ⚡ 核心专题二：电脑自动休眠掉电（假关机）排查与根治

### 1. 现象与崩溃日志确诊
- **现象**：电脑闲置离开一段时间后，主机突然关机掉电或无故重启。
- **日志证据**：
  查看 macOS 诊断日志（`/Library/Logs/DiagnosticReports/`），记录了确切的错误：
  ```text
  Event: Sleep Wake Failure in EFI
  Failure code: 0x00000000 0x0000001f
  ```
- **根本原因**：
  1. 系统默认被设置了 `sleep 1`（闲置 1 分钟强行进入深度休眠）；
  2. 模式为笔记本专用的混合休眠（`hibernatemode 3`），黑苹果台式机缺乏苹果官方电池电源管理芯片，在写硬盘休眠镜像时与 UEFI 握手失败，直接触发硬件断电崩溃；
  3. 开启了 `powernap 1`（定时后台暗唤醒），导致闲置时频繁掉电死机。

### 2. 解决方案：一行命令彻底根治
在终端中复制并执行黑苹果台式机官方标准电源优化命令：

```bash
sudo pmset -a sleep 0 hibernatemode 0 powernap 0 standby 0 proximitywake 0 tcpkeepalive 0
```
*(输入开机密码后按回车，如出现 TCP Keep Alive 警告属正常现象)*

#### 优化收益：
- **彻底消除意外关机**：关闭主机闲置掉电休眠，电脑永不无故关机；
- **依然享受正常节能**：系统保留 `displaysleep 10`，闲置 10 分钟后外接显示器依然正常息屏黑屏省电，晃动鼠标/按键立刻秒亮。

---

## 🛠️ 安装与日常使用指南

### 1. 替换 / 安装 EFI
1. 在 macOS 中挂载当前系统的 ESP（EFI）分区：
   ```bash
   sudo diskutil mount /dev/disk0s1
   ```
2. 将本仓库中的 `EFI` 文件夹复制并替换到挂载后的 EFI 分区根目录。

### 2. 重新生成三码（推荐）
建议使用 [OpenCore Configurator](https://mackie100projects.altervista.org/opencore-configurator/) 打开 `EFI/OC/config.plist`，在 **PlatformInfo -> Generic** 中重新生成专属于你自己的 `System Serial Number`、`MLB` 与 `System UUID`，避免 Apple ID 登录冲突。

### 3. 重启生效
替换配置后重启电脑，在 OpenCore 开机引导菜单处按空格键，选择 **Reset NVRAM** 清除一次缓存，随后即可正常进入系统。
