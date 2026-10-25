# Independent audit: rank-one entropy tilts and finite precision

25 October 2026. Finite-N audit agent. Conventional mathematical audit, not Lean verification.

**PASS for the stated interfaces and the restricted-path closure below.** This is not a compiler for general finite-entropy row tilts and is not an unrestricted critical-posterior theorem.

Audited snapshots:

- `nongaussian-entropy-formula-interfaces.md`: `0f0a0529f965f65dbd3505b82272e3aa4cd48286a284d9063f3835005ffdb6c1`;
- `rank-one-tilt-fock-interface.md`, through Section 10: `58edd49ab36a739a6b4eb88c274bb9d7e8ee2470e89680caeba67ca6b3669f42`;
- `same-child-multilinear-precision.md`: `2b751dc05defad42a54f3b8d34091d082058916e3c0ce8d897ce330f15ef1d2e`.

I also checked the completed theorem and closure assembled as Section 11 of the rank-one note, final snapshot `1b33b2a95496db3fe310c597ef08bc8bc9f5c698e60078e7a4786d8f990d019c`. Its statement correctly specifies a majority of rational arithmetic-sign formulas, includes the polynomial layer/precision bookkeeping, and retains independence of each tilted coordinate from its Gaussian perpendicular part.

## Entropy and scalar factories

Conditional Gaussian transport gives the claimed square-root conditional-entropy error. Its anchor interpretation is valid because the coupling preserves the entire anchor random variable. It is a one-query coupling statement and does not silently identify all query-query covariances.

The H^(3/2) cutoff estimate has the stated critical scaling; entropy controls the capped second-moment expression, but supplies neither higher moments nor a generic supercritical Sobolev bound. The direct capped tanh factory avoids the logarithmic loss of using only that Sobolev estimate. Its work/variance balancing is valid with only child second moments.

The scalar Poisson cosine and exponential identities in the rank-one note are correct. In particular, the same-child fourth-order cosine remainder is a multilinear polynomial whose monomials have degree at least four. Its second moment uses only second moments of distinct children. Although the short arithmetic expression for the pair sum displays squares, the resulting polynomial contains no squared child. The corresponding second-order exponential subtraction has the same property. Both large-parameter estimates are valid without additional moments.

## Fock trace and norm update

The relative exponential estimator contributes its full damping factor to its second moment. This cancels the true perpendicular-norm exponential in the Hermite tensor sum. The remaining averaged-child variance is bounded uniformly by the stated choice of averaging count. Odd degrees start at three and even degrees at two with an additional sine factor; consequently the integrated weighted tail is C q^2(1+z^2), as claimed.

The degree-one cap and degree-zero cap are integrable using only entropy and the Gaussian reference. No fourth or sixth moment of the tilted law is assumed. The scalar norm increment's fixed-z second moment is bounded by C[q+min(q z^4,z^2)]^2. Importance sampling with density proportional to that bracket therefore gives squared moment C(q+D)^2. The distinction between the coefficient q omega^2/2 and its product with the true perpendicular norm is handled correctly in the exponential factory.

## Arbitrary changing directions

Section 9 correctly removes the fixed-anchor requirement. Squared-coordinate sampling gives an alpha oracle of second moment at most the old trace; the local helpers v=h-a alpha and r=s-alpha^2 have bounded moments and constant expected cost. They are called only inside charged residual branches.

The map J has J*J=I because its Gaussian degree-zero and degree-one parts are orthogonal. For the small residual, J*R=a b0+P b, with b0 sampled from z^2 rho/sigma^2 and b from rho. The rank-one projection P is inexpensive in scalar coordinates. Reapplying J does not require estimating an expression that is identically zero: the degree-zero part is exactly (z/sigma)b0 and the degree-one part is exactly Pb. Thus projecting only the residual preserves its trace bound up to an absolute constant and preserves the entire query kernel. Persistent state can consist solely of the vector coordinate oracles and the total-norm scalar oracle s.

## Large steps and physical rescaling

