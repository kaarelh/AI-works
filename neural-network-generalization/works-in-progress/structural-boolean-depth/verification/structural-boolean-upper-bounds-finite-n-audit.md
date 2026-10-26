# Independent audit: structural Boolean sample upper bounds

26 October 2026. **PASS**, subject to the analytic and graph-theoretic imports explicitly identified in the manuscript. This is mathematical review, not Lean verification.

Audited manuscript: `manuscripts/structural-boolean-upper-bounds.tex`, SHA256 `f7b743c5367c5ee6b0cbd084c0fac234ff395bbab231227ab0e24277b9abefca`. The final snapshot includes the two clarifications noted below. PDF SHA256 `9413f1980bef5d1ff6e14fa69893bbde25b47a68af76f38801cd204ee7c4bf38`.

## Heterogeneous circuit seed and actual-posterior transfer

The layer-dependent recurrence charges row norm `B_j` and width `C_j` at their actual stage. Its Gaussian mean-shift cost sums to `1/(8Lt²)`. The preceding-layer accuracy condition involves `B_j sqrt(C_(j-1))`, with initial width `d+1`, and is controlled by the sum resource S. The group fractions decrease, so the final group lower bound controls every earlier group's size. Conditional concentration over the whole cube and all rows uses the maximum stage width only through its logarithm; it does not reintroduce a depth times maximum-width penalty.

The inequality `q log S <= 2S` follows from `S >= q log(q+L+3)` and `S>=q`. It yields `log(1/p_q)=O((1+log A)S)` after selecting saturation gain `a=AS`. Hence taking A large enforces any fixed seed-relative accuracy requirement and the finite-width threshold remains `exp(O(S))`. The Gaussian diagonal recurrence has Lipschitz constant at most one for every `t<=1`. Relative score/residual bounds and the critical comparator are the same as in the imported scale-reuse proof.

The scalar-continuation input is explicitly imported, including its charged scalar entropy budgets and finite-width comparison. It uses the heterogeneous prefix only through the quantities verified above. Given the target action `Hc_t+V_*+O(bS+S²/H)`, the intrinsic exponent is O(S): use the `E/b` branch when `b>=S/H`, and `sqrt(HE)` otherwise. The scale-normalized polynomial factors are also absorbed by `exp(O(S))`. Below the seed-width threshold, the full finite-width class consistency bound supplies the all-realizable-width conclusion. No compiled-width fit is assumed in that lower range.

## Narrow-cut theorem

Cone blocking contributes `O(K+jK/log(K+2))`, and a two-stage truth-table suffix on w cut bits contributes only O(w) to the heterogeneous sum. The layer-count overhead remains within the same resource. Thus charging the large suffix width at every preceding stage is avoided legitimately.

After pruning gates not ancestral to the designated output, the final level has one bit. The first level of width at most y occurs by index `s/y+1`, giving `K+y+(s/y)g` and the optimized square-root bound. The author added this pruning clarification. The square-root consequence is explicitly restricted to the synchronous, no-late-input case. With later input injection, the corrected cut resource counts all distinct later input bits in `w_j+r_j`; retaining them through the prefix changes logarithmic width resources only by O(K).

## Treewidth theorem

The external balanced-tree-decomposition theorem is explicitly cited. Enlarging each bag by the predecessors of its vertices preserves connectedness of each vertex's bag set: each added successor subtree intersects the original subtree through a covered circuit edge. The width grows by at most a constant factor, and every gate constraint is then contained in a bag.

The Boolean constraint-system dynamic program is correct even though the original circuit is directed: after fixing external inputs, acyclicity gives a unique gate assignment, and satisfiability with output one is precisely acceptance. Running intersection ensures child solutions glue when their parent-bag assignments agree. There are `2^{O(k)} poly(v+d)` table entries and connections and O(log v) threshold stages. Normalized integer gate margins and norms give the asserted sum resource `O(log(d+L)+(k+log(v+d+L))log(v+3))`.

## Scope

All sample statements hold at the actual finite width and scale, for an arbitrary common training/test input law, with the original global-margin and exact-label conditioning. The padding condition is retained. The conditions are properties of a Boolean representation of the target, not restrictions on the learner prior and not properties automatically inherited from a narrow real-valued tanh teacher. No generic subexponential-depth theorem or lower bound is established.

## Geometric-separator assembly addendum

The final eight-page manuscript adds the planar/fixed-excluded-minor theorem and its full geometric separator proof. I checked Theorem 1.3, Section 5, and the revised abstract/scope against the independently audited `geometric-separator-layer-budget.md`. The two-weight separator recursion, geometric bag bound, predecessor enlargement, on-demand local-table schedule, and all-scale/all-width transfer are accurately assembled. Final audited TeX SHA256 `34279ee12c5ff71999ece5d60955cebf550f04a13a236d727a83cfe1b3abfe18`. The earlier sections retain their previous audited proofs.
