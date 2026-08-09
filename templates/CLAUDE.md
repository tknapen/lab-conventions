# Project: <PROJECT NAME>

<One-sentence description of what this project is.>

## Lab conventions

@lab-conventions/CORE.md

The core above is always loaded. Do **not** read the rest of `lab-conventions/` up
front — skills fire when relevant, `.claude/rules/` load per path, and
`lab-conventions/reference/` is read on demand (component map in CORE.md).

## Inference regime (declare one — see checking-robustness skill)

<!-- Pick and delete the other: -->
- **Regime A — low-n / high-trial** (psychophysics/NHP): within-subject inference, every subject shown, no MC correction over descriptive sweeps.
- **Regime B — population-level**: group inference primary, MC control over the tested family.

## What this project does

<Two or three sentences: the question, the data, the model.>

## Data

- `data/raw/` is a symlink to `<LAB STORAGE PATH>`. Read-only (enforced).
- <Subjects, acquisition details.>

## Common tasks

`just sync` (env from lockfiles) · `just check` (all gates) · `just pipeline` (Snakemake DAG) · `just log <analysis>` (decision-log entry)

## Project-specific overrides

<!-- Each override must name the lab rule it overrides and why. Delete if none. -->

None.

## Top of mind

<!-- Keep fresh; delete stale items. Tag active analyses exploratory/confirmatory. -->

- <Current analysis; status: exploratory. Decision log: docs/notes/<analysis>.log.md>
