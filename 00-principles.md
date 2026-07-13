# 00 — Principles

The nine principles every other rule in this directory follows from. They are
ordered by **precedence, most important first**: principles **1–5** govern *how we
reason* (inference and judgment); principles **6–9** govern *how we build*
(reproducibility and data integrity). When two principles tension, the
**lower-numbered one wins** — it is better to be slow and right than reproducibly
wrong. We do **solid, not speedy** science.

---

## How we reason (1–5)

## 1. The analyst surfaces; the user judges

Reporting exists to make the evidence maximally interpretable and to lay out the candidate readings — **not to pre-empt the scientific verdict**. Default to presenting patterns, gradients, and *multiple plausible interpretations side by side*, each with the caveats that bear on it, and reserve the call for the user. **Quantify rather than dismiss:** a caveat (low power, a low reliability ceiling, a possible confound) is shown and weighed, never used to delete a real effect from view. Distinguish a genuine null from an underpowered or an equivalent result, and present each as a *named outcome* rather than as bare absence. Prefer elaborate, interpretation-facilitating reporting — reference/chance/ceiling lines, in-panel effect annotations, absolute *and* normalized views, stated n / error / test — over terse single-metric plots.

*Why:* the analyst owns the **completeness of the evidence**, the user (PI) owns **adjudication** — so "rigor" never becomes the analyst quietly deciding what is real and dropping the signal the user most wants; the discipline is *not* a licence to launder weak results either. Operationalized in `01`, `04`, `05`.

## 2. No premature conclusions — a result is provisional until the user judges

Findings are reported as *candidate readings*, never settled verdicts: the default verb is "this is **consistent with** X", not "this **shows** X". At every point where the analysis could branch — a subject/trial exclusion, an outlier rule, a transform, a threshold, a model form, a correction — surface the fork and its alternatives and **stop for the user's call** rather than silently taking the path that confirms the expected story. Label every analysis *exploratory* or *confirmatory*, and never re-tell an exploratory finding as if it had been predicted.

*Why:* LLM analysts are measurably overconfident and rush past the user onto an early, over-simplified path (see `REFERENCES.md`); a premature conclusion costs a non-reproducible claim, a pause costs seconds. Operationalized in `01`.

## 3. Look at the data before you summarize it

Before any summary statistic, model fit, or test, render the raw distribution — the per-trial / per-voxel / per-subject points, the residuals, the spread — not just the mean. Every headline number ships with the plot it came from.

*Why:* Anscombe's quartet and the Datasaurus dozen — radically different data, identical summary statistics; a mean without its distribution is an assertion, not evidence. Operationalized in `10` (the "look first" rule).

## 4. One analysis is one path; robustness is part of the claim

A single pipeline is one route through a garden of forking paths. A headline result is not done until it has been checked against the reasonable alternative choices (exclusions, transforms, thresholds, model forms) and the analyst has reported **how much the conclusion moves**. Every effect ships with a **positive control** (a condition where it *must* appear if the method works) and a **negative control** (one where it *must not*).

*Why:* seventy teams analysing one fMRI dataset reached materially different conclusions (see `REFERENCES.md`) — analytic flexibility alone manufactures findings, so a result that survives its multiverse is a result and one that does not is a decision dressed as a discovery. Operationalized in `02`.

## 5. The record is part of the result

Every headline analysis carries a running **decision log**: what was tried, what was chosen, what was ruled out and why, and which questions remain open — written so the user (or future-you, months later) can reconstruct the reasoning without re-deriving it. A result whose provenance the analyst cannot explain is not reportable.

*Why:* provenance-as-narrative is the core of reproducibility (The Turing Way, `REFERENCES.md`) and the log is what turns a figure back into an argument months later. Operationalized in `03`.

---

## How we build (6–9)

## 6. Reproducible by default

Any analysis, figure, or model fit must be reproducible from a clean checkout with a documented command sequence. Concretely: a fresh git clone plus `just sync && just check && just pipeline` should produce the published artifacts (modulo non-deterministic seeded operations, which must be seeded).

*Why:* science. Also: future-you will hate present-you otherwise.

## 7. The file system is the source of truth

State that matters lives on disk as text or well-defined binary files, not in a notebook kernel, not in a database the rest of the lab can't read, not in someone's home directory. Lockfiles, configuration, and convention files are committed to git.

*Why:* notebooks lie, kernels die, laptops break. Diffs are the unit of review.

## 8. Reusable code lives in `src/`, not in notebooks

Anything called twice — IO, preprocessing, model fitting, plotting helpers, statistical wrappers — belongs in an installable Python package under `src/`. Notebooks are thin orchestration layers: load, call, display, call, display. If a cell exceeds ~30 lines or defines something likely to be reused, extract it.

*Why:* code in `src/` is testable, importable, diff-reviewable, and reusable. Code in a notebook cell is none of those.

## 9. Raw data is read-only and never regenerable

`data/raw/` is treated as if it were on a CD-ROM. Writing into it is a CI failure and a Claude permission-denied. Anything derived from raw goes into `data/processed/` (deterministic, pipeline-produced) or `data/generated/` (AI/exploratory, disposable). See `12-project-layout.md`.

*Why:* raw scanner output, behavioral logs, and stimulus recordings cannot be re-collected. Everything else can be re-derived.

---

## Corollaries for AI agents

Principles 1–5 bind the agent's scientific conduct — surface don't adjudicate,
stay provisional and stop at forks, look before you summarize, check robustness,
log the reasoning. The operational detail lives in `01`–`05` (the lab-meeting
model and decision-point protocol in `01`; the per-project inference regime in
`02`). Beyond those, the build-side gates:

- **Never** write into `data/raw/` (enforced by `.claude/settings.json` `deny` rules).
- **Never** modify lockfiles by hand (`uv.lock`, `pixi.lock`) — edit the manifest and re-lock.
- **Never** silently switch package managers (`uv`↔`pip`, `pixi`↔`conda`).
- **Never** add a top-level dependency without updating `pyproject.toml` and re-locking.
- **Always** run `just check` before declaring a task done.
- **Always** prefer editing existing code to creating new files, unless it is genuinely a new module.
