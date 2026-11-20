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

        knaveVersion = "0.20.1";

        knaveSource = pkgs.fetchCrate {
          pname = "knave";
          version = knaveVersion;
          hash = "sha256-UzTWXclIIyrwhH4GQux8fwXHqJ4vAfQWLFcNWq5fR2w=";
        };

        knave = pkgs.rustPlatform.buildRustPackage {
          pname = "knave";
          version = knaveVersion;
          src = knaveSource;
          cargoLock.lockFile = "${knaveSource}/Cargo.lock";
          doCheck = false;
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
