{ pkgs ? import <nixpkgs> }:

with pkgs;
with lib;
# From: https://github.com/NixOS/nixpkgs/blob/b20284ddd88c812bbce63dd0e1e99d5eb36e2f14/pkgs/development/libraries/libwebp/default.nix
# Despite the version, this provides libweb.so.6.
stdenv.mkDerivation rec {
  name = "libwebp-${version}";
  version = "0.5.2";

  src = fetchurl {
    url = "http://downloads.webmproject.org/releases/webp/${name}.tar.gz";
    sha256 = "sha256-t1MQyBCz7aIix39tbCawYSQOPZBgCV3kSywbrikeze8=";
  };

  meta = {
    description = "Tools and library for the WebP image format";
    homepage = https://developers.google.com/speed/webp/;
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
