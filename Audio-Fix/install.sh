#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== 正在安装 Realtek ALC294 机箱小喇叭唤醒服务 ==="

# 1. 安装工具与脚本到 ~/bin
mkdir -p "$HOME/bin"
cp "$DIR/alc-verb" "$HOME/bin/alc-verb"
cp "$DIR/alc294-speaker-enable.sh" "$HOME/bin/alc294-speaker-enable.sh"
chmod +x "$HOME/bin/alc-verb" "$HOME/bin/alc294-speaker-enable.sh"
echo "[✓] 已安装 alc-verb 与唤醒脚本到 $HOME/bin"

# 2. 安装并加载 LaunchAgent
mkdir -p "$HOME/Library/LaunchAgents"
cp "$DIR/com.user.alc294speaker.plist" "$HOME/Library/LaunchAgents/"
launchctl unload "$HOME/Library/LaunchAgents/com.user.alc294speaker.plist" 2>/dev/null
launchctl load "$HOME/Library/LaunchAgents/com.user.alc294speaker.plist"
echo "[✓] 已加载开机自启服务 com.user.alc294speaker"

# 3. 立即触发一次测试发声
"$HOME/bin/alc294-speaker-enable.sh"
afplay /System/Library/Sounds/Ping.aiff 2>/dev/null
echo "[✓] 安装完成！小喇叭已激活。"
