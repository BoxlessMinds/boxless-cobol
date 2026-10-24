---
name: add-lib-tests
description: Add unit-test cases to a library module's COBOL test driver (lib/tests/TEST-*.cob) using this repo's copybook test harness (TEST-NAME / TEST-EXPECTED / TEST-ACTUAL / PERFORM ASSERT-EQUAL), then run that test. Use when the user asks to test a lib module, add test cases or edge cases, reproduce a bug as a failing test, raise coverage, or check a function's return codes.
argument-hint: "MODULE-NAME [function or behaviour to test]"
---

# add-lib-tests

The harness is `lib/copybooks/TEST-WS.cpy` (the fields) plus `lib/copybooks/TEST-PROC.cpy` (the `ASSERT-EQUAL` and `TEST-SUMMARY` paragraphs). The driver for module `FOO` is `lib/tests/TEST-FOO.cob`.

## The case pattern
Every case has four moves and a perform. Insert new cases **before** `PERFORM TEST-SUMMARY`:

```cobol
           MOVE "FORMAT pads month with zero" TO TEST-NAME
           MOVE "FORMAT" TO DU-FUNCTION
           MOVE 20260105 TO DU-DATE-NUM
           CALL "DATEUTIL" USING DATEUTIL-PARMS
           MOVE "2026-01-05" TO TEST-EXPECTED
           MOVE DU-RESULT TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL
```

- `TEST-NAME` is `PIC X(50)`: keep names short and specific, starting with the function code.
- To make several assertions on one CALL, just set a new `TEST-NAME`/`EXPECTED`/`ACTUAL` and `PERFORM ASSERT-EQUAL` again, without a new CALL (see "UPPER sets length" in `TEST-STRUTIL.cob`).
- Reset any input fields a previous case left set.

## Comparing values
`TEST-EXPECTED` and `TEST-ACTUAL` are `PIC X(80)`, so every comparison is a text comparison:

| Actual field | Write expected as |
|---|---|
| `PIC 9(3)` value 12 | `"012"` (all digits, leading zeros) |
| `PIC 9(2)` RC | `"00"`, `"10"`, `"90"` |
| `PIC S9(5)` value -42 | Move it to an edited field first, e.g. `01 WS-SHOW PIC -(5)9.`, and compare `"   -42"`. |
| `PIC 9(3)V99` 12.50 | You can't `MOVE` it straight to `TEST-ACTUAL`: cobc rejects that with `invalid MOVE statement`. Move it to an edited field first, e.g. `01 WS-SHOW-AMT PIC ZZ9.99.`, and compare `" 12.50"`. |
| Text | The literal; trailing spaces don't matter |

## Which cases to add
For each function:
- one normal case;
- the boundaries: zero, empty or all spaces, maximum length, first and last valid value, leap years for dates;
- invalid input expecting RC `10`.

Keep one RC `90` case per driver. For a bug report, write the failing case first, watch it fail, then fix the module.

## Run just this driver (PowerShell tool)
```powershell
.\build.ps1 run -Name lib\tests\TEST-FOO.cob
```
A failure prints `FAIL`, then `expected [..]` and `actual [..]`, and make exits with an error, because the driver sets `RETURN-CODE 1`. Finish with `.\build.ps1 test` to confirm the whole suite still passes, and lint with `bash .claude/skills/cobol-lint/check.sh lib/tests/TEST-FOO.cob`.
