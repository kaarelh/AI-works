# Exponential online mistakes after an arbitrarily small jump is added to tanh

[Read the paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

For every fixed positive `ε`, the bounded activation
`φ(t) = tanh(t) + ε sign(t)` admits exponentially many online mistakes under the **unchanged coordinate-isotropic Gaussian prior, at every hidden width in the strong-prior limit**. This activation is uniformly within `ε` of ordinary tanh, but remains discontinuous.

The target has a Boolean circuit of size `Θ(k)` and a same-depth teacher of width `ceil(1/ε)`, with all weights bounded by one. The input dimension is `d = 2k+2`; the proof requires `k ≥ 8` and `d ≥ 4 max(1, ε⁻⁶)`. A fixed permutation of the full Boolean cube begins with at most `2k²+6k+2` calibration examples and then has `2^k−k−1` designated mistakes, with at most `4k` examples per block. There are no repeated inputs.

The learner initially conditions on absolute output margin greater than `1/2` at every input, then fits every revealed label exactly. The conclusion concerns the actual posterior, including all nonlinear competitors. It applies to posterior sampling, majority prediction, and the convention requiring correct-label probability greater than `2/3`.

The Gaussian variances are `Nσ²/d` on every first-layer coordinate, including the appended constant, and `σ²/N` on the readout. The paper proves:

- For every fixed `N ≥ 1`, each designated wrong-label probability tends to one as `σ → 0`.
- With `σ_N² = τ² N^(−γ)`, every fixed `γ > 1` and `τ > 0` gives the same conclusion at all sufficiently large widths.
- A sufficiently small fixed `τ` gives any desired joint mistake probability uniformly over **every** `N ≥ 1` and `γ ≥ 1`.
- The same learner has polynomial IID sample complexity, `O_ε((d³ + log(1/β))/η)`, for posterior confidence greater than `2/3` outside input mass `η`.

The proof combines an exact energy inequality under an explicit affine covariance certificate, a compact relaxation giving a gap uniform in width, and a short calibration built from pairwise-independent bit assignments. The IID proof also establishes a general lemma: every low-energy full-margin shallow network with a bounded monotone activation has the same Boolean sign as a polynomial-size majority of affine thresholds.

**Scope:** the nonzero jump is fixed before the dimension and prior limits are taken. This does not prove the corresponding result for ordinary tanh, ReLU, hardtanh, or a continuous smoothing of the jump. The small-prefactor assertion does not settle `γ = 1, τ = 1`. The width and prior-scale thresholds are not made explicit. These results have undergone independent AI-agent mathematical review and are not Lean verified.

The [threshold-residual companion paper](../isotropic-residual-threshold/README.md) treats `sign(t)+tanh(t)` with a shorter calibration and a stronger threshold-specific IID bound. The present paper allows the discontinuous component to be arbitrarily small relative to tanh and is self-contained.

Run `./build.sh` to rebuild the PDF with `pdflatex`.
