{ pkgs, ... }:

{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    atuin
    bat
    beam.packages.erlang_29.erlang
    beam.packages.erlang_29.rebar3
    blueutil
    delta
    direnv
    exercism
    eza
    fd
    fzf
    gh
    git-filter-repo
    gleam
    herdr
    hunk
    jq
    mise
    neovim
    nightlight
    opencode
    pgcli
    postgresql
    ripgrep
    tealdeer
    tmux
    tree
    tree-sitter
    usql
    uv
    vivid
    zoxide
    zsh-abbr
  ];

  programs.home-manager.enable = true;
}
