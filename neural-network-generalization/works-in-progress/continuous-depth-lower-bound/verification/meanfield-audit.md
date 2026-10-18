# Independent audit of the critical-exponent depth counterexample

I checked `critical.md` against the finite-domain LDP proof in `works-in-progress/critical-depth/source/critical-variational-background.tex`, and then independently checked the finite-probe upgrade below. I found no substantive gap. The argument first establishes a finite-support version and then proves the endpoint result for the same fixed nonatomic circle distribution used at the other exponents. Width tends to infinity at fixed depth and sample size.

1. **Finite-domain LDP.** The existing proof represents each layer by the pushforward of an independent empirical standard Gaussian measure, and the readout by a covariance square root times a Gaussian vector divided by \(\sqrt N\). Sanov's theorem, the finite-product LDP, and continuous contraction give the stated good rate. The recursion is continuous in weak topology because tanh is bounded and continuous and matrix square roots are continuous. No part of that proof uses Boolean inputs or \(|X|=2^d\); those were only the former domain specification. Replacing the domain by any fixed finite circle support is valid. Singular covariances are explicitly handled by entropy contraction and the range convention for the Gaussian energy.

2. **Finite-set Lipschitz bound from rate.** Lifting a controlled tanh law through coordinatewise inverse tanh preserves entropy, including on a singular Gaussian range. Gaussian quadratic transport provides a coupling with squared distance in the \(Q^+\) metric at most twice the entropy. Minkowski and Cauchy--Schwarz give the factor \(1+\sqrt{2D_s}\) for each pairwise second-moment distance. Since the augmented first covariance satisfies \((e_x-e_y)^TQ_0(e_x-e_y)=\|x-y\|^2/2\), the readout and hidden bounds give exactly
\[
|z(x)-z(y)|\le\sqrt A\,\|x-y\|\exp\sqrt{2hA}.
\]
Hence fitting both members of any exponentially close opposite-output pair requires rate at least \(h/100\) for all sufficiently large \(h\). Infima over nonattained rate paths do not change this conclusion.

3. **First-layer seed.** The Gaussian mean shifts are legitimate full weight-space laws, with covariance \(I_3/2\). Their induced means approximate the ideal constant-and-step basis on the selected training points. The ideal inverse has \(\ell_\infty\)-to-\(\ell_1\) norm at most \(n\); perturbation by \(1/(4n)\) per entry gives coefficients of total absolute value at most \(4n/3\). Mixing the corresponding signed Gaussian shifts with coefficients scaled by \(1/(2n)\), and putting remaining mass on the centered reference law, gives the exact small training mean. Its relative entropy is polynomially bounded. Dilution by the reciprocal of this entropy bound reduces cost to at most one while retaining a **global** rank-one covariance lower bound. This avoids the possible gap of constructing a covariance direction only on training coordinates.

