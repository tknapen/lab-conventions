# 02 — Inferential robustness

A single pipeline is one path through a garden of forking paths. This file says how
to check a result *from many perspectives* before it carries a claim — the
operational form of principle 4 (`00`). These are **strong defaults** for
**headline** analyses (those entering a paper, a decision, or a go/no-go); exploratory
work is exempt, deviations named under `16`.

*Why:* seventy teams analysing one fMRI dataset reached materially different
conclusions (`REFERENCES.md`) — analytic flexibility *alone* can manufacture or erase
an effect. A single team can't recruit seventy analysts, but it can approximate the
insight with the checks below.

## Declare the inference regime (per project)

The right inference follows from the project's **data regime** — a **per-project choice, declared up front
in the project `CLAUDE.md`**, not a lab-wide constant. Two regimes recur; the four checks apply to both,
but the **unit of evidence** and how a claim is made differ:

- **(A) Low-n / high-trial** (psychophysics / NHP): a few subjects, each sampled to the hilt. Power is
  **within** subject; the individual subject is the unit. Establish an effect **within a subject** with a
  trial/stimulus resampling test; **reproducibility = consistency across the few subjects** — show **every
  subject individually** (*k of N* each within-subject reliable), not a pooled statistic. **Do NOT
  multiple-comparison-correct a descriptive sweep** — an ROI *profile* is a characterization, not a family
  of independent hypotheses to guard; reserve correction for a pre-registered confirmatory family with a
  few a-priori endpoints.
- **(B) Population-level** (large-n): many subjects, fewer trials. Power is **across** subjects; the
  **group test is primary**, with the usual MC control (FDR / FWE) over the tested family. Per-subject
  display is still good practice, but inference is group-level.

*Why:* the two designs invert what carries the claim — within-subject replication across a few subjects vs
a group estimate over many — so the statistic that is right for one is wrong for the other. Stating the
regime stops a low-n project from being held to a population-level MC standard that destroys its power for
no inferential gain.

## Check 1 — the multiverse-lite sweep

Identify the **2–4 most consequential analytic choices** (from the fork table in `01`), enumerate the
*defensible* settings of each, run the small grid, and report the effect **across the whole grid** — a mini
specification curve, with the chosen pipeline marked. The headline question becomes "**how much does the
conclusion move** across defensible choices?" Only options you'd defend to a reviewer go in, not strawmen.

*Why:* a result stable across its multiverse is a result; one that flips between "significant" and "null"
on a defensible exclusion rule is a **decision**, and the dashboard (`05`) must show that.

## Check 2 — positive and negative controls

Every headline effect ships with two controls, reported beside it:

- **Positive control** — a condition where the effect (or a known reference) *must* appear if the method
  works (a localizer that has to fire). If it's flat, the analysis can't detect the effect and a null is
  uninterpretable.
- **Negative control** — a condition where the effect *must not* appear (label-shuffle / permutation null,
  phase-scramble, off-target ROI, pre-stimulus window). If it shows up here, it's a pipeline artifact.

*Why:* the positive control proves a null is a true absence not a broken method; the negative control
defines the noise floor (`REFERENCES.md`). These are the *same synthetic generators* the test suite (`09`)
and dashboard schematics (`05`) build — write once, use three times.

## Check 3 — sensitivity analysis

State the **load-bearing assumptions** and show how far each can be pushed before the conclusion changes:
vary exclusion thresholds; swap the atlas / mask / parcellation; for causal claims, report how strong an
**unmeasured confounder** would have to be to explain the effect away (E-value-style; `REFERENCES.md`). The
deliverable is a sentence: "the conclusion holds unless *X*, which would require *Y*" — so the user can
judge whether *Y* is plausible.

## Check 4 — blind-ish analysis, where feasible

Adapt the particle-physics norm: **fix and freeze the pipeline before looking at the answer.** Develop and
lock the analysis against synthetic / label-shuffled / held-out data that doesn't reveal the contrast of
interest, record the freeze (commit + log entry), *then* unblind.

*Why:* you cannot tune exclusions toward a result you cannot yet see (`REFERENCES.md`). Full blinding isn't
always practical; the partial forms (synthetic-first development, a locked pre-registered pipeline) capture
most of the benefit.

## Wiring

The multiverse grid is a small Snakemake fan-out (`11`; `just multiverse`, `13`). The control generators are
shared with `09` fixtures and `05` schematics. The whole check is summarized in the dashboard (`05`) and
recorded in the analysis log (`03`).

## Checklist (headline analyses)

- [ ] Regime declared in the project `CLAUDE.md`; the unit of evidence matches it.
- [ ] The 2–4 most consequential choices swept; the effect reported across the grid, not just one cell.
- [ ] Positive control present and firing (else the null is uninterpretable).
- [ ] Negative control present and silent (else the effect is an artifact).
- [ ] Load-bearing assumptions stated with a sensitivity statement for each.
- [ ] Pipeline frozen against synthetic/blinded data before unblinding, where feasible.
- [ ] Robustness summarized in the dashboard; decisions in the analysis log.