The small-q assumption in the calculations can be enlarged to 0<q<=2 with absolute constants. All frequency losses are fixed polynomials in q and omega, integrated against an exponentially decaying proposal. Entropy caps continue to hold, and q^2 D is at most 4D. The estimates therefore give, for every D>=0,

    feature residual trace <= C(q^2+D),
    scalar norm residual second moment <= C(q+sqrt(D)+D)^2.

The Gaussian maximum-entropy inequality for the uncentered second moment gives sigma^2-1-log(sigma^2)<=2D. Since (sigma-1)^2<=sigma^2-1-log(sigma^2), the linear rank-one perturbation has HS norm at most sqrt(2D), globally. Also |sigma^2-1|<=C(sqrt(D)+D), which supplies the stated large-D scalar norm estimate.

Write b=q+sqrt(D)+D. Below a fixed threshold, rare creation gives the already stated 1+Cb trace and expected-work increments. Above that threshold, create the low-degree residual outright and each degree-k residual with probability 1/k^2. The weighted trace bound then gives polynomial-in-(1+b) trace and constant coordinate work; independent averaging resets these bounded-mean oracles at polynomial-in-(1+b) work. Its logarithmic cost is O(b). This handles every large step without a q^(-1) loss: the factory formulas and caps have already cancelled that factor.

For an actual path q is the maximum incoming physical squared norm. Initially q<=2; after a tanh layer q<=1. The existing metric-retention theorem applied to a maximizer and the zero vector gives

    log_+ sqrt(q_j/q_(j+1)) <= C(q_j+sqrt(D_j)+D_j).

Vector rescaling and squared rescaling of the scalar norm oracle can therefore be charged to the same budget, with averaging resets when necessary. No lower bound on an individual query norm or on q_j is added as a hypothesis.

It follows that the restricted independent rank-one-tilt path has expected scalar complex-formula size bounded by initial resources times exp(C sum_j(q_j+sqrt(D_j)+D_j)), with uniformly bounded vector trace and scalar norm moments. A readout and positive margin add their ordinary polynomial dependence. Directions may change arbitrarily, but the tilted scalar coordinate must be independent of the Gaussian perpendicular coordinates at each layer.

## Finite precision and continuous coordinate spaces

The independent-noise multilinear coefficient lemma in the precision note is correct: after conditioning on a simultaneous bounded-base event of probability at least one half, Walsh orthogonality and triangular translation inversion bound every normalized coefficient by exp[O(K log(K/gamma))] times the parent RMS.

The degree-category algebra avoids expanding all monomials. Each parent monomial has a unique decomposition between the two disjoint child blocks, so the maximum-coefficient normalizations give internal coefficients of magnitude at most one. The explicit six-category algebra handles the fourth-order cosine remainder, and the three-category algebra handles the real exponential remainder. These are the additional factories needed for the scalar norm update.

One global fixed-dimensional vector-algebra balancing operation yields polynomial scalar formula size. Applying scalar expansion separately at every recursive layer would not suffice; the proof correctly postpones that expansion until the entire seed is fixed. Conditional RMS normalization cancels singular Fourier factors, and the mixture-to-full-RMS ratio has squared expectation one. The expected-call-count selection therefore bounds the finitely realized coefficients without a lower frequency cutoff or lower coefficient-size hypothesis.

The direct-integral extension is legitimate for measurable standard-Borel coordinate spaces. Coordinate moments and sampling kernels are measurable; Tonelli supplies the same trace bounds. Fresh independent noise is generated only at each finite requested call, so no uncountable independent random field is needed. A fixed seed selects only finitely many real constants. These facts supply the polynomial-bit completion for this restricted path construction.

## Scope that remains open

An arbitrary conditional tilt of a scalar coordinate given the perpendicular Gaussian coordinates is not covered. Nor does a general finite-dimensional density factor into independent rank-one tilts with comparable cost. The result establishes a genuinely non-Gaussian restricted path compiler; a bridge from all finite-entropy posterior paths remains necessary for the original critical problem.
