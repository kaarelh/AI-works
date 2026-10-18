# Frozen-source audit: sequential-program learning

Reviewed source:
`source/critical-sequential-program-learning.tex`

SHA256:
`e552d1a1d3c692238eeeab6b74a008bcca896bb0c1792793eedf7bba6bb902ac`

Reviewer: `depth_boolean_bridge`. This is an independent check of the final source. The all-prefix refinement was developed collaboratively, so this record does not claim an independent discovery of that construction.

## Verdict

The complete frozen source passes. No mathematical correction is requested. Its conclusions are restricted positive results for the original critical prior, under the sufficiently-large-width convention inherited from the cited learning theorem. It does not establish the general small-circuit theorem.

## Checks

1. **Decision trees and width-two programs.** Each consistent leaf indicator has Fourier variation one. For a width-two program, the scalar state recurrence has coefficient functions of Fourier variation at most one, even when the two states query different coordinates. Fourier variation is submultiplicative without any disjointness assumption. The bound `T+1` therefore remains valid with repeated queries and state-dependent queries. The terminal output map does not increase it.

2. **Abelian prefix computation.** The integer threshold expansion computes each residue exactly on the full attainable interval. All prefixes cost only a quadratic factor in program length. Combining cyclic coordinates uses one conjunction for each group element, hence at most `q` conjunctions per prefix, rather than enumerating an unnecessarily larger product of coordinate alphabets. Integer margins and coefficient norms have universal polynomial bounds after converting Boolean conventions.

3. **Nonsplit extensions.** With the stated section and correction table, the identity
   `g_1 ... g_i = (t_1 ... t_i) s(H_i)`
   follows by multiplying the prefix by the next letter. It does not require a split extension. The last nontrivial derived subgroup is abelian and normal, and its quotient has smaller derived length.

4. **Uniform resource bounds.** A single quotient-prefix circuit supplies every quotient prefix. Extension steps add gates to this circuit instead of making a separate recursive copy for each prefix. Consequently the additive recurrence in group order is correct, and the geometric decrease of quotient order gives a universal polynomial degree independent of derived length. Depth is linear in derived length. Layering and constant rails preserve the stated polynomial width and gate-norm bounds.

5. **Learning substitution.** The compiler has depth `O(ell)` and logarithmic resources `O(log R)`, so the controlled-circuit parameter is `O(ell log R)`. The displayed learner-depth assumption leaves the required steering depth. The excess rate is `O(ell^2 log^2 R / L)`, whose square-root exponential factor is `R^{O(ell)}`. The remaining action and dimension factors are polynomial in `R` and are absorbed. The conclusion uses the inherited posterior, confidence threshold, sample quantifiers, and width quantifiers without adding a finite-width claim.

6. **Permutation scope.** For width at most four, the transition group is a subgroup of `S_4`, of bounded order and derived length. The stated normal series has abelian quotients. Here a permutation program has the group-program convention specified immediately above: each layer chooses between two permutations using one queried bit. The source does not extend this statement to arbitrary state-dependent, noninvertible width-three or width-four programs. An additional defining sentence would be an optional editorial clarification, not a required mathematical repair.

7. **MOD3 contrast.** The displayed roots-of-unity Fourier formula has the correct normalization and phase. Restricting to even Fourier degrees, applying the binomial identity, and allowing the empty coefficient's `-1/3` correction yields the claimed lower bound `alpha^d/3 - 2/3`. The cyclic group of order three simultaneously gives the claimed polynomial critical-learning bound. The conclusion concerns the inadequacy of large Fourier variation as a learning lower bound, not a lower bound for nonsolvable programs.

No repository files were edited during this audit.
