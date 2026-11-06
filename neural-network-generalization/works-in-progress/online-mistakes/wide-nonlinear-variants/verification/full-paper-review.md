# Independent full-manuscript mathematical review

Reviewer: independent geometry agent. Reviewed all six TeX source files of `works-in-progress/online-mistakes/wide-nonlinear-variants` on 2026-11-06, including the theorem statements, proofs, introductions, scope qualifications, and both tanh appendices. No mathematical corrections were found. This is conventional proof checking, not Lean verification.

## Main conclusions

1. The near-identity theorem matches its proof and source note. It permits every fixed width, retains the appended constant coordinate and nonlinear activation at every hidden layer, and treats the actual posterior. The activation's allowed deviation from identity depends exponentially on k and also on L; this limitation is stated prominently and prevents interpreting the theorem as a fixed-standard-activation result. The proof uses only sign preservation, contraction, and relative deviation, so the smooth nonhomogeneous residual-tanh example is correctly included.
2. The one-nonlinear-layer theorem also matches its proof. The absence of an appended constant coordinate and the use of identity activations after the first hidden layer are essential and clearly stated. Equality in the Frobenius lower bound genuinely forces a rank-one first matrix aligned with the effective readout. The resulting scalar output has the required sign under either sign preservation or monotonicity. In particular, the active paired-constraint argument correctly handles ReLU and softplus without assuming that the scalar output is odd.
3. Both theorems cover every N>=C_L=2 at L>=k+2, with no upper width bound. The teacher constructions, the lower bound excluding C_L=1, and padding to additional depth are correct. The sufficient positive sigma may depend on N; the manuscript explicitly avoids exchanging width and small-scale limits.
4. The selector lemma is correct: diagonal and carry constraints give the claimed unique affine minimizer, its global margins are odd integers, and the additional next-query constraint adds at least 4/(d+1) to squared norm by convex projection geometry. The homogenized paired sequence introduces no duplicates and is fixed independently of posterior samples. Only the first point of each new pair is counted, so the paired-history hypothesis is restored before each counted round.
5. The Gaussian energy-gap lemma is valid. An open strict-margin region below the unwanted closed set's attained energy infimum gives the denominator lower bound, while Gaussian small-noise upper bounds control the numerator. This handles the full posterior and mixtures. The finite-round union bound supports the sampled, majority, and confidence conclusions as stated.

## Tanh appendices

* The two-feature shortcut has the asserted signs on all six possible scalar input values. Its feature ratio identity, group replication energy, small-margin estimate, waiting-layer bound, and final amplification count check out. The bound L+89+12 log d<2L holds on the stated k>=128 range. The scalar lower bound uses only contraction and weighted AM-GM and is valid. The appendix correctly does not infer the wider posterior's prediction or lower-bound every wider implementation of the wrong functions.
* The finite-width certificate has the correct group fraction interval [1/95,1/48], full-cube signs, polynomial lower bound tanh(u)>=u-u^3/3, exact energy expression, and convex endpoint reduction. The largest physical coefficient is 2.2<3. The scalar comparison 8(889/4)^(1/8)>15.7 is valid. I independently ran `verification/check_finite_certificate.py`; all exact rational assertions passed. Its displayed decimal values are used only for readability.

## Reviewed source hashes

```
1618166fc74e711f511b427352b23d7ceedb97cb5f778648d0caf4beba169256  source/finite-certificate.tex
0990a1b7a91ec0262f16bd42d4b73c0c3e1fe5599f4434d71c4b1fa7564ba877  source/near-identity.tex
90e565293e17838e1547202468b99cab5d469e82aa70501efbcf1bf4cfc427b3  source/odd-projection.tex
59b6bd8172854f20dcfcf52259fe8b74bb56a406d3176159bf04954718b2e4fa  source/paper.tex
db1b2608affe49c842ddeba1610aefb875ad1a09a4ecf0536dab9d237bea5297  source/selector.tex
de62cd4e0f916abc6a04928514c7c081b6b4f057078a63f08cce168e63ba1af1  source/tanh-obstruction.tex
```

The manuscript is self-contained and accurately leaves the fully nonlinear, biased, fixed-standard-activation, arbitrarily-wide model open. Earlier note-level audits remain useful supplementary checks, but the conclusions above refer to the assembled source snapshot listed here.

## Addendum: iid comparison corollary and final seven-file snapshot

