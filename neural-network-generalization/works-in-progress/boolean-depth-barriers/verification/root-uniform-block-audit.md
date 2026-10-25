# Root audit of the uniform moving-prefactor argument

24 October 2026. Conventional mathematical audit, not Lean verification.

I checked the assembled `uniform-moving-prefactor-converse.md` against the original task conventions and the earlier fixed-prefactor and critical constructions. The new structural argument passes. This audit does not replace the separate proofs of the imported target-mass and bounded-dual finite-width extraction theorems.

The crucial improvement over the withdrawn hybrid is substantive. Grouping b=ceil(c/a) transitions gives O(S) blocks, while each good block has a dimension-independent finite cover. A per-layer two-ball cover would still have exp(S/a) prototypes and would not prove the result.

Specific checks:

* The matched Gaussian uses the uncentered second moment. Its entropy decomposition is valid with nonzero means. Projection to the anchor coordinates contracts non-Gaussian entropy; the independent free complement contributes zero to that entropy. Preserving the anchor covariance suffices after the canonical coordinate change.
* The scalar excess e controls original non-Gaussian entropy. Its prefix sum is O(aS) by stopping before the last q<=a state. Maximum-diagonal occupation is O((1+sqrt(K))S), which is the needed sublinear dependence on the large fixed prefix multiplier K.
* Original and Rao--Blackwellized diagonals are not silently identified. The global bound P_j<=2W Gamma makes an inverse-polynomial normalized coupling error an H^-2 physical error. This gives an O(1) change in total diagonal occupation.
* Polar decomposition is legitimate in the finite Gaussian feature coordinates. The Hilbert--Schmidt bound ||Sigma^(1/2)/t-I||^2<=2D_gauss follows from the scalar Gaussian entropy inequality. Rectangular isometries do not introduce a dimension factor in the block telescoping bound.
* The nonlinear block residual is only controlled on actual query states. Choosing actual representatives inside each linear-cover cell gives the required cover without asserting an ambient-ball residual bound. The initial actual-center convention absorbs the one otherwise missing factor two.
* High-Gaussian-cost blocks are counted by the raw prefix budget. High-nonlinearity blocks are counted by diagonal occupation plus the square-root non-Gaussian entropy sum. Choosing c, r0, eta, K in that order makes a fixed positive fraction of the O(KS) blocks good. The covering constant can be enormous, but is independent of t and all varying problem resources.
* The suffix scale is handled correctly. Subtracting log P_J from the tangent radius produces sum h_j/a, and h_j<=e_j bounds this by O(S). Using the total raw action here would incorrectly leave a V*/a term.
* The long prefix has O(S) residual budget after normalization; its possibly polynomially many time indices are evaluated in parallel by the established Volterra/Picard construction. Radius flooring preserves actual trajectories and adds only a constant to the budget. All lookup and distance precisions are inverse polynomial in exp(S).
* The short-depth branch aH=O(S) reduces to the critical argument with action V*+O(S^2/H). The away-from-critical branch has a uniform positive spectral gap. Together they cover arbitrary moving t in (0,1], rather than only every separately fixed t.

The resulting conclusion remains a necessary circuit-complexity condition for the original posterior: a universal joint-polynomial sample guarantee would imply P/poly=nonuniform TC^1. It neither proves an unconditional exponential-depth lower bound nor establishes a polynomial-depth upper bound for arbitrary bounded-weight tanh teachers.
