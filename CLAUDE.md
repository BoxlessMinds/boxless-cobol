# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

A COBOL learning playground: numbered lessons in `tutorials/`, complete programs in `examples/`, and a small reusable library with unit tests in `lib/`. Compiled with GnuCOBOL (`cobc`), which is installed **inside WSL**, not on Windows.

## Commands

All build logic is in the [Makefile](Makefile), which runs in WSL. From Windows, [build.ps1](build.ps1) forwards targets via `wsl make`:

```powershell
.\build.ps1                                          # build lib, tutorials, examples, tests
.\build.ps1 test                                     # build + run every lib/tests/TEST-*.cob
.\build.ps1 run -Name tutorials\07-files\files.cob   # build + run one program
.\build.ps1 clean                                    # delete build/
```

- **Single test:** `.\build.ps1 run -Name lib\tests\TEST-STRUTIL.cob` (a test driver is just a program; exit code 1 means a failed assertion).
- Inside WSL use `make`, `make test`, `make run NAME=path/to/file.cob`.
- Run builds from the **PowerShell** tool: `wsl cobc`/`wsl make` called from the Git Bash tool fails with `cobc: command not found`.
- Lint (read-only, Git Bash fine): `bash .claude/skills/cobol-lint/check.sh [files]`.
- There is no linter; `cobc -Wall` warnings are the lint. Compiler diagnostics use `file:line: error|warning: msg`.

## Build model (Makefile)

- Every `tutorials/*/*.cob`, `examples/*/*.cob` and `lib/tests/*.cob` compiles with `cobc -x` to `build/bin/<basename>`. Basenames share one flat directory, so **each program's file basename must be unique** across the repo. New programs are picked up automatically by wildcard.
- Every `lib/src/*.cob` compiles with `cobc -m` to `build/lib/<NAME>.so`.
- `-I lib/copybooks` is always on the path, so any program can `COPY FOO-PARMS.`. All binaries depend on all copybooks.
- `make run` `cd`s into the program's own folder before executing, so relative data files (e.g. `employees.dat`, `payroll.dat`) resolve next to the source.
- `COB_LIBRARY_PATH` is exported as `build/lib`; library calls are **dynamic** (`CALL "STRUTIL"` loads `STRUTIL.so` at run time), so `lib` must be built before running callers — `run` and `test` depend on it.

## Library conventions (`lib/`)

See [lib/README.md](lib/README.md). Each module:
- takes a single parameter block `01 FOO-PARMS` defined in `lib/copybooks/FOO-PARMS.cpy`, with 88-levels for function codes and return code;
- dispatches on a function code field (e.g. `SU-FUNCTION`, `DU-FUNCTION`) via `EVALUATE TRUE`;
- sets a 2-digit return code: `00` OK, `10` invalid input, `90` unknown function;
- has `PROGRAM-ID` matching the filename, `COPY FOO-PARMS.` in LINKAGE, `PROCEDURE DIVISION USING FOO-PARMS`, ends with `GOBACK`.

Tests use a tiny copybook harness: `COPY TEST-WS.` in WORKING-STORAGE and `COPY TEST-PROC.` at the end of the PROCEDURE DIVISION. Per case: move into `TEST-NAME`, `TEST-EXPECTED`, `TEST-ACTUAL` (alphanumeric, so compare numeric fields as their display form, e.g. `"012"`), then `PERFORM ASSERT-EQUAL`. End with `PERFORM TEST-SUMMARY` then `STOP RUN` (sets `RETURN-CODE`).

## Source format gotchas

- **Fixed format:** cols 1–6 sequence area, col 7 indicator (`*` comment), code in cols 8–72. Anything past col 72 is silently ignored — keep lines ≤ 72 chars (`.editorconfig` enforces it).
- Files use LF line endings (`.gitattributes`), except `.ps1/.cmd/.bat` (CRLF).
- `*.dat` files are fixed-width records: never strip trailing whitespace or change line endings — record layouts depend on exact column positions.
- File basenames must not be C keywords (`long`, `int`, `switch`...); cobc rejects them.
- Tutorials teach via the comment block at the top of each program; keep that style when editing lessons. Update `tutorials/README.md` / `examples/README.md` / `lib/README.md` tables when adding entries.

## Workspace skills (`.claude/skills/`)

Use these instead of re-deriving the conventions above; user guide: [DOCUMENTATION/GUIDES/claude-skills-guide.md](DOCUMENTATION/GUIDES/claude-skills-guide.md).

- `cobol-build-run`: build/run/test via `.\build.ps1`, environment preflight, diagnosing cobc errors
- `cobol-lint`: `check.sh` fixed-format/data-file checker; run after editing any `.cob`/`.cpy`/`.dat`
- `new-lib-module`: copybook + module + test driver from compile-tested `templates/`
- `add-lib-tests`: add cases to a `TEST-*.cob` driver
- `new-tutorial`: next numbered lesson + README row/exercise
- `new-example`: complete program in `examples/` (+ data)
- `cobol-data-file`: fixed-width `.dat` records from an FD layout
