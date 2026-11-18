# A circuit-size oracle for a dense Bayesian neural network

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

One fixed dense architecture, independent continuous weight coordinates, and a fixed Gaussian likelihood give an expected test-risk bound with coefficient one on the comparison risk and a nearly `1/n` remainder. The final bounded output is part of both likelihood and prediction. All observations enter the ordinary posterior. The data are IID, the conditional mean lies in `[-1,1]`, and the centered conditional label noise is sub-Gaussian.

The prior can use finite-variation Lévy increments at inverse fan-in time, or the explicit signed beta-prime density in the paper. It has full support and no atom at zero. There is no prior over network sizes.

The results distinguish three implementation resources:

- A shared circuit with `V` hidden vertices and `E` internal/readout edges pays `(E−V) log N`, plus a term polynomial in its actual edge count and depth. Dense width-`C`, depth-`H` comparators give roughly `C²H² + C²H log N`, suppressing logarithms and input terms.
- Stable teacher rows improve this to roughly `C²H log(nNH)`. The stability condition restricts only the comparison implementation; learner weights are unrestricted.
- Bounded-fan-in Boolean circuits admit explicit error-restoring ReLU, tanh and sigmoid implementations with nearly linear gate-count and depth cost. These also bound total online mistakes for exact Bayesian sign conditioning, including adversarial input sequences. Posterior-sampled mistakes require the usual nonanticipating choice of the next input.

Formula implementations remove the learner-width term. The same posterior can use the smaller of the shared-circuit resource and the unrolled-formula resource. Unrolling can be exponential in depth, so these alternatives are kept separate.

A retained-variance corollary also controls expected posterior-sampled risk and sign-confidence failures when the conditional mean is separated from zero.

These are expected-risk and prior-mass theorems, not efficient sampling algorithms. The proofs have undergone independent AI-agent mathematical review and have not been formalized in Lean.

Run `./build.sh` to rebuild the PDF.
