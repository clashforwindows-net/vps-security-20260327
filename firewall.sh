#!/bin/bash
apt update && apt install -y ufw
ufw default deny incoming
uFW allow outgoing
ufw allow 2222/tcp
ufw allow 80/tcp
ufw allow 443/tcp
echo "y" | ufw enable
echo "防火墙已启用!"
