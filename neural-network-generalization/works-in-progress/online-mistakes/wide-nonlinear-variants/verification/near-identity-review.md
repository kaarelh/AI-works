# Independent audit of `relu-near-linear.md`

I checked the original leaky-ReLU proof and the general-activation addendum. No mathematical error found. This is a genuine arbitrary-width result with the original appended-constant bias convention, but the activation depends on k and L and approaches the identity exponentially fast in k. It does not establish a fixed-activation theorem.

* The width-uniform linearization error follows by telescoping across L-1 activation locations. Each factor is bounded by the corresponding Frobenius norm, and the weighted Gaussian coefficients multiply to d. Therefore the proposed error bound is independent of width N even though individual first-layer norms can grow with N.
* The extra next-point affine margin constraint adds at least 4/(d+1) to squared minimum norm. This uses the projection variational inequality for the previous convex training constraint set, not a claim of convexity for global sign constraints.
* The balanced scalar path is a valid width-N network: place the path in one coordinate, balance first-layer coefficient d/N and final coefficient N, and set all other weights to zero. For leaky ReLU, positive downstream factors give exact attenuation alpha^(L-1) on the negative branch and no attenuation on the positive branch.
* The energy U_t is therefore a feasible weak-margin upper bound, approached from the strict-margin region by readout scaling. The proof never needs it to be the true minimum energy of the wrong function.
* At energy <=U_t, delta<=1/(128 p Q_*) follows from alpha^m>=1/2. With h=4/(pQ_t)<=1/2, (1-2delta)^2(1+h)>=1+h-6delta; the displayed constants then strictly dominate alpha^(-2m)<=1+8m eps. Thus every correct-at-next-query parameter has energy strictly above U_t.
* Coercivity of the finite-dimensional quadratic energy and closed weak-margin constraints promote nonexistence at energy <=U_t into a strictly larger attained infimum for the correct-label cell. A strict wrong region of smaller energy yields actual posterior concentration, irrespective of possible ties among wrong predictors.
* The teacher at depth k+2 has coefficients <=2 and output margin >1/2. A width-one, coefficient-one teacher would contract the first affine score; after sign orientation the carry constraints force its top coefficient beyond one, proving C_L=2. At every L>=k+2, weight-one extra layers preserve the conclusion because epsilon is selected using m=L-1 and alpha^m>=127/128.

## General activation addendum

The conditions phi(0)=0, Lipschitz constant <=1, and |phi(s)-s|<=eps|s| suffice. For eps<1, phi preserves sign and satisfies alpha|s|<=|phi(s)|<=|s|. A scalar chain with positive weights therefore has the desired sign and magnitude at least alpha^m times its linear product, regardless of how the scalar weights were balanced. This is why positive homogeneity is not needed for the extension. The same contraction and sign arguments prove the lower teacher-complexity bound. Lipschitz continuity also supplies open strict sign cells for the Gaussian argument.

The smooth example phi(s)=(1-eps)s+eps tanh(s) satisfies all assumptions since its derivative lies in [1-eps,1] and |s-tanh(s)|<=|s|. The asymptotic caveat remains the same: eps must decay exponentially in k, so this is an activation family rather than one fixed nonlinear model.
