# 01 — Environments

## Two managers, two manifests, one project

- **`uv`** manages Python interpreters, Python packages, and the Python virtual environment.
- **`pixi`** manages non-Python and system dependencies: CUDA, R, compilers, HDF5, FFTW, neuroimaging C/Fortran libraries.

Both write into the same `pyproject.toml`. The project ends up with two lockfiles (`uv.lock`, `pixi.lock`); both are committed.

*Why:* `uv` is faster and standards-compliant for Python; `pixi` is the only sane way to pin non-Python deps with a real lockfile. They cooperate (pixi delegates PyPI resolution to uv internally), so this is not a competing-tools setup.

## Decision rule: do I need pixi?

Pure-Python project, no CUDA, no R, no compiled C libs → **uv only**.
Anything else → **uv + pixi**.

There is no third option. Never use `conda` or `mamba` directly in a new project; never use `pip` outside `uv pip` inside a Docker layer.

## uv conventions

- Pin the Python version in `pyproject.toml` with `requires-python = ">=3.12"` (or whatever the project needs). Let `uv python install` fetch managed CPython; do not depend on system Python.
- Use **`[dependency-groups]`** (PEP 735), not `[tool.uv.dev-dependencies]`. The latter still works but is the old shape.
- Commit `uv.lock`. Run `uv sync --locked` in CI; the build fails if the lock drifts.
- For installing CLI tools (ruff, marimo, pyrefly, ty) globally outside any project, use `uv tool install`. For running commands inside the project env, use `uv run`.
- For one-off analysis scripts that should be runnable from a fresh machine, use **PEP 723 inline metadata** — see `08-commands.md`.

*Why:* lockfiles are reproducibility; dependency groups are the standardized successor to dev-deps; managed Python eliminates the "works on my machine but not on the cluster" class of bug.

## pixi conventions

- Keep pixi config in `pyproject.toml` under `[tool.pixi.*]`, not a separate `pixi.toml`. One manifest, one source of truth.
- Always declare `[tool.pixi.system-requirements]` (CUDA version, libc) so the solver knows what the host actually has.
- Use `[tool.pixi.environments]` features to bake CPU and GPU environments side-by-side from one manifest. Do not maintain parallel `environment-cpu.yml` and `environment-gpu.yml` files.
- Commit `pixi.lock`. Run `pixi install --locked` in CI.
- For offline / air-gapped HPC nodes, ship environments with `pixi-pack`.

*Why:* one manifest avoids drift; explicit system-requirements catches "CUDA 11 host, lockfile expects CUDA 12" before submission.

## Hard rules

- Lockfiles are committed. Always.
- Never edit lockfiles by hand. Edit `pyproject.toml` and run `uv lock` / `pixi install`.
- Never use `pip install` directly. Use `uv add` / `uv pip install`.
- Never use `conda` / `mamba` directly. Use `pixi`.
- Never silently fall back to system Python. If `uv` doesn't find an interpreter, install one with `uv python install`.

## Gotchas

- `uv sync` is exact by default (removes extraneous packages); `uv run` is inexact by default (won't remove). Use `uv sync --locked` in CI.
- pixi PyPI deps override `[project.dependencies]` only when names match; otherwise both are installed.
- For GPU stacks (torch, jax with CUDA), prefer pixi's `[tool.pixi.pypi-dependencies]` with explicit indices — easier than uv's source-and-no-build-isolation workarounds.
- The `uv_build` backend does not yet integrate with `uv-dynamic-versioning`. Use hatchling for now; see `02-packaging.md`.
