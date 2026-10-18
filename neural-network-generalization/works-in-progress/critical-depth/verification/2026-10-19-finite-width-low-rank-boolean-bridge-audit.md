# Independent audit of the low-rank target theorem

Final source: `source/critical-low-rank-bottleneck.tex`.

SHA256: `b8655c9bd07b84229e6af0ffafdecb6bc986de39d387d5bdaf33478f44145042`.

The complete frozen source passes independent mathematical audit, conditional on the existing circuit-rate and critical-learning theorems it invokes. No correction is requested.

Checks include:

1. The relevant-coordinate bound follows by squaring the bichromatic-edge inequalities and summing first-layer column norms. Random freezing of irrelevant coordinates preserves the expected first-layer squared Frobenius norm, so some freezing does not increase product; its column range, hence rank, cannot increase.
2. The reduced rank is explicitly allowed to fall below the original r. Orthogonal projection factorization gives a P-Lipschitz scalar suffix and the 2/P separation of oppositely labeled projected inputs.
3. The dyadic grid and coefficient rounding have the claimed uniform error. Every positive point lies in a selected box, while a negative point in such a box would violate the projected separation by a large constant margin.
4. All box boundaries are shifted by half a lattice step. Thus their threshold scores have nonzero margin eta/2 everywhere on the cube; scaling produces integer coefficients with margin one and polynomial magnitudes in P and r. The AND and OR layers also have integer margin one.
5. The number of boxes is at most (C P^2 sqrt(r))^r. The resulting three-stage circuit therefore has logarithmic resources O(r log(P+r+2)), with only the original Gaussian normalization contributing log(d+L+2).
6. The final rate, learner-depth, and sample bounds follow with universal constants. For fixed rank they are polynomial in P,d,L and independent of the original suffix depth and width. This does not imply a bound polynomial in ordinary teacher width and depth, since P remains an explicit parameter.
7. The approximate-SVD corollary has the correct output-error bound and rescaling factor 8/7.
