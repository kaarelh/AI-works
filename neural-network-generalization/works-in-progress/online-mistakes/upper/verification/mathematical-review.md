# Independent audit: cumulative NNBayes mistake upper bounds

Reviewer: independent agent `/root/quadratic_shallow`. Date: 22 October 2026.

**Status: the statistical theorem and the three original NNBayes applications pass independent mathematical review.** Two minor presentation corrections were requested and accepted: a non-strict ramp endpoint, and the distinct Boolean-circuit complexity assumption in the polynomial-depth extension. The subsequently added ReLU extension also passes source correspondence and cumulative-reduction checks. This is an AI-agent audit, not Lean verification or human peer review.

## Scope

I read `paper.tex` in full and independently derived the finite-class random-permutation theorem, its high-probability version, the direct Bayesian telescoping bound, and the nonuniform-iid extension. I compared the explicit imported scalar budgets and aggregate-mass hypotheses with the current source manuscripts in the public repository: strong-prior generalization, gamma-above-one, meanfield-all-width, and the deterministic neuron-merging bounds. This checks the new reduction and its correspondence with those source statements; it is not a new formal verification of all previously published Gaussian-compression arguments.

## Finite relevant class: expectation and high probability

Let the finite domain have size m and the relevant class have size at most exp(h). For each function with error fraction u, the probability of surviving a size-n uniform random prefix is at most exp(-nu). Consequently the maximum true error R_n of any surviving relevant function has expectation at most (h+1)/n. Since all surviving errors lie among the m-n unseen inputs, the next-input posterior risk is conditionally at most m R_n/(m-n) plus the posterior tail beta. The harmonic identity

    sum_{n=1}^{m-1} m/[n(m-n)] = 2 H_{m-1}

therefore gives the stated expectation bound. The first round costs at most one; the use of m beta instead of (m-1) beta is harmless slack.

The prior-ratio assumption supplies the crucial tail bound **after every correctly labeled history**, including rare histories: the posterior denominator is at least the target's prior mass. No average-over-samples tail estimate is substituted here.

For high probability, the union bound on the good-prefix events has probability at least 1-delta/2 with a=h+log(2m/delta). The stopped variables are adapted and their stopping indicators are known before the next input is selected. Their conditional expectation sum is bounded by the displayed deterministic budget. The exponential-supermartingale argument applies both to the fractional posterior risk variable and to a fresh posterior-sampling error indicator. Combining its delta/2 tail with the prefix event proves the two stated bounds separately. The manuscript correctly explains how to obtain a joint event by halving delta.

The confidence conversion F_theta <= S/(1-theta) is pointwise and respects the strict-success criterion: failure is posterior correct probability <=theta. In particular the requested >2/3 criterion has factor three, and arbitrary-tie majority errors have factor two. Posterior mixtures are fully allowed.

## Input order and quantifiers

Under infinite uniform iid sampling, repeats have zero risk and do not alter an exact consistency posterior. The order of first appearances is a uniform permutation, so the reduction to m rounds is valid, including fresh posterior sampling. The no-repeat training protocol and the infinite repeated-query protocol therefore have identical cumulative-error laws in this exact-conditioning setting.

The bounds hold for each fixed learner with constants independent of its width. They do not by themselves supply one event simultaneously controlling all widths or all posterior samplers. The manuscript's width paragraph states the fixed-learner interpretation. Strong-prior sigma is fixed before the stream; its threshold may depend on width and need not be width-uniform. Choosing beta=2^-d requires only a variance threshold once, not repeated variance annealing.

## Direct prior mass and the three neural-network regimes

The pathwise product of successive correct-label posterior probabilities is the prior mass of the functions fitting the revealed labels. It is at least pi(f), even for adaptively chosen input sequences. Thus sum q_j <= -log pi(f). The posterior-sampling high-probability extension follows by conditioning on the next query before sampling and applying the same exponential supermartingale. Infinite horizons follow from monotone limits.

For the strong-prior limit, the relevant class includes every function tied with the target's minimum energy. Finiteness of the Boolean function set makes the total higher-energy prior mass vanish relative to the target at each fixed width. The copied cloning bound B_L=d(d+1)C^2+LC^4 is valid: cloning does not double the first-layer term, preserves the internal term, and increases only the readout term by a factor less than two. The finite-code budget includes the necessary +1 slack for unattained energy infima. Limits of the finite-domain posterior laws preserve consistency and the finite-class tail conclusions; no unique minimizer is needed.

For fixed gamma>1, the spectral width threshold is copied correctly. With K=4A+8 log(Lm), the raw exceptional-mass / raw target-mass ratio is at most L(Lm)^(-N^gamma) <=1/m. The target lies in the relevant class because otherwise this ratio would be at least one. Global-margin conditioning cancels in this ratio. Below the threshold, the direct target cost is at most A T^gamma/2. At fixed depth and fixed gamma>1, both branches have polynomial majorants independent of learner width.

For mean field, the backward tilt recursion, sparse-dual threshold T_L, finite-realization width and parameter-grid count agree with the source manuscript. The aggregate raw exceptional-mass bound is L exp(-NK/8), not a per-function bound. The same K choice therefore gives a relative tail <=1/m, while smaller widths cost at most AT_L/2. Tanh is correctly retained as an assumption at this endpoint.

