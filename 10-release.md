# 10 — Release

**Read this file only when actually releasing a project.** Day-to-day lab work doesn't need any of it.

A "release" means making code citable, installable by strangers, or both. The three milestones, in increasing order of effort:

1. **Zenodo deposit** — a GitHub tag becomes a citable archive with a DOI. Right for: paper-companion code, datasets, anything that needs to be cited.
2. **PyPI release** — `pip install yourpackage` works for anyone. Right for: reusable libraries other people will depend on.
3. **JOSS submission** — peer-reviewed publication of the software itself, with a CrossRef DOI. Right for: substantial software that warrants its own citation, when papers using it don't already cover the methods.

Pick the minimum that matches what you actually need. Skip the rest.

## Before any release

A project ready for any release has, at minimum:

- A `LICENSE` file with an OSI-approved license. **MIT** for permissive (default for lab releases), **BSD-3-Clause** if you want explicit non-endorsement, **GPL-3.0** if you want copyleft. Pick one and stop overthinking it.
- A `README.md` with: one-sentence description, install instructions, minimal usage example, citation block.
- A `CITATION.cff` file at the repo root. GitHub renders it as a "Cite this repository" button; Zenodo and other tools parse it automatically.
- A `CHANGELOG.md` (Keep-a-Changelog format) starting at version 0.1.0.
- A `.zenodo.json` if depositing to Zenodo (controls authorship and metadata in the deposit).
- All the lab conventions in `00-09` already satisfied (lockfiles committed, CI green, etc.).

*Why:* none of the release steps below work cleanly without these. A 6-month-old repo with no license blocks Zenodo, no `CITATION.cff` produces ugly citations, no `CHANGELOG` makes "what changed in v1.2" unanswerable.

## Hard rules

- Releases are git tags. `v0.3.0`, with the `v` prefix.
- Tags are signed: `git tag -s v0.3.0 -m "Release 0.3.0"`. Configure `git config user.signingkey` once.
- Tags are pushed: `git push --tags`. No release without a pushed tag.
- The tag triggers automation (Zenodo DOI, PyPI upload, GitHub release). Don't do these by hand.
- Never delete or move a published tag. If you tagged the wrong commit, release a new patch version.

*Why:* an immutable tag is the citation primitive. Moving or deleting one breaks every reference to it (Zenodo records, downstream lockfiles, papers).

## Milestone 1: Zenodo deposit

The minimum-viable release. Right for paper-companion code where reproducibility is the goal and PyPI distribution isn't needed.

1. Enable the GitHub-Zenodo integration once per repo (zenodo.org → GitHub → flip the toggle for this repo).
2. Add `.zenodo.json` (controls Zenodo metadata; without it, Zenodo guesses from the GitHub repo and often gets author affiliations wrong):

   ```json
   {
     "title": "myproject: descriptive subtitle",
     "description": "One-paragraph description with the paper this supports.",
     "creators": [
       {
         "name": "Lastname, Firstname",
         "affiliation": "Lab Name, University",
         "orcid": "0000-0000-0000-0000"
       }
     ],
     "license": "MIT",
     "upload_type": "software",
     "keywords": ["neuroimaging", "fmri", "<project-specific>"],
     "related_identifiers": [
       {
         "identifier": "10.1234/the-paper-doi",
         "relation": "isSupplementTo",
         "resource_type": "publication-article"
       }
     ]
   }
   ```

3. Create a GitHub release pointing at the tag. Zenodo polls GitHub and produces a DOI for that release within minutes.
4. The Zenodo "concept DOI" (always points at latest version) and "version DOI" (this specific release) are both yours. **Cite the concept DOI** in papers — readers automatically get the latest version.

*Why:* Zenodo is the only path that gives you a real DOI for a GitHub tag without paying or applying. CrossRef and DataCite require institutional accounts.

## Milestone 2: PyPI release

For libraries other people will install. Adds work over Zenodo: a published wheel that survives someone's lockfile resolution.

### One-time setup

1. Reserve the name on PyPI: register an account, create an empty project with the right name (you can't claim a name until you've uploaded at least once, so this is more "pick the name carefully" than "reserve").
2. Configure **trusted publishing** on PyPI: PyPI → your project → "Publishing" → "Add a new pending publisher". Fill in your GitHub org/repo, the workflow filename (`.github/workflows/release.yml`), and the environment name (`pypi`). No long-lived tokens needed.
3. Create the GitHub environment: repo → Settings → Environments → New → name it `pypi`. Optionally require approval before deploys.

