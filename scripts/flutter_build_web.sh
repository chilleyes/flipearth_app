#!/usr/bin/env bash
# Flutter web 构建脚本：避免启动锁与网络卡住
# 用法: ./scripts/flutter_build_web.sh  或  bash scripts/flutter_build_web.sh

set -e
cd "$(dirname "$0")/.."

echo ">>> 结束可能占用锁的 dart 进程..."
killall -9 dart 2>/dev/null || true

FLUTTER_ROOT="${FLUTTER_ROOT:-$(dirname "$(dirname "$(which flutter)")")}"
LOCKFILE="$FLUTTER_ROOT/bin/cache/lockfile"
if [ -f "$LOCKFILE" ]; then
  echo ">>> 删除 Flutter 锁文件: $LOCKFILE"
  rm -f "$LOCKFILE"
fi

# 跳过版本检查与统计，减少联网卡住
export FLUTTER_SUPPRESS_ANALYTICS=true
echo ">>> 执行 flutter build web（--no-version-check）..."
flutter build web --no-version-check --suppress-analytics "$@"

echo ">>> 构建完成"
