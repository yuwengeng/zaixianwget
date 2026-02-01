#!/bin/bash

# 项目验证脚本

echo "================================"
echo "Website Downloader 改造验证"
echo "================================"
echo ""

# 1. 检查 Node.js
echo "1. 检查 Node.js..."
if command -v node &> /dev/null; then
    echo "   ✓ Node.js: $(node -v)"
else
    echo "   ✗ Node.js 未找到"
fi
echo ""

# 2. 检查 npm
echo "2. 检查 npm..."
if command -v npm &> /dev/null; then
    echo "   ✓ npm: $(npm -v)"
else
    echo "   ✗ npm 未找到"
fi
echo ""

# 3. 检查 wget
echo "3. 检查 wget..."
if command -v wget &> /dev/null; then
    echo "   ✓ wget 已安装"
    echo "     $(wget --version | head -1)"
else
    echo "   ⚠ wget 未在 PATH 中找到"
    echo "     (Windows 可通过 WGET_PATH 配置)"
fi
echo ""

# 4. 检查必要的文件
echo "4. 检查项目文件..."
files=(
    "config.js"
    "deploy.sh"
    "deploy.bat"
    ".env.example"
    "Dockerfile"
    "docker-compose.yml"
    "DEPLOY.md"
    "WGET-SETUP-WINDOWS.md"
    "INTRANET-DEPLOY.md"
    "QUICK-REFERENCE.md"
    "MODIFICATION-SUMMARY.md"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✓ $file"
    else
        echo "   ✗ $file 未找到"
    fi
done
echo ""

# 5. 检查 npm 依赖
echo "5. 检查 npm 依赖..."
if [ -d "node_modules" ]; then
    count=$(ls -1 node_modules | wc -l)
    echo "   ✓ node_modules 已安装 ($count 个包)"
else
    echo "   ⚠ node_modules 未安装，请运行 npm install"
fi
echo ""

# 6. 检查 config.js
echo "6. 验证 config.js..."
if grep -q "module.exports" config.js; then
    echo "   ✓ config.js 配置正确"
    ports=$(grep "port:" config.js | head -1)
    echo "     默认端口: $ports"
else
    echo "   ✗ config.js 配置错误"
fi
echo ""

# 7. 检查 wget 模块
echo "7. 验证 wget 模块..."
if grep -q "findWget" wget/index.js; then
    echo "   ✓ wget 模块已更新（支持 Windows）"
else
    echo "   ⚠ wget 模块可能未正确更新"
fi
echo ""

# 8. 检查部署脚本权限
echo "8. 检查部署脚本..."
if [ -f "deploy.sh" ]; then
    if [ -x "deploy.sh" ]; then
        echo "   ✓ deploy.sh 权限正确"
    else
        echo "   ⚠ deploy.sh 权限需要修复，运行: chmod +x deploy.sh"
    fi
fi
if [ -f "deploy.bat" ]; then
    echo "   ✓ deploy.bat 已就绪"
fi
echo ""

echo "================================"
echo "✓ 验证完成！"
echo "================================"
echo ""
echo "快速开始："
echo "1. Linux/macOS:  chmod +x deploy.sh && ./deploy.sh"
echo "2. Windows:      deploy.bat"
echo "3. Docker:       docker-compose up -d"
echo ""
echo "更多信息请查看: DEPLOY.md"
