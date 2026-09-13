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

# 1. Features を解決した OCI image を作る
npx -y @devcontainers/cli@latest build \
	--workspace-folder . \
	--image-name pi-guest:latest \
	--platform linux/arm64

# 2. image の ENV を build-config.json へ転記する。
#    gondolin は OCI image の ENV を rootfs に引き継がないため、これをやらないと
#    Features が ENV で通しているパス (RUSTUP_HOME など) が失われる。
if ! command -v jq >/dev/null 2>&1; then
	echo "jq is required (brew install jq)" >&2
	exit 1
fi
env_json="$(docker image inspect pi-guest:latest --format '{{json .Config.Env}}')"
jq --argjson env "$env_json" '.env = $env' build-config.json > build-config.json.tmp
mv build-config.json.tmp build-config.json

# 3. rootfs を焼いてローカルの image store に登録する
npx gondolin build --config build-config.json --tag pi-dev:latest
