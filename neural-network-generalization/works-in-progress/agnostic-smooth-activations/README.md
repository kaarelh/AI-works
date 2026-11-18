# Finite Bayesian neural networks as agnostic approximation learners

[Paper](paper.pdf) · [Source](source/paper.tex) · [Verification record](verification/README.md)

One finite dense Gaussian neural network can compete with the best smaller bounded-weight network even when that network only approximates the data. The guarantee concerns the ordinary posterior mean of the raw output, arbitrary bounded IID labels, every learner width above the comparison width, and every prior exponent `gamma >= 1`. There is one architecture and one Gaussian prior. The Gaussian likelihood is calibrated using the learner's Bayesian evidence; its calibration does not require the comparison network's size or prediction risk.

The activation can be any twice continuously differentiable function into `[-1,1]` with first derivative bounded by one and bounded second derivative. Examples include tanh and sigmoid. The activation need not vanish at zero.

## The approximation guarantee

Let `H >= 2` be hidden depth, `m` comparison width, and `B` its weight cap. Define

`v = max(4H, H^2 + 2H - 2)` and `r = v/(2H)`.

Write `R(g)` for the comparison network's squared risk. Up to logarithmic factors and constants depending on depth and activation, the posterior's expected raw squared risk, and hence its mean prediction's risk, are bounded by

`R(g) + A R(g)^(1 - 1/r) n^(-1/v) + A^r n^(-1/(2H))`.

The leading term in the comparison resource `A` is

`d(d+1) B^2 + 2H m^2 B^2`.

The resource also includes an explicit local-mass term, logarithmic in approximation accuracy and polynomial in comparison resources at fixed depth. Input dimension enters polynomially. Theorem 1.1 gives all definitions and the likelihood calibration.

At fixed comparison resources:

| Hidden layers H | Fixed positive comparison risk | Zero comparison risk |
| --- | --- | --- |
| 1 | n^(-1/2) | n^(-1) |
| 2 | n^(-1/8) | n^(-1/4) |
| 3 | n^(-1/13) | n^(-1/6) |
| 4 | n^(-1/22) | n^(-1/8) |
| 5 | n^(-1/33) | n^(-1/10) |
| H >= 3 | n^(-1/(H^2+2H-2)) | n^(-1/(2H)) |

The H=1 row uses the separate exponent pair `(v,rho)=(2,1)` and has remainder `A sqrt(R(g)/n) + A^2/n`. Logarithmic factors are omitted. The same calibration permits comparison width `n^alpha` and weight cap `n^beta` with vanishing excess whenever `alpha + beta < 1/(2v)`. It does not need those exponents as inputs.

Two separate fixed calibrations improve growing-comparison ranges:

- **One hidden layer, monotone activation**: sample budget of order `(d+1)/(lambda epsilon)`, with risk penalty of order `lambda A + epsilon`, allows `alpha + beta < 1/2`. Tanh and sigmoid qualify. Generic bounded smooth activations retain a fixed-teacher rate `n^(-1/2)`.
- **Two hidden layers**: budget of order `(d+1)^2 lambda^(-6) epsilon^(-2)` allows `alpha + beta < 1/12`. The evidence-calibrated theorem instead supplies the faster zero-risk rate in the table.

## Sharper tanh bounds above mean field

For fixed `gamma > 1`, define `h=max(H,3)` and

`v_gamma = 3 + gamma*(h-1)/(gamma-1)`, `rho_gamma = 1 + gamma/(gamma-1)`.

An additional evidence calibration gives the same oracle form with this exponent pair. It localizes the finite-width PAC–Bayes comparison and spectral truncation argument; the existence of a positive-risk rate denominator linear in depth at fixed `gamma > 1` was already established in the earlier finite-posterior paper.

The new zero-risk rate is `n^(-1/rho_gamma)`, independent of depth at fixed comparison resources. For example, `gamma=3/2` and `H>=3` give `(v,rho)=(3H,4)`. The comparison-resource power is `3H/4`, so this remains far from a sample bound polynomial jointly in width and depth.

At `gamma >= 2`, the untruncated energy argument gives the stronger pair `(v,rho)=(H,1)` for tanh. Every branch provides an observable risk certificate. Selecting the smallest valid certificate calibrates the likelihood of the same fixed Gaussian learner and obtains the best of the applicable bounds; it does not introduce a prior over models.

## Why the bound is independent of learner width

The proof separates retained Gaussian directions from a residual field. Direct Gaussian concentration controls the residual feature operator even when the subsequent coefficients depend on that same realization. A vector Bessel inequality propagates errors without multiplying them by rank. Separate estimates of residual variances allow retained factor coefficients to be contracted into the next layer, reducing the number of parameters in the proof's covering family.

All finite widths are covered by one family of proof programs. Above the effective-width threshold `N/tau^2`, Gaussian compression supplies the approximation. Below it, the actual network has few enough parameters for an ordinary parameter cover. The programs only prove statistical bounds; the learner keeps its Gaussian prior and raw network outputs.

The final statistical argument localizes around empirical risk. It calibrates the likelihood through the evidence and proves an observable risk certificate before comparing that certificate with a small network. Auxiliary good sets may depend on the sample: their prior bounds hold for every fixed sample, while all statistical suprema concern a fixed family of programs.

## Model and limits

Inputs lie in `[-1,1]^d`; labels lie in `[-1,1]`. The architecture has `H` hidden layers, a linear readout, and a first-layer bias coordinate. The comparison network has the same activation and depth. Tanh comparison networks with other biases can be represented using one additional constant neuron per hidden layer.

At learner width `N`, independent Gaussian variances are `tau^2/d`, `tau^2/N`, and `tau^2/N^2` in the first layer, internal layers, and readout. The likelihood variance is `n lambda tau^2/N`. Setting `tau^2=N^(1-gamma)` gives the exponent regime; the theorem covers every `0 < tau <= 1` simultaneously.

No width or prior-strength limit, support restriction, or prior over network sizes is used. Constants can grow quickly with depth. The theorem does not give polynomial sample complexity jointly in width and depth, remove the comparison weight bound, or supply an efficient posterior sampler.

The proof has undergone independent AI-agent mathematical checks and is not Lean verified. Run `./build.sh` with `pdflatex` installed to rebuild the PDF.
