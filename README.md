# rmap

rmap is a CLI that tracks roadmap items in a SQLite ledger and shows which are ready to start.

## Install

Enable [flakes](https://nixos.wiki/wiki/Flakes) in [Nix](https://nixos.org/download/), then run:

```sh
nix profile add github:KarlHarnois/rmap
```

Without Nix, install [Rust](https://rustup.rs) and [knave](https://crates.io/crates/knave) 0.21.0, then run `knave build`. The build writes the binary to `target/knave/rmap/rmap`.

## Develop

Run these checks before you push:

```sh
knave check
knave fmt --check
knave lint
for task in tasks/*.knv; do knave lint "$task"; done
knave task ledelint
knave test
```

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
    Lists the items that can start, and what holds back the others. With --limit, picks up to that many ready items.
  next [--roadmap <name>] [--manager <session>]
    Lists the next action for each open item and who takes it. A manager with no roadmaps gives an empty list, not an error.
  log [--item <id>] [--decision <id>] [--since <event id>]
    Prints the events, for one item, for one decision or after one event id when given.
  item add --roadmap <name> --title <text> [--description <text>] [--description-file <path|->] --kind epic|research|design|build [--parent <epic id>] [--after <ids, comma-separated>] [--from <id>] [--origin planned|user-bug|follow-up] [--priority <0 (highest) to 4 (lowest), default 2>]
    Adds an item to a roadmap.
  item list [--roadmap <name>]
    Lists the items.
  item show <id>
    Shows one item with its dependencies.
  item edit <id> [--title <text>] [--priority <0 (highest) to 4 (lowest)>] [--description <text>] [--description-file <path|->]
    Changes an item's title, priority or description. Give at least one of the flags, and only while the item is open.
  item claim <id> --session <name> [--branch <name>] [--base <branch>]
    Gives a ready item to a new session and marks it dispatched. The branch defaults to the session name and the base to the repository's default branch.
  item advance <id> <open|dispatched|reported|in_review|fixing|merging|merged|accepted|dropped> [--kind build]
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
  pause <name>
    Pauses a roadmap: its open items wait, while work already started continues.
  resume <name>
    Resumes a paused roadmap.
  decision propose --roadmap <name> --file <path|-> [--item <id>] [--blocks <ids, comma-separated>] [--supersedes <decision id>]
    Proposes a decision for the owner to settle, read from the JSON document in --file (- reads stdin). It needs at least 2 options. description, pros and cons may be left out, and keys the document shape does not list are ignored. --item names the item that raised it, --blocks the open items or unfinished epics of its roadmap that wait on it, --supersedes the decision it would replace: accepted, or rejected in the same roadmap.
    Document:
      {
        "context": "<text>",
        "options": [
          {
            "cons": [
              "<text>"
            ],
            "description": "<text, may be left out>",
            "pros": [
              "<text>"
            ],
            "title": "<text>"
          }
        ],
        "recommendation": {
          "option": 1,
          "reason": "<text>"
        },
        "title": "<text>"
      }
  decision revise <id> --file <path|-> [--supersedes <decision id>]
    Replaces the title, context, options and recommendation of a proposed decision with the JSON document in --file (- reads stdin), the same shape propose takes, and clears when it was asked. The output of `decision show --json` is accepted as is. --supersedes retargets the decision it would replace, under the same rule.
    Document:
      {
        "context": "<text>",
        "options": [
          {
            "cons": [
              "<text>"
            ],
            "description": "<text, may be left out>",
            "pros": [
              "<text>"
            ],
            "title": "<text>"
          }
        ],
        "recommendation": {
          "option": 1,
          "reason": "<text>"
        },
        "title": "<text>"
      }
  decision show <id>
    Shows one decision with its options, recommendation and outcome.
  decision list [--roadmap <name>] [--status proposed|accepted|rejected|deprecated|superseded] [--item <id>]
    Lists the decisions in every status, oldest first. --item keeps those the item raised or that block it.

Environment:
  RMAP_JSON   Set to 1 to print JSON, as --json does.
  RMAP_ACTOR  Names the actor when --actor is not given.
  USER        Names the actor when neither --actor nor RMAP_ACTOR is given.

Exit codes:
  0  The command ran.
  1  The ledger refused the command. The error holds a code and a message.
  2  The call cannot be completed. The error has the code usage when the arguments match no command or a decision's --file cannot be read or holds no proposal, no-repository when no --db was given outside a git repository, no-ledger when no ledger exists at the path yet, or description-unreadable when a --description-file or stdin read fails.
  3  The database could not be opened, read or written. The error has the code busy when the wait for the lock timed out, ledger-too-new when a newer rmap migrated the ledger, otherwise database.

Refusal codes:
  roadmap-not-found              No roadmap has that name.
  roadmap-exists                 A roadmap already has that name.
  roadmap-already-paused         A pause changes nothing: the roadmap is already paused.
  roadmap-not-paused             A resume changes nothing: the roadmap is not paused.
  item-not-found                 No item has that id.
  item-closed                    A merged, accepted or dropped item cannot be edited.
  parent-not-epic                The parent is not an epic.
  parent-in-other-roadmap        The parent belongs to another roadmap.
  epic-has-parent                An epic cannot have a parent.
  priority-out-of-range          A priority must be from 0 (highest) to 4 (lowest).
  epic-status-computed           An epic's status comes from its children, so no command moves it.
  invalid-kind-change            Only an advance to dispatched can turn an item into a build.
  invalid-transition             The transition table has no such move for this item.
  not-ready                      The item is blocked. The error lists whether the roadmap is paused, its blockers and its dropped_blockers.
  cycle                          The dependency would close a cycle of blocks dependencies.
  dep-exists                     The blocks dependency already exists.
  dep-not-found                  No such blocks dependency exists.
  decision-not-found             No decision has that id.
  decision-frozen                Only a proposed decision can change.
  decision-incomplete            A proposal needs a title, a context, at least 2 options with titles, and a recommendation that names one of them with a reason.
  not-blockable                  Only an open item or an unfinished epic can wait on a decision.
  decision-in-other-roadmap      The item belongs to another roadmap than the decision.
  supersede-target-not-accepted  Only a decision that is accepted, or rejected in the same roadmap, can be superseded.
  session-busy                   A live session already has that name.
```
