---
name: cobol-data-file
description: Create, extend, edit or debug fixed-width COBOL data files (*.dat) so each record matches a program's FD record layout exactly - computing column positions from PIC clauses, padding with spaces, encoding implied decimals, and verifying record lengths. Use when the user wants test data, sample records, new rows in employees.dat or payroll.dat, a column map of a record layout, or when a program reads garbage, wrong numbers or shifted fields from a file.
argument-hint: "path\\to\\file.dat or program.cob [what records to add]"
---

# cobol-data-file

Records in this repo are LINE SEQUENTIAL: one record per line, LF endings, every line exactly the record length. Fields are found by **column position** alone, with no delimiters.

## 1. Build the column map from the FD
Find the `FD` and its `01` record in the program that reads the file (e.g. `tutorials/07-files/files.cob` for `employees.dat`). The width of each elementary field:

| PIC | Width | Stored as |
|---|---|---|
| `X(n)` | n | text, left-aligned, space-padded |
| `9(n)` | n | digits, right-aligned, zero-padded |
| `9(n)V9(m)` / `99V9` | n+m | digits only. **The `V` takes no column**: 40.5 hours in `99V9` is `405` |
| `S9(n)` (DISPLAY, no SIGN SEPARATE) | n | sign is overpunched in the last digit; avoid in hand-made data |

Write the map out for the user, e.g. `files.cob`'s `EMP-RECORD`:

```
cols  1-5   EMP-ID      9(5)    10001
cols  6-25  EMP-NAME    X(20)   Ada Lovelace + 8 spaces
cols 26-35  EMP-DEPT    X(10)   ENGR + 6 spaces
cols 36-41  EMP-SALARY  9(6)    072000
record length 41
```

## 2. Write the records
- Pad every text field with spaces to its full width, and zero-fill every numeric field.
- Write the file with a tool that won't strip trailing spaces. The Write tool is fine; afterwards run `awk '{print length}' FILE | sort -u`, which must print one number, the record length.
- Keep LF endings and a final newline. `.editorconfig` already turns off trailing-space trimming for `*.dat`.
- If the program needs sorted input (control-break reports such as `payroll.cob` need it sorted by department), keep the file sorted.
- Show the user a ruler when it helps:
  ```
  ----+----1----+----2----+----3----+----4-
  10001Ada Lovelace        ENGR      072000
  ```

## 3. Verify
- `bash .claude/skills/cobol-lint/check.sh path/to/file.dat` reports CRs, unequal lengths and a missing final newline.
- Run the reading program with `.\build.ps1 run -Name ...` (PowerShell tool) and check that the fields print as expected.

## Debugging shifted or garbage fields
- Compare `awk '{print length}' FILE | sort | uniq -c` with the record length from the map. One short line shifts nothing else, but its last fields read as spaces.
- A non-numeric character in a `9` field (a space or a stray letter) gives wrong arithmetic or a runtime data exception.
- A CR at the end of a line becomes part of the last field: convert to LF.
