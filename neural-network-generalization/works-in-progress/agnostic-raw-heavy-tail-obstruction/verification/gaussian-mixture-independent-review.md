# Independent audit of the fixed Gaussian-mixture obstruction

Reviewed 18 November 2026 against the source in the adjacent hash manifest. This reviewer independently derived the Gaussian-mask mechanism and fixed-prior embedding, then checked the exact source written by the robust-prior reviewer.

The theorem passes. The prior is one sample-size-independent measure on smooth functions on a fixed compact interval. Its countable branch masses sum correctly; every path belongs to only one finite bump construction. The supremum is bounded by one absolute Gaussian amplitude, conditional kernels are centered rank one with diagonal at most one, and the zero function has mass exactly one half.

On the active input block, all other branches are genuinely zero. The active evidence is bounded below by the common-data Gaussian evidence times `(1-p)^n`. The common-observation likelihood advantage has a positive exponent uniformly for common count at least `n/3`, and this dominates the logarithmic branch-prior penalty. The numerical coefficient `2/9-1/50` is valid.

The active amplitude posterior is a Gaussian tilted by a function between `(1-p)^n` and one. Both its lower-tail bound and its negative-mean bound have the stated exponents. They imply a positive mean of order `sqrt(n)`, rather than merely a large posterior second moment. Unobserved mask coordinates retain their independent Bernoulli law exactly. Their positive mean survives posterior averaging, and their total test probability remains bounded below, giving the claimed linear risk lower bound with probability tending to one.

The zero comparison has fixed risk one half and KL exactly `log 2`. Thus the consequence excludes any fixed-factor distribution-uniform agnostic raw oracle whose right side stays bounded for that comparison. The paper correctly distinguishes this fixed generic function prior from an actual finite neural architecture, and varying adverse laws from inconsistency under one fixed law. No substantive mathematical gap or scope overstatement was found.

Final scope note: the subsequent short corollary using disjoint `(j,k)` blocks to obtain one temperature-independent prior was assembled by this reviewer from the coordinating and proof reviewers' construction. Its independent checks are recorded in the final five-source review and robust-agent review, not claimed as a self-audit here. The current adjacent hash covers the integrated appendix; the independent proof assessment above concerns its original theorem and mechanism.
