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
    Lists the next action for each open item and proposed decision, and who takes it: an agent asks an unanswered decision, the user answers an asked one, and a rejected decision that holds an item sends it back for a replan. A manager with no roadmaps gives an empty list, not an error.
  log [--item <id>] [--decision <id>] [--since <event id>]
    Prints the events, for one item, for one decision or after one event id when given.
  item add --roadmap <name> --title <text> [--description <text>] [--description-file <path|->] [--criterion <text>] [--criteria-file <path|->] --kind epic|research|design|build [--parent <epic id>] [--after <ids, comma-separated>] [--from <id>] [--origin planned|user-bug|follow-up] [--priority <0 (highest) to 4 (lowest), default 2>]
    Adds an item to a roadmap. Every item needs a description and at least one acceptance criterion, for example "WHEN I run item show, rmap SHALL print the acceptance criteria." Repeat --criterion for each one, or read one per non-blank line from --criteria-file.
  item list [--roadmap <name>]
    Lists the items.
  item show <id>
    Shows one item with its dependencies.
  item edit <id> [--title <text>] [--priority <0 (highest) to 4 (lowest)>] [--description <text>] [--description-file <path|->] [--criterion <text>] [--criteria-file <path|->]
    Changes an item's title, priority, description or acceptance criteria. Give at least one of the flags. --criterion and --criteria-file replace the whole list. A finished item takes only a description or criteria change.
  item verify <id> <position> [--met] [--failed] --reviewer <session> [--head <commit sha>] [--note <text>]
    Records a reviewer session's verdict on one acceptance criterion: --met or --failed, by a live review session of the item that is not the item's work or fix session and not the roadmap's manager. A build needs --head, the pull request's current head. The latest verdict on each criterion counts, and a verdict on an older head stops counting when the head moves.
  item claim <id> --session <name> [--branch <name>] [--base <branch>]
    Gives a ready item with at least one acceptance criterion to a new session and marks it dispatched. The branch defaults to the session name and the base to the repository's default branch.
  item advance <id> <open|dispatched|reported|in_review|fixing|merging|merged|accepted|dropped> [--kind build]
    Moves an item to another status. A research or design item reaches reported only through a done report, and a build reaches in_review only through a done or fixed report or pr head. A build moves to merging only when, among each reviewer's latest verdict on its pull request's head, one approves and none asks for changes, and every acceptance criterion has a met verdict on that head. It closes as merged only when those reviews still approve.
  item close <id>
    Marks a merging build merged, once the reviews on its pull request's head still approve it, or a reported research or design item accepted.
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
  decision revise <id> --file <path|-> [--supersedes <decision id>] [--no-supersedes]
    Replaces the title, context, options and recommendation of a proposed decision with the JSON document in --file (- reads stdin), the same shape propose takes, and clears when it was asked. The output of `decision show --json` is accepted as is. --supersedes retargets the decision it would replace, under the same rule, and --no-supersedes removes the link. The two flags cannot be given together.
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
  decision ask <id>
    Puts a proposed decision to the owner. It needs at least 2 options and can be asked once, until a revision clears the ask.
  decision accept <id> --option <number> --justification <text> --consequences <text>
    Accepts a proposed decision with one of its options and records who decided and why. When the decision supersedes another, that one becomes superseded in the same call.
  decision reject <id> --reason <text>
    Rejects a proposed decision and records the reason.
  decision deprecate <id> --reason <text>
    Deprecates an accepted decision and records the reason.
  decision block <id> <item>
    Makes a proposed decision hold an open item or an unfinished epic of its roadmap; an epic holds all its open children, including ones added later.
  decision unblock <id> <item>
    Removes an item from what a decision blocks, in any decision status.
  report list [--item <id>] [--unread]
    Lists the reports, oldest first. --item keeps those on one item, --unread those not read yet.
  report show <id>
    Shows one report with its body.
  report read <id>
    Marks a report read. Reading the done report of a research or design item ends the session that sent it, if it is still live.
  report <item> --session <name> --kind done|fixed|question [--text <text>] [--file <path|->] [--pr <number>] [--head <commit sha>]
    Records a report from the item's live session, with its body in --text, or in --file (- reads stdin). done moves a dispatched research or design item to reported, and a dispatched build to in_review with its pull request in --pr and its head in --head. fixed moves a fixing build to in_review with the head it pushed in --head, and a build with no pull request yet attaches one there with --pr. question leaves the status as it is.
  review start <item> --session <name>
    Starts a live review session on a build that is in_review, so the reviewer can record its verdict with pr review. A live work or fix session and one live review session may run together.
  pr review <item> --verdict changes|approve --kind behavior|design --head <commit sha> --reviewer <session>
    Records a review of the build's pull request at --head, which must be the pull request's current head in the ledger, by the reviewer session's live review session, and ends that session. It never moves the item. The build moves to merging, and closes as merged, only when, among each reviewer's latest verdict on the pull request's head, one approves and none asks for changes.
  pr head <item> <commit sha>
    Records a new head for the build's pull request when its branch moved without a fixed report, and moves an in_review or merging build back to in_review. Any live review session ends as superseded, and reviews on older heads stop counting toward its approval.
  pr show <item>
    Shows the build's pull request with its reviews and whether they approve its head.
  session end <name> --reason abandoned
    Ends a live session by name. The only reason it records today is abandoned.

