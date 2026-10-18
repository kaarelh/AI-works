# Independent audit of the round-six critical-depth structural results

Reviewed by a separate mathematical-review agent on 18 October 2026. This is a conventional mathematical audit, not a Lean verification. No repository files were edited by this reviewer.

## Frozen sources reviewed

- `source/critical-near-baseline-decomposition.tex`: SHA-256 `79498d3baf3f41abd76300ecc179a98443e40ccc08d6c68985fade931da8267f`
- `source/critical-square-root-entropy.tex`: SHA-256 `b9cffa312debbbcfc149c243ba6efadad191402fdef33d9c59a83a2786a9f2a1`
- `source/critical-invariant-kernel-product.tex`: SHA-256 `21c2979bcd105cd53483e241d5c9eeaffdc1d239f3fab020012820adab35a7b8`
- `boolean-kernel-geometry.md`: SHA-256 `cb906eeae15deff1655879952aac3ebf0da4b83b70354681098b7db0a14ad7fa`

I also read the relevant scalar-value and signed-pair comparison statements in `unrestricted-critical-flattening.tex` from the earlier manuscript, and the square-root-entropy working note. The present review checks the new deductions using those established scalar ingredients; it does not purport to reverify every theorem in the preceding papers.

## Verdict and scope

No substantive mathematical gaps found in the sources listed above. The structural results do not establish a general critical-rate-to-product-complexity bridge or a posterior sample-complexity bound. The invariant-kernel proposition supplies a product bound under an explicit symmetry assumption on the terminal kernel. Its shallow realization has finite width; the displayed theorem does not bound that width polynomially. The controlled pair-collapse proposition is a valid admissible variational construction and is not by itself a posterior lower bound.

## 1. Additive last-exit occupation

The key occupation inequality is correct. Dividing the one-step dissipation inequality by q_(j-1)^2 and using

    (q_j-q_(j-1))/q_(j-1)^2 >= 1/q_(j-1)-1/q_j

is valid because the difference is a nonnegative square divided by q_(j-1)^2 q_j. On an interval whose pre-states are at least u, nonnegativity of D_j permits replacing D_j/q_(j-1)^2 by D_j/u^2. The reciprocal terms telescope with the stated sign.

The last-exit blocks correctly remove their first transitions so that every remaining pre-state exceeds the lower dyadic level. For a nonempty block, its endpoint also exceeds that level and is at most twice the level. This gives the claimed length bounds without any monotonicity assumption on the path. The initial block, final tail, and restored transitions are all accounted for. The estimate H <= C(1/m+epsilon/m^2) and its quadratic consequence for m follow.

## 2. Near-baseline directional decomposition

For the selected edge or antipodal pair, the variance starts at 1/d, remains in (0,1], and its output has absolute value at least 1/2. The absolute value is important for negative constant targets. Finite entropy prevents recovery from zero pair variance; the admissible finite readout lies in the terminal covariance range.

The scalar suffix comparison gives the full-prefix entropy bound epsilon+C_0 v_i. The scalar small-state bridge extends to all v_i in (0,1] by enlarging C_0. Thus the occupation lemma applies to the full layer entropies, not merely scalar marginal entropies.

Coordinatewise tanh is a measurable bijection from real preactivations onto the interior of its feature range. A finite-entropy controlled feature law therefore lifts with unchanged relative entropy. The KL chain rule under the scalar projection gives the asserted nonnegative conditional entropy E_j, including for singular Gaussian covariances by disintegration on their support.

The scalar Bellman inequality has the required direction: the projected scalar tanh second moment is at least v_j, so monotonicity of V implies D_scalar,j >= V(v_(j-1))-V(v_j). Consequently all scalar Bellman slacks and the terminal slack are nonnegative. Their sum gives exactly

    A-V(m) = prefix entropy + sum(E_j+s_j)
             + readout residual + excess amplitude + terminal slack.

This identity and the boxed directional budget are correct, including when the minimum-variance index is the initial or final index.

The readout decomposition is orthogonal in the covariance-pseudoinverse seminorm. The coordinatewise residual bound |z_perp(u)|<=sqrt(2B) follows from Q_H(u,u)<=1 and the fact that the residual lies in the covariance range. Hence B<1/8 suffices for exact sign recovery from the anchored section. At B<=1/32, the anchored output margin is at least 1/4, and |a|/v_H<=4A gives the stated unscaled section margin 1/(16A)>=1/48.

## 3. Zero directional entropy and the shallow classifier

Zero prefix entropy makes the prefix the uncontrolled Gaussian feature recursion. Zero suffix conditional entropy preserves the Gaussian conditional law given the selected scalar projection, while allowing an arbitrary scalar marginal absolutely continuous with respect to its Gaussian reference. The stabilizer of the selected input pair fixes this projection, so the conditional construction preserves that stabilizer's invariance even if the controlled scalar marginal is not symmetric.

After sign-normalizing an edge pair, the stabilizer contains all permutations of coordinates 2 through d. The resulting classifier depends only on x_1 and the sum of the remaining coordinates, with at most 2d classes. The code (d+1)x_1+sum_(j>=2)x_j distinguishes these classes. For the antipodal pair, the coordinate sum gives at most d+1 classes. All code magnitudes and gaps have the stated polynomial/integer bounds.

The step expansion is correct with c_0=(f_1+f_M)/2. Replacing its finitely many steps by tanh at scale C log(d+2) gives uniform error at most 1/4. A first-layer constant feature implements the constant term. Doubling the readout gives unit margin, with depth two, polynomial width and polynomial Frobenius product independent of the original depth. This is an exact-zero-entropy rigidity result; the source correctly leaves quantitative stability open.

