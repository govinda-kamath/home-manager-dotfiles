{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.zsh = {
    enable = true;

    # zsh's built-in completion system (compinit)
    enableCompletion = true;

    # Fish-style autosuggestions as you type
    autosuggestion = {
      enable = true;
      # Subtle highlight so suggestions don't shout at you
      highlight = "fg=244";
    };

    # Syntax highlighting (valid commands green, typos red, etc.)
    syntaxHighlighting.enable = true;

    # ── History: dedup + share across sessions ────────────────────────────
    history = {
      size = 10000; # in-memory
      save = 100000; # on disk
      ignoreDups = true; # don't add if same as previous line
      ignoreAllDups = true; # don't add if it exists anywhere in history
      ignoreSpace = true; # don't add commands starting with a space
      share = true; # share history between concurrent sessions
      extended = true; # store timestamps (needed for dedup metadata)
    };

    # A few ergonomic aliases
    shellAliases = {
      ll = "ls -lah";
      la = "ls -a";
      g = "git";
      gs = "git status";
      gp = "git push";
      gl = "git pull";
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    initContent = ''
      # vi-mode not for everyone; if you want it, uncomment:
      # bindkey -v

      # Don't wait 0.4s for a key after escape — instant keybind feedback
      export KEYTIMEOUT=1

      # `cd` alone goes home, `cd -` goes back (already default, but explicit)
      setopt AUTO_CD

      # Correct typos in cd commands
      setopt CORRECT_ALL

      # Better globbing: ** for recursive, extended globs, null (no-error) globs
      setopt EXTENDED_GLOB
      setopt GLOB_DOTS

      # Prompt: user@hostname in a nice two-line layout
      setopt PROMPT_SUBST
      precmd() { print -Pn "\e]0;%n@%m %~\a" } # set terminal title
      PROMPT=$'%(?.%F{green}➜.%F{red}➜)%f %F{cyan}%n@%m%f %F{yellow}%~%f\n%F{blue}❯%f '
    '';
  };

  # zsh must be our login shell for the whole setup to feel native.
  # On non-NixOS this needs `chsh -s $(which zsh)` once (see README).
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
  };
}
