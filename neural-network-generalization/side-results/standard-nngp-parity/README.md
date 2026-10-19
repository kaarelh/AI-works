# Parity under standard-scaling neural-network Gaussian processes: superpolynomial sample lower bounds at fixed depth, and an obstruction

[Paper (PDF)](paper.pdf) · [LaTeX source](source/standard-nngp-parity.tex) · [Review record](verification/review.md) · [Numerics](numerics/) · [Collection index](../../README.md)

**Status:** Proved side result with independent AI-agent mathematical reviews. Not Lean verified, not reviewed by a human, and not externally peer reviewed. Byline: Claude.

## Question

Main result 4 proves an $\exp(\Omega(d))$ parity lower bound for the collection's $\gamma<1$ learners, whose width limit is the iterated arcsine kernel. Does the same hold for the usual NNGP scaling? There the weight variances are $\sigma_1^2/(d+1)$ in the first layer and $\sigma_\ell^2/N$ in later layers, including the readout. This is the exponent tuple $(0,1,\ldots,1,1)$ of [FAQ Question 9](../../TECHNICAL-FAQ.md#9-can-we-classify-all-tuples-of-layerwise-scaling-exponents), which is not on the $\gamma$ line. At this scaling the preactivations stay of order one, so the limit is the dual-activation kernel of the activation itself.

## Results

Width tends to infinity first, at fixed dimension $d$, depth $L$, gains, margin and training sample. Success means correct-label posterior probability strictly greater than $2/3$.

- **Width limits (proved).** For every bounded continuous nonconstant activation, the output converges to a nondegenerate Gaussian process with kernel $A\,F((1+x\cdot y)/(d+1))$. Here $F$ has nonnegative Taylor coefficients that do not depend on $d$. Both learners' posterior label probabilities converge to those of the conditioned Gaussian process.
- **No global margin, every training set (proved).** Condition only on the training signs. For every such activation, every depth and every gain, every training set with $n\le d^{\sqrt d/10-1/2}/6000$ leaves at least a quarter of the inputs of full parity without confidence above $2/3$. This holds for every training set, including deliberately chosen ones. For $`k`$-sparse parity the threshold is $\binom d{\lfloor\sqrt k/5\rfloor}/6000$; for fixed $k$ the failure fraction is at least $2^{-k}-1000\,n/\binom dk$. The same holds for the margin learner when the readout variance is $\sigma_L^2N^{-b}$ with $b<1$.
- **Global margin, tanh (proved).** For $\tanh$ at every fixed depth and every choice of gains and margin, take $n\le\exp(\frac1{20}\sqrt d\log d)$ iid uniform examples of full parity. With probability at least $1-e^{-d/10}$, the Gibbs error stays at least $3/8$ and the confidence failure at least $1/16$. The proof also covers odd activations whose dual coefficients decay no faster than $e^{-o(\sqrt m\log m)}$, but not erf.
- **Exponential lower bound (open).** We do not know whether $\exp(\Omega(d))$ samples are needed. One step of main result 4 provably fails here: its polynomial bound on the conditioning cost per sample. For $\tanh$ and $n\ge\exp(d^\epsilon)$, that cost is superpolynomial in $d$. We expect exponential behaviour, but this is only a heuristic.

The sign-only bound uses a universal inequality between consecutive level masses of an isotropic kernel. The margin bound also needs a lower bound on every eigenvalue of the kernel. It comes from an explicit Fourier-integral formula for the Hermite coefficients of tanh.

## Numerics

The [numerics folder](numerics/) contains two computations; both are illustrations, not evidence about asymptotic exponents.

- **Spectra.** `spectrum.py` computes exact kernel spectra at $d$ up to 160 and checks the spectral lemmas. Output: `spectrum.txt`, `spectrum.json`.
- **Sign-only posteriors.** `signgp_parity.py` computes sign-only posteriors for full parity at $d=10,12$, with exact Hamiltonian Monte Carlo, for tanh and arcsine kernels. Output: `signgp_parity.txt`, `signgp_parity.jsonl`. It uses the sampler validated in the [beyond-parity note](../../works-in-progress/beyond-parity/verification/sign-gp/).

`make_tables.py` writes the paper's two tables from these outputs. Requirements: Python 3 with NumPy and SciPy, and a C compiler.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, writes temporary files to `build/`, and refreshes `paper.pdf`. No network access is needed. `build/`, compiled `.so` files and run logs are not part of the published folder.
