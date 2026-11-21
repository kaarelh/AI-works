# Maximal confident mistakes for a Gaussian cosine-network limit

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. Selected deterministic components are Lean checked; the complete main theorems are not formalized.

## Result and scope

A width-one cosine target gives 2^d-1 confident observed-margin mistakes in lexicographic order in the width-first cold limit. A finite family already gives 2^(d-1) confident mistakes at prior variance of order 1/d and width exp(O(d log(d+1))), for fixed confidence; width one has O(d^2) lifetime mistakes at that scale. A separate explicit finite family makes all but the first prediction wrong. At every fixed positive prior scale, a finite exponential width also gives an exponential tail of confident majority errors, of order (1+exp(-2 sigma^2))^d/sqrt(d), while width one has O_sigma(d log(d+1)) lifetime mistakes.

Odd dimension, cosine activation, central-limit normalization, and limit order are material. Only one initial labeled input. Exponential width is necessary for the displayed exponential sampling failures; no polynomial-width or fixed-width strong-prior lower bound. The polynomial-scale order is mean selected; the all-but-first cold order is lexicographic. Conventional proof, exact finite matrix/KKT checks, no complete Lean formalization or independent review.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

The [21 November research payload](../../rounds/2026-11-21/README.md) contains supporting programs, exact finite checks, and numerical diagnostics. The [verification inventory](../../verification/README.md) distinguishes those checks from complete formalization and independent proof review.

## Related papers

- [A one-neuron target that defeats wide sign-only Bayes](../sign-only-fourier-counterexample/README.md)
- [Superpolynomial strong-prior ReLU mistakes with margins only on observed inputs](../observed-margin-control-lower-bound/README.md)
- [Exponential online mistakes from widening Gaussian softplus and tanh learners](../softplus-gaussian-width-separation/README.md)
