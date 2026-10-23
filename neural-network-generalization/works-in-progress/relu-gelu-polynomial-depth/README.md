# Polynomial-depth learning for ReLU and GELU NNBayes stable under neuron merging

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/mathematical-review.md)

This note proves a sample bound polynomial jointly in Boolean teacher width and depth for a prior restricted to networks whose clipped predictions survive merging neurons into a limited number of populations. It covers ReLU and exact GELU, every learner width above the compiled teacher width, and every Gaussian scale at least as strong as mean field (`gamma >= 1`).

For a layered bounded-fan-in Boolean circuit of width `C` and `L−1` gate stages (network depth `L`), the bound is quadratic in `C` up to logarithms. A deliberately loose literal bound is

```text
n = O((C^2 [2+d+L+log(4/epsilon)]^9 + log(1/delta))/epsilon).
```

The paper gives substantially more informative explicit budgets. The fixed-other-parameters width dependence is `O(C^2 log^3(2+C))`. The result is uniform over learner width and scale. Training conditions on `f(X_i) z(X_i) > 1/2`; test failure means `f(X) z(X) <= 1/4`. The theorem bounds the posterior average of this failure probability. Conditioning the prior on the original global absolute output margin is optional: both prior conventions are covered. Posterior-confidence criteria follow by Markov's inequality.

The main ingredients are:

- An exact Boolean compiler, using one ReLU neuron per gate or two GELU neurons per logical wire, with constant wires counted. The learner needs width at least `C` for ReLU and `2C` for the stated GELU compiler.
- A positive Gaussian cylinder controlling only teacher-population directions. Exponentially small parameter tolerances in depth cost only their logarithm; unconstrained Gaussian bulk coordinates are retained.
- A Gaussian union bound over all possible neuron partitions, taken before choosing a witness partition for a sampled network.
- A finite code for the merged network. ReLU homogeneity removes population-size parameters; GELU uses a perspective activation uniformly Lipschitz in the population scale, including scale zero.

The prior restriction is a condition on the learner's weights and outputs, independent of the target. It is **not** claimed equivalent to the original internal-noise restriction or established for ordinarily trained networks. The theorem concerns layered Boolean teachers, with compilation overhead included. It does not prove polynomial depth dependence for the unrestricted prior, arbitrary analog teachers, or efficient posterior sampling.

The source and PDF have undergone independent AI-agent mathematical review. Their main learning statements and polynomial corollaries have Lean proofs; they remain research manuscripts.

To rebuild, run `./build.sh` from this directory.

The [publication record](verification/publication-build.json) records isolated rebuilding and exact source/PDF hashes.

## Lean verification

The main statements are included in the second formalization batch. [Exact coverage and exclusions](../../lean/review/BatchTwo-coverage.md) · [Lean entry point](../../lean/NeuralGeneralization/BatchTwoMain.lean). This label does not extend automatically to every appendix, remark or numerical allocation. The original mathematical review records describe their earlier source snapshots.
