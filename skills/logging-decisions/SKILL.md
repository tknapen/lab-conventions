---
name: logging-decisions
description: Maintains the append-only per-analysis decision log that records what was tried, chosen, ruled out, and why. Use whenever an analytic decision is made (exclusion, transform, threshold, model choice), whenever a fork is resolved with the user, whenever a run is launched (to write its expectation) or read (to score it), whenever a result turns or an analysis session ends, and whenever starting work on an analysis that lacks a log. The record is part of the result.
---

# Logging decisions

Every headline analysis carries a running, append-only decision log (principle 5) — the document that lets the user, or future-you months later, reconstruct *why the analysis is the way it is* without re-deriving it. Throwaway exploration is exempt.

## Where

One markdown file per analysis, committed: `docs/notes/<analysis>.log.md` (or beside the notebook). `just log <analysis>` appends a stamped entry template and opens the editor.

## Entry template

```markdown
## 2026-06-22 · commit a1b2c3d · exploratory

**Question.** Does contrast adaptation differ between V1 and V4?
**Expectation.** Steeper adaptation in V4 (prior: Kohn 2007). If V1 ≥ V4, the eccentricity confound is the first alternative to check.

**Decision.** Excluded sub-07 (motion > 1.5 mm on >20% of TRs).
**Alternatives considered.** Keep with motion regressors; keep with scrubbing.
**Why.** Motion correlated with the task regressor (r = 0.4) → confound, not noise.
  Direction unchanged with sub-07 kept (see multiverse grid) — a power decision, not an existence one.

**Ruled out.** Power-law adaptation model — no better than exponential (ΔAIC < 2), extra parameter. Parked, not rejected.

**Open questions.** Is the V4 effect driven by the foveal sub-ROI? Not yet checked.
**Status.** Candidate reading: adaptation steeper in V4. The call is the user's.
```

When a run is read, the entry scores the expectation it was launched under and nothing more elaborate:

```markdown
## 2026-06-24 · commit b2c3d4e · exploratory — as-run

**Against the 06-22 expectation.** As expected: V4 steeper in 6 of 7 subjects (results/adaptation/by_subject.parquet; dashboard §2).
**Surprise (post hoc).** The V1 slope flips sign in the two subjects with the largest pupil — not anticipated; a reading formed after seeing the data.
**Forks.** (a) pupil as a covariate, (b) split by eccentricity, (c) stop here. The call is the user's.
```

## Gates

- **Append-only.** Correct a past entry with a new dated entry, never by editing the old one — false starts and dead ends are the most valuable part of the record.
- **Stamp date + commit + exploratory/confirmatory tag** on every entry.
- **Record alternatives and the reason**, as decisions are made — not reconstructed later.
- **Ruled-out branches stay** (marked parked vs rejected) so the same dead end isn't re-explored.
- Keep **open questions** and the current **candidate reading** current.
- **Expectation scaled to the tier** (CORE.md, *two tiers*). A gate run carries one short expectation, written before the run, and is scored *as expected* / *not as expected* / *surprise* when read; every reading formed after seeing the data is labelled **post hoc** in the entry that introduces it. Numbered, individually scored predictions are written only for claim-tier analyses. Do not re-score an old expectation in place — a changed reading is a new dated entry that says what changed.
- **Short.** An entry is about a screen: what was decided, what was expected, how it came out, what is open. Numbers live in the products (tables, parquet, dashboard) and the entry links to them; a per-ROI or per-subject table in the log is a sign the entry has become a results store.

Not the commit log (that records what changed in the *code*; this records what was decided about the *science*), and not a results store (link to `results/` and the dashboard). The user reads the lab-meeting report (`reporting-results`), not the log; the log is the record behind it.
