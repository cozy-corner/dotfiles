# dotfiles

個人の設定ファイル置き場。`install.sh` が各ファイルをホームディレクトリへシンボリックリンクする（`~/.claude/CLAUDE.md` → `claude/AGENTS.md`、`~/.claude/settings.json` → `claude/settings.json` など）。つまりこのリポジトリのファイルは、編集した時点で稼働中の設定そのものになる。

## Git
- このリポジトリでは `main` で直接作業する。ブランチも worktree も作らない。稼働中の設定は main のチェックアウトからリンクされているため、ブランチ上の変更はマージするまで反映されない。
- 依頼された変更以外に未コミットの差分があっても、一切触れない。ステージもコミットもせず（別コミットに分けるのも不可）、報告もしない。

## claude/settings.json
- `~/.claude/settings.json` のリンク先。稼働中の Claude Code 自身が `model` や `effortLevel` などを随時書き戻すため、未コミットの差分が定常的に存在する。`/model` でデフォルトを変えると `model` キーが書き戻される（キーを消しても再追加される）。
- `git merge` / `git rebase` / `git checkout` がこのファイルでブロックされたとき、`stash` や `skip-worktree` での退避は効かない。アプリが直後にほぼ同一内容で再生成するため空振りする。

## .zshrc
- マシン固有の値（vault パス、ホスト個別の PATH、インストーラが追記するブロック）は、追跡されている `.zshrc` ではなく `~/.zshrc_local`（追跡外）に置く。`.zshrc` から source される。
