FROM node:18-alpine

# 安装 wget
RUN apk add --no-cache wget ca-certificates

WORKDIR /app

# 复制 package 文件
COPY package*.json ./

# 安装依赖
RUN npm install --omit=dev

# 复制应用文件
COPY . .

# 创建必要的目录
RUN mkdir -p tmp public/sites && \
    chmod +x bin/www

# 暴露端口
EXPOSE 6868

# 环境变量
ENV NODE_ENV=production \
    PORT=6868 \
    DOWNLOAD_TIMEOUT=20 \
    LOG_LEVEL=info

# 启动应用
CMD ["npm", "start"]
