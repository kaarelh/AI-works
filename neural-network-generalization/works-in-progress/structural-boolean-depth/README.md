# Structural Boolean targets: subexponential posterior sample bounds

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification](verification/README.md)

This paper gives positive target classes for the original Gaussian tanh
posterior on the Boolean cube. It does not resolve the unrestricted
Boolean-depth question.

The learner has variances `t²/d`, `t²/N`, and `t²/N²`, for every canonical
scale `0<t≤1`. Its posterior conditions only on strict absolute output
margin greater than `1/2` throughout the cube and on exact noiseless
training labels. For any common training/test distribution, the bounds
control test mass where posterior correct-label probability is at most
`2/3`, at **every actual realizable width**.

For the following resource exponent `E`, sufficient samples are
`exp(O(E))`, apart from the stated error/confidence factors, provided
the learner depth satisfies **`L≥C E`**.

| Target representation | Resource exponent |
|---|---|
| A synchronous fan-in-two circuit with an early cut of width `w_j` | `K+min_j[j K/log(K+2)+w_j]`, where `K=log(d+s+L+3)` |
| A circuit with graph treewidth `k` and `v` vertices | `log(d+L+3)+(k+log(v+d+L+3))log(v+3)` |
| A planar or fixed-excluded-minor circuit graph with `v` vertices | `sqrt(v)+log(d+L+3)+log(v+3)log(v+d+L+3)` |
| A size-`s` Boolean formula of Horton–Strahler rank `r` | `log(d+L+3)+(r+1)log(d+s+L+3)` |

For polynomial resources in `L`, these are subexponential in `L` when
the displayed exponent is `o(L)`. In particular, the treewidth condition
`k=o(L/log L)` and the planar size condition `v=o(L²)` suffice. The
synchronous cut theorem also gives the size-only exponent
`K+sqrt(s K/log(K+2))`. If fresh inputs enter after a cut, their distinct
bits must be added to its width; that size-only consequence then does
not follow automatically.

The formula bound is polynomial for every fixed register rank,
independently of the formula's original depth. Its proof evaluates
single-bit formula paths through the last reset and suffix parities of
their unary Boolean maps. The short-padding refinement gives
`(d+s+L)^{O((r+1)²)}` samples whenever `L≥C(r+1)`; for rank at most
one, Fourier variation is at most `s+2`, giving polynomial samples
at **every `L≥2`**. Both refinements hold at every actual realizable
width and every canonical scale. Arbitrary balanced formulas can have
`r=Theta(log s)`, so the polynomial-sample question for all small
Boolean formulas remains open.

An independently audited
[supporting refinement](research-notes/strahler-exact-stage-posterior-refinement.md)
strengthens that learner-depth condition to **`L≥r+1`**, with `L≥2`
for rank zero, and retains the universal
`(d+s+L)^{O((r+1)²)}` sample bound. It compiles each formula rank into
one threshold-feature stage and extracts a quantitative bound from the
published cloning proof at the boundary depth. This refinement is in
the supporting note and its
[audit](verification/strahler-exact-stage-posterior-refinement-independent-audit.md);
the 10-page paper itself retains the weaker `L≥C(r+1)` condition.

A [supporting note](research-notes/rank-two-one-hidden-product-obstruction.md)
shows a sharp scope distinction: inner-product parity, a linear-size
rank-two XOR/AND formula, requires exponential Frobenius product in
every one-hidden-layer tanh representation with exact global unit
margin, but has polynomial product with two hidden layers. This is an
exact shallow representation result, **not a Bayesian sample lower
bound** and not a lower bound allowing arbitrary neural depth. Its
[independent audit](verification/rank-two-one-hidden-product-obstruction-finite-n-audit.md)
also records the gate-basis qualification for formula rank.

The graph conditions describe a Boolean representation of the target.
They do not restrict the prior or posterior architecture. A narrow
real-valued tanh teacher cannot be treated as a narrow Boolean-state
circuit merely by taking its hidden signs.

## Proof dependencies

The combinatorial constructions and the extension of the Gaussian
prefix construction to heterogeneous layer widths and row norms are
proved in the paper. The statistical transfer explicitly imports:

- [Uniform intrinsic learning, scalar continuation, and short-padding/Fourier target bounds](../boolean-depth-barriers/uniform-target-classes.pdf), Proposition2.1, Proposition3.3, and Theorems1.1–1.2; [source](../boolean-depth-barriers/source/uniform-target-classes.tex).
- [Baseline-subtracted intrinsic proof](../boolean-depth-barriers/proof-notes/uniform-sharp-intrinsic.md) and [scale-reuse proof](../boolean-depth-barriers/proof-notes/nearcritical-target-reuse.md).
- [Finite-width circuit prefix](../critical-depth/source/critical-finite-width-circuit-prefix.tex) and the scalar/finite-channel inputs in the [critical-depth paper](../critical-depth/paper.pdf).
- The cited balanced tree-decomposition and weighted planar/excluded-minor separator theorems.

The actual all-width conclusion includes a separate full-class VC bound
below the construction's width threshold. It never assumes that the
compiled target circuit fits inside every learner width.

## Reproduction and status

Run `./build.sh` with `latexmk` and a standard TeX installation to rebuild
the PDF. The manuscript and the new separator construction passed
independent mathematical review. This package is not Lean verified;
the imported analytic theorems retain the verification status recorded
in their own packages. No unconditional exponential sample lower bound
or generic subexponential compiler is claimed.
