# Independent audit: strict scalar decrease and signed alignment

26 October 2026. Auditor: `/root/critical_nongaussian_formula`.

**PASS** at source SHA256 `5b7d068ed1e725e2ee43cfc359eb74f727658001750b5f0f98dfd998bfd6b973`.

The strict-decrease proof correctly uses increasing nearoptimal scalar paths of bounded cost. Dissipation bounds their length by C/a^2. Entropy supplies a uniform second moment, and the next-state lower bound a forces at least a/2 mass in the displayed compact annulus. The variance-rescaling derivative is uniformly positive there; its lower bound can be taken c a^3 exp(-C/a). Entropy remains unchanged under the repeated rescalings, the state ratios stay in [1,1/a], and the final readout saving gives the claimed exp(-C/a^3) slope. No differentiability or attained Bellman optimizer is used.

For the alignment theorem, choose the maximum-norm anchor at the layer under study; it may depend on the layer. Prefix scalar Bellman telescoping and the signed-pair suffix lower bound combine exactly to V(v_x)-V(q)<=epsilon+Cq_b. The variance identity in (3) has the correct coefficients. Positive pair variance is now stated explicitly, so V(0) is never invoked.

The published small-q expansion yields C(E+q^2), and the strict slope away from zero yields C_q0 E. The uniform qualitative rank-one-neighborhood consequence follows with constants chosen in the stated order. The argument is uniform over the cube and permits arbitrary finite-entropy internal controls.

The note correctly leaves both a stable ridge replacement and a scalar-formula/circuit compiler unresolved; the alignment estimate alone is not a positive learning theorem.
