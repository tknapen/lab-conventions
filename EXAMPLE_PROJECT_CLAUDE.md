# CLAUDE.md — example project-level instructions

This file shows how a project imports `lab-conventions/` and adds project-specific instructions. Copy this into your own project's root as `CLAUDE.md`, then customize the marked sections.

---

# Project: <PROJECT NAME>

One-sentence description of what this project is.

## Lab conventions

Follow `lab-conventions/LAB_CONVENTIONS.md` and every file it indexes. Specifically:

**How we reason (read first — these outrank the build files):**

- `lab-conventions/00-principles.md` — the nine principles, culture first
- `lab-conventions/01-doing-science-with-claude.md` — surface every fork and stop for me; stay provisional; label exploratory vs confirmatory
- `lab-conventions/02-inferential-robustness.md` — multiverse sweep, positive/negative controls, sensitivity, blinding
- `lab-conventions/03-analysis-log.md` — the append-only decision log
- `lab-conventions/04-reporting.md` — interpretation-ready reporting of every result
- `lab-conventions/05-dashboards.md` — interpretation dashboards

**How we build:**

- `lab-conventions/06-environments.md` — uv + pixi
- `lab-conventions/07-packaging.md` — `pyproject.toml` shape
- `lab-conventions/08-code-quality.md` — ruff, pyrefly, jaxtyping
- `lab-conventions/09-testing.md` — pytest, hypothesis, syrupy, controls
- `lab-conventions/10-notebooks.md` — marimo, thin-notebook + look-first rules
- `lab-conventions/11-pipelines.md` — Snakemake, containers
- `lab-conventions/12-project-layout.md` — directory tree, data tiers
- `lab-conventions/13-commands.md` — the `justfile`
- `lab-conventions/16-when-to-deviate.md` — explicit exceptions
- `lab-conventions/17-release.md` — read only when releasing

## Lab style

Follow `lab-style/LAB_STYLE.md` and every file it indexes. Specifically:

- `lab-style/00-philosophy.md` — what code optimizes for
- `lab-style/01-naming.md` — variables, functions, modules
- `lab-style/02-functions.md` — function shape and signatures
- `lab-style/03-arrays.md` — NumPy / fMRI array idioms
- `lab-style/04-errors.md` — exceptions, validation, logging
- `lab-style/05-plotting.md` — matplotlib conventions
- `lab-style/06-comments.md` — docstrings, inline comments
- `lab-style/07-commits.md` — commit messages, branches, PRs
- `lab-style/08-aspirational.md` — rules in flight

When uncertain, the convention and style files are authoritative. Anything below this line is a **project-specific override** — it must name which lab rule it overrides and why.

## Project-specific context

<!-- CUSTOMIZE EVERYTHING BELOW. -->

### What this project does

Two or three sentences. What's the question, what's the data, what's the model.

### Data

- `data/raw/` is a symlink to `/lab/storage/<dataset>/`. Do not write.
- This project uses BIDS subjects `sub-01` through `sub-32`.
- Acquisition: 1.8 mm isotropic multi-echo EPI, Philips 3T.

### Common tasks

- `just sync` — set up the environment from lockfiles
- `just check` — run all quality gates
- `just pipeline` — run the full Snakemake DAG locally
- `just pipeline-slurm` — submit to the cluster

### Project-specific overrides

<!-- List each override explicitly, or delete this section. -->

None.

### Top of mind

<!-- Short notes on what's currently active, what to prioritize, what's
     in flux. Keep this section fresh; delete stale items. -->

- Currently fitting divisive-normalization model variants; see `notebooks/02_model_fitting.py`.
  Status: **exploratory** — no confirmatory claims yet. Decision log: `docs/notes/model_fitting.log.md`.
- Open question: power-law vs exponential adaptation; see `docs/notes/adaptation.md`.

### Do NOT

- Do not modify `data/raw/`.
- Do not commit anything from `data/generated/` without my explicit say-so.
- Do not push to `main`; open a PR.
- Do not run `git rebase` on a shared branch.
