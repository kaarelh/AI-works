# A polynomial-depth converse from online mistakes to neural circuit width

[Read the paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/mathematical-review.md)

This note proves that **few total online mistakes imply a small bounded-weight tanh network, with polynomial dependence on depth**, for a particular restricted Gaussian neural prior. It is a research result, not Lean verified.

The learner's prior retains the global lower output margin and adds two conditions:

- A fixed upper output cap, `|z(x)| < U` on the Boolean cube.
- A certificate bounding how internal disturbances can reach the output. It allows compensated layer expansion. Requiring every internal weight matrix to have operator norm less than one is a simpler sufficient alternative.

The certificate is stated directly in network weights. It is independent of the target, labels, training sample, and mistake count. Both conditions hold for at least some implementation of every Boolean function, although those implementations need not be cheap.

## The result

Let `m` be the actual or expected total mistakes during complete revelation of a Boolean target on `{-1,1}^d`, and let `L` be network depth. Take the Gaussian strong-prior limit at each fixed width first, then let width tend to infinity. The target has a depth-`L` tanh implementation with width and coordinate magnitudes bounded by

```text
ceil(65536 Λ² K [1 + (L−1)K] [d + log(400L)]),
K = 1 + P(d,L,U) (m+1)²,
P(d,L,U) = O(d³ log²(2+d) + L(U+1)²).
```

Here `Λ > 1` is the certificate's fixed amplification parameter; one can take `Λ = 2` for strictly nonexpansive internal layers. The polynomial degree and implicit constants are independent of depth. The leading dependence on the mistake count is fourth power.

The conclusion covers posterior sampling, majority prediction, deterministic selection of a minimum-energy function, and failures of any fixed posterior-confidence threshold. Tied minimizers cause no problem. Arbitrary input-reveal orders are allowed if every input is eventually revealed, including infinite iid streams with full support.

The proof has three parts. An increase in the minimum energy compatible with the revealed labels forces a prediction mistake. An exact singleton correction repairs a new label while increasing the square root of that energy by only a polynomial-depth additive cost. A deterministic compressor then converts the resulting quadratic energy bound into the displayed network-width bound.

## Scope

This is a converse, not a two-sided circuit-prior theorem. We do not prove that every small deep Boolean circuit has a cheap implementation satisfying this stronger support restriction. The reconstructed small tanh network need not satisfy the restriction.

The order of limits supplies spare neurons for a correction branch. The result does not yet apply at every fixed realizable learner width, or establish a converse for finite-exponent width-first posteriors. The upper output cap is substantive: removing it is another open step. Coverage is also essential; mistakes on a restricted input subset cannot determine the complexity of the target elsewhere.

## Build

Run `./build.sh` with `pdflatex` installed. The build needs the standard LaTeX packages listed at the top of the source.

The [publication record](verification/publication-build.json) records isolated rebuilding and exact source/PDF hashes.
