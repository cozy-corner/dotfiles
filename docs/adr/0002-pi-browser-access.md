# 2. pi のブラウザ操作は playwright-mcp をホストで headless 実行して与える

- 状態: 採用
- 日付: 2026-09-22

## 背景

pi からブラウザを操作する手段が無い。原因は2つ重なっている。

1つは pi が MCP を持たないこと。これは設計上の意思で、README は
「**No MCP.** Build CLI tools with READMEs, or build an extension that adds
MCP support」と書いている。コアへの MCP 内蔵は issue #563 で提案されたが未実装。
Claude Code 側の `~/.claude.json` に設定してある `chrome-devtools` MCP は
pi からは見えない。

もう1つは gondolin による隔離。pi の組み込みツールは micro VM 内で実行されるため
(`pi/gondolin/index.ts`)、bash から起動したものはホストの Chrome に到達できない。
ただし差し替えられているのは `read / write / edit / bash / ls / find / grep` の
7つを名指しで `registerTool` しているものだけで、拡張が登録するツールは pi 本体
(ホストプロセス) で動く。この差が選択肢を分ける。

選択肢は3つあった。

- **chrome-devtools-mcp をホストで動かす** — Chrome 専用。performance trace、
  Lighthouse、heap snapshot、`--browserUrl` で稼働中の実 Chrome への接続、と
  計測・デバッグ機材として強い。一方で trace 中の URL を CrUX API に送る
  `--performanceCrux` と Google への使用統計送信が既定 on
- **playwright-mcp をホストで動かす** — Chromium 以外も動き、`--codegen` で
  操作から Playwright のテストコードを生成でき、`--save-trace` / `--storage-state`
  など自動化寄りの機能を持つ
- **Playwright を gondolin の guest image に焼き、VM 内で完結させる** — 隔離方針
  との整合は最も良い。ホストで第三者コードを動かさずに済み、VM 内で回す dev server
  にはゲストの localhost からそのまま届く

想定している用途はほとんどがデバッグ (画面を見る、コンソールとネットワークを読む、
少しクリックする) で、この範囲の能力は3つとも同等だった。そのため差がつくのは
性能計測でもテスト資産化でもなく、**描画の忠実性と運用コスト**になった。

VM 内 Playwright は、レンダリングエンジンが同じなので flex/grid/overflow のような
レイアウトのバグは再現する。しかしフォントが別物で、`debian:bookworm-slim` 素の
ままでは日本語が豆腐になり、`fonts-noto-cjk` を足しても字形とメトリクスは macOS と
一致しない。テキスト幅が変われば折り返しもはみ出しも変わるため、「自分の画面で
どう見えるか」の確認には使えない。加えて image が約1GB 増え、VM のメモリを既定の
1G から引き上げる必要があり、これは pi の稼働中ずっとホストの実メモリを占める。

## 決定

**playwright-mcp をホスト側で headless 実行し、第三者拡張 `pi-mcp-adapter` 経由で
pi に繋ぐ。**

Playwright を guest image に焼く案は採らない。chrome-devtools-mcp も採らない。

## 結果

- ホストの macOS 上で描画されるため、フォントも見た目も普段の画面と一致する。
  CSS の確認に使える
- headless なのでウィンドウが湧かない
- `@playwright/mcp` は既にホストへ導入済みで、image の焼き直しも VM のメモリ増設も
  発生しない。消費するのは使用中の数百MB だけ
- **gondolin の隔離を部分的に崩す。** `pi-mcp-adapter` は第三者製で、これをホスト
  権限で動かすことになる。gondolin 導入の動機 (「ツール実行をローカル VM に隔離し、
  認証情報の漏洩を防ぐ」) と逆向きのコストを受け入れている
- 性能計測 (perf trace / Lighthouse / heap) は手に入らない。必要になった場合は
  chrome-devtools-mcp を `--browserUrl` で併用すればよく、playwright-mcp と排他では
  ない
- **VM 内で起動した dev server には届かない。** ホストで dev server を回している
  限り問題にならないが、VM 内で回す構成に倒す場合は別途 ingress が要る
  (後述)

## 残る課題: ホストから VM の画面が見えない

この ADR とは別件だが、同じ穴から出てきた問題として記録しておく。

gondolin 導入時の検証は「エージェントが VM 内でインストール・ビルド・テストできるか」
という軸に寄っており、「人間が結果を見るループ」が抜けていた。ADR-0001 も
`PLAN.md` の Phase 1〜3 も扱っているのはビルド側だけで、`index.ts` で唯一
ネットワーク方向に触れている `tcp.hosts` は guest→host (DB への転送) である。

そのため VM 内で `npm run dev` しても、ホストのブラウザからは到達できない。
gondolin 自体は `vm.enableIngress()` を持っており (ホストに HTTP ゲートウェイを
立て、ゲスト内の `/etc/gondolin/listeners` に書いた prefix→ポートで振り分ける。
WebSocket も既定で有効)、上流は想定しているが `index.ts` が呼んでいない。

現状の回避策は dev server をホスト側で回すこと。VM 内で回す必要があるのは
Linux 向けネイティブモジュールを使う場合 (loverese の better-sqlite3 など) に
限られる。

## 前提が変わる条件

dev server を VM 内で回す運用に倒すなら、ingress の実装が前提条件になる。
また、見た目の確認より隔離を優先する方針に変わるなら、VM 内 Playwright を
選び直す余地がある (その場合はフォントの不一致を受け入れることになる)。