I independently reviewed the new `source/iid-comparison.tex` and the corresponding abstract/conclusion updates. No correction found.

* On the energy ball at U_*, the linearization error is strictly less than 1/2, so every weak-global-margin sign function is affine. Thus the finite union B of nonaffine weak-margin cells is closed and has energy infimum strictly greater than U_* (or is empty).
* The strict full-target cell U_f has energy infimum at most U_*. The ratio P_sigma(B)/P_sigma(U_f) tends to zero. Since every target-consistent history event contains U_f, the same ratio bounds its posterior nonaffine mass uniformly over every possible history. This correctly avoids a sample-size-dependent union bound over histories and proves the stated scale-threshold independence of n and the sampling distribution.
* The affine hyperplane-arrangement count and the finite-class consistency union bound are valid; the stated 2^{1+d(d+1)} cardinality estimate is conservative. Taking rho=epsilon/6 and posterior nonaffine mass <=epsilon/6 gives mean test error <=epsilon/3. Markov then bounds strict-2/3-confidence failures by epsilon and majority errors by 2epsilon/3. Repeated iid inputs cause no issue.
* The resulting sample bound is independent of learner N and L, while the activation choice and sufficiently small scale can depend on them as stated. The same prior/activation/target can satisfy the iid upper and online lower bounds at one common sufficiently small positive sigma.

Final reviewed source snapshot:

```
1618166fc74e711f511b427352b23d7ceedb97cb5f778648d0caf4beba169256  source/finite-certificate.tex
c45552ead958e241a7d5bdc8acdfc393c5b03cee19ea8ee89158b27611663492  source/iid-comparison.tex
0990a1b7a91ec0262f16bd42d4b73c0c3e1fe5599f4434d71c4b1fa7564ba877  source/near-identity.tex
90e565293e17838e1547202468b99cab5d469e82aa70501efbcf1bf4cfc427b3  source/odd-projection.tex
1cccc27328007e12df4ca0ff67b4166ca0fd3eb845a5661dcef0efb48c9a63c2  source/paper.tex
db1b2608affe49c842ddeba1610aefb875ad1a09a4ecf0536dab9d237bea5297  source/selector.tex
de62cd4e0f916abc6a04928514c7c081b6b4f057078a63f08cce168e63ba1af1  source/tanh-obstruction.tex
```

## Addendum: larger activation allowance and exactly half the cube-size suffix

Independently reviewed the integrated Corollary `cor:near-half` and the corresponding iid extension. No mathematical correction found. The final local-notation clarification in the iid proof was also checked.

With t0=2^(k-1)-1, the counted rounds q_{2^(k-1)},...,q_M number exactly 2^(k-1). The original full permutation is retained, so every history before a counted round is the history in the selector lemma. Its next-label norm gap is exactly Q_{t+1}-Q_t=4(t+1)>=2^(k+1). For k>=3 and t>=t0>=3, Q_t-8(t+1)>=35+2t(t-3)>0, which justifies the bound h<1/2. The improved epsilon condition bounds the linearization error by 2^(k+1)/(128Q_*); the displayed lower and upper energy multipliers are strictly separated. The teacher retains C_L=2. The iid proof needs only a linearization error below 1/2 at the full-target candidate energy, so it extends with no change to its sample bound or history-uniform scale argument.

This is an improvement in the allowed perturbation from order 8^(-k) to order 4^(-k), up to the stated polynomial factors. It is still an instance-dependent near-identity activation family. The theorem statement and iid comparison preserve this qualification.

Final reviewed source snapshot after this addition:

```
1618166fc74e711f511b427352b23d7ceedb97cb5f778648d0caf4beba169256  source/finite-certificate.tex
109c379909cda6148b64e315924a781b40f1ad556e7df27c23fbd5f3af8904ae  source/iid-comparison.tex
f57d706e1d006ab426be7fcd612b86da3d7d006046044706ad72d7535b82cb28  source/near-identity.tex
90e565293e17838e1547202468b99cab5d469e82aa70501efbcf1bf4cfc427b3  source/odd-projection.tex
1cccc27328007e12df4ca0ff67b4166ca0fd3eb845a5661dcef0efb48c9a63c2  source/paper.tex
db1b2608affe49c842ddeba1610aefb875ad1a09a4ecf0536dab9d237bea5297  source/selector.tex
de62cd4e0f916abc6a04928514c7c081b6b4f057078a63f08cce168e63ba1af1  source/tanh-obstruction.tex
```
