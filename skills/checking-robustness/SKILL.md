---
name: checking-robustness
description: Robustness checks required before any headline scientific claim - multiverse sweep, positive/negative controls, sensitivity analysis, blind-ish development, matched to the project's declared inference regime. Use whenever an analysis result is about to be treated as a finding, whenever a result enters a paper, a decision, or a go/no-go call, whenever the user asks "is this real", "is this significant", or "can we trust this", and whenever choosing statistics for low-n/high-trial vs population-level designs.
---

# Checking robustness

A single pipeline is one path through a garden of forking paths; a headline result is not a result until it survives the checks below (principle 4). Exploratory work is exempt — but must stay labeled exploratory.

## First: match the inference regime

The project `CLAUDE.md` declares the regime. The unit of evidence differs:

- **(A) Low-n / high-trial** (psychophysics / NHP): power is **within** subject. Establish the effect within each subject with a trial/stimulus resampling test; report **every subject individually** — the claim is "*k of N* subjects show it, each within-subject reliable", not a pooled statistic. Do **NOT** multiple-comparison-correct a descriptive sweep (an ROI profile is a characterization, not a hypothesis family); reserve correction for a pre-registered confirmatory family with few a-priori endpoints.
- **(B) Population-level** (large-n): the **group test is primary** with the usual MC control (FDR/FWE) over the tested family; per-subject display is support, not the claim.

Never apply one regime's logic to the other — the statistic that is right for one is wrong for the other.

## Check 1 — multiverse-lite sweep

Identify the 2–4 most consequential analytic choices (exclusions, transforms, thresholds, model form), enumerate only *defensible* settings of each (no strawmen), run the small grid, and report the effect **across the whole grid** with the chosen cell marked — a mini specification curve. The headline question becomes "how much does the conclusion move?". A result that flips on a defensible exclusion rule is a *decision*, and the dashboard must show that.

## Check 2 — positive and negative controls

Report both beside every headline effect:

- **Positive control** — a condition where the effect (or a known reference) *must* appear (a localizer that has to fire). Flat positive control → the method can't detect the effect; a null is uninterpretable.
- **Negative control** — a condition where it *must not* appear (label-shuffle/permutation null, phase-scramble, off-target ROI, pre-stimulus window). Effect present here → pipeline artifact.

These are the *same synthetic generators* used by test fixtures and dashboard schematics — write once, use three times.

## Check 3 — sensitivity analysis

State the load-bearing assumptions and push each until the conclusion changes: vary exclusion thresholds, swap atlas/mask, and for causal claims state how strong an unmeasured confounder must be to explain the effect away (E-value-style). Deliverable: "the conclusion holds unless *X*, which would require *Y*" — the user judges whether *Y* is plausible.

## Check 4 — blind-ish analysis (where feasible)

Freeze the pipeline before seeing the answer: develop and debug against synthetic, label-shuffled, or held-out data; record the freeze (commit + log entry); then unblind. Partial forms (synthetic-first development, a locked pipeline) capture most of the benefit.

## Checklist

- [ ] Regime checked in project `CLAUDE.md`; statistics match it.
- [ ] 2–4 consequential choices swept; effect reported across the grid.
- [ ] Positive control firing; negative control silent.
- [ ] Load-bearing assumptions each carry a sensitivity statement.
- [ ] Pipeline frozen before unblinding, where feasible.
- [ ] Results → dashboard (`interpretation-dashboards`); decisions → log (`logging-decisions`).

Multiverse grids run as a Snakemake fan-out: `just multiverse <analysis>` (see `lab-conventions/reference/commands.md`). Prior art: `lab-conventions/REFERENCES.md`.
