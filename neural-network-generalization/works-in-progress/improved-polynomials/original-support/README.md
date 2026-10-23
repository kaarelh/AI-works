# An explicit quartic bound with the original robust support

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Independent review](../verification/independent-review.md#original-support-quartic-theorem)

This paper retains the existing internal-noise support restriction and gives a sufficient sample bound `O(C^4 log^9(2+C))` with other parameters fixed. Its dependence on depth is polynomial, and the statistical accuracy factor is `1/epsilon`. The guarantee holds at every learner width above Boolean teacher width in the strong-prior regime and at actual finite scales with `gamma >= 2`.

It does not prove quadratic teacher-width dependence or this quartic bound at `1 <= gamma < 2`. The full-energy estimate used here cannot discard the Gaussian bulk energy in that range.

The pruning-and-Bernstein compressor was already proved in the [17 October depth report](../../depth-supporting-notes/round1-depth-report/). The contribution here is its adaptation to the current clipped-score support, explicit polynomial bookkeeping, and the finite-scale posterior conclusion. The full target-cylinder construction from the [robust-prior paper](../../../main-results/robust-polynomial-depth/) is reproduced in an appendix, with its provenance credited. The superseded pointwise Markov prototype is not a separate paper in this collection.

The proof has independent AI-agent mathematical review. It is not Lean verified and has not received full human mathematical review.

Run `./build.sh` to rebuild `paper.pdf` with `pdflatex`. See the [collection overview](../README.md) for the stronger-support quadratic theorem and the shallow theorem.
