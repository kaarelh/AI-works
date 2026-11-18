# Independent actual-posterior range-obstruction review

18 November 2026 — agnostic_proof_audit.

RG4–RG5 pass. At lambda=delta², the explicit exact interpolant and PR2 give expected empirical loss O(delta) and expected actual path mass at most K/delta+O(log(e/delta)), uniformly in N>=4 and0<nu<=1. The uniformity in nu follows from nu log(1/nu)<=1/e.

The triangular-hat identity without exact interpolation has the displayed coefficients. Bounding its negative by the actual path mass, then replacing the four training values by their labels plus errors, gives a positive leading coefficient ell(2-K/a)/delta. Expected absolute training errors are bounded by twice the square root of posterior empirical risk. Their contribution is O(delta^(-1/2)), so the positive leading term dominates. At least one of the two fixed interior posterior-mean values is therefore at least c/delta.

Every normalized univariate ridge is1-Lipschitz, so the ordinary posterior mean has Lipschitz constant at most E P<=2K/delta. The positive excursion persists on an interval of fixed positive length. For uniform test inputs and any labels bounded by one, this gives risk at least c-prime/delta²; Jensen gives the same lower bound for posterior-average risk. Gaussian domination guarantees the finite expectations used in these steps.

This is an actual-posterior statement for a prescribed deterministic four-point training sample and its particular likelihood schedule. It is not an IID sample-probability lower bound under the uniform test law, nor an all-temperature obstruction. Those distinctions are explicitly retained.