Taking beta=2^-d only increases log(1/beta) by O(d). No compressor is required to achieve accuracy exponentially small in dimension. The small-width direct-cost branch is essential: a relevant-class theorem alone need not apply to every width.

The function-MAP remark is also valid. When beta<1, each outside-class function has prior mass below that of the always-consistent target, so no such function can be MAP. A function-level tie must be chosen independently of the next input, as explicitly stated. Parameter MAP is not identified with function MAP.

## Deterministic loss classes and polynomial depth

A fixed finite loss class taking values in [0,1] has the required survival estimate: a loss of full-domain mean u is positive on at least mu points, so an exactly zero empirical loss survives a size-n random prefix with probability at most exp(-nu). Its remaining mean is m/(m-n) times its full-domain mean. This establishes the same cumulative theorem for a deterministic representative loss dominating each retained network's test-margin error. The representative may depend on the network and history, but the finite class must be fixed before the random order.

For the merging compressor, training margin >1/2 makes the original signed clipped score exactly 1/2; an error at most 3/32 gives a representative score **at least** 13/32. A tested margin failure <=1/4 gives representative score at most 11/32. The stated ramp is zero at and above 13/32 and one at and below 11/32, so its endpoints work. The original draft's strict >13/32 was unnecessary and was corrected to >=13/32.

The polynomial-depth conclusion requires the **layered Boolean-circuit teacher** of the merging papers, counting constant wires and compilation overhead. This differs from the bounded-weight neural-network complexity C_L(f) used in the original fixed-depth applications. The author accepted an explicit statement of that scope switch. Without it the paragraph could be read too broadly.

The manuscript correctly declines to infer the same polynomial-depth cumulative result from the weaker entropy compressor whose approximation cost is polynomial in inverse approximation accuracy. An exponentially small per-round coupling error would not preserve the desired dimension dependence.

## Nonuniform sampling and limitations

The point-exception prior gives the claimed prescribed-order lower example: at the i-th query, its selected exception has posterior weight strictly greater than 1-1/R. The finite class can thus require m confidence and majority mistakes in a prescribed order despite log cardinality log(m+1). This concerns a deliberately chosen function prior, not a proved counterexample for the specified Gaussian neural-network priors.

For geometric input probabilities, the adjacent first-arrival reversal probability is rho/(1+rho), independently of the other categories. A union bound yields the adverse full order with probability at least 1-(m-1)rho. The example is correctly used to rule out a distribution-free cumulative consequence of class cardinality alone.

For the positive nonuniform extension, relevant-class expected risk is bounded both by (h+1)/n and by the expected unseen mass <=exp(-n p_min). Splitting at T=ceil(p_min^-1 log(2/p_min)) leaves an exponentially decaying tail bounded by an absolute constant. Outside-class risk is at most beta times the unseen mass at every history; the sum of expected unseen masses is exactly the support size m. The stated additive constant three is conservative. Thus polynomial dependence on log(1/p_min) follows as claimed. This paragraph states an expectation result, not the uniform-order logarithmic-confidence theorem for arbitrary distributions.

## ReLU extension

I compared the appended ReLU subsection against `/workspace/relu-learning-2026-10-22/paper.tex`, including its product-norm count and finite-variance energy-tail proof. The strong-prior relevant-class budget uses product norm at most sqrt(e) times the teacher's product norm, yielding the copied ceiling `4e(d+1) P_*^2 a_H^2` and log cardinality `v_* log(m+1)`. The expected cumulative order `O(v_* d^2)` follows directly.

For the finite-variance extension, doubling the output gives balanced energy `K_R=L(4dP_*^2)^(1/L)`. The copied target-ball radius and cost agree with the source. The parameter dimension satisfies `p sigma^2 <= d+L` for gamma>=2 at arbitrary depth, and for every gamma>=1 when L=2. Substituting `log m` into the energy-tail budget gives relative raw tail at most `exp(-log(m)/sigma^2) <= 1/m`, since sigma^2<=1. A function outside the counted low-product-norm class has every full-margin parameter representative in that high-energy event, so this bounds total function mass rather than only selected parameter draws. Initial global-margin conditioning cancels against the target event. The target is in the relevant class.

The cumulative corollary correctly keeps the deep finite-variance range 1<=gamma<2 open. It does not obtain that range by invoking the bounded-activation theorem for ReLU. At d=1, directly using the tail calculation avoids substituting a forbidden epsilon=1 endpoint into the source's PAC statement. No issue remains at that endpoint.

## Final status

Both requested presentation corrections are present in the final reviewed source. The statistical theorem, three original NNBayes applications, ReLU import, deterministic-loss merging extension, and nonuniform expectation extension pass this independent audit. No unresolved mathematical gap was found in the new cumulative argument.


Reviewed manuscript SHA-256: `898dbedea39a5445870353b94b77f8d5fe956c043c5ad89411d58d6b948f65af`.

Reviewed ReLU source SHA-256: `f360785cfcb15cf2dc74b1b6d4997cede19612394b896f0e89ba2958d0c39ac4`.
