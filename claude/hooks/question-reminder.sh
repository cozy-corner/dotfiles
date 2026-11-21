#!/bin/bash
# UserPromptSubmit: 質問への答え方を毎ターン判断の直前に注入する。AGENTS.md だけでは会話が長くなると効かない。
# 「？」の有無では判定しない。質問でも付けないことが多いため、判定は Claude に任せる。
trap 'rc=$?; echo "$(date +%FT%T) ${0##*/} exit=$rc" >>"$HOME/.claude/hook-stats.log"' EXIT
cat >/dev/null

echo "この発言が質問（批判・詰問の形も含む）なら: 答えを返してターンを終える。手元の情報で答えられるなら調べない。調べるのは答えに必要な読み取りだけ。編集・状態を変えるコマンド・修正の提案・「修正します」は禁止。"
