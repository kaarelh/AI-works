# Lean-related paper issues (from the Lean README update)

- app-lean.tex: T3 Thm 3.3(c) (thm:physics:nofree (c)): fidelity should be "variant" (no derivatives; the jet/Taylor-coefficient link is a hypothesis), not "special case".
- app-lean.tex: T6 Thm 2.6 (thm:existence:structural): fidelity "special case (fixed signature)", not "exact".
- existence.tex (around line 42): says nothing in the section is formalized except the semantic half of the duality theorem. That is stale. Bilateral.lean formalizes thm:existence:bilindenbaum, cor:existence:bilateral, thm:existence:duality and thm:existence:structural; Specker.lean formalizes thm:existence:arity and the probabilistic part of prop:existence:triangle. Add \leanok tags and fix the sentence.
- informal.tex and physics.tex have no \leanok tags. Add them per app-lean.tex's table:
  - informal: lem:informal:descent, thm:informal:objects (a),(b), thm:informal:paradoxes (b),(c), thm:informal:bags;
  - physics: prop:physics:los, prop:physics:sup, lem:physics:import, thm:physics:eternalism, prop:physics:misdesignation, thm:physics:hygiene, lem:physics:invisible, thm:physics:nofree, prop:physics:radius, thm:physics:coherencetol, thm:physics:noreg, thm:physics:lipschitz, thm:physics:monotone.
- caution.tex: add \leanok on thm:caution:esc (Unstructured.thm_3_2, deterministic) and thm:caution:unstructured (Unstructured.thm_3_9_Esc_le_card, thm_3_9_coSingleton).
- physics.tex thm:physics:nofree closing remark ("can fail outside C^infty") does not apply to case (d): Export.no_free_export_samples_of_poly_subset proves (d) for every Q once the class contains the polynomials. Adjust the remark.
