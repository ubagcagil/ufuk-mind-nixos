{
  description = "Ufuk NixOS configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      ufuk-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/hosts/ufuk-desktop.nix
        ];
      };

      ufuk-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/hosts/ufuk-laptop.nix
        ];
      };
    };
  };
}
