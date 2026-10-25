# Low-product arithmetic formulas for a Fourier-increment activation class

25 October 2026. Research note by `/root/critical_nongaussian_formula`, developing the Fourier-increment observation and mixed-normal-form proposal from `/root`. Candidate for independent audit. This extends the low-product structural theorem; it does not by itself import a posterior energy ceiling for a new activation.

## 1. Hypotheses and theorem

Fix a real activation phi with the following properties.

1. phi(0)=0, phi is globally 1-Lipschitz, and |phi|<=A for a fixed finite A.
2. For some fixed kappa>0, c>0 and r0>0,

       |phi(u)-u|<=c |u|^(1+kappa)   for |u|<=r0.

   On an interval about zero phi has a continuous inverse, and |phi^(-1)(v)|<=C|v| there. For example, a continuously differentiable activation with phi'(0)=1 and the displayed remainder satisfies this local inverse condition after shrinking the interval.
3. There is a complex Radon measure nu on R\{0}, with sigma-finite total variation, such that

       phi(u)=integral (exp(i omega u)-1) nu(d omega),
       M=integral |omega| |nu|(d omega)<infinity.

   The integral is absolutely convergent for each real u, since the increment is at most |omega u|. It is assumed real-valued. No efficient sampler, coefficient algorithm, or lower bound on Fourier frequencies is required.

**Structural theorem.** There are constants a,c_phi, depending only on this fixed activation and the displayed constants, such that a Boolean function on {-1,1}^d with a globally unit-margin phi network of arbitrary finite depth/width and Frobenius product P has a rational arithmetic-sign formula ensemble of total size at most (d+P+2)^a and polynomial coefficient bit length. After balancing and clearing denominators, it has an integer arithmetic-sign circuit of polynomial size and logarithmic depth. Thus polynomial product implies nonuniform PNC1, hence L/poly.

The activation need not be odd or analytic. The theorem covers tanh, normalized erf, arctan, and softsign. Its conclusion is an alternative representation of the Boolean function; it does not say the original weights or the activation are efficiently evaluable.

## 2. Exact Fourier-increment factory

Suppose X(x) is an unbiased scalar oracle for a(x), has second moment at most V>0 uniformly over the finite input domain, and expected arithmetic-formula work at most T>=1. At a frequency omega, let

    lambda=1+omega^2 V,
    K~Pois(lambda),
    Z=product_(j=1)^K (1+i omega X_j/lambda),

with independent child calls. Then

    E Z=exp(i omega a),
    E |Z-1|^2=exp(omega^2 E X^2/lambda)-2cos(omega a)+1
                <=C min(omega^2 V,1).

The expected complex formula work is at most C(1+omega^2 V)T. The subtraction of one is kept in its short expression or degree-category form; it is not expanded into unrelated independent terms.

Put v(omega)=min(omega^2 V,1), c(omega)=1+omega^2 V, and

    I=integral sqrt(v c) d|nu|,
    J=integral sqrt(v/c) d|nu|.

Since sqrt(min(a^2,1)(1+a^2))<=sqrt(2)a for a>=0,

    0<J<=I<=sqrt(2V) M<infinity

unless nu=0, which is trivial. Sample omega from the probability measure with density sqrt(v/c)/J relative to |nu|. Multiply Z-1 by the corresponding importance weight and the complex phase dnu/d|nu|, and take the real part. This gives an unbiased estimator U of phi(a) satisfying

    (E work(U)) (sup_x E|U(x)|^2) <= C M^2 V T.       (1)

Indeed E work<=CT I/J and E|U|^2<=CJI. The distribution of the expression, including its frequencies, is input-independent. Infinite mass of nu near zero causes no problem: J is finite by the weighted first-moment hypothesis. No second Fourier moment is used.

