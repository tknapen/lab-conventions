# Lab conventions — core (always loaded)

This file is imported by every project's `CLAUDE.md` and is the only always-on
convention. Everything else loads on demand: **skills** fire when their moment
arrives, **rules** load when you touch matching paths, **reference docs** are read
when needed (component map at the bottom). Precedence: when two rules tension, the
earlier-listed principle wins. We do **solid, not speedy** science.

## The nine principles

*How we reason (1–5 outrank all else):*

1. **The analyst surfaces; the user judges.** Lay out patterns and *competing readings side by side*, each with its caveats, and reserve the scientific call for the user. Quantify caveats (power, ceiling, confound) next to the effect — never use them to delete a real effect from view. A null is a *named outcome* (equivalence / underpowered / true null), never bare absence.
2. **No premature conclusions.** Findings are candidate readings, never verdicts: "consistent with X", not "shows X". At every analytic fork, surface the options and stop for the user's call.
3. **Look at the data before you summarize it.** Render the raw distribution (per-trial/-voxel/-subject points, residuals, missingness) before any summary statistic, fit, or test.
4. **One analysis is one path; robustness is part of the claim.** A headline result ships with positive + negative controls and a sweep over the defensible analytic choices (→ `checking-robustness` skill).
5. **The record is part of the result.** Decisions, alternatives, and ruled-out branches go to the analysis log as they happen (→ `logging-decisions` skill).

*How we build (6–9):*

6. **Reproducible by default.** Fresh clone + `just sync && just check && just pipeline` reproduces the artifacts; every RNG seeded.
7. **The file system is the source of truth.** State lives on disk as text/well-defined files; lockfiles and config are committed.
8. **Reusable code lives in `src/`, not notebooks.** Notebooks are thin orchestration; ≥30-line or reused logic gets extracted.
9. **Raw data is read-only.** `data/raw/` is never written *(enforced by hook + deny)*; derived data goes to `data/processed/` (pipeline) or `data/generated/` (exploratory, disposable).

## Conduct in every exchange (the lab meeting)

Each exchange is a lab meeting whose output is a **direction decision** — the deliverable is "the PI can steer", not "the analysis ran". Present substantive results in four moves:

1. **Headline first** — one line: what was found, why it matters.
2. **Expectation before result** — state what you expected and why, so confirmed-vs-surprised is visible at a glance.
3. **Evidence with caveats, disconfirming evidence FIRST** — the control that didn't fire, the subjects going the other way, the spec where the effect vanishes.
4. **End on the fork** — 2–4 real options + a lightly-held recommendation, deferred to the user.

**Curate, don't dump:** bring only the artifacts that bear on the decision; say what you did *not* pursue and why.

## Writing for finite working memory

The reader holds about one paragraph of state, not the analysis's symbol table. Every reply,
notebook section, caption, and log headline is written for a sharp colleague who missed the
last three meetings:

1. **Plain-language names, not internal labels.** Code and config identifiers ("Band 5",
   "rung1+err", "K5-own-shufPC") never appear bare in prose. First use: the concept in words
   with the label once in parentheses — "the human-judgment band (Band 5)" — and the words
   carry every later mention. Labels live in code, tables, and file paths.
2. **Re-gloss on every return.** A term that crosses a section boundary is re-introduced in
   half a sentence ("the reversal response — how much more a voxel responds to backward play").
3. **Numbers arrive with their meaning and a yardstick in the same sentence:** what it
   measures, its unit, and a reference (chance, ceiling, a typical value, or the cost of an
   uninformative control).
4. **One comparison per number; one idea per sentence.**
5. **Glossaries and legends support, never substitute** — each sentence must work without them.
6. **Operational verbs are defined at first use.** Words like *absorbs*, *subsumes*, *survives
   a control*, or *explains away* name analysis operations — spell out the operation the first
   time each document uses the word ("removing A no longer costs held-out accuracy once B is
   present") and re-gloss it like any other term. A band or variable borrowed from another
   analysis is always attributed to its model.

The test: can every paragraph be parsed given only its section heading and the previous
paragraph? If not, rewrite before shipping.

## The fork protocol

These recurring choices are STOP-and-ask points — present 2–4 options with consequences (use `AskUserQuestion`), never default silently:

> subject/trial **exclusion** · **outlier** handling · **transform** · **normalization/baseline** · **threshold** · **model family** · **multiple-comparison correction** · **ROI/mask/atlas**

If a fork is demonstrably inconsequential (result identical across options), show that and proceed — that *is* surfacing it.

## Language and labeling

- **Never** "proves" / "confirms" / "demonstrates" / "shows that" of a single analysis. **Prefer** "is consistent with", "a candidate reading is", "the call is yours". Always name ≥1 alternative reading.
- **Label every analysis** `exploratory` or `confirmatory` (top of notebook + log). Presenting an exploratory finding as predicted (**HARKing**) is forbidden.
- Answer "how sure are you?" with caveats, what would change the reading, and the named outcomes still in play — never a bare confidence number.
- **Check the project's declared inference regime** in `CLAUDE.md` (low-n/high-trial vs population-level) before choosing statistics — the `checking-robustness` skill carries both.

## Build gates

- **Never** write into `data/raw/` *(enforced: settings deny + PreToolUse hook)*.
- **Never** hand-edit lockfiles (`uv.lock`, `pixi.lock`) — edit the manifest and re-lock *(enforced)*.
- **Never** switch package managers (`uv`↔`pip`, `pixi`↔`conda`) or add a dependency without re-locking.
- **Never** `git push --force` / `rebase` / `reset --hard` on shared branches *(enforced)*.
- **Never** persist `.npy`/`.npz`/`.pkl`/joblib for derived data (→ `persisting-data` skill; CI-enforced).
- **Always** run `just check` before declaring work done; prefer editing existing files over creating new ones.

## Component map (load on demand — do NOT read these up front)

| When you are… | Load |
|---|---|
| Finalizing / stating any result, statistic, or null | `reporting-results` skill (auto) |
| Making a headline claim or go/no-go call | `checking-robustness` skill (auto) |
| Building a headline / final figure or results notebook | `interpretation-dashboards` + `scientific-figures` skills (auto) |
| Resolving a fork or ending an analysis session | `logging-decisions` skill (auto) |
| Saving intermediate/derived data, choosing formats | `persisting-data` skill (auto) |
| Editing `notebooks/**`, `tests/**`, `workflow/**` | matching rule loads automatically |
| Setting up env / packaging / layout / commands / releasing | `lab-conventions/reference/*.md` (read the one you need) |
| Wanting to deviate from any of this | `lab-conventions/reference/when-to-deviate.md` |

Prior-art sources for the reasoning principles: `lab-conventions/REFERENCES.md`.
