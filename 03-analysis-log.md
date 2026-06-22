# 03 — The analysis log

Every headline analysis carries a running, append-only **decision log** — the
operational form of principle 5 (`00-principles.md`): *the record is part of the
result.* It is the document that lets the user (or future-you, months later)
reconstruct *why the analysis is the way it is* without re-deriving it.

This is a **strong default** for headline analyses; throwaway exploration is
exempt (`16-when-to-deviate.md`).

*Why:* reproducibility is not just "the code runs" — it is a complete narrative of
the planning and decisions, the provenance, that produced the result (The Turing
Way). The lab's stated goal is results that stay legible after weeks or months; a
figure without its decision log is a conclusion whose reasoning has evaporated. The
log is also where the forks from `01-doing-science-with-claude.md` get recorded as
they are adjudicated.

## Where it lives

One markdown file per analysis, append-only, committed to git:

```
docs/notes/<analysis>.log.md      # or beside the notebook: notebooks/<analysis>.log.md
```

It is plain markdown (principle 7: the file system is the source of truth), diffs
cleanly, and is read top-to-bottom as the story of the analysis.

## What each entry contains

Append a dated entry whenever a decision is made, a fork is resolved, or a result
turns. Keep entries short; the point is the *reasoning*, not prose.

```markdown
## 2026-06-22 · commit a1b2c3d · exploratory

**Question.** Does contrast adaptation differ between V1 and V4?

**Decision.** Excluded sub-07 (motion > 1.5 mm on >20% of TRs).
**Alternatives considered.** Keep with motion regressors; keep with scrubbing.
**Why.** Motion correlated with the task regressor (r = 0.4) → confound, not noise.
  Effect direction is unchanged with sub-07 kept (see multiverse grid), so this is
  a power decision, not an existence decision.

**Ruled out.** Power-law adaptation model — fit no better than exponential
  (ΔAIC < 2) and has an extra parameter. Parked, not rejected.

**Open questions.** Is the V4 effect driven by the foveal sub-ROI? Not yet checked.
**Status.** Candidate reading: adaptation is steeper in V4. The call is the user's.
```

The fields, minimally: **date + commit**, **exploratory/confirmatory tag**, the
**question**, the **decision** and its **alternatives**, **why**, **what was ruled
out** (and whether parked or rejected), **open questions**, and the current
**candidate reading** with the deferral to the user.

## Hard rules (the few that are gates)

- **Append-only.** Never rewrite history to make the path look straighter than it
  was — the false starts and ruled-out branches are the most valuable part of the
  record. Correct a past entry with a new dated entry, not by editing the old one.
- **Stamp the commit.** Every entry names the commit it refers to, so a reader can
  check out the exact code state. `just log` does this automatically (`13-commands.md`).
- **Ruled-out ≠ deleted.** Record what was tried and didn't work and *why*; this is
  what stops the same dead end being re-explored in six months.

## What it is not

- Not a lab notebook for wet-lab protocols (that is a separate instrument).
- Not the commit log — commits record *what changed in the code*; the analysis log
  records *what was decided about the science and why*. They complement each other.
- Not a place for results tables or figures — those live in `results/` and the
  dashboard (`05-dashboards.md`); the log *links* to them.

## Checklist

- [ ] One append-only `*.log.md` per headline analysis, committed.
- [ ] Each entry stamped with date + commit and an exploratory/confirmatory tag.
- [ ] Decisions recorded *with their alternatives and the reason*, as they are made.
- [ ] Ruled-out branches kept (parked vs rejected), not deleted.
- [ ] Open questions and the current candidate reading kept current.
