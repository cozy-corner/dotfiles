# emacs key bind
bindkey -e

export PATH=$HOME/.nodebrew/current/bin:$PATH
export EDITOR=nvim


# eza colors (Catppuccin Mocha theme - subdued)
export LS_COLORS="$(vivid generate catppuccin-mocha)"
export EZA_COLORS="\
ur=38;2;186;194;222:uw=38;2;186;194;222:ux=38;2;186;194;222:\
gr=38;2;166;173;200:gw=38;2;166;173;200:gx=38;2;166;173;200:\
tr=38;2;147;153;178:tw=38;2;147;153;178:tx=38;2;147;153;178:\
uu=38;2;137;180;250:un=38;2;127;132;156:\
gu=38;2;166;173;200:gn=38;2;127;132;156:\
sn=38;2;166;173;200:sb=38;2;147;153;178:\
da=38;2;147;153;178"

PROMPT='%~ %! %# '

setopt append_history
setopt inc_append_history
setopt share_history

HISTSIZE=1000
SAVEHIST=1000

alias grep='grep --color=auto'  # abbrだと再帰展開になるためaliasのまま

# zsh-abbr
source "$(brew --prefix)/share/zsh-abbr/zsh-abbr.zsh"

alias ls='eza -a --icons'  # abbrだと同名コマンドが存在するためaliasのまま
alias vim='nvim'            # abbrだと同名コマンドが存在するためaliasのまま
alias vi='nvim'             # abbrだと同名コマンドが存在するためaliasのまま

# Block git commit --no-verify
git() {
    if [[ "$1" == "commit" ]]; then
        for arg in "$@"; do
            if [[ "$arg" == "--no-verify" || "$arg" == "-n" ]]; then
                echo "❌ ERROR: --no-verify bypasses quality checks and is forbidden"
                echo "Pre-commit hooks ensure code quality. Please fix issues instead of bypassing them."
                return 1
            fi
        done
    fi
    command git "$@"
}

gc() {
  git commit -m "$1"
}
alias gbd='git branch | fzf -m | xargs git branch -D'
gbr() {
  local branches branch
  branches=$(git --no-pager branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}
gbrr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout -f $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}
gbrf() {
  local branches branch
  branches=$(git --no-pager branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout -f $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}
gm() {
    local selected_branch=$(git branch | fzf --height 40% --border --ansi)

    if [[ -n "$selected_branch" ]]; then
        selected_branch=$(echo "$selected_branch" | sed 's/^[ *]*//')
        git merge "$selected_branch"
    else
        echo "No branch selected."
    fi
}
gfco() {
  local branch
  branch=$(git ls-remote --heads origin | awk '{print $2}' | sed 's|refs/heads/||' | fzf +m --height 40% --border --ansi --prompt="Select remote branch: ") &&
  branch=$(echo "$branch" | xargs) &&
  git fetch origin "$branch" &&
  git checkout "$branch"
}
gwd() {
  git worktree list | fzf -m | while read -r line; do
    local worktree_path=$(echo "$line" | awk '{print $1}')
    local branch_name=$(echo "$line" | awk '{print $3}' | tr -d '[]')
    git worktree remove -f "$worktree_path" && git branch -D "$branch_name"
  done
}
gwcd() {
  local worktrees worktree
  worktrees=$(git worktree list) &&
  worktree=$(echo "$worktrees" | fzf) &&
  cd $(echo "$worktree" | awk '{print $1}')
}

gh-watch() {
    gh run list \
      --branch $(git rev-parse --abbrev-ref HEAD) \
      --json status,name,databaseId |
      jq -r '.[] | select(.status != "completed") | (.databaseId | tostring) + "\t" + (.name)' |
      fzf -1 -0 | awk '{print $1}' | xargs gh run watch
}


killport() {
    if [ -z "$1" ]; then
        echo "Usage: killport <port>"
        return 1
    fi
    lsof -ti:$1 | xargs kill -9
}

h() {
    local cmd=$(history 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | awk '!seen[$0]++' | fzf +s +m)
    eval "$cmd"
}

cpwd() {
  pwd | tr -d '\n' | pbcopy
  echo "Copied: $(pwd)"
}
alias dc='docker-compose'  # abbrだと同名コマンドが存在するためaliasのまま

if [ -f ~/.zshrc_bo ]; then
    source ~/.zshrc_bo
fi

eval "$(fzf --zsh)"
eval "$(zoxide init zsh --hook prompt )"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sasakitakashinanji/work/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sasakitakashinanji/work/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sasakitakashinanji/work/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sasakitakashinanji/work/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="/usr/local/share/dotnet:$PATH"

# Added by CodeRabbit CLI installer
export PATH="$HOME/.local/bin:$PATH"

# Go
export PATH="$HOME/go/bin:$PATH"

# git-gtr completion
[ -f ~/tools/git-worktree-runner/completions/git-gtr.zsh ] && source ~/tools/git-worktree-runner/completions/git-gtr.zsh
# Load mise if installed (handles environment-specific tools)
command -v mise &> /dev/null && eval "$(mise activate zsh)"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# tealdeer
export TEALDEER_CONFIG_DIR="$HOME/.config/tealdeer"

# atuin - shell history
eval "$(atuin init zsh)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
