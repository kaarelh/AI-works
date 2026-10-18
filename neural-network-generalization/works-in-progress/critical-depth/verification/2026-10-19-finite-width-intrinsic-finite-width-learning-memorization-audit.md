# Independent audit of the intrinsic finite-width learning theorem

Reviewed source: `source/critical-finite-width-learning.tex`.
SHA-256: `56de4ecdbd778f6da0ab449a3fd6a62d6b4c3befaa8db6ba952ca92c46fca6af`.
Reviewer: depth_memorization, independent reconstruction of the statistical deduction from the supplied exceptional-mass theorem. The reviewer developed that underlying exceptional-mass theorem, so this is not an independent audit of that dependency.

Verdict: the frozen learning source passes, with no correction requested.

Checks performed:

1. The target cost uses raw unconditioned prior mass. For every training sample, its target full-margin event is a subset of the posterior conditioning event, giving denominator at least exp(-Na).
2. Choosing A=a+1/L changes the complexity exponential by only a universal constant, since sqrt(L(A-V*)_+)<=sqrt(L(a-V*)_+)+1.
3. The exceptional-mass corollary gives posterior leakage at most exp(d R log 2-N/L), uniformly over training samples. The stated large-width condition makes this at most epsilon/6.
4. The finite cube and Sauer's lemma give log|G_A|<=C(d+1)R; if the VC upper bound exceeds the domain size, the trivial all-functions count gives the same inequality.
5. The consistency union bound gives risk<=epsilon/6 for every consistent member of the good class. Including leakage gives posterior Gibbs risk<=epsilon/3, which implies mass<=epsilon for points whose correct-label probability is at most 2/3.
6. When either large-width condition fails, N is bounded by a fixed power of R times 1+log(1/epsilon). The ordinary polynomial tanh VC bound then yields a polynomial-in-R bound on the logarithm of the entire support, so the stated sample expression covers all smaller widths too.
7. All classes are fixed before the training sample is drawn. Ties and mixtures of posterior functions cause no additional issue.
8. The theorem's width dependence through a_N(f), and its lack of a new arbitrary-teacher prior-mass estimate, are stated explicitly. The example in the scope paragraph follows by substitution.

This audit does not reprove the external polynomial tanh VC theorem or the underlying anchored-compression theorem.
