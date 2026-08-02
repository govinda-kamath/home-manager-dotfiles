# gmk-nix-env

Portable dev environment via [home-manager](https://github.com/nix-community/home-manager), built for **non-NixOS Linux** (Ubuntu etc.) remote machines.

## What you get

| Area | Content |
|---|---|
| Shell | zsh with autocompletion, autosuggestions, syntax highlighting, dedup'd shared history, nice prompt |
| Languages | Python (python3 + uv + ruff + pyright), Rust (cargo/rustc/rust-analyzer/rustfmt/clippy), Go (go + gopls + delve) |
| Editor | Neovim: LSP for py/rust/go, nvim-cmp completion, telescope, neo-tree, treesitter, catppuccin-mocha |
| Terminal | Ghostty (catppuccin-mocha theme, JetBrains Mono Nerd Font), byobu with auto-start on SSH |
| Tools | ripgrep, fd, git (aliases + sane defaults), curl, wget, jq, htop, tree |

## Layout

```
flake.nix            # pinned nixpkgs + home-manager (release-25.05), builds for x86_64 & aarch64
home.nix             # imports modules; username lives here
modules/
  shell.nix          # zsh
  dev.nix            # python / rust / go toolchains
  nvim.nix           # neovim (LSP, completion, telescope, treesitter)
  ghostty.nix        # ghostty + font
  git.nix            # git config (EDIT git user.name/email)
  byobu.nix          # byobu + SSH auto-start
hosts/<hostname>.nix # optional per-machine overrides (loaded if HOSTNAME matches)
```

## Setup on a fresh remote machine (Ubuntu etc.)

```bash
# 1. Install nix. Flakes must be enabled; the determinate installer does this
#    for you. With the official installer, enable them first:
#      echo 'experimental-features = nix-command flakes' | sudo tee /etc/nix/nix.conf
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# or (official single-user):
#   curl -L https://nixos.org/nix/install | sh

# 2. New shell (or source the nix env script), then clone this repo
git clone <your-repo-url> ~/gmk-nix-env && cd ~/gmk-nix-env

# 3. Activate (pick the arch matching `uname -m`)
nix run .#homeConfigurations.gmk-x86_64.activationPackage
#   ARM box? → .#homeConfigurations.gmk-aarch64.activationPackage

# 4. Make zsh your login shell (nix zsh must be in /etc/shells first)
command -v zsh | sudo tee -a /etc/shells
chsh -s "$(command -v zsh)"

# 5. Done — log out and back in (or just start a new zsh).
#    On SSH login, byobu will auto-start. Your tmux sessions persist across disconnects:
#      byobu      → attach / create session
#      Ctrl-a d   → detach
#      byobu ls   → list sessions
```

### Updating later

```bash
cd ~/gmk-nix-env
nix flake update        # bump pinned inputs to latest release-25.05
nix run .#homeConfigurations.gmk-x86_64.activationPackage
```

## Customizing

- **Git identity** → edit `modules/git.nix` (`userName` / `userEmail`).
- **Machine-specific values** → create `hosts/<hostname>.nix` (use `hostname` to find it). It's auto-imported on that machine only. Example:

  ```nix
  { ... }: {
    programs.git.userName = "govinda";
    programs.git.userEmail = "me@work.com";
    home.packages = [ pkgs.some-work-tool ];
  }
  ```

- **Adding tools** → add to `home.packages` in `modules/dev.nix` (or `home.nix`).
- **More machines / different user** → change `username` at the top of `home.nix`.

## Notes

- Uses `release-25.05` for both nixpkgs and home-manager → stable, reproducible, no surprise breaks.
- Home-manager manages everything under `~/.config` on these machines. Don't hand-edit those files — change this repo and re-activate.
- Ghostty is installed on the box too; if the remote has a display (VNC, physical), `ghostty` launches with the same theme/font. On headless boxes it just doesn't run — harmless.
