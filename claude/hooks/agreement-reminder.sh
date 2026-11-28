#!/bin/bash
# UserPromptSubmit: 合意の記録を毎ターン判断の直前に注入する。AGENTS.md だけでは会話が長くなると効かない。
trap 'rc=$?; echo "$(date +%FT%T) ${0##*/} exit=$rc" >>"$HOME/.claude/hook-stats.log"' EXIT
sid=$(jq -r '.session_id // empty')

[ -n "$sid" ] && echo "この発言に、以降の判断に効く取り決め・課題の合意・ユーザーによる訂正があれば、返答の前に ~/.claude/agreements/$sid.md へ「合意: … / 理由: …」で追記する。一回きりの作業指示や結果の報告は書かない。後で蒸し返されたら困るものだけ書く。"
[ -n "$sid" ] && echo "この発言が作業の依頼（調査・設計・実装など）で、~/.claude/agreements/$sid.md にまだ課題の合意がなければ、調べる・作る前に、課題を一文（何を解決したいか＋課題の種類）にしてユーザーに確認する。確認が取れたら最初の合意として記録する。"
exit 0
