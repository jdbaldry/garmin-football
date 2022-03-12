{ pkgs ? import <nixpkgs> }:

with pkgs;
libjpeg_original.overrideAttrs (oldAttrs: rec {
  name = "libjpeg";
  version = "8d";

  src = fetchurl {
    url = "http://www.ijg.org/files/jpegsrc.v${version}.tar.gz";
    sha256 = "1cz0dy05mgxqdgjf52p54yxpyy95rgl30cnazdrfmw7hfca9n0h0";
  };
})
