# Persisting data — details

## NFS and HDF5 file locking

netCDF4/HDF5 take POSIX file locks that fail on many NFS mounts
(`OSError: unable to lock file, errno = 37`). Most university clusters are NFS.
Pick one policy per project and document it in `CLAUDE.md`:

- **Disable locking** (default): set `HDF5_USE_FILE_LOCKING=FALSE` in the
  environment (pixi `activation.env` or module-load script) and use the
  **`h5netcdf`** engine (pure `h5py`, avoids libnetcdf).
- **Use zarr**: a directory of chunks with no locking at all; `ds.to_zarr` /
  `xr.open_zarr`. Preferred for very large, chunked, or parallel-written products.

## Encoding gotchas

- **No bool in netCDF** — the save helper encodes `bool` as `int8` and restores on
  load. `h5netcdf(invalid_netcdf=True)` writes non-standard files; prefer int8.
- **Lazy vs eager** — use `xarray.load_dataset` (eager, releases the handle) over
  `open_dataset` (lazy, holds it) for small/medium intermediates on NFS.
- **Don't blob a DataFrame into netCDF** — parquet sidecar or non-dimensional
  coordinates, never a pickled column.
- **Complex configs** — stamp `params`/`seed`/`inputs` as attributes for simple
  cases; a sidecar `*.recipe.json` for complex ones. The recipe must pin the
  environment too (commit + lockfile hash) for bit-reproducibility.

## When to deviate

- Genuinely ragged/nested objects with no array/table form → structured text
  (JSON/msgpack), documented. Most "I need pickle" is an un-normalized schema.
- Arrays past ~10 GB or written concurrently by many workers → zarr over netCDF.
- A long, fragile, or rate-limited pipeline stage may checkpoint every step even
  when cheap-by-the-ratio, to bound restart cost.
- Published/archived datasets (Zenodo, OpenNeuro) are kept in full regardless of
  the cost ratio — the audience is the field, not your reruns.
