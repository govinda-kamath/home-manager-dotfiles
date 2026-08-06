{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.byobu ]; # brings tmux + screen along with it

  # Byobu launches the user's $SHELL inside tmux. On non-NixOS the system
  # login shell is bash, so point byobu at our nix zsh explicitly.
  home.sessionVariables.BYOBU_SHELL = "${config.programs.zsh.package}/bin/zsh";

  # `byobu-enable` can't be used here: it unconditionally tries to append
  # a launch line to ~/.profile, but home-manager owns that file as a
  # symlink into the read-only Nix store, so the write fails with
  # "Permission denied". Install the same line it would have written
  # (see install_launcher() in byobu's byobu-launcher-install.in)
  # directly into our zsh config instead. byobu-launch already guards
  # against nested launches and non-interactive shells, so sourcing it
  # unconditionally here is safe.
  programs.zsh.initContent = ''
    _byobu_sourced=1 . ${pkgs.byobu}/bin/byobu-launch 2>/dev/null || true
  '';
}
