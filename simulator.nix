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
  pname = "simulator";
  version = "4.0.9";

  src = ./sdk;

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook
  ];
  buildInputs = [
    libjpeg8
    libsoup
    libusb
    libwebkitgtk-1
    udev
    xorg.libXxf86vm
  ];

  installPhase = ''
    mkdir -p $out/{bin,share/simulator}
    cp bin/{api.db,simulator} $out/bin
    cp -r share/simulator/* $out/share/simulator
  '';

  meta = with lib;
    {
      description = "Garmin IQ SDK simulator binary patched for NixOS.";
      homepage = "https://developer.garmin.com/connect-iq/sdk";
      license = {
        fullname = "";
        url = "https://developer.garmin.com/connect-iq/sdk/";
      };
    };
}
