---
paths:
  - "tests/**"
---

# Testing rules

Config lives in `pyproject.toml`: `--strict-markers --strict-config -n=auto --dist=loadscope`, `filterwarnings = error` (add *narrow* per-package ignores, never a global one). Aim ≥80% line coverage on `src/`; no coverage-chasing on one-off scripts; pipelines get an end-to-end run on a tiny synthetic dataset in CI; notebooks are not tested as notebooks — test the `src/` functions they call.

## Patterns

- **Property-based (`hypothesis`)** for numerical invariants: z-score → mean 0/var 1 for any non-degenerate input; no-signal GLM betas ≈ 0 for any seed; round-trip serialization.
- **Snapshot (`pytest-regressions`)** for "this fit keeps producing the same answer on this fixture, to 1e-6".
- **Shape-aware:** pass deliberately wrong shapes to `@jaxtyped` functions and assert `BeartypeCallHintViolation` fires.
- **Synthetic fixtures:** generate NIfTIs/CSVs/event files in session-scoped fixtures; never commit real volumes.
- **Control tests** — required for any analysis carrying a headline claim (concept in the `checking-robustness` skill; generators shared with dashboard schematics):

```python
def test_detects_planted_effect(rng):
    data = synth_with_effect(delta=0.3, rng=rng)
    assert estimate_effect(data) == pytest.approx(0.3, abs=0.05)

def test_null_under_label_shuffle(rng):
    null = [estimate_effect(shuffle_labels(synth_null(rng), rng)) for _ in range(200)]
    assert abs(np.mean(null)) < 0.02
```

## Hard rules

- No test reaches outside the repo (network, `/scratch`, shared FS) — mark exceptions `@pytest.mark.integration`, excluded from the default run.
- Deterministic: seed every RNG explicitly (`np.random.default_rng(0)`); `assert_allclose(rtol=…)` for floats, never `==` on arrays.
- No inter-test order dependence (xdist randomizes). Tests >1 s: `@pytest.mark.slow`, excluded by default, run in a separate CI job.
- `.hypothesis/` is gitignored; `--dist=loadscope` keeps module-scoped fixtures on one worker.
