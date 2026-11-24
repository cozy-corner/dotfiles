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
    ripgrep
    tealdeer
    tmux
    tree
    vivid
    zoxide
  ];

  programs.home-manager.enable = true;
}
