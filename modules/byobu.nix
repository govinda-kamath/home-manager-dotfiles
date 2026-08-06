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

}
