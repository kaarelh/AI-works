# Depth and learning bounds for critical Bayesian neural networks

**Status:** Non-main research draft / work in progress

[Paper (PDF)](paper.pdf) · [LaTeX source](source/critical-paper.tex) · [Technical FAQ, Question 21](../../TECHNICAL-FAQ.md#21-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have) · [Collection index](../../README.md)

For the original critical Gaussian prior (gamma = 1), this paper proves polynomial learner-depth bounds for several target classes **at every width capable of implementing the target at the specified depth**. The learner retains the all-input output-margin condition and exact noiseless training fit. No internal robustness restriction is imposed.

The main consequences are:

- Every parity, including full parity, has polynomial sample complexity at learner depth at least a sufficiently large multiple of `log(d+L+2)`, independently of parity degree. More generally the bound is polynomial in Fourier variation under the stated depth condition.
- A bounded-weight tanh teacher of depth `D` gives `R^{O(D+1)}` samples at `L >= C(D+1)log R`, where `R` includes dimension, teacher resources, and learner depth. This is polynomial in learner depth for each fixed teacher depth.
- A Boolean threshold teacher of depth `h` gives `R^{O(h)}` samples without a bound on its original real coefficients. In particular every Boolean halfspace has a polynomial bound at every width, under the logarithmic minimum-depth condition.
- Two-state branching programs and programs over fixed solvable groups admit polynomial bounds in program length. Fixed-rank input bottlenecks give polynomial dependence on teacher product norm even with arbitrarily deep suffixes. General formulas admit quasipolynomial bounds.

These conclusions concern the full posterior and the correct-label probability greater than 2/3. The statistical factors and precise depth conditions appear in [the every-width target theorem](source/critical-all-width-target-learning.tex). **A bound jointly polynomial in arbitrary teacher width and depth remains open.**

The general [intrinsic theorem](source/critical-finite-width-learning.tex) holds at every finite width in terms of the target's actual normalized negative log-prior mass `a_N`. Its sample bound is a universal polynomial in dimension, depth, and cost, times `exp(C sqrt(L (a_N-V_*)_+))`, with accuracy and confidence factors. Forward conditional entropy gives finite input-witness certificates; exact-anchor compression and sigmoid VC bounds control the competing class. A separate [scalar-channel construction](source/critical-finite-width-channel.tex) and [circuit target-mass theorem](source/critical-finite-width-circuit-mass.tex) bound the actual target probability at quantified widths. Ordinary VC bounds handle smaller widths, removing that threshold from the learning conclusions.

The paper also proves universal rate flattening, sharp excess-rate estimates, and a complementary parity lower bound at depths below a small multiple of `log(d)/log log(d)`. Its rate-based theorems remain useful even when a quantitative target-mass construction is unavailable. No small product-norm bound for the compressed network or efficient posterior-sampling algorithm is asserted.

## Verification and scope

Complete statements and proofs are included in the PDF. Independent AI-agent mathematical reviews are retained under `verification/`; they are **not Lean verification**. The [finite-width revision record](../../verification/critical-finite-width-2026-10-19.json) records source hashes, audit scope, and an isolated rebuild comparison. Earlier records preserve their historical claims and open statuses.

The five promoted main results and their Lean files are unchanged. This paper remains a research draft outside that list.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. It performs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
