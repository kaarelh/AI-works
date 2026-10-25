# Noncentral Gaussian controls with variable query variances

25 October 2026. New extension for independent audit. This imports the scalar normalization, Hilbert--Schmidt quadratic sampling, and moment-reset machinery from `variable-diagonal-gaussian-scalar-formulas.md`, and adds nonzero Gaussian means. The finite-bit conversion is delegated to the ordinary Fourier-factory precision argument, with its two-variable version noted below. No arbitrary non-Gaussian row tilt is covered.

## 1. State and claimed resource bound

At a stage write the old physical feature as

`h(x)=sqrt(qbar r(x)) u(x)`,  `||u(x)||=1`,  `0<r(x)<=1`.

Its normalized coordinates and scalar r have unbiased random scalar formula oracles with a common expected size bound and bounded pointwise second moments. Initial qbar=q_0 in (0,1] is a constant input norm and r=1.

A Gaussian control has covariance square root `A=J+K`, where J is a signed coordinate isometric injection and K is Hilbert--Schmidt, and a mean vector m in the old feature space. Put

`kappa=||K||_HS`, `M=||m||`, `sigma=sigma_min(A)>0`.

The physical preactivation is

`sqrt(qbar r) [G·A u + <m,u>]`.

Over H stages define

`S=sum_j(kappa_j+M_j)`, `L=sum_j log_+(1/sigma_j)`.

The proposed conclusion is the same bound as the centered theorem:

`expected scalar formula size <= C T_0(H+1)^C exp[C(S+L)]`, (1)

with a uniform pointwise trace second-moment bound for the final normalized feature direction and a bounded-moment scalar oracle for its relative variance. A global-margin linear classifier has a deterministic all-input majority of real arithmetic sign formulas at this size, up to the usual polynomial readout/union-bound factors.

For a general Gaussian row control N(m,Sigma), take A=Sigma^(1/2) in the current Fock basis and extend by the identity off the query span. Its KL cost is

`D=(||m||^2+tr(Sigma-I-log Sigma))/2`.

Then `kappa+M+log_+||A^(-1)||op<=C(sqrt(D)+D)`. Total entropy B therefore bounds (1) by

`C T_0(H+1)^C exp[C(sqrt(HB)+B)]`.                    (2)

## 2. Exact shifted feature coordinates

For a fixed input put

`w=A u`, `n=||w||`, `beta=<m,u>`, `b=beta/n`,

`u_noise=w/n`, `Y_b=(Z+b)/sqrt(1+b^2)`.

Thus E Y_b^2=1. Choose the deterministic upper second moment

`a=qbar alpha^2`, `alpha^2=(1+kappa)^2+M^2`,

and the new relative scalar

`r_pre=r(n^2+beta^2)/alpha^2` in (0,1].

The preactivation equals `sqrt(a r_pre) Y_b`, with the standard Gaussian Z supplied by G·u_noise. Define

`F(t,b)=E tanh(sqrt(t)Y_b)^2`,

`phi_(t,b)(Z)=tanh(sqrt(t)Y_b)/sqrt(F(t,b))`.

At t=0 define phi_(0,b)=Y_b. Let c_k(t,b), k>=0, be its orthonormal probabilists' Hermite coefficients. They satisfy sum c_k^2=1. The exact normalized Gaussian feature has coordinates

`c_k(a r_pre,b) u_noise^(tensor k)`.

Degree zero is a single scalar coordinate. At t=0 the leading feature is

`c_0(0,b)=b/sqrt(1+b^2)`, `c_1(0,b)=1/sqrt(1+b^2)`,

`v_lead=(beta,w)/sqrt(n^2+beta^2)`.

This leading feature has norm one and is obtained by an inexpensive near-copy control when kappa+M is small. It is the base copied through a small nonlinear step.

## 3. A two-variable scalar Fourier factory

The scalar factory extends to two unbiased real oracles X_1,X_2 with bounded second moments. For f on a fixed rectangle, use a bounded compactly supported H^4 extension to R^2 and frequency density

`p(omega)=c(1+|omega|^2)^(-4)`.

At each Poisson child independently construct `W=omega_1 X_1+omega_2 X_2`, and take lambda=1+C|omega|^2 with C above its uniform second-moment constant. The product `Z=prod(1+i W/lambda)` has conditional mean exp(i omega·mu) and conditional second moment at most e. Fourier weighting and taking the real part give an unbiased estimate of f(mu), with

`E estimator^2 <= C ||f||_(H^4)^2`,

`E real-formula size <= C max(T_1,T_2)`.              (3)

Balanced real expansion costs O((K+1)^2) child occurrences. The chosen two-dimensional density has finite fourth moment; density exponent three would not suffice for this real-cost statement. All repeated occurrences are fully charged copies of the same sampled child expressions, and distinct Poisson children use independent draws.

## 4. Shift-uniform coefficient estimates

