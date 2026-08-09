# Behavioral evals for the conventions

Each JSON file is one scenario testing a load-bearing behavior the conventions
exist to produce. Run them when the conventions change (especially CORE.md or a
skill), and after deploying to a new Claude model.

## How to run

1. Create a scratch project and deploy the conventions into it
   (`lab-conventions/deploy.sh`), plus any tiny synthetic data the scenario needs.
2. From the scratch project root, run the scenario's `query` non-interactively:

   ```bash
   claude -p "<query from the JSON>"
   ```

3. Judge the transcript against `expected_behavior` (each item pass/fail) and
   check no `failure_modes` occurred. A scenario passes when every expected
   behavior is present.

Judge manually, or pipe the transcript to a fresh Claude with the rubric:
"Here is a transcript and a rubric (expected_behavior / failure_modes). For each
rubric item, quote the evidence and give pass/fail."

## The scenarios

| # | Behavior | Guards |
|---|---|---|
| 01 | Stops at the exclusion fork, shows raw data first | fork protocol, principle 2–3 |
| 02 | Labels exploratory vs confirmatory; refuses HARKing | labeling gates |
| 03 | Provisional language; no verdict verbs; alternatives named | language gates |
| 04 | Reporting unit fires on any stated result | reporting-results skill |
| 05 | Controls + sweep + regime demanded for a headline claim | checking-robustness skill |

Baseline discipline: when editing conventions, run the affected scenarios before
and after — if behavior didn't change, the edit didn't work (Anthropic's
evaluation-first skill-authoring guidance).
