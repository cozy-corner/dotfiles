#!/bin/bash
# Stop: 「未確認です」「確認しますか」で答えを終えるのを1回だけ差し戻す。AGENTS.md の規則だけでは守られず、「確認して」の往復が続くため。
# 語句で見るだけなので、結論を左右するか・読み取りで確かめられるかの判断は差し戻された Claude に任せる。
trap 'rc=$?; echo "$(date +%FT%T) ${0##*/} exit=$rc" >>"$HOME/.claude/hook-stats.log"' EXIT
input=$(cat)

[ "$(jq -r '.stop_hook_active // false' <<<"$input")" = "true" ] && exit 0

msg=$(jq -r '.last_assistant_message // empty' <<<"$input")
pattern='未確認|確認していません|確認できていません|確認しておりません|要確認|確認が必要|断言できません|読んでいない|読んでいません|読めていません|読めていない|見ていない|見ていません|調べますか|確認しますか|確認しましょうか|必要なら.{0,40}確認します|unverified|not verified|haven.t (confirmed|verified|checked)|shall I check'
hit=$(grep -Eoi "$pattern" <<<"$msg" | sort -u | paste -sd ',' -)
[ -n "$hit" ] || exit 0

reason="直前の応答に「${hit}」があります。その点が結論を左右し、読み取り（Read・grep・ログ・ドキュメント）で確かめられるなら、いま確かめて、確かめた結果を追記してください。結論を左右しないなら、その但し書きは不要だったと一言で添えてください。確かめるのに状態の変更・外部への送信・ユーザーしか持たない情報が要るなら、何が未確認でなぜ確かめられないかを明記したまま終えて構いません。"
echo "$reason" >&2
exit 2
