# rmap

`rmap` is a Knave CLI over a SQLite ledger of roadmap items, their dependencies and their state.

## Boundaries

**Code outside `src/ledger/` MUST use only `ledger/api`.** Tests in `tests/` MAY also use `ledger/core/*` and `ledger/sqlite/*` to test those modules directly.

**NEVER put a ledger rule in `src/main.knv` or `src/cli/`.** They parse arguments, call `ledger/api` and print JSON through `json/value`.

**NEVER import `ledger/sqlite/*` from `ledger/core/*`.** The core is pure: it reads a snapshot and returns values or refusals.

| Path | Holds |
| --- | --- |
| `src/json/value.knv` | The bindings over `serde_json::Value`. |
| `src/process/command.knv` | Runs a program and captures its exit code and output. |
| `src/main.knv`, `src/cli/` | The `rmap` CLI. |
| `src/ledger/api.knv` | The public ledger functions, re-exported from `src/ledger/operations/`. |
| `src/ledger/operations/` | The ledger operations. Each write runs in one `BEGIN IMMEDIATE` transaction and appends its `events` row in that transaction. |
| `src/ledger/model.knv`, `names.knv`, `refusal.knv` | The ledger values, the text of each enum case, and the refusal codes. |
| `src/ledger/core/` | The pure ledger rules. |
| `src/ledger/sqlite/` | The connection, the migrations runner and one module per table. |
| `migrations/` | The numbered `.sql` migrations. |
| `docs/cli.md` | Every command, its JSON output and its exit codes. |

## Writing Knave

**Invoke the `writing-knave` skill before you write or change a `.knv` file.**

**If `knave build` and `knave test` both pass without a `type` line, delete the line.**

**Put only the Rust calls that Knave cannot make in a `rust` template.** Write every branch, loop and conversion around those calls in Knave. If Knave can name the Rust type as a `defenum` with a `rust` clause, match on it in Knave.

## Tests

**Put the tests of `src/<path>.knv` in `tests/<path>-test.knv`.** NEVER drop the `-test` suffix: a test file at its source path collides with the source module.

**Put the tests that run the `rmap` binary in `tests/e2e/`.**

**Put a helper that tests share in `tests/support/`, and a fixture file in `tests/fixtures/`.**

## Migrations

**To change the schema, add the next numbered file to `migrations/`, then run `knave task embed-migrations`.** The task writes `src/ledger/sqlite/migration-sources.knv`.

**NEVER edit a committed migration file:** a database that already applied the file skips the edit.

**NEVER edit `migration-sources.knv` by hand.** If the test `embedded-migrations-match-the-sql-files` fails, run `knave task embed-migrations`.

## Checks

**Before you commit, run `knave fmt`, `knave lint` and `knave test`.** If `knave lint` prints a warning, fix the warning and run the three commands again. If `knave test` fails, fix the cause and run the three commands again.

**If you change a command, its JSON output or its exit codes, update `docs/cli.md` in the same commit.**

`knave test` builds the `rmap` binary itself, because the CLI and claim-race tests run it.

**Keep every file outside `tests/` under 150 lines.** If a file passes 150 lines, split it into modules by responsibility.

**If the same check still fails after three fixes, stop and show the failure to the user.**
