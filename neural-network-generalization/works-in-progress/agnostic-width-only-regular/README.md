# Learning narrow-network approximations with Gaussian Bayesian ReLU networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Build script](build.sh) · [Verification files](verification/)

This paper gives an approximation oracle measured by comparison width and depth, with no bound on the comparison network's coefficients. The learner has one fixed dense ReLU architecture, an unrestricted independent Gaussian prior, and a fixed final saturation used in both its Gaussian likelihood and posterior prediction. It selects one positive observation variance by comparing two observable risk certificates.

If the input law has density at most `kappa` relative to the uniform cube, bounded labels may be arbitrarily noisy. At fixed dimension `d` and learner hidden depth `H`, the learner competes with every width-`C`, hidden-depth-`h` teacher after

`~O_{d,H}(kappa^(d p) (C+1)^(h(d+1)p) epsilon^(−(d+1)p))`

samples for additive squared-risk error `epsilon`, where

`p = max(d+2, d(H+1)/2)`.

The guarantee holds at every `gamma >= 1` and every learner width `N >= C+1`; the extra neuron compiles arbitrary internal biases. It requires `H >= max(h, 2 ceil(log_2 d)+2)`. No prior over network sizes is used, and the calibration knows no comparison cap or risk.

The compiler uses randomly shifted multiscale Kuhn interpolation. A second compiler replaces the density condition by quantitative anti-concentration near affine hyperplanes, including sphere distributions. It needs only four hidden layers and gives a different tradeoff between comparison width and accuracy. A final-tanh version preserves the density theorem's polynomial exponents, up to logarithms, when the comparison networks also use a final tanh.

The bounded-output observation convention and regularity of the input law are substantive assumptions. The paper does not claim this coefficient-free theorem for raw unbounded outputs or arbitrary atomic input laws. Its dimensional dependence is substantial.

Run `./build.sh` to rebuild the PDF. The main theorem and complete Gaussian proof appendices have passed an independent mathematical audit; the two extensions have also been separately checked. Exact review scopes and source hashes are in `verification/`. This work is not Lean verified.
