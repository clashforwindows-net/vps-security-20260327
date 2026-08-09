# VPS安全加固工具箱2026

> SSH加固/防火墙/BBR加速/入侵检测/安全审计完整指南

## 推荐 ⭐

**VPSVIP**: [https://vpsvip.net](https://vpsvip.net)
- 专业VPS推荐平台
- 高性能、低价格
- 优质客服支持

**安全相关服务**：
- [https://nav.clashvip.net](https://nav.clashvip.net) - 网络工具导航

---

## 📦 工具箱组成

本工具箱包含以下安全加固脚本，全部开源可定制：

| 脚本 | 功能 | 适用场景 |
|------|------|----------|
| `ssh-hardening.sh` | SSH安全加固 | 所有VPS |
| `firewall.sh` | 防火墙配置 | 所有VPS |
| `bbr.sh` | BBR加速 | 需要优化的VPS |
| `monitor.sh` | 入侵检测 | 高安全需求 |

---

## 🚀 快速开始

```bash
# 克隆仓库
git clone https://github.com/clashforwindows-net/vps-security-20260327.git
cd vps-security-20260327

# 设置执行权限
chmod +x *.sh

# 运行SSH加固（推荐首先运行）
sudo ./ssh-hardening.sh

# 配置防火墙
sudo ./firewall.sh

# 开启BBR加速
sudo ./bbr.sh

# 启动入侵检测
sudo ./monitor.sh
```

---

## 🛡️ SSH安全加固详解

### 脚本功能

`ssh-hardening.sh` 提供以下安全加固：

#### 1. 更换SSH默认端口
```bash
# 将默认22端口改为高位端口（如22022）
Port 22022
```

**为什么重要**：
- 阻止自动化的端口扫描攻击
- 减少99%的SSH暴力破解尝试
- 避免被 Honeypot 检测

#### 2. 禁用ROOT直接登录
```bash
PermitRootLogin no
```

**为什么重要**：
- ROOT权限过大，风险高
- 需要通过普通用户提权操作
- 避免直接暴露ROOT账户

#### 3. 使用密钥认证
```bash
# 生成SSH密钥对
ssh-keygen -t ed25519 -C "your_email@example.com"

# 上传公钥到服务器
ssh-copy-id -p 22022 user@your-server-ip

# 禁用密码认证
PasswordAuthentication no
```

**为什么重要**：
- 密钥比密码安全100倍
- 避免暴力破解
- 防止密码泄露

#### 4. 配置Fail2Ban防暴力破解
```bash
# 安装Fail2Ban
apt install fail2ban -y

# 配置自动封禁
# 5次失败尝试后封禁1小时
```

**为什么重要**：
- 自动封禁恶意IP
- 减少服务器负载
- 提供实时监控

#### 5. SSH连接超时配置
```bash
# 客户端无响应30秒后断开
ClientAliveInterval 30
ClientAliveCountMax 2

# 登录超时5分钟无操作断开
LoginGraceTime 300
```

#### 6. 限制可登录用户
```bash
AllowUsers user1 user2 user3
```

**推荐配置示例**：
```bash
# /etc/ssh/sshd_config

# 基础设置
Port 22022
Protocol 2
ListenAddress 0.0.0.0

# 认证设置
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
MaxAuthTries 3
MaxSessions 2

# 安全设置
ClientAliveInterval 30
ClientAliveCountMax 2
LoginGraceTime 300
AllowUsers deploy-admin

# 日志设置
SyslogFacility AUTH
LogLevel VERBOSE
```

### 运行脚本

```bash
# 完全自动加固
sudo ./ssh-hardening.sh

# 交互式加固（可选择项目）
sudo ./ssh-hardening.sh --interactive

# 只更换SSH端口
sudo ./ssh-hardening.sh --port-only

# 只配置Fail2Ban
sudo ./ssh-hardening.sh --fail2ban-only

# 查看帮助
sudo ./ssh-hardening.sh --help
```

### 加固后的检查

```bash
# 检查SSH配置语法
sshd -t

# 检查SSH服务状态
systemctl status sshd

# 查看登录日志
tail -f /var/log/auth.log

# 测试SSH连接（新窗口测试，避免断开）
ssh -p 22022 user@your-server-ip
```

---

## 🔥 防火墙配置详解

### 脚本功能

`firewall.sh` 提供以下防火墙配置：

#### 1. 默认拒绝所有入站流量
```bash
# 重置防火墙规则
iptables -F
iptables -X
iptables -Z

# 设置默认策略
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
```

**为什么重要**：
- 默认拒绝，安全性最高
- 只开放必要的端口
- 减少攻击面

#### 2. 允许已建立连接
```bash
# 允许已建立的连接
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 允许本地回环
iptables -A INPUT -i lo -j ACCEPT
```

#### 3. 开放必要端口

| 端口 | 服务 | 开放建议 |
|------|------|----------|
| 80 | HTTP | Web服务器必需 |
| 443 | HTTPS | Web服务器必需 |
| 22/22022 | SSH | 远程管理必需 |
| 20 | FTP | FTP主动模式 |
| 21 | FTP | FTP控制端口 |
| 30000-40000 | FTP被动模式 | FTP被动模式 |
| 3306 | MySQL | 仅本地访问 |
| 5432 | PostgreSQL | 仅本地访问 |
| 6379 | Redis | 仅本地访问 |
| 27017 | MongoDB | 仅本地访问 |
| 8080 | 自定义Web | 按需开放 |

**示例配置**：
```bash
# 允许SSH（更换后的端口）
iptables -A INPUT -p tcp --dport 22022 -j ACCEPT

# 允许HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# 允许Ping（可选，建议禁用）
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# 限制SSH连接频率（防止暴力破解）
iptables -A INPUT -p tcp --dport 22022 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 22022 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
```

#### 4. DDOS防护规则
```bash
# 限制每IP新连接数
iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 100 -j DROP

# 限制每秒请求数
iptables -A INPUT -p tcp --dport 80 -m limit --limit 100/second --limit-burst 100 -j ACCEPT

# SYN Flood防护
iptables -A INPUT -p tcp --syn -m limit --limit 100/s --limit-burst 200 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP
```

#### 5. 保存规则
```bash
# Ubuntu/Debian
apt install iptables-persistent -y
netfilter-persistent save

# CentOS/RHEL
service iptables save
```

### 运行脚本

```bash
# 完全配置防火墙
sudo ./firewall.sh

# 只开放80/443端口
sudo ./firewall.sh --web-only

# 只开放SSH+基本端口
sudo ./firewall.sh --minimal

# 查看当前规则
sudo ./firewall.sh --show

# 清空所有规则
sudo ./firewall.sh --flush

# 查看帮助
sudo ./firewall.sh --help
```

### 验证防火墙

```bash
# 查看所有规则
iptables -L -n -v

# 查看规则编号
iptables -L -n --line-numbers

# 测试端口是否开放
nc -zv your-server-ip 80
nc -zv your-server-ip 443
nc -zv your-server-ip 22022

# 从外部测试SSH
ssh -p 22022 user@your-server-ip
```

---

## 🚀 BBR加速配置详解

### 什么是BBR？

BBR（Bottleneck Bandwidth and Rounded trip time）是Google开发的TCP拥塞控制算法，可以显著提升网络吞吐量。

**BBR优势**：
- ✅ 提升网络吞吐量30%-100%
- ✅ 降低延迟
- ✅ 改善丢包环境下的性能
- ✅ 开源免费

### BBR vs 原生TCP

| 指标 | 原生TCP | BBR |
|------|---------|-----|
| 吞吐量 | 一般 | 高 |
| 延迟 | 一般 | 低 |
| 丢包恢复 | 差 | 好 |
| 高带宽利用 | 低 | 高 |
| 适用场景 | 普通环境 | 高延迟/丢包环境 |

### 脚本功能

`bbr.sh` 提供以下功能：

#### 1. 检查BBR支持
```bash
# 检查内核版本（需要4.9+）
uname -r

# 检查BBR模块
lsmod | grep bbr

# 检查可用算法
sysctl net.ipv4.tcp_available_congestion_control
```

#### 2. 开启BBR
```bash
# 临时开启（重启失效）
sysctl -w net.core.default_qdisc=fq
sysctl -w net.ipv4.tcp_congestion_control=bbr

# 永久开启
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

# 应用配置
sysctl -p
```

#### 3. 验证BBR开启
```bash
# 检查当前算法
sysctl net.ipv4.tcp_congestion_control

# 应该显示：net.ipv4.tcp_congestion_control = bbr

# 检查队列算法
sysctl net.core.default_qdisc

# 应该显示：net.core.default_qdisc = fq
```

### 进阶优化

#### FQ队列优化
```bash
# FQ with Pacing
sysctl -w net.core.default_qdisc=fq
sysctl -w net.ipv4.tcp_congestion_control=bbr

# FQ-Codel（适合高并发）
sysctl -w net.core.default_qdisc=fq_codel
sysctl -w net.ipv4.tcp_congestion_control=bbr

# CAKE（智能队列）
sysctl -w net.core.default_qdisc=cake
sysctl -w net.ipv4.tcp_congestion_control=bbr
```

#### BBR参数调优
```bash
# 提升缓冲区
sysctl -w net.core.rmem_max=25000000
sysctl -w net.core.wmem_max=25000000
sysctl -w net.ipv4.tcp_rmem="4096 87380 25000000"
sysctl -w net.ipv4.tcp_wmem="4096 65536 25000000"

# 提升连接跟踪表大小
sysctl -w net.netfilter.nf_conntrack_max=1048576

# 提升文件描述符限制
sysctl -w fs.file-max=1000000
```

### 运行脚本

```bash
# 启用BBR（自动选择最佳配置）
sudo ./bbr.sh

# 只检查环境
sudo ./bbr.sh --check

# 只启用BBR（不优化参数）
sudo ./bbr.sh --enable-only

# 完整优化（包括参数调优）
sudo ./bbr.sh --full-optimize

# 卸载BBR恢复原状
sudo ./bbr.sh --uninstall

# 查看帮助
sudo ./bbr.sh --help
```

### 性能测试

```bash
# 安装测试工具
apt install iperf3 -y

# 服务器端
iperf3 -s -p 5201

# 客户端测试
iperf3 -c your-server-ip -p 5201 -t 30

# 观察输出中的吞吐量，应该有明显提升
```

---

## 🔍 入侵检测详解

### 监控脚本功能

`monitor.sh` 提供以下监控功能：

#### 1. 登录日志监控
```bash
# 监控SSH登录
tail -f /var/log/auth.log | grep sshd

# 检测失败登录
grep "Failed password" /var/log/auth.log

# 检测成功登录
grep "Accepted" /var/log/auth.log
```

#### 2. 可疑行为检测
```bash
# 检测SU命令使用
grep "SU" /var/log/auth.log

# 检测sudo使用
grep "sudo" /var/log/auth.log

# 检测服务重启
journalctl -xe

# 检测端口扫描
netstat -an | grep SYN_RECV | wc -l
```

#### 3. 资源使用监控
```bash
# CPU使用率
top -bn1 | head -20

# 内存使用
free -h

# 磁盘使用
df -h

# 网络连接数
netstat -an | wc -l
```

#### 4. 自动化监控脚本
```bash
#!/bin/bash
# monitor.sh 核心功能

# 1. SSH登录监控
echo "=== SSH登录监控 ==="
last -10
echo ""

# 2. 失败登录统计
echo "=== 失败登录统计 ==="
grep "Failed password" /var/log/auth.log | tail -10
echo ""

# 3. 活跃连接
echo "=== 当前连接 ==="
who
echo ""

# 4. 资源使用
echo "=== 资源使用 ==="
free -h
df -h
echo ""

# 5. 进程监控
echo "=== 高CPU进程 ==="
ps aux --sort=-%cpu | head -10
echo ""

# 6. 网络状态
echo "=== 网络状态 ==="
netstat -tuln | grep LISTEN
```

### 运行监控

```bash
# 实时监控（Ctrl+C退出）
sudo ./monitor.sh

# 单次报告
sudo ./monitor.sh --report

# 定时报告（每小时）
sudo ./monitor.sh --daemon --interval 3600

# 邮件告警配置
sudo ./monitor.sh --alert --email admin@example.com

# 查看帮助
sudo ./monitor.sh --help
```

---

## 📋 安全检查清单

### 初始化安全检查

- [ ] 更改SSH默认端口
- [ ] 禁用ROOT直接登录
- [ ] 配置SSH密钥认证
- [ ] 禁用密码认证
- [ ] 安装配置Fail2Ban
- [ ] 配置防火墙规则
- [ ] 开启BBR加速
- [ ] 配置自动安全更新
- [ ] 设置日志轮转
- [ ] 配置备份策略

### 定期安全检查

- [ ] 检查登录日志
- [ ] 检查失败登录尝试
- [ ] 检查资源使用异常
- [ ] 检查开放端口
- [ ] 检查运行进程
- [ ] 更新系统软件包
- [ ] 检查磁盘使用
- [ ] 测试备份恢复
- [ ] 检查证书有效期
- [ ] 审查用户账户

---

## 🛠️ 实用安全工具

### 1. Rkhunter（Rootkit检测）
```bash
# 安装
apt install rkhunter -y

# 更新数据库
rkhunter --update

# 全盘扫描
sudo rkhunter --checkall

# 查看报告
cat /var/log/rkhunter.log
```

### 2. ClamAV（病毒扫描）
```bash
# 安装
apt install clamav -y

# 更新病毒库
freshclam

# 扫描目录
clamscan -r /home

# 扫描并删除感染文件
clamscan -r --remove /home
```

### 3. Lynis（安全审计）
```bash
# 安装
apt install lynis -y

# 运行审计
sudo lynis audit system

# 查看详细报告
cat /var/log/lynis.log
```

### 4. OSSEC（入侵检测）
```bash
# 安装（需要编译）
wget https://github.com/ossec/ossec-hids/archive/refs/heads/master.zip
unzip master.zip
cd ossec-hids-master
./install.sh

# 启动服务
/var/ossec/bin/ossec-control start
```

---

## 🔧 高级配置

### Fail2Ban高级配置

```bash
# /etc/fail2ban/jail.local

[DEFAULT]
# 邮箱通知
destemail = admin@example.com
sender = fail2ban@vps-server.com
action = %(action_mwl)s

[sshd]
# SSH防暴力破解
enabled = true
port = 22022
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
findtime = 600
bantime = 3600
banaction = iptables-multiport

[nginx-http-auth]
# Nginx认证保护
enabled = true
port = http,https
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 5

[nginx-noscript]
# 防止恶意脚本
enabled = true
port = http,https
filter = nginx-noscript
logpath = /var/log/nginx/access.log
maxretry = 3
```

### 自动安全更新

```bash
# 安装 unattended-upgrades
apt install unattended-upgrades -y

# 配置自动更新
dpkg-reconfigure unattended-upgrades

# 配置文件
cat > /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Mail "admin@example.com";
EOF

# 测试
unattended-upgrades --dry-run
```

### 日志管理

```bash
# 配置日志轮转
cat > /etc/logrotate.d/vps-security << EOF
/var/log/auth.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 0600 root root
    sharedscripts
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
EOF
```

---

## 🚨 应急响应

### 发现被入侵怎么办？

**Step 1: 隔离**
```bash
# 断开网络连接
iptables -I INPUT -j DROP
iptables -I OUTPUT -j DROP

# 或禁用网卡
ifdown eth0
```

**Step 2: 分析**
```bash
# 查看登录日志
last
lastb
grep "Failed\|Accepted" /var/log/auth.log | tail -100

# 查看进程
ps auxf
ps -ef --forest

# 查看网络连接
netstat -tulpn
netstat -anp

# 查看定时任务
crontab -l
cat /etc/crontab
ls -la /etc/cron.d/
```

**Step 3: 收集证据**
```bash
# 保存日志
cp /var/log/auth.log /tmp/auth.log.backup
cp /var/log/syslog /tmp/syslog.backup

# 保存进程列表
ps aux > /tmp/ps.backup
netstat -anp > /tmp/netstat.backup

# 保存用户列表
cat /etc/passwd > /tmp/passwd.backup
cat /etc/shadow > /tmp/shadow.backup
```

**Step 4: 恢复**
```bash
# 方案A：重装系统（推荐）
# 如果是生产环境，重装是最安全的方式

# 方案B：清除恶意文件
# 停止可疑进程
kill -9 <pid>

# 删除恶意文件
rm -f /tmp/malware
rm -f /usr/bin/malware

# 修改所有密码
passwd root
passwd user
```

---

## ❓ 常见问题

### Q: 更改SSH端口后连接失败？

**A**: 检查步骤：
1. 确认防火墙开放了新端口
2. 确认SELinux/AppArmor允许新端口
3. 确认sshd配置语法正确：`sshd -t`
4. 重启sshd服务：`systemctl restart sshd`
5. 检查云服务商安全组设置

### Q: BBR开启失败？

**A**: 可能原因：
1. 内核版本低于4.9，需要升级内核
2. 模块未加载：运行 `modprobe tcp_bbr`
3. 不支持：BBR需要KVM/Xen等虚拟化支持，OpenVZ可能不支持

### Q: 防火墙设置后无法连接？

**A**: 急救方案：
1. 通过VNC/控制台连接（不经过防火墙）
2. 清空防火墙规则：`iptables -F`
3. 或者重启服务器（如果之前的规则未保存）

### Q: Fail2Ban不生效？

**A**: 排查步骤：
1. 检查日志路径是否正确
2. 确认Fail2Ban服务运行：`systemctl status fail2ban`
3. 检查监狱配置：`fail2ban-client status`
4. 查看详细日志：`tail -f /var/log/fail2ban.log`

### Q: 如何验证服务器安全性？

**A**: 使用以下工具：
1. [Qualys SSL Labs](https://www.ssllabs.com/ssltest/) - SSL测试
2. [Shodan](https://www.shodan.io/) - 检查暴露的端口
3. [VirusTotal](https://www.virustotal.com/) - 文件检测
4. 本地工具：`lynis audit system`

---

## 📚 学习资源

### 官方文档
- [SSH安全配置](https://www.ssh.com/ssh/sshd_config/)
- [iptables教程](https://www.netfilter.org/documentation/)
- [Fail2Ban文档](https://www.fail2ban.org/)

### 推荐工具
- [VPSVIP](https://vpsvip.net) - 优质VPS推荐
- [nav.clashvip.net](https://nav.clashvip.net) - 网络工具导航

### 社区论坛
- [ServerFault](https://serverfault.com/)
- [Unix Stack Exchange](https://unix.stackexchange.com/)

---

## 🔄 更新日志

### v2.0 (2026-08-09)
- ✅ 新增完整的安全加固文档
- ✅ 增加SSH加固详解
- ✅ 新增防火墙配置详解
- ✅ 新增BBR加速详解
- ✅ 新增入侵检测功能
- ✅ 增加安全检查清单
- ✅ 增加应急响应指南
- ✅ 保留所有原有推广链接

### v1.0 (2026-03-27)
- 初始版本发布

---

## ⚠️ 免责声明

使用本工具箱即表示您同意：
- 仅在您拥有或授权的服务器上使用
- 对操作后果自行负责
- 遵守当地法律法规

---

## 📞 技术支持

- **VPS推荐**: [VPSVIP](https://vpsvip.net)
- **问题反馈**: [GitHub Issues](https://github.com/clashforwindows-net/vps-security-20260327/issues)

---

**最后更新**: 2026-08-09  
**版本**: v2.0  
**Stars**: 0  
**Forks**: 0
