# rmap command line

`rmap` reads and writes the roadmap ledger, a SQLite database. Every command prints one JSON object on standard output.

## Database

The default database is `ledger.db` in the directory that `git rev-parse --path-format=absolute --git-common-dir` prints. Every worktree of a repository shares that database.

**To use another database, pass `--db <path>` before or after the command.**

`rmap` applies pending migrations each time it opens the database.

## Output

Every JSON object that `rmap` prints carries `"schema_version": 1` at its top level.

| Exit code | Meaning | Output |
| --- | --- | --- |
| 0 | The command ran. | The result object of the command. |
| 1 | The ledger refused the command. | An `error` object with `code` and `message`. |
| 2 | The arguments do not match a command. | An `error` object with code `usage`. The usage text goes to standard error. |
| 3 | The database could not be opened, read or written. | An `error` object with code `database`. |

A refusal looks like this:

```json
{"schema_version": 1, "error": {"code": "invalid-transition", "message": "an item cannot move from open to merged"}}
```

A `not-ready` refusal also carries `blockers` and `path_conflicts`, in the shapes that `rmap ready` uses. A `path-conflict` refusal also carries `path_conflicts`.

## Objects

An item object has these fields:

```json
{
  "id": "rm-3f2a",
  "roadmap_id": "rm-91c0",
  "parent_id": null,
  "title": "Add the parser",
  "kind": "build",
  "status": "open",
  "origin": "planned",
  "priority": 0,
  "claimed_by": null,
  "created_at": "2026-11-19T20:12:45.288Z",
  "closed_at": null
}
```

An epic's `status` is computed: `merged` when every child is `merged` or `dropped`, otherwise `open`. An epic with no children is `open`.

A roadmap object has `id`, `name`, `manager`, `status` and `created_at`.

A dep object has `item`, `on` and `type`. The `type` is `blocks` or `discovered_from`.

An event object has these fields:

- `id`
- `at`
- `actor`
- `roadmap_id`
- `item_id`
- `type`
- `payload`

## Commands

| Command | Prints | Refusal codes |
| --- | --- | --- |
| `rmap new <name> --manager <session>` | `roadmap` | `roadmap-exists` |
| `rmap list` | `roadmaps` | none |
| `rmap ready [--roadmap <name>]` | `ready`, `blocked` | `roadmap-not-found` |
| `rmap log [--item <id>] [--since <event id>]` | `events` | none |
| `rmap item add ...` | `item` | see [item add](#item-add) |
| `rmap item list [--roadmap <name>]` | `items` | `roadmap-not-found` |
| `rmap item show <id>` | `item`, `deps`, `paths` | `item-not-found` |
| `rmap item claim <id> --session <name>` | `item` | `item-not-found`, `epic-status-computed`, `invalid-transition`, `not-ready` |
| `rmap item advance <id> <status> [--kind build --paths <globs>]` | `item` | see [item advance](#item-advance) |
| `rmap item close <id>` | `item` | `item-not-found`, `epic-status-computed`, `invalid-transition` |
| `rmap item drop <id> --reason <text>` | `item` | `item-not-found`, `epic-status-computed`, `invalid-transition` |
| `rmap dep add <item> <on>` | `dep` | `item-not-found`, `dep-exists`, `cycle` |
| `rmap dep rm <item> <on>` | `dep` | `dep-not-found` |

A flag that takes a list, such as `--after` or `--paths`, takes its values separated by commas.

### ready

`ready` lists the items that can start, in start order, then the items that wait:

```json
{
  "schema_version": 1,
  "ready": [{"id": "rm-3f2a", "...": "an item object"}],
  "blocked": [
    {
      "item": {"id": "rm-77b1", "...": "an item object"},
      "blockers": ["rm-3f2a"],
      "path_conflicts": [{"with": "rm-0c4e", "glob": "src/a/b.rs", "other_glob": "src/a/**"}]
    }
  ]
}
```

An item is ready when all of these hold:

- Its kind is not `epic`, its status is `open` and nobody has claimed it.
- Every item it waits on through a `blocks` dep is `merged`. A `dropped` blocker keeps it blocked.
- None of its paths conflicts with a path of an active build in any roadmap.

An active build is a build in `dispatched`, `reported`, `in_review`, `fixing` or `merging`.

Two globs conflict when the text before the first wildcard (`*`, `?`, `[` or `{`) of one starts the other's.

Ready items come in this order: `user-bug` origin first, then higher priority, then older, then by id.

`blocked` lists the open, unclaimed items that are not ready.

### item add

```sh
rmap item add --roadmap <name> --title <text> --kind <kind>
              [--parent <id>] [--after <ids>] [--paths <globs>]
              [--from <id>] [--origin <origin>] [--priority <n>]
```

| Flag | Value |
| --- | --- |
| `--kind` | `epic`, `research`, `design` or `build` |
| `--parent` | An epic in the same roadmap |
| `--after` | Items this item waits on. Each becomes a `blocks` dep. |
| `--paths` | Globs this item locks while it is an active build. A build needs at least one. |
| `--from` | The item this one was discovered from. It becomes a `discovered_from` dep. |
| `--origin` | `planned` (default), `user-bug` or `follow-up` |
| `--priority` | A whole number. Higher starts first. The default is 0. |

Refusal codes:

- `roadmap-not-found`
- `item-not-found`
- `epic-has-parent`
- `parent-not-epic`
- `parent-in-other-roadmap`
- `build-needs-paths`

### item advance

`item advance` moves an item along this table. Any other move is refused with `invalid-transition`.

| From | To | Command |
| --- | --- | --- |
| `open` | `dispatched` | `item claim` |
| `dispatched` | `open` | `item advance` (the dispatch failed, the claim clears) |
| `dispatched` | `reported` | `item advance` (research and design only) |
| `dispatched` | `in_review` | `item advance` (build only) |
| `reported` | `dispatched` | `item advance --kind build --paths <globs>` |
| `in_review` | `fixing` or `merging` | `item advance` |
| `fixing` | `in_review` | `item advance` |
| `merging` | `fixing` | `item advance` |
| `merging` | `merged` | `item close` |
| any status but `merged` and `dropped` | `dropped` | `item drop` |

`--kind build` turns a reported research or design item into a build. The build takes the globs of `--paths`, or the item's stored paths when `--paths` is absent.

Refusal codes:

- `item-not-found`
- `epic-status-computed`
- `invalid-transition`
- `build-needs-paths`
- `path-conflict`

## Refusal codes

| Code | Meaning |
| --- | --- |
| `roadmap-not-found` | No roadmap has that name. |
| `roadmap-exists` | A roadmap already has that name. |
| `item-not-found` | No item has that id. |
| `parent-not-epic` | The parent is not an epic. |
| `parent-in-other-roadmap` | The parent belongs to another roadmap. |
| `epic-has-parent` | An epic cannot have a parent. |
| `build-needs-paths` | A build needs at least one path. |
| `epic-status-computed` | An epic's status comes from its children, so it cannot be claimed, advanced, closed or dropped. |
| `invalid-transition` | The state table has no such move for this item. |
| `not-ready` | The item is blocked or path-conflicted. |
| `path-conflict` | The new build's paths conflict with an active build. |
| `cycle` | The dep would close a cycle of `blocks` deps. |
| `dep-exists` | The `blocks` dep already exists. |
| `dep-not-found` | No such `blocks` dep exists. |
