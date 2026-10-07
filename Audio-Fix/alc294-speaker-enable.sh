#!/bin/bash
TOOL="/Users/Xiaow/bin/alc-verb"

# 1. GPIO 供电拉高
$TOOL -d 0 0x01 0x716 0x0f >/dev/null 2>&1
$TOOL -d 0 0x01 0x717 0x0f >/dev/null 2>&1
$TOOL -d 0 0x01 0x715 0x0f >/dev/null 2>&1

# 2. 写入 ALC294 Class-D 功放唤醒系数
$TOOL -d 0 0x20 0x500 0x10 >/dev/null 2>&1
$TOOL -d 0 0x20 0x400 0x0120 >/dev/null 2>&1
