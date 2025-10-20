

{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    system = "aarch64-darwin";
    overlays = import ./overlays;  # 👈 new: import your overlays folder
    pkgs = import nixpkgs {
      inherit system overlays;     # 👈 pass overlays to nixpkgs
    };
    configuration = { ... }: {
      security.pam.services.sudo_local.touchIdAuth = true;  # Replace sudo with fingerprint
      system.primaryUser = "rpetraglia";

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
        ];
      homebrew = {
          enable = true;
          onActivation.cleanup = "uninstall";

          taps = [
              # `brew tap` with custom Git URL and arguments
              {
                name = "mm/homebrew-tools";
                clone_target = "ssh://git@gitlab.meteomatics.com:2222/SYSTEM/homebrew-tools.git";
                force_auto_update = true;
              }
          ];
          brews = [
           #"cmake@3"
           "abseil"
           "allure"
           "aom"
           "argocd"
           "arping"
           "assimp"
           "autoconf"
           "automake"
           "awk"
           "bash"
           "bash-completion"
           "bat"
           "bdw-gc"
           "bison"
           "brotli"
           "btop"
           "c-ares"
           "ca-certificates"
           "cairo"
           "certifi"
           "chruby"
           "clang-format"
           "coreutils"
           "curl"
           "dav1d"
           "dbus"
           "diffutils"
           "docker"
           "docker-completion"
           "double-conversion"
           "dwarfutils"
           "emacs-plus@29"
           "exiftool"
           "fd"
           "findutils"
           "flock"
           "fontconfig"
           "freetype"
           "fribidi"
           "fzf"
           "gawk"
           "gcc"
           "gcc@12"
           "gd"
           "gdk-pixbuf"
           "gettext"
           "ghostscript"
           "giflib"
           "git"
           "git-filter-repo"
           "gitlab-ci-local"
           "glib"
           "gmp"
           "gnu-getopt"
           "gnu-indent"
           "gnu-sed"
           "gnu-tar"
           "gnupg"
           "gnuplot"
           "gnutls"
           "go"
           "graphite2"
           "graphviz"
           "grep"
           "gts"
           "gumbo-parser"
           "gzip"
           "harfbuzz"
           "hdf5"
           "helm"
           "highway"
           "htop"
           "hunspell"
           "hwloc"
           "icu4c@75"
           "icu4c@76"
           "icu4c@77"
           "imagemagick"
           "imagemagick@6"
           "imath"
           "iperf"
           "isl"
           "jansson"
           "jasper"
           "jbig2dec"
           "jinja2-cli"
           "jmeter"
           "jpeg-turbo"
           "jpeg-xl"
           "jq"
           "k9s"
           "krb5"
           "kubeconform"
           "kubernetes-cli"
           "lazydocker"
           "lazygit"
           "leptonica"
           "libaec"
           "libarchive"
           "libassuan"
           "libavif"
           "libb2"
           "libcerf"
           "libde265"
           "libdeflate"
           "libev"
           "libevent"
           "libffi"
           "libgcrypt"
           "libgit2"
           "libgpg-error"
           "libheif"
           "libidn"
           "libidn2"
           "libksba"
           "liblqr"
           "libmng"
           "libmpc"
           "libnet"
           "libnghttp2"
           "libnghttp3"
           "libngtcp2"
           "libnotify"
           "libomp"
           "libpng"
           "libpq"
           "libraw"
           "librsvg"
           "libssh2"
           "libtasn1"
           "libtiff"
           "libtool"
           "libunistring"
           "libusb"
           "libuv"
           "libvmaf"
           "libx11"
           "libxau"
           "libxcb"
           "libxdmcp"
           "libxext"
           "libxrender"
           "libyaml"
           "libzip"
           "litehtml"
           "little-cms2"
           "lua"
           "lz4"
           "lzo"
           "m4"
           "make"
           "md4c"
           "midnight-commander"
           "mpdecimal"
           "mpfr"
           "mypy"
           "ncdu"
           "ncurses"
           "netcdf"
           "netpbm"
           "nettle"
           "ninja"
           "node"
           "nomad"
           "npth"
           "oniguruma"
           "open-mpi"
           "openexr"
           "openjdk"
           "openjdk@11"
           "openjdk@21"
           "openjpeg"
           "openjph"
           "openssl@3"
           "p11-kit"
           "pandoc"
           "pango"
           "parallel"
           "pcre"
           "pcre2"
           "pinentry"
           "pixman"
           "pkgconf"
           "pmix"
           "popt"
           "protobuf"
           "pv"
           "python-packaging"
           "python-yq"
           "python@3.12"
           "python@3.13"
           "python@3.14"
           "qt"
           "qt3d"
           "qt5compat"
           "qtbase"
           "qtcharts"
           "qtconnectivity"
           "qtdatavis3d"
           "qtdeclarative"
           "qtgraphs"
           "qtgrpc"
           "qthttpserver"
           "qtimageformats"
           "qtlanguageserver"
           "qtlocation"
           "qtlottie"
           "qtmultimedia"
           "qtnetworkauth"
           "qtpositioning"
           "qtquick3d"
           "qtquick3dphysics"
           "qtquickeffectmaker"
           "qtquicktimeline"
           "qtremoteobjects"
           "qtscxml"
           "qtsensors"
           "qtserialbus"
           "qtserialport"
           "qtshadertools"
           "qtspeech"
           "qtsvg"
           "qttools"
           "qttranslations"
           "qtvirtualkeyboard"
           "qtwebchannel"
           "qtwebengine"
           "qtwebsockets"
           "qtwebview"
           "readline"
           "ripgrep"
           "rsync"
           "rtmpdump"
           "ruby-install"
           "ruff"
           "s-lang"
           "semgrep"
           "shared-mime-info"
           "shellcheck"
           "simdjson"
           "sipcalc"
           "sqlite"
           "switchaudio-osx"
           "telnet"
           "tesseract"
           "texinfo"
           "the_silver_searcher"
           "tldr"
           "tree"
           "tree-sitter"
           "unbound"
           "uv"
           "uvwasi"
           "w3m"
           "watch"
           "webp"
           "wget"
           "wireguard-go"
           "wireguard-tools"
           "x265"
           "xcodes"
           "xorgproto"
           "xxhash"
           "xz"
           "zoxide"
           "zstd"];
          casks = ["1password-cli"
                   "dbeaver-community"
                   "docker-desktop"
                   "drawio"
                   "ghostty"
                   "hammerspoon"
                   "openscad"
                   "raspberry-pi-imager"
                   "xquartz"];
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."RPE-0384" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
      specialArgs = { inherit pkgs; };  # 👈 pass pkgs with overlays to modules
    };
  };
}
