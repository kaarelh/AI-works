# Statement review: the mean-field continuous-depth lower bound

Reviewed against `works-in-progress/continuous-depth-lower-bound/source/meanfield.tex`, Theorem `critical-regression-depth-lower`.

The final endpoint is `BatchTwoContinuousDepthCritical.critical_manuscript_depth_lower_bound`. It chooses one universal positive exponential sample constant and one depth threshold before depth and sample count. The input law is the same fixed nonatomic Borel law supported on the unit circle as in the other two main regimes. The teacher is exactly `depthTarget h`, whose width-three implementation and coefficient bound thirty are proved separately.

The prior is the literal `powerPrior 2 N (h−1) 1`: first-layer variance `1/2`, internal variance `1/N`, readout variance `1/N²`, with `h` hidden layers and total depth `h+1`. Training conditions solely on strict output tolerance `<1/8`; there is no all-input margin or robustness condition. The final result gives sample probability at least `49/50` for both width-liminf conclusions: Gibbs error `>1/4` at least `1/2`, and mass of inputs whose correct-within-`1/4` posterior probability is **strictly less than `2/3`** at least `1/2`.

No energy minimizer, uniqueness, posterior-mean substitution, denominator estimate, or Gaussian approximation is assumed in the final statement. Positive training-event mass holds eventually in width, as proved by the construction. The width-first order of limits is retained; no width threshold uniform in growing depth is claimed.

The proof differs from the manuscript. Direct paired-input high moments bound prior mass of an output change by `exp(−hN/2)`. The actual training-event denominator is at least `exp(−hN/4)` eventually. For that denominator, standardized first-layer shifts build a weak signal at each separated training input. Free Gaussian layers preserve enough signed correlation in a normalized auxiliary channel; logarithmically many constant-cost shifts amplify it, one saturation layer puts it close to the prescribed sign, and an independent Gaussian readout fits the teacher outputs. Every step is an event of the physical network weights. A proved product-law argument multiplies their conditional probabilities; the auxiliary channel is a measurable function of those same weights. The final point-pair argument applies to full posterior mixtures.

The coordinating agent wrote the final assembly and performed this statement review; it is not an independent reimplementation. Earlier independent source reviews remain available in the paper folder. The kernel audit of the final endpoint reports only `propext`, `Classical.choice` and `Quot.sound`. The collection verification record separately records the fresh source build.

Ancillary finite-domain LDP, exact-interpolation, iterated-limit and smooth-density claims are not certified by this endpoint.
