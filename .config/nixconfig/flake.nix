{
  description = "Ramon's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.neovim
          pkgs.git
	  pkgs.direnv
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";
      nixpkgs.config.permittedInsecurePackages = [
       "nodejs-12.22.12"
      ];
      # Add ability to used TouchID for sudo authentication
      security.pam.enableSudoTouchIdAuth = true;

      users.users.ramon.home = "/Users/ramon";
      home-manager.backupFileExtension = "backup";
      nix.configureBuildUsers = true;

      programs.zsh.enable = true;
      environment.shells = [
        pkgs.zsh
      ];
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."Ramons-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration
        nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = "ramon";
              autoMigrate = true;
            };
          }
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ramon = import ./home.nix;
        }];
    };

    # Expose package set
    darwinPackages = self.darwinConfigurations."Ramons-MacBook-Pro".pkgs;
  };
}
