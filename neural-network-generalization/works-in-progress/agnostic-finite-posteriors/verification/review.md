# Independent review of the finite Gaussian tanh oracle paper

Reviewed 18 November 2026 (UTC) by a mathematical-review agent separate from the principal derivation agents. This review covers the assembled manuscript and its current theorem/proof correspondence. It is not a Lean formalization or external human peer review.

## Verdict and current claims

I found no substantive mathematical gap in the assembled results. The paper proves coefficient-one squared-risk comparisons for actual finite Gaussian posteriors, with ordinary raw posterior means and posterior-averaged raw risk. The data law is arbitrary on the stated bounded input and label spaces. Comparator width and weight cap are specified; exact realizability and a correct noise model are not assumed.

The strongest common theorem uses the original fixed Gaussian prefactor and one sample event for every gamma at least one and every learner width above the comparator width. With `v_H=2^(H+1)` and `b_H=max(1,(H-1)/2)`, its sample budget is proportional, up to the displayed logarithms and dimension factor, to `lambda^(-(v_H+2b_H))*epsilon^(-3)`. At fixed comparator resources it gives the rate `n^(-1/(v_H+2b_H+3))`, up to logarithms. Separate theorems retain the faster mean-field rate `n^(-1/(v_H+3))`, the stronger-scale rate `n^(-1/H)`, and the shallow square-root rate. The growing-class exponents in the introduction agree with the corresponding energy and calibration arguments.

## Norm capacity, fixed scales, and spectral energy

I checked the capacity proof with the statistical energy `Q_N^+`, which omits first-layer weights. First-layer tanh ridges are controlled by affine-halfspace dimension. Variable clipping increases Rademacher complexity by the displayed additive term, and the positive tanh mixture identity propagates the feature class. Internal Frobenius norms and readout energy then give the stated width-independent capacity bound. The first-layer Gaussian remains part of the actual model and of the full teacher implementation cost.

The fixed-scale posterior theorem correctly separates the after-first-layer Gaussian parameter count used in its statistical tail from the full parameter count used in the Gaussian teacher comparison. The raw objective tail is weighted by output energy. Its smooth-loss shell terms fit the retained energy debit; the single-hidden-layer case uses a separate Young-inequality calibration. Exact cloning and the Gaussian comparison are valid at every larger integer width.

Hard spectral truncation removes the typical internal Gaussian operator-norm bulk. Its retained energy has the claimed exponential moment, and the truncation error recurrence uses bounded actual hidden activations. The raw-risk transfer first bounds the truncated population risk, then applies the triangle inequality in loss norm. The resulting sufficient effective-scale exponent is `b_H`, as stated. The first-layer variance extension is valid because statistical energy and truncation leave that layer unrestricted, while its teacher translation cost only decreases.

## Mean-field and scaled covariance covers

The entropy-ball cover was audited independently from its posterior application. Its moment sets are compact and convex, including singular covariance references. The support-function duality, truncated scalar dual, and Gaussian log-partition derivative give the stated square-root covariance stability. The strictly regularized bounded dual supplies a continuous choice of a nearby tilt with bounded entropy.

The adaptive covariance sampler stops after a failed prefix instead of conditioning on success. Its relative entropy is therefore exactly controlled by the chain rule without an omitted conditioning cost. The approximate-readout quadratic program has the original readout as a feasible point, giving the additional quadratic bound needed for its Gaussian entropy. One common auxiliary Gaussian measure and disjoint-ball counting produce a deterministic cover independent of learner width. The auxiliary architecture is solely a proof device.

For varying scale tau, normalizing relative entropy by `tau²` makes the covariance stability constants uniform. The normalized sparse certificate has probability speed `N/tau²` and a learner-width threshold independent of tau. I checked the common finite-grid cover, including the uniform bound on tilted Gaussian coordinates and the unequal-layer parameter count.

Above a scale cutoff kappa, a more efficient cover uses a geometric grid of Gaussian scales on one fixed auxiliary architecture. A grid Gaussian with slightly larger variance pointwise dominates the desired Gaussian up to a factor at least `exp(-1)`. Consequently an auxiliary finite mixture supplies a common entropy-counting measure, costing only the displayed `kappa^(-2)` factor and logarithmic grid term. No mixture is introduced into the actual learner.

## Raw posterior integration and one event for all scales

The multiscale complexity does not require nested good sets: twice the largest failed level ensures membership at the next level, while the top failed state is treated by a weighted posterior tail. Its exponential prior moment gives exactly the entropy debit used to pay the finite-cover statistical deviation. The top-state and high-empirical-risk tails control raw population risk, not merely posterior probability.

The small-width PAC--Bayes bound preserves coefficient one on comparator risk by paying the Catoni factor's excess with the posterior's own variational objective, bounded by two. Auxiliary clipping is removed by a weighted Gaussian readout tail.

