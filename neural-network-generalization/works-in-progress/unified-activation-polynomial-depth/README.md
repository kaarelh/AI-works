# Polynomial-depth learning with general Lipschitz activations

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification and scope](verification/README.md)

One common prior restriction gives a learning theorem polynomial jointly in depth and teacher resources for **tanh, ReLU, exact GELU, SiLU, ordinary sigmoid, softplus, and every fixed globally Lipschitz activation**. The activation need not vanish at zero.

The target has an actual width-`C` neural implementation with `H=L−1` hidden layers, weights bounded by `B≥1`, and signed output strictly above `1/2` on the Boolean cube. It uses the learner's activation. No Boolean-circuit compilation or uncounted constant wire is assumed. The theorem works at every learner width `N≥C`.

## The common restriction

The network must admit a partition of each hidden layer into `q` **balanced** populations such that:

- `q≤1+N‖v‖²`, where `v` is its readout;
- averaging the weights within these populations changes its clipped predictions by at most `1/16`, at every Boolean input.

The clipping level is `±1/2`. The population count is calibrated by absolute readout energy, so this restriction is not invariant under readout rescaling. It is the balanced-population condition previously used for tanh, without the optional extra internal-noise condition. It is a **different prior restriction** from the ReLU/GELU paper's arbitrary-size populations and output-normalized count budget. Neither is established as typical of gradient-trained networks.

## Guarantee

For an activation with Lipschitz constant at most `λ≥1` and `|φ(0)|≤b`, put

```text
S = 2+d+C+H+B+λ+b+log(4/ε).
```

For a universal constant `K`, a sufficient bound is

```text
n ≥ (K/ε)[S^13 + log(1/δ)].
```

The paper also gives a more informative explicit nested budget. With sample probability at least `1−δ`, posterior-average test-margin error is at most `ε`, **simultaneously for every `N≥C` and every `0<t≤1`**, where the Gaussian variances are `t²/d`, `t²/N`, and `t²/N²`. Thus one polynomial covers all `γ≥1` through `t=N^((1−γ)/2)`, including finite-width mean field. Apply the bound with `ε/3` for strict `>2/3` posterior confidence on all but `ε` test mass.

The learner conditions the restricted prior on signed training output above `1/2`; test failure means signed output at most `1/4`. The optional additional global output-margin condition is allowed. Training and testing use the same arbitrary distribution on the Boolean cube, with noiseless labels.

## Removing the zero-at-zero assumption under the original prior

Appendix A separately proves a fixed-depth polynomial theorem for the **original globally margin-conditioned Gaussian prior**, without a neuron-averaging restriction. It covers every globally Lipschitz activation with bounded offset, all `N≥C`, and all `0<t≤1`, with teacher weight magnitude `B` counted. The polynomial degree can depend on depth. Its proof modifies the capacity and mean-field tail constructions to retain constant features; centering the activation is not treated as an equivalent prior. This extension is also conventional, not Lean formalized.

## Why exponential amplification does not spoil the bound

Balanced cloning of the teacher, with a controlled readout rescaling, gives an exact implementation satisfying the population count condition. Gaussian perturbations can amplify exponentially through depth, so its guaranteed neighborhood may be exponentially small. The prior-mass argument pays the **logarithm** of that radius, which is polynomial in depth. Gaussian tails control every candidate partition before one is selected. A finite parameter grid then describes the resulting small merged networks; exponential precision again costs only its logarithm.

This permits general bounded-weight neural teachers, even when their hidden values grow exponentially. Their weights and signed margin are counted explicitly. It does not prove the same theorem under the original internal-noise restriction alone or under an unrestricted Gaussian prior.

**Status:** conventional proof with independent AI-agent mathematical reviews; **not Lean formalized** and not human peer reviewed. The earlier formalizations do not automatically certify this extension. The result is kept among supporting research papers, with the original two formalized batches unchanged.

Run `bash build.sh` to rebuild the PDF. Authors: OpenAI Codex, Kaarel Hänni, and Dmitry Vaintrob. The paper acknowledges the earlier population arguments and their contributors.
