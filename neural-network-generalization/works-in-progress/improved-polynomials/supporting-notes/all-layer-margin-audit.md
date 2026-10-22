# All-layer-margin route: normalization, obstruction, and useful existing bound

Research audit, 22 October 2026. This note does not prove a quadratic bound under the original robustness condition.

## Exact normalization

Put `u_s=h_s/sqrt(N)` and normalize the input as `u_0=(x,1)/sqrt(d)`. Define the coordinate activation

\[
\Phi_N(a)=N^{-1/2}\tanh(\sqrt N\,a).
\]

It is 1-Lipschitz. The original network becomes

\[
u_1=\Phi_N(A_1u_0),\quad u_s=\Phi_N(A_su_{s-1}),\quad z=A_Lu_H,
\]

where

\[
A_1=\sqrt{d/N}\,W_1,\quad A_s=W_s\ (2\le s\le H),\quad A_L=\sqrt N\,v^\top.
\]

Consequently

\[
\sum_{s=1}^L\|A_s\|_F^2=\kappa_N(w).
\]

The perturbation norm in the robust paper is exactly the ordinary sum-of-squared Euclidean postactivation perturbation norm for this normalized network. Its hidden states have norm at most one. This makes the connection to all-layer-margin bounds precise, apart from their potentially different relative hidden-state normalization.

## Why a layerwise covering argument is not yet a quadratic proof

A dimension-free assertion such as

\[
\log \mathcal N(\{A:\|A\|_F\le\sqrt K\},\|\cdot\|_{\rm op},\eta)
\le O(K/\eta^2)
\]

is false for matrices with unbounded width. For example, the rank-one matrices
`A_u=sqrt(K) u e_1^T`, for unit vectors `u` in `R^N`, have Frobenius norm `sqrt(K)` and

\[
\|A_u-A_v\|_{\rm op}=\sqrt K\,\|u-v\|_2.
\]

The sphere has an exponentially large constant-separated packing. Thus, for fixed `eta/sqrt(K)`, the logarithm of this operator-norm covering number is at least a constant times `N`. This is already an obstruction for rank one.

This does **not** disprove a scalar network-function bound of order `K/r^2`: scalar outputs and the preceding nonlinear computation may render most matrix directions irrelevant. It shows why inserting a Frobenius energy bound into a standard operator-cover/all-layer-margin argument cannot silently remove width. The whole-network functional argument is the unresolved step.

The earlier depth report explicitly makes the related caution about known Lipschitz-augmentation theorems: their remaining matrix norms need not be width independent under this paper's Gaussian energy normalization.

## Existing deterministic compression gives a sharper quartic result

The earlier `works-in-progress/depth-supporting-notes/round1-depth-report/source/report.tex`, sections 3 and 4, already proves a useful deterministic all-input compressor. For energy at most `K` and a prescribed common robustness radius `r`, it uses

\[
m=\left\lceil256Kr^{-2}[d+\log(400L)]\right\rceil.
\]

The proof first prunes large entries relative to their row norms and then samples neurons. Dimension-free Hilbert-space Bernstein concentration, followed by a union bound over the `2^d` inputs, provides a noisy simulation at **every input simultaneously** with total perturbation norm at most `r/4`. A second event bounds compressed energy by `4K`; these two events intersect.

For the current clipped-score stability condition, no readout rescaling is needed: the compressed network differs in clipped score by at most `1/16` at every input. Parameter rounding adds at most `1/64`. Every interpolating original network can therefore be associated with a function in a finite class whose empirical ramp loss is zero and whose population loss dominates the original network's test-margin error. This gives a `1/epsilon` statistical factor, unlike a pointwise Markov compression with its additional inverse-accuracy factors.

The code length has the rough form

\[
O\!\left(L^2K^2r^{-4}(d+\log L)^2
\log\frac{K(d+\log L)}r\right).
\]

For the calibrated radius `r=c/sqrt(1+H E_v)` and energy cap `E_v<=K`, this is quartic in `K`, hence quartic (up to logarithms) in the Boolean teacher width when `K` is linear in teacher width. The [original-support paper](../original-support/paper.pdf) gives the exact adaptation and its statistical theorem.

## Finite-variance energy-tail range

With `P=N(d+2)+(L-2)N^2` total parameters,

\[
\kappa_N=(t^2/N)\chi_P^2.
\]

If `Nt^2<=1`, equivalently `gamma>=2` under `t^2=N^(1-gamma)`, then

\[
Pt^2/N\le d+L.
\]

If the posterior conditioning event has raw mass at least `exp(-ND_*/t^2)`, exponential Markov gives

\[
Q\{\kappa_N>K\}
\le\exp\left[-\frac N{t^2}
 \left(\frac K4-D_*-\frac{(d+L)\log2}{2}\right)\right].
\]

Thus an energy budget linear in `D_*+d+L+log(1/beta)` suffices uniformly in width. This extends the deterministic quartic bound to actual finite priors in that range. It does not cover mean field, where the raw full Frobenius energy grows with width.

## What the parameter-count heuristic does and does not establish

A dense width-`C`, depth-`L` network has on the order of `LC^2+dC` weights, but this is not by itself a lower bound on the sample complexity of every target or on a specific prior's behavior. Conversely, constant-fan-in layered Boolean circuits have a description of order `LC log(C+d)` bits. A generic description-length prior could learn these from roughly that description length divided by error tolerance. Obtaining comparable behavior from the particular conditioned Gaussian NN prior is the substantive problem.
