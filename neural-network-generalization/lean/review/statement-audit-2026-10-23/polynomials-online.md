# Statement audit: improved polynomials, shallow learning, and online upper bounds

Reviewed against publication commit `7c69c4abe5f93476d59c95b4d04d13b33ff01301` on 23 October 2026. This is a fresh comparison of the manuscript statements with the Lean declarations and their underlying definitions. It is not a new full proof rebuild or a claim of human peer review.

## Findings

- **Improved original-support polynomial theorem:** the probability model, support, learning conclusion, quantifiers, polynomial depth dependence, and sixth-power width rate agree. There is a **target-width convention qualification**: Lean requires a reserved constant `+1` wire at every stage. The manuscript merely says to count the constant wires required by the implementation. In particular, an ordinary width-one circuit computing a nonconstant literal is not represented at width one in Lean. The formal all-width threshold must use the width under the reserved-wire convention. The earlier robust paper explicitly acknowledges this issue; this improved paper's verification description needs the same qualification.
- **Shallow theorem:** all three displayed sufficient sample budgets match, including their exact constants, arbitrary teacher weights, four combinations of support switches, and one common sample event for every width and scale. No substantive mismatch found.
- **Online upper bounds:** the main finite-class theorem and the three neural applications match, when the named main endpoints are read together with the separate small-width direct-cost statements and generic prediction-conversion lemmas. No substantive mismatch found in those main claims. The unrestricted adaptive-query sampled-tail extension remains outside the formal packaging; the certified neural protocols are uniform permutations and uniform IID inputs.

The improved paper's separately printed numerical `16/epsilon` allocation remains outside certification, as already recorded. Its existential polynomial theorem and asymptotic exponents are not affected by that numerical distinction.

## Improved bounds under the original support

Manuscript: `works-in-progress/improved-polynomials/original-support-all-scales/source/learning-theorem.tex`, especially the model and theorem at lines 3–126. Formal endpoints: `BatchTwoImprovedLearningMain.lean:69`, `BatchTwoImprovedLearningWidthGrowth.lean:111`, `BatchTwoImprovedLearningPolynomial.lean:68`, and the optional global-margin counterpart `BatchTwoImprovedLearningGlobalPolynomial.lean:10`.

The model comparison is literal:

- Lean's `r` counts internal hidden-to-hidden matrices, so `H=r+1` and `L=r+2`. The constant input coordinate is first rather than last; this is just a coordinate permutation.
- `Model.lean:33–46` gives first/internal/readout variances `N sigma^2/d`, `sigma^2`, and `sigma^2/N`. Substituting `sigma=t/sqrt(N)` gives exactly `t^2/d`, `t^2/N`, and `t^2/N^2`. Positivity and `N sigma^2 <= 1` are equivalent to the manuscript's positive `t <= 1` at the admitted widths.
- `RobustModel.lean:24–62` defines the simultaneous squared RMS budget, perturbations added after every activation and to the scalar readout, clipping at `±1/2`, radius `c/sqrt(1+H E_v)`, and tolerance `1/16`. There is no unstated restriction that perturbed activations remain bounded.
- `RobustPosterior.lean:15–25` conditions the actual Gaussian on the intersection of that support with the strict training-margin event. The theorem proves the intersection has positive probability. It cannot obtain a vacuous risk bound from conditioning on a null event.
- `RobustConfidence.lean:42–49` defines the correct-margin probability and the posterior-averaged weak test-error event `f(x) z_w(x) <= 1/4`, exactly as in the manuscript.

The universal multiplier in the degree-46 endpoint is chosen before dimension, width, depth, calibration, statistical parameters, circuit, and input distribution. The good sample event is chosen before learner width and prior scale. Thus the formal theorem does not exchange the manuscript's simultaneous all-width event for separate events. Its Gibbs risk is at most `epsilon/3` and its confidence-failure mass is at most `epsilon`, which is stronger than the main manuscript Gibbs-risk conclusion for the same requested accuracy after the existential polynomial is enlarged. The fixed-parameter rate uses `C^6 (1+log C)^13`, equivalent to the displayed `O(C^6 log^13(C+2))` for positive integer widths.

### Reserved constant-wire qualification

