# 04 — Testing

## Configuration

```toml
[tool.pytest.ini_options]
minversion = "8"
testpaths = ["tests"]
addopts = [
  "-ra",
  "--strict-markers",
  "--strict-config",
  "-n=auto",            # pytest-xdist parallel
  "--dist=loadscope",
]
filterwarnings = [
  "error",
  "ignore::DeprecationWarning:pybids.*",
]
```

*Why:* `--strict-markers` catches typo'd `@pytest.mark.slow`; `filterwarnings = error` turns DeprecationWarnings into failures so the codebase doesn't rot silently; `-n=auto` is free parallelism.

## What gets tested

- **Everything in `src/`**: yes. Aim for ≥80% line coverage on library code.
- **One-off analysis scripts**: no. Don't chase coverage on `figure_3.py`.
- **Pipelines**: end-to-end with a tiny synthetic dataset, run in CI.
- **Notebooks**: not tested as notebooks. Test the functions they call (which live in `src/`).

*Why:* the rule "reusable code lives in `src/`" means the things worth testing are concentrated there. Notebooks are orchestration; they fail loudly when their inputs change.

## Patterns

### Property-based tests with `hypothesis`

For numerical invariants. Especially valuable for:

- Z-scoring produces mean-0, var-1 for any non-degenerate input.
- GLM betas with no signal recover ≈ 0 for any seed.
- Round-trip serialization (write → read → check equality).

```python
from hypothesis import given, strategies as st
from hypothesis.extra.numpy import arrays
import numpy as np

@given(arrays(np.float64, st.integers(10, 1000),
              elements=st.floats(-1e3, 1e3, allow_nan=False)))
def test_zscore_has_unit_variance(x):
    if x.std() < 1e-9:
        return  # degenerate
    z = (x - x.mean()) / x.std()
    np.testing.assert_allclose(z.std(), 1.0, rtol=1e-9)
```

### Snapshot / regression tests with `pytest-regressions`

For array outputs whose exact values matter but are tedious to hand-write. `ndarrays_regression.check(my_output)` writes a `.npz` on first run; subsequent runs diff against it within tolerance.

*Why:* a snapshot is the right shape for "this fitting routine should keep producing the same answer on this fixture dataset, to within 1e-6". Tighter than visual inspection, looser than hand-coded asserts.

### Shape-aware tests

When testing functions decorated with `@jaxtyped`, pass deliberately wrong shapes and assert that `beartype.BeartypeCallHintViolation` is raised. This validates the annotations are doing their job.

### Synthetic-data fixtures

Tests should generate synthetic NIfTIs, behavioral CSVs, and event files in a `session`-scoped fixture rather than committing real volumes. Real volumes are slow and balloon the repo.

```python
@pytest.fixture(scope="session")
def synthetic_bids(tmp_path_factory):
    root = tmp_path_factory.mktemp("bids")
    # generate dataset_description.json, sub-01 anat + func, events.tsv, ...
    return root
```

### Numerical tolerance

Use `numpy.testing.assert_allclose(actual, expected, rtol=1e-6)` for floats. Never `==` on arrays.

## Hard rules

- No test reaches outside the repo (no network, no `/scratch`, no shared filesystems). Mark anything that must with `@pytest.mark.integration` and exclude from the default run.
- Tests are deterministic. Seed every RNG explicitly; pass `np.random.default_rng(0)` rather than relying on global state.
- No test depends on another test's order. `pytest-xdist` will randomize execution.
- Slow tests (>1 s) are marked `@pytest.mark.slow` and excluded from the default `pytest` run (`-m "not slow"`); they run in CI on a separate job.

## Gotchas

- `filterwarnings = error` will catch deprecation warnings from upstream packages — add narrow ignores for packages you don't control, never `ignore::DeprecationWarning` globally.
- `pytest-xdist` with `--dist=loadscope` keeps tests in the same module on the same worker; required if you have a module-scoped fixture that's expensive to build.
- `hypothesis` example databases live in `.hypothesis/`; gitignore that directory.
