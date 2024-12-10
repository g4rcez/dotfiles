{
  description = "Setup osx";
  inputs = {
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # homebrew-nix
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle }:

  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      services.nix-daemon.enable = true;
      nix.settings.experimental-features = "nix-command flakes";
      nixpkgs.config.allowUnfree = true;

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 2;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.defaults = {
        loginwindow.GuestEnabled = false;
        dock.autohide = true;
        spaces.spans-displays = true;
        trackpad.TrackpadThreeFingerDrag = true;
        NSGlobalDomain = {
            AppleInterfaceStyle = "Dark";
            AppleICUForce24HourTime = true;
            KeyRepeat = 2;
            InitialKeyRepeat = 15;
        };
        finder = {
            ShowPathbar = true;
            ShowStatusBar = true;
            AppleShowAllFiles = true;
        };
      };

      homebrew = {
        enable = true;
        brews = ["mas"];
        casks = ["rectangle-pro" "jordanbaird-ice"];
        masApps = {};
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      environment.systemPackages =
        [ 
            pkgs.alt-tab-macos
            pkgs.bat
            pkgs.colima
            pkgs.coreutils
            pkgs.direnv
            pkgs.docker
            pkgs.docker-compose
            pkgs.espanso
            pkgs.fd
            pkgs.findutils
            pkgs.fx
            pkgs.fzf
            pkgs.gh
            pkgs.git
            pkgs.gitleaks
            pkgs.gnupg
            pkgs.google-chrome
            pkgs.jq
            pkgs.karabiner-elements
            pkgs.kitty
            pkgs.kubectl
            pkgs.lazydocker
            pkgs.lazygit
            pkgs.lsd
            pkgs.neovim
            pkgs.nixd
            pkgs.nmap
            pkgs.nuclei
            pkgs.obsidian
            pkgs.pinentry_mac
            pkgs.ripgrep
            pkgs.htop
            pkgs.fortune
            pkgs.figlet
            pkgs.rustup
            pkgs.starship
            pkgs.tokei
            pkgs.vivid
            pkgs.vscode
            pkgs.wezterm
            pkgs.zellij
            pkgs.zoxide
            pkgs.telegram-desktop
            pkgs.raycast
            pkgs.onefetch
            pkgs.mise
            pkgs.delta
            pkgs.jetbrains.rider
            pkgs.jetbrains.webstorm
            pkgs.jetbrains.datagrip
            pkgs.jetbrains.idea-ultimate
        ];
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#garcez
    darwinConfigurations."garcez" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs self; };
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "allangarcez";
            autoMigrate = true;
          };
        }
      ];
    };
    darwinPackages = self.darwinConfigurations."garcez".pkgs;
  };
}
