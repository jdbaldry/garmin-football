{ pkgs ? import <nixpkgs>, icu57 }:

with pkgs;
stdenv.mkDerivation rec {
  pname = "libjavascriptcoregtk-1.0";
  version = "2.4.11";

  src = fetchurl {
    url = "http://ftp.uk.debian.org/debian/pool/main/w/webkitgtk/${pname}-0_${version}-3_amd64.deb";
    sha256 = "sha256-g0jiJhfeZ/SnlGyixtT2c51I3+lsTN17lHzaPrjKcDw=";
  };
  unpackCmd = "${dpkg}/bin/dpkg-deb -x $curSrc .";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    enchant1
    gobject-introspection
    zlib
  ];

  propagatedBuildInputs = [
    icu57
  ];

  installPhase = ''
    mkdir -p $out/lib
    cp ./lib/x86_64-linux-gnu/* $out/lib
  '';
}
