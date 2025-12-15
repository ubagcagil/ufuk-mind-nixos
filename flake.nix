{
  description = "ufuk-mind-nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      mkHost = hostPath: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ hostPath ];
      };
    in
    {
      nixosConfigurations = {
        ufuk-desktop = mkHost ./nixos/hosts/ufuk-desktop;
        ufuk-laptop  = mkHost ./nixos/hosts/ufuk-laptop;
      };
    };
}
