{ config, pkgs, lib, ... }:
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "allangarcez";
  home.homeDirectory = "/Users/allangarcez";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".zshrc".source = ~/dotfiles/zsh/zshrc;
    ".gitconfig".source = ~/dotfiles/git/gitconfig;
    ".ideavimrc".source = ~/dotfiles/idea/.ideavimrc;
    ".config/starship.toml".source = ~/dotfiles/config/starship.toml;
    ".config/yazi".source = ~/dotfiles/config/yazi;
    ".config/lazygit".source = ~/dotfiles/config/lazygit;
    "Library/Application Support/Code/User/settings.json".source = ~/dotfiles/vscode/settings.json;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    DOTFILES = "~/dotfiles";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
