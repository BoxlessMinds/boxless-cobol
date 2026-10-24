---
name: cobol-lint
description: Check COBOL sources and fixed-width data files in this repo for fixed-format mistakes before compiling - lines past column 72, tabs, CRLF line endings, code in the wrong column, duplicate program basenames, lib PROGRAM-ID not matching the file name, and .dat records of unequal length. Use when the user asks to lint, check, validate or tidy COBOL code, when a compile error looks like truncation, and after creating or editing any .cob, .cpy or .dat file.
argument-hint: "[file ...]"
---

# cobol-lint

Run the bundled read-only checker. It needs no WSL, just bash, awk and grep, so the Bash tool is fine:

```bash
bash .claude/skills/cobol-lint/check.sh                 # whole repo
bash .claude/skills/cobol-lint/check.sh $ARGUMENTS      # specific files
```

Exit code 0 prints `cobol-lint: clean (N files checked)`; exit code 1 lists one `file:line: problem` per line.

## What each finding means and how to fix it

| Finding | Why it matters | Fix |
|---|---|---|
| `NN columns; text past column 72 is ignored` | cobc silently drops columns 73+, which often removes a period or the end of a literal and produces a confusing error somewhere else | Break the statement over two lines, indented in Area B (col 12+). For long literals use `STRING` or a continuation line (`-` in col 7). |
| `TAB character` | Tabs make column positions unpredictable | Replace with spaces |
| `line(s) end in CR` | `.gitattributes` wants LF, and a CR at the end of a `.dat` record becomes part of the last field | Convert to LF, e.g. `sed -i 's/\r$//' FILE` |
| `column 7 is "X"` | Column 7 is the indicator area (space, `*`, `/`, `-`, `D`). Code must start in column 8 or later | Re-indent the line |
| `duplicate program basename` | Every main program builds to `build/bin/<basename>`, so the second one overwrites the first | Rename one file |
| `PROGRAM-ID is ... but the file name needs ...` | `CALL "FOO"` loads `build/lib/FOO.so`, so the module's PROGRAM-ID must equal the file name | Make them match |
| `record is N chars, most records are M` | Fixed-width records are read by column position | Pad with spaces or trim to the record length; see the `cobol-data-file` skill |
| `no newline at end of file` | The last record may be read short | Add a final LF |

Report the findings to the user grouped by file, fix only what they asked for (or everything, if they asked you to fix), then re-run the check.

## Notes
- The checker never modifies files.
- A `.dat` file's "expected" length is its most common line length. If most lines are wrong, compare against the FD record layout in the program that reads the file.
