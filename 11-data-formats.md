# 11 — Data formats (intermediate & derived files)

Every intermediate or derived artifact is stored in a **self-documenting, cross-language**
format. Never a Python-only opaque one. A `.npy`/`.npz`/`.pkl` is a riddle six months later
("which axis is trials? which voxel order? which subject? what mask? what commit produced
it?"); pickle additionally breaks across library versions and is unreadable outside Python.

*Why:* an intermediate file is a contract with your future self, a collaborator, a reviewer,
and the MATLAB/R/Julia user down the hall. The format must carry the answer to "what is this?"
*in the file*, not in the script that happened to write it (which will have changed).

## The format map

| Data shape | Format | Tooling |
|---|---|---|
| Non-spatial N-D arrays | **netCDF4** (named dims, coords, attrs) | `xarray` + `h5netcdf` engine |
| Tables / metadata | **parquet** (typed columns, schema metadata) | `pandas` + `pyarrow` |
| Brain volumes | **NIfTI** (`.nii.gz`) | `nibabel` |
| Cortical surfaces | **GIFTI** (`.gii`) | `nibabel` |
| Surface + volume (grayordinates) | **CIFTI** (`.dscalar.nii`, …) | `nibabel` |
| Very large / chunked / parallel-written arrays | **zarr** | `xarray` + `zarr` |

**Never** persist `.npy`, `.npz`, `.pkl`, a `joblib.dump` of a fitted estimator, or a bare
`.csv` for a typed table.

## Hard rules

- **Label the axes.** Every stored array has named dimensions and coordinate arrays
  (netCDF) or typed columns (parquet). Positional-only arrays are banned — `(7200, 98262)`
  with no dim names is exactly the `.npz` problem with a new extension.
- **Stamp provenance, always.** Every file carries global attributes: `git_commit`,
  `created_utc`, `creator` (package + version), plus a human `description`, the `stage`
  that produced it, and the `space` / `subject` it pertains to. Variables carry
  `long_name` / `units` where meaningful. (A project's reference helper stamps these
  automatically; see below.)
- **Brain-referenced data keeps its domain format.** Volumes → NIfTI, surfaces → GIFTI,
  grayordinates → CIFTI. Do **not** repackage a cortical map into generic HDF5 — you would
  throw away the affine / header / structure that makes it self-documenting. The rule is
  "non-spatial arrays → netCDF; brain-referenced data → NIfTI/GIFTI/CIFTI", not
  "everything → HDF5".
- **Pickle/joblib are banned as a persistence format.** Persist the *arrays you need*
  (model coefficients, chosen hyperparameters, CV indices) as netCDF — never the live
  fitted `sklearn`/`himalaya` estimator, which will not survive a library bump. (`joblib`
  as an in-process *parallel backend* is fine; the ban is only on it as on-disk state.)
- **Tables are parquet, not CSV.** Trial tables, ROI manifests, per-video scores → parquet
  (typed, self-describing, cross-language). Or fold them into a netCDF `Dataset` as
  non-dimensional coordinates so the array and its metadata cannot desync.

*Why:* netCDF and parquet are the lingua franca of the scientific and data-engineering
worlds — readable from Python, R, Julia, MATLAB, C, and the command line (`ncdump`,
`parquet-tools`), stable across decades, with first-class metadata. `.npy` has none of that.

## NFS and HDF5 file locking

netCDF4 and HDF5 take POSIX file locks that **fail on many NFS mounts** with
`OSError: unable to lock file, errno = 37`. Most university clusters are NFS. Pick one
policy per project and document it:

- **Disable locking** — set `HDF5_USE_FILE_LOCKING=FALSE` in the environment (pixi
  `activation.env`, or the module-load script), and use the **`h5netcdf`** engine (pure
  `h5py`, avoids the `libnetcdf` C library entirely). This is the default.
- **Use zarr** — a directory of chunks with *no file locking at all*; xarray reads/writes
  it identically (`ds.to_zarr` / `xr.open_zarr`). Preferred for very large, chunked, or
  parallel-written products.

*Why:* a convention that intermittently fails to read its own outputs on the lab's own
cluster is worse than no convention. Decide the locking policy up front.

## The reference helper

A project ships **one** save/load pair that stamps provenance and validates the required
attributes, so the self-documented path is the path of least resistance (people reach for
`np.savez` because it is one line — the helper has to be one line too):

```python
import xarray as xr
from myproject.io import save_dataset, load_dataset

ds = xr.Dataset(
    {"unique_variance": (("band", "voxel"), uv),   # named dims
     "total_r2":        (("voxel",), r2)},
    coords={"band": BAND_NAMES, "voxel": voxel_index},   # coordinate arrays
)
save_dataset(path, ds, description="held-out CV split-R² per band",
             stage="stage2_brr", space="T1w-2p0mm", subject="sub-001", mask="cortex_dil")

ds = load_dataset(path)
uv = ds["unique_variance"].values            # back to numpy at the edge
```

The helper: enforces the `.nc` suffix; auto-stamps `git_commit` / `created_utc` / `creator`;
requires `description` + `stage`; encodes `bool` as `int8` and restores it on load (netCDF
has no boolean type); uses `xarray.load_dataset` (eager — closes the file handle, no
lingering NFS lock). A parallel `save_table` / `load_table` does the same for parquet.

## Enforcement

- A test (run in `check`) greps `src/` and `scripts/` and **fails the build** on
  `np.save`, `np.savez`, `pickle.dump`, or `joblib.dump(... .pkl ...)`. A documentation
  rule nobody tools around gets ignored.
- *Reading* legacy or third-party `.npy`/`.npz` you did not produce is fine; *producing*
  them is not.

## Gotchas

- **No bool in netCDF** — store as `int8` and restore on load (the helper does this).
  `h5netcdf(invalid_netcdf=True)` allows native bool/complex but writes non-standard files;
  prefer the `int8` encoding for portability.
- **Lazy vs eager reads** — use xarray's `load_dataset` (eager, releases the handle) over
  `open_dataset` (lazy, holds it) for small/medium intermediates on NFS.
- **Don't blob a DataFrame into netCDF** — use a parquet sidecar or non-dimensional
  coordinates, not a pickled column.
- **Precision** — cast `float64` voxel maps to `float32` before storing unless the extra
  precision is load-bearing. (That is the *storage-budget* convention — what/whether to
  save — which is separate from this *format* convention.)

## When to deviate (see `09-when-to-deviate.md`)

- A genuinely ragged or deeply nested object with no array/table representation may need a
  structured text format (JSON / msgpack) — document why. In practice most "I need pickle"
  is an un-normalized schema that *does* have a tabular/array form.
- Arrays past ~10 GB, or written concurrently by many workers → **zarr** over netCDF.
