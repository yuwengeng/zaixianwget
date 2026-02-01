#!/bin/bash

# Website Downloader - 快速部署脚本（Linux/macOS）
# 用法: chmod +x deploy.sh && ./deploy.sh

set -e

echo "================================"
echo "Website Downloader 快速部署"
echo "================================"
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未找到 Node.js，请先安装 Node.js 12+"
    exit 1
fi

echo "✓ Node.js 版本: $(node -v)"
echo "✓ npm 版本: $(npm -v)"
echo ""

# 检查 wget
if ! command -v wget &> /dev/null; then
    echo "⚠ 警告: 未找到 wget 命令"
    echo "  请运行: sudo apt-get install wget  (Debian/Ubuntu)"
    echo "         或 brew install wget         (macOS)"
    read -p "是否继续? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✓ wget 版本: $(wget --version | head -n1)"
echo ""

# 安装依赖
echo "📦 安装项目依赖..."
npm install
echo "✓ 依赖安装完成"
echo ""

# 创建必要的目录
mkdir -p tmp public/sites

# 获取配置
read -p "请输入服务器端口 (默认: 6868): " PORT
PORT=${PORT:-6868}

read -p "请输入下载超时时间(分钟, 默认: 20): " TIMEOUT
TIMEOUT=${TIMEOUT:-20}

# 保存配置到 .env 文件
cat > .env.local << EOF
PORT=$PORT
DOWNLOAD_TIMEOUT=$TIMEOUT
NODE_ENV=production
EOF

echo "✓ 配置已保存到 .env.local"
echo ""

echo "================================"
echo "✓ 部署完成！"
echo "================================"
echo ""
echo "启动应用: npm start"
echo "开发模式: npm run dev"
echo ""
echo "服务地址: http://localhost:$PORT"
echo ""
