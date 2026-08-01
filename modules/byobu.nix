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

  # Auto-start a byobu session on SSH login — the classic "ssh in and your
  # tmux session is still there" workflow. Remove this block if you'd rather
  # start byobu manually.
  programs.zsh.initContent = ''
    # Auto-start byobu on SSH login (guard against nesting inside tmux/byobu)
    if [[ -n "$SSH_TTY" && -z "$TMUX" && -z "$BYOBU" ]]; then
      exec byobu
    fi
  '';
}
