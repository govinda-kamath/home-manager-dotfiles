# gmk-nix-env

Portable dev environment via [home-manager](https://github.com/nix-community/home-manager), built for **non-NixOS Linux** (Ubuntu etc.) remote machines.

## What you get

| Area | Content |
|---|---|
| Shell | zsh with autocompletion, autosuggestions, syntax highlighting, dedup'd history, git branch + conda env in prompt |
| Languages | Python (python3 + uv + ruff + pyright), Rust (cargo/rustc/rust-analyzer/rustfmt/clippy), Go (go + gopls + delve) |
| Editor | Neovim: LSP for py/rust/go, nvim-cmp completion, telescope, neo-tree, treesitter, catppuccin-mocha |
| Terminal | Ghostty (catppuccin-mocha theme, JetBrains Mono Nerd Font), byobu (manual start) |
| Conda | micromamba with base auto-activated; `micromamba activate <env>` for project envs |
| Git | delta pager, aliases, identity prompted on first activation (stored in `~/.gitconfig.local`) |
| SSH | ed25519 key auto-generated on first activation; SSH config wired for GitHub |
| Tools | ripgrep, fd, bat, eza, lazygit, gh, just, dust, ncdu, mosh, direnv, curl, wget, jq, htop |

## Layout

```text
flake.nix            # pinned nixpkgs + home-manager (release-25.05), builds for x86_64 & aarch64
home.nix             # imports modules; username injected from $USER at eval time
modules/
  shell.nix          # zsh, direnv, prompt (git branch + conda env)
  dev.nix            # python / rust / go toolchains
  nvim.nix           # neovim (LSP, completion, telescope, treesitter)
  ghostty.nix        # ghostty + font + xterm-ghostty terminfo fix
  git.nix            # git config + delta pager; identity via ~/.gitconfig.local
  ssh.nix            # SSH key generation + GitHub host config
  byobu.nix          # byobu (installed; start manually with `byobu`)
  conda.nix          # micromamba + base env auto-activation
hosts/<hostname>.nix # optional per-machine overrides (loaded if HOSTNAME matches)
```

## Setup on a fresh remote machine (Ubuntu etc.)

**1. Ensure nix is available.** If already installed (e.g. on a shared/managed box), source its profile so it's on PATH — otherwise install it.

```bash
NIX_PROFILE=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
if [ -f "$NIX_PROFILE" ]; then
  . "$NIX_PROFILE"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
```

> With the official (non-Determinate) installer, also enable flakes:
> `echo 'experimental-features = nix-command flakes' | sudo tee /etc/nix/nix.conf`

**2. Clone this repo.**

```bash
git clone git@github.com:govinda-kamath/home-manager-dotfiles.git ~/home-manager-dotfiles
cd ~/home-manager-dotfiles
```

**3. Activate.** `--impure` lets nix read `$USER` so the config matches your login name. Pick the arch matching `uname -m`.

```bash
nix run --impure .#homeConfigurations.x86_64-linux.activationPackage
# ARM box:
# nix run --impure .#homeConfigurations.aarch64-linux.activationPackage
```

On first activation you will be prompted for git name/email (saved to `~/.gitconfig.local`) and an SSH key will be generated — add the printed public key to GitHub under Settings → SSH and GPG keys.

**4. Start your configured shell.**

```bash
exec zsh
```

> **No sudo?** If you can't run `chsh` (managed/shared boxes), skip it — home-manager already configures bash to `exec zsh` automatically for every new interactive session. You'll land in zsh on your next login without any manual steps.

**6. Initialise micromamba (one-time per machine).**

```bash
micromamba create -n base python
```

### Updating later

```bash
cd ~/home-manager-dotfiles
nix flake update        # bump pinned inputs to latest release-25.05
nix run --impure .#homeConfigurations.x86_64-linux.activationPackage
```

## Customizing

- **Git identity** → prompted automatically on first activation; re-edit `~/.gitconfig.local` any time.
- **Machine-specific values** → create `hosts/<hostname>.nix` (use `hostname` to find the name). It's auto-imported on that machine only. Example:

  ```nix
  { pkgs, ... }: {
    home.packages = [ pkgs.some-work-tool ];
  }
  ```

- **Adding tools** → add to `home.packages` in `home.nix` or `modules/dev.nix`.
- **Different username** → the flake reads `$USER` automatically when run with `--impure`. No edits needed.
- **Byobu** → not auto-started; run `byobu` manually. Sessions persist across SSH disconnects.

## Notes

- Uses `release-25.05` for both nixpkgs and home-manager → stable, reproducible, no surprise breaks.
- Home-manager manages `~/.zshrc`, `~/.bashrc`, and everything under `~/.config` as read-only symlinks into the Nix store. Don't hand-edit those files — change this repo and re-activate. To add to `$PATH`, use `home.sessionPath` in `home.nix`.
- `TERMINFO_DIRS` is set so terminals like Ghostty (`xterm-ghostty`) work correctly over SSH without the remote needing Ghostty installed system-wide.
- Ghostty is installed on the box too; if the remote has a display (VNC, physical), `ghostty` launches with the same theme/font. On headless boxes it just doesn't run — harmless.
- `~/.gitconfig.local` and `hosts/` are gitignored — safe to store machine-specific or personal config there.
