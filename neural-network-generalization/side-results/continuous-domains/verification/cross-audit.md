# Independent cross-audit: continuous regression and mean field

Reviewer: `/root/continuous_classification` (independent AI-agent mathematical review).

Reviewed the stable `regression.md` and `meanfield.md`, with the inherited proofs in `non-gaussian-priors/source/{norm-compression,sparse-dual,tilt-compression}.tex` available for comparison. This is a conventional mathematical audit, not a formal verification.

**Conclusion:** no substantive mathematical gap found in either continuous-domain extension. In particular, the regression finite-cover posterior lemma, every-width teacher-tube construction with separate width and weight parameters, and the new arbitrary-output QP dual lemma are valid. The notes support a unified fixed-depth theorem covering the strong-prior limit and every fixed finite exponent gamma>=1.

## 1. Posterior lemma and threshold bookkeeping

The regression training constraint is strict error <rho; test error is >tau. If a finite center h approximates a fitted output within a and 2a<tau-rho, then:

- every training point has |h-f|<rho+a;
- every original test error >tau has |h-f|>tau-a>rho+a.

Thus the one finite event A_h={|h-f|>rho+a} is sufficient for both sample survival and control of the original predictor. A union bound eliminates centers with D(A_h)>epsilon/6. The uniform teacher tube lower-bounds the posterior normalizer for **every** data set, so exceptional raw-prior mass <=(epsilon/6)mu(U) gives posterior exceptional mass <=epsilon/6 deterministically. The resulting Gibbs risk is <=epsilon/3.

With q_tau=Pi(|z-f|<=tau), 1-q_tau is exactly posterior probability of the strict test-error event. Therefore D{q_tau<=2/3}<=3 times Gibbs risk, including boundary cases. The target-mass-only posterior lemma follows from Tonelli and Markov with the stated log(6/(epsilon delta)) constant.

No atom at the exact teacher function is assumed or needed. No posterior-mean argument is used. The cover can be distribution independent and may have centers outside the network class.

## 2. Continuous bounded-energy cover

The energy-to-Lipschitz calculation is correct:

    ||v|| product_internal ||W|| ||W1||
    <= sqrt(K/N) K^((L-2)/2) sqrt(KN/d)
    = K^(L/2)/sqrt(d).

The compression proof only needs bounded hidden activations and a finite union bound over inputs. Replacing log_2 of the Boolean-cube cardinality by max(1,ceil(log_2 s)) is legitimate; the actual dimension d remains in the weighted norm and parameter count.

The altered compression parameter eta=a/[4(L-1)] gives total truncation plus sampling error <=a/4, and energy <=4K. M>=4K makes every retained parameter <=M in absolute value. The nearest-net-point construction avoids any need to control the compressed network's Lipschitz constant: the original network alone contributes at most a/8 between an input and its chosen net point. Parameter rounding contributes at most a/4. The total is below a.

The rounded functions are Borel. A fixed enumeration resolves ties between finitely many nearest net points. The cover is deterministic and independent of N and of the sample. Its logarithmic cardinality is polynomial at fixed L because only log(s), not s, enters compression.

## 3. Teacher tube at every width N>=C, with a separate weight bound R

The balanced-cloning energy bound

    B=d(d+1)R^2+2(L-1)C^2R^2

is correct. It does not require R<=C. The internal terms use group-size ratio <=2; the readout uses N/min(group size)<=2C. The first-layer rows are simply duplicated. Cloning is an identity for every real input.

The standardized perturbation cylinder has N[d+2+(L-2)C] independent scalar constraints. The internal constraints concern disjoint source groups in each row. Strong log-concavity, centering under the symmetric convex conditioning, conditional spectral concentration, and the translated-event lower bound are precisely the previously established ingredients.

The perturbation's orthogonal component annihilates the exact teacher's group-constant activations. Its full operator norm still controls propagation of the existing activation error. This yields the displayed recurrence with sqrt(2)CR+b_{m,L}, without any hidden width factor. The unamplified readout norm sqrt(N)||v_*||<=sqrt(2)CR is correct.

Taking eta=min(1/2,rho/(2P_0)) places the translated event in the uniform rho/2 tube. Its logarithmic cost is bounded by A N^gamma with A polynomially bounded in d,C,R,log(1/min(rho,1)) at fixed depth. No finite-domain cardinality is used. This establishes a sample-independent denominator for every N>=C and every gamma>=1.

## 4. Strong-prior and gamma>1 reductions

