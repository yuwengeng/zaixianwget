# 快速参考指南

## 常用命令速查

### 启动应用

```bash
# 基础启动
npm start

# 开发模式
npm run dev

# 指定端口启动
PORT=8080 npm start

# 指定超时时间（分钟）
DOWNLOAD_TIMEOUT=30 npm start
```

### Windows 特定命令

```powershell
# PowerShell 设置环境变量
$env:PORT = "8080"
$env:DOWNLOAD_TIMEOUT = "30"
npm start

# 或一行执行
$env:PORT = "8080"; $env:DOWNLOAD_TIMEOUT = "30"; npm start
```

### Docker 命令

```bash
# 构建镜像
docker build -t website-downloader .

# 运行容器
docker run -p 6868:6868 website-downloader

# 使用 docker-compose
docker-compose up -d          # 启动
docker-compose down           # 停止
docker-compose logs -f        # 查看日志
docker-compose restart        # 重启
```

### 进程管理

```bash
# PM2 相关
pm2 start npm --name "wd" -- start     # 启动
pm2 stop wd                            # 停止
pm2 restart wd                         # 重启
pm2 logs wd                            # 查看日志
pm2 delete wd                          # 删除
pm2 save && pm2 startup                # 保存并自启
```

### 端口管理

```bash
# 查看占用的端口（Linux/macOS）
lsof -i :6868

# 杀死进程
kill -9 <PID>

# Windows PowerShell 查看占用端口
Get-NetTCPConnection -LocalPort 6868 | Select-Object OwningProcess

# 杀死进程（Windows）
Stop-Process -Id <PID> -Force
```

### 日志查看

```bash
# 实时日志
npm start                              # 控制台输出

# 保存到文件
npm start > app.log 2>&1

# 后台运行并保存日志
nohup npm start > app.log 2>&1 &

# Windows 后台运行（推荐 PM2）
pm2 start npm --name "wd" -- start
```

---

## 配置速查表

### 主要环境变量

| 变量 | 说明 | 默认值 | 示例 |
|------|------|--------|------|
| `PORT` | 监听端口 | 6868 | 8080 |
| `DOWNLOAD_TIMEOUT` | 超时时间（分钟） | 20 | 30 |
| `NODE_ENV` | 运行环境 | production | development |
| `WGET_PATH` | wget 路径（Windows） | 自动 | C:\tools\wget.exe |
| `LOG_LEVEL` | 日志级别 | info | debug |
| `OUTPUT_DIR` | 输出目录 | ./public/sites | /data/downloads |
| `TMP_DIR` | 临时目录 | ./tmp | /var/tmp/wd |

### 创建 .env.local 示例

```bash
# Linux/macOS
cat > .env.local << EOF
PORT=8080
DOWNLOAD_TIMEOUT=30
NODE_ENV=production
LOG_LEVEL=info
EOF

# Windows (PowerShell)
@"
PORT=8080
DOWNLOAD_TIMEOUT=30
NODE_ENV=production
LOG_LEVEL=info
"@ | Out-File .env.local
```

---

## 部署速查

### Linux 自启动（Systemd）

```bash
# 1. 创建服务文件
sudo nano /etc/systemd/system/website-downloader.service

# 2. 粘贴以下内容
[Unit]
Description=Website Downloader
After=network.target

[Service]
Type=simple
WorkingDirectory=/path/to/project
Environment="NODE_ENV=production"
Environment="PORT=6868"
ExecStart=/usr/bin/npm start
Restart=always

[Install]
WantedBy=multi-user.target

# 3. 启用并启动
sudo systemctl daemon-reload
sudo systemctl enable website-downloader
sudo systemctl start website-downloader

# 4. 查看状态
sudo systemctl status website-downloader
sudo journalctl -u website-downloader -f
```

### Windows 任务计划程序

1. 按 `Win + R`，输入 `taskschd.msc`
2. 右侧点击"创建基本任务"
3. 常规：输入名称（如 "Website Downloader"）
4. 触发器：选择"系统启动时"
5. 操作：选择"启动程序"
   - 程序：`C:\Program Files\nodejs\node.exe`
   - 参数：`"C:\path\to\project\bin\www"`
   - 起始于：`C:\path\to\project`
6. 确定保存

### Nginx 反向代理速配

```nginx
server {
    listen 80;
    server_name downloader.local;

    location / {
        proxy_pass http://localhost:6868;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

---

## 问题快速诊断

### 应用启动失败

```bash
# 1. 检查 Node.js
node --version

# 2. 检查依赖
npm list

# 3. 清除并重装
rm -rf node_modules package-lock.json
npm install

# 4. 指定 Node 内存限制
NODE_OPTIONS="--max-old-space-size=2048" npm start
```

### Windows wget 错误

```powershell
# 1. 验证 wget
wget --version

# 2. 查找 wget 位置
where wget

# 3. 手动配置（如果找不到）
$env:WGET_PATH = "C:\path\to\wget.exe"
npm start
```

### 端口冲突

```bash
# 1. 更改端口
PORT=8080 npm start

# 2. 或查找并杀死占用进程
lsof -i :6868 | awk '{print $2}' | tail -1 | xargs kill -9
```

### 下载超时

```bash
# 1. 增加超时时间
DOWNLOAD_TIMEOUT=60 npm start

# 2. 检查网络连接
ping google.com

# 3. 检查代理配置（如需代理）
npm config list
```

### 内存溢出

```bash
# 1. 增加内存限制
NODE_OPTIONS="--max-old-space-size=4096" npm start

# 2. 清理临时文件
rm -rf tmp/*

# 3. 限制最大下载大小
MAX_DOWNLOAD_SIZE=5000 npm start
```

---

## 性能优化

### 提高下载速度

```bash
# 1. 关闭日志
LOG_LEVEL=error npm start

# 2. 增加 Node.js 堆大小
NODE_OPTIONS="--max-old-space-size=4096" npm start

# 3. 内网镜像配置
npm config set registry http://internal-npm-registry/
```

### 减少资源占用

```bash
# 1. 自动清理临时文件
AUTO_CLEAN_TMP=true npm start

# 2. 限制下载大小
MAX_DOWNLOAD_SIZE=3000 npm start

# 3. 缩短超时时间
DOWNLOAD_TIMEOUT=15 npm start
```

---

## 文件位置速查

| 文件/目录 | 说明 |
|---------|------|
| `./bin/www` | 应用入口 |
| `./bin/wget.exe` | Windows wget (可选) |
| `./config.js` | 配置文件 |
| `./public/sites/` | 输出 ZIP 文件位置 |
| `./tmp/` | 临时下载目录 |
| `./wget/index.js` | wget 模块 |
| `./.env.local` | 用户配置文件 |
| `./DEPLOY.md` | 完整部署指南 |

---

## 更新和维护

### 更新依赖

```bash
# 检查过期包
npm outdated

# 更新所有包
npm update

# 安全审计
npm audit
npm audit fix
```

### 清理缓存

```bash
# npm 缓存
npm cache clean --force

# 项目缓存
rm -rf node_modules
npm install
```

### 备份和恢复

```bash
# 备份配置和下载
tar -czf backup.tar.gz .env.local public/sites/

# 恢复
tar -xzf backup.tar.gz
```

---

## 更多帮助

- 📖 完整文档：`DEPLOY.md`
- 🪟 Windows 专题：`WGET-SETUP-WINDOWS.md`
- 🏢 内网部署：`INTRANET-DEPLOY.md`
- ⚙️ 配置模板：`.env.example`
- 📕 项目自述：`README.md`
