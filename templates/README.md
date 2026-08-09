# Templates

Copied into a project by `../deploy.sh` **only when the target file is missing** —
never overwritten. `settings.json` is the exception: when a project already has
one, deploy.sh merges the allow/deny entries and hooks block *additively* (user
entries are never removed).

| Template | Becomes | Canonical documentation |
|---|---|---|
| `CLAUDE.md` | `./CLAUDE.md` | imports `@lab-conventions/CORE.md`; fill the placeholders |
| `justfile` | `./justfile` | `reference/commands.md` (extracted from its code block) |
| `pyproject.toml` | `./pyproject.toml` | `reference/packaging.md` |
| `gitignore` | `./.gitignore` | `reference/project-layout.md` |
| `pre-commit-config.yaml` | `./.pre-commit-config.yaml` | `reference/code-quality.md` |
| `settings.json` | `./.claude/settings.json` | deny rules + PreToolUse hook wiring |
| `hooks/block_protected_writes.py` | referenced in place (vendored path) | deterministic deny: `data/raw/**`, lockfiles |

Manual fallback (what deploy.sh automates): create the tree from
`reference/project-layout.md`, copy the files above, symlink each
`skills/<name>` into `.claude/skills/` and `rules/` → `.claude/rules/lab`.
