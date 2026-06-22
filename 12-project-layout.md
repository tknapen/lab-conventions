# 12 — Project layout

## The canonical directory tree

```
myproject/
├── pyproject.toml          # uv + pixi + ruff + pytest + pyrefly config
├── uv.lock
├── pixi.lock               # only if [tool.pixi.*] is used
├── README.md
├── CLAUDE.md               # project-specific instructions; references lab-conventions/
├── justfile                # standard commands; see 13-commands.md
├── .pre-commit-config.yaml
├── .gitignore
├── .claude/
│   ├── settings.json       # permissions, hooks (see below)
│   ├── commands/           # project-specific slash commands
│   ├── agents/             # project-specific subagents
│   └── skills/             # project-specific skills
├── lab-conventions/        # submodule / subtree / symlink (read-only)
│   └── ... (this directory)
├── src/
│   └── myproject/          # the installable package; snake_case
│       ├── __init__.py
│       ├── io.py
│       ├── preprocess.py
│       ├── models.py
│       ├── fitting.py
│       └── viz.py
├── tests/                  # pytest; mirrors src/ layout
│   └── test_*.py
├── notebooks/              # marimo .py files; thin
│   ├── 01_data_qc.py
│   ├── 02_model_fitting.py
│   └── archive/            # legacy .ipynb during migration
├── workflow/               # Snakemake
│   ├── Snakefile
│   └── rules/
├── scripts/                # one-off PEP 723 inline-metadata scripts
├── docs/                   # Quarto or Jupyter Book 2; optional
├── data/
│   ├── raw/                # READ-ONLY. Symlink to shared storage; never write.
│   ├── processed/          # deterministic, pipeline-produced
│   └── generated/          # AI-produced / exploratory; disposable
├── results/
│   ├── figures/            # final figures only; regenerable from src/viz.py
│   └── tables/
└── logs/                   # job logs, ignored by git
```

## Hard rules

- **`src/` layout is mandatory**: `src/myproject/__init__.py`, not `myproject/__init__.py`. Prevents accidental import of the source tree instead of the installed package during testing.
- **`data/raw/` is read-only.** Enforced by `.claude/settings.json` deny rules and by file-system permissions where possible. Symlink to shared lab storage; never copy in, never write.
- **`data/processed/` is produced by `workflow/`** (Snakemake). It is regenerable from `data/raw/` + the code. CI verifies this on a small fixture.
- **`data/generated/` is the AI sandbox.** Anything Claude (or any exploratory script) produces lands here. It is `.gitignore`d by default. Promotion to `processed/` requires the work to be wrapped in a Snakemake rule.
- **`results/figures/`** holds only the final figures. They are produced by calling functions in `src/myproject/viz.py` from a notebook or script — never edited in Photoshop, never produced ad-hoc.

*Why:* the three-tier data hierarchy (`raw` → `processed` → `generated`) is the single most important convention for surviving long-running scientific projects. It makes "did this come from a pipeline or did I make it in a notebook" decidable in one second.

## `.gitignore` minimum

```
__pycache__/
*.egg-info/
.venv/
.pixi/
.hypothesis/
.pytest_cache/
.ruff_cache/
.mypy_cache/
.coverage
htmlcov/
data/generated/
data/processed/   # opinion: regenerable; don't bloat the repo
logs/
*.ipynb_checkpoints/
.DS_Store
```

`data/processed/` is debatable; commit it only if regenerating is expensive (>1 h on the cluster) AND the files are small. Otherwise leave it out and rely on DataLad for the actual storage.

## DataLad for data versioning

Neuroimaging projects use **DataLad** to version `data/`, not raw Git LFS, not DVC.

- `data/raw/` is a DataLad subdataset pointing at lab storage or OpenNeuro.
- `data/processed/` is a DataLad subdataset; pipeline outputs are committed there.
- The top-level project repo is a DataLad superdataset containing code + subdataset pointers.

*Why:* DataLad is the BIDS-ecosystem standard. OpenNeuro is DataLad. CuBIDS, BABS, and FAIRly-big assume it. `datalad run` captures the provenance (command + container + code commit) that produced any output.

## `.claude/settings.json` minimum

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Read(./**)",
      "Bash(uv:*)",
      "Bash(pixi:*)",
      "Bash(just:*)",
      "Bash(pytest:*)",
      "Bash(ruff:*)",
      "Bash(pyrefly:*)",
      "Bash(snakemake:*)",
      "Bash(marimo:*)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)"
    ],
    "deny": [
      "Read(./data/raw/**)",
      "Write(./data/raw/**)",
      "Bash(rm -rf *)",
      "Bash(git push *)",
      "Bash(git rebase *)",
      "Bash(git reset --hard *)"
    ]
  }
}
```

*Why:* `deny` rules survive even `--dangerously-skip-permissions` for PreToolUse hooks — they are the strongest safety boundary against an agent doing something irrecoverable to raw data.

## Gotchas

- `src/` layout means the package is not importable until installed. `uv sync` installs it editable; if `import myproject` fails, the answer is almost always "run `uv sync` first".
- DataLad subdatasets are recursive; `git status` at the top level won't show changes inside a subdataset. Use `datalad status -r`.
- `data/raw/` as a symlink works fine on Linux/macOS; on Windows use junctions or accept the cost of duplication.
