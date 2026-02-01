# Website Downloader - 内网快速部署指南

## 项目概述

这是一个功能强大的在线网站下载器，支持：
- ✅ 跨平台运行（Linux, macOS, Windows）
- ✅ Windows集成wget支持
- ✅ 内网快速部署
- ✅ 实时进度反馈（Socket.io）
- ✅ 自动压缩打包
- ✅ 环境变量配置

---

## 快速开始

### 前置要求

- **Node.js**: 12.0 或更高版本 ([下载](https://nodejs.org/))
- **wget**: 网站下载工具
  - Linux/macOS: 通常已预装，或通过包管理器安装
  - Windows: 需要单独配置

### Linux/macOS 部署

```bash
# 1. 克隆项目
cd /path/to/project

# 2. 运行自动部署脚本
chmod +x deploy.sh
./deploy.sh

# 3. 启动应用
npm start

# 访问: http://localhost:6868
```

### Windows 部署

#### 方案 A: 自动部署脚本（推荐）

```batch
REM 1. 在项目目录右键 -> "在此处打开 PowerShell/CMD"

REM 2. 运行部署脚本
deploy.bat

REM 脚本会自动：
REM - 检查 Node.js 和 wget
REM - 安装项目依赖
REM - 配置端口和超时时间
REM - 可选：立即启动服务
```

#### 方案 B: 手动部署

1. **安装 wget**

   - 方法 1：下载便携版本
     ```
     下载地址: https://eternallybored.org/misc/wget/
     解压后放在项目 bin/ 目录 (bin/wget.exe)
     ```

   - 方法 2：使用包管理器（如 Scoop、Chocolatey）
     ```powershell
     # Scoop
     scoop install wget

     # Chocolatey
     choco install wget
     ```

   - 方法 3：设置环境变量
     ```
     WGET_PATH=C:\path\to\wget.exe
     ```

2. **安装依赖**
   ```bash
   npm install
   ```

3. **启动应用**
   ```bash
   npm start
   ```

---

## 配置详解

项目支持通过环境变量灵活配置，无需修改代码：

### 主要配置选项

| 环境变量 | 说明 | 默认值 | 示例 |
|---------|------|--------|------|
| `PORT` | 服务器端口 | 6868 | `8080` |
| `DOWNLOAD_TIMEOUT` | 下载超时时间（分钟） | 20 | `30` |
| `NODE_ENV` | 运行环境 | production | `development` |
| `WGET_PATH` | wget 可执行文件路径（Windows） | 自动检测 | `C:\tools\wget.exe` |
| `TMP_DIR` | 临时文件夹路径 | ./tmp | `/var/tmp/downloads` |
| `OUTPUT_DIR` | 输出文件夹路径 | ./public/sites | `/data/downloads` |
| `LOG_LEVEL` | 日志级别 | info | `debug`, `warn`, `error` |
| `MAX_DOWNLOAD_SIZE` | 最大下载大小(MB) | 0(无限制) | `5000` |

### 配置使用示例

#### Linux/macOS

```bash
# 方式 1: 命令行指定
PORT=8080 DOWNLOAD_TIMEOUT=30 npm start

# 方式 2: 创建 .env.local 文件
cat > .env.local << EOF
PORT=8080
DOWNLOAD_TIMEOUT=30
NODE_ENV=production
EOF

npm start
```

#### Windows (PowerShell)

```powershell
# 方式 1: 临时设置环境变量
$env:PORT = "8080"
$env:DOWNLOAD_TIMEOUT = "30"
npm start

# 方式 2: 创建 .env.local 文件
@"
PORT=8080
DOWNLOAD_TIMEOUT=30
WGET_PATH=C:\tools\wget.exe
"@ | Out-File .env.local

npm start
```

#### Windows (CMD)

```batch
REM 方式 1: 设置环境变量
set PORT=8080
set DOWNLOAD_TIMEOUT=30
npm start

REM 方式 2: 使用 .env.local 文件（deploy.bat 自动创建）
```

---

## 内网部署最佳实践

### 1. 网络环境

```bash
# 如果内网无法访问外部 npm 源，配置内部镜像
npm config set registry http://internal-npm-registry.local/

# 或在 .npmrc 文件中配置
echo "registry=http://internal-npm-registry.local/" > .npmrc
```

### 2. 防火墙配置

- 确保内网机器能访问 6868 端口（或自定义端口）
- 如需外部访问，配置 HTTP 反向代理（Nginx/Apache）

### 3. 反向代理示例（Nginx）

```nginx
server {
    listen 80;
    server_name downloader.internal.local;

    location / {
        proxy_pass http://localhost:6868;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 4. 自启动配置

#### Linux (Systemd)

创建 `/etc/systemd/system/website-downloader.service`:

```ini
[Unit]
Description=Website Downloader Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/project
Environment="NODE_ENV=production"
Environment="PORT=6868"
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启用并启动：
```bash
sudo systemctl daemon-reload
sudo systemctl enable website-downloader
sudo systemctl start website-downloader
```

#### Windows (Task Scheduler)

1. 打开"任务计划程序"
2. 创建基本任务
3. 触发器：系统启动时
4. 操作：启动程序
   - 程序：`C:\Program Files\nodejs\node.exe`
   - 参数：`.\bin\www`
   - 起始于：项目目录

### 5. 日志管理

```bash
# 使用 PM2 进程管理器（推荐）
npm install -g pm2

# 启动应用
pm2 start npm --name "website-downloader" -- start

# 查看日志
pm2 logs website-downloader

# 保存配置并开机自启
pm2 startup
pm2 save
```

---

## 故障排查

### Windows wget 错误

**错误信息**: `Failed to start wget: spawn ENOENT`

**解决方案**:
1. 验证 wget 路径：
   ```powershell
   where wget
   ```
2. 如果找不到，手动配置：
   ```powershell
   $env:WGET_PATH = "C:\path\to\wget.exe"
   npm start
   ```
3. 或下载便携版 wget.exe 放在 `bin/` 目录

### 端口被占用

**错误信息**: `Error: listen EADDRINUSE :::6868`

**解决方案**:
```bash
# 方式 1: 更改端口
PORT=8080 npm start

# 方式 2: 查找占用端口的进程
# Linux/macOS
lsof -i :6868
kill -9 <PID>

# Windows (PowerShell)
Get-Process -Id (Get-NetTCPConnection -LocalPort 6868).OwningProcess
```

### 内存不足

设置 Node.js 内存限制：
```bash
# Linux/macOS
NODE_OPTIONS="--max-old-space-size=2048" npm start

# Windows (PowerShell)
$env:NODE_OPTIONS = "--max-old-space-size=2048"
npm start
```

---

## 开发模式

```bash
# 启动开发环境（自动热重载）
npm run dev

# 或手动指定环境
NODE_ENV=development npm start
```

---

## Docker 部署（可选）

```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN apk add --no-cache wget && npm install --production

COPY . .

RUN mkdir -p tmp public/sites

ENV PORT=6868
ENV NODE_ENV=production

EXPOSE 6868

CMD ["npm", "start"]
```

构建和运行：
```bash
docker build -t website-downloader .
docker run -p 6868:6868 -e PORT=6868 website-downloader
```

---

## 常见问题

### Q: 支持哪些操作系统？
A: Windows, Linux, macOS

### Q: 下载的文件保存在哪里？
A: 默认保存在 `public/sites/` 目录，可通过 `OUTPUT_DIR` 环境变量修改

### Q: 如何自定义下载超时时间？
A: 设置 `DOWNLOAD_TIMEOUT` 环境变量（单位：分钟）

### Q: 能否限制下载文件大小？
A: 支持，设置 `MAX_DOWNLOAD_SIZE` 环境变量（单位：MB，0为无限制）

### Q: 如何清理临时文件？
A: 手动删除 `tmp` 目录，或设置 `AUTO_CLEAN_TMP=true` 自动清理

---

## 许可证

MIT

---

## 支持

遇到问题？请检查：
1. Node.js 和 wget 是否正确安装
2. 防火墙是否阻止了端口访问
3. 查看应用日志获取更多信息
