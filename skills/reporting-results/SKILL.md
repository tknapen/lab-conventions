---
name: reporting-results
description: The lab's interpretation-ready reporting standard for every stated result - in prose, tables, figures, chat replies, or Slack messages. Use whenever reporting any statistic, effect, correlation, model fit, comparison, or null result, whenever summarizing what an analysis found, and whenever composing the results portion of any reply to the user. Applies to a single sentence as much as to a paper.
---

# Reporting results

A result is **interpretation-ready** when someone returning months later understands it — and what it does and does not support — without re-reading methods or re-running code. A bare "r = 0.31, p = 0.04" fails that bar. Elaborate over terse.

## The reporting unit

Every reported headline result carries, in or beside the figure/table/sentence:

1. **The question it answers** — plain language, before the number.
2. **n** — and the unit (subjects? trials? voxels?).
3. **The estimate with its uncertainty**, saying which kind (±1 SEM, 95% CI, HDI). No naked numbers.
4. **The reference** — chance / baseline / ceiling, so the estimate has a scale.
5. **Absolute *and* normalized views** when one hides what the other shows (a small absolute effect can be a large fraction of a collapsed ceiling).
6. **The test** and its assumptions, where a test is claimed.
7. **The caveats** — power, ceiling, confounds, exclusions — quantified next to the effect, never used to silently delete it.
8. **Provenance** — commit / date / dataset, so the number can be regenerated and trusted.
9. **Named nulls** — equivalence, underpowered, or true null; never "nothing here".

Match the unit of evidence to the project's declared regime (see `checking-robustness`): low-n → every subject shown, within-subject error, *k of N* consistency; population-level → group estimate + MC control as the headline.

## Point-of-use glossing (finite working memory)

The nine items above fail if delivered in private shorthand. No bare internal labels in prose
("Band 5", config names) — name the thing by what it is, with the label once in parentheses;
re-introduce every term that crosses a section boundary; give every number its yardstick in
the same sentence (ceiling, chance, the cost of an uninformative control). The reader who
missed the last three meetings must parse each paragraph from its heading and the previous
paragraph alone.

## Presenting to the user (the lab-meeting grammar)

Headline first → expectation stated *before* the result (confirmed or surprised?) → evidence with disconfirming items first → end on the fork (2–4 options, recommendation deferred). Candidate readings, not verdicts; at least one named alternative; "the call is yours."

## Worked contrast

> **Insufficient:** "V4 adapts more than V1 (p = 0.04)."

> **Interpretation-ready:** "**Does adaptation differ across areas?** Across n = 23 subjects, the adaptation index is steeper in V4 than V1 (Δ = 0.12, 95% CI [0.01, 0.23]; paired t-test). Chance Δ is 0; the split-half reliability ceiling is ~0.35, so the effect is ~34% of the recoverable range. Positive control (localizer) fires in both areas; label-shuffle null is flat. Sub-07 excluded (motion confound); direction unchanged with them kept. **Candidate reading:** steeper adaptation in V4 — but the CI's lower bound is near zero and this is exploratory; the call is yours. (commit a1b2c3d, dataset ds00X)."

## Checklist

- [ ] Question stated before the number; n + estimate + uncertainty kind + reference present.
- [ ] Absolute and normalized views where one hides the other; caveats quantified, not deleted.
- [ ] Nulls named; provenance stamped; regime-matched.
- [ ] Framed as candidate reading(s); expectation-before-result; ends on the fork.
