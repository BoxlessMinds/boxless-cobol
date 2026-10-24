---
name: new-example
description: Create a new complete COBOL example program in examples/<name>/ for this repo, with optional fixed-width input data, a header comment documenting purpose and record layout, and a row in examples/README.md, then build and run it. Use when the user wants a realistic or "complete" program rather than a lesson, e.g. "write an inventory report", "make a bank-statement example", "build a CSV-style batch job".
argument-hint: "example-name [what it does]"
---

# new-example

Examples are small but realistic programs. `examples/payroll-report/payroll.cob` is the reference: it reads input, applies business rules, prints a formatted report and calls a library module.

## Steps
1. **Name.** Folder `examples/<kebab-name>/` and a short, lower-case file basename that isn't used elsewhere (the lint check catches duplicates). It must not be a C keyword such as `long`, `int` or `switch`, or cobc fails with `invalid file base name`. `PROGRAM-ID` is the basename in upper case.
2. **Design the data first** if the program reads a file. Write the FD record layout, then create `<name>.dat` next to the program with the `cobol-data-file` skill. Input files use `ORGANIZATION IS LINE SEQUENTIAL`, a `FILE STATUS` field, and `ASSIGN TO "<name>.dat"` (a relative path: `make run` runs from the program folder). Name output files `*.out`, which git ignores.
3. **Header comment.** Like `payroll.cob`, give a few lines on what the program does, then the input layout column by column (`cols  1-6   department`), including implied decimals (`99V9 (405 = 40.5)`), then the business rules.
4. **Program.**
   - Use `MAIN-PARA` with `PERFORM ... UNTIL END-OF-FILE`, one paragraph per job, and edited `PIC`s (`ZZ,ZZ9.99`) for printed amounts.
   - Check the file status after OPEN.
   - Reuse `lib/` modules where they fit (`DATEUTIL` for dates, `STRUTIL` for text): `COPY xxx-PARMS.` then `CALL`.
5. **README.** Add a row to `examples/README.md`: `` | [name](name/name.cob) | what it shows | ``.
6. **Verify.**
   - `bash .claude/skills/cobol-lint/check.sh` (Bash tool).
   - `.\build.ps1 run -Name examples\<name>\<name>.cob` (PowerShell tool). Check the totals by hand for at least one record and show the user the output.

## Gotchas
- Size accumulators bigger than detail fields (payroll uses `9(5)V99` per line, `9(7)V99` for the grand total), or `ON SIZE ERROR` will fire or totals will be truncated.
- Control-break reports need sorted input; say so in the header.
- Don't let tools strip trailing spaces from the `.dat` file.
