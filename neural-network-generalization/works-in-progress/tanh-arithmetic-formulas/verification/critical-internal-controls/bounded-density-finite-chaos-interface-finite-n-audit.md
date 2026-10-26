# Independent audit: bounded-density finite-chaos interface

26 October 2026. **PASS for the fixed-degree local theorem as stated.** Source `bounded-density-finite-chaos-interface.md`, SHA256 `c0fca54a89a73fc7f0573e9c901362802b75a6a192d45900f0b58bbbee8d8818`.

The constants depend on the fixed polynomial degree k and density bound M, and the entropy threshold also depends on them. The note expressly does not give an exact-tanh path compiler or a sample upper bound. The earlier moment-floor finite-bit machinery is an import in this audit.

## Partial-contraction algebra

The Gaussian product formula puts the finite-chaos covariance perturbation into a finite sum of maps with identity strands and one Hilbert--Schmidt coefficient tensor. The density tensors up to degree 2k have total squared norm at most `C_M D`, using the pointwise bounded-density entropy comparison. Thus the diagram norm is `O_k(sqrt(C_M D))`.

I checked the potential dimension-factor obstruction in composition. At one composition interface, a surviving identity strand continues to an external leg or connects a leg of one coefficient tensor to a leg of the other. There is no closed identity loop and no trace of a single unrestricted Hilbert--Schmidt tensor. After expanding the intermediate symmetric projection as an average over permutations, every term contracts two different coefficient tensors, has Hilbert--Schmidt norm at most the product of their norms, and leaves only through strands. Contract all edges shared by a pair of tensors before merging their vertices; this same argument continues through compositions with cycles. The block-sum completion is therefore an operator-norm-dominating Banach algebra. The distinguished whole-space identity is a unit of norm one. The square-root power series converges in this algebra when the diagram norm is at most 1/2, and agrees with the positive operator square root.

## Scalar factories and norm correction

For a basic diagram, the proposed importance distribution over contracted indices gives integrated second moment bounded by the squared coefficient Hilbert--Schmidt norm times a fixed power of the integrated child second moment. This is ordinary Cauchy--Schwarz on the coefficient tensor and the tensor product of the coordinate moment profile. Remaining through strands contribute further independent child factors; symmetrization is an average and does not increase the estimate. Fixed-degree averaging brings the child moment to at most `1+1/k` at a cost depending only on k.

Sampling the absolutely summable square-root expansion by diagram weight preserves the squared norm estimate. Its infinitely many internal contractions become nonuniform coefficient tensors. A realized scalar expression still contains at most k fresh child factors, rather than a number proportional to the length of the algebraic power-series word. This distinction is essential and is correctly used.

The polynomial feature has a literal degree-one copy of h plus a residual of size O_k(q). Applying the covariance square root adds residual size `O_(k,M)(sqrt(D))`. The squared-norm correction is computed directly from the original finite Gaussian product expansion, avoiding the variance of squaring a randomized vector. Its coefficient weight is `O_(k,M)(q+sqrt(D))`. These yield the local rare-creation estimate under the stated existing oracle interfaces.

## Approximation and scope

Taylor expansion through the next even order, whose coefficient is zero, gives the global remainder `C_m |z|^(2m+3)`. Gaussian moments and the density bound yield the displayed L² coupling error `C_k sqrt(M) q^(m+1)`. The note correctly does not claim uniform constants as k grows, propagation of that error through a long path, or an exact-tanh conclusion.

## Sampling correction and polar refinement, fresh audit

**PASS for revised Sections 1–8**, source SHA256 `cfa95492541fce5df7b983be3c59195c3ade1ac1274fe9cfdec412806a204887`. The following clarifications were required before this final signoff.

The first version of Section 4 used coordinate second moments in the importance probabilities; those moments can depend on the input under a pointwise trace invariant. The author replaced them by coefficient-column squared norms, independent of the input. With `p_I=||C_(.,I)||²/||C||²`, integrated output second moment is at most `||C||² sum_I product_j E|X_ij|²`. For a general tensor-coordinate state with identity indices J it is at most `||C||² sum_(I,J) E|X_(I,J)|²`. This repairs the random-expression-shape promise without changing any theorem bound. The earlier PASS should be read together with this implementation correction.

The exact Gaussian baseline requires a raw-ball residual oracle, not a free conversion of h to h/||h||. I checked the explicitly cited public nonlinear-residual lemma in `tanh-arithmetic-formulas/source/non-gaussian-controls.tex`: set alpha=0 and use the stored squared-norm oracle. Degree-l work is O((l+1)T), while the sum of l²-weighted residual moments is O(q²). Thinning a degree-l branch by a constant times (l+1)^(-2) gives common O(T) work and total O(q²) trace. This construction uses relative exponential damping and does not divide by an arbitrarily small query norm.

The normalized Gaunt coefficient has square equal to a product of three binomial coefficients and is at most 2^(4k) for chaos indices at most k. The polynomial number of choices is absorbed in C^k. Hence the diagram perturbation and square-root bounds have the claimed exponential rather than unspecified superexponential dependence on k.

For the polar decomposition, `J=A iota_1 Sigma^(-1/2)` is an isometry because `A²=B` and `Sigma=iota_1* B iota_1`. Applying J* gives exactly the first coordinate in equation (7); the orthogonal complement gives its second coordinate. Gaussian entropy bounds the Hilbert–Schmidt norms of `Sigma^(1/2)-I` and, for small D, `Sigma^(-1/2)-I` by O(sqrt(D)). Thus the linear correction has no degree-dependent loss. Every difference in the nonlinear operator contains one small diagram factor and one R_k, giving moment C^(2k)q²D by the general tensor-state factory above.

The scalar norm oracle needed a separate proof: a trace bound alone does not cheaply sum inner products along identity strands. The final version supplies it explicitly. I independently derived the same two-frequency construction. Gaunt shared strands become powers s^ell of the stored norm, leaving a density tensor contracted with h^(a+b-2ell). Averaging coordinate children O(eta^-1) times and norm children O(eta^-2) times, with eta comparable to 1/[1+q(omega²+nu²)], gives moment at most (s+eta)^(a+b). Relative damping cancels its true-s exponential. The proposals omega*kappa(omega) and nu*kappa(nu) avoid a low-frequency singularity when one chaos degree is one. For a+b>=4, the two factorial-series bound `xy(x+y)² exp(x+y)` leaves an integrable O(q²(omega²+nu²)²) factor after normalization. The (1,1) term is handled by the relative exponential residual after subtracting the linear covariance correction. All frequency work has fixed polynomial degree, while Gaunt factors and the finite degree sum cost C^k. This proves the claimed exact norm-correction factory.

Finally the low-chaos rho feature is matched isometrically. Its actual high-chaos remainder need not be orthogonal under rho; bounded density gives norm at most sqrt(M) times the Gaussian tail, and placing the retained Gaussian tail in a new orthogonal summand gives the stated triangle-inequality error. This does not assume a false rho-orthogonality.

The final local increment is O(q+sqrt(D)+C^k q sqrt(D)) under the smallness condition stated in the note. Section 8 is only a budget observation; extending the reference to arbitrary ridge laws, proving an optimal-path excess-entropy decomposition, and controlling accumulated approximation errors remain unproved. No exact-tanh full-path or posterior conclusion is certified here.
