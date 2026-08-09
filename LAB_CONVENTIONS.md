# Lab Conventions — index

How this lab does science, delivered the way an LLM agent actually consumes
instructions: a small **always-on core**, **skills** that fire at the moment of
relevance, **path-scoped rules**, **reference docs** read on demand, and
**deterministic enforcement** for the rules that must never break. Design
rationale and prior art: `REFERENCES.md`.

> **How we do science.** Solid, not speedy: inferential robustness, no premature
> conclusions, data inspected from many angles, the user adjudicating every fork,
> every result interpretation-ready months later. The full statement lives in
> `CORE.md` — the one file that is always loaded.

## Components

| Layer | Where | Loads |
|---|---|---|
| **Core** | `CORE.md` | always (imported by project `CLAUDE.md`) |
| **Skills** | `skills/` → project `.claude/skills/` | when their trigger fires |
| `checking-robustness` | | headline claims: regime, multiverse, controls, sensitivity, blinding |
| `reporting-results` | | any stated result: the 9-item reporting unit |
| `interpretation-dashboards` | | headline figures & results notebooks |
| `logging-decisions` | | analytic decisions → append-only log |
| `persisting-data` | | saving derived data: formats, save-vs-recompute |
| `scientific-figures` | | publication-quality panel craft |
| `bootstrapping-project` | | `/bootstrapping-project` — deploy the harness |
| **Rules** | `rules/` → project `.claude/rules/lab/` | when matching paths are touched |
| `notebooks.md` | | `notebooks/**` — marimo, thin cells, look-first |
| `testing.md` | | `tests/**` — pytest, hypothesis, control tests |
| `pipelines.md` | | `workflow/**` — Snakemake, containers, DataLad |
| **Reference** | `reference/` | read the one you need |
| | | `environments` `packaging` `code-quality` `project-layout` `commands` `when-to-deviate` `release` |
| **Enforcement** | `templates/settings.json` + `templates/hooks/` | deterministic: deny + PreToolUse hook |
| **Evals** | `evals/` | run when conventions change |
| **Deploy** | `deploy.sh` | one command, idempotent, `--check` doctor |

## Where the old numbered files went (pre-v3 → v3)

| Old | New home |
|---|---|
| `00-principles.md`, `01-doing-science-with-claude.md` | `CORE.md` (distilled) |
| `02-inferential-robustness.md` | `skills/checking-robustness/` |
| `03-analysis-log.md` | `skills/logging-decisions/` |
| `04-reporting.md` | `skills/reporting-results/` |
| `05-dashboards.md` | `skills/interpretation-dashboards/` |
| `06-environments.md` `07-packaging.md` `08-code-quality.md` | `reference/` (same names) |
| `09-testing.md` `10-notebooks.md` `11-pipelines.md` | `rules/` (path-scoped) |
| `12-project-layout.md` `13-commands.md` | `reference/` |
| `14-data-formats.md` `15-storage-budget.md` | `skills/persisting-data/` |
| `16-when-to-deviate.md` `17-release.md` | `reference/` |

## Versioning

Tagged spec, as before. This re-architecture is a **major** bump: projects pinned
to v2 tags keep the numbered files; new deployments get this layout via
`deploy.sh`. Never track `main` from a project.
