# Draft audit: physical computation model

8 October 2026. Reviewed the introduction and main sections 2, 6, and 9 in `computational_cosmology/report.md`, and scanned the remaining main text. Appendices were not yet present in the version reviewed. Edits were surgical patches restricted to sections 2, 6, and 9; no other sections were changed.

## Corrections applied

1. **Disambiguated logical work from thermodynamic work.** The resource table now calls gate count “logical work” and explicitly distinguishes joules.
2. **Qualified the depth claim.** Extra processors cannot shorten the dependency chain of a given implementation, but a different algorithm may. A circuit's depth is not automatically a problem-level lower bound.
3. **Counted controllers and decoders.** They are part of the physical architecture, preventing hidden computation in free preparation or readout.
4. **Stated the storage hypotheses.** Section 6 now cites the weak-gravity Bekenstein energy–radius bound separately from the optimistic gravitational area envelope. It explicitly says general-spacetime area statements need a light-sheet formulation and do not guarantee usable RAM.
5. **Fixed the logical direction in memory–latency.** The area envelope first gives a minimum storage radius; the latency deduction then additionally requires an actual data dependence spanning that working information. Drawing a large empty sphere around a small processor cannot create a latency lower bound.
6. **Made the quantum specification statement operational.** Replaced “exponentially many parameters to fixed accuracy” with “classical description of exponential length at fixed, nontrivial trace-distance accuracy.” This avoids hiding unlimited precision inside one classical parameter.
7. **Softened the reservoir claim in the conclusion.** It now states that the reserve's light-crossing time need not be the core's clock period, rather than suggesting that geometry alone proves a feasible, durable fuel-fed machine.

## Checks that passed

- Introduction distinguishes a feasible resource region from a universal FLOP budget, and separates geometric possibility from construction and maintenance.
- The positive-cosmological-constant scenario is explicitly conditional. Unlimited proper time is not claimed to establish an infinitely reliable machine.
- Jordan 2017 is used correctly: the state-orthogonalization theorem remains valid, while its unrestricted promotion to an algorithmic gate-rate bound fails.
- The area-envelope examples are numerically consistent with the **radius** convention: approximately 29 days for 10^100 bits and 8 billion years for 10^122. A diameter-crossing version doubles these.
- The 400-bit counter illustration is sound: 2^400 is approximately 2.58×10^120. It challenges the inference from erasures to gates, without claiming a practical immortal counter.
- The main text does not apply a single de Sitter patch's entropy budget globally to all disconnected descendants.
- The causal network proposal is labelled an accounting framework rather than a completed characterization of physically realizable computation.
- The working-memory/fuel-reservoir distinction is stated explicitly in section 4 and preserved in section 6.
- No-summoning is appropriately presented as a joint quantum/spacetime restriction, not a generic failure of ordinary classical messages.
- Aaronson's linked source is the appropriate *The Complexity of Quantum States and Transformations: From Quantum Money to Black Holes* (arXiv:1607.05256).

## Points for root to preserve when adding appendices

- A finite-state nonrepetition argument must count **the entire autonomous classical state**, including clock, controller, program position, and input. Do not generalize 2^B classical states directly to arbitrary quantum dynamics or all experienced computation.
- If an action integral is shown, call it an orthogonalizing-transition or architecture-dependent bound. Jordan prevents presenting it as a universal logical-gate budget.
- Do not infer global aggregate memory across every descendant from the area of one de Sitter horizon. These are different operational domains.
- The area envelope is optimistic and conditional. Near cosmological scales, flat-space R/c is only a scale estimate; exact curved-spacetime propagation and the applicability of the entropy bound need separate treatment.
- A “finite initial reachable mass” result does not by itself prove finite all-future reversible gate count.
- Brownian examples require the controller, terminal trap/reset and reliability costs; zero error and finite error are different limits.

## Remaining main-text observations, no requested changes

Sections 3–5, 7–8 appear appropriately hedged in this review. I have not independently checked their numerical integrals or the entropy-channel derivation; those remain with the quantitative/thermodynamic reviewers. The one-channel entropy-export example is unusually large but does not itself constitute an overclaim, because the channel count and omitted physics are explicit. The thermal-activation example similarly does not establish a real device and says so. The concluding plausible future is expressly a starting hypothesis rather than a quantitative forecast.
