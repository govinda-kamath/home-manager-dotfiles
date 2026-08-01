{
  programs.git = {
    enable = true;
    userName = "gmk"; # ── EDIT ME (or override in hosts/<hostname>.nix)
    userEmail = "gmk@example.com"; # ── EDIT ME

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
      # Make `git diff` a bit prettier
      diff.algorithm = "histogram";
      # Cache credentials in memory for 1 hour (no plaintext storage)
      credential.helper = "cache --timeout=3600";
    };
  };
}
