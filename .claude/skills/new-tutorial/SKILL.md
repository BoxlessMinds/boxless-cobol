---
name: new-tutorial
description: Write a new numbered COBOL lesson in tutorials/ in this repo's teaching style - one heavily commented program whose header comment is the lesson, plus a row and an exercise in tutorials/README.md - then build and run it. Use when the user wants a new tutorial, lesson, or walkthrough of a COBOL topic (e.g. "a lesson on SORT", "teach me COMPUTE with intrinsic functions", "add tutorial 09").
argument-hint: "topic [lesson number]"
---

# new-tutorial

## Steps
1. **Number and names.** List `tutorials/` and use the next free `NN` (two digits). Folder `tutorials/NN-topic-in-kebab-case/`.
   - Pick a short lower-case file basename that no other `.cob` in the repo uses: `bash .claude/skills/cobol-lint/check.sh` reports duplicates.
   - The basename must not be a C keyword (`long`, `int`, `char`, `case`, `switch`, `void`, ...). cobc refuses it with `invalid file base name`.
   - `PROGRAM-ID` is the basename in upper case (≤ 8 characters is the tradition here: `HELLO`, `DATADIV`, `SUBPROG`).
2. **Check prerequisites.** Read the `tutorials/README.md` table so the lesson builds on earlier ones and doesn't re-teach them.
3. **Write the program.** Copy the house style from `tutorials/01-hello/hello.cob` and `tutorials/07-files/files.cob`:
   - `IDENTIFICATION DIVISION.` / `PROGRAM-ID.`, then a boxed comment header (`      *****...` rule lines, `      * ` text lines) titled `Lesson NN - Title`, with a short explanation and an aligned cheat-sheet of the statements covered.
   - The code underneath demonstrates each point in order. Add a short `*` comment before each demo block, and `DISPLAY` labelled output so a run explains itself.
   - Keep it a single program that runs with no input. If it needs a data file, put it next to the `.cob` and build it with the `cobol-data-file` skill. To use the library, `COPY xxx-PARMS.` and `CALL`.
   - Fixed format: code in cols 8–72 and Area A (col 8) only for division, section, paragraph and `01`/`FD` names.
4. **Update `tutorials/README.md`.** Add a table row `` | NN | [topic](NN-topic/file.cob) | what it covers | `` and one line under *Exercises* (`- **NN:** ...`) that asks the learner to change something and predict the result.
5. **Verify.**
   - `bash .claude/skills/cobol-lint/check.sh` (Bash tool).
   - `.\build.ps1 run -Name tutorials\NN-topic\file.cob` (PowerShell tool). It must compile without warnings, and the output must match what the comments promise.
6. Show the user the run output and the exercise.

## Style reminders
- Explain why, not just what; the comment header is the lesson text.
- Prefer one concept per demo paragraph, `PERFORM`ed from `MAIN-PARA` in order.
- End with `STOP RUN.`
