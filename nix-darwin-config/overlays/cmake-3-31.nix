# overlays/cmake-3-26.nix
final: prev: {
  cmake = prev.cmake.overrideAttrs (old: rec {
    version = "3.31.6";
    src = prev.fetchurl {
      url = "https://cmake.org/files/v3.26/cmake-${version}.tar.gz";
      sha256 = "1w2mkvfjvqlcnz7hh6595irnq3565bxjf9zjzym50iq1ypq2fd35";
    };
  });
}