The unit-second-moment Gaussian family Y_b has uniformly bounded moments of every fixed order, and every fixed b derivative is bounded by a fixed polynomial in |Z|, uniformly in b. For small t, F(t,b)/t is uniformly bounded away from zero: E Y_b^2=1 and E Y_b^4<=3 give this directly from the Taylor remainder or uniform integrability. Consequently all fixed mixed derivatives in t,b,Z of phi_(t,b) have uniform Gaussian L2 bounds for t in [0,t_0]. The removable t=0 singularity is handled by

`tanh(sqrt(t)Y_b)/sqrt(t)=Y_b psi(tY_b^2)`,

where psi(s)=tanh(sqrt(s))/sqrt(s) has bounded fixed derivatives on [0,infinity). For t bounded away from zero, F(t,b) has a uniform positive lower bound: Paley--Zygmund applied to Y_b^2 gives P(|Y_b|>=1/sqrt(2))>=1/12. Thus all required mixed derivatives have polynomial growth in 1+t, uniformly in b.

An exact weighted tail estimate is

`sum_(k>=2) k^2 c_k(t,b)^2 <= 8t^2`.                 (4)

Indeed Gaussian Sobolev Parseval and tanh''(z)^2<=4tanh(z)^2 give

`sum k(k-1)c_k^2 = [t^2/(1+b^2)^2] E tanh''(sqrt(t)Y_b)^2/F(t,b) <=4t^2`,

and k^2<=2k(k-1) for k>=2.

For the actual two-variable coefficient functions, let r in [0,1] and z in a fixed compact interval, and write b=B z. A bounded extension operator from that rectangle to H^4(R^2) is applied to every coefficient. When 0<a<=a_0 and B is bounded by an absolute constant, the mixed Sobolev estimates imply

`sum_(k>=2) k^2 ||c_k(a ·,B ·)||_(H^4)^2 <= C a^2`,

`||c_l(a ·,B ·)-c_l(0,B ·)||_(H^4)^2 <= C a^2`, l=0,1. (5)

For derivatives involving b, note that the entire k>=2 tail vanishes identically at t=0; the fundamental theorem of calculus in t supplies the same factor a. The mixed Gaussian-Sobolev derivative bounds supply all fixed orders through four. If a or B is large, the corresponding norms are bounded by a fixed polynomial in 1+a and 1+B. This polynomial is charged only once in a jointly large control stage below.

## 5. Uniform physical upper variance

For all real z,

`tanh(z)^2 <= z^2/(1+z^2/2)`.

For z>=0, compare tanh(z) to w(z)=z/sqrt(1+z^2/2). One has w(0)=0 and w'(z)>=1-w(z)^2: after multiplying the positive denominator this follows from `(1+t)^(-1/2)>=1-t`, t=z^2/2. Scalar differential comparison proves the claim; symmetry handles negative z.

Since s/(1+s/2) is increasing and concave for s>=0, Jensen and E Y_b^2=1 give

`F(t,b)<=G(t)`, `G(t)=min(1,t/(1+t/2))`.             (6)

Thus qbar_next=G(a) is a valid common upper variance. Update

`r_next=F(a r_pre,b)/G(a)` in (0,1].

For small a, `F(a r,b)/G(a)-r` has H^4 norm O(a) on the same fixed parameter rectangle. This follows from F(t,b)=t+O(t^2), with uniform mixed derivatives, and G(a)=a/(1+a/2). For large a or large B the norm is polynomial in 1+a and 1+B. Therefore the scalar r update has exactly the same rare-residual accounting as the normalized feature coefficients.

## 6. Small joint control: build all helpers, without a free b oracle

Let 0<tau=kappa+M<=tau_0, with tau_0 a sufficiently small fixed constant. If tau=0 the control is just the coordinate injection and all zero residuals are omitted. The old state is u and r. For M>0, sampling m_i^2/M^2 gives a linear estimator of beta=<m,u> with second moment at most C M^2 and expected size C T; for M=0 return exact zero.

Both quadratic norm corrections have Hilbert--Schmidt kernels:

`delta_A=n^2-1=<u,(A* A-I)u>`,

`delta_tot=n^2+beta^2-1=<u,(A* A+m m*-I)u>`.

Their kernel norms are at most C kappa and C tau respectively. Entrywise squared-coefficient sampling, with independent coordinate children, therefore estimates these corrections with second moments O(kappa^2) and O(tau^2). The centered scalar inverse-square-root factory constructs the normalization residuals at the same respective costs and amplitudes.

Construct u_noise=w/n by the centered near-copy normalization procedure, with cost multiplier 1+O(kappa). Separately construct the leading feature v_lead=(beta,w)/sqrt(n^2+beta^2): copy/sample w as before, create the new beta coordinate on a probability-tau branch, and normalize by the delta_tot inverse-square-root residual on a probability-tau branch. The beta-coordinate trace cost is `O(M^2/tau)<=O(tau)`. The leading feature therefore has trace increment O(tau) and common scalar cost multiplier 1+O(tau).

Update the relative scalar by

`r_pre=r(1+delta_tot)/alpha^2`.

