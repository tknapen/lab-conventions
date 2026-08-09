---
name: bootstrapping-project
description: Sets up a new or existing project with the lab conventions harness - runs deploy.sh, then interviews the user to fill in the project CLAUDE.md. Invoke with /bootstrapping-project when the user asks to set up a project with lab conventions, deploy the harness, or start a new lab project.
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
