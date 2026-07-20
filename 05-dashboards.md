# 05 — Interpretation dashboards (juxtapose the result with its hypotheses)

A bare result figure encodes *what* was found, not *what it means* or *what else it
could have been* — the reader supplies those from memory, which is exactly where a
result gets misread (including by the author six months later).

> A bare result figure asks the reader to **simulate the alternatives in their
> head**. A dashboard **renders** them — each through the *same plot function* as the
> result — so "which world is this?" becomes a visual match, not a feat of memory.

## The standard

Every **headline** analysis (result enters a paper, a decision, or a go/no-go) ships an **interpretation
dashboard**, not a bare figure: the result plot in direct juxtaposition with (1) schematic plots of what
each competing hypothesis would look like and (2) self-contained text — concept, metric, verdict.
Exploratory and intermediate plots are exempt.

This sits **on top of** the scientific-figures skill (`skills/scientific-figures/`, panel craft) and is
the operational expression of **principle 1** (`00`, surface don't adjudicate): the dashboard makes the
evidence and competing readings legible and leaves the call to the reader — readings framed as *candidates*
("the call is yours"), caveats shown next to their effect (never used to delete it), absolute *and*
normalized views where one hides what the other shows.

## Principle 1 — schematics come from the *result's own plot function*, fed idealized data

The load-bearing rule. For each competing hypothesis, **synthesize idealized data that embodies it** and
push it through the **exact plot function** used for the real result — never a hand-drawn cartoon. Payoffs a
cartoon forfeits:

- **Comparability** — same axes, encoding, scale, colour semantics as the result, so the reader
  pattern-matches directly.
- **Honesty** — the schematic shows what the analysis *would actually render* under that hypothesis,
  including its noise and ceiling, not an idealised fiction.
- **Method validation** — if idealized "rotation" data doesn't produce a visibly distinct plot, the
  analysis *cannot detect rotation*; better to learn that here than after a false claim. These generators
  are the **same fixtures that test the analysis** (`09`) — write once, use for both.

## Principle 2 — the dashboard is self-documenting

Legible to someone who has never seen the analysis. It carries, in prose on the figure or page: the
**concept** (what is tested and why), the **metric definitions** (each axis/quantity, its assumptions and
ceilings), and an **auto-derived verdict** computed from the data (e.g. a classifier returning
`same_operator` / `rotation` / `underpowered`), not asserted by hand. If reading it needs an external
methods section, it is not done.

## Principle 3 — show the honest nulls

The hypothesis row **must include the null and the underpowered / uninformative cases**, rendered like the
live hypotheses. This is what lets a null read as a *positive match to a named world* ("same operator",
"underpowered") rather than an absence — distinguishing *equivalence* from *failure-to-reject* from
*underpowered* is a first-class job of the schematic row, and the single most common misreading this
convention prevents.

## Layout and process

Hypothesis schematics as a row (the menu of possible worlds) directly adjacent to the **result** in the
identical encoding; concept/metric text alongside; the verdict highlighted. Reading path: *possibilities →
reality → reading*, ordered as the argument considers them. For each headline analysis: (1) enumerate the
competing hypotheses incl. null and underpowered, each with a one-line meaning; (2) write one generator per
hypothesis → the result plot function → a schematic (reuse the test fixtures); (3) render the real data
through the same function; (4) compose schematic row + result + concept text + auto-verdict.

## The dashboard's home is a narrated notebook

An on-figure text panel is cramped — no equations, no citations. The dashboard's real home is a **narrated
results notebook** (marimo; `10`): each headline analysis becomes a section pairing its dashboard *and the
cortical maps / raw views behind it* with the concept, the metric **equation(s)** (marimo renders LaTeX),
the **references**, the stated expectation, and the candidate reading — the "what does this mean" steps the
dashboard renders *visually*, also written out. A standalone dashboard image is then a **build artifact**
(a slide/PR export produced by a script calling the *same* `src/` functions), not the primary deliverable;
shipping only loose PDFs under-implements the convention. It inherits the thin-notebook rules (`10`): thin
cells, all prose in `mo.md`, no analysis logic in the notebook, a provenance line at the top, cached long
renders, `marimo export html` wired into the `justfile`. Litmus test: a reader six months out follows each
claim question → method (with equation) → competing hypotheses (schematic row) → cortical map → candidate
reading, with no second document.

## Worked example — the forward/backward covariance rotation test

"Are the forward and backward second-moment representations the *same operator*, a *rotation*, or
*independent*?" — four named worlds, each one small synthetic covariance pair fed to the same
alignment-vs-ceiling plot as the real result:

| Hypothesis | Idealized data | Schematic signature |
|---|---|---|
| Same operator | identical covariance both directions | cross line sits *on* the within-direction ceiling |
| Rotation | same eigenvalue spectrum, orthogonal leading eigenvectors | cross line *below* a high ceiling |
| Independent | different spectrum and eigenvectors | cross and ceiling both low/divergent |
| Underpowered | near-chance ceiling (weak signal) | ceiling ≈ chance floor; no verdict possible |

Rendered beside the real cohort line and the auto-verdict, a reader sees the data sits on the
*same-operator* template — and that "rotation" was a real, detectable alternative that did not occur, not a
possibility the method was blind to.

## Checklist

- [ ] Headline analyses ship a dashboard, not a bare figure.
- [ ] Every schematic is generated by the *result's own plot function* fed idealized data — no cartoons.
- [ ] The null and underpowered cases are among the schematics.
- [ ] Concept, metric, and a *candidate* reading are on the artifact; no external doc needed to read it.
- [ ] The verdict is framed as candidate reading(s), deferred to the user (principle 1); caveats shown and
      quantified, not dropped; absolute *and* relative views where one hides what the other shows.
- [ ] Schematic generators are shared with the analysis's test fixtures (`09`).
- [ ] Panel craft follows `skills/scientific-figures/`.
- [ ] Dashboards live in a **narrated marimo notebook** (concept + equation(s) + references + candidate
      reading around each figure); standalone figure files are *exports* of the same functions.
