{ pkgs ? import <nixpkgs> }:

with pkgs;
let
  libjpeg8 = libjpeg_original.overrideAttrs (oldAttrs: rec {
    name = "libjpeg";
    version = "8d";

    src = fetchurl {
      url = "http://www.ijg.org/files/jpegsrc.v${version}.tar.gz";
      sha256 = "1cz0dy05mgxqdgjf52p54yxpyy95rgl30cnazdrfmw7hfca9n0h0";
    };
  });
  harfbuzzWithIcu = harfbuzz.override {
    withIcu = true;
  };
in
let
  # From: https://github.com/NixOS/nixpkgs/commit/b5485da2cd359a1257a296cba5361a0e52bbe4e0#comments.
  icu57 = stdenv.mkDerivation rec {
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
  };
in
let
  libjavascriptcoregtk-1 = stdenv.mkDerivation rec {
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
  };
  # From: https://github.com/NixOS/nixpkgs/blob/b20284ddd88c812bbce63dd0e1e99d5eb36e2f14/pkgs/development/libraries/libwebp/default.nix
  # Despite the version, this provides libweb.so.6.
  libwebp6 = with lib; stdenv.mkDerivation rec {
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
  };
in
let
  libwebkitgtk-1 = stdenv.mkDerivation rec {
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
  };
in
stdenv.mkDerivation rec {
  pname = "sdkmanager";
  version = "1.0.3";

  src = fetchurl
    {
      url = "https://developer.garmin.com/downloads/connect-iq/sdk-manager/connectiq-sdk-manager-linux.zip";
      sha256 = "52dd93adf5cf03bf8ad8f9e640105829c090b5ed6bb2437490c52ddeb2c26b30";
    };
  unpackPhase = ''
    unzip ${src}
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook
    unzip
  ];
  propagatedBuildInputs = [
    atk
    cairo
    curl
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    glib-networking
    gtk2
    libjpeg8
    libpng
    libsoup
    mozjpeg
    pango
    libjavascriptcoregtk-1
    libwebkitgtk-1
    xorg.libSM
    xorg.libX11
    xorg.libXext
    xorg.libXxf86vm
    zlib
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/
  '';

  meta = with lib;
    {
      description = "Garmin IQ SDK manager.";
      homepage = "https://developer.garmin.com/connect-iq/sdk";
      license = {
        fullname = "";
        url = "https://developer.garmin.com/connect-iq/sdk/";
      };
    };
}