Use the scaled old r as a base and add an independent product of an r child and the delta_tot estimator on a probability-tau branch. Its moment/cost increment is O(tau), and its true mean is in (0,1].

For coefficient factories only, construct a local helper z=b/M when M>0. Multiply an independent beta/M estimator by an independent estimator of 1/n. Since n>=1-kappa and the small-control normalization estimator has bounded second moment, this helper has bounded second moment, mean in a fixed interval such as [-2,2], and expected cost C T. If M=0 set b=0 deterministically. In (5) use B=M.

The z helper is not inserted as an additional common-cost stored state at every layer. It is only called inside the probability-tau mean construction or the probability-a nonlinear coefficient branches. Its constant construction factor therefore does not accumulate as a fixed per-layer multiplier. The leading feature and u_noise are alternative local oracle families, not a jointly evaluated vector or a doubled persistent trace budget.

## 7. Small free step, including leading-coordinate corrections

Suppose the joint control is small and a<=a_0. For k>=2 use the two-variable factory to estimate c_k(a r_pre,b). Before each degree-k tensor product of u_noise coordinates, average ceil(kV) independent copies of every coordinate child. Its summed product second moment is at most e. Create each higher-degree coordinate with probability p_k=a/k^2. Equations (3)--(5) give total higher-degree trace increment O(a) and uniform expected coordinate cost T(1+C a).

For degree zero and one, use the already constructed leading feature as the base. Add the coefficient differences

`d_0=c_0(a r_pre,b)-c_0(0,b)`,

`d_1=c_1(a r_pre,b)-c_1(0,b)`

on probability-a branches. For degree one multiply the independent d_1 estimator by an independent u_noise coordinate; degree zero needs no coordinate product. Each coefficient estimator has second moment O(a^2).

The summed leading cross term is nonpositive:

`c_0(0,b)d_0+c_1(0,b)d_1 = <Y_b,phi_(a r_pre,b)>-1 <=0`,

because both Gaussian functions have L2 norm one. Thus the leading trace increment is O(a), without assuming separate signs for d_0 and d_1. Together with the tail this gives the same trace/cost recurrence as the centered theorem. The scalar r_next update uses the H^4 identity residual from Section 5 on another probability-a branch and also costs O(a).

## 8. Jointly large stages

If tau>=tau_0, charge the control and its immediately following free step jointly. Put rho=min(1,sigma). Copy J u and sample only K to obtain w; do not sample the infinite identity map. The centered inverse-normalization factory estimates 1/n with second moment polynomial in 1+kappa and rho^(-1). Average polynomially many copies, if needed, to make its second moment at most C rho^(-2). Construct u_noise and v_lead by the same direct products and polynomial resets as in the centered large-step argument.

With `B=max(1,M/rho)`, the local helper z=b/B now has bounded second moment and mean in [-1,1]. Its expected size is a fixed polynomial in 1+kappa, 1+M, and rho^(-1), times T. The relative variance uses delta_tot and the deterministic alpha^2, so it has the same polynomial cost and bounded true mean.

The coefficient and radial H^4 norms with this B grow only polynomially. Use p_k=min(1,a/k^2) and polynomially many averages to reset the resulting traces. If a is small, the unaveraged trace can have the form C a times a polynomial in B; a polynomial-in-B reset suffices, independent of a. If a is large the additional reset cost is polynomial in 1+a. Hence the log cost of the entire joint stage is at most

`C[tau+log(1/rho)+ell(a)]`, `ell(a)=log(a/G(a))`.     (7)

Here ell(a) is comparable to a near zero and to log(1+a) away from zero. The fixed overhead of a jointly large stage is absorbed because tau>=tau_0. In particular a large b-range normalization is never charged as a new constant factor in subsequent unrelated free layers.

For a large free step after a small joint control, the same argument has bounded B and simply gives log cost C ell(a).

## 9. Telescoping and conclusion

The deterministic recursion is

`a_j=alpha_j^2 qbar_(j-1)`, `qbar_j=G(a_j)`,

with `alpha_j^2=(1+kappa_j)^2+M_j^2>=1` and

`log alpha_j^2<=C(kappa_j+M_j)`.

Since G is increasing and G(q)=q/(1+q/2) on q<=1,

`qbar_H>=q_0/(1+H q_0/2)`.

Therefore

`sum_j ell(a_j)=log(q_0/qbar_H)+sum_j log alpha_j^2`

`<=log(1+H/2)+C S`.

Small controls and small free steps have moment increments charged to tau and a; their coordinatewise averaging resets have the same accumulated-budget bound as before. Large stages already include polynomial resets. Combining this telescope with (7) proves the proposed size bounds (1)--(2).

The argument is for arbitrary Gaussian mean and positive covariance controls, including query-dependent norms and means. It does not use a finite coordinate support bound. Nonuniform finite-bit realization requires the moment-floor precision arguments, with the ordinary two-variable Fourier-factory version; no assertion about sampling efficiency is intended.
