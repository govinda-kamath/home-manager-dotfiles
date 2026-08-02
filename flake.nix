{
  description = "gmk dev environment (standalone home-manager)";

  inputs = {
    # Pin to a stable release for reproducibility on remote machines.
    # To update: bump the ref, then run `nix flake update`
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # Read $USER at eval time; falls back to "gmk" in pure mode.
      # Run with `--impure` so this picks up the real login user:
      #   nix run --impure .#homeConfigurations.x86_64-linux.activationPackage
      envUser = builtins.getEnv "USER";
      defaultUsername = "gmk";
      username = if envUser != "" then envUser else defaultUsername;

      mkHome = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./home.nix ];
          # username and system are available to all modules via specialArgs
          extraSpecialArgs = { inherit system username; };
        };
    in
    {
      # NB: define attrs directly — `builtins.listToAttrs` forces the config values
      # eagerly and trips a home-manager eval bug (masked "attribute not provided").
      homeConfigurations = {
        # Preferred: system-only keys work for any username when run with --impure
        "x86_64-linux"  = mkHome "x86_64-linux";
        "aarch64-linux" = mkHome "aarch64-linux";
        # Legacy aliases for backward compatibility
        "gmk-x86_64"  = mkHome "x86_64-linux";
        "gmk-aarch64" = mkHome "aarch64-linux";
      };
    };
}
