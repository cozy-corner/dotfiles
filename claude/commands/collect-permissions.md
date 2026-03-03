---
description: Collect likely-harmless tool calls from this session and register them in global settings
allowed-tools: Read, Edit, Bash(git diff:*)
---

このセッションで実行されたツール呼び出しを分析し、明らかに無害な操作をグローバル設定に追加します。

## 現在のグローバル設定

!`cat ~/.claude/settings.local.json`

## 手順

### 1. セッションの操作を分析する

この会話全体を遡り、`Bash(...)` で実行されたコマンドをすべてリストアップする。

### 2. 無害性の判定基準

**収集対象（明らかに無害）：**
- 読み取り専用コマンド（ls, cat, grep, find, stat, wc, diff, head, tail, file, type, which, env など）
- git 情報取得系（git log, git diff, git show, git status, git blame, git branch, git tag, git remote, git stash list など）
- gh 情報取得系（gh pr view/list/diff/checks, gh issue view/list, gh repo view, gh run view/list, gh workflow list など）
- CLI ツールの情報取得（jq, yq, bat, fd, rg, tree, tokei, curl -s GETなど）
- ビルド系（pnpm build, tsc, gradle build, cargo build, npm run build など）
- テスト系（pnpm test, jest, vitest, gradle test, cargo test, npm test, pytest など）
- Lint / Format 確認系（eslint, ktlint, prettier --check, rubocop など）
- パッケージ情報確認（pnpm list, brew list, brew info, npm list, pip list など）

**収集しない：**
- 破壊的ファイル操作（rm, rmdir, mv による上書きなど）
- git 変更系（commit, push, checkout, reset, rebase など）
- 外部サービスへの書き込み（gh pr create, gh issue create, curl POST など）
- 本番環境操作（deploy, terraform apply, kubectl delete など）

### 3. 既存との差分

上記設定の `permissions.allow` にすでに含まれているものは除外する。

パターンの形式：
- 引数なし固定コマンド → `"Bash(command subcommand)"`
- 引数が変わるコマンド → `"Bash(command:*)"`

### 4. 候補を提示して確認

追加候補を箇条書きで表示し、ユーザーの確認を求める。
候補が0件の場合はその旨を伝えて終了する。

### 5. 確認後に書き込む

ユーザーが承認したら `~/.claude/settings.local.json` の `permissions.allow` 配列に追記する。
書き込み後、`git diff ~/.claude/settings.local.json` で差分を表示する。
