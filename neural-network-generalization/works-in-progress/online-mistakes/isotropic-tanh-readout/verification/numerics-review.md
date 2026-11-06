# Independent proof review and numerical-work separation

Reviewed on 6 November 2026 by the `wide_numerics` research agent. This is an AI-agent mathematical review, not a Lean formalization or an external human referee report. The reviewer developed the Fourier teacher lemma; a different agent (`wide_tanh`) independently checked that lemma in full. The reviewer independently checked the geometry agent's dual and posterior arguments.

## Conclusion

The statements and proofs in the reviewed source agree, and I found no mathematical gap in the stated modified-prior theorem. The theorem requires the diverging readout correction A_N. It does **not** prove the canonical A_N=1 case, an exponential lower bound at every realizable width, or a polynomial upper bound on the width threshold. The abstract, main theorem, proof, and concluding scope paragraph all preserve these distinctions. The final abstract correctly restricts the claim about unchanged power-law exponents to subpolynomial readout corrections. The final main-theorem IID clause explicitly states the greater-than-two-thirds correctness guarantee, matching the proved IID theorem.

## Checks performed

- **Model and normalization.** Recomputed the substitutions b_j=Nv_j, U_j=sqrt(d/N)u_j, B_j=sqrt(A_N/N)b_j. The whitened dimension is N(d+2), every coordinate has variance tau²N^(-gamma), and the displayed energy is its squared Euclidean norm. The constant input coordinate has the same variance as every other first-layer coordinate.
- **Exact all-width dual theorem.** Checked the KKT weights, the orientation step using oddness, Jensen's inequality only on nonnegative active scores, the bad-atom bound, the scalar stationary equation, strict concavity of tanh²sqrt(v), and the dual equality at the cloned witness. Both explicit saturation inequalities follow from A>=256dQ log(16/p)/p². The theorem bounds every nonlinear competitor satisfying the training margins, without requiring an affine output sign function.
- **Uniform Boolean penalty.** Checked the minimal-support conic KKT representation, linear independence, G mu=1, the integer determinant and Cramer's-rule bounds, and the resulting common penalty1024dQmax³D^(2D)log(32Qmax D^D).
- **Selector geometry and sequence.** Recomputed the u,v,w,s change of variables, all diagonal/carry implications, the use of t>=k, the exact convex minimum Q_t, and Q_(t+1)-Q_t=4(t+1). The wrong witness has full-cube affine margin at least1. The calibration and query blocks are disjoint; there are2^k-k-1>=2^(k-1) designated rounds for k>=3. The Boolean circuit upper bound and essential-input lower bound are valid.
- **Bounded shallow teacher.** Checked both parity cases, the alternating-binomial Fourier coefficient, the odd-integer tanh/sign error sum, the central-binomial induction, the exact signed-feature representation, the Hoeffding constant and union bound, all weight bounds, and the comparator Fourier-l1 bound k+2. The width constant288 is valid. This lemma received a separate complete audit from `wide_tanh`.
- **Direct growing-width posterior comparison.** Recomputed the profile gap, amplified witness energy/slack, whitened output gradient, radius A_N^(-2) ball, Gaussian cube-volume bound, and chi-square upper tail. Keeping dimension times variance together is essential: at gamma=1 the lower volume loss is O(N log A_N), not O(N log N). Thus every A_N tending to infinity works, however slowly. For gamma>1 the N log N term is also dominated. No fixed-width cold limit is substituted for the claimed growing-width result.
- **Actual mistakes.** The comparison bounds the posterior mass of every function assigning the correct next label, not merely one selected rival. A finite union bound gives simultaneous posterior-sampling mistakes; no independence of predictions is assumed. Majority and the strict two-thirds correctness convention follow as stated.
- **IID theorem.** Checked the nonthreshold energy gap, the full-target witness common to every consistent history, the history-uniform posterior mass bound, the threshold-class region count, and the finite-class consistency bound. With consistent threshold errors at most epsilon/4 and nonthreshold mass at most epsilon/12, posterior mean error is at most epsilon/3, so the strict two-thirds criterion fails on at most an epsilon fraction of the test distribution. The width threshold can be independent of the sample and input distribution.

- **Canonical-scaling obstruction.** Independently checked the final proposition: cloning the sampled Fourier teacher into any N>=2n_k preserves its strict-margin function and gives energy at most d(d+1)+2B². Each clone count is at least N/(2n), which bounds the readout term. Every scalar affine witness has energy at least sqrt(dQ_t) by tanh(r)<=r and AM--GM. Thus the true target beats these specific scalar witnesses at all sufficiently large k and widths, while no claim is made about all wide wrong functions.

## Numerical searches are not premises

Separate canonical-prior searches investigated full comparator energies, parity stars, and AND stars. Those searches only provide approximate feasible energies and local searches for dual violations; they do not certify unrestricted global minima. None of their numerical values is used in this paper's theorem or proof. In particular, a k4 comparator energy profile is nonmonotone in those searches, so naive extension of the scalar ordering to the canonical wider tanh model is not claimed.

## Reviewed file hashes

SHA-256:

| File | Hash |
|---|---|
| source/paper.tex | `eab80a2624d7de185f917834e05a175d9d981d3a99f5b030493cc6d7013a5fb2` |
| source/dual.tex | `7f7be0ad477e146261f2d4cc6c08dc25723dfe6070470449a4cf47a5c66d55e1` |
| source/selector.tex | `b64cf59a362f6fd6a923d28143056545db4ee0e8985cbf87d1eb1efd14fdd378` |
| source/teacher.tex | `65fa6474f78d38c0a36af2406c3e0aec5a9eb343ce5f04078bf13b2f7f524d6d` |
| source/posterior.tex | `921f88aaabdf0433c196c3ad73b37d5b74679885890f5e0a2af7a000a7096624` |
| paper.pdf | `71cd027ebc98c94353f43fba9afeacd6a5d5b269f40a8b4be12a480153de67ec` |

A later PDF rebuild can change the PDF hash without changing the mathematics. Any source change should be compared with these reviewed versions.
