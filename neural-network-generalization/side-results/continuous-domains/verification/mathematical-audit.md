# Independent audit of the continuous-domain extension

Audit by a separate mathematical-review agent, 18 October 2026. This is a conventional proof review, not a Lean verification. Reviewed `regression.md`, `classification.md`, `meanfield.md`, and the finite-covariance/finite-realization lemmas in the published non-Gaussian paper. A final assembled-manuscript check is still appropriate.

## Verdict

I find no substantive gap in the proposed continuous-score regression theorem for the strong-prior limit, each fixed gamma > 1, or gamma = 1. The result concerns the actual finite-width parameter posterior, with no global output-margin conditioning, and covers every learner width at least the teacher width. The necessary quantitative parameters include the teacher's weight bound and positive training tolerance. The binary-label corollary requires a positive signed margin on the distribution's support.

The central continuous-domain move is sound: a finite input net is used only inside a proof of a statistical cover. Nearest-net-point extensions of finite network evaluations are legitimate measurable cover centers. They need not themselves be neural networks or be continuous. Consequently there is no circular requirement that the compressed network have a Lipschitz constant compatible with the net chosen before compression.

## Common posterior lemma

Let U be a positive-mass uniform rho tube around the target and let E have raw-prior mass at most epsilon times mu(U)/6. On compact X, U is open in the finite-dimensional parameter space because parameter-to-output maps are continuous in the uniform norm. The posterior training normalizer is at least mu(U) for every possible data sample, so posterior(E) <= epsilon/6 deterministically; this step neither depends on sample size nor introduces a distribution-dependent width threshold.

If the remaining outputs have a finite uniform a-cover with 2a < tau-rho, then every fitted output corresponding to center h avoids A_h={|h-f|>rho+a} at every training point, and every test error {|z-f|>tau} lies in A_h. The finite union bound gives risk <= epsilon/6 outside E, and hence Gibbs risk <= epsilon/3. Fubini and Markov then bound the mass of inputs whose actual posterior correct-output probability is <=2/3 by epsilon. This handles posterior mixtures, not just individual minimizers or posterior means.

The fallback at widths below a polynomial threshold is equally sound: integrate the at-most exp(-n epsilon/6) training-survival probability of any parameter of test risk >epsilon/6, then apply Markov using the deterministic denominator lower bound. This yields n >= (6/epsilon)[A + log(6/(epsilon delta))] when mu(U)>=exp(-A), with no need for atoms at individual functions.

## Measurability and input nets

For a compact subset X of the unit ball, a maximal r-separated set gives a finite r-net of cardinality at most (1+2/r)^d. A fixed ordering and nearest-point tie break give a Borel map T:X->S. Thus q(T(x)) is Borel for every finite network q. Uniform sup distances between a continuous network z_w and a fixed bounded cover center are measurable, in fact continuous in w: the change in such a distance is bounded by ||z_w-z_w'||_infinity. All posterior integrals and sample-probability interchanges used here therefore satisfy the relevant measurability requirements for arbitrary Borel D. No density or lower bound on support masses is used.

If the optional extension to X contained in [-1,1]^d is stated, its covering cardinality should use radius sqrt(d), or a coordinate grid, rather than repeat the unit-ball bound literally. This changes only polynomial dimension factors. The unit-ball and sphere theorem as stated has no issue.

## Strong prior

Balanced cloning exactly preserves a real-valued teacher on all real inputs. For teacher width C and weight bound B>=1, every N>=C has a clone of energy at most d(d+1)B^2+2(L-1)C^2B^2. For Gaussian coordinates, fixed-N small-noise large deviations lower-bound the uniform teacher tube by rate at most this energy/2 and upper-bound an energy tail at K by rate at least K/2. Choosing K strictly larger than the teacher bound makes the tail/tube ratio vanish.

The strong-prior scale threshold may depend on N, the target, rho and epsilon. It does not need to depend on the input distribution, sample size, confidence delta, or the test tolerance. This order of quantifiers is supported by the proof. Under two-sided quadratic envelopes, replace K by a constant larger than the envelope ratio times the teacher energy. Width-dependent density prefactors are harmless because N is fixed before the scale tends to zero.

Energy gives the width-independent Lipschitz estimate K^(L/2)/sqrt(d). Neuron sampling on a finite input net uses only log of the net size. Subsequent parameter rounding gives a common finite cover over all original learner widths. The proof also covers L=2, when internal matrices are absent.

## Uniform finite-scale teacher tube

The translated-cylinder construction extends uniformly to bounded real inputs. Its residual internal matrix annihilates the cloned teacher's group-constant activation vectors, while the group-projection constraints control the remaining action. With separate width C and weight bound B, the internal clone norm is at most sqrt(2)CB and the readout norm multiplied by sqrt(N) is at most sqrt(2)CB. These give a fixed-depth polynomial stability factor.

Choosing the standardized cylinder radius proportional to rho divided by that factor gives log tube probability at least -A N^gamma, where A is polynomially bounded in d,C,B,1+log^+(1/rho) for fixed depth and fixed coordinate law. Evenness cancels the score term under symmetric conditioning; the upper curvature bound controls translation cost. Strong convexity after convex cylinder conditioning supplies the sub-Gaussian operator-norm estimate. Neither net cardinality nor sample size enters this denominator estimate.

## Gamma > 1

The singular-value truncation event is independent of a finite input list. On that event, write an original internal matrix as its retained large-singular-value part plus a remainder of operator norm at most b. Propagating the discrepancy using the retained part's norm and the original bounded activations gives e_j <= sqrt(K)e_(j-1)+b sqrt(N). The final readout yields a uniform output error controlled by a polynomial in K times b. This is enough for a regression cover; no sign preservation on unsampled inputs is asserted or needed.

