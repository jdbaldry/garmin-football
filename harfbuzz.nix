{ pkgs ? import <nixpkgs> }:

with pkgs;
harfbuzz.override {
  withIcu = true;
}
