# Noise-adaptive Bayesian learning with nonexpansive hidden layers

**[Paper (PDF)](paper.pdf) · [Source](source/paper.tex) · [Verification record](verification/README.md)**

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, Dmitry Vaintrob. Authors are listed in alphabetical order.

This paper proves an agnostic squared-loss bound for one finite dense Gaussian neural network, conditioned on an internal gain restriction. The learner competes with a smaller network that approximates the labels; neither realizability nor Gaussian label noise is assumed. Prediction is the ordinary mean of raw posterior outputs.

At fixed input dimension and teacher coefficient bound, a width-`C` comparison network with population squared loss `R_*` needs the following sample counts for excess loss at most `ε`:

| Activation and restriction | Sufficient samples, up to logarithms |
|---|---|
| Tanh, hardtanh, ordinary sigmoid, and the stated bounded activation class; internal absolute row sums at most one | `C² (R_*/ε² + 1/ε)` |
| Any globally Lipschitz activation vanishing at zero, including ReLU and GELU; prescribed first-layer gain and nonexpansive internal layers | `C² H (R_*/ε² + 1/ε)` |

Here `H` is hidden depth, and total affine depth is `L=H+1`. The bounded-activation rate contains only logarithmic depth dependence. Both teacher and learner obey the stated restrictions. The result holds at every learner width `N≥C` and every internal Gaussian exponent `γ≥1`.

## Prior and likelihood

The first and internal Gaussian variances retain the prescribed layerwise scaling. The readout variance is `1/(ωN)`, where `ω=H N^max(γ,2)` at multiple hidden layers, and `ω=N^γ` with one hidden layer. This accounts for the hidden parameter volume. The theorem is not a claim for every unchanged scaling tuple.

A positive Gaussian likelihood variance is selected using observed free energy. The selection requires no teacher width, coefficient bound, or noise level. The model has one fixed architecture and no prior over network sizes. Arbitrary bounded IID labels, including misspecification and label noise, are allowed.

The proof transports the actual conditioned Gaussian distribution toward a cloned teacher. Its conditional normalizer cancels exactly, leaving a controlled relative-entropy cost. Rademacher capacity depends on readout energy, and the free-energy calibration adapts to the comparison risk. In particular the sufficient rate improves from order `1/ε²` at fixed nonzero comparison risk to order `1/ε` when the comparison loss is zero.

## What the teacher restriction excludes

An arbitrary small network need not have an equivalent implementation satisfying these gain bounds. For tanh, hidden amplitudes at depth `H` are at most `sqrt(3/(H+2))`, so fixed-width teachers with bounded readout coefficients can become small-amplitude. For ordinary sigmoid, input variation contracts by `4^(-(H−1))`, so such deep teachers become nearly constant. Hardtanh and ReLU permit identity layers that preserve a nonzero signal.

The bounds are information-theoretic. They do not establish typicality of the restriction in trained networks, efficient posterior sampling, or equivalence to gradient descent.

## Verification

The statements, comparison law, activation extensions, adaptive likelihood, and raw-output bounds received independent AI-agent mathematical review. This package is **not Lean formalized**. See the verification record for reviewed source hashes. Run `bash build.sh` to rebuild the PDF with pdfLaTeX.
