# Independent shallow-product audit

26 October 2026. Source SHA256 `930e01edee9154e292c987bdc8d1aea0101f26725e2d9ce1b3170135642a9af1`.

PASS. Sorting columns preserves the Hadamard operator norm and makes every affine halfspace row a prefix, including tied values under a fixed threshold convention. The aligned dyadic decomposition uses at most one interval of each length per row. At a fixed scale the row groups and the column intervals are each pairwise disjoint, so Cauchy–Schwarz sums the rectangle spectral bounds to n^(3/2); summing m+1 scales gives the stated correlation bound. No weight size or precision restriction enters.

The layer-cake identity uses the full bounded score range M=sqrt(2m+1)||w||. Its constant term contributes at most M/n and its integral at most 2M(m+1)/sqrt(n). This yields precisely (2m+3)sqrt(2m+1)2^(-m/2)||w||. Summing output weights and applying Cauchy–Schwarz proves the all-width Frobenius-product lower bound from unit global margin.

The arbitrary-binary-gate rank-two formula claim is correct and basis-qualified. The two-hidden-layer escape computes the AND bits to inverse-polynomial error, then all Hamming-weight thresholds and an alternating parity readout. Charged constant wires and gains O(log(m+2)) maintain every integer threshold margin; the resulting product is polynomial. The theorem concerns exact global representation and does not imply a constant-error posterior or depth-unrestricted lower bound.

Editorial follow-up: source SHA256 `5eb7a0f19b90707f8717f79835f4d15e3a1eda8a265238837f9bc8dcfa1dff46` appends a related-work and credit paragraph while leaving the theorem and proof unchanged. The mathematical PASS therefore remains valid. The paragraph correctly avoids a broad novelty claim and preserves the distinction from Bayesian sample lower bounds; the author separately checked the cited external sources.
