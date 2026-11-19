# rmap

**Keep every ledger rule inside `src/ledger/`.**

**Put only the Rust calls that Knave cannot make in a `rust` template.** Write the logic around those calls in Knave.

**If CI reports a file over 150 lines, move a concept that deserves its own name into its own module.** NEVER split a file only to cut its length.
