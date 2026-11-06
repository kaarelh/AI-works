# Independent mathematical review

Reviewed on 6 November 2026 by a separate geometry research agent.

- Research proof `relu/exact-parity-energy-and-width.md`: SHA256 `6b7ff0f6b2ecade0b0563dd9df298f72533d3dbdb1f7a61cfac5e4b30e8f1c60`.
- Integrated manuscript `source/paper.tex`: SHA256 `667ac223254a05ee973f0c23ff41cb786dbeac58914ff4c019da6d4e3f6bf55c`.

**Verdict: the main theorem and its proof pass the audit. No mathematical gap found.** This is not Lean verification.

Checked independently:

1. Permutation averaging preserves the top Fourier coefficient of a monotone function; the coupling of adjacent Hamming slices and the alternating-binomial identity give the sharp bound.
2. Integrating the ReLU derivative across the smallest relevant weight gives the stated parity-correlation constant. Equality in the augmented norm bound forces zero bias, zero irrelevant coordinates, and equal magnitudes on every relevant coordinate. These directions attain equality.
3. The Gaussian energy lower bound has the correct factor 2 sqrt(d). Equality forces exact output chi/2 at every cube input, all nonzero neuron directions to be correlation maximizers, and the prescribed readout signs. Zero-contribution neurons must have zero parameters.
4. The second-difference calculation gives 1/(2 sqrt(r)) times the balanced-slice indicator. The equator moment formula is nonzero at every even degree; degree-one coefficients are nonzero and higher odd coefficients vanish.
5. Fourier inversion forces the orientation measure to give mass 2^(1-r) to every antipodal pair. This proves the exponential support bound. The r=2 case additionally forces all odd moments to vanish and needs all four orientations.
6. The half-orbit construction for even r>=4 has exactly the required output; its only potentially extraneous moment corresponds to an odd ridge coefficient of degree at least three, which vanishes. Balancing each atom with t_s²=N|c_s|/sqrt(d) attains the lower bound at every larger width.
7. Coercivity and closed constraints justify a strictly larger attained minimum below the equality threshold whenever the cell is realizable. Readout amplification equates strict and weak margin infima.
8. The spline construction supplies the stated O(r²) bounded-weight shallow teacher: O(r) hinges have readout slope jumps at most two, and normalizing affine biases of magnitude at most r requires only O(r) bounded readout copies per hinge.

The interpretation correctly distinguishes exact energy-minimizer width from realizability, approximation width, sample complexity, and online mistakes. The theorem proves none of the latter lower bounds. The mathematical audit does not assess novelty beyond the literature comparison stated in the manuscript.

The final clarification that the equality-case Fourier analysis uses only the r relevant coordinates was also checked; it correctly follows from the forced zero irrelevant weights.
