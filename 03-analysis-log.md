# 03 — The analysis log

Every headline analysis carries a running, append-only **decision log** — the
operational form of principle 5 (`00`): *the record is part of the result.* It lets
the user (or future-you, months later) reconstruct *why the analysis is the way it
is* without re-deriving it. Strong default for headline work; throwaway exploration
is exempt (`16`).

*Why:* reproducibility is a complete narrative of the decisions, not just "the code
runs" (The Turing Way, `REFERENCES.md`); a figure without its log is a conclusion
whose reasoning has evaporated. It is also where the forks from `01` get recorded as
they are adjudicated.

## Where it lives

One markdown file per analysis, append-only, committed to git (principle 7):

```
docs/notes/<analysis>.log.md      # or beside the notebook
```

## What each entry contains

Append a dated entry whenever a decision is made, a fork resolved, or a result turns. Short — the reasoning,
not prose. `just log` stamps date + commit (`13`).

```markdown
## 2026-06-22 · commit a1b2c3d · exploratory

**Question.** Does contrast adaptation differ between V1 and V4?

**Decision.** Excluded sub-07 (motion > 1.5 mm on >20% of TRs).
**Alternatives considered.** Keep with motion regressors; keep with scrubbing.
**Why.** Motion correlated with the task regressor (r = 0.4) → confound, not noise.
  Direction unchanged with sub-07 kept (see multiverse grid) — a power decision, not an existence one.

**Ruled out.** Power-law adaptation model — fit no better than exponential (ΔAIC < 2), extra parameter.
  Parked, not rejected.

**Open questions.** Is the V4 effect driven by the foveal sub-ROI? Not yet checked.
**Status.** Candidate reading: adaptation steeper in V4. The call is the user's.
```

Not the commit log (that records *what changed in the code*; this records *what was decided about the
science and why*) and not a results store (those live in `results/` and the dashboard; the log *links* to
them).

## Checklist (★ = hard gate)

- [ ] ★ One **append-only** `*.log.md` per headline analysis, committed — correct a past entry with a new
      dated entry, never by editing the old one.
- [ ] ★ Each entry stamped with **date + commit** and an exploratory/confirmatory tag.
- [ ] Decisions recorded *with their alternatives and the reason*, as they are made.
- [ ] ★ Ruled-out branches kept (parked vs rejected), not deleted — so the same dead end isn't re-explored.
- [ ] Open questions and the current candidate reading kept current.
