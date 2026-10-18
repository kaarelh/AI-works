# Independent audit: weight-independent threshold compiler

Reviewer: depth_counter_audit. Verdict: **pass**.

Reviewed source: `source/critical-weight-independent-threshold-compiler.tex`.
SHA-256: `86a22f3164adabfc04a72abdb4f5fe79a1e9b2a5eeb284c5320cde40f8749632`.

The finite-input tie-breaking perturbation is valid for either fixed Boolean tie convention. Restricting the feasible signed constraint matrix to independent columns preserves its column space and feasibility. The constructive movement argument does reach a vertex: every old tight row is orthogonal to the chosen direction, some row has a nonzero derivative, and after orienting that derivative negatively the first new tight row increases the active rank. Feasibility is maintained throughout. Cramer's rule followed by multiplication by the absolute determinant produces integer coefficients without reversing inequalities. Hadamard bounds all retained coefficients by r^(r/2), hence by (k+1)^((k+1)/2), including k=0.

The compiler correctly uses the bounded bit length as hardcoded input to constant-depth majority addition/comparison. It does not silently assign exponentially large coefficients to the replacement threshold gates. Signed affine sums reduce to comparison of nonnegative integer sums; all bit lengths, gate counts, wire counts, and layering overhead are polynomial in d+C+h. Replacing all gates at a level in parallel therefore gives depth O(h), polynomial width, polynomial gate coefficient norms, and unit margins. The standard majority-arithmetic theorem is an external dependency, explicitly identified in the source.

The final limitation is correct: this applies to Boolean threshold circuits and does not compile arbitrary real-valued intermediate tanh states.
