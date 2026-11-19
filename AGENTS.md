# rmap

**The CLI only parses arguments, calls `ledger/api` and prints the result.** NEVER decide in the CLI whether a ledger change is allowed.

**Put only the Rust calls that Knave cannot make in a `rust` template.** Write the logic around those calls in Knave.

**If CI reports a file over 150 lines, move a concept that deserves its own name into its own module.** NEVER split a file only to cut its length.
