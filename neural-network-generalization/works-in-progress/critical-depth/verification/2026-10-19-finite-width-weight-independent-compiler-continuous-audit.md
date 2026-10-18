# Independent audit: weight-independent Boolean threshold compiler

Auditor: `/root/continuous_audit`.

Source: `source/critical-weight-independent-threshold-compiler.tex`.
SHA256: `86a22f3164adabfc04a72abdb4f5fe79a1e9b2a5eeb284c5320cde40f8749632`.

The complete source passes independent mathematical audit, conditional on
the standard unweighted-majority arithmetic theorem already cited in the
paper. No correction is required.

- Bias perturbation handles either fixed threshold tie convention on a
  finite Boolean set, preserving every previously nonzero sign.
- Selecting independent columns of the signed input matrix preserves its
  full column space, so feasibility is retained even on a rank-deficient
  set of realized states.
- The explicit active-constraint argument terminates at full rank: all
  negative-direction constraints are initially slack, the first hitting
  time is positive and finite, and each new tight row is independent of
  the previous tight rows.
- Cramer's rule and multiplication by the absolute determinant preserve
  feasibility and yield integer coefficients. Hadamard gives the stated
  (k+1)^((k+1)/2) bound, including k=0.
- Integer coefficients use polynomially many bits. Converting ±1 variables
  to 0/1 selectors only changes the hardcoded constant and doubles integer
  coefficients, preserving this bit bound. Separate signed sums and a
  comparison can be evaluated by constant-depth polynomial-size circuits
  of unweighted majority/Boolean gates.
- Stacking these constant-depth blocks multiplies depth by a universal
  constant and introduces only a universal polynomial in d,C,h in gate
  count, layering overhead, and normalized gate coefficient norms.
- This compiler applies to Boolean threshold states and makes no claim
  that arbitrary real-valued tanh activations can be replaced independently
  of their parameter magnitude.
