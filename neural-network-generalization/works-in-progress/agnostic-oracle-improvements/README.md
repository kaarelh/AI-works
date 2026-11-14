# Agnostic oracle bounds for Bayesian neural networks

**[Paper (PDF)](paper.pdf) · [Complete source](source/paper.tex) · [Verification and limitations](verification/README.md)**

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, Dmitry Vaintrob. Authors are listed in alphabetical order.

Can Bayesian prediction compete with the best small neural network even when no network exactly describes the data? These results give coefficient-one squared-loss comparisons for arbitrary distributions of bounded labels, including noise and model misspecification. They strengthen the positive result in the [tempered-likelihood research note](../agnostic-learning/).

## Two different guarantees

| Learner | Guarantee | Scope |
|---|---|---|
| Dense independent Gaussian tanh weights; calibrated likelihood; prior scale tending to zero at each fixed learner width | At fixed teacher, dimension and depth, excess bound of order `n^(-1/(L-1))` for `L≥3`, or `n^(-1/2)` for one hidden layer, up to logarithms | High probability, on one event for every learner width `N≥m`. Covers posterior-averaged risk and posterior means. Raw-output predictions use the smooth-loss appendix's calibration. |
| Same dense Gaussian family at finite scale `σ²=N^(-γ)` | The improved rates for clipped predictions, with an additional explicit complexity factor | All `γ≥2` at every width; with one hidden layer, all `γ≥1`. No prior-strength limit. Likelihood variance scales as `nλ N^(-γ)`. |
| Prior explicitly mixing over network sizes and continuous weights; fixed Gaussian likelihood centered on clipped outputs | Expected final-posterior-mean risk at most the best clipped teacher risk plus approximately `P [log n + L log(max(d,m)(B+1))] / n` | Any globally Lipschitz activation, including tanh, ReLU and GELU; arbitrary larger maximum width/depth, or no limits. This changes the prior and is an expectation guarantee. |

Here `L` counts the linear readout, `m` is teacher hidden width, `B` bounds its weights, and

```text
P = m(d+1) + (L-2)m² + m.
```

The architectural prior can use independent Cauchy weights or conditionally independent Gaussian weights with a prior over their scale. It has no finite parameter grid. At fixed dimension, its joint width/depth penalty is approximately `m²L²/n`, up to logarithms; one hidden layer instead has a penalty linear in `m`. It puts the preference for small architectures into the prior explicitly, so this is not a proof of the same rate for dense Gaussian weights.

For fixed depth and dimension, the architectural learner can compete with teachers of width `n^α` for every `α<1/2`, allowing any polynomially growing weight bound. With one hidden layer, every `α<1` works. The improved dense Gaussian result, including its finite-scale version for `γ≥2`, allows both width and weight cap `n^α` for `α<1/[4(L-1)]` at `L≥3`, with faster decay than the earlier proof; for one hidden layer in the strong-prior limit the improved range is `α<1/4` with the stated teacher-class calibration.

## What changed in the proof?

The Gaussian argument keeps the learner's negative energy penalty when comparing its empirical loss with the teacher's. A uniform statistical deviation can be absorbed by that penalty. Discarding it earlier led to the slower `n^(-1/(L+1))` rate. A standard smooth-loss theorem extends the argument to the ordinary posterior mean of raw outputs, with extra logarithms.

For the architectural prior, Bayesian averaging reduces squared loss by the posterior prediction variance. A leave-one-out argument uses that reduction to obtain a sharp expected-risk oracle inequality for the **final** posterior mean. The underlying finite-dictionary aggregation result is due to [Høgsgaard, Rebeschini and Wegel (2026)](https://arxiv.org/abs/2607.02247); the paper supplies a continuous-prior proof and quantitative neural-network application. This statistical phenomenon is not claimed as new.

## Audit and qualifications

The supplied Opus 5.5 positive theorem checks out under its conventions. Its zero-prior-scale limit is taken separately at each fixed width, its main predictions are clipped, and it charges teacher weight magnitude. The referenced `statement/tempered-learner.pdf` was absent from the repository snapshot; the compressed statement was checked directly against its supporting proof and the supplied PDF.

Neither result requires close fitting of every noisy label. Such interpolation can fail for the original Gaussian learner. A width-only comparison with arbitrarily large teacher weights also fails uniformly for the fixed proper priors considered here: two inputs can be arbitrarily close while a steep width-one teacher assigns opposite labels. The paper proves this obstruction.

These are conventional mathematical proofs with independent AI-agent checks, **not Lean formalizations or external peer review**. The fast architectural-prior guarantee is in expectation, not a fast high-probability guarantee or a guarantee for posterior draws. Its polynomial-depth dependence does not settle the dense Gaussian prior's depth question.

Run `./build.sh` to rebuild the PDF using TeX Live.
