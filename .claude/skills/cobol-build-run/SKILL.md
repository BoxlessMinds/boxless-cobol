---
name: cobol-build-run
description: Build, run and test the COBOL programs in this repo with GnuCOBOL inside WSL, and diagnose and fix compile or runtime errors. Use when the user asks to build, compile, run, execute or test a program, run the unit tests, clean the build, or when cobc reports errors or warnings, a CALL fails with "module not found", or a program cannot open its data file.
argument-hint: "[all|test|clean|path\\to\\program.cob]"
---

# cobol-build-run

GnuCOBOL (`cobc`) lives inside **WSL**, at `/usr/bin/cobc` in the default Ubuntu distro. Always build through **the PowerShell tool** with `.\build.ps1`. Calling `wsl ...` from the Git Bash tool fails with `cobc: command not found`.

## Commands (PowerShell tool, repo root)

| Goal | Command |
|---|---|
| Build everything | `.\build.ps1` |
| Run all library tests | `.\build.ps1 test` |
| Build and run one program | `.\build.ps1 run -Name tutorials\07-files\files.cob` |
| Run a single test driver | `.\build.ps1 run -Name lib\tests\TEST-STRUTIL.cob` |
| Delete `build/` | `.\build.ps1 clean` |

Map `$ARGUMENTS` like this: empty or `all` → build everything; `test` → run the tests; `clean` → clean; a `.cob` path → `run -Name <path>`.

## Steps
1. **Preflight** (once per session): run `wsl cobc --version`. If that fails:
   - run `wsl -l -v`; Ubuntu must be the default (`*`) distro (`wsl --set-default Ubuntu`);
   - tell the user to run `sudo apt install gnucobol make` inside Ubuntu. Don't run sudo yourself.
2. If you changed sources, first run the `cobol-lint` skill's checker (`bash .claude/skills/cobol-lint/check.sh`). Truncation past column 72 causes misleading compile errors.
3. Run the command and read the output.
4. On failure, fix the source and re-run. Report the final result honestly, with the failing output if it still fails.

## Reading diagnostics
cobc prints `path:line: error: message` (or `warning:`). Open that line and look at the lines before it too, because COBOL errors often surface one statement late.

| Symptom | Likely cause |
|---|---|
| `syntax error, unexpected ...` at the start of a paragraph | Missing period at the end of the previous paragraph, or a period lost past col 72 |
| `continuation character expected` / `unexpected end of file` | A line ran past column 72 and cobc cut off the closing quote of a literal |
| `invalid file base name 'x' - name duplicates a 'C' keyword` | Rename the file (`long.cob`, `int.cob` and similar are not allowed) |
| `'X' is not defined` | Typo, or a missing `COPY xxx-PARMS.` in WORKING-STORAGE/LINKAGE |
| `libcob: error: module 'FOO' not found` | `build/lib/FOO.so` isn't built (`run` and `test` build `lib` first, so check the module's PROGRAM-ID matches its file name) or `COB_LIBRARY_PATH` isn't set (only when running a binary by hand) |
| File status `35` on OPEN | Data file not found. `make run` runs the program from **its own folder**, so `ASSIGN TO "x.dat"` means `x.dat` next to the `.cob` |
| Wrong numbers or garbage fields from a `.dat` | Record columns don't match the FD; run the `cobol-data-file` skill |
| `make: *** [run] Error 1` after output | The program set a non-zero RETURN-CODE (test drivers do this when an assertion fails) |

## Facts about the build (see Makefile)
- Flags: `-Wall -I lib/copybooks`. Main programs build with `cobc -x` to `build/bin/<basename>`; `lib/src/*.cob` builds with `cobc -m` to `build/lib/<NAME>.so`.
- Every binary depends on every copybook, so editing a `.cpy` rebuilds everything.
- To run a binary by hand inside WSL: `COB_LIBRARY_PATH=build/lib ./build/bin/NAME`, run from the program's folder if it reads files.
