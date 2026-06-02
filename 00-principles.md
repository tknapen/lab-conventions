# 00 — Principles

The four things every other rule in this directory follows from. If a rule below ever conflicts with another rule, the higher-numbered principle here wins.

## 1. Reproducible by default

Any analysis, figure, or model fit must be reproducible from a clean checkout with a documented command sequence. Concretely: a fresh git clone plus `just sync && just check && just pipeline` should produce the published artifacts (modulo non-deterministic seeded operations, which must be seeded).

*Why:* science. Also: future-you will hate present-you otherwise.

## 2. The file system is the source of truth

State that matters lives on disk as text or well-defined binary files, not in a notebook kernel, not in a database the rest of the lab can't read, not in someone's home directory. Lockfiles, configuration, and convention files are committed to git.

*Why:* notebooks lie, kernels die, laptops break. Diffs are the unit of review.

## 3. Reusable code lives in `src/`, not in notebooks

Anything called twice — IO, preprocessing, model fitting, plotting helpers, statistical wrappers — belongs in an installable Python package under `src/`. Notebooks are thin orchestration layers: load, call, display, call, display. If a cell exceeds ~30 lines or defines something likely to be reused, extract it.

*Why:* code in `src/` is testable, importable, diff-reviewable, and reusable. Code in a notebook cell is none of those.

## 4. Raw data is read-only and never regenerable

`data/raw/` is treated as if it were on a CD-ROM. Writing into it is a CI failure and a Claude permission-denied. Anything derived from raw goes into `data/processed/` (deterministic, pipeline-produced) or `data/generated/` (AI/exploratory, disposable). See `07-project-layout.md`.

*Why:* raw scanner output, behavioral logs, and stimulus recordings cannot be re-collected. Everything else can be re-derived.

## Corollaries for AI agents

When Claude (or any agent) edits this lab's code:

- **Never** write into `data/raw/`. This is enforced by `.claude/settings.json` `deny` rules.
- **Never** modify lockfiles by hand (`uv.lock`, `pixi.lock`). Modify the manifest and run the lock command.
- **Never** silently switch package managers. If a project uses `uv`, do not use `pip`; if it uses `pixi`, do not use `conda`.
- **Never** add a top-level dependency without updating `pyproject.toml` and re-locking.
- **Always** run `just check` (or its components) before declaring a task done.
- **Always** prefer editing existing code to creating new files, unless the new file is genuinely a new module.
