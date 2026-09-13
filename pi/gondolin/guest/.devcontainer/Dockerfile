# 言語 toolchain は devcontainer.json の Features に任せ、ここでは
# Features が扱わない汎用コマンドだけを入れる。
#
# ベースに devcontainers/base を使わないのは、zsh / oh-my-zsh / man / locale など
# 人間が対話的に使うための一式が 600MB 超で付いてくるため。ゲストではエージェントが
# コマンドを実行するだけなので不要。
FROM debian:bookworm-slim

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential \
		ca-certificates \
		curl \
		git \
		jq \
		less \
		openssh-client \
		procps \
		python3 \
		ripgrep \
		rsync \
		unzip \
		zip \
	&& rm -rf /var/lib/apt/lists/*
