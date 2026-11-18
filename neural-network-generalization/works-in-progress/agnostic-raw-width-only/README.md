# Raw Bayesian regression against narrow approximations

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

This paper gives a coefficient-one approximation guarantee for a Bayesian tanh network whose likelihood and posterior-mean prediction both use its **raw real output**. It compares with ReLU networks of arbitrary finite coefficients, including arbitrarily large raw outputs. The architecture is prescribed before seeing the data; there is no prior over network sizes.

The primary prior has continuous gamma multipliers on hidden outgoing weights, Student hidden factors, and a Gaussian readout with a Dirichlet allocation of its variance. It has full support on the prescribed dense architecture. These weights are dependent through their continuous multipliers and variance allocation; this is a different prior from independent Gaussian weights.

Under **only a finite second label moment**, the same prior has a raw approximation oracle with a variance calibrated from the observed labels. At fixed input dimension, teacher depth and input regularity, it competes with arbitrary-coefficient raw ReLU teachers of width `n^(1/(24bh))`, for every prescribed learner width `N ≥ n` and learner depth up to `n^(1/36)`. Its estimation remainder is of order `n^(-1/12)` up to logarithms, plus `E[Y² 1{|Y| > n^(1/24)}]`, which tends to zero for every fixed finite-variance label law. Continuous inputs still require learner depth of order `log n`. This uses one posterior on all data, with temperature `n^(5/6) (1 + empirical mean Y²)`; it is a data-calibrated likelihood, not a fixed-variance generative model.

Faster rates are available with a label-tail bound. With marginally sub-Gaussian labels and Gaussian observation variance proportional to the square root of sample size, the ordinary posterior mean after all observations satisfies

$$
\mathbb E R(\widehat f_n)
\le \inf_{g\in\mathcal G_{C,h}} R(g)
 +\widetilde O\left(\frac{C^{2bh}+H}{\sqrt n}\right).
$$

Here the input dimension and teacher depth are fixed, the comparison class contains raw ReLU networks of width at most `C` and depth `h`, `H` is learner hidden depth, and `b` is a numerical compiler constant. Learner width must exceed the explicit compiled width in the theorem; the bound does not grow with further increases in width. The expectation is over the training sample.

- **Boolean inputs:** any input distribution is allowed, with learner depth at least a constant times teacher depth.
- **Continuous inputs:** the result holds under bounded density on a cube or slab anticoncentration, including uniform spheres and bounded densities relative to sphere surface measure. A binary quantizer requires learner depth of order `log n`. It avoids a power-of-accuracy increase in compiled width.
- **Growing comparison classes:** for `C = n^(1/(8bh))`, every prescribed learner width `N ≥ n` and learner depth up to `n^(1/4)` have an estimation remainder of order `n^(-1/4)`, up to logarithms. The preceding lower depth requirements still apply.

For a bounded conditional mean represented by a comparison network, with conditionally sub-Gaussian observation noise, a separate theorem uses **one fixed likelihood variance**. It controls both posterior-averaged risk and posterior-mean risk, in expectation and with high probability. Its excess above the noise floor is of order `(C^(2bh) + H)^2 / n`, up to logarithms, at fixed noise and output bounds. This is a noisy realizable-target result; the main agnostic theorem uses the stated sample-size-dependent variance.

If the noise is exactly Gaussian with known variance, an additional theorem uses **that true variance**, without inflation or tempering. It again controls raw posterior-averaged and mean risk, in expectation and with high probability, with a larger complexity polynomial. For example, teacher width `n^(1/(24bh))`, learner depth up to `n^(1/12)`, and every `N ≥ n` give nearly `n^(-1/2)` excess risk in this noisy-realizable setting; the continuous logarithmic depth floor remains.

Two appendices give alternatives. Changing the fixed power `p` in a readout density proportional to `exp(-|u|^p)` improves the agnostic sample exponent at a different prior. A mixed Lévy/variance-gamma prior makes **all weight coordinates independent**, at the cost of an explicit `log N` factor and the agnostic sample exponent `1/3`; its simple growing-width corollary restricts learner width to a polynomial in sample size.

A further **full-support, very light-tailed readout** uses sinh-normal factors, `P_j asinh(G_j)`, in place of the normalized Gaussian readout. Its deterministic likelihood variance grows as `log² n`. For bounded conditional means with conditionally sub-Gaussian noise, the coefficient-one expected remainder is nearly `(C^(2bh) + H)/n`. Under only marginally sub-Gaussian labels, it adds an explicitly stated `n^(-1+o(1))` term. In either case, teacher width `n^(1/(4bh))`, learner depth up to `n^(1/2)`, and every `N ≥ n` give nearly `n^(-1/2)` remainder, with the same continuous logarithmic depth floor. The actual prior and raw outputs remain unbounded; the stronger rate comes from a different readout-tail assumption.

A confidence version controls posterior-averaged and posterior-mean risk with coefficient `1 + η` on approximation error. Taking `η = n^(-1/4)` gives a coefficient-one growing-class gap of nearly `n^(-1/4)` with high probability, at variance of order `n^(1/4) log² n`. Separately, the expected asymptotic result can use a temperature constant chosen from the prior alone; the sample size at which its bound begins may depend on the unknown label-tail scale.

An optional **readout with bounded absolute-weight sum** gives nearly `(C^(2bh) + H)/n` expected remainder at a fixed likelihood variance for bounded conditional means and conditionally sub-Gaussian noise. The raw affine predictor is bounded by its readout prior itself, with no final output activation. This explicitly changes parameter support and is separate from the unrestricted-support primary prior.

No output clipping, label truncation, holdout selection, or averaging across sample sizes is used by these learners. Bounded comparison networks and truncated priors occur only in the proofs. Efficient posterior computation is not established.

The [raw-prior companion](../agnostic-raw-priors/) proves the statistical and weight-neighborhood results used here. This paper supplies the coefficient-free input compilation, margin-restoring comparison refinement, and resulting width-only guarantees. These manuscripts have independent mathematical and presentation audits; they have not been formalized in Lean.

Build the PDF with `./build.sh` using a TeX installation containing `pdflatex`, Latin Modern, `microtype`, and the standard AMS packages.
