/**
 * 改造要点：
 * - 使用 spawn 而不是 exec
 * - 校验 URL（必须以 http:// 或 https:// 开头）
 * - 将 wget 输出到临时目录（./tmp/site-xxxx）
 * - 增加超时（可配置），并在异常时通知前端
 */
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const { URL } = require('url');
const os = require('os');
const archiver = require('../archiver');
const config = require('../config');

/**
 * 查找 wget 可执行文件
 */
function findWget() {
  const isWindows = os.platform() === 'win32';
  
  // 1. 检查项目本地的 wget（Windows 可选）
  if (isWindows) {
    const localWget = path.join(__dirname, '..', 'bin', 'wget.exe');
    if (fs.existsSync(localWget)) {
      return localWget;
    }
  }
  
  // 2. 检查环境变量自定义 WGET_PATH
  if (process.env.WGET_PATH && fs.existsSync(process.env.WGET_PATH)) {
    return process.env.WGET_PATH;
  }
  
  // 3. 使用系统 wget 命令
  return 'wget';
}

module.exports = (io, data) => {
  const website = (data && data.website) ? data.website.trim() : '';

  // 基本校验
  if (!website || !(website.startsWith('http://') || website.startsWith('https://'))) {
    io.emit(data.token, { error: 'Invalid URL. Must start with http:// or https://' });
    return;
  }
  try {
    new URL(website);
  } catch (err) {
    io.emit(data.token, { error: 'Malformed URL' });
    return;
  }

  // 创建临时工作目录： ./tmp/site-<random>
  const tmpBase = path.join(__dirname, '..', 'tmp');
  fs.mkdirSync(tmpBase, { recursive: true });
  const workDir = fs.mkdtempSync(path.join(tmpBase, 'site-'));

  // wget 参数（把输出放到 workDir）
  const args = ['-mkEpnp', '--no-if-modified-since', `--directory-prefix=${workDir}`, website];
  const wgetCmd = findWget();

  let killedByTimeout = false;
  let domain = '';

  try {
    const child = spawn(wgetCmd, args);

    // 超时处理（从配置读取，默认 20 分钟）
    const TIMEOUT_MS = (config.downloadTimeout || 20) * 60 * 1000;
    const killTimer = setTimeout(() => {
      killedByTimeout = true;
      try { child.kill('SIGKILL'); } catch (e) {}
      io.emit(data.token, { error: 'Task timed out and was terminated' });
    }, TIMEOUT_MS);

    child.stderr.on('data', (chunk) => {
      const response = chunk.toString();
      // 监听 wget 的解���信息提取域名（尽量与原逻辑保持一致）
      if (response.startsWith('Resolving ') || response.includes('Resolving ')) {
        const m = response.match(/Resolving\s+([^\s(]+)/i);
        if (m && m[1]) domain = m[1];
      }
      io.emit(data.token, { progress: response });
    });

    child.stdout.on('data', (chunk) => {
      io.emit(data.token, { progress: chunk.toString() });
    });

    child.on('error', (err) => {
      clearTimeout(killTimer);
      io.emit(data.token, { 
        error: 'Failed to start wget: ' + err.message + 
               '\n\nHint: For Windows, ensure wget.exe is in PATH or set WGET_PATH environment variable.' 
      });
    });

    child.on('close', (code, signal) => {
      clearTimeout(killTimer);
      if (killedByTimeout) return;
      if (code !== 0) {
        io.emit(data.token, { error: 'wget exited with code ' + code });
        return;
      }
      io.emit(data.token, { progress: 'Converting' });
      const nameForZip = domain || data.token || path.basename(workDir);
      archiver(workDir, nameForZip, io, data);
    });

  } catch (e) {
    io.emit(data.token, { error: 'Internal server error: ' + e.message });
  }
};