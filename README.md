# rmap

rmap is a CLI that tracks roadmap items in a SQLite ledger and shows which are ready to start.

## Install

Enable [flakes](https://nixos.wiki/wiki/Flakes) in [Nix](https://nixos.org/download/), then run:

```sh
nix profile add github:KarlHarnois/rmap
```

Without Nix, install [Rust](https://rustup.rs) and [knave](https://crates.io/crates/knave) 0.20.1, then run `knave build`. The build writes the binary to `target/knave/rmap/rmap`.

## Use

```sh
rmap init
rmap new website --manager me
rmap item add --roadmap website --title "Add the parser" --kind build --paths 'src/parser/**'
rmap ready
```
