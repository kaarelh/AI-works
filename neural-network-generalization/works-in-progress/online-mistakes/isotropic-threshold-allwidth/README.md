# Exponential mistakes for isotropic Bayesian threshold networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Volume proof](source/volume.tex) · [Verification](verification/README.md)

**Authors:** ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.[^authors]

This paper uses the **fixed discontinuous sign activation** and the **exactly isotropic Gaussian prior**. For each `k >= 2`, it constructs a target on `d = 167k + 1617` Boolean inputs with a circuit of size `Θ(k)` and a width-one teacher whose weights are all at most one. A fixed input permutation forces **`2^k − 2` designated online mistakes at every sufficiently large learner width**.

The learner has one hidden layer, a constant input coordinate, global output margin greater than `1/2`, and exact label conditioning. Its original strong-prior variances are

```
Var(W_ai) = τ² N^(1−γ) / d
Var(v_a)  = τ² N^(−γ−1).
```

For every fixed `γ > 1` and every fixed `τ > 0`, the posterior probability of the wrong label tends to one at each designated round as width grows. This includes the unit-prefactor prior `τ = 1`. The same conclusion holds for `γ = 1` with a sufficiently small fixed prefactor. The result covers posterior-label majority, the strict `2/3` criterion, and posterior sampling.

The proof controls every Boolean output of the wide network. An exact finite-width Gaussian-tail bound reduces the posterior to powers of single-neuron threshold-cone probabilities. A full-cube calibration built from four redundant binary registers leaves a chain of threshold functions with strictly decreasing isotropic Gaussian cone probabilities. Integrating a common positive helper-weight direction proves that ordering; no coordinate anisotropy is introduced.

The same target and priors have IID sample bound `O((d² + log(1/β))/ε)` for population error `ε` with confidence `1 − β`, at every sufficiently large width.

The scope has three material limits:

- The activation is discontinuous sign. The corresponding exactly isotropic results for ordinary tanh, ReLU, and GELU remain open in this paper.
- The calibration prefix contains `2^(d−1) + 2` examples. The result does not give a short calibration prefix.
- The claim is for all sufficiently large widths. The cold-posterior width bound is `poly(k) 2^k`, with a logarithmic confidence factor; the direct fixed-`γ` prior has an additional dimension-dependent width requirement. No result at every width above the width-one teacher is asserted, and unit-prefactor `γ = 1` is not covered.

**Status:** Conventional proof with independent AI-agent mathematical reviews; not Lean formalized.

Run `bash build.sh` to rebuild `paper.pdf` from the two packaged LaTeX source files with three `pdflatex` passes. Auxiliary files go to `build/`.

[^authors]: Authors are listed in alphabetical order.
