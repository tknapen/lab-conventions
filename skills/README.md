# Skills

The lab's agent skills. `deploy.sh` symlinks each into a project's
`.claude/skills/`; Claude loads a skill's ~100-token description at startup and
the full SKILL.md only when its trigger fires (progressive disclosure).

| Skill | Fires when |
|---|---|
| `checking-robustness` | a result is about to become a headline claim |
| `reporting-results` | any result/statistic/null is stated |
| `interpretation-dashboards` | headline figures / results notebooks are made |
| `logging-decisions` | an analytic decision or fork is resolved |
| `persisting-data` | derived data is saved / formats chosen |
| `scientific-figures` | publication-quality plotting (per-panel craft) |
| `bootstrapping-project` | `/bootstrapping-project` (manual) — deploys this harness |

`scientific-figures` is adapted from Gilles de Hollander's skill
(<https://github.com/Gilles86/gilles-claude-skills>): the PyMC/bauer posterior
section is omitted; `references/figure_types.md` is included.
