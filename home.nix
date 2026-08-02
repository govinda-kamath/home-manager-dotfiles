{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Keeps `home-manager` happy; see https://nix-community.github.io/home-manager/options.html#opt-home.stateVersion
  home.stateVersion = "25.05";

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Back up any distro-default dotfiles that would block home-manager's symlinks.
  home.activation.backupConflictingDotfiles = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    for f in .bashrc .profile; do
      if [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
        mv "$HOME/$f" "$HOME/$f.bak"
      fi
    done
  '';

  # Everything under ~/.config is managed by home-manager. Don't fight it.
  xdg.enable = true;

  home.packages = with pkgs; [
    # --- core CLI essentials ---
    curl
    wget
    jq
    htop
    tree
    file
    lazygit

    # --- improved CLI tools ---
    bat      # cat with syntax highlighting
    eza      # modern ls with colors, icons, git status
    mosh     # UDP ssh that survives flaky connections
    ncdu     # interactive disk usage
    du-dust  # intuitive du replacement
    gh       # GitHub CLI
    just     # modern make replacement

    # --- languages & toolchains (details in ./modules/dev.nix) ---
  ];

  imports =
    [
      ./modules/shell.nix # zsh with autocomplete/highlighting/dedup history
      ./modules/dev.nix # python, rust, go toolchains
      ./modules/nvim.nix # neovim with LSP/completion/telescope
      ./modules/ghostty.nix # ghostty terminal + config
      ./modules/git.nix
      ./modules/ssh.nix
      ./modules/byobu.nix
      ./modules/conda.nix
    ]
    # Load per-host overrides if present (e.g. hosts/somebox.nix)
    ++ (let
      host = builtins.getEnv "HOSTNAME";
      f = ./hosts + "/${host}.nix";
    in
    lib.optional (builtins.pathExists f) f);
}
