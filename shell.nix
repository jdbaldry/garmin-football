{ pkgs ? import <nixpkgs> }:

with pkgs;
mkShell {
  buildInputs = [
    cfr
    monkeyc
    monkeydo
    openjdk
    sdkmanager
    simulator
  ];
  shellHook = ''
    export PATH="$PATH":"$(pwd)/bin":"$(pwd)/result/bin"
  '';
}
