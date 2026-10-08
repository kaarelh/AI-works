# Publication audit of the revised computational-cosmology report

8 October 2026. Reviewed the abstract, sections 2, 6, 7, and 9, and Appendices D and I; also checked overlapping claims in Appendix F. This was an independent scope and algebra review, not a new empirical validation of hypothetical hardware.

## Result

**No blocking mathematical or conceptual error found in the requested sections.** The report now distinguishes universal causal restrictions, necessary resource inequalities, and sufficient constructions conditional on jointly valid hardware contracts. It does not infer useful gates from the Margolus–Levitin bound, addressable memory from horizon entropy, or reliable lifetime from cosmic proper time. The reserve/core distinction is appropriately narrow.

The principal new calculations are correct under their stated assumptions:

- The serial model follows from Cauchy's inequality. Equal durations saturate its dynamic-cost expression, and optimization over delivery time produces the stated finite-depth plateau. The minimum-tick form and integer-rounding qualification are correct. Controller capacity, finite validity ranges, and maintenance after delivery are explicitly addressed.
- The persistent-memory relation $qD^2\leq B^2/(4a\gamma)$ is correctly conditioned on fixed hardware coefficients; it is not advertised as a universal memory–depth theorem.
- The immediate-return de Sitter expression $t=-H^{-1}\ln(1-r/r_{\rm ret})$ and the resulting maintenance-limited radius are correct. The quoted matter fraction for $HB_{\rm wait}/\Gamma=0.1$ is approximately $0.0008618$, or $0.086\%$.
- The neighbor-chain routing count is correct: moving one register to adjacency and back costs at most $2(q-2)$ swaps. Its use as a construction counts the physical implementation and protection overhead instead of silently equating swaps with free long-range gates.
- Appendix I's Haar-ball measure is exact for pure candidate outputs. The factor-of-two-radius repair for mixed outputs is a valid triangle-inequality covering bound. The necessary integer ceilings of 404 and 405 at the stated program budget and precision are consistent with the equations. The closed, initially programmed controller condition avoids confusing a simultaneous storage cap with a bound on lifetime streamed advice.
- The growing archive statement and the reversible block-checkpoint construction in Appendix F agree with the independently reviewed research memo. Both retain the necessary architecture and task restrictions.

## Small recommended changes before publication

1. **Section 2, “a complete depth–memory–duration frontier”:** replace with “an explicit entropy-constrained depth–memory–duration frontier.” The figure solves the stipulated entropy model, while capacity, controller implementation, and reliability remain conditions. The caption already makes this distinction; the revised phrase would make the earlier sentence match it.

2. **Appendix D, “Appendix F gives a less wasteful construction”:** replace “a less wasteful” with “another.” No comparative dominance over the nearest-neighbor routing construction has been established, and the two constructions charge different aspects of the implementation. The constructive point does not depend on that comparison.

3. **Appendix F, paragraph beginning “A simple illustrative optimization makes the speed–maintenance tradeoff visible”:** delete or reduce to a cross-reference. The same $A/\tau+\Gamma\tau$ optimization is now derived more fully in section 7 and Appendix D. Its repetition adds length without a new result.

4. **Optional terminology polish in Appendix D:** “idle entropy rate” can be read as a cost only while no gate executes, whereas $\gamma_i\int q_i(t)dt$ charges protection throughout the memory lifecycle. “Memory-maintenance entropy rate” is clearer and avoids a possible double-counting interpretation.

5. **Optional local precision in section 6:** make the archive sentence say “error at most $\varepsilon<1/2$.” Appendix F supplies this assumption already, and the main-text example uses 1%; stating it locally keeps the information-theoretic inequality self-contained.

## Publication readiness and limits

The main text is readable without project history. The abstract's claim that the model admits conditional constructions is supported, and the concluding refusal to give an unjustified maximum-depth exponent is consistent with the analysis. The figures and formulas are explanatory rather than presented as empirical fits. The remaining duplication is mostly useful main-text versus appendix repetition; the specific Appendix F paragraph above is the exception.

The physical coefficients and unbounded-duration primitive validity remain unresolved research questions, clearly disclosed. No additional generic warning or approval disclaimer is needed. A future improvement would be a jointly realizable primitive package with measured or defensible duration, error, storage, work, and entropy bounds; independently optimistic coefficients should continue to be avoided.
