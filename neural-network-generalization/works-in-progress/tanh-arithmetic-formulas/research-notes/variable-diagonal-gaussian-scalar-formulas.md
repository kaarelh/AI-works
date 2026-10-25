# Variable-diagonal centered Gaussian paths: a scalar-formula construction

25 October 2026. Conventional mathematical derivation, independently audited in its scalar factory, mixed Hermite derivative estimates, tracked norm updates, and variance telescoping. The audit's large-step clarification has been incorporated: copy J and sample K, not A. This removes the equal-diagonal hypothesis from the exact real-constant Gaussian/Fock formula construction, for centered Gaussian covariance controls. The finite-bit conversion is separate. No assertion about arbitrary non-Gaussian row tilts or the full NNBayes learning theorem is made here.

## 1. Candidate theorem and model

Let X be finite. Start with a Hilbert-valued feature h_0(x) of constant squared norm q_0 in (0,1], whose normalized coordinates u_0=h_0/sqrt(q_0) have deterministic arithmetic formulas of size at most T_0. At each of H stages first apply

`A_j=J_j+K_j`,

where J_j is a signed coordinate isometric injection, K_j is Hilbert--Schmidt, and A_j has a positive minimum singular value sigma_j. Then take the centered Gaussian tanh feature: its covariance on two inputs is

`E_G tanh(<G,A_j h_(j-1)(x)>) tanh(<G,A_j h_(j-1)(y)>)`.

Use the canonical full ordered-tensor Fock representation for this feature. Put

`S=sum_j ||K_j||_HS`, `L=sum_j log_+(1/sigma_j)`.

The claim is that the normalized direction `u_j(x)=h_j(x)/||h_j(x)||` has unbiased independent-call random scalar real arithmetic formulas, with a bounded pointwise trace second moment and common expected size at most

`C T_0 (H+1)^C exp[C(S+L)]`.                         (1)

All formula sizes count actual scalar trees. Countable Hilbert bases are permitted. The random expression shape is independent of x. Physical norms are positive because A_j is bounded below and F(q)>0 for q>0.

A global-margin linear classifier from h_H has the same signs as its readout on u_H. Since ||h_H||<=1 after a tanh Gaussian feature step, a unit physical margin remains at least unit margin on u_H. The usual sampled readout, averaging, and finite-input union argument therefore give a deterministic real-arithmetic sign-formula majority with size

`poly(log|X|+1,T_0,||v||,H) exp[C(S+L)]`.             (2)

The construction does not compute a square root of an arbitrarily small query norm at the final readout. It tracks normalized directions and relative squared norms throughout, and uses only their signs at the end.

For centered Gaussian covariance controls, choose A_j=Sigma_j^(1/2) in the existing Fock basis and extend it by the identity off the finite query span. If D_j is its Gaussian KL cost and B=sum D_j, then

`||A_j-I||_HS<=sqrt(2D_j)`,

`log_+||A_j^(-1)||op<=C(sqrt(D_j)+D_j)`.

Thus (1) is bounded by

`C T_0 (H+1)^C exp[C(sqrt(HB)+B)]`.                  (3)

No arbitrary intermediate change of the already constructed scalar-coordinate basis is needed for this positive-square-root realization.

## 2. A generic scalar Fourier--Poisson factory

Suppose X is an unbiased scalar oracle for r in a fixed compact interval, with E X^2<=V_0 for an absolute constant V_0 and expected real-formula size at most T>=1. Let f have a compactly supported H^3 extension to the real line. Use Fourier convention

`f(r)=(2pi)^(-1) integral fhat(omega) exp(i omega r) domega`.

Draw omega with fixed density `p(omega)=c(1+omega^2)^(-3)` on the real line. Conditional on omega, take K~Pois(lambda), lambda=1+V_0 omega^2, fresh independent X_a, and

`Z=product_(a=1)^K (1+i omega X_a/lambda)`,

`Y=Re[fhat(omega) Z/(2pi p(omega))]`.

The Poisson product identity gives E[Z|omega]=exp(i omega r) and E[|Z|^2|omega]<=e. Therefore

`E Y=f(r)`, `E Y^2<=C ||f||_(H^3)^2`.                (4)

The expectation is justified by the finite second-moment bound and Fourier integrability. Expand the real and imaginary parts of the product by balanced multiplication. This uses O((K+1)^2) child occurrences, with all syntactic duplicates fully charged. Since E_p omega^4<infinity, E(K+1)^2 is an absolute constant. Thus

`E size(Y)<=C T`.                                   (5)

This is an exact real-constant formula factory, not an algorithm for computing fhat. The same density works for a countable family f_k, and weighted sums of their output second moments are bounded by the corresponding weighted sums of H^3 norms. A fixed bounded extension operator from H^3([0,1]) to compactly supported H^3(R) is used below. Its bound commutes with nonnegative sums over k.

## 3. Uniform coefficient-function estimates

