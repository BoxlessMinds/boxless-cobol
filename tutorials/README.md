# Tutorials

Work through the lessons in order. Each lesson is a single program. The comments at the top of the program are the lesson, and the code underneath demonstrates it.

Run a lesson with `.\build.ps1 run -Name tutorials\NN-topic\file.cob`, then change the program and run it again.

| # | Lesson | Covers |
|---|---|---|
| 01 | [hello](01-hello/hello.cob) | Program structure, divisions, fixed-format columns |
| 02 | [data-division](02-data-division/datadiv.cob) | Level numbers, PIC clauses, group items, 88-levels, edited pictures |
| 03 | [arithmetic](03-arithmetic/arith.cob) | ADD/SUBTRACT/MULTIPLY/DIVIDE, COMPUTE, ROUNDED, ON SIZE ERROR |
| 04 | [control-flow](04-control-flow/control.cob) | IF, EVALUATE, PERFORM (paragraph, TIMES, VARYING, UNTIL) |
| 05 | [tables](05-tables/tables.cob) | OCCURS, INDEXED BY, REDEFINES-loaded tables, SEARCH, SEARCH ALL |
| 06 | [strings](06-strings/strings.cob) | STRING, UNSTRING, INSPECT, reference modification, intrinsic functions |
| 07 | [files](07-files/files.cob) | SELECT/FD, OPEN/READ/WRITE/CLOSE, FILE STATUS, read loops |
| 08 | [subprograms](08-subprograms/subprog.cob) | CALL, LINKAGE SECTION, BY REFERENCE vs BY CONTENT, nested programs, the [lib/](../lib/) modules |

## Exercises

- **02:** add an `88 WS-OVERDRAWN` condition. Test it on a negative balance.
- **03:** change `WS-SMALL` to `PIC 9(4)` and watch the size error go away.
- **05:** add a fifth product. What breaks, and why does `SEARCH ALL` care about the order?
- **07:** write the employees whose salary is below 50,000 to a second output file.
- **08:** add a `LOWER` call. Then write your own module in `lib/`, following [lib/README.md](../lib/README.md).
