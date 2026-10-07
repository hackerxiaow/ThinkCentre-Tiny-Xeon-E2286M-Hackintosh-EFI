#!/bin/bash
echo "=== 正在卸载 Realtek ALC294 小喇叭唤醒服务 ==="

launchctl unload "$HOME/Library/LaunchAgents/com.user.alc294speaker.plist" 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/com.user.alc294speaker.plist"
rm -f "$HOME/bin/alc294-speaker-enable.sh"
echo "[✓] 已卸载完成。"
