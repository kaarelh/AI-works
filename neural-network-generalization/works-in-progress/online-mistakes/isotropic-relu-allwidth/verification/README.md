# Build and proof status

The [paper](../paper.pdf) uses conventional analytic proofs and is **not Lean formalized**. Independent AI-agent mathematical reviews have been completed; the full review reports are not included in this publication.

The [build record](build-record.json) records the PDF and source checksums and the visual inspection of the title, author order, footnote, and theorem pages. A three-pass LaTeX build completed without warnings or unresolved references. The [isolated rebuild](isolated-build.json) reproduced the published PDF text from a clean copy of the source.

The result concerns the actual posterior at every sufficiently large fixed width, with the prior scale then tending to zero. The error count is `exp(Ω(C^(1/3)))` in the displayed shallow teacher width and `exp(Ω(√d))` in input dimension. The result covers ReLU and standard softplus; the softplus width threshold is existential. The input order reveals entire physical input classes between designated mistakes.
