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

Run rmap inside a git repository, or pass `--db <path>`. `rmap init` creates the ledger once per repository. For JSON output, pass `--json` or set `RMAP_JSON=1`. `rmap help` lists every command.

### rmap ready

`rmap ready` lists the items that can start now, and what blocks the others. `--roadmap <name>` limits both lists to one roadmap.

`rmap ready --limit <n>` picks up to n ready items that can all start at once:

- It walks the ready items in order and picks each item whose paths conflict with no item already picked.
- It skips each item whose paths conflict with a picked item, and names that picked item.
- Research and design items take no path locks, so it picks them and counts them toward n.
- It stops once it picks n items or reaches the end of the list.

The output holds the picked items, the skipped items, and the blocked items. If n is not a whole number of at least 1, rmap exits with code 2.
