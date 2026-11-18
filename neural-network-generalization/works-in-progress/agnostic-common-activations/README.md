# Agnostic oracle bounds for Gaussian neural networks with Lipschitz activations

A single dense Gaussian Bayesian network can compete in squared loss with a smaller network, for **every fixed globally Lipschitz activation** and **every finite Gaussian scale at or stronger than mean field**. This includes tanh, ReLU, GELU, sigmoid and softplus, and does not require the activation to vanish at zero.

- [Paper PDF](paper.pdf)
- [LaTeX source](source/paper.tex)
- [Verification record](verification/README.md)

The learner has a fixed width, independent Gaussian weights, a Gaussian observation likelihood, and the ordinary raw posterior mean. There is no prior over network sizes. Inputs have any distribution on the input cube; labels may have arbitrary noise or misspecification, subject to being bounded.

For H ≥ 2 hidden layers and L = H + 1, let R* be the smallest risk among width-m teachers with coefficients bounded by B. At every learner width N ≥ m, the bound has the form

$$
R(\bar f_S)\le R_*+
C\left[
 \overline A\,R_*^{\,1-1/L}\theta_n^{1/[2H(H+1)]}
 +\overline A^{\,L}\theta_n^{1/(2H)}
\right]+n^{-3}.
$$

Here θₙ is a polynomial in input dimension times logarithms divided by n, and A is polynomial in teacher width, coefficient bound and input dimension at fixed depth, with only logarithmic dependence on n. The likelihood calibration uses a scalar equation involving the observed free energy; it does not need the teacher's complexity or approximation error. The one-hidden-layer proof gives exponents 1/5 and 2/5. A likelihood schedule fixed before seeing the observations also gives a polynomial oracle with the same general-risk exponent; the appendix proves this without data-dependent calibration.

The guarantee applies to actual finite priors with 0 < σ² ≤ 1/N, including all γ ≥ 1. It also bounds posterior-averaged raw risk. The constants and polynomial degrees remain conservative, and their depth dependence is not claimed polynomial.

The proof constructs finite dictionaries that approximate typical Gaussian networks independently of learner width. These dictionaries are only a proof device. Shared sampling preserves a residual standard deviation, so the same compression works for smooth bounded activations and for ReLU without repeatedly losing a square root of accuracy.

This manuscript has undergone independent AI-agent mathematical review. It has not been formalized in Lean. Rebuild the PDF with bash build.sh.
