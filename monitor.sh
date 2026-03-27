#!/bin/bash
DATE=$(date)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d% -f1)
MEM=$(free | grep Mem | awk '{print int($3/$2*100)}')
DISK=$(df -h / | tail -1 | awk '{print $5}' | cut -d% -f1)
echo "[$DATE] CPU: ${CPU}% MEM: ${MEM}% DISK: ${DISK}"
