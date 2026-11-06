# Independent full-paper mathematical review

Reviewer: separate ChatGPT-6 Astra research agent (`wide_tanh`).
Date: 6 November 2026.

Reviewed source: `source/paper.tex`, SHA-256
`667ac223254a05ee973f0c23ff41cb786dbeac58914ff4c019da6d4e3f6bf55c`.

The complete source was reviewed, including the final clarification that the Fourier calculations after energy equality use only the r relevant coordinates. No mathematical error was found. This is an AI-agent mathematical review, not a Lean verification.

## Sharp neuron correlation

The monotone-function lemma has the correct factor `2^-m`. Symmetrizing over coordinate permutations preserves the top Fourier coefficient, and the monotone Hamming-layer sequence is a convex mixture of constants and upper thresholds. The alternating-binomial identity gives the stated central-binomial extremum.

The ReLU finite-difference integral has the correct one-half factor and interval length. Conditioning on irrelevant coordinates is legitimate, and the remaining relevant-input indicator is monotone. The resulting coefficient bound is sharp for equal-magnitude relevant weights and zero bias. Equality in the Euclidean minimum-coordinate bound forces exactly those directions, with all irrelevant weights zero. The even-r central threshold attains equality throughout the integral. The optional odd-parity statement also checks: randomizing the bias sign converts the absolute-value correlation to even parity on r+1 variables, with the same augmented norm.

## Energy and equality cases

The Gaussian normalization gives the displayed quadratic energy. Per-neuron AM--GM gives the factor `2 sqrt(d)`, and the global margin gives top correlation at least one half. Thus the energy lower bound is exactly `sqrt(d)/rho_r`.

Equality requires every nonzero neuron to attain the sharp correlation with correctly oriented readout; neurons contributing zero must have all parameters zero. Equality in the averaged pointwise margin implies the exact real-valued output `chi/2` on the full cube. The positive orientation probability measure and its total variation are therefore justified, rather than assumed.

## Fourier support argument

The second discrete derivative of the equal-weight ridge is `1/(2 sqrt(r))` on the equator of the remaining r-2 bits and zero elsewhere. The equator character moment follows from `(1-u²)^((r-2)/2)` and gives the displayed nonzero coefficient at every even degree. Odd coefficients vanish except for the explicitly nonzero degree-one coefficients.

Fourier comparison with `chi/2` forces every nonempty even moment of the orientation measure to vanish. Antipodal symmetrization and Fourier inversion therefore give exactly equal total mass to each antipodal pair, so at least `2^(r-1)` orientations are needed. For r=2, the additional degree-one ridge coefficients force the two odd moments to vanish as well, requiring all four orientations. This exception is correctly stated separately.

For every even r>=4, the measure uniform on `s_1=+1` has only the empty and first-singleton moments. Its possible unwanted output coefficient has degree r-1, an odd degree at least three, and hence vanishes. This gives the matching `2^(r-1)`-orientation construction. Positive homogeneity and the displayed per-neuron scaling attain the same energy at every greater integer width, with zero padding. Coercivity and closedness give a strictly larger minimum at any smaller feasible width.

## Teacher and theorem scope

The alternating one-variable spline in the sum of the r input bits represents parity exactly. It has O(r) hinges with biases at most r and bounded slope jumps. Rescaling each affine form and replicating its outgoing coefficient into O(r) bounded copies gives O(r²) neurons with every incoming and outgoing weight at most one. Constants and the linear term require only O(r) further neurons. The output is exactly parity, with margin one.

The paper correctly distinguishes exact minimum-energy width from realizability width. It does not claim an exponential sample-complexity bound, an online-mistake lower bound, an efficient learning result, or an approximation gap uniform in r. Strict-margin infima agree with the closed-margin minima by readout amplification, but exact attainment is stated for the closed-margin problem.