The exceptional mass is exp(-c K N^gamma), so comparison to the teacher tube exp(-A N^gamma) gives a deterministic posterior bound after choosing K >= (A+log(1/epsilon))/c. All width thresholds are polynomial in the stated parameters for fixed gamma>1. The low-width fallback therefore supplies every N>=C. Polynomial degrees may grow without bound as gamma approaches one; the endpoint proof is separate.

## Gamma = 1: the new arbitrary-output step

The stated bounded-dual lemma is correct. For z=Hv with N||v||^2<=K, minimize N||u||^2/2 subject to ||Hu-z||_infinity<=t. The supplied point v is strictly feasible for t>0, so finite-dimensional convex KKT applies. With a suitable signed multiplier beta,

    Nu=H^T beta,
    t||beta||_1 = beta^T z-N||u||^2
                  <= sqrt(K) r-r^2 <= K/4,
    r=sqrt(N)||u||.

The two opposite multipliers at a coordinate cannot both be active because t>0. Thus ||beta||_1<=K/(4t), and Q beta=Hu approximates arbitrary output z within t. This removes the Boolean sign-margin hypothesis from the finite-domain readout argument without changing the posterior.

The prior Lipschitz event also has the necessary failure probability exp(-cNK): a Frobenius bound on the first layer, operator-norm bounds on internal layers, and a readout norm bound suffice. These are weaker than bounding every internal Frobenius norm, and hold under the independent bounded-curvature coordinate laws. Choose the fixed-law baseline for K to be at least two as well as large enough for the displayed tail bounds.

Sparse covariance certificates on s net points use log(2s^2+1), not s, in their width threshold. Relative Lindeberg compares log partition functions under the actual non-Gaussian internal row law and the Gaussian proxy law. The first-layer law remains the actual non-Gaussian law. The covariance proxy is a proof device, not a replacement posterior.

With t=a/4 the multiplier norm is at most K/a. The proposed backward tilt-budget recursion produces covariance error at most a^2/(8K), hence at most a/8 output error. Finite realization and rounding each contribute at most a/8. The original output varies by at most a/4 off the input net. Together with the initial a/4 readout approximation, total error is 7a/8. All realization widths, weight bounds and counting exponents have fixed-depth polynomial majorants independent of the original width. This verifies the endpoint cover and rules out the main suspected circularity.

The statement allowing a=1 is harmless if desired: every estimate remains valid. Alternatively choose a=min(1/2,(tau-rho)/4) consistently so that the strict 0<a<1 cover statement applies verbatim.

## Scope that must remain explicit

- Regression observes clean real scores f(X_i) and uses positive tolerance rho. It is not a theorem about exact equality conditioning on real-valued outputs.
- The proof controls teacher width and teacher weight magnitude (or the paper's earlier complexity convention that bounds both). It does not prove pure-width learning for arbitrarily large teacher weights.
- Binary labels can use the same results if a teacher has a positive signed margin on the data support. A nonconstant continuous teacher cannot have such a margin everywhere on a connected sphere. Dropping the original global-margin prior does not by itself solve the unrestricted full-sphere binary-label problem.
- The separate width-one halfspace observation is valid, but it does not prove the all-width nonlinear theorem without a support margin.
- No polynomial depth dependence, efficient posterior algorithm, arbitrary noise result, or Lean verification is established here.

## Additional exact-fit strong-limit corollary

The proposed exact-interpolation corollary is also sound, provided the order of limits is named explicitly. For a Gaussian strong prior at fixed finite learner width, fix rho>0 and let sigma tend to zero in the posterior conditioned on training errors <rho. The same global teacher tube gives, for every eta>0, vanishing posterior mass outside {kappa<=B+eta}. This implies tightness and forces every weak cluster point to be supported on {kappa<=B}. The training constraints close to errors <=rho under weak convergence.

Now take rho down to zero through any sequence of such inner cluster points. They are all supported on one compact ellipsoid. Every outer cluster point is therefore supported on exact interpolants of energy <=B. A single common finite-cover sample event controls every exact interpolant in that energy class, simultaneously across widths, and hence controls each such posterior limit. No separate semicontinuity passage for the test loss is needed. Under two-sided quadratic envelopes, replace B by (b/a)B; the conclusion still has polynomial complexity.

For comparison, a minimum-energy exact interpolant exists because the exact-fit constraints are closed and the energy is coercive. Its energy is at most the exact teacher clone's B, so it satisfies the same learning bound directly. This does not claim that arbitrary equality-conditioned posteriors at a fixed nonzero prior scale satisfy the result. Reversing the order of the zero-tolerance and strong-prior limits remains outside the argument.

For Gaussian coordinates the exact-limit conclusion strengthens to actual minimum-energy interpolation. Let b_rho be the infimum of kappa over the strict training-tolerance event. Inner strong-prior limits are supported on kappa=b_rho: the lower energy exclusion is deterministic, and an open neighborhood of an almost-minimizer supplies the matching upper large-deviation bound. As rho decreases, b_rho increases to the minimum energy b_0 of an exact interpolant. To prove equality of this monotone limit with b_0, take almost-minimizers in shrinking tubes; their energies are bounded by b_0+1, so compactness gives an exact-fitting limit of energy no greater than lim b_rho. Outer posterior limits therefore consist entirely of minimum-energy exact interpolants. It is unnecessary to identify the closure of a strict tolerance event with all of its non-strict constraints; the obvious inclusion suffices.
