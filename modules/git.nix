{ lib, ... }:
{
  programs.git = {
    enable = true;

    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      lg = "log --oneline --decorate --graph -20";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
    };

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
      push.autoSetupRemote = true;
      color.ui = "auto";
      core.editor = "vim";
      diff.algorithm = "histogram";
      credential.helper = "cache --timeout=3600";
      # Personal name/email live here — file is not tracked by git
      include.path = "~/.gitconfig.local";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
    };
  };

  # Prompt for git identity on first activation; writes ~/.gitconfig.local
  home.activation.gitLocalIdentity = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ ! -f "$HOME/.gitconfig.local" ]]; then
      if [[ -t 0 ]]; then
        echo ""
        echo "Git identity not set up (stored in ~/.gitconfig.local, not committed)."
        read -rp "  Full name:  " _git_name
        read -rp "  Email:      " _git_email
        printf '[user]\n\tname = %s\n\temail = %s\n' "$_git_name" "$_git_email" > "$HOME/.gitconfig.local"
        echo "  Saved to ~/.gitconfig.local"
      else
        echo "Warning: ~/.gitconfig.local missing. Run activation in an interactive terminal to set up git identity."
      fi
    fi
  '';
}
