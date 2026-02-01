/**
 * 应用配置文件
 * 支持环境变量覆盖，便于内网快速部署
 */

module.exports = {
  // 服务器端口 (环境变量: PORT)
  port: process.env.PORT || 6868,

  // 下载超时时间（分钟，环境变量: DOWNLOAD_TIMEOUT）
  downloadTimeout: parseInt(process.env.DOWNLOAD_TIMEOUT || '20', 10),

  // 是否自动清理临时文件（环境变量: AUTO_CLEAN_TMP）
  autoCleanTemp: process.env.AUTO_CLEAN_TMP === 'true',

  // 临时文件夹路径（环境变量: TMP_DIR）
  tmpDir: process.env.TMP_DIR || './tmp',

  // 输出文件夹路径（环境变量: OUTPUT_DIR）
  outputDir: process.env.OUTPUT_DIR || './public/sites',

  // 日志级别 (环境变量: LOG_LEVEL) - 'error', 'warn', 'info', 'debug'
  logLevel: process.env.LOG_LEVEL || 'info',

  // 环境类型 (环境变量: NODE_ENV)
  env: process.env.NODE_ENV || 'production',

  // wget 自定义路径（环境变量: WGET_PATH，用于 Windows 指定 wget.exe）
  wgetPath: process.env.WGET_PATH || null,

  // 是否允许大文件下载（MB，环境变量: MAX_DOWNLOAD_SIZE，0表示无限制）
  maxDownloadSize: parseInt(process.env.MAX_DOWNLOAD_SIZE || '0', 10),
};
