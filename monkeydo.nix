{ pkgs ? import <nixpkgs> }:

with pkgs;
stdenv.mkDerivation {
  name = "monkeydo";
  version = "4.0.9";

  src = ./sdk;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ gccForLibs ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/{monkeybrains.jar,monkeydo,shell} $out/bin
  '';

  meta = with lib; {
    description = "Garmin IQ monkeydo script patched for NixOS.";
    homepage = "https://developer.garmin.com/connect-iq/sdk";
    license = {
      fullname = "";
      url = "https://developer.garmin.com/connect-iq/sdk/";
    };
  };
}
