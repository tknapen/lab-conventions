# lab-conventions

Authoritative reference for how code in this lab is written, built, tested, and run. Read `LAB_CONVENTIONS.md` for the index; read every numbered file before doing non-trivial work in a project that imports this.

## Vendoring into a project

Pick one. Submodule is the most explicit; subtree is the most hands-off; symlink is the fastest for solo work.

### Option A: git submodule (recommended for shared projects)

```bash
cd myproject
git submodule add git@github.com:<org>/lab-conventions.git lab-conventions
git submodule update --init --recursive
```

To pin to a specific version:

```bash
cd lab-conventions
git checkout v1.0
cd ..
git add lab-conventions
git commit -m "Pin lab-conventions to v1.0"
```

### Option B: git subtree (recommended for projects that never want to deal with submodules)

```bash
cd myproject
git subtree add --prefix=lab-conventions \
    git@github.com:<org>/lab-conventions.git v1.0 --squash
```

To update later:

```bash
git subtree pull --prefix=lab-conventions \
    git@github.com:<org>/lab-conventions.git v1.1 --squash
```

### Option C: symlink (solo work only)

```bash
cd myproject
ln -s ~/code/lab-conventions lab-conventions
```

Add `lab-conventions` to `.gitignore` if symlinked; you don't want a relative path that breaks for collaborators.

## After vendoring

In the project's `CLAUDE.md`, add:

```markdown
## Lab conventions
Follow `lab-conventions/LAB_CONVENTIONS.md` and every file it indexes.
```

See `EXAMPLE_PROJECT_CLAUDE.md` for a complete template.

## Versioning

Tag this directory like a package: `v1.0`, `v1.1`, `v2.0`. Breaking changes (a rule reversal, a new mandatory tool) get a major bump. Additive changes (a new optional convention, clarifications) get a minor bump.

Projects pin to a tag. Don't track `main` from inside a project — it makes "what was the convention when this was written" unanswerable.

## Contributing

A new convention enters this directory by PR. The PR must:

1. Touch only the numbered files relevant to the change.
2. Explain *why* in the rationale section (every rule has a `*Why:*` line).
3. Update `09-when-to-deviate.md` if the change introduces a new exception class.
4. Bump the version tag.

If you find yourself wanting to override a convention in a project's `CLAUDE.md` more than once, the convention is wrong — fix it here, don't accumulate overrides in projects.
