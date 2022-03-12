{ pkgs ? import <nixpkgs> }:

with pkgs;
stdenv.mkDerivation {
  name = "monkeyc";
  version = "4.0.9";

  src = ./sdk;

  installPhase = ''
    mkdir -p $out/bin
    touch $out/bin/default.jungle
    cp bin/{api.mir,monkeybrains.jar,monkeyc} $out/bin
  '';

  meta = with lib; {
    description = "Garmin IQ SDK simulator binary patched for NixOS.";
    homepage = "https://developer.garmin.com/connect-iq/sdk";
    license = {
      fullname = "";
      url = "https://developer.garmin.com/connect-iq/sdk/";
    };
  };
}
