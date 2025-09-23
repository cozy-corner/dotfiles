# CodeRabbit CLI スラッシュコマンド開発記録

## 概要
Claude Code向けにCodeRabbit CLIを活用したスラッシュコマンドを作成した際の試行錯誤と最終的な解決策をまとめる。

## 目標
- uncommitted changesに対するCodeRabbit CLIレビューを実行
- バックグラウンド実行によるノンブロッキング動作
- 詳細なレビュー結果の取得と整形

## 開発過程

### Phase 1: Taskエージェントアプローチ

#### 設計思想
- `allowed-tools: Task(general-purpose:*)`でTaskエージェントを起動
- エージェントがバックグラウンドでCodeRabbit CLIを実行
- 真のバックグラウンド実行を実現

#### 実装
```markdown
---
allowed-tools: Task(general-purpose:*)
---

## How it works
1. Launches background agent - Uses Task tool with general-purpose agent
2. Agent runs CodeRabbit CLI - Executes `coderabbit --prompt-only`
```

#### 問題点と矛盾
1. **バックグラウンドの虚偽**: Taskエージェント起動後、結果を待ってブロッキング
2. **用途の不一致**: Taskエージェントは「投げっぱなし」用途で、即座に結果が欲しいスラッシュコマンドに不適切
3. **複雑性**: 不要に複雑な実装

#### 気づき
- Taskエージェントはリサーチや長期タスク向け
- スラッシュコマンドには即座の結果が必要
- 「バックグラウンド実行」と言いながら同期的に待機していた

### Phase 2: 直接実行アプローチ（最終解決策）

#### 設計思想
- Claude CodeがBashツールで直接`coderabbit`コマンドを実行
- シンプルで確実な動作
- 複雑な間接実行を排除

#### 最終実装
```markdown
---
syntax: coderabbit-review
description: AI-driven review of uncommitted changes
allowed-tools: Bash(coderabbit:*), Bash(git:*)
---

## How it works
1. Check git status - Show current uncommitted changes
2. Run CodeRabbit CLI - Execute `coderabbit --prompt-only` directly
3. Process results - Analyze AI prompts and format findings
4. Provide detailed report - Human-readable summary with specific fixes
```

#### 成功要因
- ✅ エラーなしで動作
- ✅ 確実な実行（Bashツールは動作確認済み）
- ✅ シンプルで理解しやすい
- ✅ デバッグしやすい

## 技術的な発見

### CodeRabbit CLI の挙動

#### `--plain` vs `--prompt-only`
- **`--plain`**: 人間向けの詳細出力（Comment、diff例、AI prompts）
- **`--prompt-only`**: AI向けの簡潔出力（AI promptsのみ）

#### ファイル認識とStaging状態

**検証した事実（実験結果）:**
```bash
# Staged状態でのテスト
A  problematic_code.js  → 詳細なレビュー結果 ✅

# Untracked状態での複数回テスト（同一ファイル内容）
?? problematic_code.js  → 結果なし ❌
?? problematic_code.js  → 詳細なレビュー結果 ✅
?? problematic_code.js  → レート制限エラー ❌
?? problematic_code.js  → 詳細なレビュー結果 ✅
```

**観察された現象:**
- Staged状態では安定してレビュー結果が出力された（1回のテスト）
- Untracked状態では同じファイル内容でも結果が変動した（4回のテスト）

**不明な点:**
- Staging状態とレビュー結果の因果関係は不明
- 結果の変動がStaging状態に起因するかサービス側の問題かは特定できない
- より多くのテストケースでの検証が必要

#### 出力の一貫性問題

**検証した事実:**
- 同一ファイル・同一内容で実行しても結果が異なることがある
- レート制限エラーが発生することがある
- "Review completed ✔"のみで詳細結果が出力されないことがある

**影響する可能性のある要因（推測）:**
- サービス側の負荷状況
- ネットワーク状況
- キャッシュの影響
- Staging状態（因果関係は不明）

#### 認証と組織

**検証した事実:**
- `coderabbit auth org`で組織切り替えが可能
- 認証状態は `coderabbit auth status` で確認可能
- 会社利用の組織 から 個人アカウント への組織切り替えを実行


### レート制限の特徴
```
❌ RATE_LIMIT ERROR: Rate limit exceeded (Recoverable)
```
- 明確なエラーメッセージで識別可能
- "Recoverable"表示で一時的な制限を示唆
- 時間経過で解除される(数分?)

### 実行環境の違い

**検証した事実:**
- **Bashツール使用**: ユーザーのローカル環境で実行される
- このセッションでレート制限エラーが複数回発生

**推測:**
- Claude Codeサーバーからの実行がレート制限に影響する可能性
- ユーザーローカル実行の方が安定する可能性

## 設計の誤解と学習

### 間違った前提
1. **Taskエージェント=バックグラウンド**: 用途が異なる

### 学んだこと
1. **obvious な解決策を見落とさない**: 直接実行が最良だった
2. **ツールの本来の用途を理解**: Taskエージェントは投げっぱなし用
3. **実際の動作を検証**: 「バックグラウンド」と言いながらブロッキングしていた

## 最終的な成果

### 動作するスラッシュコマンド
```bash
/coderabbit-review
```

### 機能
- uncommitted changesの詳細レビュー
- セキュリティ脆弱性の検出
- 具体的な修正提案
- ファイル・行番号の特定

### 検出例
- SQL injection vulnerabilities
- XSS risks (innerHTML usage)
- Command injection (exec concatenation)
- eval() security risks
- Hardcoded credentials
- Null reference errors
- Infinite loops

## 今後の改善点

### 確認された制限
- レート制限による実行失敗
- 同一条件での結果の変動
- Untracked ファイルでの不安定な動作（因果関係は不明）

### 潜在的改善策
- タイムアウト値の調整
- エラーハンドリングの強化
- 代替レビューツールの併用
- ローカルキャッシュの活用
- **レビュー前の自動staging（`git add` → review → `git reset`）**

## 結論

最終的に**直接実行アプローチ**により、機能的なCodeRabbitスラッシュコマンドを実現できた。過程では複数の設計ミスがあったが、シンプルな解決策が最も効果的であることが判明した。

外部サービス（CodeRabbit）への依存により完全な安定性は保証できないが、実用的なレベルでの動作を確認している。
