{ config, lib, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    # Let `ghostty` set up zsh integration (shell integration for panes/cwd tracking)
    enableZshIntegration = true;

    settings = {
      # Built-in theme — no external files needed
      theme = "catppuccin-mocha";

      # Font: JetBrains Mono Nerd Font (installed below via nerd-fonts)
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;

      # Feel
      background-opacity = 0.95;
      cursor-style = "block";
      cursor-style-blink = false;
      mouse-hide-while-typing = true;
      copy-on-select = "clipboard";

      # Sensible scrollback
      scrollback-limit = 10000;

      # Makes terminal apps (vim, byobu/tmux) behave well
      term = "xterm-256color";
    };
  };

  # Ghostty looks for system fonts via fontconfig. On non-NixOS (Ubuntu) we
  # need home-manager to wire up font discovery for our nix-installed fonts.
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    ghostty
    nerd-fonts.jetbrains-mono
  ];
}
