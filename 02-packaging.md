# 02 — Packaging

Every project — even a one-shot analysis — is structured as an installable Python package. This is non-negotiable.

*Why:* installable means `from myproject.io import load_subject` works from a notebook, a test, or a script without `sys.path` games. Editable installs (`uv sync` does this automatically for the workspace) mean changes to `src/` are picked up live.

## The canonical `pyproject.toml` skeleton

```toml
[project]
name = "myproject"
description = "One-line description."
readme = "README.md"
requires-python = ">=3.12"
license = "MIT"
authors = [{ name = "Lab Member", email = "you@example.edu" }]
dynamic = ["version"]
dependencies = [
  # runtime deps only
  "numpy>=2.1",
  "scipy>=1.14",
  "nibabel>=5.3",
  "pybids>=0.17",
]

[dependency-groups]
test = ["pytest>=8", "pytest-xdist", "hypothesis", "syrupy", "beartype"]
lint = ["ruff>=0.8"]
typecheck = ["pyrefly>=1.0"]
notebook = ["marimo>=0.10"]
dev = [
  { include-group = "test" },
  { include-group = "lint" },
  { include-group = "typecheck" },
  { include-group = "notebook" },
  "ipython",
]

[build-system]
requires = ["hatchling", "uv-dynamic-versioning"]
build-backend = "hatchling.build"

[tool.hatch.version]
source = "uv-dynamic-versioning"

[tool.uv-dynamic-versioning]
pattern = "default-unprefixed"

# Tool sections live below: see 03-code-quality.md for ruff/pyrefly,
# 04-testing.md for pytest, 01-environments.md for [tool.pixi].
```

## Hard rules

- `name` is `kebab-case`; the Python import name (`src/<name>/`) is `snake_case`.
- `requires-python` is set to the actual minimum the code needs, not "whatever I have locally".
- `version` is **dynamic**, derived from git tags. Never hardcode versions in `pyproject.toml` or `__init__.py`.
- Runtime dependencies in `[project.dependencies]` are minimal and unpinned (`numpy>=2.1`, not `numpy==2.1.3`). Pin in the lockfile.
- Development tooling goes in `[dependency-groups]`, never in `[project.dependencies]`. Users installing the package don't need ruff.

*Why:* dynamic versioning means `v0.3.0` tag → wheel filename → published version are all coupled to one source. Unpinned runtime deps + pinned lockfile is the standard reproducibility/compatibility split.

## Build backends — pick one

| Project type | Backend |
|---|---|
| Pure Python | **hatchling** + `uv-dynamic-versioning` |
| Rust extensions | **maturin** |
| C/C++/Fortran extensions | **scikit-build-core** |

Do not use `setuptools` for new projects. Do not use `uv_build` until `uv-dynamic-versioning` supports it.

## Versioning

- Tag releases as `v0.3.0` (with the `v` prefix).
- `uv-dynamic-versioning` reads the tag and produces `0.3.0` for the wheel.
- Untagged commits get a dev version like `0.3.0.post1.dev0+gabc1234`.

*Why:* one source of truth (the tag), automatically propagated to install metadata, wheel filename, and `mypackage.__version__`.

## Editable installs and workspaces

- A single project: `uv sync` installs the package as editable automatically.
- A monorepo with multiple sibling packages: use a **uv workspace** with `[tool.uv.workspace] members = ["packages/*"]` and `[tool.uv.sources] sibling-pkg = { workspace = true }`. One `uv.lock` covers everything; one `uv sync` installs all members editable.

*Why:* workspaces are the right shape for a lab with several related sibling packages (one for IO, one for GLM, one for visualization). No `pip install -e` games.

## Gotchas

- Adding a dependency: always `uv add foo` (or `pixi add foo` for conda deps), never edit `pyproject.toml` and forget to re-lock.
- Adding a dev tool: `uv add --group dev foo`, not `uv add foo`.
- Removing a dependency: `uv remove foo` — manual edits leave the lockfile inconsistent.
- The `src/` layout (`src/myproject/__init__.py`, not `myproject/__init__.py`) is mandatory. It prevents accidental imports of the source tree instead of the installed package during testing.
