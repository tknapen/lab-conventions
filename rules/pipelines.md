---
paths:
  - "workflow/**"
---

# Pipeline rules

Multi-step / multi-subject analyses are **Snakemake** workflows in `workflow/` — not ad-hoc bash, not run-these-cells-in-order. Single-stage one-shot scripts use PEP 723 inline metadata instead (see `reference/commands.md`).

## Hard rules

- Every rule declares its `output:` — that contract is what lets Snakemake know what to skip vs re-run.
- Outputs → `data/processed/`; AI/exploratory artifacts → `data/generated/`.
- Rules carry `conda:`/`container:` directives (not the calling shell's env) for HPC/CI portability.
- `snakemake --lint` passes; always dry-run (`snakemake -n`) after any change before `--cores N`.
- Nothing non-trivial in `shell:` — use `script:` pointing at `src/`.

## Containers and HPC

Neuroimaging tools (FSL/FreeSurfer/fMRIPrep/AFNI): **Docker** locally, **Apptainer** on the cluster, built once from the same image (`apptainer build foo.sif docker://org/foo:tag`). SLURM via `--executor slurm --workflow-profile profiles/slurm` (Snakemake 8+); resources live in the rule's `resources:` block (consistent names: `mem_mb`, `runtime`), never hand-rolled sbatch. Commit `profiles/slurm/config.yaml`.

## Provenance

Neuroimaging projects pair Snakemake with **DataLad**: `datalad run` captures command + container + code commit per output — the answer to "which fMRIPrep produced this derivative?". `data/raw/` and `data/processed/` are subdatasets; use `datalad status -r` (top-level `git status` won't see subdataset changes).

## Gotchas

- `container:` needs Docker on CI nodes, Apptainer on HPC nodes.
- `--use-conda` is legacy; declare per-rule `conda:` env files, pinned via lockfiles.
- The multiverse robustness grid (see `checking-robustness` skill) is a small fan-out here: wildcards over the choice axes, one aggregated specification-curve output — `just multiverse <analysis>`.
