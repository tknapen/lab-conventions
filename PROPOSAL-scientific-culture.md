# Proposal — from a pipeline harness to a *how-to-do-science* harness

**Status:** proposal for discussion. Nothing here is wired into the convention
index yet. Each item is independently adoptable; pick a subset, reorder, or send
back.

**Date:** 2026-06-22

---

## 1. The problem this proposal addresses

The conventions as they stand (`00`–`13`) are excellent at cementing a *technical*
pipeline: environments, packaging, code quality, testing, notebooks, pipelines,
layout, data formats, storage. Two files already reach past the pipeline into
*scientific culture* — principle 5 (`the analyst surfaces; the user judges`) and
`13-dashboards.md` (juxtapose the result with its hypotheses). They are the seed.
This proposal grows that seed into a coherent set of norms that govern **how we
reason**, not just **how we build**.

The goal, stated plainly so it can anchor every item below:

> We do **solid, not speedy** science. Reproducibility is necessary but not
> sufficient; what makes a result trustworthy is **inferential robustness** —
> never jumping to a conclusion, inspecting the data and the result from many
> angles, distinguishing a genuine effect from an analytic artifact, and letting
> the **user adjudicate** at every fork. Every reported result must be
> **interpretation-ready**: legible, with enough context to be understood when
> the user returns to it weeks or months later.

