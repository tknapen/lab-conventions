# 16 — When to deviate

These conventions are defaults, not laws. The list below is the **complete** set of situations where deviating is acceptable. If your case isn't on this list, follow the conventions; if you think your case should be on this list, propose adding it.

## Acceptable deviations

### A frozen analysis tied to a published paper

A `.ipynb` from a 2022 paper does not need to be migrated to marimo. Tag the commit, archive the environment with `uv export` or `pixi-pack`, deposit on Zenodo, and leave it alone.

*Why:* reproducibility of the published result trumps tooling modernization. Touching the notebook risks invalidating the paper's record.

### A teaching notebook that must stay as `.ipynb`

Course materials and tutorials shared with students who run them on Colab / nbviewer can stay as `.ipynb`. Treat the marimo `.py` as source of truth and **export** with `just notebook-export`; never hand-maintain both.

### A collaborator's repo we don't control

A multi-author project where the other PI standardized on conda + Jupyter + black is theirs, not ours. Use their conventions for their repo. Maintain a personal fork using lab conventions only if you're doing substantive solo work in it.

### Truly throwaway exploration

A 10-minute spike in a scratch directory does not need `pyproject.toml`, `justfile`, or pre-commit. Use a PEP 723 script and move on. If the spike survives more than a day, promote it to a project.

*Why:* the conventions have overhead; ten minutes of work doesn't justify ten minutes of scaffolding.

### Hard CUDA / driver constraints

A specific PyTorch/JAX version that only works with a specific CUDA version on a specific cluster overrides the "pixi solves this" rule. Pin explicitly in `[tool.pixi.system-requirements]` and document the constraint in the project's `CLAUDE.md`.

### An upstream tool that hard-requires conda

If a critical neuroimaging tool ships only as a conda-forge package and pixi can't resolve it cleanly, use a separate conda env for that tool and call it from Snakemake as an external program. Don't bend pixi to make it work; isolate the offender.

### Type checking on legacy code

Library code (`src/`) on a published package is type-checked with pyrefly under strict settings. Analysis scripts and notebooks are type-checked with ty under gradual settings (errors warn, don't block). Adding strict types to a 2000-line legacy analysis is wasted time.

### Tests on one-off scripts

PEP 723 scripts and `figure_3.py`-style files don't get unit tests. The output (the figure, the table) is the test. If the script becomes load-bearing — used by more than one analysis — extract its logic to `src/` and test it there.

### The cultural defaults on exploratory / throwaway analysis

The "how we reason" conventions (`01`–`04`) are **strong defaults scaled to headline
work** — analyses that enter a paper, a decision, or a go/no-go breakpoint. A
10-minute exploratory spike does **not** need a multiverse sweep, a dashboard, a
formal analysis log, or full interpretation-ready reporting. What is *not* optional
even in exploration: labelling it **exploratory** (so it is never later retold as
confirmatory), and not presenting its output as a settled result.

*Why:* the overhead of robustness checks and decision logs is justified by the
weight a result carries, not by ceremony. Exploration that stays exploration, and is
labelled as such, is exactly what these conventions want to protect.

## Unacceptable deviations

These are never OK, regardless of context:

- Writing to `data/raw/`.
- Hand-editing lockfiles.
- Skipping the lockfile check in CI ("it works on my machine").
- Disabling ruff or pyrefly to "fix" a CI failure rather than fixing the code.
- Using `pip install` outside `uv pip` inside a Docker layer.
- Using `conda` / `mamba` directly when the project has a `pixi.lock`.
- Committing real raw NIfTIs or behavioral data to git (use DataLad).
- Running `git push --force`, `git rebase`, or `git reset --hard` on a shared branch.
- **HARKing** — presenting a finding derived from the data (exploratory) as if it
  had been hypothesized in advance (confirmatory). Re-label the analysis honestly
  instead (`01-doing-science-with-claude.md`).
- **Reporting a single un-robustness-checked path as a settled conclusion** for
  headline work — claiming a result without its positive/negative controls and a
  sweep over the defensible analytic choices (`02-inferential-robustness.md`).
- **Asserting a verdict the user hasn't made** — using "proves" / "confirms" of a
  single analysis, or deleting a real, caveated effect from view to clean up the
  story (principle 1).

*Why:* these don't have legitimate use cases in this lab. They either break
reproducibility, break the data-integrity guarantee, break collaborators' work, or
break the inferential honesty that the "how we reason" principles exist to protect —
manufacturing a confident conclusion the evidence does not yet support.

## How to propose a new exception

Open a PR against `lab-conventions/` that:

1. Adds the case to the "Acceptable deviations" section above with a name and rationale.
2. Updates the relevant numbered file(s) if the case requires a specific configuration.
3. Tags a new version.

Don't accumulate undocumented exceptions in project READMEs; they vanish.
