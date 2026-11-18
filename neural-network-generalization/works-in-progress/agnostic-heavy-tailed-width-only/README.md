# Width-only approximation guarantees for Bayesian neural networks with heavy-tailed priors

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Build script](build.sh) · [Verification](verification/)

One prescribed dense Bayesian ReLU network can approach the best arbitrary-real-weight narrow ReLU approximation. The weight prior has independent continuous heavy-tailed coordinates, with tail indices decreasing through the layers. The main theorem assumes the conditional mean lies in `[-1,1]`; the final output is clipped to that interval inside both the Gaussian likelihood and prediction. There is no prior over architectures.

The main guarantee is

`test risk <= irreducible noise + (1+eta) best narrow-network approximation error + epsilon`.

The ordinary posterior mean satisfies this at every learner width `N >= C+1`, where `C` is comparison width. The extra neuron carries biases. A known conditional sub-Gaussian noise proxy around this bounded conditional mean is allowed, so labels may have genuine Gaussian noise. Two observable scores select one positive likelihood variance; above the compiled comparison width, a single fixed variance suffices.

On Boolean inputs, a constant-factor depth overhead gives sample complexity polynomial in comparison width and input dimension, with no original coefficient bound. The accuracy power is `2/(2-a)`, where `a` is the fixed second-layer tail index. For example, `a=1/2` gives accuracy cost `epsilon^(-4/3)`; choosing a smaller positive index gives any power strictly above one, with different constants. The factor `1+eta` applies only to approximation error, not to irreducible noise.

A continuous-domain theorem assumes anti-concentration near affine hyperplanes. It includes bounded-density cube distributions and uniform sphere distributions. If the slab exponent is `alpha`, hidden depth is `H`, and `p=a/(2-a)`, the accuracy power is

`1+p+H(a+2p)/alpha`.

This also approaches one as a fixed positive `a` is chosen smaller. The continuous compiler pays a polynomial precision cost; the Boolean compiler pays only logarithms. Constants can be large, and the depth dependence is not claimed to be polynomial.

Taking `eta=1/log(en)` gives a coefficient-one comparison with the best width-`n^u` network, plus a vanishing additive term, for a stated positive range of `u`. Under the same bounded-conditional-mean assumption, the native fixed-variance learner is also universally risk consistent for every prescribed width schedule tending to infinity, however fast, on arbitrary compact input laws; this qualitative corollary needs no slab regularity.

An output-normalization appendix replaces the uniform bound on the conditional mean by a known marginal sub-Gaussian label tail, with only logarithmic changes to the rates. That variant uses a growing bounded output range and likelihood variance.

Another appendix retains an alternative prior with the same Student tail index in every layer and tanh hidden activations. It includes a leading-one total-risk guarantee for bounded labels, and an explicit width-`2C+1`, depth-`2h` tanh approximation of arbitrary-coefficient ReLU networks.

Related work includes [Castillo–Egels (JMLR, 2025)](https://www.jmlr.org/papers/v26/24-0894.html), which already studies dense independent heavy-tailed priors without an architecture mixture. The paper explains the distinction between their contraction results and the width-uniform agnostic comparison proved here.

The coefficient-free compilers and native heavy-tail comparison laws are imported with their exact statements. The score-selection and all-width arguments have separate mathematical reviews recorded in `verification/`. These are conventional proofs, not Lean formalizations. Statistical existence does not imply efficient posterior evaluation or efficient compilation.