4. **Free cooling.** Projecting the uncontrolled feature field onto a latent standard Gaussian coordinate gives the global covariance lower bound with updated direction \(b'_x=b_x\mathbb E\operatorname{sech}^2(\sqrt{q_x}Z)\). The scalar recursion obeys \(F(q)\le q-q^2/100\) for \(0\le q\le1\). An elementary certificate is \(u^2-\tanh^2u\ge u^4/6\) on \([-1,1]\), integrated over \(|Z|\le1\); using the Gaussian density lower bound \(1/5\) on that interval already gives a coefficient exceeding \(1/100\). Also \(h(1)>1/8\), so \(-\log h(q)\le8q\). The stated polynomial loss \(e^{-8}(1+H)^{-800}\) is safe. No constant-diagonal assumption is needed.

5. **Amplification.** The direction \(b\) belongs to the covariance range and satisfies \(b^TQ^+b\le1\). Shifting the Gaussian by \(Ab\) therefore costs at most \(A^2/2\). A uniform positive derivative lower bound for the expected tanh on means in \([0,1]\), variances in \([0,1]\), yields the stated \(c_1\min(Au,1)\). With \(A=2/c_1\), logarithmically many controlled layers restore a constant signal. A final shift obtains fixed training accuracy with bounded extra cost. Allocating all other layers to free cooling requires \(L\) to dominate a sufficiently large universal multiple of \(\log n+\log L\), exactly as stated. Constants may be very large; a sufficiently small positive exponential sample exponent still exists.

6. **Posterior conditioning.** The training constraints form an open output-vector set with rate below \(h/200\). The union of all events fitting both points in a paired prefix is a finite union of closed sets, of rate at least \(h/100\). The LDP lower and upper bounds therefore make its actual conditioned posterior mass tend to zero. At fixed depth and sample size the input support is finite, so samplewise eventual bounds can also be made uniform over all separated samples, if desired.

7. **Mixtures and the confidence criterion.** The final bound can be strengthened from \(1/4\) to \(1/2\). Let \(B\) be the event that at least one pair is fitted at both endpoints. For every particular pair,
\[
p(x_+)+p(x_-)\le1+\Pi(B).
\]
As soon as \(\Pi(B)<1/3\), both correctness probabilities cannot exceed \(2/3\). The balanced pairing therefore gives confidence-error mass at least \(1/2\). This is a statement about the full actual posterior, including arbitrary mixtures and tied minima.

The finite-support theorem above is sound. The following finite-probe argument also establishes the result on the **same fixed nonatomic distribution** as the other exponents.

## Fixed nonatomic distribution: finite-probe upgrade

Fix a separated training sample \(S\) from the stationary Cantor distribution and a particular paired test input \(p=(x_+,x_-)\). Apply the finite-domain LDP only on \(S\cup\{x_+,x_-\}\). The preceding Gaussian weight-space seed construction extends to this finite set with unchanged cost: its training means are selected from the sample, but it is a genuine full feature law on all probe coordinates. Cooling and amplification preserve the covariance inequalities on the whole probe set.

On the stationary support, the actual teacher labels lie in \([-0.65,-0.5]\cup[0.5,0.65]\). Use signed target amplitude \(a=0.6\), final feature-mean error \(\eta=0.01\), and training tolerance \(\rho=1/8\). Then the constructed witness has training error at most \(0.1+0.6\eta=0.106<\rho\). Thus its rate remains \(O(\log n+\log L)\). At test tolerance \(\tau=1/4\), fitting the two paired points requires predicted gap at least \(1-2\tau=1/2\), so the same transport bound gives pair-fit rate at least \(h/100\) for large \(h\).

Consequently, for every fixed probe pair, its actual conditioned posterior probability \(b_N(p)\) of fitting both endpoints tends to zero. These are measurable functions of the pair and lie in \([0,1]\). Dominated convergence gives \(\mathbb E_p b_N(p)\to0\), with no functional LDP and no uniformity in the pair required.

If \(q_N(x)\) denotes posterior correctness probability, then
\[
q_N(x_+)+q_N(x_-)\le1+b_N(p).
\]
Whenever both correctness probabilities exceed \(2/3\), one has \(b_N(p)>1/3\). The balanced pairing and Markov's inequality therefore imply
\[
D\{x:q_N(x)\le2/3\}
\ge\tfrac12\{1-3\mathbb E_p b_N(p)\}.
\]
Thus, for every separated sample, the liminf of the confidence-error mass is at least \(1/2\). Fatou's lemma then yields, for every fixed \(\varepsilon>0\), a limiting sample-probability bound of at least \(49/50\) for confidence-error mass at least \(1/2-\varepsilon\).

**Quantifier distinction:** the finite-probe argument proves eventual error at least any constant strictly below \(1/2\), such as \(0.49\). It does not by itself prove eventual error at least exactly \(1/2\), since the displayed lower bound may approach \(1/2\) from below. A statement using the samplewise liminf error at least \(1/2\) is also valid.

This upgrade is sound and removes the need for depth-dependent finite input distributions at the critical exponent. It retains the width-first order of limits and still does not resolve the original Boolean-cube classification problem.
