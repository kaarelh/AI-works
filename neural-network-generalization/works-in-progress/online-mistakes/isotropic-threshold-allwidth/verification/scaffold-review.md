# Independent scaffold, posterior, and statement audit

Reviewed on 6 November 2026 by a separate geometry research agent.

Reviewed final sources:

- `source/paper.tex`: SHA256 `b26f6794205abf24ac0a64d94cf526ee7a3426970a3b954f0f2f0a71f98b9d7d`
- `source/volume.tex`: SHA256 `b4fc6eb63be11c0280a9d22eea83668946b65645c4028413e3b193081a05f7af`

**Verdict: the main theorem's stated model, quantifiers, and bounds are supported by the proofs. No mathematical gap found.** This is an independent mathematical review, not a Lean verification.

The audit checked the complete arithmetic scaffold, rather than merely assuming its cone properties. The four-register comparisons give the positive coefficients, near-doubling recurrence, superincreasing low-level separation, and uniform main subset-sum accuracy. The balanced-helper examples bound all pair means relative to their common mode. The two-example helper argument proves every actual helper exceeds the full main coefficient sum. All constraints involving a nonzero total helper sum are lower bounds on the common mode; thus the representation cone really has the claimed product-ray structure. The bounds B=200L², p=20k+200, L=21k+202, d=167k+1617 and epsilon<ell/32 are valid.

The radial integration counts D+1 Gaussian coefficients correctly, uses the variance-two branch biases, and integrates the entire function cone. The power-tail estimate puts at least half the normalized common-mode mass below T0R. Its logarithmic derivative bound yields the adjacent probability ratio 1+ell/4. The geometric-series posterior argument then gives exactly 2^k-2 designated errors, with the stated cold width threshold. The endpoint calibration avoids the unbounded terminal cutoff cell.

The finite-width posterior inequality includes every Boolean output function. Unaligned hidden columns have the asserted correlation deficit, the Gaussian-tail ratio is valid, and the binomial average gives the exact bounds. These imply the cold law proportional to pi(g)^N, the direct limit for every fixed gamma>1 and tau>0, and the gamma=1 conclusion for a sufficiently small fixed tau. The finite number of histories permits one width threshold. The positive-scale result is not incorrectly conflated with the cold width estimate.

The target's one-neuron sign teacher follows by positive rescaling, which is legitimate for this activation. The independent O(k)-gate Boolean implementation is also valid: carry-save addition uses O(H) gates for the helper count and O(L) gates for the bounded number of dyadic source bits at each level; multiplying the count by 2^(L+2)-3 uses shifts and O(L+log H)-bit subtraction. The AND branch makes d-1 inputs essential, giving the matching bounded-fan-in lower bound.

The IID theorem uses a valid finite threshold-class count and a uniform bound on nonthreshold posterior mass through the full target cell. Its width threshold is independent of the sample and the input distribution. The bound concerns posterior-label majority; stronger confidence requirements would require the corresponding constant adjustment, which the statement does not silently claim.

The manuscript correctly states the material limits: discontinuous sign rather than ordinary tanh, an exponential calibration prefix, sufficiently large rather than all realizable widths, and no assertion at the unit mean-field prefactor. The source does not claim that an isotropic tie is broken adversarially or that the tanh question has been solved.
