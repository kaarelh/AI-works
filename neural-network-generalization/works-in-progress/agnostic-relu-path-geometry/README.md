# Path-norm geometry of Gaussian ReLU posteriors

[Paper](paper.pdf) · [Source](source/paper.tex) · [Verification records](verification)

This note studies the actual independent-Gaussian, one-hidden-layer ReLU posterior with a raw Gaussian likelihood and raw linear readout. It gives empirical geometry results and a deterministic range counterexample; it does not claim a new population upper rate.

The main results are:

- **Exact one-dimensional representation.** Normalizing incoming rows gives independent uniform ridge directions and independent Laplace amplitudes. Conditional on the directions, the coefficient posterior is a Bayesian lasso.
- **Finite-width empirical convexification.** At every width `N >= n`, the expected empirical loss plus path penalty is within `C lambda nu log(e/(lambda nu))` of the full convex path-norm optimum. The same quantity bounds squared training-vector distance to its unique fitted vector. A direct Gaussian argument extends this to every input dimension, with an explicit dimension factor.
- **Conditional excess-mass control.** Given directions and training predictions, amplitude mass above the minimum on that affine fiber has mean at most `nu` and a Gamma-type tail.
- **Actual posterior excursions.** Four bounded data pairs force every minimum full-path-norm interpolant to have an excursion of order `1/delta`. At `lambda = delta^2`, the ordinary Gaussian posterior mean also has that excursion, uniformly over all `N >= 4` and `0 < nu <= 1`. This is a deterministic-sample result, not an IID-sample lower bound or a lower bound for every likelihood schedule.
- **A conditional variance diagnostic.** For maximum sample gap of order `log(n/delta)/n` and `N >= n`, conditional Gaussian readout variance is at most `O(lambda + log^2(n/delta)/(n^3 lambda))`. Variation of the hidden-feature conditional means and extrapolation remain uncontrolled by this argument.

The architecture is fixed, all weight coordinates have their stated independent Gaussian laws, and prediction uses the ordinary final posterior. No prior over network sizes or output clipping is introduced.

Run `./build.sh` to compile the PDF in an isolated temporary directory. The proofs have independent AI review records; they are not Lean formalizations.
