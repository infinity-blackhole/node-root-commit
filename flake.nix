{
  description = "Node template project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, devenv, ... }@inputs: {
    devShells = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.unix (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              pre-commit.hooks = {
                actionlint.enable = true;
                markdownlint.enable = true;
                shellcheck.enable = true;
                nixpkgs-fmt.enable = true;
                statix.enable = true;
                deadnix.enable = true;
                hadolint.enable = true;
              };
              packages = [
                pkgs.nixpkgs-fmt
                pkgs.docker
              ];
            }
            {
              pre-commit.hooks.prettier.enable = true;
              packages = [
                pkgs.nodejs
              ];
            }
          ];
        };
      }
    );
  };
}