Averaging or a Bernoulli return-and-rescale operation balances work and moment as in the tanh construction. Coordinatewise cost-aware sampling through a matrix therefore gives the same potential recurrence as for tanh, with one fixed activation-dependent factor per retained layer. The joint work-second-moment quantity, not either quantity alone, is the invariant.

## 3. A short mixed-activation normal form

The normal form need not use phi in its replacement suffix. Keep a short phi prefix and attach the already constructed ordinary-tanh nearest-center classifier. Both activations have the factory (1). This avoids requiring a tanh-like saturation rate, nonzero curvature at a specified point, or a quantitative step approximation from phi.

### Relevant coordinates and two balls

The relevant-coordinate argument and the two-ball cover use only zero preservation and 1-Lipschitzness. They give at most P^2 relevant input coordinates. After j=O(log(P+2)) prefix layers, a polynomial number of normalized prefix centers separates opposite labels by an inverse polynomial distance. These statements hold unchanged for phi.

### Width compression at short depth

The existing width-compression proof for tanh needs two additional facts beyond Lipschitzness: bounded activation values and a polynomial local linearization remainder. Both are assumed here. The following modifications make the dependence explicit.

At a pair of adjacent matrices W,V, put S=the preceding product, A_pair=||W||F||V||F and P_*=an upper bound on the current full product. Allocate output error e and pair-product increase eta. Delete rows with S||w_i||>B, where

    B=A P_*/e.

Their activation norm is at most A times the square root of their count, giving output error at most e. For small rows S||w_i||<tau, replace phi by the identity, where

    tau<=r0/R,
    c P_* tau^kappa R^(1+kappa)<=e.

The vector linearization error is at most c tau^kappa R^(1+kappa) S||W||F, so propagation gives the displayed output bound.

Middle-row sampling is unchanged. In particular, incoming row norms lie in [tau/S,B/S], the ratio parameter is Q=(B/tau)^2, and the number of samples is polynomial in P_*,R,e^(-1),eta^(-1),log(2|X|). It keeps ordinary phi at every sampled neuron.

For the truncated small-row linear branch B_k=UV0 of nuclear norm nu, use K replicated channels with incoming rows sqrt(c0/K)V0 and outgoing columns U/sqrt(c0 K), as in the original proof. Its propagated error is at most

    C P_* (c0 nu S^2/K)^(kappa/2) R^(1+kappa).

Here c0 is the balancing scalar of that proof, not the activation remainder constant. The previous middle-branch estimates bound c0 nu S^2 by a polynomial independent of original widths. Choose K polynomially large, and additionally large enough to keep all replicated preactivations inside [-r0,r0]. This preserves the exact pair Frobenius-product bound. Since kappa is fixed, all new widths are polynomial in the same short-prefix resources.

### Constant rail and tanh suffix

After width compression, the retained width C is polynomial in P. Boundedness and the global margin imply each retained prefix product S_s<=A P sqrt(C). Choose a positive epsilon with inverse polynomial in P and epsilon S_s inside the local inverse interval. Supply one constant rail with exact outputs epsilon S_s. Its first weight is phi^(-1)(epsilon S_1), and subsequent weights are phi^(-1)(epsilon S_s)/(epsilon S_(s-1)). Each is at most a fixed constant times the corresponding original Frobenius norm. The rail therefore multiplies the prefix product by only a fixed constant to the power j, which is polynomial in P.

Normalize the interface using S_j and the rail, and attach the ordinary-tanh squared-distance classifier from normal-form.tex. It has two hidden layers, polynomial width and polynomial product, and robust margin. The result is a mixed network: phi on the retained prefix, tanh on the new suffix, depth O(log(P+2)), width and product polynomial in P.

### Physical weights and rounding

Tiny prefix products can cause large interface coefficients. The physical-weight lemma extends to the mixed network. Set kappa_*=min(kappa,2); on a fixed neighborhood of zero both activations have remainder bounded by C|u|^(1+kappa_*). Replace activations at layers with original prefix product less than tau by the identity, taking

    tau<=r_*/R,
    C P D tau^kappa_* R^(1+kappa_*)<=1/100.

