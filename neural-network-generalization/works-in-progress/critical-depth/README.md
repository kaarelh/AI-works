# Depth and learning bounds for critical Bayesian neural networks

**Status:** Non-main research draft / work in progress

[Paper (PDF)](paper.pdf) · [LaTeX source](source/critical-paper.tex) · [Technical FAQ, Question 17](../../TECHNICAL-FAQ.md#17-what-does-the-critical-depth-result-imply-about-learning) · [Collection index](../../README.md)

For the original critical Gaussian prior (gamma = 1), the paper proves an actual posterior learning bound from the target's rate above a universal scalar baseline. The sample bound is polynomial in dimension, learner depth, and total rate, times `exp(C sqrt(L eta))`, where `eta` is the excess rate. The usual accuracy and confidence factors are included.

The main consequences are:

- Every parity, including full parity, has polynomial sample complexity once learner depth is a sufficiently large multiple of `log(d+L+2)`, uniformly in parity degree.
- More generally, the sample bound is polynomial in Fourier variation, dimension, and learner depth, under the stated minimum-depth condition.
- A bounded-weight teacher of depth `D` gives a sample bound `R^{O(D+1)}`, where `R` includes dimension, teacher resources, and learner depth. This is polynomial in learner depth for fixed teacher depth; joint polynomial dependence on teacher width and depth remains open.

The learner retains the original all-input output-margin convention and exact training fit. No internal robustness restriction is added. The guarantee holds at every sufficiently large width, including arbitrary mixtures of tied rate minimizers. The width threshold is not quantified, and this paper does not replace the all-width statement of main result 3.

The proof's [finite representation theorem](source/critical-anchored-compression.tex) preserves a small input-anchor covariance block exactly, then uses importance sampling to approximate all other inputs. It produces an ordinary finite tanh network with arbitrary finite real weights. A classical sigmoid VC bound supplies the capacity estimate used in the [posterior theorem](source/critical-rate-sublevel-learning.tex). No small product-norm or finite parameter-precision bound is asserted.

The paper also contains universal rate flattening, sharp excess-rate estimates, controlled circuit and Fourier constructions, and a complementary parity sample lower bound at depths below a small multiple of `log(d)/log log(d)`. A bounded absolute parity rate requires depth of order `(log d)^2`; polynomial learning already holds under the weaker logarithmic minimum-depth condition above.

## Verification and scope

The complete statements and proofs are included in the PDF. Independent AI-agent mathematical reviews are retained under `verification/`; they are **not Lean verification**. The [critical-learning revision record](../../verification/critical-learning-2026-10-19.json) records source hashes, audit scope, and an isolated rebuild comparison. Earlier records preserve their historical claims and open statuses.

The five promoted main results are unchanged. This research draft remains outside that list.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. It performs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.
