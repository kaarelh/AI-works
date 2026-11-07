# Isotropic Bayesian networks with a monotone Lipschitz activation

[Paper](paper.pdf) · [LaTeX source](source/paper.tex)

**Authors:** ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.[^authors]

The fixed activation is `ψ(t) = (2t + φ(t))/3`, where `φ` is the period-four triangle wave. It is odd, continuous, strictly increasing, unbounded, and 1-Lipschitz, with slopes `1/3` and `1`.

For every `m ≥ 5`, an explicit target on `d = 10^8(6m²+1)^3 + 1 + 6m² = Θ(m^6)` inputs has a Boolean circuit of size `Θ(d)` and a one-hidden-layer teacher of width `8m-4`, with incoming weights `0, ±1`, readouts `±3/4`, and margin at least one. One fixed input permutation forces `2^(m-4)` designated online mistakes at every sufficiently large learner width, in the strong-prior limit taken at that fixed width. At every designated round the actual posterior probability of the correct label tends to zero.

The Gaussian prior keeps variances `Nσ²/d` for all incoming coordinates, including the bias, and `σ²/N` for every readout coordinate. The learner conditions on absolute margin greater than `1/2` on the entire cube before observing exact labels.

The proof is standalone. An exact triangle-wave Fourier norm is combined with four-orientation cancellation to represent code characters under the monotone activation. Calibration controls the affine part of every competing network; no cancellation is assumed for arbitrary competitors. A quantitative margin argument excludes other sign functions, and strictly ordered subgroup costs yield the full posterior lower bound at all sufficiently large finite widths.

The mistake count is exponential in the displayed teacher width and `exp(Ω(d^(1/6)))` in input dimension and Boolean-circuit size. Calibration covers `15/16` of the cube. The sufficient width need not be polynomial, and no width-uniform variance threshold is claimed. The activation is simple but nonstandard; the theorem does not settle ordinary tanh, ReLU, GELU, or hardtanh.

The argument also applies to any fixed strictly increasing `αt + εφ(t)` with `α > ε > 0`, after adjusting constants. In particular, the activation can be uniformly arbitrarily close to the identity. This is not a uniform theorem as `ε` tends to zero.

Run `bash build.sh` to rebuild the PDF. The proof uses conventional mathematics, not a Lean formalization. Three complete-manuscript reviews and additional component audits found no substantive mathematical gap; see the [verification record](verification/README.md).

[^authors]: Authors are listed in alphabetical order.
