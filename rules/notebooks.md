---
paths:
  - "notebooks/**"
---

# Notebook rules

**Marimo is the default.** New notebooks are marimo `.py` files, never `.ipynb` — they diff, lint, type-check, and have no hidden execution-order state. `marimo check --strict notebooks/` runs in pre-commit and CI.

**Thin-notebook rule.** A cell does one of: imports · call a `src/` function and assign · display. Logic over ~30 lines gets extracted to `src/` (principle 8). A good notebook reads like an outline of the analysis.

**Look at the data first (principle 3).** The first substantive cell of an analysis notebook plots the *raw* data — per-trial/-subject points, residuals, missingness — before any summary, fit, or test. A notebook that opens with `.mean()` skipped the most informative step.

**Two kinds of notebook.** *Analysis* notebooks explore and decide (look-first, thin). *Results* notebooks communicate — they house the interpretation dashboards with narration (see the `interpretation-dashboards` skill); standalone figure files are exports of the same `src/` functions, not the deliverable.

## Hard rules

- No variable redeclared across cells (marimo enforces); pick clear names (`df_raw`, `df_clean`), not `df1`/`df2`.
- Outputs go to `data/generated/`, never beside the notebook. Import from `src/`, never from sibling notebooks.
- No `%matplotlib inline`, `!pip install`, or `%load_ext autoreload`.
- Computations >30 s: cache at the function level in `src/` (`mo.persistent_cache` / `functools.cache`), keyed on real inputs.

## Legacy `.ipynb`

Park in `notebooks/archive/` until migrated: `marimo convert` then refactor to the thin rule (expect ~30% hand-fixing: magics, repeated assignments, order dependence). Collaborator/teaching notebooks that must stay `.ipynb`: keep the marimo `.py` as source of truth and `marimo export ipynb` via the justfile — never hand-maintain both. Active `.ipynb` files get `nbstripout` in pre-commit.

## Gotchas

- Marimo reactivity re-runs cells on input change — cache long fits at the function level, not the cell level.
- `from __future__ import annotations` breaks `jaxtyping` runtime checks; don't use it in notebooks calling jaxtyped functions.
