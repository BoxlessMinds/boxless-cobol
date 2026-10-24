---
name: new-lib-module
description: Create a new reusable COBOL library module in lib/ following this repo's convention - a parameter-block copybook, a callable subprogram dispatched by function code with 00/10/90 return codes, a unit-test driver, and a row in lib/README.md - then build and run the tests. Use when the user wants a new library module, utility, callable subprogram, or shared routine (e.g. "add a MATHUTIL module", "make a reusable currency formatter").
argument-hint: "MODULE-NAME [what it should do]"
---

# new-lib-module

The convention is documented in [lib/README.md](../../../lib/README.md); the working references are `lib/src/STRUTIL.cob`, `lib/copybooks/STRUTIL-PARMS.cpy` and `lib/tests/TEST-STRUTIL.cob`. The templates in `templates/` next to this file are a compile-tested skeleton of that pattern.

## Decide first
Derive these from `$ARGUMENTS` and the conversation. Ask only if the purpose is unclear.

| Placeholder | Rule | Example |
|---|---|---|
| `@MOD@` | Upper case, ≤ 8 chars, ends in `UTIL` by habit, must not already exist in `lib/src/` | `MATHUTIL` |
| `@PFX@` | 2-letter field prefix, unique among copybooks (`SU` and `DU` are taken) | `MU` |
| `@FUNC@` | First function code, ≤ 8 chars (`PIC X(8)`) | `GCD` |
| `@DESC@` | One-line description | `integer math helpers` |

Then list every function, its inputs and outputs, and what counts as invalid input (that's RC 10).

## Steps
1. **Copybook**: copy `templates/PARMS.cpy` to `lib/copybooks/@MOD@-PARMS.cpy` and replace the placeholders.
   - Replace the generic `@PFX@-INPUT`/`@PFX@-RESULT` fields with fields that fit, e.g. numeric `PIC S9(9)` inputs, or a `PIC X(80)` text field like STRUTIL's.
   - Add an `88` level for each function code.
   - Keep `@PFX@-RC PIC 9(2)` and the three `88`s: `OK` 0, `INVALID` 10, `BAD-FUNCTION` 90.
   - Update the usage example in the header comment.
2. **Module**: copy `templates/MODULE.cob` to `lib/src/@MOD@.cob`.
   - `PROGRAM-ID` must equal the file name.
   - Add one `WHEN @PFX@-xxx PERFORM DO-xxx` per function, and one paragraph each.
   - Set `@PFX@-INVALID` on bad input and keep `WHEN OTHER` → `BAD-FUNCTION`. End with `GOBACK` and `END PROGRAM @MOD@.`
3. **Tests**: copy `templates/TEST.cob` to `lib/tests/TEST-@MOD@.cob`.
   - For each function, write at least one normal case, one edge case, and one RC 10 case. Keep the RC 90 case.
   - See the `add-lib-tests` skill for how to compare numbers.
4. **Docs**: add a row to the *Modules* table in `lib/README.md`: `` | `@MOD@` | `@MOD@-PARMS.cpy` | `FUNC1`, `FUNC2` ... | ``.
5. **Verify**:
   - `bash .claude/skills/cobol-lint/check.sh` (Bash tool), which must be clean.
   - Then `.\build.ps1 test` (PowerShell tool), which must end in `ALL TESTS PASSED` with no `-Wall` warnings for the new files.
6. Tell the user the files you created, and show a 4-line `CALL` example they can paste into a program.

## Gotchas
- After placeholder replacement, re-align the `PIC` and `VALUE` columns and keep every line ≤ 72 columns.
- Numeric `PIC 9` fields hold no sign: use `S9` if negatives are valid.
- `MOVE` a number to the alphanumeric `TEST-ACTUAL` and it compares as its digits with leading zeros, e.g. `PIC 9(3)` 12 → `"012"`.
- A caller only finds the module at run time if `build/lib/@MOD@.so` exists, and `make run` and `make test` build it automatically.
