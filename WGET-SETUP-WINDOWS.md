# Windows wget 配置指南

## 方案对比

| 方案 | 难度 | 推荐度 | 适用场景 |
|------|------|--------|---------|
| 下载便携版（推荐） | ⭐ 简单 | ⭐⭐⭐⭐⭐ | 内网独立部署 |
| 包管理器安装 | ⭐⭐ 一般 | ⭐⭐⭐⭐ | 已安装包管理器 |
| 环境变量配置 | ⭐⭐ 一般 | ⭐⭐⭐ | 已有 wget 安装 |
| Git Bash 内置 | ⭐⭐⭐ 复杂 | ⭐⭐ | 临时测试 |

---

## ✅ 推荐方案：下载便携版 wget.exe

### 步骤 1: 下载 wget.exe

访问以下链接之一：

- **官方推荐**（维护活跃）
  - 下载地址: https://eternallybored.org/misc/wget/
  - 选择最新版本，例如 `wget-1.21.4-win64.zip`

- **备用源**（如上面链接失效）
  - GitHub: https://github.com/rg3/wget/releases
  - SourceForge: https://sourceforge.net/projects/gnuwin32/files/wget/

### 步骤 2: 解压文件

1. 下载 `wget-1.21.4-win64.zip` 后右键解压
2. 找到 `wget.exe` 文件

### 步骤 3: 放置到项目目录

将 `wget.exe` 放在项目的 `bin/` 文件夹：

```
website-downloader/
├── bin/
│   ├── www
│   └── wget.exe  ← 放在这里
├── public/
├── routes/
├── ...
```

### 步骤 4: 验证

打开命令提示符或 PowerShell，进入项目目录：

```powershell
# 验证 wget.exe 可用
.\bin\wget.exe --version

# 输出示例
GNU Wget 1.21.4 built on win64.
```

---

## 备选方案 1: Scoop 包管理器（推荐）

如果你经常管理多个工具，推荐使用 Scoop。

### 安装 Scoop

```powershell
# 以管理员身份打开 PowerShell 并运行
iwr -useb get.scoop.sh | iex
```

### 安装 wget

```powershell
scoop install wget
```

### 验证

```powershell
wget --version
```

### 自动配置

应用会自动检测系统 PATH 中的 wget，无需额外配置。

---

## 备选方案 2: Chocolatey 包管理器

### 安装 Chocolatey

以管理员身份打开 PowerShell 并运行：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### 安装 wget

```powershell
choco install wget -y
```

### 验证

```powershell
wget --version
```

---

## 备选方案 3: 手动设置环境变量

如果你已经在其他地方安装了 wget（如 Git Bash），可以通过环境变量指向它。

### 找到 wget.exe 位置

```powershell
# 如果通过 Scoop 安装
scoop which wget

# 如果通过 Chocolatey 安装
choco find wget

# Git Bash 内置位置
C:\Program Files\Git\usr\bin\wget.exe
```

### 设置环境变量

#### 方法 A: 临时设置（仅当前 PowerShell）

```powershell
$env:WGET_PATH = "C:\full\path\to\wget.exe"
npm start
```

#### 方法 B: 临时设置（仅当前 CMD）

```batch
set WGET_PATH=C:\full\path\to\wget.exe
npm start
```

#### 方法 C: 永久设置（系统级）

1. 按 `Win + X`，选择"系统"
2. 点击"高级系统设置"
3. 点击"环境变量"按钮
4. 在"系统变量"下点击"新建"
5. 变量名：`WGET_PATH`
6. 变量值：`C:\path\to\wget.exe`（你的 wget.exe 完整路径）
7. 点击"确定"
8. 重启应用或 PowerShell

#### 方法 D: 添加到 PATH（推荐）

这样任何应用都能找到 wget：

1. 按 `Win + X`，选择"系统"
2. 点击"高级系统设置"
3. 点击"环境变量"按钮
4. 在"系统变量"下选择 `Path`，点击"编辑"
5. 点击"新建"，输入 wget.exe 所在目录：`C:\path\to\wget\directory`
6. 点击"确定"保存
7. 重启应用或 PowerShell

