# Independent audit of the finite-width canonical posterior cover

25 October 2026. Finite-N audit agent. Conventional mathematical audit, not Lean verification.

**PASS.** Source `canonical-finite-width-posterior-cover.md`, SHA256 `544a764cfd3926cb0f6eb29fc098ec4493ee5f728b279432548c5d124d7189c7`.

The isotropic coordinate transformation gives exactly p=N(d+2)+(L-2)N^2 independent coordinates of variance t^2/N, and preserves the physical network through the normalized activation tanh(sqrt(N)s)/sqrt(N). Cloning at all N>=C, including nonmultiples, gives the stated width-independent teacher energy: first-layer and output costs use the smallest/largest replication counts, and internal costs use their ratio, at most two.

The parameter Lipschitz estimate follows from the product of all other block Frobenius norms, the zero-fixing unit-Lipschitz activation, and AM–GM. Convexity of the energy ball permits integration along the whole segment. The chosen teacher neighborhood stays inside its energy ball and has signed output at least 3/4 everywhere.

The posterior denominator uses an actual Euclidean neighborhood of that cloned teacher and retains both global-margin and training constraints. Clipping the inscribed cube half-side at sigma is crucial and correctly removes any log(1/t) penalty. Its density lower bound yields the displayed T uniformly in t. Dividing the Gaussian chi-square Chernoff tail by this denominator gives the stated posterior energy radius, with the coefficient 2K and all sigma/N factors correct.

The energy-ball net is independent of the sample and distribution. Global absolute margin makes every low-energy posterior truth table exactly equal to a net-center truth table, even though the centers need not satisfy global margin themselves. Its entropy is bounded by C p L log(S+N+beta^(-1)). The finite-class consistency union bound, posterior energy tail, and Gibbs-to-confidence Markov inequality then give the claimed sample bound at alpha=beta=epsilon/6.

Uniformity as t tends to zero can be passed through the posterior Gibbs error, which is a continuous functional on the finite truth-table simplex. There is no need to pass the discontinuous confidence-threshold event directly through the limit. The final confidence conclusion follows again from the same Markov inequality. This justifies the fixed-architecture strong-prior limits and all pointwise parameter schedules claimed in the note.

The exponential-width consequence also follows: when ordinary teacher resources are polynomial in L, the upper bound is N^2 times a polynomial in L and log N. An exponential-in-L sample lower bound therefore requires log N>=cL/2-O(log L). The note correctly retains its bounded-weight teacher assumption, explicit learner-width dependence, and finite-width posterior scope. It does not establish an all-width depth-polynomial sample theorem.

## Integration audit of the combined manuscript

25 October 2026. **PASS** for Sections 1–2 (including Theorem 2.1 and its exponential-width corollary) of `manuscripts/finite-width-posterior-bounds.tex`, SHA256 `a30ab8a81329824484f1c8243b468c4ad72bc655083e3cf662544ae16647eb2c`.

I freshly read the assembled model, statement, and full upper-bound proof against the source audited above. All hypotheses survive integration: the teacher is at the learner's depth, has bounded physical weights and a unit signed margin, the prior has canonical prefactor `0<t<=1`, both posterior conditioning events remain imposed, and the bound keeps the actual learner-width parameter count. The cloned teacher, clipped cube, conditional energy radius, margin-stable net, Gibbs conversion, and cold-limit argument are unchanged mathematically and remain valid. No substantive correction is needed. The separate symmetry lower bound and width-nonmonotonicity example are outside this integration audit.
