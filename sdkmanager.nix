{ pkgs ? import <nixpkgs> }:

with pkgs;
let
  harfbuzzWithIcu = import ./harfbuzz.nix { inherit pkgs; };
  icu57 = import ./icu57.nix { inherit pkgs; };
  libjpeg8 = import ./libjpeg8.nix { inherit pkgs; };
  libwebp6 = import ./libwebp6.nix { inherit pkgs; };
in
let
  libjavascriptcoregtk-1 = import ./libjavascriptcoregtk-1.nix { inherit pkgs icu57; };
in
let
  libwebkitgtk-1 = import ./libwebkitgtk-1.nix { inherit pkgs harfbuzzWithIcu libjavascriptcoregtk-1 libwebp6; };
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
