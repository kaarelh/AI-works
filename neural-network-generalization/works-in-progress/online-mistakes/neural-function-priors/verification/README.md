# Review and publication record

30 October 2026. [Paper](../paper.pdf) · [source](../source/paper.tex)

These are conventional proofs with independent AI-agent reviews, not Lean formalizations or human peer review. Earlier Lean coverage of the imported neural results does not automatically certify the new online transfers.

The mathematical reviews checked:

- **Imported neural bounds:** the norm count, cloning bound, target-cylinder probability, aggregate exceptional mass, and small-/large-width split against the three primary neural papers and the existing online upper-bound paper. Fixed-depth, fixed-exponent, all-width, and width-dependent small-variance quantifiers are preserved. A scalar bound on both branches does not falsely assert a common finite class in the direct-mass branch.
- **Structured environments:** the posterior tail estimate after every history, the pathwise charge `q_out <= beta·1{new input}`, the iid source-prefix survival integral, adaptive source interleaving, and the finite-pool variation. Input distributions are fixed before the process; source selection is predictable.
- **Concentration:** the inside process conditions before the fresh input; the sampled outside process conditions after the query and before the private posterior draw. The two distinct conditioning stages are used explicitly. The stopping rule tests only observed source prefixes. Cumulative posterior error and sampled mistakes have separate stated probability bounds.
- **Neural transfer:** setting `beta=2^(-d)` keeps the structural budgets polynomial while making the entire outside contribution at most one. Direct-prior branches already work on arbitrary orders. Strong-prior limits are taken after conditioning on each history, rather than conditioning a limiting prior that may give the target zero mass.
- **Rank transformation:** averaging `1/[r(r+1)]` across a tie group gives exactly `1/[(a+1)(b+1)]`; the total normalizer is `M/(M+1)`. All strict comparisons and ties are preserved. Inclusive target rank bounds the target's negative log probability. The transformation is fixed before labels and does not use the unknown target.
- **Prediction conventions:** posterior sampling, majority, and failures of strict `>2/3` correctness use the corresponding Bayesian potential bounds. Rank preservation leaves MAP choices unchanged; the new bound is not attributed to MAP prediction.
- **Parameter-space realization:** multiplying the global-margin-conditioned Gaussian density by the desired function mass divided by its original function mass gives the claimed pushforward and preserves conditional laws within each function event. It generally destroys Gaussianity and coordinate independence.
- **Energy budgets:** geometric near-minimum function classes have monotone complexity budgets, logarithmic depletion costs, and one charge for each exhausted budget. The proof samples distinct functions, not parameter vectors. No attainment of a minimum-energy parameter is required.
- **Scope:** global-margin conditioning is required by the imported neural bounds. No uniform exponent as `gamma` tends to one, unrestricted polynomial depth bound, efficient rank computation, or arbitrary-order theorem for the unchanged Gaussian learner is asserted. The abstract distinct-energy failure example is not relabeled as a neural counterexample.

The [machine-readable record](record.json) contains source/PDF hashes, an isolated rebuild comparison, final LaTeX diagnostics, link checks, and confirmation that earlier Lean files and other manuscript mathematics were unchanged. The PDF was also inspected visually. The collection navigation and FAQ distinguish the unchanged-prior result from the prior modification.
