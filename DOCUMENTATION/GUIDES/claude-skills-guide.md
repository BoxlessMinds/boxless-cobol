# Claude Skills for the COBOL Playground

A friendly, example-heavy guide to the seven Claude Code skills that come with this repo: what each one does, when to use it, and what to type.

---

## Contents

1. [The 60-second version](#1-the-60-second-version)
2. [How skills work](#2-how-skills-work)
3. [Quick-start table](#3-quick-start-table)
4. [Before you start: a one-time check](#4-before-you-start-a-one-time-check)
5. [The skills, one by one](#5-the-skills-one-by-one)
   - [cobol-build-run](#51-cobol-build-run--build-run-test-fix)
   - [cobol-lint](#52-cobol-lint--catch-fixed-format-mistakes-early)
   - [new-lib-module](#53-new-lib-module--a-reusable-callable-module)
   - [add-lib-tests](#54-add-lib-tests--more-test-cases)
   - [new-tutorial](#55-new-tutorial--a-new-numbered-lesson)
   - [new-example](#56-new-example--a-complete-realistic-program)
   - [cobol-data-file](#57-cobol-data-file--fixed-width-data-done-right)
6. [Walkthrough: from idea to tested module to lesson](#6-walkthrough-from-idea-to-tested-module-to-lesson)
7. [Handy combinations](#7-handy-combinations)
8. [Troubleshooting](#8-troubleshooting)
9. [Changing or adding skills](#9-changing-or-adding-skills)
10. [Cheat sheet](#10-cheat-sheet)

---

## 1. The 60-second version

- Skills are short instruction files that teach Claude how to do one job the way this repo does it.
- They live in [.claude/skills/](../../.claude/skills/), and they only apply to this workspace.
- You don't have to remember them. Ask in plain English ("add a lesson on SORT") and Claude picks the right skill.
- If you want to be explicit, type a slash command: `/new-tutorial SORT`.
- Every skill ends by **checking its own work**: it runs the lint check, builds, and runs or tests the result.

---

## 2. How skills work

### Where they live

```
.claude/skills/
├── cobol-build-run/SKILL.md      build, run, test, fix errors
├── cobol-lint/
│   ├── SKILL.md                  explains the findings
│   └── check.sh                  the actual checker (read-only)
├── new-lib-module/
│   ├── SKILL.md
│   └── templates/                PARMS.cpy, MODULE.cob, TEST.cob
├── add-lib-tests/SKILL.md
├── new-tutorial/SKILL.md
├── new-example/SKILL.md
└── cobol-data-file/SKILL.md
```

Each `SKILL.md` starts with a short header like this:

```yaml
---
name: new-lib-module
description: Create a new reusable COBOL library module in lib/ ...
argument-hint: "MODULE-NAME [what it should do]"
---
```

The **description** is what Claude reads to decide whether a skill fits your request. The rest of the file holds the steps it follows.

### Two ways to use a skill

| Way | You type | When it's handy |
|---|---|---|
| **Just ask** | `Can you add a string-padding function to the library?` | Most of the time. Claude matches your request to a skill. |
| **Slash command** | `/new-lib-module PADUTIL left and right padding` | When you want a specific skill for certain, or want to pass arguments. |

Anything after the skill name is passed to the skill as its **arguments**. Each skill's `argument-hint` (shown when you type `/`) tells you what it expects.

### What "scoped to this workspace" means

These skills are in the repo's own `.claude/` folder, so they only show up when Claude Code is opened in this folder. They don't affect your other projects, and if you commit them, anyone who clones the repo gets them too.

---

## 3. Quick-start table

| I want to… | Skill | Try typing |
|---|---|---|
| Build or run something, or fix a compile error | `cobol-build-run` | `run the payroll example` |
| Check my code for column or format mistakes | `cobol-lint` | `/cobol-lint` |
| Add a new reusable library module | `new-lib-module` | `/new-lib-module MATHUTIL GCD and LCM` |
| Add test cases to a module | `add-lib-tests` | `add edge-case tests for DATEUTIL VALIDATE` |
| Write a new lesson | `new-tutorial` | `/new-tutorial SORT verb` |
| Write a complete example program | `new-example` | `/new-example inventory-report` |
| Create or fix a `.dat` data file | `cobol-data-file` | `add three employees to employees.dat` |

---

## 4. Before you start: a one-time check

GnuCOBOL runs **inside WSL** (Ubuntu). Check it in a PowerShell terminal:

```powershell
wsl cobc --version
```

You should see something like this:

```
cobc (GnuCOBOL) 4.0-early-dev.0
Copyright (C) 2020 Free Software Foundation, Inc.
...
```

If you get `command not found`, see [Troubleshooting](#8-troubleshooting). The `cobol-build-run` skill runs this same check on its own the first time it builds in a session.

> **Good to know:** Claude Code has two shells, PowerShell and Git Bash. Calling `wsl cobc` from Git Bash fails with `cobc: command not found` even when cobc is installed. The skills know this and always build through PowerShell (`.\build.ps1`). If you build by hand, use PowerShell too.

---

## 5. The skills, one by one

### 5.1 `cobol-build-run`: build, run, test, fix

**What it does:** runs the repo's build ([build.ps1](../../build.ps1) → [Makefile](../../Makefile) in WSL), reads the output, and fixes the source if something fails.

**Reach for it when:** you want to see a program run, run the tests, or understand a confusing compiler message.

#### Example A: run a lesson

> **You:** run the files tutorial

Claude runs:

```powershell
.\build.ps1 run -Name tutorials\07-files\files.cob
```

`make run` runs the program **from its own folder**, so `employees.dat` is found next to `files.cob`.

#### Example B: run all the tests

> **You:** `/cobol-build-run test`

Real output from this repo:

```
== build/bin/TEST-DATEUTIL
TEST-DATEUTIL
  PASS  VALIDATE accepts leap day 2024-02-29
  PASS  VALIDATE rejects 2023-02-29
  ...
  0008 run, 0000 failed
== build/bin/TEST-STRUTIL
TEST-STRUTIL
  PASS  UPPER converts to upper case
  ...
  0007 run, 0000 failed
ALL TESTS PASSED
```

#### Example C: run a single test driver

> **You:** just run the STRUTIL tests

```powershell
.\build.ps1 run -Name lib\tests\TEST-STRUTIL.cob
```

#### Example D: explain and fix a compile error

> **You:** payroll won't compile, it says "syntax error, unexpected PERFORM". Fix it?

Claude opens the line cobc points at **and the lines just before it**, because COBOL errors often show up one statement late (a missing period on the previous line is the classic). It fixes the source, rebuilds, and shows you the clean run.

#### The arguments it accepts

| You type | Claude runs |
|---|---|
| `/cobol-build-run` or `/cobol-build-run all` | `.\build.ps1` |
| `/cobol-build-run test` | `.\build.ps1 test` |
| `/cobol-build-run clean` | `.\build.ps1 clean` |
| `/cobol-build-run examples\fizzbuzz\fizzbuzz.cob` | `.\build.ps1 run -Name examples\fizzbuzz\fizzbuzz.cob` |

---

### 5.2 `cobol-lint`: catch fixed-format mistakes early

**What it does:** runs [check.sh](../../.claude/skills/cobol-lint/check.sh), a small read-only checker that needs no WSL. It looks for the mistakes that fixed-format COBOL punishes most.

| Checks for | Why it matters |
|---|---|
| Lines longer than 72 columns | cobc **silently ignores** columns 73+, which can cut off a period or a closing quote |
| TAB characters | They make column positions unpredictable |
| CRLF line endings | The repo uses LF, and a CR at the end of a data record becomes part of the last field |
| Code in column 7 or earlier | Column 7 is only for indicators (`*`, `-`, `/`, `D`) |
| Two programs with the same basename | Every program builds to `build/bin/<name>`, so one would overwrite the other |
| A lib module whose `PROGRAM-ID` doesn't match its file name | `CALL "FOO"` looks for `FOO.so` |
| `.dat` records of different lengths | Fields are read by column position |

#### Example A: check the whole repo

> **You:** `/cobol-lint`

```
cobol-lint: clean (20 files checked)
```

#### Example B: check specific files

> **You:** lint payroll.cob and its data file

```bash
bash .claude/skills/cobol-lint/check.sh examples/payroll-report/payroll.cob examples/payroll-report/payroll.dat
```

#### Example C: what problems look like

A line that's 79 characters long:

```
SCRATCH_FOLDER/toolong.cob:5: 79 columns; text past column 72 is ignored by cobc
cobol-lint: 1 problem(s)
```

A data file with one short record and no final newline:

```
bad.dat:2: record is 4 chars, most records are 3
bad.dat: no newline at end of file
```

You can also run the checker yourself, from Git Bash, at any time:

```bash
bash .claude/skills/cobol-lint/check.sh
```

---

### 5.3 `new-lib-module`: a reusable, callable module

**What it does:** creates a new module the same way `STRUTIL` and `DATEUTIL` are built (the convention is in [lib/README.md](../../lib/README.md)). It creates three files, updates one, and runs the tests:

| File | What's in it |
|---|---|
| `lib/copybooks/FOO-PARMS.cpy` | One `01 FOO-PARMS` block: a function code, input and output fields, a 2-digit return code, and `88` levels for each |
| `lib/src/FOO.cob` | `EVALUATE TRUE` dispatch on the function code, one paragraph per function, `GOBACK` |
| `lib/tests/TEST-FOO.cob` | Tests that use the copybook test harness |
| `lib/README.md` | A new row in the *Modules* table |

Return codes are the same for every module:

| RC | 88-level | Meaning |
|---|---|---|
| `00` | `xx-OK` | worked |
| `10` | `xx-INVALID` | bad input |
| `90` | `xx-BAD-FUNCTION` | unknown function code |

#### Example A: from a slash command

> **You:** `/new-lib-module MATHUTIL GCD of two numbers`

Claude chooses the prefix `MU` (`SU` and `DU` are taken) and the function code `GCD`, and builds the three files. See [the walkthrough](#6-walkthrough-from-idea-to-tested-module-to-lesson) for the full result.

#### Example B: in plain English

> **You:** I keep formatting money in my examples. Can we have a library routine that turns 1234.5 into "1,234.50"?

Claude recognises this as a new module, suggests a name (for example `FMTUTIL` with function `MONEY`), and asks only if the purpose is unclear.

#### Example C: a module with several functions

> **You:** `/new-lib-module TEXTUTIL functions PADL, PADR and CENTER on an 80-char field`

You get one `88` level and one paragraph per function, and tests for each, including what counts as invalid input.

#### What a caller looks like afterwards

```cobol
       WORKING-STORAGE SECTION.
       COPY MATHUTIL-PARMS.
       ...
           MOVE "GCD" TO MU-FUNCTION
           MOVE 48 TO MU-A
           MOVE 18 TO MU-B
           CALL "MATHUTIL" USING MATHUTIL-PARMS
           IF MU-OK
               DISPLAY "GCD = " MU-RESULT
           END-IF
```

> **Behind the scenes:** the skill starts from tested templates in [.claude/skills/new-lib-module/templates/](../../.claude/skills/new-lib-module/templates/) that compile cleanly with `-Wall`. Placeholders such as `@MOD@` (module name), `@PFX@` (prefix) and `@FUNC@` (first function) are filled in for you.

---

### 5.4 `add-lib-tests`: more test cases

**What it does:** adds cases to a `lib/tests/TEST-*.cob` driver using the repo's test harness, then runs just that driver.

Every test case has the same shape:

```cobol
           MOVE "FORMAT pads month with zero" TO TEST-NAME
           MOVE "FORMAT" TO DU-FUNCTION
           MOVE 20260105 TO DU-DATE-NUM
           CALL "DATEUTIL" USING DATEUTIL-PARMS
           MOVE "2026-01-05" TO TEST-EXPECTED
           MOVE DU-RESULT TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL
```

1. Name the test.
2. Set up the inputs.
3. `CALL` the module.
4. Say what you expect, and move in what you got.
5. `PERFORM ASSERT-EQUAL`.

#### Example A: edge cases

> **You:** add edge-case tests for DATEUTIL VALIDATE

You can expect cases like these: 1900-02-29 (not a leap year), 2000-02-29 (a leap year), month 13, day 00, and 31 April, each checking the return code.

#### Example B: turn a bug into a test first

> **You:** I think STRUTIL REVERSE breaks on an 80-character string. Write a test that proves it.

Claude writes the failing case **first** and runs it so you can watch it fail, then fixes the module and runs it again.

#### Example C: what a failure looks like

This is real output from a test with a deliberately wrong expectation:

```
TEST-MATHUTIL
  FAIL  GCD of 48 and 18 is 6
          expected [000000007]
          actual   [000000006]
  PASS  GCD with one zero is the other number
  PASS  GCD of 0 and 0 returns RC 10
  PASS  unknown function returns RC 90
  0004 run, 0001 failed
make: *** [Makefile:66: run] Error 1
```

The `Error 1` at the end is expected: a driver with failures sets `RETURN-CODE` to 1, so the build reports it.

#### How to write the expected value

`TEST-EXPECTED` and `TEST-ACTUAL` are both text (`PIC X(80)`), so numbers are compared as text. These were all checked with cobc:

| Field | Value | Write the expected value as |
|---|---|---|
| `PIC 9(3)` | 12 | `"012"` |
| `PIC 9(9)` | 6 | `"000000006"` |
| `PIC 9(2)` return code | 10 | `"10"` |
| `PIC S9(5)` | -42 | Move it to `PIC -(5)9` first, then expect `"   -42"` |
| `PIC 9(3)V99` | 12.50 | Move it to `PIC ZZ9.99` first, then expect `" 12.50"`. Moving a decimal field straight to text is a compile error (`invalid MOVE statement`) |

---

### 5.5 `new-tutorial`: a new numbered lesson

**What it does:** writes the next lesson in [tutorials/](../../tutorials/) in the house style, adds it to the lesson table and the exercises in [tutorials/README.md](../../tutorials/README.md), then builds and runs it.

**The house style:** each lesson is a single program. The boxed comment at the top **is** the lesson, and the code underneath demonstrates it, point by point. For example, from `01-hello`:

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO.
      *****************************************************************
      * Lesson 01 - Hello, COBOL
      *
      * Fixed-format source layout (the classic 80-column card):
      *   columns 1-6   sequence number area (ignored)
      *   column  7     indicator: '*' = comment line, '-' = continue
      ...
      *****************************************************************
```

#### Example A: the next lesson

> **You:** `/new-tutorial SORT and MERGE`

Lessons 01–08 already exist, so this creates `tutorials/09-sort/sort.cob`. If it needs data, it also creates a small `.dat` file next to it. It adds a table row and a new exercise, then runs the program so you can see the output.

#### Example B: a topic that builds on earlier lessons

> **You:** write a lesson on COMPUTE with intrinsic functions like SQRT, MAX and NUMVAL. Assume they've done lesson 03.

Claude reads the lesson table first, so it doesn't re-teach what lesson 03 already covers.

#### Example C: a lesson that uses the library

> **You:** a lesson showing how to call DATEUTIL to print today's day of the week

The lesson uses `COPY DATEUTIL-PARMS.` and `CALL "DATEUTIL"`, and its comments point back to lesson 08 (subprograms).

> **Naming rules the skill follows for you**
> - The file basename must be unique across the whole repo.
> - The basename must not be a C keyword: `long.cob`, `int.cob` and `switch.cob` all fail with `invalid file base name ... duplicates a 'C' keyword`.

---

### 5.6 `new-example`: a complete, realistic program

**What it does:** creates `examples/<name>/<name>.cob`, an optional `.dat` input file, and a row in [examples/README.md](../../examples/README.md), then runs the program and checks a total by hand. The model to follow is [payroll.cob](../../examples/payroll-report/payroll.cob): it reads records, applies business rules, prints a report and calls a library module.

#### Example A: a report

> **You:** `/new-example inventory-report reorder list for items below minimum stock`

You get:
- `examples/inventory-report/inventory.cob`, with a header that documents every input column;
- `inventory.dat`, made by `cobol-data-file`, so the columns line up;
- an output report, plus a hand-check of at least one line.

#### Example B: a calculation that reuses the library

> **You:** make a loan amortisation example that prints the schedule with dates from DATEUTIL

#### Example C: a batch filter

> **You:** an example that reads transactions and writes rejected ones to rejects.out

Output files use the `.out` extension, which git ignores ([.gitignore](../../.gitignore)).

---

### 5.7 `cobol-data-file`: fixed-width data done right

**What it does:** works out the exact column positions from a program's `FD` record and creates or edits `.dat` files to match. Then it checks that every line is the right length.

**Why you need it:** in fixed-width files, fields are found **only by column position**. One missing space shifts every field after it on that line.

#### How widths are counted

| PIC | Width | 40.5 / "Ada" stored as |
|---|---|---|
| `X(20)` | 20 | `Ada` + 17 spaces |
| `9(5)` | 5 | `00040` (right-aligned, zero-padded) |
| `99V9` | 3 | `405`, because **the `V` takes no column** |
| `999V99` | 5 | `02250` for 22.50 |

#### Example A: show me the layout

> **You:** what's the column layout of employees.dat?

```
cols  1-5   EMP-ID      9(5)    10001
cols  6-25  EMP-NAME    X(20)   Ada Lovelace + 8 spaces
cols 26-35  EMP-DEPT    X(10)   ENGR + 6 spaces
cols 36-41  EMP-SALARY  9(6)    072000
record length 41

----+----1----+----2----+----3----+----4-
10001Ada Lovelace        ENGR      072000
```

#### Example B: add records

> **You:** add three people to employees.dat, one of them in a new SALES department

Claude pads every field, keeps LF line endings, and checks that every line is still 41 characters.

#### Example C: payroll data with implied decimals

> **You:** add a worker to payroll.dat who did 42.5 hours at 31.75 an hour, in ENGR

Hours `99V9` → `425`, and rate `999V99` → `03175`. Because the payroll report uses control breaks, the record goes in **with the other ENGR rows**, keeping the file sorted by department.

#### Example D: "my program reads garbage"

> **You:** files.cob prints weird salaries for Grace Hopper

Claude compares each line's length with the record length, looks for a stray tab, CR or short field, and fixes the data.

---

## 6. Walkthrough: from idea to tested module to lesson

This is a real session, shortened. The module and test output below were produced in this repo and then removed, so you can try it yourself.

### Step 1: ask for the module

> **You:** `/new-lib-module MATHUTIL GCD of two numbers`

Claude creates the copybook `lib/copybooks/MATHUTIL-PARMS.cpy`:

```cobol
       01  MATHUTIL-PARMS.
           05  MU-FUNCTION         PIC X(8).
               88  MU-GCD                    VALUE "GCD".
           05  MU-A                PIC 9(9).
           05  MU-B                PIC 9(9).
           05  MU-RESULT           PIC 9(9).
           05  MU-RC               PIC 9(2).
               88  MU-OK                     VALUE 0.
               88  MU-INVALID                VALUE 10.
               88  MU-BAD-FUNCTION           VALUE 90.
```

…the module `lib/src/MATHUTIL.cob`, whose core is the dispatch and the work paragraph:

```cobol
       MAIN-PARA.
           SET MU-OK TO TRUE
           MOVE 0 TO MU-RESULT
           EVALUATE TRUE
               WHEN MU-GCD
                   PERFORM DO-GCD
               WHEN OTHER
                   SET MU-BAD-FUNCTION TO TRUE
           END-EVALUATE
           GOBACK.

       DO-GCD.
           IF MU-A = 0 AND MU-B = 0
               SET MU-INVALID TO TRUE
           ELSE
               MOVE MU-A TO WS-X
               MOVE MU-B TO WS-Y
               PERFORM UNTIL WS-Y = 0
                   MOVE FUNCTION MOD(WS-X, WS-Y) TO WS-R
                   MOVE WS-Y TO WS-X
                   MOVE WS-R TO WS-Y
               END-PERFORM
               MOVE WS-X TO MU-RESULT
           END-IF.
```

…and `lib/tests/TEST-MATHUTIL.cob`, with a normal case, an edge case, an invalid-input case and an unknown-function case.

### Step 2: Claude checks its own work

```
cobol-lint: clean (23 files checked)
```

```
cobc -m -Wall -I lib/copybooks -o build/lib/MATHUTIL.so lib/src/MATHUTIL.cob
cobc -x -Wall -I lib/copybooks -o build/bin/TEST-MATHUTIL lib/tests/TEST-MATHUTIL.cob
TEST-MATHUTIL
  PASS  GCD of 48 and 18 is 6
  PASS  GCD with one zero is the other number
  PASS  GCD of 0 and 0 returns RC 10
  PASS  unknown function returns RC 90
  0004 run, 0000 failed
```

It also adds a `MATHUTIL` row to the table in `lib/README.md`.

### Step 3: grow it

> **You:** add LCM to MATHUTIL

The `new-lib-module` conventions and `add-lib-tests` work together here:
- a new `88 MU-LCM VALUE "LCM"`;
- a `WHEN MU-LCM` branch and a `DO-LCM` paragraph (LCM = A × B / GCD);
- new tests, including what happens when the result doesn't fit in `PIC 9(9)`;
- an updated row in `lib/README.md`.

### Step 4: teach it

> **You:** `/new-tutorial calling MATHUTIL to simplify fractions`

This creates lesson 09. Its header explains how a `CALL` finds `MATHUTIL.so` at run time, and its code simplifies 12/18 → 2/3, using MATHUTIL to find the GCD. The skill adds it to the lesson table and adds an exercise such as "add a fraction with a zero denominator — what should happen?".

### Step 5: run it all

> **You:** run everything and the tests

```powershell
.\build.ps1
.\build.ps1 test
```

You should see `ALL TESTS PASSED`.

---

## 7. Handy combinations

| Goal | Say |
|---|---|
| A new example with clean data | `make a grade-report example with 10 students of sample data`. **new-example** uses **cobol-data-file** for the data, then **cobol-build-run** to run it. |
| Tidy before committing | `lint everything and fix what you find, then run the tests`. That's **cobol-lint**, then **cobol-build-run**. |
| Harden a module | `look at STRUTIL and add tests for anything untested`. **add-lib-tests** then runs that driver. |
| Learn from an error | `why does this compile error mention a continuation character?` **cobol-build-run** explains it, then **cobol-lint** finds the long line. |
| Try an exercise | `do exercise 07 from the tutorials README, explain each change`. **cobol-data-file** and **cobol-build-run** help. |

---

## 8. Troubleshooting

### `cobc: command not found`

1. **From the Git Bash tool?** That's expected. Use PowerShell: `wsl cobc --version`.
2. **From PowerShell too?** Check which Linux is the default:
   ```powershell
   wsl -l -v
   ```
   Ubuntu should have the `*`. If it doesn't: `wsl --set-default Ubuntu`.
3. **Still missing?** Install it inside Ubuntu:
   ```bash
   sudo apt install gnucobol make
   ```

### A confusing error on a line that looks fine

```
toolong.cob:6: error: continuation character expected
toolong.cob:5: error: syntax error, unexpected end of file
```

Line 5 ran past column 72. cobc cut off the closing quote, so it thought the literal continued onto line 6. Run `/cobol-lint` to find the line, then split the statement.

### `invalid file base name 'long' - name duplicates a 'C' keyword`

GnuCOBOL compiles through C, so file names such as `long`, `int`, `char` or `switch` aren't allowed. Rename the file.

### `libcob: error: module 'FOO' not found`

- `build.ps1 run` and `build.ps1 test` build the library first, so if you used those, check that `PROGRAM-ID` in `lib/src/FOO.cob` is exactly `FOO`. `/cobol-lint` checks this.
- If you ran a binary **by hand** inside WSL, set the path: `COB_LIBRARY_PATH=build/lib ./build/bin/NAME`.

### File status `35` when opening a data file

The file wasn't found. Programs run from **their own folder**, so `ASSIGN TO "employees.dat"` means the file must sit next to the `.cob`.

### Wrong numbers or shifted fields from a `.dat` file

The data doesn't match the record layout. Ask: `check employees.dat against the FD in files.cob`. Also make sure your editor isn't stripping trailing spaces (the repo's [.editorconfig](../../.editorconfig) already turns that off for `*.dat`).

### A test fails and make says `Error 1`

That's how a failure is reported. Read the `FAIL` lines above it, which show `expected [...]` and `actual [...]`.

---

## 9. Changing or adding skills

Skills are plain Markdown, so you can edit them like any other file.

### Tweak an existing skill

Open `.claude/skills/<name>/SKILL.md` and edit the steps. For example, to make every new tutorial end with a quiz, add this line to the *Style reminders* in `new-tutorial/SKILL.md`:

```markdown
- End the header comment with a 3-question "Check yourself" quiz.
```

### Make a skill trigger more (or less) often

Claude chooses a skill by its `description`. Add the words you naturally use. For example, if you say "kata" for small exercises, add "kata" to the description of `new-example`.

### Add a new skill

1. Create `.claude/skills/my-skill/SKILL.md`:
   ```markdown
   ---
   name: my-skill
   description: What it does, and the phrases that should trigger it.
   argument-hint: "[what to pass]"
   ---

   # my-skill

   1. Step one...
   2. Verify with `bash .claude/skills/cobol-lint/check.sh` and `.\build.ps1 test`.
   ```
2. Inside a skill, `$ARGUMENTS` stands for whatever is typed after `/my-skill`.
3. Restart Claude Code, or start a new session, so it picks the skill up.

You can also ask Claude: *"make a skill that ..."*.

### Change the module templates

The files in `.claude/skills/new-lib-module/templates/` are ordinary COBOL with `@MOD@`, `@PFX@`, `@FUNC@` and `@DESC@` placeholders. After editing them, keep every line within 72 columns. You can check them with:

```bash
bash .claude/skills/cobol-lint/check.sh .claude/skills/new-lib-module/templates/*
```

---

## 10. Cheat sheet

```text
/cobol-build-run [all|test|clean|path\to\prog.cob]   build / test / run
/cobol-lint [file ...]                               format check (read-only)
/new-lib-module NAME [what it does]                  copybook + module + tests
/add-lib-tests NAME [what to test]                   more test cases
/new-tutorial topic [number]                         next numbered lesson
/new-example name [what it does]                     complete program (+ data)
/cobol-data-file file.dat|prog.cob [records]         fixed-width data
```

```powershell
.\build.ps1                                     # build everything
.\build.ps1 test                                # all tests
.\build.ps1 run -Name lib\tests\TEST-FOO.cob    # one test driver
.\build.ps1 run -Name tutorials\01-hello\hello.cob
.\build.ps1 clean
```

```bash
bash .claude/skills/cobol-lint/check.sh         # lint (Git Bash is fine)
```

The fixed-format rules in one line: cols 1–6 sequence area · col 7 indicator · cols 8–11 Area A · cols 12–72 Area B · anything past 72 is ignored.
