# COBOL Playground

A personal workspace for learning and writing COBOL. It has four parts:

- **[tutorials/](tutorials/)**: numbered lessons, each a small, heavily commented program.
- **[examples/](examples/)**: small complete programs.
- **[lib/](lib/)**: reusable copybooks and callable modules, with unit tests.
- **[museum/](museum/)**: a static website about COBOL's history and design (see [The COBOL Museum](#the-cobol-museum)).

## Prerequisites

- Windows with **WSL** and **GnuCOBOL** installed inside it. On Ubuntu, run `sudo apt install gnucobol make`.
- Check the install with `wsl cobc --version`. This repo was built against GnuCOBOL 4.0-early-dev, and 3.x should also work.
- VS Code with the recommended extensions in [.vscode/extensions.json](.vscode/extensions.json). These are optional.

## Quick start

1. Install the prerequisites above.
2. Run `.\build.ps1 test` from the repo root. Every test should pass.
3. Run your first lesson: `.\build.ps1 run -Name tutorials\07-files\files.cob`.

### Let an AI assistant set it up

If you use **Claude Code** or **GitHub Copilot** (agent mode in VS Code Chat), you can ask it to do the setup for you. Open the repo and paste this prompt:

```text
Set up this COBOL playground on my machine. Read CLAUDE.md and
README.md first. Check that WSL is installed and that GnuCOBOL and
make are available inside it (wsl cobc --version, wsl make --version).
If anything is missing, tell me the exact commands to install it and
wait for me to confirm before running anything that needs sudo.
Then run .\build.ps1 test from PowerShell, fix or explain any
failures, and finish by running one tutorial program.
```

- **Claude Code** reads [CLAUDE.md](CLAUDE.md) automatically and has project skills in [.claude/skills/](.claude/skills/). You can also just say "build and run the tests" and it will use the `cobol-build-run` skill. See [the skills guide](DOCUMENTATION/GUIDES/claude-skills-guide.md).
- **Copilot** loads [.github/copilot-instructions.md](.github/copilot-instructions.md), which summarizes the repo rules and points to `CLAUDE.md`. Use agent mode so it can run terminal commands.
- Review each command before you approve it, especially anything that installs packages.

## The COBOL Museum

[museum/](museum/) is a small static website that tells the story behind the code: where COBOL came from, how a program is put together, and why it still runs payroll and banks. Visit it at **<https://boxlessminds.github.io/boxless-cobol/>**, or open [museum/index.html](museum/index.html) in a browser. It needs no build step or server. Every push to `main` that changes `museum/` republishes the site through [.github/workflows/pages.yml](.github/workflows/pages.yml).

Some galleries tie straight back to this repo:

- **[Divisions](museum/divisions.html)**: the four divisions every program here is built from.
- **[Verbs](museum/verbs.html)**: `MOVE`, `PERFORM` and friends, next to how other languages say the same thing.
- **[Punch cards](museum/punch-cards.html)**: why the source still stops at column 72.
- **[Workshop](museum/workshop.html)**: a guided path through installing GnuCOBOL and this repo's lessons, examples and library.
- **[Quiz](museum/quiz.html)**: ten questions, with a printable badge for a score of 7 or more.

The other galleries cover the origins, the timeline of standards, the Y2K problem and where COBOL is still in use today.

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
museum/               static COBOL Museum site (open index.html)
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

## License

The code, lessons and museum text are released under the [MIT License](LICENSE). The AI-generated images in [museum/assets/img/](museum/assets/img/) are dedicated to the public domain under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/). See the image credits on the museum's [Reading Room](museum/resources.html) page.
