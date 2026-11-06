# Exponential mistakes at every width under small Gaussian anisotropy

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification](verification/README.md)

[Generic covariance asymmetries](GENERIC-VARIANCES.md): a companion proof permits almost every fixed-size small perturbation across dimensions, with a longer calibration prefix.

**Authors:** ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob (alphabetical order).

For every odd dimension `d >= 17`, ordinary majority has a Boolean circuit of size `Θ(d)` and a one-hidden-unit tanh teacher with every weight at most one. Nevertheless, an arbitrarily small explicit coordinate asymmetry in the first-layer Gaussian covariance gives a fixed input permutation forcing at least `2^floor(d/8)` online mistakes in the strong-prior limit **at every learner width `N >= 1`**. At sufficiently small positive variance, all designated mistakes occur with arbitrarily high probability. The result covers posterior sampling, posterior-label majority, and the strict `2/3` confidence criterion.

The covariance perturbation and input order are independent of width. The proof retains standard tanh, the Boolean cube, the constant input coordinate, global output margin greater than `1/2`, and exact label conditioning. The first construction permits a fixed positive perturbation amplitude in every dimension and uses a large calibration prefix. A second construction, for `d = 9q` with odd `q`, uses only `2q` calibration inputs and forces exactly `9^((q+1)/2)` designated mistakes; the explicit amplitude bound is `0 < δ <= 1/(80000 q³)`.

In the mean-field parametrization `Var(W_ai) = t²/(d λ_i)` and `Var(v_a) = t²/N²`, one sufficiently small positive `t` works for every width. The paper also proves a width-independent IID sample bound `O((d⁴ + log(1/β))/ρ)` for learning the same majority target under the same priors, with a common small mean-field scale for every width.

For each fixed prior exponent `γ > 1`, the corresponding unit-prefactor covariance `Var(W_ai) = N^(1−γ)/(d λ_i)` and `Var(v_a) = N^(−γ−1)` therefore has exponential online mistakes at every sufficiently large width, together with the polynomial IID bound. A sufficiently small common prefactor gives both conclusions for every width and every `γ >= 1`. The unit-prefactor case `γ = 1` is not covered.

**This changes the first-layer covariance and does not resolve the exactly isotropic prior.** The paper identifies precisely what changes there: the corresponding minimum-energy majority functions have equal prior masses, and their cold posterior incurs only a logarithmic expected sampling-error sum before that tier is exhausted.

The central bound applies to every nonlinear network: each essential input coordinate imposes a first-layer column-norm cost. Calibration forces a minimum number of essential inputs, and the energy bound and its quantitative equality case isolate majorities as the cheapest consistent functions. This yields a strict energy comparison uniformly over all widths, without restricting the posterior to scalar subnetworks.

**Status:** Conventional proof with independent AI-agent mathematical reviews; not Lean formalized.

Run `bash build.sh` to rebuild `paper.pdf` from the packaged source with three `pdflatex` passes. Auxiliary files go to `build/`.
