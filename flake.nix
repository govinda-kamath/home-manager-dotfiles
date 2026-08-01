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
      # Both x86_64 (most VPS/cloud boxes) and aarch64 (ARM boxes like Hetzner ARM)
      mkHome = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./home.nix ];
          # Make `system` available to modules for hostname/arch-conditional config
          extraSpecialArgs = { inherit system; };
        };
    in
    {
      # NB: define attrs directly — `builtins.listToAttrs` forces the config values
      # eagerly and trips a home-manager eval bug (masked "attribute not provided").
      homeConfigurations = {
        "gmk-x86_64" = mkHome "x86_64-linux";
        "gmk-aarch64" = mkHome "aarch64-linux";
      };
    };
}
