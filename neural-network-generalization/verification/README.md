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

The final publication check results are recorded in `build-results.json`.

## Publication checks, 16 October 2026

- All 30 papers rebuilt successfully from the copied source dependencies using two LaTeX passes. No unresolved references or LaTeX warnings were reported.
- Extracted PDF text matched the copied canonical PDF for 29 papers. The earlier positive-subcritical standalone draft had unresolved references in its old one-pass PDF. Its unchanged source was rebuilt to resolve those references; a fresh isolated rebuild now matches the published PDF text. No mathematical source edits were made.
- The four main-result descriptions and the complete 30-paper catalog received separate scope reviews against the manuscripts.
- Both computational certificate ZIPs passed archive-integrity checks. Their original scripts and exact data are preserved; the long certificate enumerations were not rerun for this packaging task.
- Local Markdown links, PDF checksums, and the final Git diff were checked before publication.

[Detailed build results](build-results.json) · [Excluded duplicates and external references](excluded-duplicates-and-references.json)

To verify all published file checksums, run `sha256sum -c SHA256SUMS` from the collection root. The checksum file excludes itself and ignored build output.