The manuscript's circuit definition at `learning-theorem.tex:79–85` allows NAND, copies and negations, says that constants required by internal gates count toward `C`, and has a final output wire. The actual Lean structure in `RobustCircuit.lean:86–93` additionally has a field `constant : Fin C`, forces that slot to copy the constant input at the first stage, and forces it to copy itself thereafter. At `C=1`, that slot is also the only possible output, so only the constant positive function is represented. A circuit that just copies `x_1` through every stage is a concrete counterexample to literal equality of the two width-one target classes.

One may state the formal theorem using the compiled width with a reserved constant wire. Adding a constant wire gives a width-at-most-`C+1` representation of any circuit under the broader convention, and at most doubles positive width, so it preserves the polynomial complexity rate. It does **not** by itself certify the exact learner-width range `N >= C` in the broader convention. The source comparison does not claim a formal same-width compilation theorem for every circuit in that broader class.

The separate numerical sufficient condition in `source/explicit-budget.tex` is also not the formal endpoint's threshold. `all_width_all_scale_learning` uses `200*(entropy+log(1/delta)) <= n*epsilon` and a different finite-class construction with larger internal constants. The `16/epsilon` formula, its particular `J`, and the precise failure allocations therefore must remain explicitly excluded. This is already stated in the public theorem map and source.

## One hidden layer

Manuscript: `works-in-progress/improved-polynomials/shallow/source/paper.tex:40–121, 493–507`. Formal endpoints:

| Manuscript threshold | Lean statement |
|---|---|
| `16/epsilon * (m h_d + log(1/delta))` | `BatchTwoShallow.shallow_all_width_all_scale`, `BatchTwoShallowMain.lean:49` |
| `64/epsilon * (m(d+1)log(2 e n) + log(4(m+2)/delta))` | `shallow_sharp_all_width_all_scale`, `BatchTwoShallowSharpMain.lean:100` |
| `ceil(4 T log(8 e T))` | `shallow_explicit_sharp_all_width_all_scale`, same file, line 134 |

I checked the scalar definitions, not only theorem names. `BatchTwoShallowTeacher.lean:13–39` defines the two first-layer energy bounds, their minimum `U`, and the readout squared norm. `BatchTwoShallowTarget.lean:14–19` is the printed radius and cost `D_*`; its lines 67–71 give the support switches and scale `s=3` or `2c+3`. `BatchTwoShallowPosterior.lean:49–52` gives `B^2=8(D_*+log(4/epsilon))`. `BatchTwoShallowMain.lean:14–20` gives exactly `m=ceil(512 B^2 log(24/epsilon))`, `h_d`, and the first threshold. The other two thresholds and `T` are defined at `BatchTwoShallowSharpMain.lean:13–20`.

The teacher hypothesis is an actual real weight vector with strict signed margin on every Boolean input. It does not assume bounded coefficients until the separate resource corollaries. The `robust` and `global` Boolean flags cover raw Gaussian, global-margin only, robust-only, and both conditions. All these posteriors use strict training margin `>1/2` and weak test error `<=1/4`. `posterior_eq_twoStage` in `BatchTwoShallowPriorConventions.lean:10` identifies intersection conditioning with the intended two-stage procedure. The nuisance `c>0` parameter in the nonrobust cases does not restrict those learners because both their cost and prior are then independent of `c`.

The actual IID law allows arbitrary input distributions. The existential measurable good event precedes both universal width and universal scale quantifiers. Positive posterior normalizers are part of the conclusion. The ordinary raw and robust-only cases are not silently converted into globally margin-conditioned learners, nor is Gibbs risk replaced by posterior-mean prediction.

The separate `C^2` corollary assumes readout coefficients bounded by an independent fixed `V`; the `C^4` corollary permits readout weights as large as `C`. These are different teacher classes, as stated in the manuscript. The sharper dimension bound retains its logarithmic width factors.

## Polynomial total online mistakes

Manuscript: `works-in-progress/online-mistakes/upper/source/paper.tex:42–120, 198–216, 224–350, 499–551`.

### Actual protocol and prediction variables

`BatchTwoOnlineFiniteMain.lean:21–25` gives precisely

`B_E = 1 + 2(h+1) H_(m-1) + m beta`

and

`U_delta = (e-1) [1 + 2(h+log(2m/delta)) H_(m-1) + m beta] + log(2/delta)`.