The telescoping error is small. Collapsing linear runs leaves ratios of retained prefix products bounded polynomially in P,D,C,R, because every retained product is at least tau and at most max(A,1)P sqrt(C). Double the readout to restore a strict margin. Ordinary matrix perturbation and 1-Lipschitzness then allow dyadic rounding with O(log^2(P+2)) bits at the retained logarithmic depth. No activation evaluator is used in this argument.

## 4. Finite bits and arithmetic complexity

There is a direct bounded-frequency approximation proof, so no quantitative tail assumption on the Fourier measure is hidden in the finite-bit step.

First use the exact mixed normal form. Let B>=2 be polynomial in d+P and bound all its dimensions, weights and preactivation magnitudes; retained depth D is O(log(d+P+2)). Choose a tolerance delta with

    log(delta^(-1))=O(log^2(d+P+2))

small enough that replacing each phi evaluation by a uniformly delta-close function on [-2B,2B] changes the final output by at most 1/10. For example the elementary row-sum propagation bound D sqrt(C) [B max(1,2M)]^D times delta suffices, after enlarging B. The truncated activation is at most 2M-Lipschitz; this fixed factor at logarithmic depth is harmless. The activation's boundedness and delta<=1 ensure inductively that all hybrid preactivations remain in [-2B,2B].

Define the deterministic approximation

    phi_(eta,U)(u)=a_eta u+Re integral_(eta<=|omega|<=U)
                                  (exp(i omega u)-1) nu(d omega),
    a_eta=Re integral_(0<|omega|<eta) i omega nu(d omega).

The low-frequency Taylor remainder and high-frequency amplitude bound give

    |phi(u)-phi_(eta,U)(u)|
       <=(M eta/2)|u|^2+2M/U.                         (2)

Choose eta>0 small and U large enough to make (2) at most delta on that interval. Their logarithms have magnitude O_phi(log^2(d+P+2)). This is an explicit deterministic replacement with controlled bias, not conditioning an unbiased estimator on a frequency cutoff and continuing to call it unbiased.

The truncated Fourier branch still has the work-moment bound (1). The linear branch a_eta X has moment at most M^2 V and work T. Combine the two by cost-aware two-branch sampling: for moments v_i and works t_i use branch probability proportional to sqrt(v_i/t_i). The product of resulting work and moment is at most C(sum_i sqrt(v_i t_i))^2, hence C_phi VT. One can use the upper bound M^2V for the linear branch even if a_eta vanishes; no division by that coefficient is required.

To bound internal scales, fix once and for all a compact frequency band a<=|omega|<=b having positive |nu| mass. Such a band exists because phi is not zero. Enlarge U and decrease eta so every truncation contains it. On this band,

    J>=c_phi min(sqrt(V),1/sqrt(V)),
    I<=sqrt(2V)M,
    J<=I.

Thus the deterministic positive work and moment bounds for the truncated factory, its linear branch, and the cost-aware mixtures have logarithms growing by at most a fixed factor at one retained layer. The original rounded matrix coefficients have polynomial logarithmic size; induction through D=O(log(d+P+2)) layers gives polynomial logarithmic bounds on all internal deterministic quantities and their inverses. The full work-moment product remains polynomial because it accumulates only fixed activation factors and squared Frobenius norms.

All sampled frequencies now lie between eta and U. Their importance coefficient has modulus

    J sqrt((1+omega^2 V)/min(omega^2 V,1)),

whose logarithm is polynomial by the preceding bounds. The Poisson coefficient omega/lambda has the same property. Every other coefficient is an original bounded matrix coefficient, a cost-aware sampling weight whose normalization has polynomial logarithmic bounds, or the bounded scalar a_eta. Thus a good realization with polynomial total formula size has all coefficients of modulus at most exp(poly(d+P+2)), without any probabilistic tail estimate for nu.

