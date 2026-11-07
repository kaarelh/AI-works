# Isotropic Bayesian triangle-wave networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex)

**Authors:** ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.[^authors]

For one fixed continuous, bounded, 1-Lipschitz triangle-wave activation, the unchanged canonical isotropic Gaussian prior makes `2^(m-4)` designated online mistakes at every sufficiently large learner width in the strong-prior limit taken at that fixed width. At every designated round the actual posterior probability of the correct label tends to zero.

The construction has `d = 10^6(6m²+1)^3 + 1 + 6m² = Θ(m^6)` Boolean inputs. Its target has a Boolean circuit of size `Θ(d)` and an explicit one-hidden-layer teacher of width `2m-1`, with all weights at most one and margin at least one. The mistake count is exponential in that teacher width and stretched exponential, `exp(Ω(d^(1/6)))`, in input dimension and Boolean-circuit size.

The model keeps the full Boolean cube, global absolute margin greater than `1/2` imposed before data, exact labels, and variances `Nσ²/d` in the incoming layer and `σ²/N` in the readout. The sequence is one fixed permutation, independent of learner width and variance.

The calibration prefix occupies `15/16` of the cube. The sufficient width can be very large; no polynomial bound or width-uniform variance threshold is claimed. This result uses a periodic triangle wave and does not settle ordinary tanh, ReLU, GELU, or hardtanh.

The proof is conventional mathematics, with independent AI-agent audits of the atomic norm, quantitative fiber gap, weighted subgroup costs, and finite-width posterior transfer. Three further complete-manuscript reviews found no substantive mathematical gap. It is not Lean formalized. See the [verification record](verification/README.md) for scope and provenance.

Triangle-wave activations have previously been studied in Bayesian neural networks: see Meronen, Trapp and Solin, [“Periodic Activation Functions Induce Stationarity” (NeurIPS 2021), Section 3.2](https://proceedings.neurips.cc/paper_files/paper/2021/file/0d5a4a5a748611231b945d28436b8ece-Paper.pdf). That citation supplies background on the activation; its prior and stationarity results are not used in this proof.

Run `bash build.sh` to rebuild the PDF.

[^authors]: Authors are listed in alphabetical order.
