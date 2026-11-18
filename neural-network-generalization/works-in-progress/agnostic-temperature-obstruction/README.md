# Deep Bayesian tanh networks can learn a shallow teacher slowly

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

A very wide Gaussian Bayesian tanh network can learn slowly on one fixed regression problem even when the true conditional mean is the shallow one-neuron function `tanh(x₁)`. Choosing a likelihood temperature from the data, or averaging arbitrary temperature-dependent posterior means, does not remove the obstruction.

## Main result

Fix a hidden learner depth `H≥3` and any exponent `β>2/H`. There is a fixed input law on a unit sphere in a fixed finite dimension, with nondegenerate covariance, and independent Gaussian observation noise of variance `1/16`, such that:

- The regression function is `g(x)=tanh(x₁)`, with a width-one, one-hidden-layer implementation and unit coefficients.
- On the data support it also has an exact implementation at the learner's depth, with width two and coefficient cap four.
- Almost surely along a deterministic sample subsequence `n_j`, every learner width `N≥n_j²`, every Gaussian prior scale `Nσ²≤1`, and every positive likelihood temperature has excess squared risk at least `n_j^(−β)`.
- The same lower bound holds for arbitrary data-dependent mixtures of their **ordinary raw posterior means**.
- The result still holds after adding an independent broad Gaussian affine output component, including an output bias and direct linear input features.

The actual Gaussian likelihood family contains the true observation-noise variance. This is therefore a correctly specified regression example. Each component learner has one fixed dense architecture. The lower bound also permits averaging over eligible widths and prior scales.

The conclusion excludes a sample bound polynomial jointly in input dimension, learner depth, and inverse excess accuracy for this family, uniformly over sufficiently large widths. It does not exclude a polynomial bound at each fixed depth.

## Exponential depth cost at inverse-polynomial accuracy

There are universal positive constants `c,C` such that, for every sufficiently large hidden learner depth `H`, a uniform input law in dimension `d=4H+2` has the same shallow regression function and independent Gaussian noise, but after

```text
n = 4 · 256^H
```

observations, all allowed raw posterior-mean mixtures still have excess at least `c H^(−6)` with probability at least 90%, at every learner width `N≥exp(C H)`. The constants may depend on the fixed covariance cap for optional affine output priors. Thus even inverse-polynomial excess accuracy can require exponentially many examples as learner depth grows. The teacher remains shallow and has width one.

This finite-depth theorem uses a distribution indexed by `H`; the next theorem fixes the distribution once `H` is chosen and then lets sample size tend to infinity. Neither asserts an exponential lower bound at one fixed positive excess accuracy.

## Explicit slow-rate exponents

For an auxiliary fixed grid dimension `D`, define

```text
ρ = max(2/D, (1+2/D)/H),
κ = (1+2/D)(2−1/H).
```

When `ρ<1/2`, the fixed-law Gaussian-noise construction gives excess at least `n_j^(−2ρ−o(1))`, uniformly at learner widths above `C n_j^κ log(n_j)`. The dimension is `d=D+2`.

A concrete choice is `D=4H`, giving:

```text
d = 4H+2,
2ρ = 2/H + 1/H²,
κ = 2 − 1/(2H²) < 2.
```

Thus every width `N≥n_j²` eventually lies in the claimed range. Increasing the fixed dimension makes the lower-rate exponent arbitrarily close to `2/H`.

## Other results in the paper

A simpler construction gives constant excess in two dimensions for a width-two teacher with coefficient cap growing faster than `n log n`. The input covariance stays nondegenerate, and every likelihood temperature fails at every sufficiently large finite width.

A Fourier construction recovers the sharper teacher-growth obstruction

```text
H a + (H+1)b > (H+1)/(2H)
```

for width `n^a` and coefficient cap `n^b`, in a fixed dimension chosen from the strict exponent gap. Its inputs also lie on a unit sphere. In particular, every `b>1/(2H)` has a fixed-dimensional width-two counterexample.

The constant-excess mixture theorem covers raw posterior means and clipping each raw mean before mixing. The fixed-law slow-rate theorem with affine output components and Gaussian labels concerns **raw means only**. Means of clipped posterior draws are a different prediction convention.

## Model and mechanism

The independent Gaussian variances are `Nσ²/d` in the first layer, `σ²` in subsequent hidden layers, and `σ²/N` in the readout. The Gaussian likelihood variance is `nλσ²`. The range `Nσ²≤1` includes every canonical exponent `γ≥1` through `σ²=N^(−γ)`. No width or prior-strength limit is taken.

Small temperatures fit noisy singleton observations using a deep-network memorizer. Larger temperatures shrink the nonlinear part of the prediction. Conditional Gaussian readout formulas give a common linear witness for the error, which also rules out cancellation by mixtures. Nested rare grid blocks make the obstruction occur on one fixed law along a sample subsequence.

## Scope

The fixed input law is countably supported. No claim is made for a smooth input density. The lower bound tends to zero, so it is a slow-learning result rather than an inconsistency result. Its width range grows with sample count; it does not concern keeping one finite learner architecture fixed while taking arbitrarily many samples.

The explicit finite-depth theorem gives an exponential sample lower bound at **inverse-polynomial accuracy**, with input dimension linear in learner depth. It does not establish an exponential-depth lower bound at one fixed positive accuracy or at a dimension fixed as depth grows. Restricting the learner's prior support or adding prior features that already represent the true nonlinear regression function changes the setting.

The manuscript has independent AI-agent mathematical reviews and a reproducible LaTeX build. It is not Lean verified or externally peer reviewed.

Authors, in alphabetical order: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, and Dmitry Vaintrob.