### The release workflow

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ["v*"]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0   # required for uv-dynamic-versioning
      - uses: astral-sh/setup-uv@v8
      - run: uv build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/

  smoke-test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/
      - uses: astral-sh/setup-uv@v8
      - run: uv run --isolated --no-project --with dist/*.whl python -c "import myproject; print(myproject.__version__)"

  publish-pypi:
    needs: smoke-test
    runs-on: ubuntu-latest
    environment:
      name: pypi
      url: https://pypi.org/p/myproject
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/
      - uses: astral-sh/setup-uv@v8
      - run: uv publish

  github-release:
    needs: publish-pypi
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v6
      - uses: softprops/action-gh-release@v2
        with:
          generate_release_notes: true
          # tag triggers Zenodo deposit automatically once integration is on
```

*Why:* the four-job split (build → smoke-test → publish → github-release) means a bad wheel never reaches PyPI, and the GitHub release at the end triggers the Zenodo DOI automatically.

### Hard rules for PyPI

- Never publish from a local machine. PyPI uploads happen from CI, signed via OIDC. Trusted-publishing only.
- Never re-use a version number. If you tagged `v0.3.0` and the upload broke, fix the cause and release `v0.3.1`. PyPI does not allow overwriting; pretending otherwise wastes hours.
- Yank rather than delete: PyPI's "yank" hides a version from default resolution but keeps it installable by exact pin, which is the correct behavior for anyone whose lockfile points at the bad version.

## Milestone 3: JOSS submission

JOSS (Journal of Open Source Software) is peer-reviewed publication of the software itself. The paper is a 750–1750-word `paper.md`. Right for: substantial libraries (>~3 person-months of work, original methods) where you want a citation that isn't tied to a specific research paper.

### Eligibility check (do this first)

- Public repo with ≥6 months of history. Brand-new repos are not eligible.
- Substantial scholarly effort — JOSS rejects "a few scripts" and "thin wrappers around existing libraries".
- Documentation: install instructions, usage example, statement of need, automated tests.
- An OSI-approved license.

If any of these fail, fix them first, then submit.

### The submission

1. Add a `paper/` directory:
   - `paper.md` — 750–1750 words with the JOSS-mandated sections: Summary, Statement of need, Research impact statement, AI usage disclosure (required as of 2026), Acknowledgements, References.
   - `paper.bib` — BibTeX references.
2. Validate locally with the `openjournals/inara` Docker image, or run the `openjournals/openjournals-draft-action` GitHub Action that compiles `paper.md` on every PR.
3. Submit at joss.theoj.org → "Start submission". Wait for editor assignment, then ~1–6 months of review.

*Why:* JOSS is peer-reviewed and CrossRef-indexed. A JOSS paper gives downstream users a single, stable, peer-reviewed citation rather than a moving GitHub URL.

### Hard rules for JOSS

- The `paper.md` is in the repo, not a separate one. Reviewers expect to find it at `paper/paper.md` or `paper.md`.
- Include the **Research impact statement** and **AI usage disclosure** sections; these were added to the JOSS scope in 2026 and reviewers will request them if missing.
- Co-authors get added to `CITATION.cff` and `.zenodo.json` at submission time, not after. Late authorship changes in JOSS are a common rejection cause.

## Versioning policy

Semantic versioning, strictly:

- `MAJOR.MINOR.PATCH`, starting at `0.1.0` for first release.
- `PATCH` for bugfixes, no API changes.
- `MINOR` for backwards-compatible new functionality.
- `MAJOR` for breaking changes. Releases before `1.0.0` may break in minor versions — document it in `CHANGELOG.md`.
- The version comes from the git tag via `uv-dynamic-versioning` (see `02-packaging.md`); never hardcode it.

*Why:* downstream users pin via SemVer ranges (`^0.3` etc.); violating SemVer breaks their lockfiles silently. The lab will get bug reports either way; SemVer makes them about real bugs, not surprise breakage.

## Gotchas

- The Zenodo integration only fires on **GitHub Releases**, not on bare tags. The workflow above creates the release; if you tag without releasing, no DOI.
- `uv-dynamic-versioning` needs `fetch-depth: 0` in the checkout action. With the default shallow clone, the version is wrong.
- PyPI trusted publishing requires the workflow filename and environment name to match what you registered on PyPI. Rename either and the upload fails with a confusing OIDC error.
- The JOSS review happens entirely in GitHub issues on `openjournals/joss-reviews`. Watch the issue; reviewer comments expect responses within ~2 weeks or the submission stalls.
- `CITATION.cff` and `.zenodo.json` are easy to leave inconsistent (different author lists, different ORCIDs). Use a single source of truth — generate one from the other in a `just` recipe, or commit a check that diffs them in pre-commit.

## What this file does NOT cover

- **Containerized releases (Docker Hub, GHCR).** Add a separate `release-container.yml` workflow; the pattern is parallel to PyPI publishing.
- **conda-forge feedstocks.** Worth doing for libraries with non-Python deps that pip-only users struggle with. The conda-forge bot handles most of it once you submit a recipe; see the conda-forge docs.
- **R packages, MATLAB toolboxes.** Out of scope for these conventions.
- **Press / institutional announcements.** Not a release matter.
