export PATH=$HOME/.nodebrew/current/bin:$PATH

alias ll='ls -laG'
alias llh='ls -laG ~' 
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias c='clear'
alias h='history'
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
