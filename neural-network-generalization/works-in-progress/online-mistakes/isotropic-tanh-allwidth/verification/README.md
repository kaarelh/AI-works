# Build and proof status

The paper gives a conventional analytic proof and is **not Lean formalized**. Independent AI-agent component reviews and integrated theorem/proof reviews passed.

The reviews covered the eventual sharp single-parity theorem; the periodic response, lattice localization, uniform residual central-limit estimate and equal-bulk bias bound used to prove it; affine support stability; the exact code norm; cost ordering and physical rounding; teacher resources; and the finite-width Gaussian posterior comparison. The carrier construction uses the odd downward Fourier space throughout.

The main theorem has `d=Θ(m log² m)`, a same-depth bounded-weight teacher of width `C=O(m² log² m)`, and `exp(Ω(m))` designated errors, giving `exp(Ω(√C/log C))`. One fixed input permutation works for every sufficiently large fixed finite width, followed by the strong-prior limit. The sufficient parity-degree and learner-width thresholds are existential. No scale threshold uniform over all learner widths is claimed.

The improved resources use three independently checked steps: whole-set parity determinants and a sum over the number of switched rails; high-order local vanishing with the same switch count; and a triangular path transfer with a common boundary term. Scalar Walsh signs and dominance follow from the inverse Laplace kernel's positivity near zero. Repeated physical columns realize the two larger logical increments without violating the rail-size condition.

All analytic and finite-width steps are proved in the PDF. The positive-curvature certificate in [certify_curvature.py](certify_curvature.py) uses exact rational interval arithmetic; floating point is used only to display certified endpoints. Numerical optimization is not a premise.

[Build record](build-record.json) records source/PDF hashes, an isolated three-pass rebuild, the exact certificate rerun, and visual inspection of the first and main-theorem pages.