A specific, evidenced reason this matters *more* now that an AI agent is in the
loop: LLM analysts are measurably **overconfident** and tend to "advance through
analysis without adhering to user instructions, thereby missing crucial
insights," locking onto an early, over-simplified path
([IDA-Bench, 2025](https://arxiv.org/pdf/2505.18223); "[LLMs are overconfident
and amplify human bias](https://arxiv.org/pdf/2505.02151)";
[Google: LLMs abandon correct answers under
pressure](https://venturebeat.com/ai/google-study-shows-llms-abandon-correct-answers-under-pressure-threatening-multi-turn-ai-systems)).
The conventions are the place to install the brakes.

---

## 2. Prior art consulted

| Idea | Source |
|---|---|
| Researcher degrees of freedom / **garden of forking paths** — minor analytic choices manufacture findings | Gelman & Loken; [FORRT glossary](https://forrt.org/glossary/english/garden_of_forking_paths/) |
| **Multiverse analysis** / **specification curve** — run the reasonable analytic choices, report how the conclusion moves | [Multiverse analysis (Wikipedia)](https://en.wikipedia.org/wiki/Multiverse_analysis); Steegen et al.; Simonsohn et al. |
| **Many analysts, one dataset** — 70 teams, one fMRI dataset, materially divergent conclusions | [Botvinik-Nezer et al., *Nature* 2020](https://www.nature.com/articles/s41586-020-2314-9); [Silberzahn et al. 2018](https://pmc.ncbi.nlm.nih.gov/articles/PMC9971968/) |
| **Blind analysis** — design the analysis before seeing the answer, to defuse confirmation bias (standard in particle physics/cosmology) | [MacCoun & Perlmutter 2017](https://novel-coronavirus.onlinelibrary.wiley.com/doi/abs/10.1002/9781119095910.ch15); [Berkeley News](https://news.berkeley.edu/2015/10/08/blind-analysis-could-reduce-bias-in-social-science-research/) |
| **Sensitivity analysis / robustness checks / E-values** — quantify how much an unmodelled assumption would have to bite to overturn the claim | [VanderWeele & Ding, E-value](https://content.sph.harvard.edu/wwwhsph/sites/603/2017/08/EValue_Preprint.pdf) |
| **Positive & negative controls** as analysis sanity checks; **good-enough practices** | [Wilson et al., *Good enough practices in scientific computing*](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5480810/) |
| **Always plot the data** — identical summary stats, wildly different data | [Anscombe's quartet](https://en.wikipedia.org/wiki/Anscombe's_quartet); [Datasaurus dozen](https://www.research.autodesk.com/publications/same-stats-different-graphs/) |
| **Exploratory vs confirmatory** distinction; **HARKing**; preregistration | [Preregistration (Wikipedia)](https://en.wikipedia.org/wiki/Preregistration_(science)); Nosek et al.; Wagenmakers et al. |
| **Provenance as narrative / decision log** — a complete record of the reasoning is part of reproducibility | [The Turing Way](https://book.the-turing-way.org/reproducible-research/reproducible-research/) |
| **Reporting completeness** for neuroimaging specifically | [COBIDAS, Nichols et al. 2017](https://www.humanbrainmapping.org/files/2016/COBIDASreport.pdf) |
| **AI-agent overconfidence / premature commitment** in interactive analysis | [IDA-Bench 2025](https://arxiv.org/pdf/2505.18223); [overconfidence & bias amplification](https://arxiv.org/pdf/2505.02151) |

---

## 3. The alterations

Grouped, prioritized. Each carries: **what**, **where**, and **why (+ prior
art)**. Items marked **★** are the high-leverage core; the rest are reinforcing.

### ★ Group A — Elevate the culture into the principles (`00-principles.md`)

`00` currently has four reproducibility principles (1–4) plus one inference
principle (5). Add an **inference-and-judgment cluster** so the cultural norms
get equal billing with the technical ones. Proposed precedence note: principles
5–9 form the "how we reason" cluster and **jointly outrank 1–4 when they tension**
(it is better to be slow and right than reproducibly wrong).

Draft additions (matching the existing terse-with-a-`Why:` voice):

> **6. No premature conclusions — a result is provisional until the user judges.**
> Findings are reported as *candidate readings*, never settled verdicts: the
> default verb is "this is **consistent with** X," not "this **shows** X." At every
> point where the analysis could branch — an exclusion, a transform, a threshold,
> a model form — surface the fork and its alternatives and **stop for the user's
> call** rather than silently taking the path that confirms the expected story.
> *Why:* LLM analysts are measurably overconfident and tend to advance through an
> analysis without waiting for the user, locking onto an early over-simplified
> path (IDA-Bench). A premature conclusion costs a non-reproducible claim; a pause
> costs seconds. Solid, not speedy.

> **7. Look at the data before you summarize it.**
> Before any summary statistic, model fit, or test, render the raw distribution —
> the per-trial / per-voxel / per-subject points, not just the mean. Every
> headline number ships with the plot it came from.
> *Why:* Anscombe's quartet and the Datasaurus dozen — radically different data,
> identical summary statistics. A mean without its distribution is an assertion,
> not evidence.

> **8. One analysis is one path; robustness is part of the claim.**
> A single pipeline is one route through a garden of forking paths. A headline
> result is not done until it has been checked against the reasonable alternative
> choices (exclusions, transforms, thresholds, model forms) and the analyst has
> reported **how much the conclusion moves**. Every effect ships with a **positive
> control** (a condition where it must appear if the method works) and a
> **negative control** (one where it must not).
> *Why:* 70 teams analyzing one fMRI dataset reached materially different
> conclusions (Botvinik-Nezer 2020); analytic flexibility alone manufactures
> findings (multiverse / specification-curve). A result that survives its
> multiverse is a result; one that doesn't is a decision dressed as a discovery.

> **9. The record is part of the result.**
> Every headline analysis carries a running **decision log**: what was tried, what
> was chosen, what was ruled out and why, and which questions remain open —
> written so the user (or future-you, months later) can reconstruct the reasoning
> without re-deriving it.
> *Why:* provenance-as-narrative is the Turing Way's core of reproducibility, and
> the lab's stated goal is results that stay legible after weeks or months. The log
> is what turns a figure back into an argument.

Also extend the **"Corollaries for AI agents"** list with: *label every conclusion
provisional; stop at analytic forks and ask; never silently pick the
confirming branch; never present an exploratory finding as confirmatory.*

> *Note:* four new principles is a lot. A lighter variant is to add **6** and **8**
> as principles and demote **7** and **9** to the new files below. Your call.

### ★ Group B — New file `14-doing-science-with-claude.md` (agent conduct)

The keystone for "let the user decide on every step." A short file that
operationalizes principle 6 into concrete agent behavior. Contents:

- **The decision-point protocol.** Enumerate the recurring forks in a scientific
  analysis (subject/trial exclusion, outlier handling, transform, normalization,
  threshold, model family, multiple-comparison correction, ROI definition). At
  each, Claude **presents the options with their trade-offs and stops** — using
  `AskUserQuestion` for genuine forks — instead of choosing silently.
- **Provisional language is mandatory.** Banned verbs in result reporting
  ("proves", "confirms", "demonstrates" used of a single analysis) vs. preferred
  framing ("consistent with", "candidate reading", "the call is yours").
- **Exploratory vs confirmatory labeling.** Every analysis is tagged at the top as
  *exploratory* (hypothesis-generating, no strong inference) or *confirmatory*
  (pre-specified). Re-deriving a hypothesis from the data and reporting it as
  confirmatory (HARKing) is forbidden.
- **Surface disconfirming evidence first.** A standing instruction to actively look
  for, and lead with, the evidence *against* the expected result — the direct
  counter to LLM confirmation bias.
- **Calibration over confidence.** When stating how strong a result is, give the
  caveats and the things that would change the reading, not a bare confidence
  assertion (LLM self-confidence is poorly calibrated).

*Why:* this is the file that turns "the user adjudicates" from a slogan into a
behavior the agent can be held to. It is also the natural home for the
"how Claude should behave" content that is currently scattered across `00`.

### ★ Group C — New file `15-inferential-robustness.md`

The technical-cultural core: *how to check a result from many perspectives.*

- **Multiverse-lite.** For a headline effect, define the 2–4 most consequential
  analytic choices and run the small grid of reasonable combinations; report the
  effect across the grid (a mini specification curve), not just the chosen cell.
  Lean on the existing test fixtures and the `13-dashboards.md` generators.
- **Positive / negative controls** as a required companion to every effect, with
  worked fMRI examples (e.g. a localizer contrast that *must* fire; a label-shuffle
  / phase-scramble null that *must not*).
- **Sensitivity analysis.** State the load-bearing assumptions and show how far each
  can be pushed before the conclusion flips (E-value-style for confounding; reduced
  exclusions; alternative atlases/masks).
- **Blind-ish analysis where feasible.** Develop and freeze the pipeline against
  synthetic or label-shuffled data before looking at the real contrast of interest
  — adapting the particle-physics norm to a lab workflow.
- **Hooks into existing files:** the synthetic generators are the same ones
  `04-testing.md` and `13-dashboards.md` already build; the multiverse grid is a
  small Snakemake fan-out (`06`).

*Why:* analytic flexibility alone produces divergent, often non-replicable results
(many-analysts, multiverse). Robustness checks are how a single team approximates
the many-analysts insight in-house.

### Group D — New file `16-analysis-log.md` (the decision record)

Operationalizes principle 9. Every headline analysis ships an append-only
`analysis-log.md` (markdown, lives beside the notebook / in `docs/notes/`) capturing,
per entry: **date + commit**, the **question**, the **decision and its
alternatives**, **why**, **what was ruled out**, and **open questions**. A light
template + a `just log` helper to stamp date/commit. The log is the thing that makes
a result legible months later, and it is where the forks from Group B get recorded.

*Why:* Turing-Way provenance-as-narrative; directly serves the lab's "interpretation-
ready after weeks or months" goal.

### Group E — New file `17-reporting.md` (interpretation-ready reporting standard)

`13-dashboards.md` governs *figures*. This governs *every reported result* —
including numbers in prose, tables, and chat replies. A reported result is
incomplete unless it carries: the **question it answers**, **n**, the **error /
uncertainty** and what it represents, the **test** and its assumptions, the
relevant **reference / chance / ceiling**, the **effect in absolute and normalized
terms**, the **caveats**, and the **commit/date** it came from. Modeled on
COBIDAS reporting completeness, generalized beyond neuroimaging. Could alternatively
be folded into `13` as a "reporting, not just figures" section.

*Why:* "quantify rather than dismiss" and "elaborate over terse" (principle 5)
apply to prose and tables, not only figures. This closes that gap.

### Group F — Targeted edits to existing files

- **`04-testing.md`:** add a *positive/negative-control test* pattern and a
  *"can the method detect the planted effect?"* test (the dashboards' schematic
  generators, reused as tests). One paragraph + a code sketch.
- **`05-notebooks.md`:** add a *"look first"* rule — the first substantive cell of
  any analysis notebook plots the raw distributions before any summary (principle 7).
- **`09-when-to-deviate.md`:** add **HARKing** (presenting an exploratory finding as
  confirmatory) and **reporting a single un-robustness-checked path as a settled
  conclusion** to the **Unacceptable deviations** list; add *exploratory vs
  confirmatory labeling* as a standing requirement.
- **`08-commands.md`:** optional `just log` (stamp a decision-log entry) and
  `just multiverse <analysis>` (run the robustness grid) recipes.
- **`EXAMPLE_PROJECT_CLAUDE.md`:** add a *"How we reason here"* block pointing at the
  new files, and an *exploratory/confirmatory* status line in "Top of mind".

### Group G — Wiring

Update `LAB_CONVENTIONS.md` and `README.md`: add the new files to the index, add a
one-paragraph *"How we do science"* framing to the top of `LAB_CONVENTIONS.md`
(the boxed statement from §1 above), and bump the version with a note that this is
a **major** change (it adds mandatory norms, not just clarifications).

---

## 4. Suggested sequencing

1. **Group A** (principles) + **Group B** (agent conduct) — the cultural spine; cheap,
   high-leverage, and they make every later item enforceable.
2. **Group C** (inferential robustness) + **Group F** edits to `04` — the methodological
   muscle.
3. **Group D** (analysis log) + **Group E** (reporting) — the legibility/longevity layer.
4. **Group G** wiring + version bump once the above are settled.

---

## 5. Open questions for the user (these are forks — your call)

1. **Four new principles, or two?** Add 6–9 as full principles, or keep 6 & 8 as
   principles and move 7 & 9 into files C/D?
2. **One big file or several?** B/C/D/E as four files, or consolidate (e.g. one
   `14-inference-and-conduct.md`)? More files = more navigable; fewer = less to read.
3. **Reporting standard:** new `17-reporting.md`, or a new section inside `13`?
4. **How hard are the mandates?** Should "headline analyses ship a multiverse +
   controls + decision log" be a *hard rule* (like the data-tier rules) or a
   *strong default* with documented deviations under `09`?
5. **Scope of `just` automation** for the log and the multiverse grid — worth it,
   or leave it manual at first?
