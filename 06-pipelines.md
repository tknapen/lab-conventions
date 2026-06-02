# 06 — Pipelines

## Snakemake for orchestration

Multi-step analyses (anything that touches more than one subject, or that has more than one stage) are Snakemake workflows. Not ad-hoc bash, not "I'll run these cells in order".

*Why:* Snakemake gives you a DAG, automatic dependency tracking, restart-from-failure, parallelism, and HPC submission (SLURM, SGE) from one declaration. The cost is one `Snakefile`. The Python DSL keeps it readable for a lab that already reads Python.

## Hard rules

- Pipelines live in `workflow/` (Snakemake's canonical location).
- Every rule has an `output:` declaration. No rule writes files it doesn't claim.
- Pipeline outputs go to `data/processed/`. AI-generated artifacts go to `data/generated/`. See `07-project-layout.md`.
- Rules use `conda:` or `container:` directives for their environment, not the calling shell's. This keeps rules portable to HPC and CI.
- The `Snakefile` is type-checked via `snakemake --lint`.
- Always run `snakemake -n` (dry-run) before `snakemake --cores N` after any change.

*Why:* an output declaration is the contract that lets Snakemake know what to skip and what to re-run. Skipping it leads to mysterious re-execution.

## Containers and HPC

Neuroimaging pipelines that touch FSL / FreeSurfer / fMRIPrep / AFNI use **Apptainer** (formerly Singularity) on HPC, **Docker** for local development. Build once with Docker; convert with `apptainer build foo.sif docker://org/foo:tag` for the cluster.

```python
# Snakefile rule with a container
rule fmriprep:
    input:  "data/raw/sub-{sub}/"
    output: directory("data/processed/derivatives/fmriprep/sub-{sub}")
    container: "docker://nipreps/fmriprep:24.1.1"
    threads: 8
    resources:
        mem_mb=32000,
        runtime=720,  # minutes
    shell:
        "fmriprep {input} data/processed/derivatives participant "
        "--participant-label {wildcards.sub} -w $SCRATCH/wd"
```

*Why:* Apptainer's root-free, single-`.sif` model is the only thing university HPC centers reliably support. Docker locally + Apptainer on the cluster from the same image is now the BIDS Apps convention.

## SLURM submission

Use Snakemake's `--executor slurm` (Snakemake 8+) rather than hand-rolling sbatch scripts. Resource requirements go in the rule's `resources:` block, not in a wrapper.

```bash
snakemake --executor slurm --jobs 100 --workflow-profile profiles/slurm
```

`profiles/slurm/config.yaml` holds cluster-wide defaults (partition, account, default time limit). Commit it.

*Why:* one source of truth for resource requirements (the Snakefile) means changing memory in one place propagates everywhere.

## Provenance

For neuroimaging-shaped projects, pair Snakemake with **DataLad** (see `07-project-layout.md`). DataLad's `datalad run` captures the command, container, and code commit that produced an output. This is the lab's provenance layer.

*Why:* "which version of fMRIPrep produced this derivative?" is a question DataLad answers in one command and a bare Snakemake setup cannot.

## Gotchas

- Snakemake's `resources:` block names (`mem_mb`, `runtime`, `tmpdir`) are conventional; pick consistent names across the lab and stick with them.
- `container:` directives require Apptainer or Docker available on the executing node. CI nodes typically have Docker; HPC nodes typically have Apptainer.
- Don't use `shell:` for anything non-trivial — extract to a `script:` directive pointing at a Python file in `src/`.
- `--use-conda` is legacy; new pipelines use `conda:` env files declared per-rule and resolved at runtime, but pin them in lockfiles for reproducibility.

## When Snakemake is overkill

For a single-stage script that runs once and produces one figure, use a PEP 723 inline-metadata script (see `08-commands.md`) instead. Snakemake is for *multi-stage* or *multi-subject* work.