Let F(q)=E tanh(sqrt(q)Z)^2 and let b_k(q) be the normalized odd Hermite coefficients of tanh(sqrt(q)Z), with b_1(0)=1 and b_k(0)=0 for k>=3. For a small positive a and r in [0,1], the following estimates hold after applying the fixed extension operator:

`sum_(k>=3) k^2 ||b_k(a ·)||_(H^3)^2 <= C a^2`,

`||b_1(a ·)-1||_(H^3)^2 <= C a^4`,

`||F(a ·)/F(a)-id||_(H^3)^2 <= C a^2`.              (6)

Here and below only odd degrees are summed. A useful direct justification is to write

`phi_q(z)=tanh(sqrt(q)z)/sqrt(F(q))`.

For q in [0,1], all mixed q derivatives through order three and z derivatives through order two are uniformly bounded in Gaussian L2. One explicit verification uses `psi(t)=tanh(sqrt(t))/sqrt(t)`, with psi(0)=1. Every fixed derivative of psi is bounded on [0,infinity): its Taylor expansion handles zero, compactness handles a middle interval, and direct differentiation handles infinity. Now `tanh(sqrt(q)z)/sqrt(q)=z psi(q z^2)`. Its fixed mixed derivatives are bounded by fixed polynomial functions of |z| for q<=1. The normalization F(q)/q is smooth, bounded away from zero, and has bounded fixed-order derivatives by Gaussian dominated differentiation. Gaussian Sobolev Parseval then bounds `sum k^2 |partial_q^ell b_k(q)|^2` for ell<=3.

For ell=0, the sharper tail estimate is `sum_(k>=3) k^2 b_k(q)^2<=6q^2`. Scaling q=a r proves the first line of (6). Differentiating ||phi_q||_2^2=1 at zero gives b_1'(0)=0; bounded higher derivatives give the second line. Finally F(q)=q+O(q^2), with bounded fixed-order derivatives, gives the third line including its r derivatives through order three.

For a bounded away from zero, all three relevant H^3 norms, including the weighted k^2 sum, are bounded by a fixed polynomial in 1+a. For q>=1, F(q) is bounded below, and direct differentiation of tanh(sqrt(q)z) and its z derivatives gives polynomial bounds in 1+q. Thus no inverse minimum query variance appears in these estimates.

## 4. Track a direction and a relative scalar variance

Maintain the true normalized direction u(x), ||u(x)||=1, and a scalar r(x) in (0,1] such that

`h(x)=sqrt(qbar r(x)) u(x)`,

where qbar is a deterministic common upper bound. Maintain scalar formula oracles for every u coordinate and for r, with combined pointwise second moment at most four and a common expected size bound T. The true combined mean squared norm is at most two. Coordinatewise two-copy averaging resets this combined moment bound from at most four to at most three. The same threshold/reset bookkeeping as in the near-copy theorem will be used.

Initially qbar=q_0 and r=1. The construction never assumes an oracle for r for free; the following updates build it along with u.

## 5. Small control step

Write kappa=||K||_HS and suppose 0<kappa<=kappa_0 for a sufficiently small absolute threshold. Put

`B=A* A-I=J* K+K* J+K* K`,

so `beta=||B||_HS<=2kappa+kappa^2`. The squared norm correction is

`delta(x)=<u(x),B u(x)>`, `|delta(x)|<=C kappa`.

Sample an ordered matrix entry with probability B_ij^2/beta^2 and return `B_ij X_i X'_j /p_ij`, using independent coordinate children. This estimator D satisfies

`E D=delta`, `E D^2<=beta^2 (sum_i E X_i^2)^2<=C kappa^2`,

with expected size at most C T. The zero-B case is deterministic zero. All countable sums are justified by Tonelli and the Hilbert--Schmidt bound.

Apply the scalar factory to D/kappa and the compactly extended function

`f_kappa(z)=(1+kappa z)^(-1/2)-1`.

The true z is in a fixed interval and the small threshold keeps its denominator away from zero. Its H^3 norm is O(kappa), so the resulting eta estimator has mean `(1+delta)^(-1/2)-1`, second moment O(kappa^2), and expected cost C T.

First construct coordinates of w=A u by the existing near-copy rare linear update. Then normalize each coordinate by an independent rare correction: with probability kappa add `eta_hat w_i'/kappa` to an independent base w_i. The true output is `u'=w/sqrt(1+delta)`. Its trace second moment rises by O(kappa): the cross term is bounded by C kappa and the rare correction second moment is O(kappa) times the preexisting trace bound. Its common size multiplier is 1+O(kappa).

Set `qbar'=(1+kappa)^2 qbar` and update

`r'=r(1+delta)/(1+kappa)^2`.

Use the old r oracle as the base, and with probability kappa add an independent product `r_copy D/kappa`, then scale by (1+kappa)^(-2). The scalar moment also rises by O(kappa), and the size multiplier is 1+O(kappa). The true r' remains in (0,1]. Both updates use only old-state scalar oracles; there is no shared vector child.

