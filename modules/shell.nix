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
      ls  = "eza --icons";
      ll  = "eza -lah --icons --git";
      la  = "eza -a --icons";
      g = "git";
      gs = "git status";
      gp = "git push";
      gl = "git pull";
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    initContent = ''
      # home.sessionVariables are written to ~/.profile (login shells only).
      # Source them here so TERMINFO_DIRS and friends work in all interactive shells.
      [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]] && \
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

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

      # Prompt: user@hostname, git branch, conda env, two-line layout
      setopt PROMPT_SUBST
      precmd() { print -Pn "\e]0;%n@%m %~\a" } # set terminal title

      autoload -Uz vcs_info
      zstyle ':vcs_info:*' enable git
      zstyle ':vcs_info:git:*' formats ' %F{magenta}[%b]%f'

      _set_prompt() {
        local conda_part=
        [[ -n "''${CONDA_DEFAULT_ENV}" ]] && conda_part=" %F{green}(''${CONDA_DEFAULT_ENV})%f"
        local nl=$'\n'
        PROMPT="%(?.%F{green}➜.%F{red}➜)%f %F{cyan}%n@%m%f %F{yellow}%~%f''${vcs_info_msg_0_}''${conda_part}''${nl}%F{blue}❯%f "
      }
      precmd_functions+=(vcs_info _set_prompt)
    '';
  };

  # Can't chsh without sudo on this host, so hand off from bash to zsh.
  programs.bash = {
    enable = true;
    initExtra = ''
      [[ $- == *i* ]] && exec zsh
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  # zsh must be our login shell for the whole setup to feel native.
  # On non-NixOS this needs `chsh -s $(which zsh)` once (see README).
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
    # ncurses on non-NixOS doesn't search the nix profile by default;
    # this lets it find terminfo entries like xterm-ghostty from installed packages.
    TERMINFO_DIRS = "${config.home.profileDirectory}/share/terminfo:/usr/share/terminfo";
  };
}
