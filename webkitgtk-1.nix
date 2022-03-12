{
  # Despite the name webkitgtk-1 is actually webkitgtk-2.4.11 which is the source of libwebkitgtk-1.0.so.0 and libjavascriptcoregtk-1.0.so.0.
  # Adapted from the derivation: https://github.com/NixOS/nixpkgs/blob/72d7f73a641ab71fad0455420c87aa1a9860375d/pkgs/development/libraries/webkitgtk/default.nix.
  webkitgtk-1 =
    stdenv.mkDerivation
      rec
      {
        name = "webkitgtk-2.4.11";

        meta = {
          description = "Web content rendering engine, GTK port";
          homepage = "http://webkitgtk.org/";
          maintainers = [ ];
          license = lib.licenses.bsd2;
          platforms = lib.platforms.linux;

          knownVulnerabilities = [
            # "WSA-2016-0004"
            # "WSA-2016-0005"
            # "WSA-2016-0006"
            # "WSA-2017-0001"
            # "WSA-2017-0002"
          ];
        };

        CC = "cc";
        NIX_CFLAGS_COMPILE = [
          "-DU_NOEXCEPT="
          "-Wno-expansion-to-defined"
        ];

        patches = [
          (fetchpatch {
            url = https://raw.githubusercontent.com/gentoo/gentoo/7c5457e265bd40c156a8fe6b2ff94a4e34bcea8e/net-libs/webkit-gtk/files/webkit-gtk-2.4.9-gcc-6.patch;
            sha256 = "0ll93dr5vxd40wvly1jaw41lvw86krac0jc6k6cacrps4i5ql5j0";
          })
        ];
        src = fetchurl {
          url = "http://webkitgtk.org/releases/${name}.tar.xz";
          sha256 = "sha256-WIrqBRv7rM7Sf9/gM1qVfcqDnr42qlSN85x7uv22W/c=";
        };

        prePatch = ''
          patchShebangs Tools/gtk
        '';

        configureFlags = [
          "--disable-geolocation"
          "--disable-jit"
          # needed for parallel building
          "--enable-dependency-tracking"
          "--with-gtk=2.0"
          "--disable-webkit2"
        ];

        dontAddDisableDepTrack = true;

        nativeBuildInputs = [
          bison
          flex
          gettext
          gobject-introspection
          gperf
          icu
          perl
          pkgconfig
          python
          ruby
          sqlite
          which
        ];

        buildInputs = [
          gobject-introspection
          enchant
          gtk2
          gst_all_1.gstreamer
          gst_all_1.gst-plugins-base
          harfbuzzWithIcu
          libsecret
          libwebp
          libxml2
          libxslt
          xorg.libXdamage
          xorg.libXt
          wayland
        ];

        buildPhase = '''';

        propagatedBuildInputs = [
          gobject-introspection
          gnome.libsoup
          gtk2
        ];

        enableParallelBuilding = true;
      };
}
