# Independent audit: critical learning after Boolean depth blocking

Reviewed by the counter-audit agent on 19 October 2026.

Reviewed note: `critical-blocking-and-formulas.md`, SHA-256
`5a600b7b3063d57550bdca2c5dfb01cac595e87ec2089db3dfff6d905f778b1b`.

**Verdict: the stated consequences follow from the established circuit-rate and critical-sublevel-capacity theorems. No mathematical correction requested.**

I independently checked the following points.

* With binary fan-in, a block of b layers has at most 2^b relevant boundary signals per output. Its full truth-table DNF uses at most 2^(2^b) terms, two threshold stages, and weights and widths whose logarithms are O(log S + 2^b). Identity-wire layering costs O(S) maximum width, even though total wire count can grow by h.
* The threshold circuit's rate parameter is bounded by C(1+h/b)[log(S+L)+2^b]. Taking L at least a sufficiently large multiple of this expression gives both L-h_b at least L/2 and the precise prefix-steering depth hypothesis. The resulting excess is C U_b^2/L, and the capacity exponential is exp(C U_b). The remaining polynomial prefactor is absorbed because U_b dominates log(S+L), while h is at most S and U_b is O(L) in the stated feasible regime.
* The choice b approximately log_2 log(S+L), capped at h and below by one, has the asserted upper bound. For h smaller than this cutoff, b=h and the additive 1 absorbs the edge case. The near-optimality claim concerns this full-DNF blocking construction only; it does not assert a lower bound for other circuit compilers.
* Formula balancing uses an ordinary separator-subformula recurrence, yielding polynomial size and logarithmic depth. Substitution gives exp(O(log^2 S/log log S)) samples for polynomial learner depth, subject to the stated minimum-depth condition.
* A fixed-width oblivious branching program becomes a balanced Boolean-semiring matrix-product circuit of logarithmic depth and polynomial size. All read-only input queries remain explicit. No finite-state neural bottleneck follows merely from the constant number of work states.

The width threshold remains qualitative, inherited from the width-first learning theorem. The result does not prove a polynomial bound for general logarithmic-depth circuits, formulas, or constant-width branching programs. The warning that the displayed optimized bound is not numerically decreasing with learner depth is correct.

## Final optimized TeX source

Also reviewed `source/critical-optimized-circuit-blocking.tex`, SHA-256
`0c83d78ae1f387e590de0e7f4eaf8a4253209b234b376e534a30f0fe76dbe255`.
The full source passes, including the newly optimized prefix budget and adaptive width-sensitive expression.

The revised per-stage entropy budget eta=q/L is at most one under L>=q. The mixture weight eta*r/P remains at most one, total prefix entropy is q^2/L, and the surviving covariance component has logarithmic cost log d + sum log(4 C_j P_j L/q). This makes the displayed T dominate q; the hypothesis L>=C_0 T therefore gives L-q>=L/2 and permits the prescribed-prefix steering theorem. Both q^2/L and the steering cost are bounded by C T^2/L. The sample-capacity prefactor is absorbed into exp(C T) because T dominates log(d+L+2), and, in the feasible regime, the rate bound is at most V_*+C T.

For adaptive blocking, k=ceil(h/b) implies L/k<=bL/h. Hence log(2+L/k)<=log b+log(2+L/h). With a=log(C+2)+log(2+L/h) and b the capped floor of log_2(a+2), one has 2^b<=a+2, log b<=C a, and k<=C[1+h/log(a+2)], including the capped case b=h. Substitution proves T_b<=C T_* exactly as claimed. No hidden teacher-depth constant is needed.
