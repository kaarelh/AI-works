# Superpolynomial online mistakes for isotropic Bayesian ReLU and softplus networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

**Authors:** ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.[^authors]

Ordinary one-hidden-layer ReLU and softplus networks under the unchanged isotropic Gaussian strong prior can make superpolynomially many online mistakes on one fixed, nonrepeating input order, at every sufficiently large learner width.

The mistake lower bound is **exp(Ω(C^(1/3)))** in the displayed teacher width `C`. For every sufficiently large integer `m`, the construction has

- `d = Θ(m²)` Boolean inputs and a bounded-fan-in Boolean circuit of size `O(d)`;
- a same-depth ReLU teacher of width `C = Θ(m³)`, margin at least one, and weights bounded by that width;
- `2^(m/2−o(m))` designated rounds at which the actual posterior probability of the correct label tends to zero;
- an explicit sufficient learner-width threshold `N₀ = 2^(m+n_max+1)`, where `n_max = 2^42(2m−1)²+6m−2`.

For standard softplus, `φ(t) = log(1+exp(t))`, the same target and input order give the same cube-root lower bound. The softplus teacher has comparable width and bounded coefficients. Its sufficient learner-width threshold is existential; the explicit `N₀` above is the ReLU threshold.

The order is independent of learner width and prior scale. For each fixed width above the corresponding activation’s threshold, the prior scale then tends to zero. No scale threshold uniform over all widths is claimed. The mistake count is exponential in `m`, at least `exp(Ω(C^(1/3)))` in the displayed shallow teacher width and `exp(Ω(√d))` in input dimension. The Boolean circuit has `O(d)` gates, so the latter also gives a square-root exponent in the displayed Boolean gate count. The theorem does not assert `exp(Ω(C))` mistakes in teacher width `C`.

The learner first conditions on `|F(x)| > 1/2` at every Boolean input, then on exact observed labels. In the predictor `F(x)=Σⱼ vⱼ ReLU(Wⱼ·(1,x))`, the independent Gaussian variances are `Nσ²/d` for every incoming coordinate, including the bias, and `σ²/N` for every readout. This is the usual strong-prior scaling with the change of variable `t=√N σ` at fixed width. The covariance has no input-coordinate asymmetry.

The target is a parity multiplied by an AND of block parities. The input order first reveals a large calibration set, then reveals entire remaining input classes in a specified order. The first point of each such class is a designated mistake. This is an arbitrary-order online lower bound, with a very long history; it is not an IID sample-complexity lower bound or a counterexample for the ordinary big-AND target.

The proof determines an exact weighted Fourier variation norm for ReLU, proves a quantitative stability estimate for every affine neuron, and uses the global output margin to round nearly optimal networks to a single candidate function. Quantitative Hölder stability and local concentration under parity conditioning allow a code built from a path with linearly sized blocks. A transfer-matrix argument distinguishes exponentially many code weight enumerators; square-root independence then distinguishes the corresponding candidate energies. Their ordering then controls the actual Gaussian posterior. For softplus, a representation as an average of shifted ReLUs preserves the lower bounds, and increasingly wide softplus networks approach the strict ReLU witnesses at the required energy. There is no assumption about selecting a particular minimizer or breaking ties.

The paper is standalone and uses conventional proofs with independent mathematical reviews. It is **not Lean formalized**. Ordinary tanh remains open in the same unchanged-prior, all-large-width setting.

Run `bash build.sh` to rebuild the PDF with a standard LaTeX installation.

[^authors]: Authors are listed in alphabetical order.
