# Width-independent Bayesian neural-network learning on continuous input domains

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Review and build records](verification/README.md) · [Collection index](../../README.md)

**Status:** Proved side result with independent AI-agent mathematical reviews. Not Lean verified or externally peer reviewed.

The main result concerns learning a teacher's **real-valued output** on a compact continuous domain, including the entire unit sphere or ball. The input distribution can be arbitrary. There is no global output-margin condition on the prior, and the teacher can cross zero.

Suppose a tanh teacher has depth $L$, width $C$, and weights bounded in absolute value by $B$. For **every learner width $`N\ge C`$**, the sample bound is polynomial in dimension, teacher resources, and accuracy parameters at each fixed depth, independently of $N$. Width and weight magnitude are counted separately; the result does not give a width-only bound for arbitrarily large teacher weights.

## Regression theorem

Training observes clean values $f(X_i)$. The posterior conditions on

$$
|z_w(X_i)-f(X_i)|<\rho
$$

at every training input, for a positive tolerance $\rho$. For any larger test tolerance $\tau>\rho$, polynomially many samples suffice to make

$$
\Pr_{w\sim\Pi(\cdot\mid S)}
\bigl(|z_w(x)-f(x)|\le\tau\bigr)>2/3
$$

outside a set of test probability at most $\varepsilon$, with training-sample probability at least $1-\delta$. The guarantee controls the full posterior, including mixtures.

The theorem covers the strong-prior limit at each fixed width, every finite exponent $\gamma>1$, and mean-field scaling $\gamma=1$, with the original layer scalings. Gaussian priors and the [non-Gaussian bounded-curvature family](../non-gaussian-priors/) are included. Taking $\rho=\tau/2$ gives a bound polynomial in $d,C,B,1/\tau,1/\varepsilon$ and $\log(1/\delta)$ at fixed depth and exponent.

The input net used in the proof creates a finite family of approximating functions. Neither the training distribution nor the actual learner is discretized. At mean field, a bounded dual representation of arbitrary readouts replaces the earlier sign-margin argument.

## Exact interpolation in the strong-prior limit

The paper also proves a sample guarantee simultaneously for every learner width and every exact interpolant whose weighted energy is at most the cloned teacher's energy bound. In particular, it covers all minimum-energy exact interpolants and every mixture of them.

For Gaussian priors, take the strong-prior limit first at each positive training tolerance, and then send the tolerance to zero. Every iterated subsequential posterior limit is supported on minimum-energy exact interpolants and satisfies the learning guarantee. This does not identify the equality-conditioned posterior at a fixed nonzero prior scale or justify reversing these limits.

## Classification and scope

With binary training labels, conditioning only on training margins also gives a theorem if the teacher has a positive signed margin on the data support. This needs no robustness restriction on the prior. It applies to the original finite Boolean targets and to separated continuous supports.

A nonconstant continuous classifier on a connected sphere cannot have a nonzero absolute margin everywhere. Binary-only learning without a support-margin assumption remains a separate question. Learning real scores can imply sign generalization through a bound on the probability of small teacher scores; that consequence uses score labels during training.

The results allow large dependence on depth, including rapidly growing polynomial degrees. The [continuous-depth lower bound](../../works-in-progress/continuous-depth-lower-bound/) shows that an exponential depth dependence is necessary in general for the unrestricted Gaussian regression learner, even at constant teacher width and bounded weights. It covers the strong-prior limit, every fixed exponent above one at sufficiently large finite widths, and mean-field scaling in the width-first limit, on a particular fixed nonatomic distribution on the circle. It does not concern uniform spherical inputs.

The upper bounds do not establish computationally efficient inference, learning from noisy real-valued observations, or a finite-scale zero-tolerance regression theorem.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, writes temporary files to `build/`, and refreshes `paper.pdf`. No network access is needed.
