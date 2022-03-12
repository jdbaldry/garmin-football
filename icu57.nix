{ pkgs ? import <nixpkgs> }:

with pkgs;
# From: https://github.com/NixOS/nixpkgs/commit/b5485da2cd359a1257a296cba5361a0e52bbe4e0#comments.
stdenv.mkDerivation rec {
  pname = "icu4c";
  version = "57.1";

  src = fetchurl {
    url = "http://download.icu-project.org/files/${pname}/${version}/${pname}-"
      + (lib.replaceChars [ "." ] [ "_" ] version) + "-src.tgz";
    sha256 = "10cmkqigxh9f73y7q3p991q6j8pph0mrydgj11w1x6wlcp5ng37z";
  };

  outputs = [ "out" "dev" ];
  outputBin = "dev";

  postUnpack = ''
    sourceRoot=''${sourceRoot}/source
    echo Source root reset to ''${sourceRoot}
  '';

  preConfigure = ''
    sed -i -e "s|/bin/sh|${stdenv.shell}|" configure
  '';

  configureFlags = "--disable-debug" +
    lib.optionalString (stdenv.isFreeBSD || stdenv.isDarwin) " --enable-rpath";

  # remove dependency on bootstrap-tools in early stdenv build
  postInstall = lib.optionalString stdenv.isDarwin ''
    sed -i 's/INSTALL_CMD=.*install/INSTALL_CMD=install/' $out/lib/icu/${version}/pkgdata.inc
  '';

  postFixup = ''moveToOutput lib/icu "$dev" '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Unicode and globalization support library";
    homepage = http://site.icu-project.org/;
    platforms = platforms.all;
  };
}
