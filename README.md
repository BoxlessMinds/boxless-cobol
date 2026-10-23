# COBOL Playground

A personal workspace for learning and writing COBOL. It has three parts:

- **[tutorials/](tutorials/)**: numbered lessons, each a small, heavily commented program.
- **[examples/](examples/)**: small complete programs.
- **[lib/](lib/)**: reusable copybooks and callable modules, with unit tests.

## Prerequisites

- Windows with **WSL** and **GnuCOBOL** installed inside it. On Ubuntu, run `sudo apt install gnucobol make`.
- Check the install with `wsl cobc --version`. This repo was built against GnuCOBOL 4.0-early-dev, and 3.x should also work.
- VS Code with the recommended extensions in [.vscode/extensions.json](.vscode/extensions.json). These are optional.

## Build, run, test

All build logic lives in the [Makefile](Makefile), which runs inside WSL. On Windows, [build.ps1](build.ps1) forwards targets to it:

```powershell
.\build.ps1                                              # build everything
.\build.ps1 test                                         # run library unit tests
.\build.ps1 run -Name tutorials\07-files\files.cob       # build + run one program
.\build.ps1 clean                                        # delete build/
```

Inside a WSL shell, run `make`, `make test` or `make run NAME=...` directly.

In VS Code, **Ctrl+Shift+B** builds everything. Use *Terminal → Run Task → COBOL: build & run current file* to build and run the open program.

Build output goes to `build/`, which git ignores:
- `build/bin/` holds the executables.
- `build/lib/` holds the library modules (`.so`).

`make run` executes a program from its own folder, so relative data files such as `employees.dat` resolve there. It also sets `COB_LIBRARY_PATH` so `CALL "STRUTIL"` can find the library modules.

## Layout

```
tutorials/NN-topic/   lesson source + README
examples/<name>/      example program + any data files
lib/copybooks/        *.cpy shared layouts (COPY ...)
lib/src/              callable modules, one per file -> build/lib/*.so
lib/tests/            TEST-*.cob unit-test drivers
CONTEXT/              plans, prompts, recipes, skills (notes for AI-assisted work)
DOCUMENTATION/        findings and longer-form notes
SCRATCH_FOLDER/       personal scratch space (git-ignored)
```

## Adding code

- **A new program:** create `tutorials/NN-topic/name.cob` or `examples/<name>/name.cob`. The Makefile picks it up automatically.
  - Use a file basename that no other program uses, because every executable lands in `build/bin/`.
- **A library module:** see [lib/README.md](lib/README.md).

Sources use **fixed format**:
- columns 1–6 are the sequence area
- column 7 is the indicator
- code goes in columns 8–72

The editor shows rulers at those columns.