`random_order_cumulative_errors` in that file includes equality of expected posterior error and actual posterior-sampled error, plus the two separate probability bounds. `BatchTwoOnlineMain.lean:66` combines the uniform permutation and infinite uniform IID conclusions. `RandomOrderBounds` and `InfiniteIIDBounds` unfold to actual expectations and tail events, not assumptions called by those names. The latter's equality of expectations is explicit. The learner reveals every label and retains all consistency constraints.

`BatchTwoOnlineIIDSampledInfinite.lean:15–32` constructs fresh posterior draws as an infinite product of the successive consistency posteriors conditional on the query sequence, and defines total sampled mistakes as the sum of actual zero-one errors. `iidQueryLaw` is the independent uniform query law. This is suitable for the two stated protocols; it does not encode an adaptive input policy that observes previous posterior draws.

`FunctionPrior.lean:70–95` uses each actual Gaussian global-margin sign-function mass. Its global normalizer cancels on conditioning. `BatchTwoOnlineNetwork.lean:43` and the corresponding infinite-history theorem identify these consistency posteriors with the neural posterior. The learner is not a selected minimizer or a posterior mean. Confidence failures use the weak inequality on correct-label probability, and the generic confidence theorems establish the `1/(1-theta)` conversion; majority errors are controlled with factor two, including ties.

### Neural endpoints and literal scalar budgets

- `BatchTwoOnlineSharpMain.lean:86` chooses one positive `sigma_0` at fixed `d,C,N,r`, target and activation, before any query stream or confidence parameter. It supplies every smaller positive variance for both complete protocols. `normCapacity(d,r,teacherBudget(d,C,r))` is the displayed `F_L(d,B_L(d,C))`.
- `BatchTwoOnlineSharpNeuralMain.lean:61` has the specified positive power prior for every fixed `gamma>1`, every eligible width, and the exact threshold `T`. `onlineEnergy`, `powerWidthThreshold`, `normRho`, `normWidth`, and `normLogCount` in the corresponding `BatchTwoOnlineSharp*` modules match the printed `K`, `T`, and `F_L`; `targetCost` in `BatchTwoOnlineSharpCylinderTeacher.lean:12–17` matches `A_L`.
- `BatchTwoOnlineSharpNeuralMain.lean:99` uses the actual `gamma=1` tanh prior. `BatchTwoOnlineMeanFieldExactBudgets.lean:15–40` reproduces the real-valued backward recursion, `T_L`, `G_L`, and all ceiling/logarithm terms. There is no limit replacing finite-variance mean field.

The low-width branches need a small reading qualification: the combined `NetworkOnlineBounds` declaration inserts `J` into a common harmonic-capacity wrapper, giving a deliberately looser bound. The literal smaller direct cost `S <= J` is separately proved by `aboveMeanField_small_total_paper` and `meanField_small_total_paper` at lines 26 and 85, for every entire fixed query stream. The exact direct sampled tail is the generic `BatchTwoOnlineMain.infinite_sampled_prior_tail` at line 83, and finite sampled tails are in `BatchTwoOnlineExponential.lean`; expectation equality is proved for the actual product sampling law. Reading the combined wrapper alone as the manuscript's exact small-width direct-cost formula would be inaccurate. The relevant additional statements are present, so this is a packaging distinction, not a missing neural analytic bound.

The above-mean-field and strong-prior activation hypothesis unfolds to a bounded-by-one, one-Lipschitz activation, matching the imported bounded-activation setting. The mean-field endpoint is explicitly tanh. `realizesAtComplexity` requests an implementation at width `C` with weights at most `C`, rather than requiring `C` to be the minimum; it therefore implies the manuscript's minimum-complexity specialization and is slightly more general. All width bounds are for each fixed learner with common numerical budgets, not a simultaneous event for infinitely many independent posterior-sampling runs, as the paper itself specifies.

The optional ReLU constants, all raw merging sampled-tail extensions, function-MAP remarks, limiting-law remarks, and sampled tails for input policies adapted to previous draws are not promoted to part of this main-statement check.

## Documentation resolution

The improved original-support paper's status paragraph, its README, the FAQ and the coverage record now explicitly state the formal reserved-constant-wire convention and the excluded width-one cases. Its proof and Lean statements are unchanged. The separate numerical allocation remains excluded.
