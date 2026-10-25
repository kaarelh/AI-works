# Rank dependence of the independent-block scalar factories

25 October 2026. Quantitative interface extracted from the fixed-rank proof, independently audited in `block-tilt-quantitative-factory-interface-audit.md`. Intended for the Poisson mixture of bounded-rank tilts. Here r>=1, 0<q<=2, and D is the block entropy. T is the old common scalar expected work; old vector trace and total-norm scalar moments are bounded by an absolute constant.

There are universal constants C and a fixed integer p such that the block residual and its total-norm increment admit coordinate formulas with common expected work at most T after balancing, and bounds of the following form:

    integrated vector residual second moment
        <= C(1+r)^p(q^2+D),

    squared-norm scalar residual second moment
        <= C(1+r)^p(q^2+D+D^2).                       (1)

Replacing the polynomial by exp(Cr) is a safe weaker interface sufficient for the proposed Poisson mixture. These bounds concern local residual factories before large-step resets; no exp(CD) reset cost is paid separately to each mixture component. Importance sampling and finite precision are nonuniform existence constructions, not efficient samplers.

## Why no exponent depends on rank

1. The block projection helpers involve at most r terms. Squared-coordinate sampling evaluates every unit-direction functional with second moment bounded by the old trace. A direct implementation of v=Ph and s-||A*h||^2 has O(r) work and O((1+r)^2) trace/scalar moments. More efficient HS sampling is possible but unnecessary. Denote this polynomial moment bound by V_r.

2. For each fixed z, the scalar tilted input is ||z|| times the unit-direction projection along Az/||z||. Its oracle moment is independent of r. The trigonometric frequency factory therefore remains one-dimensional, as does the perpendicular-norm exponential factory. No r-dimensional Fourier integral or r-dependent differentiability order is introduced.

3. The Gaussian degree k tensor factors use m=ceil(C(1+q omega^2 V_r)) averages. Their trace is at most r_perp+V_r/m, and the relative exponential factor cancels exp(q omega^2 r_perp). The remaining exponential is bounded by exp(C), independently of r and k. A k^2-weighted degree tail starts at degree two or three; its prefactor contains only a fixed power of 1+V_r. Consequently summing all k does not produce V_r^k or an exponent proportional to rank.

4. Every Poisson rate is a fixed polynomial in omega and V_r. The relative exponential second moment is a fixed polynomial factor times exp(-q omega^2 r_perp). The cosine fourth-order and exponential second-order residual moments involve only fixed powers of V_r. All remaining frequency integrals are moments of one fixed exponentially decaying proposal, of fixed order. Thus their values and their common-work balancing costs are polynomial in V_r.

5. The required tilted-coordinate caps have explicit bounds

       E min(q^2||Z||^6,||Z||^2) <= C(rD+q^2r^3),
       E min(q||Z||^4,||Z||^2) <= C(rD+qr^2),
       E||Z||^2 <= C(r+D).

   The first two follow by taking entropy dual parameter 1/(8r); the needed Gaussian exponential moments and fixed polynomial moments then have only polynomial rank growth. The degree-one quartic cap follows similarly. All scalar z-importance integrations therefore have polynomial rank constants.

6. With M=E ZZ*, ||sqrt(M)-I||_HS<=sqrt(2D), while ||M-I||_HS<=C(sqrt(D)+D). The first controls the copied linear feature correction, and the second controls the scalar norm correction. No inverse eigenvalue appears in their moments. The normalized linear isometry uses xi=M^(-1/2)z, but E xi xi*=I. Its r adjoint coordinates can be sampled with the normalized densities xi_l^2; hence their total trace costs at most a factor r, regardless of the size of M^(-1/2). Reapplying J and the rank-r projection incurs another fixed polynomial in r.

7. The total-norm scalar factory at fixed z has a polynomial-r multiple of [q+min(q||z||^4,||z||^2)]^2. Importance sampling by the bracket gives a second moment polynomial in r times (q+D)^2. Adding the linear covariance correction contributes polynomial in r times D+D^2. This gives the second line of (1).

There are only finitely many operations of fixed polynomial degree in this list. It follows that one common universal p bounds all the costs and moments. Its smallest value has not been optimized. Sparsifying a call whose expected work is C(1+r)^p T to a common T multiplies its second moment by the same polynomial; increasing p once absorbs this. The degree-k 1/k^2 creation convention preserves common coordinate work and is absorbed by the weighted degree-tail estimate.

## Consequence for exponentially integrable random rank

Suppose a mixture of such blocks has rank r<=2K and component entropy D_K<=C_0 K, where K has the weighted estimates

    E exp(aK) D_K <= C_a q^2

for every fixed a>0, and finite exponential moments uniformly in q. Then (1), after common-work balancing and integration over the component, gives O(q^2) residual trace and O(q^2) scalar norm-increment second moment: D_K^2<=C_0K D_K and every rank polynomial is dominated by exp(aK).

Restoring one literal old-coordinate copy across the component mixture requires a common linear isometry, rather than averaging component-normalized linear maps blindly. With actual mixture moment matrix M, the common map is h -> g.M^(-1/2)h. The mixture entropy is at most the average component entropy, hence O(q^2); therefore M^(1/2)-I and M^(-1/2)-I have HS norm O(q) for small q. Component moment matrices and their inverses cost at most exp(CK), which is absorbed by the same weighted estimates. Only the residual is projected between these linear realizations.

Once this common-isometry interface is supplied explicitly, rare residual creation with probability proportional to q gives 1+O(q) moment/work increments. The fixed-degree precision algebras do not depend on r or K; global fixed-seed balancing therefore remains polynomial. This last paragraph is an interface for the separately written mixture construction, not an independent check of its probability weights or entropy estimates.
