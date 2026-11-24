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
    eza
    fd
    fzf
    gh
    jq
    neovim
    ripgrep
    tealdeer
    tmux
    tree
    tree-sitter
    vivid
    zoxide
  ];

  programs.home-manager.enable = true;
}
