# 10 — Notebooks

## Marimo is the default

New notebooks are marimo (`.py` files), not Jupyter (`.ipynb`). This is non-negotiable for new work.

*Why:* marimo notebooks are plain Python files forming a reactive DAG. They diff in git, lint with ruff, type-check with pyrefly, and have no hidden execution-order state. None of this is true for `.ipynb`.

## The thin-notebook rule

A notebook cell does one of:

1. Imports.
2. Calls a function from `src/` and assigns the result.
3. Displays a result (last expression in the cell).

If a cell has more than ~30 lines of logic, that logic gets extracted to `src/`. A good notebook reads like an outline of the analysis, not the analysis itself.

*Why:* code in `src/` is testable, importable, and reusable. Code stuck in a notebook cell is none of those. See principle 8 in `00-principles.md`.

## Look at the data first (principle 3)

The **first substantive cell** of any analysis notebook plots the *raw data* — the per-trial / per-voxel / per-subject distribution, not a summary. Histograms, a strip/swarm of the points, residuals, missingness, the range and the outliers. Only after that cell do summary statistics, fits, or tests appear.

```python
# Cell 1 (after imports): look before you summarize.
raw = load_subject(sub)            # from src/
viz.distributions(raw)             # per-trial points, not the mean
viz.missingness(raw)               # what's absent, before it silently biases a mean
```

*Why:* Anscombe's quartet and the Datasaurus dozen — identical mean / variance / correlation, completely different data. A summary computed before the distribution is seen is an assertion, not evidence (principle 3 in `00-principles.md`). A notebook that opens with a `.mean()` has skipped the most informative step.

## Hard rules

- No variable is redeclared across cells. Either rename (`df_raw`, `df_clean`, `df_modeled`) or chain in one cell. (Marimo enforces this; this rule documents the *style* — pick clear names, not `df1`, `df2`.)
- Notebooks go in `notebooks/`. Their outputs (figures, intermediate data) go in `data/generated/`, never beside the notebook.
- Notebooks import from the project's `src/` package, never from sibling notebooks.
- No `%matplotlib inline`, no `!pip install`, no `%load_ext autoreload`. Marimo's reactivity handles reloading; package management is `uv`'s job.
- Long-running computations (>30 s) are cached with `mo.persistent_cache` or `functools.cache` on the underlying function in `src/`, keyed on actual inputs. Never `time.sleep`-style cell ordering.

*Why:* the rules above eliminate every "but it worked in my notebook" failure mode in one sweep.

## CI

`marimo check --strict notebooks/` runs in pre-commit and CI. It catches DAG violations, multiple definitions, circular dependencies.

## Legacy `.ipynb` handling

Existing `.ipynb` files live in `notebooks/archive/` until migrated. Migration recipe:

```bash
marimo convert notebooks/archive/old.ipynb -o notebooks/old.py
# then refactor cells to satisfy the thin-notebook rule;
# move reusable logic to src/.
marimo check --fix notebooks/old.py
```

For notebooks that must stay as `.ipynb` (collaborator-facing, course materials), keep the marimo `.py` as source of truth and *export* on demand:

```bash
marimo export ipynb notebooks/02_model_fitting.py -o shared/02_model_fitting.ipynb
```

Wire that into the `justfile` so the `.ipynb` is a build artifact, not a maintained file.

*Why:* maintaining two parallel versions of a notebook always ends with them drifting. One source of truth + build step is the only sustainable shape.

## Gotchas

- Marimo's reactivity re-runs cells when their inputs change — bad for a 20-minute model fit. Cache at the function level in `src/`, not at the cell level.
- `from __future__ import annotations` breaks `jaxtyping` runtime checking; don't use it in notebooks that call jaxtyped functions and want shape errors to fire.
- `marimo convert` handles ~70% of cases automatically; expect to hand-fix the rest (cells with magics, repeated assignments, dependence on execution order).
- Pre-existing `.ipynb` files in active use get `nbstripout` in pre-commit so committed diffs don't include re-executed cell outputs.
