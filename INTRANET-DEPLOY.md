# 内网部署配置示例

## Linux/macOS 内网部署

### .env.local 配置文件
```
PORT=6868
DOWNLOAD_TIMEOUT=30
NODE_ENV=production
LOG_LEVEL=info
OUTPUT_DIR=/data/downloads
TMP_DIR=/var/tmp/website-downloader
```

## Windows 内网部署

### .env.local 配置文件
```
PORT=6868
DOWNLOAD_TIMEOUT=30
NODE_ENV=production
WGET_PATH=C:\tools\wget.exe
OUTPUT_DIR=D:\downloads
TMP_DIR=C:\temp\website-downloader
```

## Docker Compose 内网部署

### docker-compose.yml
```yaml
version: '3.8'

services:
  website-downloader:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "6868:6868"
    environment:
      - PORT=6868
      - DOWNLOAD_TIMEOUT=30
      - NODE_ENV=production
      - LOG_LEVEL=info
    volumes:
      - ./public/sites:/app/public/sites
      - ./tmp:/app/tmp
    restart: always
    networks:
      - intranet

networks:
  intranet:
    driver: bridge
```

运行:
```bash
docker-compose up -d
```

## Kubernetes 部署

### deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: website-downloader
  labels:
    app: website-downloader
spec:
  replicas: 1
  selector:
    matchLabels:
      app: website-downloader
  template:
    metadata:
      labels:
        app: website-downloader
    spec:
      containers:
      - name: website-downloader
        image: website-downloader:latest
        ports:
        - containerPort: 6868
        env:
        - name: PORT
          value: "6868"
        - name: DOWNLOAD_TIMEOUT
          value: "30"
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        volumeMounts:
        - name: downloads
          mountPath: /app/public/sites
        - name: tmp
          mountPath: /app/tmp
      volumes:
      - name: downloads
        persistentVolumeClaim:
          claimName: downloads-pvc
      - name: tmp
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: website-downloader
spec:
  selector:
    app: website-downloader
  ports:
  - protocol: TCP
    port: 80
    targetPort: 6868
  type: LoadBalancer
```

## Nginx 反向代理配置

### /etc/nginx/sites-available/website-downloader

```nginx
upstream website_downloader {
    server localhost:6868;
}

server {
    listen 80;
    server_name downloader.internal.local downloader;

    # 可选: SSL 配置
    # listen 443 ssl http2;
    # ssl_certificate /path/to/cert.pem;
    # ssl_certificate_key /path/to/key.pem;

    # 日志
    access_log /var/log/nginx/website-downloader-access.log;
    error_log /var/log/nginx/website-downloader-error.log;

    # 上传大小限制
    client_max_body_size 10M;

    location / {
        proxy_pass http://website_downloader;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;

        # WebSocket 支持
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }

    # 缓存静态资源
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        proxy_pass http://website_downloader;
        proxy_cache_valid 200 1h;
        expires 1h;
        add_header Cache-Control "public, max-age=3600";
    }
}
```

启用配置:
```bash
ln -s /etc/nginx/sites-available/website-downloader /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

## Apache 反向代理配置

### /etc/apache2/sites-available/website-downloader.conf

```apache
<VirtualHost *:80>
    ServerName downloader.internal.local
    ServerAlias downloader

    ErrorLog ${APACHE_LOG_DIR}/website-downloader-error.log
    CustomLog ${APACHE_LOG_DIR}/website-downloader-access.log combined

    <IfModule mod_proxy.c>
        ProxyPreserveHost On
        ProxyPass / http://localhost:6868/
        ProxyPassReverse / http://localhost:6868/

        # WebSocket 支持
        ProxyPass /socket.io/ ws://localhost:6868/socket.io/
        ProxyPassReverse /socket.io/ ws://localhost:6868/socket.io/
    </IfModule>

    <IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteCond %{HTTP:Upgrade} websocket [NC]
        RewriteCond %{HTTP:Connection} upgrade [NC]
        RewriteRule ^/?(.*) "ws://localhost:6868/$1" [P,L]
    </IfModule>
</VirtualHost>
```

启用配置:
```bash
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_wstunnel
a2enmod rewrite
a2ensite website-downloader
apache2ctl configtest
systemctl restart apache2
```

## 监控和日志

### PM2 生态配置 (ecosystem.config.js)

```javascript
module.exports = {
  apps: [
    {
      name: 'website-downloader',
      script: './bin/www',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 6868,
        DOWNLOAD_TIMEOUT: 30
      },
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      watch: false,
      ignore_watch: ['node_modules', 'tmp', 'public/sites'],
      max_memory_restart: '500M',
      restart_delay: 4000,
      listen_timeout: 5000,
      kill_timeout: 5000
    }
  ],
  deploy: {
    production: {
      user: 'node',
      host: '192.168.1.100',
      ref: 'origin/main',
      repo: 'git@github.com:user/website-downloader.git',
      path: '/home/node/website-downloader',
      'post-deploy': 'npm install && pm2 restart ecosystem.config.js --env production'
    }
  }
};
```

启动:
```bash
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup
```

---

根据你的网络环境选择相应的配置方案。
