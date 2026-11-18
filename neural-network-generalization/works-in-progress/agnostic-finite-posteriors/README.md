# Finite Gaussian Bayesian networks can compete with small approximating networks

**[Paper (PDF)](paper.pdf) · [Source](source/paper.tex) · [Verification](verification/README.md)**

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, Dmitry Vaintrob. Authors are listed in alphabetical order.

This paper proves squared-loss oracle inequalities for **actual finite Gaussian Bayesian tanh networks**, with arbitrary bounded IID inputs and labels. A small network need only approximate the data well. The ordinary posterior mean of raw outputs has risk at most the comparison network's risk plus a vanishing remainder, with leading coefficient one.

Every learner has one specified dense architecture and independent centered Gaussian weights. There is no prior over network sizes. Auxiliary finite architectures and mixtures used to count functions or prove PAC–Bayes bounds are proof devices only.

## Main results

Let `H` count hidden layers, so total depth is `L=H+1`. The comparison network has width `m` and coefficient bound `B≥1`; the learner has any width `N≥m`. The base prior variance is `σ²=N^(−γ)`, and first-layer, internal, and readout variances are `Nσ²/d`, `σ²`, and `σ²/N`. The Gaussian likelihood variance is `n λ_n σ²`, with an explicit deterministic calibration.

| Setting | Fixed-resource remainder, up to logarithms | Permitted width `m=n^a` with fixed coefficient cap |
|---|---|---|
| One hidden layer, all `γ≥1` | `n^(−1/2)` | `a<1/2` |
| `H≥2`, all `γ≥2` | `n^(−1/H)` | `a<1/(2H)` |
| `H≥2`, mean field `γ=1` | `n^(−1/(2^(H+1)+3))` | `a<1/2^(H+2)` |
| `H≥2`, all `γ≥1` with one common calibration | `n^(−1/(v+2b+3))`, where `v=2^(H+1)`, `b=max(1,(H−1)/2)` | `a<1/[2(v+2b)]`; improved to `a<1/18` for `H=2` |

If width and coefficient cap both grow as `n^a`, halve the last column. The width-growth statements use calibrations for the declared comparison class; they are not merely substitutions into a fixed-teacher asymptotic formula. The paper also gives a separate intermediate-exponent bound that can be faster when `γ>1` is separated from one.

The last row has **one high-probability sample event simultaneously for every `γ≥1` and every eligible learner width**. Its rates for two, three, and four hidden layers are `n^(−1/13)`, `n^(−1/21)`, and `n^(−1/38)`. Mean field alone has the better respective rates `n^(−1/11)`, `n^(−1/19)`, and `n^(−1/35)`.

No width or prior-strength limit is taken. All results control posterior-average raw squared loss, which also bounds the ordinary posterior mean's loss by Jensen's inequality. Ordinary internally biased teachers compile exactly into the stated architecture with one extra constant neuron per hidden layer and coefficient cap `2B`.

## An explicit all-exponent sample budget

Write `E=d(d+1)B²+2Hm²B²`. Up to the displayed logarithmic and dimension factors, the common all-exponent theorem gives

```text
n ≥ C_H (d+1)² polylog(...) λ^(−a_H) ε^(−3),
a_H = 2^(H+1) + 2 max(1,(H−1)/2),
```

and oracle excess of order `λ E + ε`, together with teacher-neighborhood, confidence, and teacher-concentration terms. The paper states those terms explicitly. Constants may grow rapidly with hidden depth. At two hidden layers, the budget improves to `λ^(−9) ε^(−4)`, allowing joint width and coefficient growth `n^a` for `a<1/36`.

An additional sample-dependent prior prefactor `σ²=t_n² N^(−γ)` yields the faster `n^(−1/H)` rate for all `γ≥1`. This still uses a finite Gaussian prior, but changes that prior as the sample size grows. A separate corollary permits the first-layer fan-in variance to remain fixed.

## Why weights must be counted

The appendix gives a fixed-dimension, noiseless obstruction to the literal width-only conjecture. For any prescribed finite Gaussian architecture and positive likelihood temperature, a four-point law has a width-two tanh teacher with zero risk, while every training sample leaves the posterior mean with risk at least `1/8`. Input variance stays at least `1/2`; a unit-circle construction is also given. The teacher's weights grow as two oppositely labeled inputs approach each other.

The law is chosen after the prior and temperature. This argument excludes uniform width-only bounds for prescribed finite calibrations; it does not defeat every data-adaptive temperature on one law. The separate [temperature-obstruction paper](../agnostic-temperature-obstruction/) proves that stronger kind of negative result with noisy labels.

## Proof and scope

For stronger scales, an energy inequality and smooth-loss capacity bounds control raw posterior risk. Spectral truncation separates a Gaussian matrix's typical high-rank component from the component that has a substantial prior cost. Near mean field, entropy-ball covariance stability gives finite output covers. A common auxiliary measure and a simultaneous-scale PAC–Bayes argument make the final statistical event uniform over prior scales and learner widths. Weighted posterior tail estimates justify all raw-prediction claims.

The likelihood is calibrated, not forced to interpolate arbitrary noisy labels. The theorem does not supply an inference algorithm or a bound polynomial jointly in unrestricted teacher width and depth. Attaining the faster fixed-prefactor mean-field rate remains open. The [fixed-dimension sequel](../agnostic-lipschitz-oracles/) gives a shorter argument for all globally Lipschitz activations and faster low-dimensional tanh rates, at the cost of dimension-dependent sample exponents. The [ReLU paper](../agnostic-relu-sharp/) has matching strict comparator-growth exponents; a [nonexpansive prior restriction](../agnostic-nonexpansive/) gives a much better joint width–depth polynomial for restricted teachers.

The paper has conventional proofs and independent AI-agent mathematical reviews. It is **not Lean verified or externally peer reviewed**. Run `bash build.sh` to rebuild the PDF.
