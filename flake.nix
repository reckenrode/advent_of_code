{
  description = "Advent of Code solutions";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs?ref=release-23.11";

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          dotnet = pkgs.mkShell {
            packages = [ pkgs.dotnet-sdk_8 ];
          };
        }
      );
    };
}
