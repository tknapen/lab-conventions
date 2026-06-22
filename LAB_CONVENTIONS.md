# Lab Conventions

This directory is the canonical reference for how science in this lab is reasoned about, and how code is written, built, tested, and run. Read every file before doing non-trivial work in a project that imports it.

> **How we do science.** We do **solid, not speedy** science. Reproducibility is necessary but not sufficient; what makes a result trustworthy is **inferential robustness** — never jumping to a conclusion, inspecting the data and the result from many angles, distinguishing a genuine effect from an analytic artifact, and letting the **user adjudicate** at every fork. Every reported result must be **interpretation-ready**: legible, with enough context to be understood when you return to it weeks or months later. The "how we reason" files (`00`–`04`) come first and **outrank** the "how we build" files when the two ever tension.

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

Ordered by precedence: **how we reason** first, **how we build** second. The file
numbers track that priority — read low-to-high.

### How we reason (read first)

| File | Topic |
|---|---|
| `00-principles.md` | The nine principles everything else follows from — culture first (incl. *the analyst surfaces, the user judges*; *no premature conclusions*; *look before you summarize*; *robustness is part of the claim*; *the record is part of the result*). Read first. |
| `01-doing-science-with-claude.md` | How the agent behaves: surface every fork and stop for the user; provisional language; exploratory-vs-confirmatory labelling; surface disconfirming evidence first. |
| `02-inferential-robustness.md` | The lab's low-n/high-trial inference regime (within-subject power + cross-subject consistency, no MC over descriptive sweeps); multiverse-lite sweeps, positive/negative controls, sensitivity analysis, blind-ish analysis. |
| `03-analysis-log.md` | The append-only decision log: what was tried, chosen, ruled out, and why — legible months later. |
| `04-reporting.md` | Interpretation-ready reporting of every result (prose, tables, chat), not just figures. |
| `05-dashboards.md` | Interpretation dashboards: juxtapose the result with hypothesis schematics (same plot fn, idealized data) + self-documenting text. |

### How we build

| File | Topic |
|---|---|
| `06-environments.md` | uv + pixi: how environments are defined and reproduced. |
| `07-packaging.md` | `pyproject.toml` shape, build backends, dependency groups. |
| `08-code-quality.md` | Ruff, type checking (pyrefly / ty / jaxtyping), pre-commit. |
| `09-testing.md` | pytest config, hypothesis, syrupy, shape-aware tests, controls. |
| `10-notebooks.md` | Marimo as default; the thin-notebook and "look first" rules. |
| `11-pipelines.md` | Snakemake, DataLad, containers, HPC. |
| `12-project-layout.md` | Directory structure, data quarantine, AI-generated artifacts. |
| `13-commands.md` | The standard `justfile` every project should ship. |
| `14-data-formats.md` | Intermediate/derived file formats: netCDF + parquet, never `.npy`/`.pkl`. |
| `15-storage-budget.md` | What to save vs recompute: reproducibility gate, cost ratio, tiers, recipes. |
| `16-when-to-deviate.md` | Explicit list of situations where these rules don't apply. |
| `17-release.md` | Optional. Read only when releasing a project (PyPI, JOSS, Zenodo). |

## Versioning

Treat this directory as a versioned spec. Tag releases (`v1.0`, `v1.1`, …). A project pinned to `v1.0` should keep working forever; changes here are additive or breaking-with-a-tag, never silent. The culture-first reorganization (new `01`–`04`, renumbered build files, nine principles) is a **major** bump.
