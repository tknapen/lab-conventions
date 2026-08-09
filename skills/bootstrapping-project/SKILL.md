---
name: bootstrapping-project
description: Sets up a new or existing project with the lab conventions harness - runs deploy.sh, then interviews the user to fill in the project CLAUDE.md. Also migrates projects from the pre-v3 numbered-file layout. Invoke with /bootstrapping-project when the user asks to set up a project with lab conventions, deploy the harness, start a new lab project, or migrate/update a project to the new conventions layout.
disable-model-invocation: true
---

# Bootstrapping a project

1. **Vendor** if not present: `git submodule add <lab-conventions remote> lab-conventions && git submodule update --init`. Pin to the latest tag (`cd lab-conventions && git checkout <tag>`).
2. **Deploy:** run `./lab-conventions/deploy.sh` from the project root. It is idempotent: scaffolds the canonical tree, copies missing templates (justfile, pyproject, gitignore, pre-commit, CLAUDE.md), wires skills/rules into `.claude/`, merges settings (additive), and runs the doctor. Fix any FAILs it reports (`--copy` on filesystems without symlinks).
3. **Interview the user** (use `AskUserQuestion`) for the placeholders in the generated `CLAUDE.md`:
   - project name + one-sentence description; what the project does (question, data, model);
   - **inference regime** — A (low-n/high-trial) or B (population-level); delete the other from CLAUDE.md;
   - `data/raw/` storage path (create the symlink; never copy raw data in);
   - anything for "Top of mind".
4. **Fill in `CLAUDE.md`**, replace the `<placeholders>`, and delete unused template comments.
5. **Finish:** run `just sync && just hooks`, then `./lab-conventions/deploy.sh --check` once more; tell the user to run `/context` in their next session to confirm CORE.md loads.

## Migrating a v2 project (pre-v3 numbered layout)

When the project already has a `CLAUDE.md` written against the old numbered files (`lab-conventions/00-…17-…`):

1. Run `./lab-conventions/deploy.sh` — its doctor flags exactly what is stale (missing CORE import, numbered references, superseded `Write()` deny entries).
2. **Splice `CLAUDE.md` with judgment, not wholesale:** replace the old "Lab conventions" follow-block (the numbered list and the "follow every file it indexes" instruction) with the single import line `@lab-conventions/CORE.md` plus the do-not-read-up-front note (see `templates/CLAUDE.md`). **Preserve every project-specific section** (description, data, overrides, top-of-mind). Add the inference-regime declaration if absent — ask the user which regime (A low-n/high-trial or B population-level).
3. Fix any other stale numbered references in project docs using the old→new map in `lab-conventions/LAB_CONVENTIONS.md`.
4. Remove superseded `Write(./…)` deny entries from `.claude/settings.json` if flagged.
5. **Review auto memory:** open the project's memory (`/memory`) and correct or delete entries referencing the old numbered files.
6. Re-run `./lab-conventions/deploy.sh --check` until green; have the user confirm with `/context` in a fresh session; remind them to commit the submodule pin + spliced files.
