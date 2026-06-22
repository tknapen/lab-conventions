# 15 — Storage budget (what to save vs recompute)

Every derived artifact sits between two failure modes, and the convention must guard both at
once: **under-saving** (you discard something expensive that turns out to feed a spin-off, a
revision, or a reviewer's "also show X" — and now you re-pay the full cost, maybe on a pipeline
you can no longer reproduce exactly) and **over-saving** (you hoard large arrays that are cheap
to regenerate and never reread, burning shared quota and making the project illegible — *which*
file is canonical?).

The reframe that resolves most "but I might need it" anxiety:

> The question is **not** "is this scientifically useful?" (almost everything is). It is
> **"is it cheaper to keep than to regenerate, given how reproducibly I can regenerate it?"**
> If regeneration is deterministic, cheap, and the code is pinned, an artifact is *disposable —
> no matter how important* — because it is fully recoverable.

This is the BIDS / fMRIPrep stance ("derivatives are regenerable") and it is the most
load-bearing idea here. Note it is a **cost comparison, not a save/delete binary**: even reload
is not free, so the comparison is *recompute time* vs *store + reload time*. The optimal
"what to materialize" problem is provably NP-hard (Helix, arXiv 1812.05762), so we use
heuristics, not optimisation.

## The decision

Apply this to **each derived artifact at a stage boundary**:

```
Intra-stage scratch?                              → temporary (Snakemake temp() / /scratch); recompute.
Reproducibility gate — SAVE (mandatory) + recipe, regardless of cost, if ANY of:
   • regeneration is non-deterministic (random init, GPU non-determinism, un-seedable tool)
   • it is downstream of a manual / QC / interactive step
   • it depends on an external or unpinned dependency (download, mutable atlas, a service)
   • losing it would make a published figure unreproducible
Else (regenerable) — cost-ratio test:
   • recompute_secs × reuse_count  ≫  size_on_disk + reload_secs   → SAVE (float32 + compressed)
   • cheap, or rarely reused, and large                            → DROP; recompute on demand
   • borderline                                                    → SAVE to the scratch/cold tier with a TTL
ALWAYS: persist the recipe (git commit, params/config, seed, input identities) — saved or not.
```

The recipe rule is what *makes "drop and recompute" safe*: it is the enabling condition for the
whole convention, so it is unconditional.

## Hard rules

- **Reproducibility gate first.** The four triggers above force a save irrespective of the cost
  ratio. A non-deterministic or manually-curated artifact is not recoverable from code, so cost
  is moot.
- **Then the cost ratio.** Decide on **compute-seconds-saved per GB**, not two separate gut
  calls. Default thresholds (tune to the host's quota): **keep** if it takes **> ~10 min to
  regenerate** *or* is **reused ≥ 3 times**, *and* is **< ~1 GB** after float32 + compression;
  otherwise lean toward recompute. These numbers are lab defaults, not laws — state any local
  override.
- **Always write the recipe.** Every persisted product carries enough to regenerate it: the git
  commit, the params/config, the `random_state`/seed, and the identities of its inputs (paths +
  their own provenance, or content hashes). For netCDF/parquet products the format helper
  (`14-data-formats.md`) already stamps `git_commit`/`created_utc`/`creator`; **add `params`,
  `seed`, and `inputs`** as extra attributes for simple cases, or a sidecar `*.recipe.json` for
  a complex config. A dropped artifact must be reconstructable from its recipe alone.
- **float32 for voxel data.** Cast `float64` voxel maps to **float32** before storing — fMRI SNR
  makes float64 overkill (~1e-5 precision is far below measurement noise). **Keep float64** for
  affines, spatial transforms, and displacement fields, and for anything where the extra
  precision is genuinely load-bearing. Do **not** drop to int16 for voxel data (too coarse).
- **Store sufficient statistics, not raw volumes**, when they suffice: betas / contrast maps /
  covariance summaries over every resampled volume; mean±SD across seeds over every run. This is
  the statistical sibling of fMRIPrep's "keep the transforms, drop the resampled volumes".
- **Persist at stage boundaries, not every step.** Intra-stage scratch is `temp()` (Snakemake)
  or lands in `/scratch`; only the named, downstream-depended-on stage outputs are candidates
  for the curated tier.

## Tiers and lifecycle

Three tiers, mapped onto the project layout (`12-project-layout.md`):

| Tier | Where | Lifetime | For |
|---|---|---|---|
| **Transient** | `/scratch/$USER/…` (node-local/cluster scratch), Snakemake `temp()` | purged (cluster policy / TTL) | intra-stage working files, anything recomputed within a run |
| **Disposable** | `data/generated/` | TTL'd; gitignored | exploratory / AI-produced / borderline-kept products |
| **Curated** | `data/processed/` (DataLad) | kept + versioned | stage outputs that passed the gate above |

*Why:* a documented purge window on the transient/disposable tiers is what lets you save
borderline artifacts *without* the bloat becoming permanent — the lifecycle policy, not your
discipline, does the cleanup. Use `/scratch` for genuinely transient working dirs (it is fast
and auto-purged); never leave a curated product there.

## Gotchas

- **`/scratch` is not backup and not durable.** It is purged on a schedule and may be
  node-local. A product you intend to keep must be promoted to `data/processed/` (a Snakemake
  rule output), never left in scratch.
- **The recipe must pin the environment too** — a git commit without the `pixi.lock` / env hash
  does not guarantee bit-reproducibility across machine or library upgrades.
- **Reuse count is easy to under-estimate.** CV folds, model variants, and reviewer reruns each
  multiply recompute cost; an artifact consumed "once per fold" is reused `n_folds` times.
- **Compression changes the ratio.** Evaluate the size threshold *after* float32 + chunked
  compression, not on the raw array.

## When to deviate (see `16-when-to-deviate.md`)

- A pipeline with a **long, fragile, or externally-rate-limited** stage may warrant checkpointing
  *every* step even when cheap-by-the-ratio, to bound restart cost.
- A **published / archived** dataset (Zenodo, OpenNeuro) is kept in full regardless of the ratio —
  the audience is the field, not your own reruns.
