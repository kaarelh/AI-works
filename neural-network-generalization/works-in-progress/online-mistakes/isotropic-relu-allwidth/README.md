# Superpolynomial online mistakes for isotropic Bayesian ReLU networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

**Authors:** ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.[^authors]

Ordinary one-hidden-layer ReLU networks under the unchanged isotropic Gaussian strong prior can make superpolynomially many online mistakes on one fixed, nonrepeating input order, at every sufficiently large learner width.

For every integer `m ≥ 32`, put `R = 2^60 m^10`. The construction has

- `d = 2mR + 6m² = Θ(m^11)` Boolean inputs and a bounded-fan-in Boolean circuit of size `O(d)`;
- a same-depth ReLU teacher of width at most `(m+1)(mR+6m²+1) = O(m^12)`, margin at least one, and weights bounded by that width;
- `2^(m−floor(m/2)−1)` designated rounds at which the actual posterior probability of the correct label tends to zero;
- an explicit sufficient learner-width threshold `N₀ = 2^(m+mR+6m²+1)`.

The order is independent of learner width and prior scale. For each fixed `N ≥ N₀`, the prior scale then tends to zero. No scale threshold uniform over all widths is claimed. The mistake count is exponential in `m`, stretched exponential in the displayed teacher width and input dimension, and therefore larger than every polynomial in these complexity measures. The theorem does not assert `exp(Ω(C))` mistakes in teacher width `C`.

The learner first conditions on `|F(x)| > 1/2` at every Boolean input, then on exact observed labels. In the predictor `F(x)=Σⱼ vⱼ ReLU(Wⱼ·(1,x))`, the independent Gaussian variances are `Nσ²/d` for every incoming coordinate, including the bias, and `σ²/N` for every readout. This is the usual strong-prior scaling with the change of variable `t=√N σ` at fixed width. The covariance has no input-coordinate asymmetry.

The target is a parity multiplied by an AND of block parities. The input order first reveals a large calibration set, then reveals entire remaining input classes in a specified order. The first point of each such class is a designated mistake. This is an arbitrary-order online lower bound, with a very long history; it is not an IID sample-complexity lower bound or a counterexample for the ordinary big-AND target.

The proof determines an exact weighted Fourier variation norm for ReLU, proves a quantitative stability estimate for every affine neuron, and uses the global output margin to round nearly optimal networks to a single candidate function. Distinct candidate energies then control the actual Gaussian posterior. There is no assumption about selecting a particular minimizer or breaking ties.

The paper is standalone and uses conventional proofs with independent mathematical reviews. It is **not Lean formalized**. Ordinary tanh remains open in the same unchanged-prior, all-large-width setting.

Run `bash build.sh` to rebuild the PDF with a standard LaTeX installation.

[^authors]: Authors are listed in alphabetical order.
