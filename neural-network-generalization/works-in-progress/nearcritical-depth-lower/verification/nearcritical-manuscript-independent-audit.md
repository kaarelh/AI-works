# Fresh audit of the standalone nearcritical manuscript

25 October 2026. Finite-N audit agent. Conventional mathematical audit; not Lean verified.

**PASS.** I read the complete standalone manuscript `nearcritical-depth-lower/source/paper.tex` after the scratch assembly audit. The audited source SHA256 is `a0ba5249bcf8db9a620eeaa627a1963fb56600ad71dedd24a9b49d6625410e1a`.

I also checked the subsequent scope clarification, source SHA256 `d96691d2449ea93b89b0cd697815c0e37cbd77852672291bf54d8c398bc14a28`: the empirical-transport proposition now explicitly assumes `N>=C m^4 log(eN)`, as required by its appendix. This assumption already follows from the main theorem's parameter choice. The clarification is appropriate and does not alter the main theorem or this verdict.

No mathematical correction was needed. In particular, compression into the paper retained:

- the specified finite width, global margin convention, `t>1`, and exclusion of deterministic-majority and exact-critical claims;
- the exact Gaussian covariance-chain marginals, adaptive measurable factor choices, and distinction between population Hermite factors and empirical common-array coupling;
- the nearcritical scalar and Hermite expansions, normalized global/local geometry, and the fact that fixed metric-comparison constants multiply only empirical errors or higher Hermite components;
- the unital-Schur spectral monotonicity, first-Hermite spectral lower comparison, composite occupation potential, and high-variance cooling estimate with the correct `3 epsilon` coefficient;
- the separate seed, weak amplification, and final amplification stages of the mass witness, including the phase-two bootstrap, relative Frobenius accuracy, noncommuting Gaussian KL decomposition, and stopped controls;
- the special relative-accuracy treatment of the free-prefix endpoint before the seed, and the smaller absolute tolerances used for subsequent controlled covariances;
- the noncircular constant order, actual full-label probability lower bound, exponentially smaller discarded probabilities, and exact Gaussian readout dilation comparison;
- the compact two-feature proof with a negative MGF, the half-mass rare-strip VC estimate, matrix derivative concentration in Frobenius dual norm, and empirical diagonal-normalization differentiation;
- the common-additive-error Bures lemma, including indefinite covariance errors and the positive-definite path argument;
- the free-prefix proof's gain `1+O(epsilon^2)` during burn-in and its invariant entrywise box for arbitrarily long remaining prefixes.

I also checked the new corollaries: `epsilon=d^-alpha`, for fixed `0<alpha<=1/2`, gives `H=Theta(d^(1+2alpha))`, width exponential in d, and confidence sample lower bound `exp(Omega(H^(1/(1+2alpha))))`. These substitutions do not assert a result at exact `t=1`.

The manuscript is self-contained at the level of a conventional research proof apart from its explicitly cited standard sigmoidal VC-dimension theorem and standard Gaussian/matrix facts. The separate scratch audit records provide additional detail, not missing hypotheses needed to interpret its main theorem.
