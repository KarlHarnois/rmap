# rmap

rmap is a CLI that tracks roadmap items in a SQLite ledger and shows which are ready to start.

## Install

Install with [Nix](https://nixos.org/download/):

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

Run rmap inside a git repository, or pass `--db <path>`. `rmap init` creates the ledger once per repository. For JSON output, pass `--json` or set `RMAP_JSON=1`. `rmap help` lists every command.
