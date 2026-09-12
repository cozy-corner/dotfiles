#!/bin/bash
# gondolin のゲスト image をビルドして pi-dev:latest として登録する。
# 要件: Docker が起動していること、mke2fs (brew install e2fsprogs)。
set -euo pipefail

cd "$(dirname "$0")"

# Homebrew の e2fsprogs は keg-only なので PATH に足す
if command -v brew >/dev/null 2>&1 && brew --prefix e2fsprogs >/dev/null 2>&1; then
	E2FS_PREFIX="$(brew --prefix e2fsprogs)"
	export PATH="$E2FS_PREFIX/sbin:$E2FS_PREFIX/bin:$PATH"
fi

docker build --platform linux/arm64 -t pi-guest:latest .
npx gondolin build --config build-config.json --tag pi-dev:latest
