# lab-conventions

How this lab does science — **solid, not speedy** — packaged the way an LLM agent
actually consumes instructions: a small always-on core (`CORE.md`), skills that
fire at the moment of relevance, path-scoped rules, on-demand reference docs, and
deterministic enforcement (deny rules + hooks) for the gates that must never
break. `LAB_CONVENTIONS.md` is the index; `REFERENCES.md` holds the prior art.

## Deploy into a project (one command)

```bash
cd myproject
git submodule add git@github.com:<org>/lab-conventions.git lab-conventions
./lab-conventions/deploy.sh
```

`deploy.sh` is **idempotent** — safe to re-run any time. It:

1. scaffolds the canonical project tree (only missing pieces);
2. copies starter files (`CLAUDE.md`, `justfile`, `pyproject.toml`, `.gitignore`, pre-commit) for missing files only;
3. wires the agent harness: symlinks skills into `.claude/skills/`, rules into `.claude/rules/lab`, and creates or **additively merges** `.claude/settings.json` (deny rules + the protected-writes hook);
4. runs the **doctor** (`--check` runs it alone) and prints a pass/fail table.

Flags: `--check` (verify only) · `--copy` (no symlinks, e.g. Windows without dev mode).

Conversational route: in a Claude session, `/bootstrapping-project` runs the same
deploy and then interviews you to fill in the project `CLAUDE.md` (description,
inference regime, data location).

Then fill in the `<placeholders>` in `CLAUDE.md`, pin the submodule to a tag, and
run `/context` in your next session to confirm `CORE.md` is loaded.

## Updating a project

```bash
cd myproject/lab-conventions && git fetch && git checkout <new-tag>
cd .. && ./lab-conventions/deploy.sh    # re-wires anything new; settings merge is additive
git add lab-conventions && git commit -m "Pin lab-conventions to <new-tag>"
```

## Design (why this shape)

Per Anthropic's context-engineering and skill-authoring guidance: always-on
instructions must stay small (bloated memory files get ignored); task guidance
loads on trigger via skill descriptions; file-type guidance loads per path;
zero-exception rules are hooks, not prose. `evals/` contains behavioral scenarios
— run them when the conventions change to verify the change actually moves
behavior.

## Contributing

By PR: touch the affected component (core / one skill / one rule / reference),
run the affected `evals/` scenarios before and after, update the
`LAB_CONVENTIONS.md` map if a component moves, and bump the version tag
(breaking = major). If you keep overriding a convention in project CLAUDE.md
files, the convention is wrong — fix it here.
