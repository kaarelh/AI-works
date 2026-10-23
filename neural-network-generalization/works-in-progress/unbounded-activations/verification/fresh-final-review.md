# Fresh adversarial mathematical review

Reviewer: independent `fresh_final_review` agent. Review started at 2026-10-22 13:02:32 UTC; final source hashes were rechecked unchanged at 13:11:45 UTC. This review examined the mathematical argument directly, without using the other review reports. No author source was edited.

## Verdict

**No fatal proof gap or incorrect mathematical claim was found in the reviewed version.** The argument supports the stated fixed-depth polynomial sample bound, on one sample event simultaneously for every learner width `N >= C` and every `0 < sigma^2 <= 1/N`, under the stated teacher and global-margin conditioning assumptions. In particular, the mean-field endpoint does not rely on homogeneity or boundedness of the fixed learner activation.

This is a mathematical source audit, not a formal verification. The conclusion concerns exactly the source hashes below.

## Sources reviewed

All six source files were read in full, including the main file's capacity and strong-prior proofs and all five local inputs. SHA-256 hashes:

| File under `common/source/` | SHA-256 |
| --- | --- |
| `paper.tex` | `1793ad161334f922f6d32982e14c4ab152ba9a073a6088b1620f067a547c7396` |
| `spectral-extension.tex` | `bbf8ea4a4a138d9e2cd856ee0185f4bb96d3080a6d512bc407d1d69d49533d35` |
| `meanfield-preliminaries.tex` | `722eac54ff77fe82f60a2928cac5fd4e7770fa6494e13e13beda7b3ac0319cfa` |
| `meanfield-atoms.tex` | `df0673be93fe246251ca4c1820332fa254822318b37656b380175ddbbda2d0ca` |
| `meanfield-closure.tex` | `f20a10b87122f6061bdad2a4e1d408ce1740e6b25d3a6c21cae7d167ac191a1a` |
| `uniform-supercritical.tex` | `de1104c4f61cc3c6de18e00844dbaf7c287c0b5b7182a9d54eb3ecda83e87da9` |

## Mathematical checks

### Auxiliary activation capacity

The scalar cover counts at most `5^(2J)` rounded codes and uses actual globally 1-Lipschitz, zero-at-zero representatives, so its centers preserve the required activation class. The convex-contraction proof's two-number maximum and sum inequalities are valid, including for a nonodd activation. The feature recursion correctly absorbs each row norm into a new auxiliary activation and uses the sum of squared row norms, avoiding a width factor. Its exponential union bound over the scalar cover yields the asserted `m^(-1/3)` bound.

The product-norm normalization is an exact identity in the enlarged neuron-specific activation class. It is not asserted to be a parameter rescaling of GELU. The weighted-energy arithmetic–geometric mean calculation gives the stated product bound, and strict global margin makes the resulting Rademacher shattering argument apply to the Boolean counting class. This class includes all auxiliary activations produced by the tail construction, even when their formulas depend on the original draw.

### Gaussian bounded bulk and RKHS tails

Whitening on the support of a possibly singular covariance turns its RKHS distance into Euclidean distance. The bounded-coordinate convex set has probability at least one half, and Gaussian isoperimetry gives the stated distance tail. Integrating that tail indeed yields the exponential moment at parameter `1/4` bounded by 2. Independence then gives the aggregate `exp(-N K)` bound.

For an arbitrary Lipschitz activation, replacing the tail feature `phi(Z_i)` by `phi(u_i)` costs at most `6 lambda^2 B M A / T`. The two estimates on the tail's weighted count and weighted RKHS norm follow from `sqrt(M) delta_i >= T/2`. Normalization by `delta_i` produces a zero-at-zero activation of Lipschitz constant at most `lambda` and total covariance coefficient mass at most `A`; it requires no recession limit or homogeneity. The next-layer diagonal estimate also checks out.

### Sparse tilt certificate and covariance transport

The sparse-vertex approximation of the l1 parameter ball has the claimed log-partition error, by Hoeffding's exponential lemma and Jensen's inequality. The maximizer's first-order condition proves both the maximum-norm residual and the entropy bound; these do not require an unstated sparsity property of the final maximizer.

The covariance-interpolation derivative formula is correct. Bounding its derivative sums under the tilted law gives the displayed polynomial `C_G`. In particular, the proof does not introduce a reciprocal partition-function factor into `C_G`. Singular endpoints can be handled by adding `epsilon I` and taking limits, since the bounded observables give strictly positive bounded partition functions.

The RKHS l1 certificate is valid on the covariance range even for a singular matrix. Its multiplier identity and `r - r^2 <= 1/4` give `||beta||_1 <= 1/(4 eta)`. Hence entrywise covariance transport incurs error at most `eta/4` when the covariance changes by `eta^2`. No lower eigenvalue bound or factor proportional to the number of Boolean inputs is hidden here. The constants in the sampled atom approximation have substantial slack.

