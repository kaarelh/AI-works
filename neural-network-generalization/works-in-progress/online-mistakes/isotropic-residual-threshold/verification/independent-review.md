# Independent mathematical and statement-correspondence review

Reviewed 6 November 2026 by the geometry research agent, independently of the manuscript author. The full two-file source was read and checked. This is an AI mathematical audit, not Lean verification. No mathematical correction remains outstanding.

## Scope checked

The learner uses the unchanged canonical coordinate-isotropic Gaussian prior on a single hidden layer, including the appended constant coordinate, with initial full-cube absolute margin and exact revealed labels. The activations are fixed discontinuous threshold-residual functions. The bounded theorem covers sign(t)+c*tanh(t) for every fixed 0<c<=1. Ordinary tanh, ReLU, and hardtanh are explicitly outside the theorem.

The main statement correctly distinguishes: every fixed N>=1 followed by the strong-prior limit; every fixed gamma>1 and tau>0 followed by N tending to infinity; and sufficiently small tau giving the designated mistake probability uniformly over every N>=1 and every gamma>=1. Its width-one teacher has weights bounded by one and strict signed output greater than one. The designated input sequence is fixed, has no repeated points, has O(k) calibration examples, and supplies 2^k-k-1 mistakes. No choice among tied predictors enters the argument.

## Exact energy inequalities

Checked the active affine KKT probabilities, the sign-plus-linear Cauchy inequality, scalar attainment at every width, strict monotonicity of the profile, and the gap below 1/4.

Independently derived and checked the bounded-residual dual. The affine unit-margin norm gives dQ>=1/2. The scalar optimum has r<=c/(4dQ)<=1/2. The tangent intercept alpha>=1 and slope beta<=1 imply the two-sided tangent bound for all scores in [-sqrt(2),sqrt(2)]. Small-norm atoms satisfy the KKT tangent bound; large-norm atoms have nonnegative dual floor by boundedness. The quadratic minimum is attained at the stated scalar radius, with leading coefficient at least 1/4 and floor -alpha/(4h^3)<0. Cloning attains the exact bound. The zero-mean convex-hull argument gives the nonthreshold energy floor 1/4 for both activations.

## Selector and actual posterior

Checked every calibration constraint, the transformed affine variables, the induction forcing binary weights, the unique convex affine norm Q_t, full-cube odd-integer margin, and the increment Q_(t+1)-Q_t=4(t+1). The Boolean circuit upper and essential-input lower bounds establish Theta(k).

The posterior proof correctly avoids invoking continuity across activation jumps. A fixed open row box around an amplified scalar witness remains inside one strict function cell. Its Gaussian product probability is compared with a chi-square energy tail. The logarithmic variance terms cancel exactly, leaving exp[-delta/(2sigma^2)+CN]. The tail condition and all quantifiers for cold, direct-width, and uniform-small-prefactor regimes follow. Correct-next-label competitors are bounded using the enlarged training set, so no compactness or uniqueness assumption is needed.

## IID guarantee

Checked the sample-independent full-target denominator and total nonthreshold-event numerator. The threshold-class count, consistency union bound with error epsilon/4, residual nonthreshold mass epsilon/12, and factor-three confidence conversion give the stated >2/3 guarantee outside mass epsilon. The variance/width thresholds are uniform over target-consistent histories and input distributions.

## Presentation

The final abstract states that the proof uses the jump at zero, rather than suggesting that continuous activations have been ruled out. Authors are alphabetically ordered with the requested footnote.

## Final reviewed snapshots

- `source/paper.tex`: `5eb9104f73f0f07de0605d0f6bc653ad904104b81d73e69bfb1ded52d6cf0a3e`
- `source/selector.tex`: `244bdd04e4000f67356b36032208e70ba5783e6b6f42139aa01fdbc74194f522`
- `paper.pdf`: `1b6a0dba6843adb0db3686746ec46548cd5fdb1564431ccb3c1486e315ba06c0`

Whitespace-only source normalization: one trailing space was removed from `source/selector.tex`; the isolated rebuilt PDF has identical extracted text to the reviewed publication PDF. The source hash above includes that normalization.
