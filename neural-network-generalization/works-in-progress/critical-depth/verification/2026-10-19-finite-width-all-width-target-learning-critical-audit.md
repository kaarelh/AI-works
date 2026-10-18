# Independent audit: target-based learning at every realizable width

Reviewed by the critical-depth agent, 2026-10-19.

Source: `source/critical-all-width-target-learning.tex`.

SHA256: `12189cd5401374d9bb6749e9b502fb7c663a99b28fd7853b318b2f0eb967fef3`.

The full section passes this audit without correction. This is a conventional mathematical audit, not Lean verification.

## General transfer and quantifiers

- The stated notion of realizability is equivalent to positive raw strict-margin target mass: a nonzero finite-domain realization can have its readout rescaled to margin strictly greater than one half, after which a sufficiently small open parameter neighborhood preserves all the finitely many inequalities. The Gaussian density is positive on that neighborhood. Conversely positive event mass supplies a realization.
- The quantitative raw mass hypothesis above exp(cT), together with the intrinsic finite-width learning theorem, gives a sample bound exp(CT) times the stated statistical factors. Its resource factors are absorbed because T dominates log(d+L), L>=T, and the target cost is at most 2+cT. The exact-width cost need not be related to the limiting variational rate.
- Below the mass theorem's width threshold, the entire tanh sign class has polynomial VC dimension in d,L,N. Counting its restrictions to the 2^d cube gives logarithmic class size at most exp(CT), so the finite-class consistency bound applies uniformly to the full posterior support. This is a separate small-width argument and does not claim the near-baseline target mass there.
- Positive target mass guarantees nonempty conditioning for every realized training sample. The class count is independent of the sample. Bounding every consistent function's test error by epsilon/3 bounds the posterior's Gibbs error by epsilon/3; the mass where correct-label confidence is at most 2/3 is then at most epsilon, including equality cases.

## Target classes

- Fourier variation: the finite Fourier target-mass result has exactly the needed parameter log((d+L+2) A_F). Signed parity has A_F=1; the tree and binary-state program bounds follow from A_F<=s and A_F<=t+1. Products of resource parameters are absorbed into a fixed power of their sum.
- Bounded threshold circuits: T=log(d+2)+h log(C_T+B+h+L+2) satisfies the transfer hypotheses. The learner-depth condition leaves sufficient continuation depth in the finite circuit mass theorem. Every N>=C_T is indeed realizable: a common sufficiently large gain approximates every Boolean threshold gate on its realized states, constant rails included, and additional layers preserve the final sign using a scalar positive tanh chain.
- Real threshold coefficients: the separately proved small-bit separator and majority-arithmetic compiler has universal polynomial degree and depth O(h). No original coefficient magnitude is hidden in the learning resource. A halfspace is independently realizable at width one at every positive hidden depth, including fixed ties after a finite-domain bias perturbation.
- Bounded-weight analog teachers: the previously audited compiler has depth O(D+1) and a universal polynomial resource bound. Its precision-dependent arithmetic is implemented using majority circuits, so substituting it gives exponent O(D+1), not a polynomial degree depending on the required precision.
- Low-rank teachers: the three-stage box circuit from the audited low-rank construction has logarithmic resources O(log(d+L)+r log(P+r)); its substitution gives precisely the displayed factor (P+r)^(cr). The approximate-rank statement uses the same established 8P/7 product adjustment.
- Solvable groups: the compiler has depth O(ell), universal polynomial resources in q,t, and ell<=log_2 q. Hence its substitution gives R^(c ell). The S_4 corollary has universally bounded order and derived length; it concerns permutation programs, not arbitrary width-four state transition programs.
- Boolean blocking: a block of b fan-in-two layers has at most 2^b relevant entrance bits per output. The full DNF gives two threshold layers with logarithmic width and norm O(log C_T+2^b). Substitution yields the stated U_b. With b comparable to min(h,log log(S+L)), U_b is bounded by C log(S+L)(1+h/log log(S+L)). Layering and standard formula balancing preserve the asserted quasipolynomial order.

The final scope paragraph correctly distinguishes this finite-width blocking parameter from the sharper width-first optimized-prefix parameter. It also correctly leaves joint polynomial learning for arbitrary small deep circuits unresolved. The phrase "at every realizable width" remains essential for general compiled target classes; the stronger explicit N>=C_T assertion is proved only where stated.
