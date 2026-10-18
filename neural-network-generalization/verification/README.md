# Collection verification

This record concerns packaging and source reproducibility. Mathematical review records are retained in the relevant paper folders.

The current inventory contains **40 papers and notes**. The [latest Boolean-depth revision record](boolean-depth-structure-2026-10-18.json) covers the unrestricted-depth and critical-depth works in progress: independently reviewed structural theorems, a stronger actual parity learning lower bound, exact source hashes, and clean isolated rebuilds with matching PDF text. These additions are not Lean verified. The general polynomial-depth Boolean learning problem remains open. The [earlier revision record](boolean-depth-progress-2026-10-18.json) preserves the preceding circuit-rate and finite-bottleneck snapshot; counts in older records refer to their publication snapshots.

To check the catalog, PDF checksums, and local Markdown links:

```sh
python verify_collection.py
```

To additionally rebuild all papers in isolated temporary directories:

```sh
python verify_collection.py --rebuild --jobs 4
```

Run these commands from the collection root. They require Python 3, `pdflatex`, `pdfinfo`, and `pdftotext`; no network access is needed. Published PDFs are not changed by the verification script.

The latest full collection rebuild is recorded in [depth-publication-all-builds.json](depth-publication-all-builds.json). The five main papers were subsequently revised editorially and independently rebuilt; their source and PDF hashes are in the [editorial revision record](main-papers-editorial-revision-2026-10-18.json). A subsequent [robust-paper abstract clarification](robust-abstract-revision-2026-10-18.json) records that paper's current hashes and independent rebuild. The earlier `build-results.json` remains the 16 October snapshot.

The non-Gaussian extension was added separately after that full rebuild. Its [review and build record](../side-results/non-gaussian-priors/verification/README.md) includes an isolated source rebuild with identical extracted PDF text and no unresolved references or LaTeX warnings. The collection contains 38 catalogued papers after this addition; the historical counts below describe their respective publication snapshots. The extension is not Lean verified.

The continuous-domain regression paper brings the inventory to 39 papers. Its [review and build record](../side-results/continuous-domains/verification/README.md) covers the tolerance-regression and iterated exact-interpolation statements, independent mathematical reviews, and an isolated source rebuild with matching PDF text. It is also a conventional proof, outside the current Lean verification.

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

## Main-paper editorial revision, 18 October 2026

- All five main papers now introduce their learning question, prior, prediction convention, and quantifiers before the technical proof machinery. The robust-prior paper is retitled **A polynomial-depth learning bound for NNBayes on robust networks** and collects variants and detailed experiments in appendices.
- All five published PDFs match independent clean builds of their revised source after text extraction, with no unresolved references. The [revision record](main-papers-editorial-revision-2026-10-18.json) records the current hashes and per-paper checks. Earlier records describe earlier snapshots.
- Every formal theorem, lemma, proposition, corollary, definition, remark, and proof environment in the LaTeX source was compared with the preceding Git version and is unchanged. All non-entry source dependencies are byte-for-byte unchanged. Section numbering changes in the robust and mean-field papers. These comparisons establish the scope of the editorial changes, not a new correctness proof.
- The Lean sources and their verification scope are unchanged; the Lean build was not rerun for this editorial revision.
