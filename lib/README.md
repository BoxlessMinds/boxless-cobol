# Library

Code that is meant to be reused across programs.

| Path | What |
|---|---|
| `copybooks/*.cpy` | Shared data layouts. `-I lib/copybooks` is on the compile path, so `COPY STRUTIL-PARMS.` just works. |
| `src/*.cob` | Callable subprograms. Each one compiles to `build/lib/<NAME>.so`. |
| `tests/TEST-*.cob` | Unit-test drivers. `make test` runs every one of them and fails if any assertion fails. |

## Modules

| Module | Parameters | Functions |
|---|---|---|
| `STRUTIL` | `STRUTIL-PARMS.cpy` | `UPPER`, `LOWER`, `TRIM`, `REVERSE`. Each one also sets `SU-LENGTH`. |
| `DATEUTIL` | `DATEUTIL-PARMS.cpy` | `VALIDATE`, `FORMAT` (YYYY-MM-DD), `DOW` (day name) |

Each module follows the same convention:
- It takes **one parameter block**, defined in a copybook.
- It selects behaviour with a function code.
- It reports the result in a 2-digit return code:
  - `00` means OK.
  - `10` means invalid input.
  - `90` means an unknown function.

```cobol
       WORKING-STORAGE SECTION.
       COPY DATEUTIL-PARMS.
       ...
           MOVE "FORMAT" TO DU-FUNCTION
           MOVE 20261023 TO DU-DATE-NUM
           CALL "DATEUTIL" USING DATEUTIL-PARMS
           IF DU-OK
               DISPLAY DU-RESULT
           END-IF
```

The call is dynamic: at run time GnuCOBOL looks for `DATEUTIL.so` on `COB_LIBRARY_PATH`. The Makefile exports that variable, set to `build/lib`.

## Adding a module

1. `copybooks/FOO-PARMS.cpy`: the `01 FOO-PARMS` block, with 88-levels for the function codes and the return code.
2. `src/FOO.cob`: set `PROGRAM-ID. FOO.` to match the file name, put `COPY FOO-PARMS.` in the LINKAGE SECTION, declare `PROCEDURE DIVISION USING FOO-PARMS`, and end with `GOBACK`.
3. `tests/TEST-FOO.cob`: `COPY TEST-WS.` in working storage and `COPY TEST-PROC.` at the end of the procedure division. Then for each case, set `TEST-NAME`, `TEST-EXPECTED` and `TEST-ACTUAL` and `PERFORM ASSERT-EQUAL`. Finish with `PERFORM TEST-SUMMARY` and `STOP RUN`.
4. Run `.\build.ps1 test`.
