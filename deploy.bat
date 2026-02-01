@echo off
REM Website Downloader - 快速部署脚本（Windows）
REM 用法: deploy.bat

setlocal enabledelayedexpansion

echo ================================
echo Website Downloader 快速部署
echo ================================
echo.

REM 检查 Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到 Node.js，请先安装 Node.js 12+
    echo 下载地址: https://nodejs.org/
    pause
    exit /b 1
)

echo ✓ Node.js 版本:
node -v
echo ✓ npm 版本:
npm -v
echo.

REM 检查 wget
where wget >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo ⚠ 警告: 未找到 wget 命令
    echo.
    echo 请选择以下方案之一:
    echo 1. 下载 wget.exe 并放在项目 bin 目录: https://eternallybored.org/misc/wget/
    echo 2. 设置环境变量 WGET_PATH 指向 wget.exe 路径
    echo 3. 添加 wget 到系统 PATH
    echo.
    set /p CONTINUE="是否继续? (y/n): "
    if /i not "!CONTINUE!"=="y" (
        exit /b 1
    )
)

REM 安装依赖
echo.
echo 📦 安装项目依赖...
call npm install
if %errorlevel% neq 0 (
    echo ❌ 依赖安装失败
    pause
    exit /b 1
)
echo ✓ 依赖安装完成
echo.

REM 创建必要的目录
if not exist "tmp" mkdir tmp
if not exist "public\sites" mkdir public\sites

REM 获取配置
set /p PORT="请输入服务器端口 (默认: 6868): "
if "!PORT!"=="" set PORT=6868

set /p TIMEOUT="请输入下载超时时间(分钟, 默认: 20): "
if "!TIMEOUT!"=="" set TIMEOUT=20

REM 保存配置到 .env.local 文件
(
    echo PORT=!PORT!
    echo DOWNLOAD_TIMEOUT=!TIMEOUT!
    echo NODE_ENV=production
) > .env.local

echo ✓ 配置已保存到 .env.local
echo.

echo ================================
echo ✓ 部署完成！
echo ================================
echo.
echo 启动应用: npm start
echo 开发模式: npm run dev
echo.
echo 服务地址: http://localhost:!PORT!
echo.

REM 询问是否立即启动
set /p START="是否立即启动应用? (y/n): "
if /i "!START!"=="y" (
    echo.
    echo 正在启动服务...
    timeout /t 2
    npm start
) else (
    echo.
    echo 应用已准备好，执行 npm start 启动
    pause
)
