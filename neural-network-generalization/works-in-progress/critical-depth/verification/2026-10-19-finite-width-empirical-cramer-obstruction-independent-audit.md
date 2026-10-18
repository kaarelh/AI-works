# Independent audit: failure of distribution-free empirical Cramér tails

Reviewed `empirical-cramer-obstruction.md` on 19 October 2026.
Reviewed SHA-256: `61eb8daed0866eb3db7b6400c813c759a2c76c92a27ea03098232bbba727ccc2`.

**Verdict: the elementary counterexample and its stated scope pass.**

I independently reconstructed the argument. For t=log M>=log 3 and r=(4t)^(-1), the exposing quadratic score at atom i is t(2u-u^2), u=a_i/a_j. At i=j it is t; at earlier atoms u>=4t>2 gives a nonpositive score; at later atoms u<=1/(4t) gives a score at most 1/2. The moment generating function is therefore at most 1+sqrt(e)/2<e. On the event of exactly one nonzero observation, the empirical mean has Cramér transform at least log(M)/N-1. That event has probability N 2^(-N), independent of M. This proves the failure of every reference-uniform tail bound tending to zero with the action, at every fixed N, even with N much larger than two.

The rate is finite at the exhibited empirical mean because its empirical type has finite relative entropy against the finite-support reference. The moment consequence follows by multiplying the fixed event probability by exp(alpha[log(M)/N-1]). The support remains in a common compact box.

The obstruction also survives replacing the atoms by sufficiently narrow smooth bumps in the underlying scalar variable x, with sufficient statistic (x,x^2). For any fixed M, all finitely many exposing linear statistics and moment generating functions are continuous under sufficiently concentrated smoothing; the bumps can be chosen to preserve the inequalities with a fixed additive loss. Thus atoms and infinite-rate boundary behavior are not essential. This extension is an observation, not needed by the reviewed statement.

The result does not furnish a Gaussian/tanh reference law or a Bayesian neural-network counterexample. It diagnoses the failure of a distribution-free moment-certificate shortcut. The literature discussion was not needed for the elementary proof and is consistent with the retained family-dependent terms in the cited generic bounds.
