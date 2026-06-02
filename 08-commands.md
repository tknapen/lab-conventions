# 08 — Commands

Every project ships a `justfile` with a standard set of targets. The vocabulary is shared across the lab so anyone (and Claude) can drop into any repo and run `just sync && just check` without reading the README.

*Why:* `just` is the only task runner in the lab. Not `make`, not `[project.scripts]`, not hand-rolled bash. One vocabulary, one tool.

## The canonical `justfile`

```just
# justfile — see lab-conventions/08-commands.md
set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# --- environment ---------------------------------------------------------

# Sync the full environment (uv + pixi if present)
sync:
    @if [ -f pixi.lock ]; then pixi install --locked; fi
    uv sync --locked

# Update lockfiles (run when pyproject.toml changes)
lock:
    uv lock
    @if [ -f pyproject.toml ] && grep -q '\[tool.pixi' pyproject.toml; then pixi install; fi

# --- code quality --------------------------------------------------------

lint:
    uv run ruff check --fix
    uv run ruff format

typecheck:
    uv run pyrefly check src

# --- tests ---------------------------------------------------------------

test *args:
    uv run pytest {{args}}

test-slow:
    uv run pytest -m slow

# --- notebooks -----------------------------------------------------------

notebook name:
    uv run marimo edit notebooks/{{name}}.py

notebook-check:
    uv run marimo check --strict notebooks/

# Export marimo notebooks to .ipynb for collaborators (rare)
notebook-export name:
    uv run marimo export ipynb notebooks/{{name}}.py -o shared/{{name}}.ipynb

# --- the gate ------------------------------------------------------------

# Run everything CI runs. If this passes, you're done.
check: lint typecheck test notebook-check
    @echo "All checks passed."

# --- pipelines -----------------------------------------------------------

# Dry-run the workflow DAG
pipeline-dry:
    uv run snakemake -n

# Run the workflow
pipeline cores="8":
    uv run snakemake --cores {{cores}} --use-apptainer

# Submit the workflow to SLURM
pipeline-slurm jobs="50":
    uv run snakemake --executor slurm --jobs {{jobs}} \
        --workflow-profile profiles/slurm

# --- docs ----------------------------------------------------------------

docs:
    quarto render docs/

docs-preview:
    quarto preview docs/

# --- maintenance ---------------------------------------------------------

# Clean caches and build artifacts. Does NOT touch data/.
clean:
    rm -rf .pytest_cache .ruff_cache .mypy_cache .hypothesis htmlcov dist build
    find . -type d -name __pycache__ -exec rm -rf {} +

# Install pre-commit hooks
hooks:
    uv run pre-commit install

# Validate that pixi.lock and uv.lock match pyproject.toml
verify-locks:
    uv lock --check
    @if [ -f pixi.lock ]; then pixi install --locked --dry-run; fi
```

## Hard rules

- Every project has a `justfile`. No exceptions.
- `just sync`, `just check`, `just test`, `just lint` are reserved names with the meanings above. Don't redefine them.
- `just check` is the gate. If it passes, the work is done; if it fails, the work isn't.
- New project-specific recipes go below the standard ones, separated by a comment.

*Why:* "run `just check`" is the lab's equivalent of "run the tests". Universal vocabulary kills onboarding friction.

## CI mirrors the justfile

The CI workflow is essentially `just check` plus a matrix:

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.12", "3.13"]
    steps:
      - uses: actions/checkout@v6
      - uses: astral-sh/setup-uv@v8
        with:
          enable-cache: true
          cache-dependency-glob: "uv.lock"
      - run: uv python install ${{ matrix.python-version }}
      - uses: extractions/setup-just@v3
      - run: just sync
      - run: just check
```

*Why:* one source of truth (the justfile) means "passes on my machine" implies "passes in CI". No CI-only commands.

## One-off scripts: PEP 723 inline metadata

For scripts that live outside any project — reviewer-2 responses, "make this one figure", reanalysis requests — use **PEP 723 inline metadata**:

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#   "nibabel",
#   "numpy",
#   "matplotlib",
# ]
# ///
"""Figure 3: contrast response function fits per ROI."""
import nibabel as nib
import numpy as np
import matplotlib.pyplot as plt
...
```

`chmod +x figure_3.py && ./figure_3.py`. No virtual environment to manage; uv handles it. Lock with `uv lock --script figure_3.py` if you need exact pinning for archival.

*Why:* the script is self-contained, version-control-friendly, and runnable from a fresh machine without any setup. The right shape for paper-companion scripts and reviewer responses.

## Gotchas

- `just`'s default shell is `sh`; the `set shell := ["bash", "-euo", "pipefail", "-c"]` line at the top makes it bash with strict mode. Always include it.
- `just` arguments are positional; named args use `=`. `just pipeline cores=16` works; `just pipeline 16` also works.
- `just --list` only shows recipes without `_` prefix. Use `_private-helper:` for internal recipes.
