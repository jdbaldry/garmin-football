{ pkgs ? import <nixpkgs>, harfbuzzWithIcu, libjavascriptcoregtk-1, libwebp6 }:

with pkgs;
stdenv.mkDerivation rec {
  pname = "libwebkitgtk-1.0";
  version = "2.4.11";

  src = fetchurl {
    url = "http://ftp.uk.debian.org/debian/pool/main/w/webkitgtk/${pname}-0_${version}-3_amd64.deb";
    sha256 = "sha256-sBGD6fTMPLnxukCcFXAW8fNSXofmekWy2eXbXeUm2uA=";
  };
  unpackCmd = "${dpkg}/bin/dpkg-deb -x $curSrc .";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    enchant1
    harfbuzzWithIcu
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gtk2
    fontconfig.lib
    libsecret
    libsoup
    libwebp6
    libxslt
    pango
    xorg.libXdamage
    xorg.libXrender
    xorg.libXt
  ];

  propagatedBuildInputs = [
    libjavascriptcoregtk-1
  ];

  installPhase = ''
    mkdir -p $out/lib
    cp ./lib/x86_64-linux-gnu/* $out/lib
  '';
}
