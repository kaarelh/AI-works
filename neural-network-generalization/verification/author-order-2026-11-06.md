# Author-order publication review, 6 November 2026

The collection's named authors are ordered alphabetically: **ChatGPT-6 Astra; Claude (when credited); Kaarel Hänni; Dmitry Vaintrob**. Human names are sorted by surname and AI authors by their credited name. Each paper retains its own author roster.

This editorial revision adds the established footnote, “Authors are listed in alphabetical order,” to 13 canonical manuscripts and five current named-author companions. It corrects the author order on the two isotropic online papers and aligns all 18 PDFs' author metadata. The unified-activation polynomial-depth paper now uses the user-preferred **ChatGPT-6 Astra** credit instead of **OpenAI Codex**; the collection overview no longer lists those as two author identities. The [folder convention](../AGENTS.md) applies to future papers as well.

[Machine-readable checks and current manuscript hashes](author-order-2026-11-06.json) · [Independent author audit](author-order-independent-audit-2026-11-06.md)

## Scope

The 13 canonical manuscripts are:

- Unified-activation polynomial depth.
- Narrow-layer information.
- ReLU relative product.
- Finite-width posterior bounds.
- Local group computation.
- Structural Boolean depth.
- Shallow logistic learning.
- The nearcritical positive window.
- Occam learning under distribution shift.
- Neural function priors and online mistakes.
- AND learning under a Gaussian prior.
- Isotropic exponential online mistakes.
- Isotropic subexponential online mistakes.

The five companions are the uniform-target-classes note, the shallow softplus paper, and the Gaussian-controls, non-Gaussian-controls, and Gaussian-quadratic-occupation notes accompanying the tanh arithmetic-formula paper.

Single-author audits, preparer/recipient distinctions, the unnamed majority-OOD note, and explicitly archived provenance copies retain their previous credits. The existing equivalent wording “Authors are listed alphabetically” in the unbounded-activations paper is retained.

## Checks

- All 18 published PDFs were rebuilt. Each was then rebuilt in an isolated temporary directory; all extracted texts match, with no unresolved references or LaTeX warnings.
- The independent auditor checked the visible first-page author order and footnote, PDF `Author` metadata, and the 13 affected catalog author arrays. The two reordered isotropic title pages were also rendered and visually inspected.
- For every edited LaTeX source, the complete text after `\begin{document}` is byte-for-byte unchanged from commit `dcaec09bd5971adb1d5408b335a139e80a769751`. The independent audit additionally compared the full sources after removing only author declarations and `pdfauthor` metadata, confirming that preamble mathematical definitions are unchanged too.
- No Lean source changed. No Lean rebuild or new mathematical verification is claimed for this editorial revision.
- The catalog and current package checksum inventories were refreshed. Earlier dated mathematical review records remain historical snapshots; this record supplies the current author-revised manuscript hashes.
- The full collection inventory and local Markdown links were checked before publication. The collection-wide `SHA256SUMS` includes this editorial record and the new author convention.
