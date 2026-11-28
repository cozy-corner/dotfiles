#!/bin/bash
# UserPromptSubmit: 合意の記録を毎ターン判断の直前に注入する。AGENTS.md だけでは会話が長くなると効かない。
trap 'rc=$?; echo "$(date +%FT%T) ${0##*/} exit=$rc" >>"$HOME/.claude/hook-stats.log"' EXIT
sid=$(jq -r '.session_id // empty')

[ -n "$sid" ] && echo "この発言で、依頼が済んだ後も判断を縛り続けるもの（作業の進め方の取り決め・仕様の決定・課題の合意）が決まったら、返答の前に ~/.claude/agreements/$sid.md へ「合意: … / 理由: …」で追記する。値の変更・指摘への対応指示・承認した設計の中身・作業の結果は書かない（コードと会話に残る）。"
[ -n "$sid" ] && echo "この発言が作業の依頼（調査・設計・実装など）で、~/.claude/agreements/$sid.md にまだ課題の合意がなければ、調べる・作る前に、課題を一文（何を解決したいか＋課題の種類）にしてユーザーに確認する。確認が取れたら最初の合意として記録する。"
exit 0
