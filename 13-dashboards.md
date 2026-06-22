# 13 — Interpretation dashboards (juxtapose the result with its hypotheses)

A result figure encodes *what* was found. It does not encode *what it means*, or *what else it could
have been* — the reader is expected to supply those from memory. Interpreting a bare result is really
four steps the reader does in their head: (a) recall the analysis logic, (b) hold the competing
hypotheses, (c) simulate each hypothesis's visual signature, (d) match the data to the nearest one.
Steps (b)–(d) are exactly where a result gets misread, and where anyone not already fluent in the
analysis is locked out — including the author six months later.

The reframe that fixes this:

> A bare result figure asks the reader to **simulate the alternatives in their head**. A dashboard
> **renders** them — each through the *same plot function* as the result — so "which world is this?"
> becomes a visual match instead of a feat of memory.

## The standard

Every **headline** analysis — one whose result enters a paper, a decision, or a go/no-go breakpoint —
ships an **interpretation dashboard**, not a bare figure. A dashboard is the result plot placed in
direct juxtaposition with (1) schematic plots of what each competing hypothesis would look like and
(2) self-contained text explaining the concept, the metric, and the verdict. Exploratory and
intermediate plots are exempt; the dashboard is for the figures that carry a claim.

This convention sits **on top of** the scientific-figures skill (`skills/scientific-figures/`): that
skill governs the craft of each individual panel (spines, palette, annotation, physical size); this
doc governs the **composition for interpretation** — pairing result with hypotheses and prose.

## Stance: surface, don't adjudicate

A dashboard is the operational expression of **principle 5** (`00-principles.md`): *the analyst
surfaces, the user judges.* Its job is to make the evidence and the competing readings maximally
legible and to leave the scientific call to the reader. Throughout the dashboard:

- **Report patterns and gradients descriptively; do not collapse to a single strict verdict.** Where a
  reading is offered, frame it as a *candidate* and make the deferral explicit ("the call is yours").
  Show the plausible readings side by side — which the hypothesis-schematic row already does by
  construction, so this stance and this format reinforce each other.
- **Quantify, don't dismiss.** A caveat (low ceiling, low power, a confound) is shown and weighed —
  never used to delete an effect from view. The canonical failure this guards against: labelling an
  elevated-but-low-ceiling effect "underpowered noise" and dropping it, when it may be the signal the
  user most wants. State the caveat next to the effect and let the reader weigh it.
- **Show both absolute and normalized/relative views** whenever one hides structure the other reveals
  (e.g. a small absolute effect that is a large *fraction* of a collapsed ceiling).
- **Elaborate over terse.** Reference/chance/ceiling lines, in-panel effect annotations, stated
  n / error / test — the opposite of the sparse single-metric plot. More interpretation-facilitating
  information is the goal, not minimalism.

The "honest nulls" rule below — distinguishing a null from an underpowered or an equivalent result —
is part of the same stance. None of this is a licence to overclaim: the discipline is to surface
*everything with its caveats*, which is simultaneously less dismissive and more honest.

## Principle 1 — hypothesis schematics come from the *same plot function*, fed idealized data

This is the load-bearing rule. For each competing hypothesis, **synthesize idealized data that embodies
it** and push that data through the **exact plot function** used for the real result. Never hand-draw a
cartoon of "what rotation would look like."

Three payoffs, all of which a cartoon forfeits:

- **Comparability.** Same axes, same encoding, same scale, same colour semantics as the result, so the
  reader pattern-matches directly instead of translating between a stylised cartoon and real data.
- **Honesty.** The schematic shows what the analysis *would actually render* under that hypothesis —
  including its noise, its ceiling, its power limits — not an idealised fiction that the method could
  never produce.
- **It doubles as a method validation.** If the idealized "rotation" data does not produce a visibly
  distinct plot, the analysis *cannot detect rotation* — and it is far better to learn that here than
  after a false claim. The synthetic generators that embody each hypothesis are the **same fixtures
  that test the analysis** (`04-testing.md`): the planted-effect and null cases a good test suite
  already builds are exactly the dashboard's schematics. Write them once; use them for both.

