{
  description = "nixos-server-config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      host = "timenowaste";
    in
    {
      nixosConfigurations = {
        "${host}" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit host;
          };
          modules = [
            ./hosts/${host}/config.nix
            inputs.disko.nixosModules.disko
          ];
          };
        };
        packages.x86_64-linux = {
          image = self.nixosConfigurations.${host}.config.system.build.diskoImages;
      };
    };
}
