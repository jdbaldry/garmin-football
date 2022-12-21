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
let
  buildInputs = [
    atk
    cairo
    curl
    expat
    fontconfig
    freetype
    gdk-pixbuf
    gccForLibs
    glib
    glib-networking
    gtk2
    libjavascriptcoregtk-1
    libjpeg8
    libpng
    libsoup
    libusb
    libwebkitgtk-1
    mozjpeg
    pango
    udev
    xorg.libSM
    xorg.libX11
    xorg.libXext
    xorg.libXxf86vm
    zlib
  ];
in
let
  LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
in
mkShell {
  packages = [
    cfr

    go_1_19
    gopls
    golangci-lint
    gotools

    jmtpfs
    monkeyc
    monkeydo
    openjdk
    patchelf
    # sdkmanager
    simulator
  ];
  inputsFrom = buildInputs;
  # Dynamic libraries expected by the simulator.
  shellHook = ''
    export PATH="$PATH":"$(pwd)/bin":"$(pwd)/result/bin"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":${LD_LIBRARY_PATH}
  '';
}
