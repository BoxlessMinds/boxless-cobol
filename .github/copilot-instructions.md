# Copilot instructions

The full project guide is [CLAUDE.md](../CLAUDE.md). Read it before
building, editing COBOL, or adding programs. The essentials:

- GnuCOBOL (`cobc`) and `make` are installed **inside WSL**, not on
  Windows. Build from PowerShell with `.\build.ps1` (`test`, `clean`,
  `run -Name path\to\file.cob`). Inside WSL use `make` directly.
- Sources are **fixed format**: code in columns 8–72, `*` in column 7
  for comments. Anything past column 72 is silently ignored.
- Each program's file basename must be unique across the repo, and must
  not be a C keyword.
- `*.dat` files are fixed-width records. Never strip trailing
  whitespace or change their line endings.
- Use LF line endings, except `.ps1`/`.cmd`/`.bat` (CRLF).
- Library modules in `lib/` follow the conventions in
  [lib/README.md](../lib/README.md): one parameter-block copybook,
  function-code dispatch, return codes `00`/`10`/`90`.
- When adding a tutorial, example or library module, update the table
  in that folder's README.
- Write any guide, analysis, findings, README or other documentation
  to be detailed, easy to follow and approachable for someone new to
  COBOL. See "Writing documentation" in CLAUDE.md.
- Draw diagrams in PlantUML when the `jebbs.plantuml` VS Code extension
  is installed (check `code --list-extensions`), otherwise in Mermaid.
  Save the source as a `.puml` file, pre-render it to a `.png` with the
  same name, and embed the PNG with a link to the source. See
  "Diagrams" in CLAUDE.md for how to render.
- Lint after editing `.cob`/`.cpy`/`.dat` files:
  `bash .claude/skills/cobol-lint/check.sh [files]`.

The step-by-step workflows in `.claude/skills/*/SKILL.md` (new lesson,
new example, new library module, adding tests, data files) apply to
Copilot too. Open the relevant one and follow it.
