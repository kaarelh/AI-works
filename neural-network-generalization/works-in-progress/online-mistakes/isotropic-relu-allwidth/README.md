# Superpolynomial online mistakes for isotropic Bayesian ReLU and softplus networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

**Authors:** ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.[^authors]

Ordinary one-hidden-layer ReLU and softplus networks under the unchanged isotropic Gaussian strong prior can make superpolynomially many online mistakes on one fixed, nonrepeating input order, at every sufficiently large learner width.

The mistake lower bound is **exp(Ω(√C))** in the displayed teacher width `C`. For every sufficiently large integer `k`, put `m = 6k+4` and `ℓ = 8k+4` (the paper's `ℓ`, Lean's `pairDim`). The construction has

- `d = Θ(m)` Boolean inputs and a bounded-fan-in Boolean circuit of size `O(d)`;
- a same-depth ReLU teacher of width `C = Θ(m²)`, margin at least one, and weights bounded by that width;
- `2^(k−1)` designated rounds at which the actual posterior probability of the correct label tends to zero;
- an explicit sufficient learner-width threshold `N₀ = 2^(m+d+1)`, where `d = ℓ(2R+4)` and `R = 2^1024`.

For standard softplus, `φ(t) = log(1+exp(t))`, the same target and input order give the same square-root lower bound. The softplus teacher has comparable width and bounded coefficients. Its sufficient learner-width threshold is existential; the explicit `N₀` above is the ReLU threshold.

The order is independent of learner width and prior scale. For each fixed width above the corresponding activation’s threshold, the prior scale then tends to zero. No scale threshold uniform over all widths is claimed. The block size is the fixed constant `R = 2^1024`; constants and the minimum admissible `m` have not been optimized. The mistake count is exponential in `m`, at least `exp(Ω(√C))` in the displayed shallow teacher width and `exp(Ω(d))` in input dimension. The Boolean circuit has `O(d)` gates, so the latter also gives a fully exponential lower bound in the displayed Boolean gate count. The theorem does not assert `exp(Ω(C))` mistakes in teacher width `C`.

The learner first conditions on `|F(x)| > 1/2` at every Boolean input, then on the correct output sign at every observed input: `yᵢF(xᵢ) > 1/2`. The real-valued output is not fixed to the label value. In the predictor `F(x)=Σⱼ vⱼ ReLU(Wⱼ·(1,x))`, the independent Gaussian variances are `Nσ²/d` for every incoming coordinate, including the bias, and `σ²/N` for every readout. This is the usual strong-prior scaling with the change of variable `t=√N σ` at fixed width. The covariance has no input-coordinate asymmetry.

The target is a parity multiplied by an AND of block parities. The input order first reveals a large calibration set, then reveals entire remaining input classes in a specified order. The first point of each such class is a designated mistake. This is an arbitrary-order online lower bound, with a very long history; it is not an IID sample-complexity lower bound or a counterexample for the ordinary big-AND target.

The proof determines an exact weighted Fourier variation norm for ReLU, proves a quantitative stability estimate for every affine neuron, and uses the global output margin to round nearly optimal networks to a single candidate function. A parity-conditioning argument proves the sharp neuron bound even with constant-sized blocks. An exactly triangular transfer matrix orders exponentially many path-code enumerators in the same way at every positive Laplace parameter. The positive integral representation of the ReLU parity cost preserves their strict order. Their ordering then controls the actual Gaussian posterior. For softplus, a representation as an average of shifted ReLUs preserves the lower bounds, and increasingly wide softplus networks approach the strict ReLU witnesses at the required energy. There is no assumption about selecting a particular minimizer or breaking ties.

The **ReLU and standard-softplus main theorems are Lean verified**, including the actual Gaussian posteriors, the exact designated rounds, teacher bounds, and finite-scale sampling/majority/confidence conclusions. The softplus theorem explicitly uses the same target and input sequence as ReLU. The optional ReLU extension to arbitrary positive layer variances is also formalized. See the [ReLU proof](../../../lean/NeuralGeneralization/OnlineLowerReluMain.lean), [softplus proof](../../../lean/NeuralGeneralization/OnlineLowerSoftplusMain.lean), [layer-variance proof](../../../lean/NeuralGeneralization/OnlineLowerReluLayerVarianceMain.lean), and [full-paper coverage inventory](../../../lean/review/OnlineLowerRelu-full-paper-coverage.md). The inventory separately identifies coverage of the independent lemmas and appendix assertions. The [ordinary-tanh companion](../isotropic-tanh-allwidth/README.md) proves an exp(Ω(√C/log C)) lower bound under the same unchanged-prior, all-large-width conventions.

Run `bash build.sh` to rebuild the PDF with a standard LaTeX installation.

[^authors]: Authors are listed in alphabetical order.
