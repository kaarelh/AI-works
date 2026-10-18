# Collection verification

This record concerns packaging and source reproducibility. Mathematical review records are retained in the relevant paper folders.

To check the catalog, PDF checksums, and local Markdown links:

```sh
python verify_collection.py
```

To additionally rebuild all papers in isolated temporary directories:

```sh
python verify_collection.py --rebuild --jobs 4
```

Run these commands from the collection root. They require Python 3, `pdflatex`, `pdfinfo`, and `pdftotext`; no network access is needed. Published PDFs are not changed by the verification script.

The latest full paper rebuild is recorded in [depth-publication-all-builds.json](depth-publication-all-builds.json). The earlier `build-results.json` remains the 16 October snapshot.

## Publication checks, 16 October 2026

- All 30 papers rebuilt successfully from the copied source dependencies using two LaTeX passes. No unresolved references or LaTeX warnings were reported.
- Extracted PDF text matched the copied canonical PDF for 29 papers. The earlier positive-subcritical standalone draft had unresolved references in its old one-pass PDF. Its unchanged source was rebuilt to resolve those references; a fresh isolated rebuild now matches the published PDF text. No mathematical source edits were made.
- The four main-result descriptions and the complete 30-paper catalog received separate scope reviews against the manuscripts.
- Both computational certificate ZIPs passed archive-integrity checks. Their original scripts and exact data are preserved; the long certificate enumerations were not rerun for this packaging task.
- Local Markdown links, PDF checksums, and the final Git diff were checked before publication.

[Detailed build results](build-results.json) · [Excluded duplicates and external references](excluded-duplicates-and-references.json)

To verify all published file checksums, run `sha256sum -c SHA256SUMS` from the collection root. The checksum file excludes itself and ignored build output.

## Publication checks, 18 October 2026

- The collection now contains **37 papers and notes: five main results, 25 side results, and seven works in progress**. The recent unrestricted-depth research remains a work in progress.
- All 37 papers rebuilt in isolated temporary directories. Extracted PDF text matched the published PDFs, with no unresolved references or LaTeX warnings. [Full build results](depth-publication-all-builds.json) and the [seven-paper addition check](depth-publication-builds.json) record these checks. The robustness paper was subsequently rebuilt after one editorial sentence updated its Lean verification status; a separate isolated rebuild of that revised source again matched the published text. Its [revision record](robust-publication-revision-build.json) preserves the original build evidence and revised source hashes; mathematical content was unchanged.
- The empirical package preserves 473 original files byte for byte. Of these, 470 also match the original full archive manifest; the other three are packaging records generated after the archive contents were selected. All 70 abridged model records match their original records after removal of the two explicitly declared per-example output arrays.
- Five original model checkpoints and full records are included (105, 301, 500, 504, and 505); the other 65 are omitted. The full original archive inventory is preserved, but its ZIP volumes have no public download URL. [Reproduction scope](../works-in-progress/depth-experiments/REPRODUCTION.md) states what can be replayed directly and what must be regenerated.
- The selected exact model-105 counterexample, model-500 all-domain certificate, and model-301 global certificate were replayed from the packaged inputs. Their computational checks are separate from Lean verification. [Representative replay](../works-in-progress/depth-experiments/reproducibility/representative-replay.json) · [Model-301 replay](../works-in-progress/depth-experiments/reproducibility/model301-replay.json).

The Lean theorem gate and its precise scope are recorded separately in [the Lean verification record](../lean/VERIFICATION.md). Package checks do not establish mathematical correctness or extend the scope of a formal theorem.
