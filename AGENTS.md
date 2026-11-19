# rmap

**Code outside `src/ledger/` MUST use only `ledger/api`.** A test MAY also import the ledger module it tests.

**Keep every ledger rule inside `src/ledger/`.**

**Put only the Rust calls that Knave cannot make in a `rust` template.** Write the logic around those calls in Knave.

**If CI reports a file over 150 lines, move a concept that deserves its own name into its own module.** NEVER split a file only to cut its length.

**NEVER edit a committed migration file:** a database that already applied the file skips the edit.

**If you change a command, its JSON output or its exit codes, update `docs/cli.md` in the same commit.**
