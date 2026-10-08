# Revision audit: cosmology and specification

2026-10-08. Reviewed current `report.md`, principally sections 3–4 and Appendices A, C, and I. No report edits made. The report is being edited concurrently, so findings refer to the text read during this audit.

## Finding requiring clarification

**Appendix I: simultaneous storage versus lifetime target-specific input.** The counting theorem requires a bound on *all independently selectable target-specific classical choices* used in an execution. Appendix D carefully applies the conditional horizon entropy ceiling to a *simultaneously stored* program. Those are not automatically the same bound: a stream of externally supplied advice or control can cumulatively exceed instantaneous storage. Appendix I already charges all such choices to P, but should explicitly state the extra premise when putting P equal to horizon entropy.

Suggested addition: “For the cosmic numerical illustration, assume all target-specific choices are encoded in an initially programmed, closed controller, with no additional independently selected target-specific input later. A ceiling on instantaneous storage alone would not bound the lifetime length of externally streamed advice.” An equivalent clearly stated bounded-total-choice assumption suffices. The about-400-qubit conclusion then remains a conditional specification result, not a consequence of horizon entropy alone.

## Verified cosmology

- The probe/return, moving-receiver ellipsoid, and limiting-history geometry are correct with the stated initially comoving, homogeneous, light-speed-envelope assumptions. The finite-event inequality permits equality only for null deployment and instantaneous processing; the infinite-future envelope is not a reception event. The migration volume is πLq(Lq²−d²)/6 and is maximized at d=0.
- Olson attribution is now correct. Counting k returned answers after deployment corresponds to his n=2k−1 messages, giving r=L/(β⁻¹+2k−1).
- The fixed-worker proper-time processing recurrence and equal-delay radius are correct. The unequal-delay prefix-time formula is also correct; it agrees with explicit stepwise propagation for unequal examples. The finite-processing derivations are separated from Olson's existing zero-processing result without claiming priority.
- Reference-cosmology examples match `feedback_results.json`: 8 versus 6 complete answers at 1 Gly; radius table 8.340/8.100, 0.8340/0.6153, 0.08340/0.001564 Gly; 48.0 Gyr one-shot worker processing supremum. The text correctly warns that the last tiny radius is not an expansion bound on the retained Local Group. It keeps exact de Sitter analytic formulas separate from the full Lambda-CDM numerical integration.
- Nariai mass, fmax=1−(M/MN)^(2/3), initial matter comparison, and collected-energy mass are correct. The distinction between initial rest mass and assembled gravitational mass prevents an incorrect “all one-way matter is impossible to retain” inference.
- Nolan's exterior stable-circular-orbit threshold M<0.08MN is correct and appropriately restricted. The central-anchor depletion formula gives Mcrit/M0=0.94396 at u=0.5, so the about-6% statement is correct within its Newtonian adiabatic model.
- Outside-in consumption is accurately presented as an ideal spherical force-balance argument. The citation does not overclaim a Lambda-inclusive stability proof. Transport mass PR/c³, finite-particle effects, missing conversion mechanism, and lack of an end-to-end harvesting/storage architecture are acknowledged.
- The radius-crossing example gives 17.53/0.9794≈17.90, supporting “about 18.” The report does not turn this into a universal small-core clock or a Hubble-time expiration date.

## Independent Appendix I check

The mathematics is sound under a fixed decoder with at most 2^P selectable programs and trace distance defined with its usual factor one-half.

For a Haar state in C^d, rotational invariance permits taking the comparison state as the first coordinate. Squared normalized complex-Gaussian coordinates have a Dirichlet(1,…,1) distribution, so z=|ψ1|² has Beta(1,d−1) density. Integrating from 1−ε² to 1 gives ε^[2(d−1)]. The union bound and necessary P≥2(d−1)log2(1/ε) follow.

The mixed-output relaxation is also valid: choose any pure target within ε of a given mixed output, if one exists; all other covered pure targets lie within 2ε of that chosen target by triangle inequality. The ε→2ε replacement is conservative and sufficient at ε=0.1. It would need truncation at radius 1 for larger ε, irrelevant to the quoted example.

Recomputed numerical cutoffs at P=4.77×10^122:

- Pure-output necessary upper value: n≤floor(404.7972)=404.
- Mixed-output relaxed necessary upper value: n≤floor(405.3139)=405.

Plesch & Brukner's cited primary paper explicitly gives 2^(n+1)−2 real parameters in section II. The report correctly treats the covering argument as necessary rather than sufficient, distinguishes short descriptions of structured states, and excludes a physically supplied unknown state from its classical-description premise. Its main remaining vulnerability is the total-input versus simultaneous-storage clarification above.

**Conclusion:** No substantive algebraic, numerical, causal, or attribution errors found in the reviewed cosmology sections. Appendix I is mathematically correct; explicitly condition the horizon-sized total specification budget as described.
