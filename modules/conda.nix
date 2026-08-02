{ pkgs, ... }:

{
  home.packages = [ pkgs.micromamba ];

  home.sessionVariables.MAMBA_ROOT_PREFIX = "$HOME/.micromamba";

  programs.zsh.initContent = ''
    eval "$(${pkgs.micromamba}/bin/micromamba shell hook --shell zsh)"
    # Only activate base once the prefix has been initialised
    [[ -d "$HOME/.micromamba" ]] && micromamba activate base
  '';
}
