# 02 — Inferential robustness

A single analysis pipeline is one path through a garden of forking paths. This
file says how to check a result *from many perspectives* before it is allowed to
carry a claim — the operational form of principle 4 (`00-principles.md`).

These are **strong defaults** for **headline** analyses (those that enter a paper,
a decision, or a go/no-go breakpoint). Exploratory and intermediate analyses are
exempt; deviations for headline work are named under `16-when-to-deviate.md`.

*Why:* seventy independent teams analysing one fMRI dataset reached materially
different conclusions, even with highly-correlated intermediate maps
(Botvinik-Nezer et al., *Nature* 2020). Analytic flexibility *alone* — exclusions,
transforms, thresholds — can manufacture or erase an effect (the multiverse /
specification-curve literature). A single team cannot recruit seventy analysts,
but it can approximate the insight in-house with the four checks below.

## Declare the inference regime (per project)

The right inference follows from the project's **data regime**, which is a **per-project choice — not a
lab-wide constant** — and must be **declared up front in the project's `CLAUDE.md`**. Two regimes recur:

- **(A) Low-n / high-trial** (psychophysics / non-human-primate): a few subjects each sampled to the
  hilt (thousands of trials / stimuli). This tradition has produced highly reproducible results; power
  is **within** subject and the individual subject is the unit of evidence.
- **(B) Population-level** (large-n cognitive neuroscience / individual-differences): many subjects,
  fewer trials each. Power is **across** subjects and the group is the unit.

The four checks below apply to **both**; what differs is the unit of evidence and how a claim is made:

**Regime A — low-n / high-trial:**
- Establish an effect **within a subject** with a resampling test over trials / stimuli (permutation or
  bootstrap) — that is where the degrees of freedom are.
- **Reproducibility = consistency across the few subjects:** show **every subject individually**
  (n = 6 → six lines/points, each with its within-subject error); the endpoint is "*k of N* subjects
  show it, each within-subject reliable", not a pooled group statistic.
- **Do NOT multiple-comparison-correct a descriptive sweep.** Pushing 27 ROIs (or a whole-brain map)
  through Bonferroni / BH at n = 6 is self-defeating: a hierarchy / ROI *profile* is a characterization,
  not a family of independent hypotheses to be guarded. Report effect sizes, within-subject CIs, and
  cross-subject consistency; reserve correction for a pre-registered confirmatory family and prefer a
  few **a-priori endpoints**.

**Regime B — population-level:**
- The **group test is primary**; control multiple comparisons over the tested family (FDR / FWE) as
  usual. Individual-subject display is still good practice, but the inference is group-level.

*Why:* the two designs invert what carries the claim — within-subject replication across a few subjects
vs a group estimate over many — so the same statistic that is right for one is wrong for the other.
Stating the regime up front tells reviewers and future-you which logic is in play, and stops a low-n
project from being held to a population-level multiple-comparison standard that would destroy its power
for no inferential gain.

## Check 1 — the multiverse-lite sweep

For a headline effect, identify the **2–4 most consequential analytic choices**
(usually drawn from the fork table in `01-doing-science-with-claude.md`), enumerate
the *reasonable* settings of each, and run the small grid of combinations.

- Report the effect **across the whole grid**, not just the chosen cell — a mini
  specification curve: the distribution of the effect over reasonable pipelines,
  with the chosen pipeline marked.
- The headline question is then "**how much does the conclusion move** across
  defensible choices?" — reported, not hidden.
- Keep the grid honest: only *defensible* options go in (each one you'd be willing
  to defend to a reviewer), not a strawman alternative chosen to make the favored
  path look good.

A result stable across its multiverse is a result. One that flips between
"significant" and "null" on a defensible exclusion rule is a **decision**, and the
dashboard (`05-dashboards.md`) must show that.

## Check 2 — positive and negative controls

Every headline effect ships with two controls, reported beside it:

- **Positive control** — a condition where the effect (or a known reference effect)
  *must* appear if the method is working at all. A localizer contrast that has to
  fire; a manipulation with a known, large signature. If the positive control is
  flat, the analysis cannot detect the effect of interest and a null is
  uninterpretable.
- **Negative control** — a condition where the effect *must not* appear: a
  label-shuffle / permutation null, a phase-scrambled stimulus, an off-target ROI,
  a pre-stimulus baseline window. If the effect shows up in the negative control,
  it is a pipeline artifact, not signal.

*Why:* controls are an experiment's sanity checks — the positive control proves a
null is a true absence rather than a broken system; the negative control defines
the noise floor so a "finding" can be distinguished from leakage ("Good enough
practices in scientific computing", Wilson et al.). These are the *same synthetic
generators* the test suite (`09-testing.md`) and the dashboard schematics
(`05-dashboards.md`) already build — write them once, use them three times.

## Check 3 — sensitivity analysis

State the **load-bearing assumptions** of the analysis and show how far each can
be pushed before the conclusion changes:

- vary the **exclusion** thresholds and show the effect's trajectory;
- swap the **atlas / mask / parcellation** for a reasonable alternative;
- for causal / observational claims, report how strong an **unmeasured confounder**
  would have to be to explain the effect away (an E-value-style statement;
  VanderWeele & Ding).

The deliverable is a sentence of the form "the conclusion holds unless *X*, which
would require *Y*" — so the user can judge whether *Y* is plausible.

## Check 4 — blind-ish analysis, where feasible

Adapt the particle-physics norm: **fix and freeze the pipeline before looking at
the answer.** Develop, debug, and lock the analysis against **synthetic data,
label-shuffled data, or a held-out partition** that does not reveal the contrast
of interest; only then unblind onto the real effect. Record the freeze (commit +
analysis-log entry) before unblinding.

*Why:* blind analysis is standard in physics and cosmology precisely because it
removes the analyst's (and the prompt's) thumb from the scale — you cannot tune
exclusions toward a result you cannot yet see (MacCoun & Perlmutter 2017). Full
blinding is not always practical; the partial forms (synthetic-first development,
a locked pre-registered pipeline) capture most of the benefit.

## How this wires into the existing tooling

- The multiverse grid is a small **Snakemake** fan-out (`11-pipelines.md`): one
  rule, wildcards over the choice axes, one aggregated specification-curve output.
  See `just multiverse` (`13-commands.md`).
- The control / hypothesis generators are shared with `09-testing.md` fixtures and
  `05-dashboards.md` schematics — one set of synthetic generators, three uses.
- The whole robustness check is summarized in the analysis's **dashboard**
  (`05-dashboards.md`) and its decisions recorded in the **analysis log**
  (`03-analysis-log.md`).

## Checklist (headline analyses)

- [ ] The 2–4 most consequential choices identified and swept (multiverse-lite);
      the effect reported across the grid, not just the chosen cell.
- [ ] Positive control present and firing (else the null is uninterpretable).
- [ ] Negative control present and silent (else the effect is an artifact).
- [ ] Load-bearing assumptions stated with a sensitivity statement for each.
- [ ] Pipeline frozen against synthetic/blinded data before unblinding, where feasible.
- [ ] Robustness summarized in the dashboard; decisions in the analysis log.
