#!/usr/bin/env bash
# deploy.sh — deploy the lab conventions as a project's harness. Idempotent.
#
# Usage (from the project root, after vendoring lab-conventions/ as a submodule):
#   ./lab-conventions/deploy.sh            # scaffold + wire + doctor
#   ./lab-conventions/deploy.sh --check    # doctor only, change nothing
#   ./lab-conventions/deploy.sh --copy     # copy instead of symlink (e.g. Windows)
set -euo pipefail

MODE="deploy"; LINK="symlink"
for arg in "$@"; do
  case "$arg" in
    --check) MODE="check" ;;
    --copy)  LINK="copy" ;;
    *) echo "unknown flag: $arg (use --check / --copy)"; exit 2 ;;
  esac
done

# Locate: this script lives at <project>/lab-conventions/deploy.sh
CONV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_DIR="$(dirname "$CONV_DIR")"
CONV_NAME="$(basename "$CONV_DIR")"
cd "$PROJ_DIR"

SKILLS=(checking-robustness reporting-results interpretation-dashboards logging-decisions persisting-data scientific-figures bootstrapping-project)
PASS=(); FAIL=(); SKIPPED=(); DONE=()

note()  { DONE+=("$1"); }
skip()  { SKIPPED+=("$1"); }

link_or_copy() { # $1 target(rel to link location) $2 linkpath
  if [ "$LINK" = "symlink" ]; then ln -s "$1" "$2"; else cp -r "$(dirname "$2")/$1" "$2"; fi
}

if [ "$MODE" = "deploy" ]; then
  # 1) Scaffold the canonical tree (only what's missing)
  for d in src tests notebooks workflow scripts data/raw data/processed data/generated results/figures results/tables logs docs/notes .claude/skills .claude/rules .claude/hooks; do
    if [ -d "$d" ]; then skip "dir $d"; else mkdir -p "$d"; note "created $d/"; fi
  done

  # 2) Templates for missing files only — never overwrite
  declare -A TPL=(
    [justfile]="justfile" [pyproject.toml]="pyproject.toml"
    [.gitignore]="gitignore" [.pre-commit-config.yaml]="pre-commit-config.yaml"
    [CLAUDE.md]="CLAUDE.md"
  )
  for dst in "${!TPL[@]}"; do
    if [ -e "$dst" ]; then skip "file $dst"; else cp "$CONV_DIR/templates/${TPL[$dst]}" "$dst"; note "created $dst"; fi
  done

  # 3) Wire skills and rules (relative symlinks survive clones on the same OS)
  for s in "${SKILLS[@]}"; do
    dst=".claude/skills/$s"
    if [ -e "$dst" ] || [ -L "$dst" ]; then skip "skill $s"
    else link_or_copy "../../$CONV_NAME/skills/$s" "$dst"; note "wired skill $s"; fi
  done
  if [ -e ".claude/rules/lab" ] || [ -L ".claude/rules/lab" ]; then skip "rules dir"
  else link_or_copy "../../$CONV_NAME/rules" ".claude/rules/lab"; note "wired rules"; fi

  # 4) Settings: copy template if absent; else additive JSON merge (never removes user entries)
  if [ ! -e ".claude/settings.json" ]; then
    cp "$CONV_DIR/templates/settings.json" ".claude/settings.json"; note "created .claude/settings.json"
  else
    merge_result=$(python3 - "$CONV_DIR/templates/settings.json" ".claude/settings.json" <<'PYEOF'
import json, sys
tpl_path, cur_path = sys.argv[1], sys.argv[2]
tpl, cur = json.load(open(tpl_path)), json.load(open(cur_path))
changed = False
perms = cur.setdefault("permissions", {})
for key in ("allow", "deny"):
    have = perms.setdefault(key, [])
    for entry in tpl.get("permissions", {}).get(key, []):
        if entry not in have:
            have.append(entry); changed = True
hooks = cur.setdefault("hooks", {})
# Migrate cwd-fragile registrations of the lab hook IN PLACE: a relative
# script path write-locks every matched tool call whenever the session's
# shell leaves the project root (python3 exits 2 before the script's
# fail-open guard can run, and exit 2 is a blocking deny). Rewriting —
# rather than appending the anchored entry beside the broken, still-blocking
# one — is what lets a re-deploy heal a pre-v3.0.1 project.
anchored = {}
for event, matchers in tpl.get("hooks", {}).items():
    for m in matchers:
        for h in m.get("hooks", []):
            if "block_protected_writes" in h.get("command", ""):
                anchored[event] = h["command"]
for event, matchers in hooks.items():
    for m in matchers:
        for h in m.get("hooks", []):
            cmd = h.get("command", "")
            if ("block_protected_writes" in cmd
                    and "$CLAUDE_PROJECT_DIR" not in cmd
                    and anchored.get(event)):
                h["command"] = anchored[event]; changed = True
for event, matchers in tpl.get("hooks", {}).items():
    have = hooks.setdefault(event, [])
    for m in matchers:
        if m not in have:
            have.append(m); changed = True
if changed:
    json.dump(cur, open(cur_path, "w"), indent=2); print("merged")
else:
    print("unchanged")
PYEOF
)
    if [ "$merge_result" = "merged" ]; then note "settings merged (additive)"; else skip "settings (up to date)"; fi
  fi