For fixed finite N, kappa_N/sigma^2 is a finite-dimensional chi-square variable in the Gaussian case. The lower large-deviation bound for the open uniform teacher tube is >=-B/2; the upper bound for energy>K is <=-K/2. K=B+2 therefore makes their ratio tend to zero. The small-scale threshold may depend on N, teacher, rho, and accuracy but not D, sample size, or confidence delta. The broader quadratic-envelope extension uses the stated K=(b/a)B+2.

At gamma>1, the spectral truncation error

    b sum_{j=1}^{L-2} K^(j/2)

is <=a/2 for b=a/[2L(sqrt(K)+1)^(L-2)]. The retained network has energy <=LK. An additional a/2 cover gives total a error. The exceptional raw-prior probability divided by teacher-tube mass is <=epsilon/6 for the displayed K. For all smaller widths the target-mass-only posterior lemma applies with cost A T^gamma. The threshold T and T^gamma have polynomial majorants at fixed gamma>1, even when gamma is not an integer. L=2 is covered: there are no internal truncations and the corresponding sum is zero.

## 5. New QP lemma: checked independently

Minimize N||u||^2/2 subject to Hu-z<=t and z-Hu<=t. The original v is strictly feasible because z=Hv and t>0. Coercivity gives a minimizer; Slater's condition supplies KKT multipliers alpha>=0 for the first inequality and eta>=0 for the second.

Define beta=eta-alpha. Stationarity is Nu=H^T beta, so Hu=Q beta. Because t>0, both constraints at one coordinate cannot be active simultaneously. Complementarity therefore gives exactly

    t||beta||_1 = beta^T(z-Hu)
                 = N<u,v>-N||u||^2.

Writing r=sqrt(N)||u|| and using N||v||^2<=K bounds the right side by sqrt(K)r-r^2<=K/4. Hence ||beta||_1<=K/(4t), and primal feasibility gives ||Q beta-z||_infinity<=t. No rank assumption on H or Q is needed. This is a valid replacement for the earlier sign-separation QP and does not assume output margins.

## 6. Mean-field probability and approximation budgets

The event ||W1||_F^2<=NK, all internal operator norms <=sqrt(K), and N||v||^2<=K makes the original output K^(L/2)-Lipschitz. Scalar square-exponential moments give the first/readout tail estimates; two sphere nets give the internal estimate. A fixed-law lower baseline on K makes the total failure <=L exp(-mNK/16).

The entropy-certificate width threshold forces failure <=r exp(-NK/4), provided **K>=2**. This minor explicit condition should be included in the paper's baseline. The non-Gaussian Lindeberg threshold makes the log-partition error <=1 and changes K to Kbar=K+1. The first layer retains its exact non-Gaussian law.

With G_r=8r K Kbar/a^2 and G_(ell-1)=b_ell G_ell, every summand in the proxy-covariance telescoping estimate equals Kbar/G_r. Thus covariance error is <=a^2/(8K). The QP lemma with t=a/4 supplies ||beta||_1<=K/a and output error <=a/4; replacing covariance contributes <=a/8.

The finite-realization choice eta_cov=a^2/[8K r b^(r-1)] gives another <=a/8 output error. Its width bound follows from Hoeffding over r s^2 bounded covariance entries. The bounded tilt changes a coordinate tail by at most exp(2G_1), so the existence of a realization with polynomially bounded weights follows by the existing square-exponential tail union bound. In particular no exp(G_1) appears in the **weight bound** after taking logarithms. Readout weights satisfy |v_i|<=K/(a n).

Rounding contributes <=a/8; nearest-input replacement contributes <=a/4. The total a/4+a/8+a/8+a/8+a/4=7a/8 is correct. Rounded-network values at the fixed input net produce a deterministic finite family independent of the original width N, although the tilt matrices used to prove membership may depend on the draw. The statistical cover never replaces the actual posterior.

The large-width exceptional-mass ratio is <=epsilon/6 under cK>=A+log(12L/epsilon). The small-width denominator-only argument has cost A T_L. This covers every N>=C.

## 7. Presentation points to retain

1. State K>=2 along with the fixed-law concentration baseline.
2. The mean-field final theorem should retain a separate teacher weight bound R. Its proof already permits this; only the target-tube exponent A changes. The preliminary meanfield note specializes to R<=C in its final prose unnecessarily.
3. Use 1/min(1,tau-rho), or an equivalent majorant, for a globally valid stated polynomial dependence when the tolerance gap can exceed one.
4. The real-valued posterior uses positive tolerance. Exact equality conditioning is not established here.
5. The independent classification consequence requires a uniform teacher signed margin on the distribution support. It does not turn a nonconstant Boolean target on the entire connected sphere into a globally separated continuous function.
6. The checks are mathematical reviews by AI agents; they must not be described as Lean verification.
