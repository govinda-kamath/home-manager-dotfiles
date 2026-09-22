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
  # directly into our zsh config instead.
  #
  # Source the dot-prefixed `.byobu-launch` (the actual POSIX-sh launcher),
  # NOT the plain `byobu-launch` in bin/ — that one is a Nix makeWrapper
  # stub whose last line is `exec .../. byobu-launch "$@"`. Sourcing a
  # script that ends in `exec` replaces the *current* shell process with
  # `sh -e` running the real launcher, so any failure in it (e.g. no
  # usable tty over some SSH clients) kills the login shell outright —
  # this silently dropped SSH connections before a prompt ever appeared.
  # Sourcing `.byobu-launch` directly avoids the exec (and its inherited
  # `-e`), so failures fall through to the `|| true` guard as intended.
  #
  # Byobu also ships autolaunch *disabled* by default: the first time its
  # config dir is created it drops a `disable-autolaunch` flag file, and
  # normally only `byobu-launcher-install` (part of the real byobu-enable,
  # which we're not running) removes it. Clear it ourselves right before
  # every launch attempt — not just once via home.activation — since on a
  # brand-new machine the config dir (and its flag) won't exist yet at
  # activation time and would otherwise get created fresh on first login,
  # silently re-disabling autolaunch until the next `home-manager switch`.
  programs.zsh.initContent = ''
    rm -f "$HOME/.config/byobu/disable-autolaunch" 2>/dev/null
    _byobu_sourced=1 . ${pkgs.byobu}/bin/.byobu-launch 2>/dev/null || true
  '';
}
