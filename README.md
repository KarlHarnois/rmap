# rmap

rmap is a CLI that tracks roadmap items in a SQLite ledger and shows which are ready to start.

## Install

Enable [flakes](https://nixos.wiki/wiki/Flakes) in [Nix](https://nixos.org/download/), then run:

```sh
nix profile add github:KarlHarnois/rmap
```

Without Nix, install [Rust](https://rustup.rs) and [knave](https://crates.io/crates/knave) 0.20.1, then run `knave build`. The build writes the binary to `target/knave/rmap/rmap`.

## Usage

```text
Usage: rmap [--db <path>] [--actor <name>] [--json] [--help] <command> <operands> [--<flag> <value>]

Commands:
  help
    Prints this help.
  init
    Creates the ledger for this repository, as ledger.db in its git directory. Pass --db to keep it elsewhere, and pass the same --db to every command.
  new <name> --manager <session>
    Creates a roadmap that a manager session runs.
  list
    Lists the roadmaps.
  ready [--roadmap <name>] [--limit <whole number, at least 1>]
    Lists the items that can start, and what holds back the others. With --limit, picks up to that many ready items whose paths do not conflict, and lists the ones it skipped.
  next [--roadmap <name>] [--manager <session>]
    Lists the next action for each open item and who takes it. A manager with no roadmaps gives an empty list, not an error.
  log [--item <id>] [--since <event id>]
    Prints the events, for one item or after one event id when given.
  item add --roadmap <name> --title <text> --kind epic|research|design|build [--parent <epic id>] [--after <ids, comma-separated>] [--paths <globs, comma-separated>] [--from <id>] [--origin planned|user-bug|follow-up] [--priority <whole number>]
    Adds an item to a roadmap.
  item list [--roadmap <name>]
    Lists the items.
  item show <id>
    Shows one item with its dependencies and paths.
  item claim <id> --session <name>
    Gives a ready item to a session and marks it dispatched.
  item advance <id> <open|dispatched|reported|in_review|fixing|merging|merged|accepted|dropped> [--kind build] [--paths <globs, comma-separated>]
    Moves an item to another status.
  item close <id>
    Marks a build merged, or a reported research or design item accepted.
  item drop <id> --reason <text>
    Drops an item and records the reason.
  dep add <item> <on>
    Makes an item come after another.
  dep rm <item> <on>
    Removes the dependency between two items.
  graph [--roadmap <name>] [--all] [--level item|epic|roadmap] [--format mermaid]
    Prints the roadmaps, their items and dependencies as a Mermaid flowchart. Merged items show only with --all. --level epic or roadmap draws one node per epic or roadmap.

Environment:
  RMAP_JSON   Set to 1 to print JSON, as --json does.
  RMAP_ACTOR  Names the actor when --actor is not given.
  USER        Names the actor when neither --actor nor RMAP_ACTOR is given.

Exit codes:
  0  The command ran.
  1  The ledger refused the command. The error holds a code and a message.
  2  The call is incomplete. The error has the code usage when the arguments match no command, no-repository when no --db was given outside a git repository, or no-ledger when no ledger exists at the path yet.
  3  The database could not be opened, read or written. The error has the code busy when the wait for the lock timed out, ledger-too-new when a newer rmap migrated the ledger, otherwise database.

Refusal codes:
  roadmap-not-found        No roadmap has that name.
  roadmap-exists           A roadmap already has that name.
  item-not-found           No item has that id.
  parent-not-epic          The parent is not an epic.
  parent-in-other-roadmap  The parent belongs to another roadmap.
  epic-has-parent          An epic cannot have a parent.
  build-needs-paths        A build needs at least one path.
  epic-status-computed     An epic's status comes from its children, so no command moves it.
  invalid-kind-change      Only an advance to dispatched can turn an item into a build.
  invalid-transition       The transition table has no such move for this item.
  not-ready                The item is blocked or path-conflicted. The error lists blockers, dropped_blockers and path_conflicts.
  path-conflict            The build's paths conflict with an active build. The error lists path_conflicts.
  cycle                    The dependency would close a cycle of blocks dependencies.
  dep-exists               The blocks dependency already exists.
  dep-not-found            No such blocks dependency exists.
```
