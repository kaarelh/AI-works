This record reviews the research draft used to prepare the [published proof note](../README.md). The scratch filenames below identify that review snapshot. It is an AI-agent mathematical review, not a Lean proof or external peer review.

# Independent audit of positive.md

Reviewed by the independent obstruction agent, 19 October 2026. I checked the actual energy-cover and cloning statements in `side-results/continuous-domains/source/paper.tex`, in particular the teacher-energy equation and Proposition “A continuous-domain energy cover.”

## Verdict

The co-scaled Gaussian-likelihood theorem is correct, with the quantifier qualification that the sufficiently small prior/observation variance threshold may depend on the selected sample size n, learner width N, and teacher. The proof does not establish one threshold simultaneously for all n>=n0. This does not impair its polynomial sample-complexity upper bound: choose a polynomially bounded sufficient n, then take the strong-prior limit.

No mathematical correction is needed to the constants 96 and 48 in the finite-cover argument. I recommend stating the conclusion as a **proved short adaptation**, not merely a plausible route, provided its co-scaling and clean latent-regression conventions are explicit. It is not an unchanged fixed-noise SLT theorem.

## Checks

1. The clone energy bound is exactly the published continuous-domain bound:

   E_*=d(d+1)B^2+2(L-1)C^2B^2.

   The clone computes the teacher's real output exactly for all real inputs and exists at every N>=C.

2. For fixed n,N, a small parameter ball around the clone has objective J_S<=E_*+1/2, uniformly over samples from the compact input domain. Uniformity follows from continuity of the network jointly in weights and compact inputs, or directly a uniform local parameter-Lipschitz bound. The ball radius can depend on n,N. This handles uncountably many possible training samples.

3. A completely explicit coercive upper-tail Laplace estimate is available. In whitened coordinates u, kappa=||u||² and J>=kappa. Put K=E_*+1 and theta=1/(4K). The integral over J>K is at most

   exp[-(1-theta)K/(2sigma²)] (2pi sigma²/theta)^(P/2).

   The denominator is at least the ball volume times exp[-(E_*+1/2)/(2sigma²)]. Since (1-theta)K=E_*+3/4, the ratio tends to zero exponentially in sigma^-2. Gaussian normalization cancels. Thus the posterior concentration is uniform over samples of the selected size n.

4. With cover precision tau/8, A_h={|h-f|>tau/2}, every sampled A_h-point has residual magnitude >3tau/8. The empirical count is at most (64/9)K/tau²<8K/tau². If true mass exceeds epsilon/6 and n>=96K/(epsilon tau²), this count is at most half its expectation. Chernoff then bounds failure by exp[-n epsilon/48], so n>=48(log M+log(1/delta))/epsilon completes the simultaneous bound. The network's tau-error set is contained in A_h.

5. The cover has log M polynomial in d,K,1/tau at fixed L and is independent of N. Its centers may be Borel rather than networks, which is harmless. Arbitrary input distributions supported in the compact unit ball are included; the existing paper explicitly extends the result to compact subsets of [-1,1]^d with polynomially changed dimension factors.

6. For a training-good sample, posterior mass outside J<=K at most epsilon/6 and individual good-parameter tail risk at most epsilon/6 yield Gibbs tail risk <=epsilon/3. Markov gives test mass at most epsilon where posterior latent correctness P(|z-f|<=tau) is <=2/3. This is the same posterior-confidence convention, adapted to real outputs.

7. Observation variance c sigma² changes objective to kappa+c^-1 sum residual², hence residual budget cK. Fixed c>0 is harmless, with constants depending on c.

8. The fixed-positive-variance prior-mass bound in positive.md is also correct. It generally pays log(1/p), which grows with the shrinking-prior width scale. It therefore cannot be described as recovering the original width-uniform theorem.

## Boolean-label Gaussian extension

The proposed approximate-teacher extension can be made rigorous with straightforward architecture bookkeeping. If a depth-L, width-C tanh teacher z_T has signed margin >=1/2, append one tanh hidden layer whose first neuron's incoming row is A times the old readout, followed by scalar readout 1. Set other new neurons to zero, padding to width C. This gives output tanh(A z_T), preserves a width-C realization, and changes depth to L+1. Every parameter is bounded by max(B,AB,1). Uniform label error is at most 2 exp(-A), so A=log(4 sqrt(n)) gives sum of squared training errors <=1/4.

Balanced cloning yields an objective comparison bounded by a fixed-depth polynomial in d,C,B,1+log n. Repeat the same proof with K equal to that comparison bound plus 1. The sample requirement is n >= polynomial(d,C,B,1/epsilon,1/tau,log(1/delta),1+log n) at fixed depth. It has a polynomial sufficient solution because every fixed power of log n is eventually dominated by n^(1/2), with the corresponding fixed-depth constants. Choosing tau<1 turns the latent regression guarantee into a correct-sign guarantee. Thus a precise Boolean-label positive variant is also available, with one extra learner layer and co-scaled observation variance.

## Tempered logistic extension

The objective J=kappa+sum_i log(1+exp(-y_i z_w(x_i))) is handled similarly. Scale the target readout by A=2 log(2n); the teacher comparison has total logistic loss <=1/2 and energy <=A² E_*. With posterior density exp(-t J), t tends to infinity, so bounded-objective concentration applies at fixed n,N.

For sign generalization choose an output cover of radius 1/4 and A_h={x:y h(x)<=1/4}. This contains {y z_w<=0}. Every sampled A_h-point has y z_w<=1/2, hence logistic loss at least log(1+exp(-1/2))>0. The same Chernoff/count argument applies with a constant multiple of K in place of K/tau². The resulting sample bound is polynomial after absorbing log n.

This is an explicitly co-tempered/power logistic posterior. It is not ordinary logistic Bayes with the statistical link held fixed while only the prior variance tends to zero. For ordinary posterior-predictive Bernoulli probability, rather than latent signs, use a positive score threshold (e.g. log 5) in the same counting argument; a good score has link probability >=5/6, and controlling posterior mass below that threshold by 1/6 yields predictive confidence >=25/36>2/3. The teacher readout still needs only O(log n) scaling.