Environment:
  RMAP_JSON   Set to 1 to print JSON, as --json does.
  RMAP_ACTOR  Names the actor when --actor is not given.
  USER        Names the actor when neither --actor nor RMAP_ACTOR is given.

Exit codes:
  0  The command ran.
  1  The ledger refused the command. The error holds a code and a message.
  2  The call cannot be completed. The error has the code usage when the arguments match no command or a decision's --file cannot be read or holds no proposal, no-repository when no --db was given outside a git repository, no-ledger when no ledger exists at the path yet, description-unreadable when a --description-file or stdin read fails, or report-unreadable when a report's --file or stdin read fails.
  3  The database could not be opened, read or written. The error has the code busy when the wait for the lock timed out, ledger-too-new when a newer rmap migrated the ledger, otherwise database.

Refusal codes:
  roadmap-not-found              No roadmap has that name.
  roadmap-exists                 A roadmap already has that name.
  roadmap-already-paused         A pause changes nothing: the roadmap is already paused.
  roadmap-not-paused             A resume changes nothing: the roadmap is not paused.
  item-not-found                 No item has that id.
  item-closed                    A merged, accepted or dropped item is closed.
  description-required           An item needs a description.
  criteria-required              An item needs at least one acceptance criterion.
  blank-criterion                An acceptance criterion cannot be blank.
  parent-not-epic                The parent is not an epic.
  parent-in-other-roadmap        The parent belongs to another roadmap.
  epic-has-parent                An epic cannot have a parent.
  priority-out-of-range          A priority must be from 0 (highest) to 4 (lowest).
  epic-status-computed           An epic's status comes from its children, so no command moves it.
  invalid-kind-change            Only an advance to dispatched can turn an item into a build.
  invalid-transition             The transition table has no such move for this item.
  not-ready                      The item is blocked. The error lists whether the roadmap is paused, its blockers, its dropped_blockers and its blocking_decisions.
  cycle                          The dependency would close a cycle of blocks dependencies.
  dep-exists                     The blocks dependency already exists.
  dep-not-found                  No such blocks dependency exists.
  decision-not-found             No decision has that id.
  decision-frozen                Only a proposed decision can change.
  decision-incomplete            A proposal needs a title, a context, at least 2 options with titles, and a recommendation that names one of them with a reason.
  invalid-decision-transition    The transition table has no such move for this decision.
  option-not-found               The decision has no option with that number.
  already-asked                  The decision was already put to the owner.
  not-blockable                  Only an open item or an unfinished epic can wait on a decision.
  decision-in-other-roadmap      The item belongs to another roadmap than the decision.
  decision-block-exists          The decision already blocks that item.
  decision-block-not-found       The decision does not block that item.
  supersede-target-not-accepted  Only a decision that is accepted, or rejected in the same roadmap, can be superseded.
  session-busy                   A live session already has that name.
  session-not-live               No live session has that name.
  session-not-claimant           The session is not the item's live session.
  report-empty                   A report needs a body.
  report-not-found               No report has that id.
  report-already-read            The report was already read.
  pr-required                    A done report on a build, or a fixed report on a build with no pull request yet, needs --pr and --head.
  head-required                  A fixed report on a build needs --head.
  pr-not-allowed                 Only a done or fixed report on a build takes --pr or --head, and --pr only when the build has no pull request yet.
  pr-number-taken                Another item already has a pull request with that number.
  pr-not-found                   The item has no pull request.
  invalid-head                   A head is a full 40-character commit SHA in lowercase hex.
  head-not-current               A review names a head other than the pull request's current head in the ledger.
  head-unchanged                 pr head names the head the pull request is already at.
  reviewer-is-worker             The reviewer is a work or fix session of the item, live or ended.
  reviewer-not-fresh             The reviewer already reviewed another head of the same pull request. A new head needs a new reviewer. The error names the reviewer, the head it reviewed and the head it tried.
  review-not-in-review           A review can start only while the item is in_review.
  review-already-live            The item already has a live review session.
  review-session-required        The reviewer has no live review session for this item. Start one with review start.
  not-approved                   Among each reviewer's latest verdict on the pull request's head, none approves or one asks for changes. The error lists the head, approved_by, changes_requested and stale_heads.
  criteria-unmet                 A build needs a met verdict on the pull request's current head for every acceptance criterion before it can move to merging. The error lists each criterion without one or with failed.
  verifier-not-reviewer          The verifier has no live review session for this item. Start one with review start.
  verifier-is-worker             The verifier is a work or fix session of the item, live or ended.
  verifier-is-manager            The verifier is the roadmap's manager session.
  criterion-not-found            The item has no acceptance criterion at that position.
  verdict-head-required          A criterion verdict on a build needs --head.
  verdict-head-not-current       The criterion verdict names a head other than the pull request's current head. The error names both heads.
```
