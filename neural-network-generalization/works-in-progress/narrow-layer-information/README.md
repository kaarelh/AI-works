# The cost of narrow input layers in Boolean neural networks

[Paper PDF](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

**A narrow teacher can require exponential Frobenius product even when its Boolean function has an inexpensive wider implementation.** Inner-product parity gives an explicit example: every fixed-width first layer requires exponential product, while a width-`O(n)`, depth-three tanh network has polynomial product.

These are representation results, **not sample-complexity lower bounds** for an unrestricted Bayesian neural-network prior. The paper is a conventionally checked work in progress and has **not been formalized in Lean**.

## Results

- **Low first-layer rank gives a constant-depth circuit.** A globally unit-margin network with first-layer rank `r` and layer Frobenius product `P` has a threshold circuit of constant depth and size `(d + max(1,P) + r + 2)^{O(r+1)}`. Fixed rank and polynomial product therefore imply nonuniform TC⁰, independently of later widths and neural depth.
- **Inner-product parity forces an expensive narrow bottleneck.** For two `n`-bit input blocks, every globally unit-margin representation with first hidden width at most `r` has `P ≥ (2^{(n−1)/r}−1)/√2`. The activations may be any 1-Lipschitz functions, and subsequent depth and widths are unrestricted.
- **A polynomial common coefficient grid cannot replace fine input resolution.** If the first layer has width `r`, coefficients bounded by `B`, and all coefficients lie on the grid `1/Q`, exact inner-product parity requires `Q ≥ (2^{n/r}−1)/(2Bn)`. No continuity assumption on the remaining computation is needed.
- **Widening removes the exponential product cost.** An explicit tanh network with two hidden layers, width `O(n)`, and charged constant rails implements the same function with unit margin and `P = O(n^{5/2} log²(n+2))`.

The [companion constant-width compiler](../boolean-depth-barriers/paper.pdf) also gives width-24, bounded-coefficient, polynomial-depth teachers for this target. Together, the results show that preserving a teacher's narrow first layer can prevent an economical implementation. A learner with an unrestricted architecture can use the cheaper wider one.

## Why this does not give a learning lower bound

The minimum product within a narrow architecture is different from the minimum product over all architectures available to the learner. At large learner width, the inexpensive shallow representation is available. At fixed learner width, finite-architecture consistency bounds can give polynomial sample guarantees even when its minimum product is large. A posterior sample lower bound requires additional target-relative probability information.

The unrestricted Boolean depth question for the original canonical Gaussian priors remains open.

## Supporting results on precision and oscillation

The [supporting note](research-notes/precision-and-oscillation.md) gives two further conventionally checked results:

- The constant-width analog compiler can be rounded to a common grid using `O(d+S)` fractional bits for a Boolean circuit with `S` gates. This is polynomial description length, but still exponentially fine absolute resolution.
- A fixed-width, coefficient-bounded tanh construction has exponentially many sign changes on a shifted Boolean input grid at linear depth, with global output margin after amplification. Thus fixed width and analyticity alone do not force a subexponential number of sign regions.

Neither statement proves an intrinsic circuit lower bound or a Bayesian sample lower bound. The note explains precisely where those inferences would fail.

## Build

Run `./build.sh` with TeX Live and `latexmk`. It rebuilds `paper.pdf` and keeps temporary files in the ignored `.build/` directory. The source is self-contained; the constant-width representation consequence cites the companion paper, while the four main theorems are proved within this paper.

Authors: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
