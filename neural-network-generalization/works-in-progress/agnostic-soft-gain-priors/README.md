# A full-support path-variation prior for Bayesian ReLU networks

**[Paper (PDF)](paper.pdf) · [Source](source/paper.tex) · [Verification record](verification/README.md)**

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, Dmitry Vaintrob. Authors are listed in alphabetical order.

This paper constructs a Bayesian ReLU learner whose function probabilities and sample complexity are controlled by path variation. The prior starts from one dense Gaussian architecture and adds a soft penalty for internal amplification. Every finite parameter vector retains positive density. There is no prior over network sizes and no teacher-specific complexity cutoff.

For a comparison network with hidden depth `H`, width `C`, mixed path variation `P`, and population squared loss `R_*`, the ordinary raw posterior mean obeys

```text
R(posterior mean) ≤ R_* + O_tilde((1+P) sqrt(H R_*/n) + (1+P)^2 H/n).
```

The guarantee holds at every learner width `N≥C` and every internal Gaussian exponent `γ≥1`. Inputs lie in a Euclidean unit ball and labels may follow any bounded IID law. The likelihood variance is selected from the observed free energy, without knowing `C`, `P`, or the comparison risk. The principal bound has no input-dimension factor.

## What the prior prefers

Mixed path variation is the sum of absolute path weights, using a Euclidean row norm at the first layer. It is unchanged by positive rescaling of individual ReLU neurons. The paper proves two-sided bounds on the precision-normalized negative log probabilities of uniform function neighborhoods in terms of minimal approximate path variation. The normalization is by the Gaussian precision `ω`, which depends on learner width; the actual neighborhood probabilities need not stay bounded away from zero as width grows. It also proves that the minimum normalized prior energy tends exactly to twice minimal path variation as learner width grows.

These are function-prior statements, not merely names for a sample bound. They concern path variation rather than ordinary Boolean circuit description length or width alone. A small deep network can have large path variation.

## Two Gaussian base scalings

Both versions add an explicit soft gain penalty. For a teacher with bounded endpoint norms and bounded product of internal absolute spectral gains, `P=O(C)`. At fixed input dimension and those bounds:

| Gaussian base | Sufficient sample count, up to logarithms |
|---|---|
| Endpoint precision matched to parameter volume | `C² H (R_*/ε² + 1/ε)` |
| Usual first/internal/readout variances `N^(1−γ)/d`, `N^(−γ)`, `N^(−γ−1)` | `C² H³ (R_*/ε² + 1/ε)` |

The first version has the sharper dimension-free path guarantee. In the second, the precise resource is `1 + sqrt(d) P + HC + d`, and the sufficient sample count is its square times `H (R_*/ε² + 1/ε)`.

The usual Gaussian base is reweighted; the theorem does not assert these bounds for unchanged independent Gaussian coordinates. Total affine depth is `L=H+1`.

## Using ordinary spectral gains

A further variant replaces the absolute matrix norm by the ordinary spectral norm in the soft penalty. This retains cancellation between signed weights and measures familiar Lipschitz amplification through the hidden layers. Its teacher complexity is

```text
S = ||W_first||_F ||v||_2 product_internal ||W_layer||_op.
```

Let `s=max(d,2)`. At fixed input dimension, its sufficient sample count is

```text
O_tilde_d((1+S)^s [R_*^(s/2)/ε^s + 1/ε^(s/2)]).
```

Depth appears only in logarithms once `S` is held fixed. For bounded endpoint coefficients and internal spectral-product at most one, `S=O(C)`; in dimensions one and two the width dependence is quadratic. This more permissive prior has a cost: its exponents and constants deteriorate with input dimension. It is separate from the dimension-free path-variation result above.

## Why the construction works

Positive neuron rescaling puts any ReLU implementation into a form with nonexpansive internal absolute matrices. Forward and backward path flows make the endpoint quadratic energy exactly twice path variation, without changing the function, width, or depth.

The prior softly penalizes the product of internal absolute spectral gains, `G`. Its actual internal distribution has `E[G²]≤2`, by a change of variables in its normalizing integral. An affine transport toward a comparison implementation decreases both gain penalties, so their potentially large normalization costs cancel in the relative-entropy calculation. A selective block transport gives the version with the usual Gaussian base scales.

The remaining arguments combine a width-independent path-capacity bound, Gaussian endpoint tails, and an observable free-energy certificate. The learner averages raw network outputs; it does not clip predictions after fitting, condition on exact real output values, or choose among architectures.

## Scope and verification

The prior regularizer and likelihood calibration are substantive modeling choices. Small path variation is sufficient; small width by itself need not imply it at arbitrary depth. Biases can be represented through a constant input and propagated constant wires, whose width and path costs must be counted. The result does not provide an efficient posterior algorithm or a claim about gradient descent.

All main arguments, the usual-base variant, and the ordinary-spectral-gain variant received independent AI-agent mathematical review. The package is **not Lean formalized**. The verification record identifies the reviewed sources and build checks. Run `bash build.sh` to rebuild the PDF with pdfLaTeX.
