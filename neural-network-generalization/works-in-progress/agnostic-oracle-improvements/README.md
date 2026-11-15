# Sharper agnostic bounds for dense Gaussian Bayesian neural networks

**[Paper (PDF)](paper.pdf) · [Complete source](source/paper.tex) · [Verification and limitations](verification/README.md)**

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, Dmitry Vaintrob. Authors are listed in alphabetical order.

Can a dense Gaussian Bayesian network compete with a small network that only approximates the data? These results give coefficient-one squared-loss comparisons for arbitrary distributions of bounded labels, including noise and model misspecification. They strengthen the positive result in the [tempered-likelihood research note](../agnostic-learning/).

Every learner has a specified dense architecture and independent centered Gaussian weight coordinates. Teacher cloning is a comparison construction in the proof; every coordinate of the learner remains random under its prior.

## Results

| Prior regime | Prediction convention | Rate at fixed teacher resources and dimension |
|---|---|---|
| Strong-prior limit, any fixed depth `L≥3` | Posterior-averaged clipped risk and mean of clipped outputs | Approximately `n^(-1/(L-1))`, improving `n^(-1/(L+1))` |
| Strong-prior limit, any fixed depth `L≥3`, smooth-loss calibration | Raw posterior-averaged risk and ordinary raw-output posterior mean | Same exponent, with additional logarithms |
| Strong-prior limit, one hidden layer | Clipped or raw predictions, with the appropriate calibration | Approximately `n^(-1/2)` |
| Finite prior scale `σ²=N^(-γ)`, every `γ≥2`, depth `L≥3` | Clipped posterior-averaged risk and mean of clipped outputs | Approximately `n^(-1/(L-1))`; no prior-strength limit |
| Finite prior scale, every `γ≥1`, one hidden layer | Clipped posterior predictions | Approximately `n^(-1/2)`; includes mean field |

All rates suppress logarithmic factors. Each theorem gives a high-probability bound on one sample event for every learner width `N≥m`. Here `m` is teacher hidden width, `L` counts the linear readout, and `B` bounds teacher weights. An exact teacher implementation at each eligible width has energy at most

```text
E = d(d+1)B² + 2(L-1)m²B².
```

The leading teacher penalty is `λ_n E`. For `L≥3`, the improved calibration has `λ_n` of order `n^(-1/(L-1))`, up to dimension factors and logarithms. For example, depth three improves from a quarter-power to a square-root rate.

At fixed dimension and depth `L≥3`, both teacher width and weight cap can grow as `n^α` for every `α<1/[4(L-1)]`, with a faster remainder than in the earlier proof. This also holds in the new finite-scale theorem for `γ≥2`. With one hidden layer, the strong-prior result's teacher-class calibration improves the growing-width-and-weight range to `α<1/4`; the finite-scale theorem is stated with its separate calibration.

## Why the proof improves

The statistical comparison retains the negative learner-energy penalty. A uniform deviation bound can be absorbed by that penalty. Discarding it led to the earlier `n^(-1/(L+1))` rate. A standard smooth-loss theorem extends the argument to the ordinary posterior mean of raw outputs.

At finite prior scale, an entropy inequality turns Gaussian relative entropy into an energy bound. Combining it with a global statistical inequality and an explicit Gaussian perturbation of a cloned teacher gives the oracle bound directly for the finite posterior.

## Scope and audit

The supplied Opus 5.5 positive theorem checks out under its conventions. Its strong-prior limit is taken separately at each fixed width; no width-uniform prior-strength threshold is claimed. The referenced `statement/tempered-learner.pdf` was absent from the repository snapshot, so the compressed statement was checked directly against its supporting proof and the supplied PDF.

The likelihood is calibrated rather than required to fit every noisy label exactly. The new finite-scale result uses likelihood variance `nλ_n N^(-γ)`. Arbitrarily tight conditioning can memorize noise. Teacher weight magnitude is still counted; the paper proves a width-one obstruction using two nearby inputs and the strong-prior energy budget.

The sample exponent still deteriorates with depth. A favorable bound based only on teacher parameter count for dense Gaussian Bayesian learning remains open. The improved deep finite-scale rate for `1≤γ<2`, and raw-output finite-scale predictions, also remain open here.

These are conventional mathematical proofs with independent AI-agent reviews, **not Lean formalizations or external peer review**. Run `./build.sh` to rebuild the PDF using TeX Live.