## 4. Square-root entropy and excess rate

The square-root entropy argument is valid for arbitrary nonmonotone full-vector paths. Its cutoff a=max(epsilon,1/(H+1)) controls the initial block. Each remaining dyadic last-exit block has O(1/u) transitions and O(u) full entropy, hence O(1) square-root entropy by Cauchy--Schwarz. There are O(log(H+2)) blocks. The final tail has bounded length and entropy. The coarse epsilon>=1/4 branch covers every larger excess and removes endpoint problems for near-minimizing sequences.

The new dimension/excess inequality is also valid. Gaussian second-moment entropy duality implies, for the selected scalar coordinate,

    q_j <= q_(j-1) exp(2 sqrt(D_j)).

Indeed the controlled preactivation second-moment ratio r has entropy at least (r-1-log r)/2; when r>=1 this is at least (log r)^2/4. The signed tanh pair has squared magnitude at most the squared preactivation pair. Finite scalar second moments follow from finite Gaussian relative entropy.

Iteration from q_0=1/d, together with the readout requirement q_H>=1/(8A), gives log d<=log(8A)+2 sum sqrt(D_j). The logarithmic term is absorbed into the claimed bound for small and large excess alike. Passing to arbitrarily near-minimizing paths requires no attained minimizer. The positive-part formulation is correct, including J_L(f)<V_*. Restricting L to a sufficiently small fixed power of d yields the stated positive lower bound on excess. This is an action lower bound, not a learning lower bound.

During review a sign typo was corrected: the selected scalar readout satisfies |b^T z|>=1/2, rather than necessarily b^T z>=1/2. The final source hash includes this correction; all subsequent squared inequalities were already unaffected.

## 5. Free Boolean kernel geometry and controlled pair collapse

The free-kernel first-chaos proof checks out. Integration by parts gives the first-chaos coefficient h(q)=1-F(q), and subtracting that projection yields the PSD lower bound Q_next >= h(q)^2 Q. The scalar estimates q_s=Theta(1/(s+1)) and sum q_s^2<infinity imply a uniformly positive product of the normalized first-chaos ratios. Therefore a fixed fraction of the normalized linear input Gram matrix survives at every depth. Applying a pair difference gives the stated Hamming-distance lower bound. Singular covariance causes no issue in the Gaussian linear representation.

The controlled pair-collapse construction is valid on the full Boolean cube. Decomposing the reference Gaussian into its conditional expectation given the contrast B and an independent residual isolates one scalar Gaussian direction. Scaling that direction by t preserves the Gaussian support and costs exactly (t^2-1-log(t^2))/2 in KL; retaining the other conditional directions does not add entropy. With t=exp(-sqrt(J/T)), the per-step cost is at most J/T.

The common/contrast pair representation remains valid at every step. Tanh contraction gives b_(s+1)<=t^2 b_s. The diagonal recursion and the increasing 1-Lipschitz function F imply that its loss relative to the free diagonal is at most sum (1-t^2)b_s<=1/d. Under d>=4(1+3T), the claimed diagonal lower bound follows. Combining it with b_T<=exp(-2sqrt(TJ))/d yields the stated normalized pair-collapse estimate. The construction refutes a polynomial pair-separation bound for all bounded-entropy controlled paths, while leaving posterior rate comparisons and sample lower bounds unresolved.

## 6. Invariant-kernel product bound

The Fourier normalization in the invariant-kernel proposition is correct: for the kernel operator under uniform input measure, the character eigenvalues sum to q, and the RKHS norm equals both sum |g_hat(S)|^2/lambda_S and g^T K^dagger g for the unnormalized kernel matrix. Cauchy--Schwarz gives Fourier variation at most ||g||_K sqrt(q).

Each parity character is approximated by k threshold steps of the coordinate sum, with integer margins. Tanh approximation at logarithmic scale gives the stated O((d+1)^2 log(2(d+1)/delta)) Frobenius-product and variation bounds. Combining characters pays Fourier variation, not Fourier support size.

Integer neuron cloning then makes the Frobenius product approach the shallow variation sum while preserving the function exactly. This argument correctly avoids any false homogeneity assumption for tanh. A sufficiently large finite cloning multiplicity attains a fixed constant-factor bound. Its width may be large, as the source allows.

For a critical path with invariant terminal kernel, doubling the original half-margin readout gives unit margin and RKHS norm at most sqrt(8J). The displayed product bound follows, independently of depth. The source properly states that arbitrary controlled terminal kernels need not have this translation invariance and that the general bridge remains open.

## Final square-root-entropy source update: matching signed-parity excess

The final `source/critical-square-root-entropy.tex` hash is now `3164a165582e8485e1e44a367fa866f4341979e26043bef1b43663bfdf2941c8`. This supersedes the entropy-source hash in the initial snapshot list. Its added corollary and proof were independently checked against the existing controlled Fourier-seed theorem (`thm:controlled-fourier-seed`).

For every signed parity, including constants and dictators, the normalized Fourier variation is exactly one. The existing theorem therefore gives excess at most C log^2(d+L+2)/L under L>=C' log(d+L+2). In the new corollary's range L<=d^c_0 with c_0<=1, one has L<=d and log(d+L+2)=O(log d) for d>=2. Enlarging the universal lower depth constant in L>=C_0 log(d+2) ensures that theorem's condition. The previously audited universal excess lower bound applies on the same range. Thus the matching Theta(log^2 d/L) excess order, uniformly over parity degree, is valid. The source correctly disclaims any conclusion about equality of leading constants, exact rate ordering, or posterior sample complexity. The no-substantive-gap verdict applies to this final entropy source.