Average and take O(d+1) independent groups as in the tanh proof. Chebyshev, Chernoff and the union bound over 2^d inputs give a positive-probability simultaneous strict-margin event, and Markov also bounds total work polynomially. Fix such a realization. The existing formula-constant rounding estimate then gives polynomial bit length; clearing denominators and one global fixed-dimensional real-affine balancing give polynomial-size logarithmic-depth integer arithmetic circuits. Median/majority closure yields PNC1.

This proves the structural theorem. The argument uses only the weighted first Fourier moment, together with the explicit deterministic approximation (2), and does not assume an efficient sampler or an effective convergence rate for the original Fourier integral.

## 5. A convenient sufficient spectral condition and examples

If phi is continuously differentiable and

    phi'(u)=integral exp(i omega u) mu(d omega)

for a finite complex measure mu with no atom at zero, then condition 3 follows by integrating in u and taking nu(d omega)=mu(d omega)/(i omega). The weighted moment M is ||mu||TV. All following derivative measures are positive probabilities, so M=1.

* Normalized erf: phi(u)=integral_0^u exp(-s^2)ds=(sqrt(pi)/2)erf(u). Its derivative is the characteristic function of N(0,2). It is bounded, odd, 1-Lipschitz, locally invertible, and has cubic remainder.
* Arctan: phi(u)=arctan(u). Its derivative 1/(1+u^2) is the characteristic function of the probability density (1/2)exp(-|omega|). The remaining hypotheses hold with cubic remainder.
* Softsign: phi(u)=u/(1+|u|). Its derivative is (1+|u|)^(-2), including at zero. The identity

      (1+|u|)^(-2)=integral_0^infinity t exp(-t) exp(-t|u|)dt

  represents it as a positive mixture of Cauchy characteristic functions; the mixing density t exp(-t) has mass one. The resulting spectral measure has no atom at zero and total mass one. Its local remainder is bounded by |u|^2, and its local inverse is v/(1-|v|). Analyticity and a cubic remainder are unnecessary.

Tanh itself fits with the familiar nonnegative Fourier measure for sech-squared. None of these verifications uses a numerically efficient exact sampling procedure.

The coded analytic activation from analytic-activation-depth-lower also satisfies this Fourier hypothesis, including its all-derivatives-bounded variant. For a single bump

    f(u)=delta b_rho((u-c)/r),
    b_rho(v)=(1+rho v)^3 exp(-v^2),     |rho|=r/|c|<=1,

the Fourier L1 norm of f' is at most C delta/r. This follows by scaling and the uniform Fourier L1 bound for b_rho', a fixed-degree polynomial times a Gaussian. In the growing-order construction there are 2^d bumps at level d and delta_d/r_d=tau 2^[-(m_d-3)d], so their derivative Fourier norms sum to at most

    C tau sum_d 2^[-(m_d-4)d]<infinity.

The constant-order original construction has the same summability. Add the finite Fourier measure of sech-squared and the reflected perturbation. The resulting activation has a finite derivative Fourier measure and all the local normal-form properties. This does not contradict its posterior lower bound: the coded teachers have large Frobenius product, and the structural theorem concerns low-product representatives. It also emphasizes that Fourier compressibility is not an assertion of efficient numerical evaluation of the activation.

## 6. Scope for Bayesian consequences

This theorem can be combined with any separately established posterior ceiling that places most posterior functions in a polynomial-product class. It does not prove such a ceiling for a new activation, and it does not change the unresolved arbitrary conditional-tilt problem at gamma=1. The exact original tanh posterior consequences remain as stated in the main paper.

The hypotheses exclude ReLU/GELU because boundedness is used in the short normal form, and the increment spectral condition as stated does not cover their distinct asymptotic slopes. One should not infer the theorem for all Lipschitz activations or all smooth bounded activations merely from these examples.
