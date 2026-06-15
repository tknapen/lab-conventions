# Skills

Vendored Claude skills the lab follows. Each skill lives in its own folder with a
`SKILL.md` (frontmatter `name` + `description`) and an optional `references/` directory,
mirroring the Claude Code skill layout so a project can symlink or copy them into its
`.claude/skills/`.

## scientific-figures

Publication-quality scientific-figure house style (seaborn on top of matplotlib).

**Adapted from** Gilles de Hollander's skill:
<https://github.com/Gilles86/gilles-claude-skills/blob/main/skills/scientific-figures/SKILL.md>

First-version adaptation for this lab:

- The **"Posteriors from PyMC / bauer"** section and its linked
  `references/bayesian_posteriors.md` are **omitted**.
- The linked `references/figure_types.md` (per-panel-type specializations) **is included**.
- Everything else follows the upstream skill verbatim.
