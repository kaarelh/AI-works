# Verification

This package contains a standalone LaTeX manuscript and independent mathematical review records. These are AI proof audits, not Lean verification.

The component reviews cover the exact Gaussian-to-Laplace representation, affine-fiber integration by parts and its moment bound, finite-width empirical objective comparison, training-vector concentration, the full-path interpolation obstruction, the actual posterior excursion, the dimension-explicit extension, and the conditional Gaussian readout variance bound. The final integration record identifies the reviewed source snapshot by SHA256 hashes.

`build.sh` copies only the TeX sources into a temporary directory and runs three `pdflatex` passes. The final log and pass outputs are retained here.
