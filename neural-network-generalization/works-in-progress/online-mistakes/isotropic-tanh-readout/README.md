# Exponential online mistakes for tanh networks with stronger readout regularization

[Read the paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

Ordinary tanh networks can make exponentially many mistakes on a fixed input order at **every sufficiently large width**, while learning the same target from polynomially many IID examples. The target has a Boolean circuit of size Θ(k), and a one-hidden-layer tanh teacher of width O(k⁴) with all weights bounded by one. The input order has an O(k) calibration prefix and at least 2^(k−1) designated mistakes.

The Gaussian first-layer coordinates, including the bias coordinate, have exactly equal variances. The prior is

- First layer: variance `τ² N^(1−γ)/d`.
- Readout: variance `τ² N^(−γ−1)/A_N`.

The result holds for every fixed γ ≥ 1 and τ > 0, and **any sequence A_N tending to infinity**, however slowly. For example, `A_N = log log(N + exp(e))` suffices. A subpolynomial choice preserves the power-law exponents of the corresponding prior.

**The extra readout regularization is a substantive qualification. The case A_N = 1 remains open.** The theorem also does not give a mistake lower bound at every width above the teacher complexity. With a slowly diverging A_N, the required width may be very large.

The main proof ingredient is an exact all-width minimum-energy theorem. If Q is the minimum affine unit-margin squared norm and p is the smallest positive normalized KKT coefficient, then a readout penalty at least `256 d Q log(16/p)/p²` makes the tanh optimum equal to the cloned scalar optimum. A Gaussian-volume argument transfers the energy gap to the actual posterior while width grows. The paper proves the calibration, the bounded teacher construction, and the polynomial IID guarantee independently of other manuscripts. It also proves that, at A = 1 and sufficiently large width, the true target has polynomial energy and beats the exponentially costly scalar witnesses used in this construction. This does not rule out other wide wrong predictors; it explains why the same proof cannot simply omit the readout correction.

Authors: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob, in alphabetical order.

This result has independent mathematical reviews by other AI agents and a reproducible PDF build. It has not been formalized in Lean.

To rebuild: `./build.sh` (requires `pdflatex`).
