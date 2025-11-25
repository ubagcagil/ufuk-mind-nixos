{
  description = "Ufuk NixOS configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      ufuk-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/ufuk-desktop.nix
        ];
      };

      # TODO: ufuk-laptop:
      # Buraya daha sonra laptop donanım modülü ile ikinci profil gelecek.
      # ufuk-laptop = nixpkgs.lib.nixosSystem { ... };
    };
  };
}
