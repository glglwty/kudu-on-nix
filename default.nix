with import ((import <nixpkgs> {}).fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  # nixpkgs master as of 05/26/2018
  rev = "8e426877b5c1ee90741de4683d36b81e47ef0be3";
  sha256 = "0gw21zg2mhnh3h06mnjd6q4zylxswkqr658f2yyqivj8rd46a9wx";
}) {};

let
  bitshuffle-multiarch = stdenv.mkDerivation {
    name = "bitshuffle-multiarch";
    src = fetchFromGitHub {
      owner = "kiyo-masui";
      repo = "bitshuffle";
      rev = "55f9b4caec73fa21d13947cacea1295926781440";
      sha256 = "07v43hb1k31ldm6qk4fvriykc90xzq1l8dkp1ald3fsjs6763i08";
    };
    builder = ./bitshuffle-multiarch-builder.sh;
    buildInputs = [ lz4 ];
  };
  squeasel-lite = stdenv.mkDerivation {
    name = "squeasel-lite";
    src = fetchFromGitHub {
      owner = "cloudera";
      repo = "squeasel";
      rev = "9335b81317a6451d5a37c5dc7ec088eecbf68c82";
     sha256 = "0p6vm30fwir3ammq8yvpcs7iwh0n5z101x74wwbnli111fqb6awl";
    };
    buildInputs = [ openssl ];
    builder = builtins.toFile "builder.sh" ''
      set -e
      . $stdenv/setup
      mkdir -p $out/include $out/lib
      gcc $src/squeasel.c -lssl -fPIC -O3 -shared -o $out/lib/libsqueasel.so
      cp $src/squeasel.h $out/include/
    '';
  };
  cpp-mustache = stdenv.mkDerivation {
    name = "cpp-mustache";
    src = fetchFromGitHub {
      owner = "henryr";
      repo = "cpp-mustache";
      rev = "87a592e8aa04497764c533acd6e887618ca7b8a8";
      sha256 = "0cn9smdf4y9r4nmlhvway9qppd6dqh9zhvx0dc9zxxvpq50zvjc5";
    };
    nativeBuildInputs = [ rapidjson-ancient boost ];
    builder = builtins.toFile "builder.sh" ''
      set -e
      . $stdenv/setup
      mkdir -p $out/include $out/lib
      gcc $src/mustache.cc -fPIC -O3 -shared -o $out/lib/libmustache.so
      cp $src/mustache.h $out/include/
    '';
  };
  nvml = stdenv.mkDerivation {
    name = "nvml";
    src = fetchFromGitHub {
      owner = "pmem";
      repo = "pmdk";
      rev = "1c8cffccc8605f10c7bb3d827f6cd0fd8c39f302";
      sha256 = "13zp2jqw7ifdphvk6miqhgrnfkd81p7jfnjviwfq2nvf2xfiwrng";
    };
    nativeBuildInputs = [ pkgconfig autoconf man ];
    patchPhase = "patchShebangs .";
    installFlags = "prefix=$(out)";
  };
  crcutil = stdenv.mkDerivation {
    name = "crcutil";
    src = fetchFromGitHub {
      owner = "adembo";
      repo = "crcutil";
      rev = "42148a6df6986a257ab21c80f8eca2e54544ac4d";
      sha256 = "13cnz3xdbph5j00kz0z3nhndzbx3cw2syzjfq3bsrp09g8sdq3lm";
    };
    nativeBuildInputs = [ which autoconf automake libtool ];
    patchPhase = "patchShebangs .";
    preConfigure = "./autogen.sh";
  };
  breakpad = stdenv.mkDerivation {
    name = "breakpad";
    src = fetchgit {
      url = https://chromium.googlesource.com/breakpad/breakpad;
      rev = "9eac2058b70615519b2c4d8c6bdbfca1bd079e39";
      sha256 = "1sd2vc87awnlkjfzxjga19rj7ibrkxakdcffz46kgskrh741788p";
    };
    lss = fetchgit {
      url = https://chromium.googlesource.com/linux-syscall-support;
      rev = "3f6478ac95edf86cd3da300c2c0d34a438f5dbeb";
      sha256 = "079mn8fhy2zws1s74qz56p7h5z9dwnxx663bppdl94ylrhzv2rws";
    };
    nativeBuildInputs = [ perl ];
    preConfigure = "cp -r $lss ./src/third_party/lss";
    postInstall = ''
      find $out -type f | xargs grep -l "#include" | \
        xargs perl -p -i -e '@pre = qw(client common google_breakpad processor third_party); for ''$p (@pre) { s{#include "''$p/}{#include "breakpad/''$p/}; }'
    '';
  };
  hadoop = stdenv.mkDerivation {
    name = "hadoop";
    src = fetchTarball {
      url = https://archive.apache.org/dist/hadoop/common/hadoop-2.8.2/hadoop-2.8.2.tar.gz;
      sha256 = "1g1ana3x208xxjy4626fqjix41qzjj0g0x2wg5mj2vlm6klf74b2";
    };
    installPhase = "mkdir -p $out && mv * $out";
  };
  fb303 = stdenv.mkDerivation {
    name = "fb303";
    src = fetchTarball {
      url = http://archive.apache.org/dist/thrift/0.11.0/thrift-0.11.0.tar.gz;
      sha256 = "1p7y7w2h3p566n73cwzg9xpvwgvfsz5p13qdddd5cjldf8ifllgz";
    };
    builder = builtins.toFile "builder.sh" ''
      . $stdenv/setup
      mkdir -p $out/share/fb303/if
      cp $src/contrib/fb303/if/fb303.thrift $out/share/fb303/if
    '';
  };
  hive = stdenv.mkDerivation {
    name = "hive";
    src = fetchTarball {
      url = https://archive.apache.org/dist/hive/hive-2.3.1/apache-hive-2.3.1-bin.tar.gz;
      sha256 = "0lxl33q78kx5lg42qi6mxyh6k8fbhq3mxlrkgwhq7f9n77b5r7p8";
    };
    installPhase = "mkdir -p $out && mv * $out";
  };
  rapidjson-ancient = stdenv.mkDerivation {
    name = "rapidjson-ancient";
    src = fetchurl {
      url = https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/rapidjson/rapidjson-0.11.zip;
      sha256 = "0wzj8rg9hmzvaf035jsr5gg6h7g15hsgfl06iqxralaiaqnfqqf0";
    };
    nativeBuildInputs = [ unzip ];
    installPhase = "mkdir -p $out && mv include $out";
  };
  sparsehash-c11 = stdenv.mkDerivation {
    name = "sparsehash-c11";
    src = fetchFromGitHub {
      owner = "sparsehash";
      repo = "sparsehash-c11";
      rev = "47a55825ca3b35eab1ca22b7ab82b9544e32a9af";
      sha256 = "0shkq324hkjrlmmx2diz76b6hzvrm7k6dyq6kl3aa5qrn9zb48ga";
    };
    installPhase = "mkdir -p $out/include && mv sparsehash $out/include";
  };
  sparsepp = stdenv.mkDerivation {
    name = "sparsepp";
    src = fetchFromGitHub {
      owner = "greg7mdp";
      repo = "sparsepp";
      rev = "824860bb76893d163efbcff330734b9f62eecb17";
      sha256 = "16llag6yrw19mn3cma5896wgds7kpha8fx6mzli6hqxkhly1ps5z";
    };
    installPhase = "mkdir -p $out/include && mv sparsepp $out/include";
  };
  gperftools-patched = gperftools.overrideAttrs(oldAttrs : {
    name = "gperftools-patched";
    nativeBuildInputs = [ perl ];
    patchPhase = ''
      perl -p -i -e 's,base::,tcmalloc::,g' $(find . -name "*.h" -o -name "*.cc")
      perl -p -i -e 's,namespace base,namespace tcmalloc,g' $(find . -name "*.h" -o -name "*.cc")
    '';
  });
