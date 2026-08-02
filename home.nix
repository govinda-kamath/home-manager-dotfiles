{
  config,
  lib,
  pkgs,
  ...
}:

let
  # ── EDIT ME: per-machine identity ────────────────────────────────────────
  username = "gmk";
  # If different machines need different values, put overrides in ./hosts/<hostname>.nix
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Keeps `home-manager` happy; see https://nix-community.github.io/home-manager/options.html#opt-home.stateVersion
  home.stateVersion = "25.05";

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

    # --- languages & toolchains (details in ./modules/dev.nix) ---
  ];

  imports =
    [
      ./modules/shell.nix # zsh with autocomplete/highlighting/dedup history
      ./modules/dev.nix # python, rust, go toolchains
      ./modules/nvim.nix # neovim with LSP/completion/telescope
      ./modules/ghostty.nix # ghostty terminal + config
      ./modules/git.nix
      ./modules/byobu.nix
    ]
    # Load per-host overrides if present (e.g. hosts/somebox.nix)
    ++ (let
      host = builtins.getEnv "HOSTNAME";
      f = ./hosts + "/${host}.nix";
    in
    lib.optional (builtins.pathExists f) f);
}