## Principle 2 — the dashboard is self-documenting

A dashboard must be legible to someone who has never seen the analysis. It carries, in prose on the
figure or page:

- the **concept** — what is being tested and why, in plain language;
- the **metric definitions** — what each axis/quantity is, and its assumptions and ceilings;
- an **auto-derived verdict** — which hypothesis the result matches, computed from the data (e.g. a
  classifier that returns `same_operator` / `rotation` / `underpowered`), not asserted by hand.

If reading the dashboard requires an external methods section, it is not done.

## Principle 3 — show the honest nulls

The hypothesis row **must include the null and the underpowered / uninformative cases**, rendered the
same way as the live hypotheses. This is what lets a null result read as a *positive match to a named
world* ("same operator", "no penalty", "underpowered") rather than as an absence or a failure. A
dashboard that only shows the exciting hypotheses next to a flat result invites the reader to see
"nothing" instead of "equivalence" — the single most common scientific misreading, and the one this
convention exists to prevent. Distinguishing *equivalence* from *failure-to-reject* and from
*underpowered* is a first-class job of the schematic row.

## Layout

- The **hypothesis schematics** as a row (or column) — the menu of possible worlds — directly
  adjacent to the **result** in the identical encoding.
- **Concept/metric text** alongside; the **verdict** highlighted.
- Reading path: *possibilities → reality → reading*. Order the schematics so the eye travels through
  them in the order the argument considers them (e.g. strongest-claim first, null last, or
  hierarchy-ordered).
- Panel-letter and house-style rules are the scientific-figures skill's job; apply them here too.

## The process (and what it produces)

For each headline analysis:

1. **Enumerate the competing hypotheses**, including the null and the underpowered case, each with a
   one-line meaning. (This is the "interpretation guide" table many analyses already write — make it
   executable.)
2. **Write one generator per hypothesis**: idealized data → the result plot function → a schematic.
   Reuse the analysis's test fixtures.
3. **Render the real data** through the same plot function → the result panel.
4. **Compose** schematic row + result + concept text + auto-verdict into one artifact.

**Format.** A single composed vector figure (PDF + SVG) for papers and slides, and/or an HTML page for
exploration — both driven by the *same* generators, never a separately maintained mockup. Save under
`figures/<analysis>/dashboard.{pdf,svg,html}`. The hypothesis generators live in the analysis's plot
module (or its tests); the composer is a thin, reusable layout helper, not bespoke per analysis.

## Worked example — the forward/backward covariance rotation test

The question "are the forward and backward second-moment representations the *same operator*, a
*rotation*, or *independent*?" has four named worlds. Each is one small synthetic covariance pair fed
to the same alignment-vs-ceiling plot used for the real result:

| Hypothesis | Idealized data | Schematic signature |
|---|---|---|
| Same operator | identical covariance both directions | cross line sits *on* the within-direction ceiling |
| Rotation | same eigenvalue spectrum, orthogonal leading eigenvectors | cross line *below* a high ceiling |
| Independent | different spectrum and eigenvectors | cross and ceiling both low/divergent |
| Underpowered | near-chance ceiling (weak signal) | ceiling ≈ chance floor; no verdict possible |

The dashboard renders these four signatures beside the real cohort line and the auto-derived verdict.
A reader with no prior exposure sees immediately that the data sits on the *same-operator* template —
and that "rotation" was a real, detectable alternative that did not occur, not a possibility the
method was blind to.

## Checklist

- [ ] Headline analyses ship a dashboard, not a bare figure.
- [ ] Every hypothesis schematic is generated by the *result's own plot function* fed idealized data —
      no hand-drawn cartoons.
- [ ] The null and underpowered cases are among the schematics.
- [ ] Concept, metric, and a *descriptive* reading are on the artifact; no external doc needed to read it.
- [ ] The verdict is framed as candidate reading(s) and explicitly deferred to the user (principle 5).
- [ ] Every caveated effect is shown and quantified, not dropped; absolute *and* relative views where one hides what the other shows.
- [ ] Schematic generators are shared with the analysis's test fixtures.
- [ ] Panel craft follows `skills/scientific-figures/`.
