## 在线wegt扒站 💾

下载任何网站的完整源代码（包括所有资源）🔨，支持**跨平台部署**，**Windows 集成 wget**，**内网快速部署**。

👉 在线演示: https://bazhan.net/

![enter image description here](https://github.com/AhmadIbrahiim/Website-downloader/blob/master/public/Record.gif?raw=true)

---

## ✨ 核心特性

- ✅ **跨平台支持** - Windows、Linux、macOS
- ✅ **Windows 集成 wget** - 自动检测或通过环境变量配置
- ✅ **内网快速部署** - 一键部署脚本（Windows & Linux）
- ✅ **灵活配置** - 环境变量支持，无需修改代码
- ✅ **实时进度反馈** - Socket.io 实时通信
- ✅ **自动压缩打包** - ZIP 格式存档
- ✅ **超时管理** - 可配置下载超时时间
- ✅ **多部署方案** - Docker、Kubernetes、Systemd、PM2 等

---

## 📋 前置要求

- **Node.js**: 12.0 或更高版本 ([下载](https://nodejs.org/))
- **wget**: 网站下载工具
  - Linux/macOS: 通常已预装
  - Windows: 需要配置（见下文）

---

## 🚀 快速开始

### Linux/macOS

```bash
# 1. 克隆项目
git clone https://github.com/hudsonsir/zaixianwget.git
cd zaixianwget

# 2. 运行自动部署脚本
chmod +x deploy.sh
./deploy.sh

# 3. 启动应用
npm start

# 访问: http://localhost:6868
```

### Windows

#### 方案 A: 自动部署（推荐）

1. 下载 wget.exe：https://eternallybored.org/misc/wget/
2. 解压并放入项目 `bin/` 文件夹（命名为 `wget.exe`）
3. 在项目目录运行：
   ```batch
   deploy.bat
   ```
4. 根据提示配置端口和超时时间
5. 选择是否立即启动

#### 方案 B: 手动部署

```batch
# 1. 安装依赖
npm install

# 2. 创建必要目录
mkdir tmp
mkdir public\sites

# 3. 启动应用
npm start

# 访问: http://localhost:6868
```

---

## 📚 完整部署文档

| 文档 | 说明 |
|------|------|
| [DEPLOY.md](./DEPLOY.md) | 📖 完整部署指南（所有平台） |
| [INTRANET-DEPLOY.md](./INTRANET-DEPLOY.md) | 🏢 内网部署方案（Docker、K8s、Nginx等） |
| [WGET-SETUP-WINDOWS.md](./WGET-SETUP-WINDOWS.md) | 🪟 Windows wget 配置指南 |
| [.env.example](./.env.example) | ⚙️ 配置模板 |

---

## 🔧 环境变量配置

创建 `.env.local` 文件来自定义配置：

```bash
# 服务器端口 (默认: 6868)
PORT=6868

# 下载超时时间，分钟 (默认: 20)
DOWNLOAD_TIMEOUT=30

# 运行环境 (默认: production)
NODE_ENV=production

# Windows 的 wget 路径 (可选)
WGET_PATH=C:\tools\wget.exe

# 日志级别 (默认: info)
LOG_LEVEL=info
```

或通过命令行临时设置：

```bash
# Linux/macOS
PORT=8080 DOWNLOAD_TIMEOUT=30 npm start

# Windows PowerShell
$env:PORT = "8080"
$env:DOWNLOAD_TIMEOUT = "30"
npm start
```

---

## 🏢 内网部署

### Docker 部署

```bash
docker build -t website-downloader .
docker run -p 6868:6868 -e PORT=6868 website-downloader
```

### Systemd 自启动（Linux）

```bash
sudo cp website-downloader.service /etc/systemd/system/
sudo systemctl enable website-downloader
sudo systemctl start website-downloader
```

### PM2 进程管理

```bash
npm install -g pm2
pm2 start npm --name "website-downloader" -- start
pm2 save && pm2 startup
```

### Nginx 反向代理

```nginx
location / {
    proxy_pass http://localhost:6868;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

详见 [INTRANET-DEPLOY.md](./INTRANET-DEPLOY.md)

---

## 📝 使用说明

1. **输入网站 URL** - 在输入框中输入要下载的网站地址
2. **点击"下载"** - 开始下载过程
3. **实时进度** - 在页面上查看下载进度
4. **下载结果** - 完成后自动生成 ZIP 文件供下载

### wget 参数说明

默认使用以下 wget 参数：

```bash
wget -mkEpnp --no-if-modified-since --directory-prefix={workDir} {url}
```

| 参数 | 说明 |
|------|------|
| `-m` | 递归下载（镜像模式） |
| `-k` | 转换链接为相对链接（离线查看） |
| `-E` | 根据内容类型调整扩展名 |
| `-p` | 下载页面所需的所有资源（CSS、图片等） |
| `-np` | 不上升到父目录 |
| `--no-if-modified-since` | 忽略时间戳 |

---

## 🐛 故障排除

### Windows wget 错误

```
Failed to start wget: spawn ENOENT
```

**解决方案**：
- ✓ 下载 wget.exe 放在 `bin/` 目录
- ✓ 或设置 `WGET_PATH` 环境变量
- ✓ 或将 wget 加入系统 PATH

详见 [WGET-SETUP-WINDOWS.md](./WGET-SETUP-WINDOWS.md)

### 端口被占用

```
Error: listen EADDRINUSE :::6868
```

**解决方案**：

```bash
# 更改端口
PORT=8080 npm start

# 或杀死占用的进程
lsof -i :6868 | grep LISTEN | awk '{print $2}' | xargs kill -9
```

### 超时错误

```
Task timed out and was terminated
```

**解决方案**：增加超时时间

```bash
DOWNLOAD_TIMEOUT=60 npm start
```

---

## 📊 项目结构

```
zaixianwget/
├── bin/                      # 应用启动脚本
│   ├── www                   # Node.js 入口
│   └── wget.exe             # Windows wget (可选)
├── public/                   # 静态资源
│   ├── sitemap.xml
│   ├── robots.txt
│   ├── stylesheets/
│   └── sites/               # 下载的 ZIP 输出目录
├── routes/                   # Express 路由
│   ├── index.js
│   └── users.js
├── views/                    # 视图模板（Handlebars）
│   ├── index.hbs
│   ├── error.hbs
│   └── layout.hbs
├── socket/                   # WebSocket 处理
│   └── socket.js
├── wget/                     # wget 下载模块（Windows 兼容）
│   └── index.js
├── archiver/                 # ZIP 压缩模块
│   └── index.js
├── tmp/                      # 临时文件目录（自动创建）
├── config.js                 # 配置管理
├── app.js                    # Express 应用
├── package.json
├── deploy.sh                 # Linux/macOS 部署脚本
├── deploy.bat                # Windows 部署脚本
├── DEPLOY.md                 # 完整部署文档
├── INTRANET-DEPLOY.md        # 内网部署方案
├── WGET-SETUP-WINDOWS.md     # Windows wget 设置
└── README.md                 # 本文件
```

---

## 🔐 安全建议

- ✓ 在生产环境使用 HTTPS（通过反向代理）
- ✓ 限制下载文件大小：`MAX_DOWNLOAD_SIZE=5000`
- ✓ 设置合理的超时时间：`DOWNLOAD_TIMEOUT=30`
- ✓ 定期清理临时文件：`AUTO_CLEAN_TMP=true`
- ✓ 使用内网 npm 镜像加速部署
- ✓ 配置防火墙限制访问

---

## 📦 依赖项

| 包 | 说明 |
|----|------|
| express | Web 框架 |
| socket.io | 实时通信 |
| wget | 网站下载（系统级） |
| archiver | ZIP 压缩 |
| morgan | HTTP 日志 |
| hbs | 模板引擎 |

---

## 🤝 贡献

欢迎提交 Pull Request 或报告 Issue！

---

## 📄 许可证

MIT License

---

## 🙏 致谢

原始项目：[Website-downloader](https://github.com/Ahmadibrahiim/Website-downloader)

本项目在此基础上增加了：
- Windows wget 集成
- 跨平台部署脚本
- 灵活的环境变量配置
- 完整的内网部署文档
- Docker 和 Kubernetes 支持

---

## 📞 支持

- 📖 查看 [DEPLOY.md](./DEPLOY.md) 获取详细部署指南
- 🪟 Windows 用户参考 [WGET-SETUP-WINDOWS.md](./WGET-SETUP-WINDOWS.md)
- 🏢 内网部署参考 [INTRANET-DEPLOY.md](./INTRANET-DEPLOY.md)
- ⚙️ 配置参考 [.env.example](./.env.example)
