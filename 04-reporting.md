# 04 — Reporting (interpretation-ready results)

`05` governs the craft of *figures*; this file governs **every reported result** —
numbers in prose, tables, slide bullets, chat replies. It is principle 1 (`00`)
beyond figures: *quantify rather than dismiss; elaborate over terse.*

A result is **interpretation-ready** when someone — including the user returning
months later — can understand it, and what it does and does not support, **without**
re-reading the methods or re-running the code. That is the bar.

Strong default for reported results; exploratory scratch is exempt (`16`).

*Why:* a bare "r = 0.31, p = 0.04" is uninterpretable on return — against what
chance level, what n, what error, which ROI, which commit? Under-reported results are
unreproducible (COBIDAS; `REFERENCES.md`), and this applies to a sentence in Slack as
much as to a paper.

## The reporting unit

Every reported headline result carries, in or beside the figure / table / sentence:

1. **The question it answers** — plain language, before the number.
2. **n** — and the unit (subjects? trials? voxels?).
3. **The estimate** — with its **uncertainty** and *what it is* (±1 SEM, 95% CI, HDI — say which).
4. **The reference** — chance / baseline / ceiling / null, so the estimate has a scale.
5. **Absolute *and* normalized views** when one hides what the other shows.
6. **The test** and its assumptions, where a test is claimed.
7. **The caveats** — power, ceiling, confounds, exclusions — shown and weighed, never used to silently
   delete the effect (principle 1).
8. **Provenance** — commit / date / dataset, so it can be regenerated and trusted on return.
9. **Named outcome, not bare absence** — a null is *equivalence*, *underpowered*, or *true null*.

Provisional framing (`01`) applies to prose too: candidate readings not verdicts, ≥1 named alternative, the
call deferred. **Match the reporting to the project's declared regime** (`02`): low-n → show every subject,
within-subject error, cross-subject consistency, no MC over a descriptive sweep; population-level → the
group estimate with MC control as the headline.

## Worked contrast

> **Terse (insufficient):** "V4 adapts more than V1 (p = 0.04)."

> **Interpretation-ready:** "**Does adaptation differ across areas?** Across n = 23 subjects, the adaptation
> index is steeper in V4 than V1 (Δ = 0.12, 95% CI [0.01, 0.23]; paired t-test). Chance Δ is 0; the
> split-half reliability ceiling is ~0.35, so the effect is ~34% of the recoverable range — modest in
> absolute terms but a large fraction of what is measurable. Positive control (localizer) fires in both
> areas; the label-shuffle null is flat. One subject (sub-07, motion confound) excluded; direction
> unchanged with them kept. **Candidate reading:** steeper adaptation in V4 — but the CI's lower bound is
> near zero and this is exploratory; the call is yours. (commit a1b2c3d, dataset ds00X)."

The second form is longer on purpose. "Elaborate over terse" is the standard.

## Checklist (★ = hard gate)

- [ ] The question is stated in plain language before the number.
- [ ] ★ n, estimate, and uncertainty (SEM/CI/HDI — say which) with a reference level — **no naked number**.
- [ ] Absolute *and* normalized views where one hides what the other shows.
- [ ] Caveats shown and quantified, not used to delete the effect.
- [ ] ★ Nulls reported as named outcomes (equivalence / underpowered / true null).
- [ ] Reporting matches the declared regime (`02`).
- [ ] ★ Provenance (commit/date/dataset) attached.
- [ ] Framed as a candidate reading with the call deferred to the user.
