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
  ];

  programs.home-manager.enable = true;
}
