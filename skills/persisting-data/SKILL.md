---
name: persisting-data
description: Governs how intermediate and derived scientific data is saved - which file formats (netCDF/parquet/zarr/NIfTI, never .npy/.pkl), what to save vs recompute, and the provenance every file must carry. Use whenever writing code that saves arrays, tables, model outputs, or any derived data file, whenever choosing a file format, whenever deciding if an artifact should be kept, and whenever np.save, pickle, or joblib.dump is about to be written.
---

# Persisting data

Every derived artifact is stored **self-documenting and cross-language** — a `.npy`/`.pkl` is a riddle six months later and unreadable outside Python. And every artifact faces one question first: *is it cheaper to keep than to regenerate, given how reproducibly it can be regenerated?*

## The format map

| Data shape | Format | Tooling |
|---|---|---|
| Non-spatial N-D arrays | **netCDF4** (named dims, coords, attrs) | `xarray` + `h5netcdf` |
| Tables / metadata | **parquet** (typed columns) | `pandas` + `pyarrow` |
| Brain volumes / surfaces / grayordinates | **NIfTI / GIFTI / CIFTI** — keep the domain format, never repackage into generic HDF5 | `nibabel` |
| Very large / chunked / parallel-written | **zarr** | `xarray` + `zarr` |

**Banned as persistence:** `.npy`, `.npz`, pickle, `joblib.dump` of fitted estimators, bare CSV for typed tables. Persist the *arrays you need* (coefficients, hyperparameters, CV indices) as netCDF, never the live estimator. (Reading legacy third-party `.npy` is fine; producing it is not — a CI grep test fails the build on `np.save`/`pickle.dump` in `src/` and `scripts/`.)

## Format gates

- **Label the axes.** Named dimensions + coordinate arrays (netCDF) or typed columns (parquet); positional-only arrays are banned.
- **Stamp provenance, always:** `git_commit`, `created_utc`, `creator`, `description`, `stage`, `space`/`subject`. Use the project's `save_dataset`/`load_dataset` helper (one-line, auto-stamps, validates) so the self-documented path is the path of least resistance.
- **float32 for voxel data** (fMRI SNR makes float64 overkill); keep float64 for affines, transforms, displacement fields.

## Save vs recompute — the decision

Apply at each stage boundary:

```
Intra-stage scratch?                       → temp (Snakemake temp() / /scratch); recompute.
Reproducibility gate — SAVE regardless of cost, if ANY of:
  • regeneration is non-deterministic (unseedable, GPU nondeterminism)
  • downstream of a manual / QC / interactive step
  • depends on an external or unpinned dependency
  • losing it makes a published figure unreproducible
Else cost ratio:
  • recompute_secs × reuse_count ≫ store+reload cost → SAVE (float32+compressed)
  • cheap or rarely reused, and large               → DROP; recompute on demand
  • borderline                                      → scratch/TTL tier
ALWAYS persist the recipe (commit, params, seed, input identities) — saved or not.
```

The recipe rule is what makes "drop and recompute" safe; it is unconditional. Reuse is easy to under-estimate (an artifact consumed once per fold is reused `n_folds` times). Lab default thresholds: keep if >~10 min to regenerate or reused ≥3×, and <~1 GB after compression.

## Tiers

| Tier | Where | Lifetime |
|---|---|---|
| Transient | `/scratch`, Snakemake `temp()` | purged; never durable |
| Disposable | `data/generated/` | TTL'd; gitignored |
| Curated | `data/processed/` (DataLad) | kept + versioned; only via a pipeline rule |

NFS/HDF5 file-locking policy and encoding gotchas: [references/details.md](references/details.md).