### 部署脚本自动处理

如果你用 `deploy.bat` 部署，脚本会自动：
1. 检查 `bin/wget.exe` 是否存在
2. 检查系统 PATH 中是否有 wget
3. 如果都没找到，提示你配置方案

---

## 备选方案 4: Git Bash 内置 wget

如果你已安装 Git for Windows，可以使用内置的 wget：

### 设置环境变量指向 Git Bash wget

```powershell
# 找到 Git Bash 中的 wget
$env:WGET_PATH = "C:\Program Files\Git\usr\bin\wget.exe"
npm start
```

或在 `.env.local` 中配置：

```
WGET_PATH=C:\Program Files\Git\usr\bin\wget.exe
```

---

## 故障排除

### 问题 1: "wget is not recognized"

**解决方案**：
- ✓ 检查 `bin/wget.exe` 是否存在
- ✓ 检查 `WGET_PATH` 环境变量是否正确设置
- ✓ 重启 PowerShell/CMD 使环境变量生效
- ✓ 运行 `echo %WGET_PATH%` (CMD) 或 `$env:WGET_PATH` (PowerShell) 验证

### 问题 2: "permission denied" 或"access denied"

**解决方案**：
- ✓ 右键项目文件夹，选择"属性" > "安全" > "编辑"
- ✓ 选择你的用户，勾选"完全控制"
- ✓ 或以管理员身份运行 PowerShell/CMD

### 问题 3: wget 下载太慢

**解决方案**：
- ✓ 检查网络连接
- ✓ 在内网环境中，可能需要配置代理：
  ```bash
  npm config set proxy http://proxy.internal:8080
  npm config set https-proxy http://proxy.internal:8080
  ```

### 问题 4: 下载后的文件为 0 字节

**解决方案**：
- ✓ 确认 wget.exe 是 64 位版本（如果系统是 64 位）
- ✓ 检查磁盘空间是否充足
- ✓ 验证网络连接

---

## 快速验证清单

```powershell
# 1. 验证 Node.js
node --version

# 2. 验证 wget（三选一）
.\bin\wget.exe --version      # 本地 wget
wget --version                # 系统 wget
$env:WGET_PATH                # 环境变量 wget

# 3. 验证项目依赖
npm list

# 4. 启动应用
npm start

# 5. 访问服务
# 打开浏览器访问: http://localhost:6868
```

---

## 内网部署最佳实践

### 离线包准备

对于完全离线的内网环境：

```powershell
# 在有网络的机器上：
npm install --production

# 复制整个项目到内网机器，包括 node_modules/
# 或使用内部 npm 仓库
```

### 反向代理

内网一般部署在单个服务器，可使用反向代理统一入口：

**IIS 配置反向代理**：
- 安装 "URL Rewrite" 和 "Application Request Routing" 模块
- 配置规则指向 `http://localhost:6868`

**Nginx for Windows**：
- 下载 Windows 版本：http://nginx.org/en/download.html
- 配置参考本项目 `INTRANET-DEPLOY.md`

---

## 常见问题

**Q: 如何知道 wget.exe 下载的是否是正确的版本？**

A: 运行 `wget.exe --version` 应该显示版本信息和 `built on win64` 或 `built on win32` 字样。

**Q: 能否在 cmd.exe 和 PowerShell 之间切换？**

A: 可以，wget 支持所有 Windows 终端。部署脚本 `deploy.bat` 适用于 cmd.exe，手动启动 `npm start` 两者都可用。

**Q: 内网更新 wget 需要重启应用吗？**

A: 需要。重启应用后会使用新的 wget.exe。

**Q: 是否支持 wget 的其他参数配置？**

A: 暂不支持 UI 级别配置，但可以修改 `wget/index.js` 中的 args 数组添加更多参数。

---

需要帮助？请参考主项目 `DEPLOY.md` 和 `README.md` 文件。
