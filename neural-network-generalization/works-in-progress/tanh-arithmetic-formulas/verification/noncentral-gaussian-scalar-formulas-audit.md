# Independent audit of the noncentral Gaussian extension

25 October 2026. Audit by the fresh-canonical-depth agent of
`noncentral-gaussian-scalar-formulas.md`. Verdict: PASS for the stated
exact real-formula construction, with the original augmented-input norm
q0<=2 extension included in the assembled TeX. The finite-bit ingredients
have separate audit records.

The normalization is semantically exact. With w=A u, n=||w||,
beta=m dot u, and b=beta/n, the physical preactivation equals
sqrt(a r_pre) (G dot u_noise+b)/sqrt(1+b^2), using the definitions in
Section 2. The leading degree-zero/one feature is exactly
(beta,w)/sqrt(n^2+beta^2). Query-dependent means and diagonals do not
invalidate the Hermite kernel identity: each query uses its own scalar
coefficients while correlations are powers of the common Gaussian-direction
inner product.

The shifted standardized Gaussian Y_b has uniform fixed moments and uniform
fixed-order derivative bounds in b. F(t,b)/t has a uniform positive lower
bound for t<=1, and F(t,b) has one for t>=1. The psi representation therefore
justifies the mixed derivative estimates. The weighted tail identity
sum_(k>=2) k^2 c_k^2<=8t^2 follows directly from the second Gaussian
derivative and is valid at all shifts. The H4 estimates on the rescaled
rectangle follow by differentiating in t and observing that every tail
coefficient vanishes at t=0 for every b. The two-dimensional density with
power four has the required finite fourth moment for real O(K^2) formula
expansion; power three would not suffice, and is not used here.

The small joint-control construction correctly charges the new beta
coordinate by a probability-tau branch. Both normalization corrections
come from Hilbert--Schmidt quadratic forms, so their moments and costs have
the claimed orders. The b/M helper is constructed rather than assumed, and
is used only on rare branches. The u_noise and leading-feature families
are alternative transient oracle families; they do not double the persistent
trace budget. In the free step, the sum of the degree-zero/one cross terms
is nonpositive by the unit-norm Gaussian inner-product identity. Independent
coefficient and tensor children give the stated tail and radial bounds.

For jointly large controls, the lower singular value is explicitly charged.
The bound |b|<=M/rho justifies the local rectangle rescaling. All corresponding
Sobolev, helper, and reset costs are polynomial in the stage parameters;
they are charged once to that joint stage. This prevents a hidden fixed
factor at unrelated later layers. Copying J while sampling K avoids the
infinite-Hilbert--Schmidt-identity error.

The tanh envelope is correct, including its scalar comparison proof. It
gives the exact deterministic G(a) recursion and logarithmic telescope.
For the original q0=(d+1)/d in [1,2], the first post-step upper variance is
at least G(q0)>=2/3, and thereafter reciprocal cooling gives c/(H+1).
Thus the same O(log(H+1)+S) telescope holds without the initial q0<=1
restriction in the development note.

The final normalized direction uses the same physical readout v. Its output
is z(x)/||h_H(x)||, so signs agree and the margin cannot decrease because
||h_H(x)||<=1. No query-dependent norm is incorrectly absorbed into a
constant readout coefficient.

All-Gaussian control paths are covered, including nonzero means. Arbitrary
non-Gaussian finite-entropy tilts and the unrestricted posterior are not.

