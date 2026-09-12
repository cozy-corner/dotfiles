# gondolin のゲスト rootfs のベースになる image。
# macOS では gondolin build の postBuild.commands が使えないため、
# パッケージ導入はここで済ませる (build/index.js の OCI + 非 Linux ホスト制約)。
FROM node:24-bookworm-slim

# gh は Debian の公式リポジトリに無いため、GitHub のリポジトリを追加する
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		gnupg \
	&& curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
		-o /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
		> /etc/apt/sources.list.d/github-cli.list \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential \
		gh \
		git \
		jq \
		less \
		openssh-client \
		python3 \
		ripgrep \
	&& rm -rf /var/lib/apt/lists/*
