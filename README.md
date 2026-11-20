# rmap

rmap is a ledger for roadmaps. It keeps roadmaps, items, dependencies and the paths each build changes in one SQLite database. It works out which items are ready to start. It refuses each change that breaks the rules of the ledger.

## Install with Nix

Install [Nix](https://nixos.org/download/) with [flakes](https://nixos.wiki/wiki/Flakes) enabled, then run:

```sh
nix profile add github:KarlHarnois/rmap
```

To upgrade to the latest `main`, run `nix profile upgrade rmap`.

## Install without Nix

1. Install the Rust toolchain with [rustup](https://rustup.rs).
2. Install [knave](https://crates.io/crates/knave) 0.20.1:

   ```sh
   cargo install knave --version 0.20.1 --locked
   ```

3. Build rmap:

   ```sh
   git clone https://github.com/KarlHarnois/rmap.git
   cd rmap
   knave build
   ```

4. Copy the binary to a directory on your `PATH`:

   ```sh
   install -Dm755 target/knave/rmap/rmap ~/.local/bin/rmap
   ```

   If your shell then reports `rmap: command not found`, add `~/.local/bin` to your `PATH`.

## Use

Run `rmap` inside a git repository. rmap keeps the ledger in `ledger.db` in the git directory of the repository. Every worktree of the repository shares that ledger. If you run rmap outside a git repository, pass `--db <path>`.

```sh
rmap new website --manager me
rmap item add --roadmap website --title "Add the parser" --kind build --paths 'src/parser/**'
rmap ready
```

`rmap help` lists every command and flag, the exit codes and the refusal codes.

## Output

rmap prints text by default. For scripts and agents, pass `--json` or set `RMAP_JSON=1`. The JSON output carries `"schema_version": 1`, and the exit codes are the same in both formats.

## Develop

`nix develop` opens a shell with knave and the Rust toolchain. Before you push, run:

```sh
knave fmt --check
knave lint
knave test
```
