# 03 — Code quality

## Lint and format: Ruff, no exceptions

Ruff is the only linter and the only formatter. Black, flake8, isort, pyupgrade, pydocstyle are all subsumed; do not install them.

```toml
[tool.ruff]
line-length = 100
target-version = "py312"
extend-exclude = ["data/", "results/"]

[tool.ruff.lint]
extend-select = [
  "E", "F", "W",   # pycodestyle + pyflakes
  "I",             # isort
  "UP",            # pyupgrade
  "B",             # bugbear
  "C4",            # comprehensions
  "SIM",           # simplify
  "RET",           # returns
  "PTH",           # pathlib (no os.path)
  "TC",            # type-checking blocks
  "NPY",           # NumPy-specific (catches deprecated APIs, legacy np.random)
  "PD",            # pandas-vet (catches inplace=True etc.)
  "PERF",          # perf-lint
  "FURB",          # idioms
  "ICN",           # import conventions (np, pd, pl, plt aliases)
  "RUF",
]
ignore = [
  "E501",          # line length: formatter handles
  "PD901",         # `df` is fine
]

[tool.ruff.lint.per-file-ignores]
"tests/*"     = ["S101"]                # assert is fine in tests
"notebooks/*" = ["E402", "F401", "B018"] # top-of-cell imports, marimo display
```

*Why:* NPY catches `np.random.choice` (you should use a `Generator`); PD catches `inplace=True`; ICN enforces the canonical aliases everyone expects to see. Ruff is fast enough to run on every save.

## Type checking: layered

Three layers, used together:

1. **Static checker** (catches type errors before runtime). Use **`pyrefly`** for libraries (high spec-conformance matters), **`ty`** for application/analysis code (gradual guarantee — adding annotations never adds new errors). Both are Rust-based and orders of magnitude faster than mypy.

2. **Runtime shape/dtype checks** with `jaxtyping` + `beartype`. This catches the bugs that actually wreck fMRI work: swapped axes, wrong TR length, broadcasting mistakes. Neither static checker understands tensor shapes.

   ```python
   from jaxtyping import Float, jaxtyped
   from beartype import beartype
   from numpy import ndarray as A

   @jaxtyped(typechecker=beartype)
   def glm(
       design: Float[A, "time regressors"],
       bold:   Float[A, "voxels time"],
   ) -> Float[A, "voxels regressors"]:
       ...
   ```

3. **Pydantic v2** for any structured config or input data that crosses a boundary (file, network, user). Use `pydantic-settings` for env-var / `.env` config.

*Why:* layered defenses. Static types catch the easy mistakes for free; shape annotations catch the science-killing mistakes at the door; pydantic catches the "JSON we trusted was wrong" mistakes at the boundary.

## Hard rules

- Every function in `src/` has type annotations on its public signature. Internal helpers may skip.
- Functions taking or returning arrays have **shape annotations** via `jaxtyping`, not just `np.ndarray`.
- No bare `except:`. No `except Exception:` without re-raising or logging the traceback.
- No `from foo import *` outside `__init__.py`.
- No `os.path` — use `pathlib.Path` (enforced by ruff PTH).
- Imports follow the ICN aliases: `import numpy as np`, `import pandas as pd`, `import polars as pl`, `import matplotlib.pyplot as plt`.

## Pre-commit

`.pre-commit-config.yaml` is committed to every project. Required hooks:

- `ruff-check --fix` and `ruff-format`
- `uv-lock` (fails if `pyproject.toml` drifts from `uv.lock`)
- `check-yaml`, `check-toml`, `check-added-large-files`, `trailing-whitespace`, `end-of-file-fixer`
- `codespell`
- `pyrefly check` (or `ty check`) as a local hook
- `marimo check --strict notebooks/` as a local hook (if the project has marimo notebooks)
- `nbstripout` only if any `.ipynb` files survive in the project

*Why:* a broken pre-commit means a broken CI, by design. Catch the failure on the developer's machine, not in a 10-minute Actions run.

## Gotchas

- `from __future__ import annotations` stringifies annotations; this breaks `jaxtyping` runtime checking. Don't use it in files that decorate functions with `@jaxtyped`.
- Pyrefly 1.0's minor versions can introduce new errors; pin in CI and use `pyrefly suppress` on upgrade.
- `ty` is still 0.0.x beta — fine for analysis code, not yet recommended as the sole gate for libraries.