fi

# 5) Doctor — always runs
WARN=(); MIGRATION=0
check() { # $1 label $2 command
  if eval "$2" >/dev/null 2>&1; then PASS+=("$1"); else FAIL+=("$1"); fi
}
check "conventions vendored"        "[ -f '$CONV_DIR/CORE.md' ]"

# CLAUDE.md must import the always-on core (v2 projects point at the old numbered files instead)
if grep -q "@$CONV_NAME/CORE.md" CLAUDE.md 2>/dev/null; then
  PASS+=("CLAUDE.md imports CORE.md")
else
  FAIL+=("CLAUDE.md does not import CORE.md — replace the old 'Lab conventions' follow-block with the single line '@$CONV_NAME/CORE.md' (keep all project-specific content), or run /bootstrapping-project in a Claude session to have the splice done for you")
  MIGRATION=1
fi
stale=$(grep -oE "$CONV_NAME/[0-9]{2}-[a-z-]+\.md" CLAUDE.md 2>/dev/null | sort -u | tr '\n' ' ' || true)
if [ -n "$stale" ]; then
  WARN+=("CLAUDE.md references the pre-v3 numbered layout: ${stale}— these files no longer exist; old→new map in $CONV_NAME/LAB_CONVENTIONS.md")
  MIGRATION=1
fi
if grep -qE '"Write\(\./(data/raw|uv\.lock|pixi\.lock)' .claude/settings.json 2>/dev/null; then
  WARN+=("settings.json carries superseded Write() deny entries from the v2 template — remove them; Edit() rules cover all file-editing tools")
  MIGRATION=1
fi

check "canonical tree present"      "[ -d src ] && [ -d data/raw ] && [ -d notebooks ]"
for s in "${SKILLS[@]}"; do
  check "skill $s resolves"         "[ -f '.claude/skills/$s/SKILL.md' ]"
done
check "rules resolve"               "[ -f .claude/rules/lab/notebooks.md ]"
check "settings deny data/raw"      "grep -q 'data/raw' .claude/settings.json"
check "settings hook wired"         "grep -q 'block_protected_writes' .claude/settings.json"
check "hook script runs"            "echo '{}' | python3 '$CONV_DIR/templates/hooks/block_protected_writes.py'"

# The hook must be registered by an ANCHORED path: a relative path write-locks
# every matched tool call whenever a session's shell leaves the project root
# (the interpreter exits 2 before the script's fail-open guard can run).
# Execute the REGISTERED command string from a subdirectory, as Claude Code
# would — the check above only proves the script itself is healthy.
reg_cmd=$(python3 - <<'PYEOF' 2>/dev/null || true
import json
try:
    cfg = json.load(open(".claude/settings.json"))
except Exception:
    raise SystemExit
for ms in cfg.get("hooks", {}).values():
    for m in ms:
        for h in m.get("hooks", []):
            if h.get("type") == "command" and "block_protected_writes" in h.get("command", ""):
                print(h["command"]); raise SystemExit
PYEOF
)
if [ -n "$reg_cmd" ]; then
  if (cd "$CONV_DIR" && echo '{}' | CLAUDE_PROJECT_DIR="$PROJ_DIR" bash -c "$reg_cmd") >/dev/null 2>&1; then
    PASS+=("registered hook command runs from a subdirectory")
  else
    FAIL+=("registered hook command fails when cwd is not the project root — a cwd-fragile registration blocks ALL matched tool calls; anchor it: python3 \"\$CLAUDE_PROJECT_DIR/$CONV_NAME/templates/hooks/block_protected_writes.py\"")
  fi
fi

check "justfile present"            "[ -f justfile ]"
if git -C "$CONV_DIR" describe --tags --exact-match >/dev/null 2>&1; then
  PASS+=("submodule pinned to a tag")
else
  WARN+=("submodule not pinned to a tag (pin with: cd $CONV_NAME && git checkout <tag>)")
fi

# Report
if [ "$MODE" = "deploy" ]; then
  [ ${#DONE[@]} -gt 0 ]    && printf 'did:     %s\n' "${DONE[@]}"
  [ ${#SKIPPED[@]} -gt 0 ] && echo "skipped: ${#SKIPPED[@]} already-present items"
fi
printf 'PASS  %s\n' "${PASS[@]}"
[ ${#WARN[@]} -gt 0 ] && printf 'WARN  %s\n' "${WARN[@]}"
[ "$MIGRATION" = 1 ] && echo "note: migration findings above — after fixing, also review this project's auto memory (/memory in a Claude session) for stale numbered-file references."
if [ ${#FAIL[@]} -gt 0 ]; then
  printf 'FAIL  %s\n' "${FAIL[@]}"
  echo "→ fix the FAILs above, then re-run ./$CONV_NAME/deploy.sh --check"
  exit 1
fi
echo "All checks passed. In a Claude session, run /context to confirm CORE.md is loaded."
