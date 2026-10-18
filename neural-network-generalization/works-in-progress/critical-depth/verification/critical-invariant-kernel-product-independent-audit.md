# Independent source audit: invariant-kernel product bound

Independently read and approved the full source `source/critical-invariant-kernel-product.tex`, SHA256 `21c2979bcd105cd53483e241d5c9eeaffdc1d239f3fab020012820adab35a7b8`.

Checked all normalization and approximation details:

- The kernel operator uses uniform probability on the cube, so its eigenvalues lambda_S sum to the diagonal q. The same RKHS norm is g^T K^dagger g for the unnormalized kernel matrix.
- Cauchy–Schwarz bounds Fourier variation by ||g||_K sqrt(q). Terms with zero eigenvalue are omitted, as specified immediately above the formula.
- The parity identity has the correct alternating coefficients and optional constant b0. The threshold arguments are odd integers, so tanh steepness (1/2)log(2k/delta) gives total error delta.
- The incoming/readout Frobenius bounds are O(tau k^{3/2}) and O(sqrt(k)), respectively, giving O(k^2 tau). Constant rails use only the augmented input.
- Combining Fourier terms with delta=1/(4A), then doubling the readout, preserves global margin. Neuronwise cloning converts the finite shallow variation sum into an arbitrarily close Frobenius product, without dependence on the number of Fourier terms in the product bound.
- Critical readout action (1/2)z^T Q^dagger z<=J and margin1/2 give unit-margin RKHS norm at most sqrt(8J) after doubling. This is exactly the stated sqrt(8Jq) bound.

The theorem requires an invariant terminal covariance; it makes no claim that general minimizing paths have this symmetry. It is a representation result, not a posterior sample-complexity theorem. No mathematical correction is needed.
