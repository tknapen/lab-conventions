# 04 — Reporting (interpretation-ready results)

`05-dashboards.md` governs the craft of *figures*. This file governs **every
reported result** — numbers in prose, tables, slide bullets, and the agent's own
chat replies. It is the operational form of principle 1 (`00-principles.md`)
applied beyond figures: *quantify rather than dismiss; elaborate over terse.*

A result is **interpretation-ready** when someone — including the user returning
after weeks or months — can understand it, and what it does and does not support,
**without** re-reading the methods or re-running the code. That is the bar.

This is a **strong default** for reported results; exploratory scratch output is
exempt (`16-when-to-deviate.md`).

*Why:* a bare number ("r = 0.31, p = 0.04") is uninterpretable on return — against
what chance level, with what n, what error, in which ROI, from which commit, with
what caveats? Neuroimaging's own reporting standards exist precisely because
under-reported results are unreproducible and unreadable (COBIDAS; Nichols et al.,
2017). The same completeness applies to a sentence in a Slack message.

## The reporting unit

Every reported headline result carries, in the figure / table / sentence or
immediately beside it:

1. **The question it answers** — in plain language, before the number.
2. **n** — and the unit (subjects? trials? voxels?).
3. **The estimate** — with its **uncertainty** and *what the uncertainty is*
   (±1 SEM across subjects, 95% bootstrap CI, posterior HDI — say which).
4. **The reference** — chance / baseline / ceiling / null, so the estimate has a
   scale. An effect is always *relative to* something; name it.
5. **Absolute and normalized views** when one hides what the other shows (a small
   absolute effect that is a large fraction of a collapsed ceiling, and vice versa).
6. **The test** and its assumptions, where a test is claimed.
7. **The caveats** — power, reliability ceiling, confounds, exclusions — *shown and
   weighed*, never used to silently delete the effect (principle 1).
8. **Provenance** — the commit / date / dataset the number came from, so it can be
   regenerated and trusted on return.
9. **Named outcome, not bare absence** — a null is reported as *equivalence*,
   *underpowered*, or *true null*, distinguished, never as "nothing here".

## Match reporting to the project's inference regime

The reporting unit depends on the project's **declared regime**
(`02-inferential-robustness.md`). For a **low-n / high-trial** project: show **every subject
individually** rather than only a group mean — the individual replications *are* the evidence; the
error bar of first resort is **within-subject** (a trial / stimulus resampling CI); the replication
statement is cross-subject **consistency** (*k of N*, each within-subject reliable); and a low-n
descriptive ROI / voxel sweep is **not** collapsed to a single multiple-comparison-corrected group
*p* — report the profile with its per-subject spread. For a **population-level** project the group
estimate with its multiple-comparison control is the headline, with individual-subject display as
support.

## Provisional framing carries into prose

The language rules from `01-doing-science-with-claude.md` apply to all reporting:
candidate readings, not verdicts; at least one named alternative; the call deferred
to the user. Of a single analysis, write "is consistent with", not "shows that".

## Worked contrast

> **Terse (insufficient):** "V4 adapts more than V1 (p = 0.04)."

> **Interpretation-ready:** "**Does adaptation differ across areas?** Across n = 23
> subjects, the adaptation index is steeper in V4 than V1 (Δ = 0.12, 95% CI
> [0.01, 0.23]; paired t-test). Chance Δ is 0; the split-half reliability ceiling
> on this index is ~0.35, so the effect is ~34% of the recoverable range — modest
> in absolute terms but a large fraction of what is measurable. The positive
> control (stimulus-drive localizer) fires in both areas; the label-shuffle null is
> flat. One subject (sub-07, motion confound) is excluded; the direction is
> unchanged with them kept. **Candidate reading:** steeper adaptation in V4 — but
> the CI's lower bound is near zero and this is exploratory; the call is yours.
> (commit a1b2c3d, dataset ds00X)."

The second form is longer on purpose. "Elaborate over terse" is the standard.

## Hard rules (the few that are gates)

- **No naked number.** A reported headline statistic without n, uncertainty, and a
  reference level is incomplete.
- **State what the error bar means**, every time — SEM vs CI vs HDI is not optional.
- **A null is a named outcome** (equivalence / underpowered / true null), never bare
  absence.
- **Stamp provenance** (commit/date/dataset) on reported headline results.

## Checklist

- [ ] The question is stated in plain language before the number.
- [ ] n, estimate, uncertainty (and its kind), and a reference level are all present.
- [ ] Absolute *and* normalized views where one hides what the other shows.
- [ ] Caveats shown and quantified, not used to delete the effect.
- [ ] Nulls reported as named outcomes.
- [ ] Reporting matches the project's declared regime (low-n: individuals + within-subject error + consistency, no MC over a sweep; population-level: group estimate + MC).
- [ ] Provenance (commit/date/dataset) attached.
- [ ] Framed as a candidate reading with the call deferred to the user.
