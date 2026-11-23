# rmap

**The CLI only parses arguments, calls `ledger/api` and prints the result.** NEVER decide in the CLI whether a ledger change is allowed.

**Put only the Rust calls that Knave cannot make in a `rust` template.** Write the logic around those calls in Knave.

**If CI reports a file over 150 lines, move a concept that deserves its own name into its own module.** NEVER split a file only to cut its length.

**Give each source file at most one unit test file, at the same path under `tests/` with a `-test` suffix.** `src/ledger/operations/deps.knv` is tested in `tests/ledger/operations/deps-test.knv`. NEVER create a unit test file named after a feature or a behavior. Put tests that run the built binary in `tests/e2e/`.

**Run `knave check`, `knave fmt --check`, `knave lint`, `knave lint` on each `tasks/*.knv`, `knave task ledelint` and `knave test` before you push.**
