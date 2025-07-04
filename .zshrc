# emacs key bind
bindkey -e

export PATH=$HOME/.nodebrew/current/bin:$PATH
export EDITOR=nvim

PROMPT='%~ %! %# '

setopt append_history
setopt inc_append_history
setopt share_history

HISTSIZE=1000
SAVEHIST=1000

alias ll='ls -laG'
alias llh='ls -laG ~' 
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias c='clear'
alias vim='nvim'

# git
alias gb='git branch --sort=-committerdate'
alias gs='git status'
alias ga='git add'
alias gd='git diff'
alias gp='git push'
alias gpoh='git push origin head'
alias gl='git log --oneline --graph --decorate'
alias gcan='git commit --amend --no-edit'
alias gsmdc='current_branch=$(git rev-parse --abbrev-ref HEAD) && git checkout main && git branch -D $current_branch'
alias gcae='git commit --allow-empty -m "empty commit"'
alias gpc='git pull origin $(git branch --show-current)'
alias grh='git fetch origin && git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)'
alias proot='cd $(git rev-parse --show-toplevel)'

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

alias kp=killport

export PATH=$HOME/.nodebrew/current/bin:$PATH
alias uuid='uuidgen | tr "[:upper:]" "[:lower:]" | tr -d '\n' | pbcopy'
aliasdc='docker-compose'
alias tf='terraform'
alias dc='docker-compose'
alias dcu='docker-compose up'

# google cloud
alias gal='gcloud auth login --update-adc'

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
