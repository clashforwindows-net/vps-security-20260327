#!/bin/bash
echo "=========================================="
echo "         VPS 性能测试"
echo "=========================================="
echo ""
echo "[系统信息]"
echo "Hostname: $(hostname)"
CPU=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d: -f2)
echo "CPU: $CPU"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $2}')"
echo ""
echo "[磁盘I/O测试]"
dd if=/dev/zero of=test bs=64k count=256 oflag=dsync 2>&1 | grep copied
rm -f test
echo "测试完成"