The simultaneous-scale version is valid. It uses one auxiliary reference mixture and a fixed inverse temperature corresponding to the smallest allowed scale. This makes the KL coefficient no larger than the true posterior's coefficient at every other scale. Thus the same objective bound remains available. The scale-grid confidence term is uniformly bounded after the countable union over widths. Its sample event covers the continuum of scales directly, without an uncountable union bound.

The final theorem splits scales at `kappa=c_H lambda^b_H`. Spectral truncation handles smaller scales; the common entropy cover handles larger scales at sufficiently large width; the simultaneous PAC--Bayes event handles the remaining widths. Substituting the cover threshold gives the exact final sample power `lambda^(-(v_H+2b_H))*epsilon^(-3)`. All probability events are common to the stated widths and prior exponents. The effective-energy risk budget is bounded independently of input dimension under the final sample condition, so the cutoff constant can indeed depend only on hidden depth.

## Integration and presentation checks

The full prior energy, auxiliary energies, hidden-layer count, total depth, Gaussian variances, likelihood temperature, and prediction conventions are consistent across the assembled sections. Teacher costs remain full-energy costs even when capacity ignores first-layer energy. Every ordinary-mean claim is supported by finite raw second moments and Jensen. A population-best comparator is selected before sampling from a specified compact class; no unjustified common event over unknown data laws or every conceivable comparator class is asserted.

The introduction distinguishes fixed-prefactor results from sample-dependent prefactor schedules and lists the stronger endpoint rates separately from the common all-exponent rate. Theorems do not claim efficient inference, interpolation of noisy labels, a depth-polynomial unrestricted bound, or a learner prior over architectures. Two minor fresh-reader wording corrections were reported and applied: the tanh `n^(-1/H)` rate is no longer called optimal or “sharp” without an optimality theorem, and precise section references now identify the spectral argument. These do not alter the mathematics.

The source-hash manifest accompanying this review records the exact assembled files checked, including the width-only appendix reviewed below.


## Width-only obstruction appendix

I checked the complete added `width-only.tex` appendix. The finite-temperature moment argument is valid for any prior with the stated uniform output second moment and squared Lipschitz moment. Jensen supplies a sample-uniform evidence lower bound; domination by the prior bounds posterior expected sensitivity. The two close inner points then force the claimed risk lower bound for the ordinary mean, both clipped-mean conventions, and raw or clipped Gibbs risk. The two outer zero-labeled anchors keep input variance bounded below independently of their inner separation.

The width-two tanh construction fits all four support points exactly: the ratio of the two chain outputs cancels at the outer anchor, and its inner normalization stays positive as the separation shrinks. The width-four ReLU tent is exact and globally bounded. Gaussian network moments satisfy the appendix assumptions by polynomial moment bounds at each finite architecture.

The order of quantifiers is correctly stated. At each sample size the finite architecture, Gaussian prior, and finite positive temperature are chosen before the close-pair law. The law and unrestricted-coefficient teacher may vary with sample size. Thus this is a fixed-dimension, noiseless obstruction to a distribution-uniform width-only remainder for prescribed finite calibrations. It does not claim one law defeats every temperature, does not cover unbounded adaptive responses to the observed separation, and does not interchange this construction with a zero-temperature or strong-prior limit. These qualifications distinguish it from the separate all-temperature noisy counterexample.

## Final refinements and model interpretations

The two-hidden-layer refinement in `two-layer-refinement.tex` is valid. The exact spectral approximation error is `8 tau sqrt(q)`. On the low-objective region this is small enough to establish the same truncated population-risk budget. Young's inequality bounds loss transfer by `lambda q/16+9216 M tau²/lambda`. Choosing the scale cutoff proportional to `sqrt(lambda epsilon)` therefore pays the transfer with epsilon. The common-cover and small-width budgets become `lambda^(-9) epsilon^(-3)` and `lambda^(-9) epsilon^(-4)`; the latter dominates. This improves the joint growing width/weight range to `alpha<1/36`, and the fixed-weight width range to `alpha<1/18`, while preserving the fixed-resource exponent `1/13`.

The unit-circle version of the width-only appendix also checks. Its close pair retains distance `2eta`, the teacher ignores the second coordinate, and the centered covariance is exactly `diag((1+eta²)/2,(1-eta²)/4)`, with eigenvalues at least `3/16` for `eta<=1/2`. The same finite Gaussian moment and evidence argument applies in this fixed two-dimensional unit-norm domain.

Finally, the internally biased tanh teacher compilation is exact when all original weights and biases are bounded by B at least one. A constant neuron of value one half uses first preactivation `atanh(1/2)` and subsequent self-edge `log 3`. Each internal or readout bias becomes an edge of weight twice that bias. The resulting teacher has width increased by one, the same depth, and coefficient cap at most `2B`; the learner prior is unchanged. The explicit original-weight bound was clarified before the final review because bounding only the biases would not imply the compiled coefficient cap.
