# Verification and scope

30 October 2026. [Paper](../paper.pdf) · [source](../source/paper.tex)

These are conventional proofs with independent AI-agent mathematical reviews, **not Lean formalizations or human peer review**. The earlier formalized Gaussian width limits do not automatically certify the new consequences.

The reviews checked:

- **Fixed-depth AND upper bound:** nonnegative Taylor coefficients give the affine Gaussian covariance component; shifting that component realizes the full AND margin. Gaussian tails and a binary relative-entropy inequality give a lower bound on raw target mass. Global-margin conditioning increases that mass. One eventual finite-width bound applies to every history, rather than assuming uniform convergence of infinitely many posterior histories.
- **Growing-depth Gaussian lower bound:** iterated arcsine correlations become small at the explicit linear depth. Density bounds are integrated over full-margin orthants, so rare-event conditioning is retained. All finitely many function masses converge, yielding an eventual finite-width ratio bound uniform over every history. Sampling, confidence, and majority are distinguished; no majority lower bound follows from this part.
- **Width-one geometry:** the tanh norm reduces monotonically to the affine full-cube margin norm. Essential coordinates have magnitude at least one. Averaged lower-layer constraints classify the exact initial minimizers. A signed augmented-coordinate symmetry gives equal Gaussian function masses across both majority-support families. The logarithmic mistake bound covers only this initial tier, not all later energies.
- **Anisotropic strong-prior lower bound:** strict convexity gives the optimizer derivative for each function's perturbed quadratic cost. Dyadic coordinate coefficients split all relevant support ties; a finite positive gap keeps every such candidate cheaper than outsiders. A covering count forces exponentially many distinct counterexamples. Gaussian small-noise concentration gives the same result at sufficiently small positive variance, on a fixed input permutation. The covariance perturbation is essential to the argument.
- **Admissible majority target:** the same queried labels agree with majority on odd dimension, implemented by one unit-weight tanh neuron, so `C_2(f)=N=1`. The AND realization alone does not establish this bounded-weight width convention.
- **Prediction and probability conventions:** confidence failure includes equality at `2/3`; high-probability forced errors follow by taking one sufficiently small variance for all finitely many selected rounds. The iid comparison measures error under the chosen test distribution, not an unsupported uniform fraction.
- **Remaining gap:** no exponential counterexample is claimed for the original equal-coordinate-variance strong prior or `gamma>=1`. No finite-width threshold is quantified for the Gaussian-process results; no variance threshold is quantified for the perturbed strong-prior result. The orders of these parameter choices are explicit.

The [machine-readable record](record.json) records source hashes, an isolated PDF rebuild, LaTeX diagnostics, collection-link checks, and preservation of earlier manuscript mathematics and Lean files. The PDF was also checked visually.
