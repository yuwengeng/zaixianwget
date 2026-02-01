/**
 * 改造要点：
 * - 接收临时目录完整路径和用于生成 ZIP 的安全文件名
 * - 确保 ./public/sites 存在
 * - 完成后通知前端并（可���）删除临时目录或保留（这里默认保留）
 */
const archiverLib = require('archiver');
const fs = require('fs');
const path = require('path');

function sanitizeName(name) {
  // 保留字母数字、下划线、横线；其他替换为 '-'
  return name.replace(/[^a-zA-Z0-9-_\.]/g, '-').substring(0, 200) || 'site';
}

module.exports = (dirPath, suggestedName, io, data) => {
  if (!fs.existsSync(dirPath)) {
    io.emit(data.token, { error: 'Directory to archive does not exist' });
    return;
  }

  const name = sanitizeName(suggestedName || path.basename(dirPath) || data.token || 'site');
  const outDir = path.join(__dirname, '..', 'public', 'sites');
  fs.mkdirSync(outDir, { recursive: true });

  const outputPath = path.join(outDir, name + '.zip');

  const output = fs.createWriteStream(outputPath);
  const archive = archiverLib('zip', { zlib: { level: 9 } });

  output.on('close', function () {
    console.log(archive.pointer() + ' total bytes');
    console.log('archiver has been finalized and the output file descriptor has closed.');
    io.emit(data.token, { progress: 'Completed', file: name });
    // 可选：删除 dirPath 临时目录以释放空间
    // fs.rmSync(dirPath, { recursive: true, force: true });
  });

  output.on('end', function () {
    console.log('Data has been drained');
  });

  archive.on('warning', function (err) {
    if (err.code === 'ENOENT') {
      console.warn('Archiver warning', err);
    } else {
      throw err;
    }
  });

  archive.on('error', function (err) {
    throw err;
  });

  archive.pipe(output);
  // 将临时目录内容加入 zip（不包含外层目录）
  archive.directory(dirPath, false);
  archive.finalize();
};