## 6. Large control step

For kappa>=kappa_0, retain/copy J u and sample only the rows of K, using the large-step near-copy construction. One must not sample A directly: J can have infinite Hilbert--Schmidt norm. The resulting w=A u has trace moment and scalar costs polynomial in 1+kappa. The same quadratic estimator gives delta, with variance bounded by a polynomial in 1+kappa. Let `rho=min(1,sigma_min(A))`. On the true delta range,

`1+delta>=rho^2`, `1+delta<=(1+kappa)^2`.

Scale the delta oracle to have an absolute second-moment bound. The function `(1+delta)^(-1/2)` has a compact smooth extension from this range with H^3 norm bounded by a fixed polynomial in 1+kappa and rho^(-1). The scalar factory, multiplication with independent w-coordinate oracles, and polynomially many independent averages therefore produce normalized u' with bounded trace moment at polynomial cost. The scalar r' update has the same polynomial cost or better. Reset both families using their true combined mean norm bound.

The logarithm of this entire size multiplier is

`O(kappa+log(1/rho))`.                               (7)

This explicitly charges near-singularity rather than assuming a hidden uniform lower query norm. Only the large control steps use this argument; fixed overhead is absorbed because kappa>=kappa_0.

## 7. Free Gaussian feature step with variable r(x)

Let a=qbar after the control. The physical variance at input x is a r(x). The exact normalized Fock output has coordinates

`b_k(a r(x)) u(x)^(tensor k)`.

For small a, estimate each coefficient b_k(a r) with the scalar factory of Section 2. For k>=3 the weighted sum of coefficient second moments is at most C a^2 by (6). Before a degree-k tensor product, average ceil(kV) independent copies of each coordinate oracle, where V is the current common trace budget. Its summed product second moment is at most e. Create this coordinate with probability p_k=a/k^2, independently of everything else, and divide by p_k when created. The resulting total higher-degree trace increment is at most C a. Its expected coordinate cost is at most

`1+C p_k[k ceil(kV) T+T] <= T(1+C a)`.

For degree one, copy u_i and add a rare product correction using an independent estimator of b_1(a r)-1. Its second moment is O(a^4); a branch probability a is sufficient. The trace cross term is nonpositive because b_1(q)<=1, and the remaining moment/cost increase is O(a).

Set the new common upper variance to F(a) and update the scalar relative variance by

`r_next=F(a r)/F(a)`.

Estimate the residual of this map from the identity using (6), adding it on a probability-a branch. Its second moment is O(a^2), so its scalar moment/cost increment is O(a). The true r_next is in (0,1]. Thus the combined state has a small-step cost multiplier 1+O(a), and its moment reset charge is O(a).

For a>=a_0, use p_k=min(1,a/k^2), the polynomial coefficient H^3 bounds, and polynomially many independent averages. Include degree one and the scalar r map directly. This gives a size multiplier polynomial in 1+a and restores the combined trace bound. Therefore the log cost of a free step is bounded by

`C a` for small a, and `C log(1+a)` for a>=a_0.       (8)

All scalar factories use independent children; the only repeated occurrences are fully charged copies within an individual real expansion of a complex product.

## 8. The deterministic upper variances telescope

Let qbar_j be the post-Gaussian upper variances and a_j the pre-Gaussian upper variances. Then

`a_j=(1+kappa_j)^2 qbar_(j-1)`, `qbar_j=F(a_j)`.

For q>0 define `ell(q)=log(q/F(q))`. It is positive, comparable to q near zero, and comparable to log(1+q) away from zero. Thus (8) is at most C ell(a_j). Exact telescoping gives

`sum_j ell(a_j)=log(q_0/qbar_H)+2 sum_j log(1+kappa_j)`.

Because the control upper bounds only increase variance and F is increasing, `qbar_j>=F(qbar_(j-1))`. On (0,1], `F(q)>=q/(1+Cq)` for a uniform C. Hence

`qbar_H >= q_0/(1+C H q_0)`,

`sum_j ell(a_j) <= log(1+C H)+2S`.                   (9)

Small-step resets are charged to their accumulated O(kappa+a) moment increments. Large steps already include their resets and have bounded log cost. Equations (7)--(9) prove the candidate bounds (1)--(2).

## 9. Verification limits

The proof uses exact Fourier transforms of fixed smooth scalar coefficient functions as real constants. It establishes no efficient sampler or effective coordinate enumeration. Turning the resulting real formulas into polynomial-bit rational formulas needs an additional argument; a separate noise-floor precision proposal is under investigation.

The theorem concerns centered Gaussian covariance controls, represented by positive covariance square roots on an existing feature basis. Nonzero Gaussian mean controls require an additional scalar mean coordinate and corresponding coefficient estimates, and arbitrary non-Gaussian row tilts are outside this note. Consequently this is not yet a general critical NNBayes sample-complexity result.
