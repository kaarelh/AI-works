# Bayesian neural networks compete with narrow approximations

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

A single Bayesian neural network can compete with narrower ReLU networks whose coefficients and real-valued outputs are unrestricted. The parameter prior has independent dense coordinates, full support, and finite variance proportional to inverse fan-in. Each coordinate is a Lévy increment at inverse fan-in time. There is no prior over architectures or robustness restriction.

## A direct approximation guarantee with finite-variance labels

Assume only that the labels have a finite second moment. Set `C_n = floor(n^(1/8))`. At every prescribed learner width `N ≥ C_n+1` and hidden depth `1 ≤ H ≤ n^(1/4)`, the ordinary posterior mean trained on **all original observations** satisfies

> Expected test risk ≤ best risk among width-`C_n` shallow ReLU teachers + `O(n^(-1/2) log² n)` + a vanishing marginal label-tail term.

Teacher coefficients and outputs may be arbitrarily large. The input law can be arbitrary on a Boolean cube, or satisfy the stated slab anticoncentration condition on a continuous domain. Input dimension and regularity constants are fixed in this rate.

The parameter prior is fixed. The output range is `[-n^(1/8), n^(1/8)]`, and the Gaussian observation variance is `128 n^(1/4)`. These schedules are deterministic; no labels are clipped, no validation split is used, and no variance is selected from the data. The tail term is explicitly `5 E[Y² 1{|Y| > n^(1/8)}]`, which tends to zero for every finite-second-moment label law. The guarantee is **in expectation**, with coefficient one on the comparison risk.

## Fixed-likelihood bounds and explicit complexity costs

When the conditional mean lies in `[-1,1]` and centered conditional noise is sub-Gaussian with proxy `σ²`, one fixed Gaussian observation variance suffices. The bounded network output enters both likelihood and prediction. Write `s = 1+σ²`, `C` for teacher width, `h` for teacher hidden depth, and `H` for learner hidden depth.

| Comparison class / input setting | Additive expected-risk cost, suppressing logarithms | Learner width |
| --- | --- | --- |
| Shallow teachers, Boolean inputs | `s (d+1)² (C²+H) / n` | Every `N ≥ C+1` |
| Shallow teachers, slab-regular continuous inputs | `s (d+1)^4 (C²+H) / (α² n)` | Every `N ≥ C+1` |
| Shallow teachers, one continuous input dimension | `s (C+H) / (α n)` | Every `N ≥ 6C+6` |
| Formula teachers on Boolean inputs, biases only in the first layer | `s C²(d+1)² h / n` | Every `N ≥ C`, at depth `h` |

The extra neuron in the first two rows carries an affine output bias. The formula condition means that each hidden neuron is used at most once; it is a restriction on the comparison graph, **not** on the learner's prior. Formula teachers with hidden biases and regular continuous inputs also have jointly polynomial bounds, with the looser depth polynomials stated in the paper.

General fixed-depth teachers have a coefficient-free polynomial-width comparison at every sufficiently large learner width. In particular, at every prescribed `N ≥ n`, one fixed likelihood competes in expected risk with a width-`n^u` comparison class for some `u>0`, with a vanishing remainder. Additional learner depth contributes additively, up to logarithms, through a two-channel output construction.

## Other conclusions and scope

- A separate high-probability theorem covers every `N ≥ C+1` at general teacher depth. It trains posteriors at the same architecture on half the data and chooses one variance by validation on the other half. It does not claim the bound after an all-data refit.
- An optional existence theorem covers every realizable width at arbitrary fixed teacher depth with one posterior trained on all observations. Its likelihood schedule is chosen before data, but can require an extremely small, nonexplicit variance at smaller widths. This is separate from the simple fixed-likelihood and shallow all-width schedules above.
- Universal squared-risk consistency holds for arbitrary compact-domain input laws, arbitrary finite-variance labels, and any deterministic learner-width sequence tending to infinity. This pointwise conclusion needs no input regularity; the uniform coefficient-free rates do.
- A two-nearby-inputs counterexample shows why no uniform coefficient-free width-only rate can hold over all input laws on a continuous domain. An atomless version is included.
- Retaining posterior variance in the expectation proof gives bounds for posterior draws and for the test mass on which correct-sign posterior confidence fails to exceed `2/3`.

The core prior-localization theorem is proved in [Fast agnostic learning with infinitely divisible neural-network priors](../agnostic-levy-fanin/). This paper states the imported prior and compiler interfaces explicitly and proves the coefficient-free wrappers, same-width compactification, refinements, and statistical reductions.

The proofs have undergone independent AI-agent mathematical review. They are **not Lean formalized**. These are statistical guarantees for exact posteriors, with no claim of efficient posterior computation. See the verification record for exact reviewed sources and the distinctions between expectation and high-probability guarantees.

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, Dmitry Vaintrob, in alphabetical order.

To rebuild, run `./build.sh` with a LaTeX installation providing `pdflatex`.
