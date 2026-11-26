{
  description = "rmap: a ledger of roadmap items over SQLite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        knaveVersion = "0.22.0";

        knaveSource = pkgs.fetchCrate {
          pname = "knave";
          version = knaveVersion;
          hash = "sha256-2tR3Z2PYIzOzjZwG5WrRIK1ABjLsAveiffUOHE3rs8c=";
        };

        knave = pkgs.rustPlatform.buildRustPackage {
          pname = "knave";
          version = knaveVersion;
          src = knaveSource;
          cargoLock.lockFile = "${knaveSource}/Cargo.lock";
          doCheck = false;
        };

        ledelintRevision = "67d735e0d9c632fc04508b53d4c42dcd1102e95b";

        ledelintSource = pkgs.fetchgit {
          url = "https://github.com/KarlHarnois/ledelint";
          rev = ledelintRevision;
          hash = "sha256-10RYPOSnMQE826i4NGTInQwSPQ+9rgxtIOBtu3GXOL4=";
        };

        vendoredCrates = pkgs.rustPlatform.importCargoLock {
          lockFile = ./Cargo.lock;
        };

        rmap = pkgs.stdenv.mkDerivation {
          pname = "rmap";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ knave pkgs.cargo pkgs.rustc pkgs.rustfmt ];
          buildPhase = ''
            export HOME=$TMPDIR
            export CARGO_HOME=$TMPDIR/cargo
            mkdir -p $CARGO_HOME
            cat > $CARGO_HOME/config.toml <<CONFIG
            [source.crates-io]
            replace-with = "vendored"

            [source.vendored]
            directory = "${vendoredCrates}"

            [net]
            offline = true
            CONFIG
            export XDG_CACHE_HOME=$TMPDIR/xdg-cache
            mkdir -p "$XDG_CACHE_HOME/knave/git"
            cp -r "${ledelintSource}" "$XDG_CACHE_HOME/knave/git/${ledelintRevision}"
            knave build
          '';
          installPhase = ''
            install -Dm755 target/knave/rmap/rmap $out/bin/rmap
          '';
        };
      in
      {
        packages = {
          default = rmap;
          inherit knave;
        };

        devShells.default = pkgs.mkShell {
          packages = [ knave pkgs.cargo pkgs.rustc pkgs.rustfmt pkgs.git pkgs.sqlite ];
        };
      });
}
