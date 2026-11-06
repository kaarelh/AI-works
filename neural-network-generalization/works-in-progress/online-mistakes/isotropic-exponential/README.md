# Exponential online mistakes under the isotropic strong prior

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification](verification/README.md)

The unchanged Gaussian tanh prior can make exponentially many mistakes on a fixed input order. This result retains equal first-layer coordinate variances, the all-input absolute output margin, exact label conditioning, and actual posterior prediction.

On `d=2k+1` bits, the target is positive exactly when a selector bit is negative and one `k`-bit integer is at least another. Its ordinary bounded-fan-in Boolean circuit size is `Θ(k)`. After at most `4k+3` calibration examples, a fixed sequence forces at least

$$
2^k-k-1\ge 2^{k-1}
$$

mistakes. At every sufficiently small positive prior scale, all the specified sampled mistakes occur with arbitrarily high probability. The same rounds are posterior-majority mistakes and strict `>2/3` confidence failures. No choice of MAP tie-breaking is involved: each round has a unique minimum-energy function.

The learner has **one neuron per hidden layer**. At depth `2k+2`, the target has a same-width implementation with every weight at most two and Gaussian energy less than `(40k+11)/3`. Its entire hypothesis class consists of affine thresholds, so its IID sample complexity remains polynomial in `d` at every prior scale and depth.

**Width qualification:** under the collection's convention that `C_L` bounds both width and individual weight magnitude, this target has `C_L=2`, whereas the learner has `N=1`. The theorem therefore does **not** establish the tanh counterexample with `N≥C_L`, nor a fixed-depth counterexample with polynomial bounded-weight teacher complexity. At depth two, the construction instead uses exponentially large teacher weights. Adding a second neuron can change the minimum-energy functions and needs a new argument.

**A separate appendix changes the activation to the identity.** It proves the same exponential lower bound at every fixed learner width, including every `N≥C_L=2`, using the same layer-scaled Gaussian prior. This establishes the sufficient-width statement for deep linear networks, while the tanh extension remains open.

The proof identifies the unique minimum affine norm after each observation. Its decision threshold advances by one integer at a time; the next input is always just beyond it and receives the opposite true label. Scalar tanh depth preserves this function ordering while allowing a bounded-weight implementation through repeated amplification.

The [companion upper-bound paper](../isotropic-subexponential/) proves that the big AND itself cannot cause `exp(Ω(d))` mistakes for the scalar isotropic learner, and gives subexponential bounds for specified narrow, shallow learners. These are conventional proofs with independent AI-agent reviews, **not Lean formalizations**.

Run `bash build.sh` to rebuild the PDF. The verification folder includes exact rational optimality certificates for finite instances of the central affine calculation.
