# Per-host overrides

Create a file named `<hostname>.nix` here (check with `hostname`) to apply
machine-specific settings. It is auto-imported by `home.nix` on that machine
only.

Example `web1.example.com.nix`:

```nix
{ ... }: {
  programs.git.userName = "govinda";
  programs.git.userEmail = "govinda@example.com";
  home.packages = [ pkgs.docker-compose ];
}
```

Example `devbox.nix`:

```nix
{ ... }: {
  home.username = "deploy";
  home.homeDirectory = "/home/deploy";
  programs.zsh.shellAliases.deploy = "ssh deploy@prod";
}
```

See the README at the repo root for more.
