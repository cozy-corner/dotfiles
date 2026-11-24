{ pkgs, ... }:

{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    atuin
    bat
    delta
    direnv
    exercism
    eza
    fd
    fzf
    gh
    git-filter-repo
    herdr
    hunk
    jq
    mise
    neovim
    opencode
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
