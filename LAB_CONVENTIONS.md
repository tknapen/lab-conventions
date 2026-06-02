# Lab Conventions

This directory is the canonical reference for how code in this lab is written, built, tested, and run. Read every file before doing non-trivial work in a project that imports it.

These conventions apply to **personal and lab-wide projects**. Things destined for PyPI / JOSS / public release have additional requirements not covered here.

## How to use these in a project

In a project's root `CLAUDE.md`:

```markdown
## Lab conventions
Follow `lab-conventions/LAB_CONVENTIONS.md` and every file it indexes.
Project-specific overrides go BELOW this line, and must explicitly
name which lab convention they override and why.
```

Vendor `lab-conventions/` into projects via git submodule, git subtree, or a symlink — whichever is least friction. The convention files are authoritative; if a project's local CLAUDE.md disagrees, it must say so explicitly.

## Files in this directory

| File | Topic |
|---|---|
| `00-principles.md` | The four principles everything else follows from. Read first. |
| `01-environments.md` | uv + pixi: how environments are defined and reproduced. |
| `02-packaging.md` | `pyproject.toml` shape, build backends, dependency groups. |
| `03-code-quality.md` | Ruff, type checking (pyrefly / ty / jaxtyping), pre-commit. |
| `04-testing.md` | pytest config, hypothesis, syrupy, shape-aware tests. |
| `05-notebooks.md` | Marimo as default; Jupyter handling; thin-notebook rule. |
| `06-pipelines.md` | Snakemake, DataLad, containers, HPC. |
| `07-project-layout.md` | Directory structure, data quarantine, AI-generated artifacts. |
| `08-commands.md` | The standard `justfile` every project should ship. |
| `09-when-to-deviate.md` | Explicit list of situations where these rules don't apply. |
| `10-release.md` | Optional. Read only when releasing a project (PyPI, JOSS, Zenodo). |

## Versioning

Treat this directory as a versioned spec. Tag releases (`v1.0`, `v1.1`, …). A project pinned to `v1.0` should keep working forever; changes here are additive or breaking-with-a-tag, never silent.
