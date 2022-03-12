{ pkgs ? import <nixpkgs> }:

with pkgs;
mkShell {
  buildInputs = [ openjdk glib-networking ];
  shellHook = ''
    export PATH="$PATH":"$(pwd)/bin":"$(pwd)/result/bin"
  '';
}
