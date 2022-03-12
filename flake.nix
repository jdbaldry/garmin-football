{
  description = "garmin-football shell development tooling";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlay =
        (
          final: prev: {
            sdkmanager = prev.callPackage ./sdkmanager.nix { pkgs = prev; };
          }
        );
    } //
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs
          {
            inherit system; overlays = [ self.overlay ];
          };
      in
      {
        defaultPackage = pkgs.sdkmanager;
        devShell = import ./shell.nix { inherit pkgs; };
        packages.sdkmanager = pkgs.sdkmanager;
      }));
}
