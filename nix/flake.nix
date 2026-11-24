{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # getEnv / currentSystem はマシンごとの値を読むため `--impure` が必要
  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = builtins.currentSystem;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "zsh-abbr" ];
      };
      modules = [ ./home.nix ];
    };
  };
}
