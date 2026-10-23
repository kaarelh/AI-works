# Width-independent learning bounds for ReLU, GELU, and other Lipschitz activations

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Final mathematical review](verification/meanfield-review.md) · [Fresh independent audit](verification/fresh-final-review.md) · [Earlier capacity and spectral review](verification/mathematical-review.md)

For any fixed globally Lipschitz activation vanishing at zero, a teacher of width `C`, with weights bounded by `C` and signed output margin strictly greater than `1/2` at every Boolean input, has a fixed-depth polynomial sample bound at every learner width `N≥C`. **One polynomial works simultaneously for all Gaussian scales at least as strong as mean field**, including every exponent `γ≥1`. Its degree does not deteriorate as `γ` approaches `1`. ReLU, exact GELU, SiLU, tanh, and centered softplus are included.

The raw Gaussian coordinate variances are

```text
first layer:     t²/d
internal layers: t²/N
readout:         t²/N²,       0<t≤1.
```

The exponent convention is `t=N^((1−γ)/2)`. The prior is conditioned on a strict absolute output margin greater than `1/2` at every Boolean input, then on exact agreement with iid noiseless training labels. With high probability over the sample, the bound controls posterior average sign error simultaneously for every learner width and every scale in the displayed range. Using one third of the target error tolerance gives the strict correct-label probability criterion `>2/3`.

The main proof combines three arguments:

- At small scales, spectral truncation discards the Gaussian part with small operator norm and leaves a function with bounded energy.
- At mean field and intermediate scales, a Gaussian projection separates a bounded bulk from rare large neurons. Exponential tilts describe the bulk covariance; controlled reproducing-kernel atoms retain the tail. A stable recursive construction gives a finite auxiliary implementation.
- The auxiliary functions have a width-independent capacity bound. They may use different zero-at-zero Lipschitz activations at different neurons. This is only a counting device: the actual learner still uses its single fixed activation.

The paper gives all needed proofs, including the sparse exponential-tilt certificate. It also includes a shorter strong-prior argument and an exact GELU compilation of a layered Boolean circuit of width `C` into the same depth, width at most `2C`, and weights bounded by `4`.

The capacity budget used throughout is

```text
H = L−1
v(K) = ceil([16 H λ^H sqrt((d+1)/d) (K/L)^(L/2)]³)
log |F(K)| ≤ v(K) log(2^d+1).
```

`F(K)` allows the auxiliary neuron-specific activations and includes every finite width. The uniform theorem gives a polynomial energy budget `J*` and sample bound `n ≥ 2[v(J*) log(2^d+1) + log(1/δ)]/ε`. Its recursive polynomials are deliberately loose and retain poor depth dependence. The simpler strong-prior argument has a crude teacher-width exponent at most `6L`; the specialized homogeneous ReLU argument in the earlier ReLU note can give a sharper bound.

This paper does not provide a polynomial-depth guarantee, efficient posterior inference, or a same-activation circuit-compression converse for the generic activation class. It retains the global-margin prior conditioning. Those are separate questions.

Authors: ChatGPT-6 Astra; Claude Fable 5 and Opus 5; Kaarel Hänni; Dmitry Vaintrob. Dated October 22, 2026. Claude is credited for contributions to the inherited strong-prior setup and prior-scaling program. The proofs have undergone independent AI-agent mathematical review; their main learning statements now have Lean proofs.

Run `./build.sh` to build the PDF in a TeX environment with the packages declared in `source/paper.tex`.

The [publication record](verification/publication-build.json) records isolated rebuilding and exact source/PDF hashes. It also maps the reviewed source hashes to the published hashes after removal of three trailing blank lines; no mathematical text changed.

## Lean verification

The main statements are included in the second formalization batch. [Exact coverage and exclusions](../../lean/review/BatchTwo-coverage.md) · [Lean entry point](../../lean/NeuralGeneralization/BatchTwoMain.lean). This label does not extend automatically to every appendix, remark or numerical allocation. The original mathematical review records describe their earlier source snapshots.