### Finite reconstruction and polynomial dependence on dimension

The global cutoff selects a scalar coefficient for a sampled neuron after its entire field has been chosen. This scalar is fixed in the resulting network; the cutoff is not an additional operation evaluated on the test input. Its covariance coefficient can therefore be absorbed into ordinary incoming weights at the next layer and into the final readout. Evaluating the actual activation in the bulk also avoids accidentally putting the mollified activation, which need not vanish at zero, into the auxiliary network.

The bounded bulk's empirical covariance concentration and the latent Gaussian-coordinate tail event have a common realization. The latter uses a union bound over sampled coordinates with density ratio at most `exp(2 G F0)`, giving the displayed square-root bound on the latent coefficients. Thus the selected finite weights grow polynomially, rather than exponentially, in the tilt budgets.

All input-set concentration unions cost only `log(m)` or `log(m^2)`. The potentially dense RKHS certificate is used through its l1 bound when converted to finitely many physical weights; its length does not enter the norm or width bounds. Computation of these coefficients can be expensive, but the theorem is explicitly information-theoretic.

The backward accuracy recursion is a fixed finite composition of reciprocal-polynomial moduli. For example, with the other budgets held fixed, the displayed choices give `T = O(alpha^(-1))`, `F2 = O(alpha^(-3))`, `C_G = O(alpha^(-6))`, and a reciprocal-polynomial modulus no worse than order `alpha^(-7)`, up to polynomial factors in the other budgets. Repeating this a fixed number of times preserves polynomial dependence on `d` and `K`. The forward physical-feature bounds may square previous bounds, but again only a fixed number of times. These observations justify the existence of polynomial majorants `P` and `J`; no exponential dependence on `m = 2^d` remains.

The reconstructed covariance need not satisfy exactly the original diagonal bound: the transport estimates and cutoff sampling are valid for every positive semidefinite reconstructed covariance sufficiently close entrywise. Thus no unaccounted diagonal-error induction is needed.

The final readout certificate has l1 bound `16 K`; covariance error `1/(128 K)` contributes at most `1/8`, in addition to the certificate's `1/8` error. Doubling the reconstructed output therefore preserves signs and produces strict margin greater than `1/2`. Padding gives precisely the stated normalized-energy upper bound.

### Target mass and spectral band

The target-cylinder construction constrains only order `N` coordinates. The unconstrained internal Gaussian component annihilates the group-constant cloned teacher state, and its operator norm controls only propagated perturbations. This is the mechanism needed to avoid a cost of order `N^2`. The deterministic perturbation bounds, scalar Gaussian interval bound, and constrained-center energy estimates all hold for a general zero-at-zero Lipschitz activation.

The spectral distance argument gives the stated Frobenius-tail exponent. The first-layer and readout chi-square thresholds follow from the scale hypotheses. The hidden RMS recursion and truncation-error recursion have the stated constants, including the separate zero-error case `L = 2`. Doubling the truncated readout gives the required margin and energy budget.

### Uniform scales and posterior argument

At arbitrary `t <= 1`, conditional preactivation covariance is exactly `t^2 Q`. Reconstructed bulk incoming weights acquire a factor `t`, and atom incoming weights acquire a factor `t^2`; the l1 certificate stays uniformly bounded. The endpoint width and energy majorants therefore do remain independent of `t`.

The three posterior-ratio regimes are exhaustive. Their constants check directly:

- Spectral band: `K_s/8 - A_f/2 = log(2L/epsilon)`.
- Mean-field band: the definition of `K_m` leaves more than the required logarithmic slack for every `t >= t_*`.
- Bounded-width band: `J_0/4 - A_f/2 - D_* log(2)/2 = log(2/epsilon)`.

The target raw mass is a valid lower bound on every noiseless posterior denominator, since the global-margin normalization cancels. The auxiliary class is the same for all widths and all scales. Consequently the final union bound is over a single finite Boolean function class, not over the continuum of variances. It yields the advertised simultaneous sample event.

The simpler strong-prior argument also handles ties correctly by retaining every function with minimum energy no greater than the target's. The exact same-depth GELU gate identity and its stated weight bounds were checked separately and are correct.

## Exposition versus defects

No missing argument was found that blocks the theorem. Two optional clarifications would make the finite-reconstruction paragraph easier to audit, but are not mathematical repairs:

1. State explicitly `0 <= a_l <= V` when introducing weighted feature covariances. Nonnegativity is already ensured by every coefficient in the construction and is implicit in the Gaussian realization with `sqrt(a_l)`.
2. Display the tilted latent Gaussian density and the union bound over `n_B r` coordinates in one line. The current density-ratio bound and the displayed `R_xi` already supply the complete argument.

Giving explicit expanded polynomial majorants for `P` and `J` would improve quantitative readability, but the stated recursion is sufficient for the theorem's existential fixed-depth polynomial bound. None of these points warrants weakening the result.
