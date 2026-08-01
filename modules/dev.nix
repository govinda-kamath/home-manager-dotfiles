{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ── Python ─────────────────────────────────────────────────────────────
    python3 # python3 with pip bundled (nixpkgs default)
    uv # fast, modern package manager / venv / interpreter manager
    ruff # fast Python linter + formatter
    pyright # Python LSP for editors

    # ── Rust ───────────────────────────────────────────────────────────────
    cargo
    rustc
    rust-analyzer # LSP
    rustfmt
    clippy # lints

    # ── Go ─────────────────────────────────────────────────────────────────
    go
    gopls # LSP
    delve # debugger

    # ── Search / misc ──────────────────────────────────────────────────────
    ripgrep # `rg`, fast grep replacement
    fd # `fd`, fast find replacement (plays nicely with ripgrep)
  ];
}
