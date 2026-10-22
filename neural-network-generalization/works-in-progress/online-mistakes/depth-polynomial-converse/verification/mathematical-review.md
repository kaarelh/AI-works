# Verification record

Date: 22 October 2026.

The manuscript and PDF have been independently reviewed by a second mathematical research agent. This is an AI-agent mathematical check, not a Lean formalization or independent human review.

The reviewer checked the following proof components and reported no substantive gap:

- Continuity and finite-disturbance meaning of the internal-gain certificate.
- Exact certificate identities under neuron cloning, padding, and block direct sums.
- Open-support Gaussian energy rates and the strong-prior-then-width connection to minimum-action prediction.
- The exact singleton expansion, its coefficient bounds, strictly contractive relays, and polynomial-depth correction cost.
- Forced mistakes when the minimum compatible action increases, including arbitrary mixtures of tied minimizers.
- The deterministic compressor's independence structure, pruning error, Bernstein constants, expected energy, and actual bounded-width reconstruction.

The reviewer requested an explicit source for the Hilbert-space Bernstein inequality; the final draft states the inequality and cites Tarrès–Yao, Appendix A, Corollary A.2. At the proof's displayed variance, norm, and tolerance bounds, the Bernstein exponent is at least `3 m r²/(640 K)`, which is stronger than the claimed `m r²/(256 K)`.

The source was compiled twice with `pdflatex -halt-on-error`; the PDF builds successfully. The remaining LaTeX underfull-box notices occur in references and do not affect mathematical content.

No code tests replace any part of the proof. The result is not Lean verified and should remain a work in progress until additional review.
