# Parity under standard-scaling neural-network Gaussian processes: superpolynomial and nearly exponential sample lower bounds at fixed depth

[Paper (PDF)](paper.pdf) · [LaTeX source](source/standard-nngp-parity.tex) · [Review record](verification/review.md) · [Revision records](verification/revision-2026-10-20/) · [Numerics](numerics/) · [Collection index](../../README.md)

**Status:** Proved side result with independent AI-agent mathematical reviews. The one-sided coercivity theorem used by the typical-sample bounds is a theorem of the collection's Lean project; the rest is conventional proof, not Lean verified, not reviewed by a human, and not externally peer reviewed. Authors: Claude Opus 5.5, Kaarel Hänni, and Dmitry Vaintrob (alphabetical order). Revised 20 October 2026: new nearly exponential typical-sample theorem; Section 7 (formerly 6) corrected.

## Question

Main result 4 proves an $\exp(\Omega(d))$ parity lower bound for the collection's $\gamma<1$ learners, whose width limit is the iterated arcsine kernel. Does the same hold for the usual NNGP scaling? There the weight variances are $\sigma_1^2/(d+1)$ in the first layer and $\sigma_\ell^2/N$ in later layers, including the readout. This is the exponent tuple $(0,1,\ldots,1,1)$ of [FAQ Question 12](../../TECHNICAL-FAQ.md#12-can-we-classify-all-tuples-of-layerwise-scaling-exponents), which is not on the $\gamma$ line. At this scaling the preactivations stay of order one, so the limit is the dual-activation kernel of the activation itself.

## Results

Width tends to infinity first, at fixed dimension $d$, depth $L$, gains, margin and training sample. Success means correct-label posterior probability strictly greater than $2/3$.

- **Width limits (proved).** For every bounded continuous nonconstant activation, the output converges to a nondegenerate Gaussian process with kernel $A\,F((1+x\cdot y)/(d+1))$. Here $F$ has nonnegative Taylor coefficients that do not depend on $d$. Both learners' posterior label probabilities converge to those of the conditioned Gaussian process.
- **No global margin, every training set (proved).** Condition only on the training signs. For every such activation, every depth and every gain, every training set with $n\le d^{\sqrt d/10-1/2}/6000$ ($d\ge25$; this explicit bound exceeds one only for $d\ge385$) leaves at least a quarter of the inputs of full parity without confidence above $2/3$. This holds for every training set, including deliberately chosen ones. For $`k`$-sparse parity with $k\ge25$ the threshold is $\binom d{\lfloor\sqrt k/5\rfloor}/6000$; for fixed $k$ the failure fraction is at least $2^{-k}-1000\,n/\binom dk$. The same holds for the margin learner when the readout variance is $\sigma_L^2N^{-b}$ with $b<1$.
- **Global margin, tanh (proved).** For $\tanh$ at every fixed depth and every choice of gains and margin, and for $d\ge d_0$ (not explicit), take $n\le\exp(\frac1{20}\sqrt d\log d)$ iid uniform examples of full parity. With probability at least $1-e^{-d/10}$, the Gibbs error stays at least $3/8$ and the confidence failure at least $1/16$. The proof also covers odd bounded continuous activations whose odd-degree composite dual coefficients are at least $\kappa e^{-\psi(m)}$, with $\psi$ nondecreasing and $\psi(m)=o(\sqrt m\log m)$, but not erf.
- **No global margin, typical samples, tanh (proved).** For $\tanh$ at every fixed depth and every choice of gains, and for $d\ge d_0$ (explicit but astronomically large; Remark 6.17), take $n\le\exp(10^{-3}d\log\log d/\log d)$ iid uniform examples of full parity. With probability at least $13/16$, at least $3/8$ of the inputs fail. The key new tool is a random-restriction form of the Aspnes–Beigel–Furst–Rudich bound whose loss grows only logarithmically in the posterior mean's amplitude. The coercivity input is the Lean-verified theorem `parity_squared_coercivity_probability`. The same proof covers erf.
- **Exponential lower bound (open).** We do not know whether $\exp(\Omega(d))$ samples are needed.
  - For the sign-only learner, the proof suggests it would follow from two open log-free estimates at linear degree: one-sided coercivity, and a bound on the sampled tail Gram matrix. This is an extension suggested by the proof, not a result.
  - For the margin learner, one step of main result 4 provably fails at this scaling: its polynomial bound on the conditioning cost per sample. For $\tanh$ and $\exp(d^\epsilon)\le n\le e^{cd}$, that cost is superpolynomial in $d$ with probability at least $7/8$. A sharper lower bound shows that no matching upper bound on the cost exists. With our tail-Gram bound, the subcritical head-bound argument at the margin scale therefore cannot give an exponential bound. An earlier version presented such a matching upper bound as the missing step toward an exponential proof; the sharper lower bound shows that no such bound exists.

The every-training-set bound uses a universal inequality between consecutive level masses of an isotropic kernel. The margin bound also needs a lower bound on every eigenvalue of the kernel, from an explicit Fourier-integral formula for the Hermite coefficients of tanh. The typical-sample bound uses two-step regularity of those coefficients and an intrinsic-dimension matrix Chernoff bound.

## Numerics

The [numerics folder](numerics/) contains these computations. They are illustrations and constant checks, not evidence about asymptotic exponents.

- **Spectra.** `spectrum.py` computes exact kernel spectra at $d$ up to 160 and checks the spectral lemmas. Output: `spectrum.txt`, `spectrum.json`.
- **Sign-only posteriors.** `signgp_parity.py` computes sign-only posteriors for full parity at $d=10,12$, with exact Hamiltonian Monte Carlo, for tanh and arcsine kernels. Output: `signgp_parity.txt`, `signgp_parity.jsonl`. It uses the sampler validated in the [beyond-parity note](../../works-in-progress/beyond-parity/verification/sign-gp/).

- **Spectral ratio.** `theta.py` shows that the level-mass decay seen at $d\le160$ is pre-asymptotic: numerically $\theta_r\sqrt r\ge0.61$ for $d\le3200$ and $r\le0.065d$, while its maximum still grows slowly with $d$. Output: `theta.txt`.
- **Constants.** `s1_constants.py` evaluates the conditions and the thresholds of the typical-sample theorem. Output: `s1_constants.txt`.

`make_tables.py` writes the paper's two tables from these outputs. Requirements: Python 3 with NumPy and SciPy, and a C compiler.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, writes temporary files to `build/`, and refreshes `paper.pdf`. No network access is needed. `build/`, compiled `.so` files and run logs are not part of the published folder.