in stdenv.mkDerivation rec {
  name = "kudu";
  src = fetchFromGitHub {
    owner = "apache";
    repo = "kudu";
    # kudu master as of 05/26/2018
    rev = "2f61b72ca470eab9ee73f7c445582b50a9435ca7";
    sha256 = "19p2lly27q15dxaqgybcmhhlqyaafdkg264gqqd941rmw7ajm3ib";
  };
  prePatch = "patchShebangs .";
  patches = [ ./0001-Build-kudu-on-nix.patch ];
  # build time dependencies
  nativeBuildInputs = [cmake hadoop hive rapidjson-ancient sparsepp sparsehash-c11 xxd clang_6.cc hostname fb303];
  # Potential runtime dependencies.
  # Build debug info for some packages.
  buildInputs = (map (x : x.overrideAttrs (oldAttrs : {separateDebugInfo = true;}))
    [ curl openssl gflags breakpad krb5Full snappy libev lz4 zlib crcutil gperftools-patched nvml llvm_6 thrift cyrus_sasl glog libunwind])
    # Additional work is required to enable debug symbols in the following packages
    ++ [gmock boost python27Full openjdk protobuf bitshuffle-multiarch squeasel-lite cpp-mustache sparsepp];
  NO_REBUILD_THIRDPARTY = true;
  preConfigure = ''
    cmakeFlags="-DLIBSTDCXX_INCLUDE:PATH=${gcc.cc.outPath}/include/c++/${gcc.cc.version} -DLIBC_INCLUDE:PATH=${glibc.dev.outPath}/include -DKUDU_LINK:STRING=s -DNO_TESTS=1 -DKUDU_GIT_HASH=${src.rev}"
  '';
}
