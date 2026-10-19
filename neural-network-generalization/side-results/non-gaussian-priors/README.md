# Bayesian neural-network learning with non-Gaussian weight priors

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Review and build records](verification/README.md) · [Collection index](../../README.md)

**Status:** Proved side result with independent AI-agent mathematical reviews. Not Lean verified or externally peer reviewed.

The three positive learning results extend to independent non-Gaussian weights from a common family. Let the standardized coordinate law be even, have variance one, and have density

$$
q(u)=Z^{-1}e^{-V(u)},\qquad V\in C^2,\qquad
0<m\le V''(u)\le M<\infty.
$$

The law and its curvature bounds are fixed independently of network width. A non-Gaussian example is the variance-standardized law proportional to $e^{-u^2/2-b\log\cosh u}$ for fixed $b>0$.

At each fixed depth, the paper proves a sample bound polynomial in input dimension and target complexity, independently of learner width, in all three regimes:

1. The strong-prior limit, taken separately at each fixed width.
2. Finite scale with any fixed $\gamma>1$.
3. Mean-field scaling, $\gamma=1$.

Each theorem covers **every width $`N\ge C_L(f)`$**, where $C_L(f)$ counts both width and weight magnitude at the specified depth. The original layer scalings are retained. The networks have tanh hidden layers, a linear readout, and the original global margin restriction on all Boolean inputs. Training conditions on exact agreement with noiseless labels. For any common training/test distribution, correct-label posterior probability exceeds $2/3$ on all but an arbitrarily small fraction of test inputs, with high probability over training samples. The result controls posterior mixtures.

The paper also proves polynomial comparison between bounded-weight circuit complexity and normalized negative log function prior mass. For the strong-prior result alone, two-sided quadratic density envelopes suffice without symmetry or log-concavity; asymptotically quadratic log densities give the original weighted-energy prior ordering at exponential-rate level.

## Proof ingredients

The target-mass argument conditions perturbations on a convex cylinder, controls their operator norms, and translates this event to a cloned target. Upper curvature bounds the translation cost, while lower curvature supplies concentration. For $\gamma>1$, a singular-value tail permits deterministic compression.

At $\gamma=1$, a relative Lindeberg estimate compares log partition functions for finite covariance tests with polynomial losses in the tilt budget. It transfers finite entropy certificates to auxiliary Gaussian covariance towers, which have small finite network implementations. The first layer retains its actual non-Gaussian law. This is a description argument for the actual posterior, not a replacement of that posterior by an NNGP learner.

The manuscript includes the statistical argument, deterministic compression, entropy certificates, and finite-realization proofs, so it can be read independently of the earlier papers.

## Scope

The sample polynomials may depend on depth, exponent, and coordinate law. The paper does not claim polynomial depth dependence, computationally efficient inference, noisy-label learning, or a subcritical non-Gaussian lower bound. Laplace, uniform, Student, and pure quartic-exponential coordinates at the original layer scales are outside the proved family.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, writes temporary files to `build/`, and refreshes `paper.pdf`. No network access is needed.
