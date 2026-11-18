# Bayesian neural networks adapt to approximation error

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Build script](build.sh) · [Verification files](verification/)

One fixed Gaussian Bayesian network can compare its squared test loss with smaller approximating networks without knowing their width, coefficient bound, or risk. The observation variance is selected from empirical free energy. Prediction uses one ordinary posterior mean of the raw real output; there is no prior over architectures or mixture of predictors.

For a comparison network of risk `R` and implementation cost `A`, the main stronger-scale oracle is

`R + ~O(A R^(1−1/r) n^(−1/r) + A^r/n)`.

Here `r` is hidden depth for tanh with at least two hidden layers, and total affine depth for every globally Lipschitz activation, including ReLU, GELU, sigmoid and softplus. It applies to every finite learner width and every canonical Gaussian exponent `gamma >= 2`; one hidden layer permits every `gamma >= 1`. Shallow tanh has the sharper remainder `~O(sqrt(A R/n) + A/n)`.

A separate proof covers every `gamma >= 1` and every fixed globally Lipschitz activation, with a dimensional cost:

`R + ~O(A R^(1−1/r) n^(−2/[r(d+2)]) + A^r n^(−2/(d+2)))`.

The generic exponent is total affine depth, and tanh has a refinement stated in the paper. If both certificates apply, the learner selects the smaller one and still returns a single posterior. The parameter prior remains unchanged.

For a shallow ReLU teacher of path variation `P` on the unit ball, the original Gaussian prior gives the sharper sample count `~O((P^2+d+1)(R/epsilon^2+1/epsilon))` at every learner width above the teacher width and every `gamma >= 1`.

The comparison classes otherwise include coefficient bounds. The input law and bounded label noise are arbitrary. A separate appendix extends the raw-output Gaussian bounds to labels with a known sub-Gaussian tail scale, including Gaussian noise around a bounded conditional mean, with only logarithmic changes. It retains the original weight prior and observations and makes the likelihood normalization explicit. These are statistical guarantees for exact Bayesian integration; computational efficiency and polynomial dependence on unrestricted depth are not claimed.

Run `./build.sh` to rebuild the PDF. The source incorporates previously independently audited proof modules, with their provenance recorded in `verification/source-provenance.json`; the integrated presentation, common-activation extension, certificate selector, shallow ReLU path bound and sub-Gaussian-label transfer have passed an independent final mathematical audit. This work is not Lean verified.
