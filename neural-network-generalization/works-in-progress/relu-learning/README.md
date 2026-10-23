# Polynomial sample complexity for ReLU NNBayes with strong Gaussian priors

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Independent mathematical review](verification/mathematical-review.md)

The [unified activation paper](../unbounded-activations/) extends the learning guarantee to every `gamma >= 1`, including multiple hidden layers, for ReLU, GELU, and all fixed globally Lipschitz activations vanishing at zero. This earlier paper remains useful for its simpler argument and sharper explicit ReLU strong-prior bounds; its discussion of the remaining deep-scaling gap describes its original scope.

This note proves a learning guarantee for ReLU networks on the Boolean cube under the original strong-prior convention: condition the parameter prior on an absolute output margin greater than 1/2 at every input, then condition on exact training labels. For every learner width at least the teacher width, a sufficiently small prior variance gives a sample bound independent of learner width. No internal-stability restriction is imposed.

Let the teacher have depth `L`, hidden width `C`, and product of layer Frobenius norms `P`. Writing `H=L−1`, define

```text
a = 1 + sqrt(2 H log 2)
v = ceil(4 e (d+1) P² a²)
B = v log(2^d + 1).
```

Then `n ≥ 2(B + log(1/δ))/ε` suffices for posterior average sign error at most `ε`, with probability at least `1−δ` over iid noiseless training data from any distribution on the cube. This implies the strict posterior confidence criterion `>2/3` with a factor of three in accuracy. The sufficiently-small variance threshold may depend on learner width, teacher, and accuracy, but not on the data distribution, sample size, or confidence level.

Two concrete consequences are:

- A width-`C`, depth-`L` ReLU teacher with individual weights bounded by `C` has sample bound `O((L(d+1)³ C^(4L−2) + log(1/δ))/ε)`.
- A layered NOR/COPY/NOT Boolean circuit with `L−1` stages and width `C`, counting its constant wires, has sample bound `O((L(d+1)² (5C)^(L−1) + log(1/δ))/ε)`. The paper gives an exact ReLU implementation. Compilation from other gate bases must include the resulting width and depth overhead.

The proof combines exact positive-homogeneous energy balancing, a width-independent product-norm Rademacher bound, VC/Sauer counting of globally separated functions, and finite-dimensional Gaussian small-variance asymptotics. It supplies the needed arguments, including the order of quantifiers.

A separate theorem gives a finite-variance guarantee for every exponent `γ≥2`, at the prescribed variance `σ²=N^(−γ)`, simultaneously for all learner widths `N≥C`. Its explicit bound uses a target-ball probability lower bound and a Gaussian energy tail; it remains polynomial in bounded-weight teacher width and input dimension at fixed depth. For a single hidden layer (`L=2`), exactly the same finite-variance proof and constants cover every `γ≥1`, including mean-field scaling. With more hidden layers, this note leaves `1≤γ<2` open. Both results have poor depth dependence. It does not prove an inverse equivalence between minimum circuit width and the function-prior rate. The theorem is information-theoretic and provides no efficient posterior sampler.

Authors: ChatGPT-6 Astra; Claude Fable 5 and Opus 5; Kaarel Hänni; Dmitry Vaintrob. Dated October 21, 2026. Claude is credited for contributions to the inherited strong-prior setup and slides. This note has independent AI-agent mathematical review, but no Lean formalization.

Build with `./build.sh` in a TeX environment containing the packages declared in `source/paper.tex`.

The [publication record](verification/publication-build.json) records isolated rebuilding and exact hashes.
