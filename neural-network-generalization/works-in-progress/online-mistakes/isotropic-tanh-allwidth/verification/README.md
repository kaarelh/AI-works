# Build and proof status

The paper gives a conventional analytic proof and is **not Lean formalized**. Independent AI-agent component reviews and integrated theorem/proof reviews passed.

The reviews covered the eventual sharp single-parity theorem; the periodic response, lattice localization, uniform residual central-limit estimate and equal-bulk bias bound used to prove it; affine support stability; the exact code norm; cost ordering and physical rounding; teacher resources; and the finite-width Gaussian posterior comparison. The carrier construction uses the odd downward Fourier space throughout.

The main theorem has `d=Θ(m³)`, a same-depth bounded-weight teacher of width `C=O(m⁴)`, and `exp(Ω(√m))` designated errors. One fixed input permutation works for every sufficiently large fixed finite width, followed by the strong-prior limit. The sufficient parity-degree and learner-width thresholds are existential. No scale threshold uniform over all learner widths is claimed.

All analytic and finite-width steps are proved in the PDF. The positive-curvature certificate in [certify_curvature.py](certify_curvature.py) uses exact rational interval arithmetic; floating point is used only to display certified endpoints. Numerical optimization is not a premise.

[Build record](build-record.json) records source/PDF hashes, an isolated three-pass rebuild, the exact certificate rerun, and visual inspection of the first and main-theorem pages.
