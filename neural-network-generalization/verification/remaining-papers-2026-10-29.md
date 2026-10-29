# Remaining-paper writing and mathematical review, 29 October 2026

This pass covers the **48 canonical NNbayes manuscripts** outside the [earlier standalone review](standalone-writing-2026-10-29.md), plus **six standalone companions and technical supplements**. Together, the two passes cover all **66 canonical manuscripts** in the collection. The conditional-impossibility abstract was also clarified in response to a reader's notation concern. All 55 affected PDFs were rebuilt from isolated copies of their packaged sources.

[Detailed per-paper reviews, source comparisons, hashes, and build results](remaining-papers-2026-10-29.json) · [Formal coverage](../lean/VERIFICATION.md)

## Scope of the review

Six reviewers began with the assigned manuscripts, without the research conversation. They read the included proof chains, identified missing definitions and dependencies, improved the exposition, and checked the mathematics. The coordinating reviewer checked three further papers and the proposed corrections. Additional independent checks covered the singular-covariance correction, the endpoint margin convention, the two historical audit notes, and thirteen fragments of the longer depth report.

This was a conventional mathematical review, **not a new formal verification**. The detailed notes state which calculations were independently checked, which dependencies were imported, and which long estimates were not fully reconstructed. In particular, some implicit constants in the longest parity transport and contour estimates were traced but not independently quantified throughout. Build success is evidence of reproducibility of the source, not correctness of its mathematics.

## Corrections and findings

- **Singular Gaussian readout cost.** The [nearcritical positive-window paper](../works-in-progress/nearcritical-positive-window/nearcritical-positive-window.pdf) wrote a pseudoinverse quadratic form without requiring the output to lie in the covariance matrix's range. That condition is necessary: a nonzero vector in the nullspace has zero pseudoinverse cost but is outside the Gaussian support. The definition now assigns infinite cost off the range. Every witness and actual finite-network output used by the proof satisfies the condition; the learning theorem is unchanged.
- **Margin in the target complexity.** The [earlier mean-field endpoint paper](../side-results/gamma-ge1-endpoint/paper.pdf) now explicitly requires strict signed output margin greater than one-half in both its target-complexity definition and shallow counting lemma. Its existing cloning proof triples the readout, which does not provide the claimed margin from a sign-only witness of arbitrarily small margin. The correction restores the convention used in the main papers; it does not prove an unchanged resource bound for arbitrary sign-only implementations.
- **A missing hypothesis in an abstract.** The [symmetric-parity amplitude paper](../side-results/symmetric-parity-amplitudes/paper.pdf) now retains the fractional block-degree hypothesis when describing its block-sign-symmetry extension. The theorem already required that hypothesis.
- **An unsupported additional conclusion.** The [Fisher-degree note](../side-results/fisher-degree-reductions/paper.pdf) asserted that an omitted repair-cost calculation excluded a selector construction from bounded-cost models. No proof or citation established that assertion. The closing passage now states the scope of the proved analytic obstruction and leaves the repair-cost conclusion unproved.
- **Simultaneous-depth quantifier.** The [logistic shallow-target paper](../works-in-progress/shallow-logistic-softplus/logistic.pdf) claimed a single sample event over depths but only explicitly argued at fixed depth. The proof now allocates failure probability as `delta_L = delta/[L(L-1)]`, for `L>=2`, and takes the countable union. The extra logarithmic depth term is absorbed into the theorem's existential polynomial. Its small-width class union, and the analogous softplus union, are now explicit. The theorem is preserved.
- **Boundary and convention corrections.** The critical-depth confidence statement now counts equality at probability two-thirds as failure, as its existing Markov argument already permits. The appendix audit distinguishes an infimum budget from actual strict-margin feasibility, states the normalized activation bound needed by its sensitivity formula, and defines its rescaling coefficients. The second depth report specifies the domain of its fault-model parameters and counts the constant wire at every circuit stage. The logistic and softplus parity examples now account for their fixed overall sign convention. These changes and nominal notation edits are recorded in the source comparison.
- **Empirical reproducibility wording.** The second depth report implied that a complete replay archive for its 168-network cohort accompanies the public package. The archive index records that earlier archive without a public download URL. The paper now states this limitation. Those experiments were not rerun in this review; the separately published depth experiments have a different, documented reproduction scope.

No further counterexample to a central learning conclusion was established by these checks. This is a report of the review's findings, not a guarantee that all remaining arguments are correct.

The two audit notes also received independent checks of their historical allegations. The L2-to-pointwise regularity counterexample was verified against Definition A.6(I4) of [Vaintrob–Hänni, arXiv:2607.05735v1](https://arxiv.org/html/2607.05735v1). The entropy-tail and fresh-noise examples identify gaps in particular justifications, not complete counterexamples to every hypothesis of that paper's final theorem. The strong-prior audit now acknowledges that the source slides themselves warn against deriving a sample lower bound solely from tiny target prior mass.

## Standalone presentation

The revisions introduce architectures, layer variances, conditioning events, prediction criteria, complexity measures, and orders of limits before using them. Proof roadmaps explain how the technical estimates produce the learning conclusion. References to “the original model,” “the supplied note,” or “the previous report” were replaced by local definitions or identified sources. Historical open-problem statements are scoped to their original arguments and distinguished from subsequent results.

In the [conditional-impossibility abstract](../works-in-progress/conditional-nonpolynomial-learning/paper.pdf), the scale is now explicitly a prescribed schedule `t=t(d,L,N)`, hence `t(N)` at fixed dimension and depth. Constant schedules remain allowed. The theorem already used this quantifier convention; neither its statement nor its formalization changed. Relevant papers now make the same width dependence explicit. The FAQ also clarifies that the tanh population condition may be used alone or intersected with internal-noise robustness.

## Correspondence and build checks

The comparison baseline is commit [`2a7fa22a`](https://github.com/kaarelh/AI-works/commit/2a7fa22a3d3e586b8d94c7cf5b682c21515a278d).

- All **1,907 tracked Lean files** are byte-identical to the baseline. No theorem, definition, proof, axiom dependency, or formal-coverage claim was added or changed. The previously formalized papers retain their correspondence; the abstract clarification is consistent with the existing scale-schedule statement.
- Author declarations are unchanged. The remaining-paper source comparison records mathematical and explanatory edits; unlike the earlier prose-only pass, this pass does **not** claim every informal statement was unchanged.
- All **55 affected PDFs** were rebuilt in isolated directories and their extracted text matches the published PDFs. Final logs contain no unresolved references, missing citations, or overfull boxes. Four PDFs retain harmless underfull spacing warnings around long URLs or certificate filenames.
- Exact certificate checks included the 49,149-orbit enumeration, smaller repair certificates, and the rational Gaussian counterexample. Other targeted checks covered spectral identities, parity relays, occupancy/confidence constants, and small-cube harmonic masses. Numerical sanity checks supplement, rather than replace, the stated proofs.
- Catalog pages and hashes, current checksum manifests, manuscript indexes, and local Markdown links were refreshed. The collection validator now respects custom PDF filenames and ignores code blocks when checking Markdown links. Historical verification records retain their original snapshot hashes.

## Papers and documents

The table lists the 48 papers reviewed in this pass. Detailed checks and limitations for each are included in the JSON companion above. Reviewer notes precede final integration; the final build and source-hash fields are authoritative for the published files.

| Paper | Pages |
|---|---:|
| [Small circuits under Gaussian-process classification: what sample complexity follows from the actual posterior?](../side-results/nngp-sample-complexity/paper.pdf) | 12 |
| [The fixed-kernel regime of a margin-conditioned Bayesian neural-network prior](../side-results/gamma-below-one/paper.pdf) | 12 |
| [Small circuits can have exponentially large prior complexity below the mean-field scaling](../side-results/subcritical-circuit-prior/paper.pdf) | 7 |
| [Gaussian conditioning below the mean-field scaling: a sharp fluctuation threshold](../side-results/subcritical-gaussian-conditioning/paper.pdf) | 10 |
| [Finite-width circuit learning below mean-field scaling](../side-results/finite-width-subcritical/paper.pdf) | 6 |
| [Global Margin Conditioning Amplifies a Gaussian Posterior Mean](../side-results/gamma-zero-mean-energy/paper.pdf) | 5 |
| [Global-margin conditioning at the Gaussian endpoint: normalization, training loss, and output amplitude](../side-results/zero-gamma-conditioning-note/paper.pdf) | 12 |
| [Failure of Bayesian Gaussian process classification at exponentially large sample sizes](../side-results/gaussian-exponential-schedule/paper.pdf) | 11 |
| [Exponential sample lower bounds for Bayesian Gaussian process classification](../side-results/gaussian-exponential-lower-bound/paper.pdf) | 13 |
| [Superpolynomial sample lower bounds for globally margin-conditioned Bayesian neural networks below the mean-field scaling](../side-results/subcritical-sample-complexity/paper.pdf) | 12 |
| [Superpolynomial sample lower bounds below the mean-field scaling: the earlier positive-exponent argument](../works-in-progress/positive-subcritical-sample-complexity/paper.pdf) | 8 |
| [Sparse parity under globally conditioned neural priors](../side-results/sparse-parity/paper.pdf) | 20 |
| [Exponential sample lower bounds for sparse parity under a globally separated neural prior](../side-results/growing-sparse-positive/paper.pdf) | 21 |
| [Growing sparse parity under a globally separated neural prior](../side-results/intermediate-parity/paper.pdf) | 38 |
| [Natural sparse-parity lower bounds at slowly growing depth](../side-results/growing-depth-parity/paper.pdf) | 38 |
| [Symmetric parity predictors require large amplitudes: an exponential lower bound and a consequence for margin repairs](../side-results/symmetric-parity-amplitudes/paper.pdf) | 8 |
| [Homogeneous parity approximants have a strict local repair cost](../side-results/homogeneous-cell-calibration/paper.pdf) | 7 |
| [Certified margin-repair bounds for structured parity predictors: cubic and quartic heads, exact certificates, and parity-block lifts](../side-results/structured-parity-repair-certificates/paper.pdf) | 8 |
| [Learning parity from selected examples under a globally separated neural kernel](../side-results/selected-examples-parity/paper.pdf) | 6 |
| [Degree and square-root energy on the Boolean cube: equivalent positive estimates and a signed obstruction](../side-results/fisher-degree-reductions/paper.pdf) | 5 |
| [Parity, polynomial degree, and contact-weighted error costs](../side-results/parity-contact-calibration/paper.pdf) | 7 |
| [A certified margin-repair bound for cubic parity predictors: one arbitrary bit, twenty-six symmetric bits, and parity-block lifts](../side-results/cubic-parity-repair-certificate/paper.pdf) | 5 |
| [A quartic-width learning bound for Bayesian networks stable under internal noise](../works-in-progress/improved-polynomials/original-support/paper.pdf) | 7 |
| [Quadratic-width learning bounds for Bayesian networks with stable neuron populations](../works-in-progress/improved-polynomials/neuron-averaging/paper.pdf) | 8 |
| [Quadratic-width learning with symmetry-invariant neuron merging](../works-in-progress/improved-polynomials/neuron-merging-naturality/paper.pdf) | 8 |
| [Polynomial sample complexity for ReLU NNBayes with strong Gaussian priors](../works-in-progress/relu-learning/paper.pdf) | 10 |
| [Polynomial-depth Bayesian learning with general Lipschitz activations under balanced neuron-averaging stability](../works-in-progress/unified-activation-polynomial-depth/paper.pdf) | 13 |
| [A sharp ReLU energy baseline and compression above that baseline](../works-in-progress/relu-relative-product/paper.pdf) | 8 |
| [Shallow targets under deep logistic posteriors](../works-in-progress/shallow-logistic-softplus/logistic.pdf) | 8 |
| [Representation constraints and polynomial-depth learning in Gaussian Bayesian networks](../works-in-progress/unrestricted-depth/paper.pdf) | 53 |
| [Depth dependence, internal robustness, and Bayesian neural-network learning](../works-in-progress/depth-supporting-notes/round1-depth-report/paper.pdf) | 32 |
| [Depth-uniform Gaussian Bayesian learning of shallow Boolean targets](../works-in-progress/depth-supporting-notes/round2-shallow-targets/paper.pdf) | 16 |
| [Bounded critical Gaussian cost for every Boolean function at quadratic depth](../works-in-progress/depth-supporting-notes/round2-critical-rates/paper.pdf) | 9 |
| [Depth and learning bounds for critical Bayesian neural networks](../works-in-progress/critical-depth/paper.pdf) | 107 |
| [Bayesian circuit learning at mean-field scaling: a variational principle and width-independent generalization](../side-results/gamma-ge1-endpoint/paper.pdf) | 15 |
| [An explicit sufficient width for mean-field Bayesian circuit learning](../side-results/meanfield-quantified-width/paper.pdf) | 16 |
| [Exponential-depth sample complexity for a Gaussian Bayesian tanh network with a supercritical variance prefactor](../works-in-progress/supercritical-depth-lower/paper.pdf) | 12 |
| [Exponential sample complexity for an analytic activation arbitrarily close to tanh](../works-in-progress/analytic-activation-depth-lower/paper.pdf) | 25 |
| [The cost of narrow input layers in Boolean neural networks](../works-in-progress/narrow-layer-information/paper.pdf) | 5 |
| [Arithmetic formulas for low-product tanh networks and a Bayesian learning converse](../works-in-progress/tanh-arithmetic-formulas/paper.pdf) | 21 |
| [Exponential sample complexity arbitrarily near mean-field criticality](../works-in-progress/nearcritical-depth-lower/paper.pdf) | 18 |
| [Finite-width bounds for the globally margined tanh posterior](../works-in-progress/finite-width-posterior-bounds/paper.pdf) | 8 |
| [A Wasserstein lower bound for local group-product networks](../works-in-progress/local-group-computation/paper.pdf) | 8 |
| [Structural Boolean circuits and subexponential sample bounds for the original Gaussian tanh posterior](../works-in-progress/structural-boolean-depth/paper.pdf) | 10 |
| [A positive learning window above the critical tanh prefactor](../works-in-progress/nearcritical-positive-window/nearcritical-positive-window.pdf) | 6 |
| [A proof audit of strong-prior Bayesian neural-network generalization](../side-results/strong-prior-appendix-audit/paper.pdf) | 9 |
| [An audit of Gaussian-prior scaling arguments for Bayesian neural-network learning](../side-results/gamma-proof-audit/paper.pdf) | 4 |
| [Polynomial depth in Bayesian neural-network learning: unrestricted Gaussian priors, trained networks, and numerical stability](../works-in-progress/depth-supporting-notes/round2-depth-report/paper.pdf) | 69 |

Additional documents: the three Gaussian/non-Gaussian/quadratic-occupation companions to the tanh arithmetic-formula paper; the softplus companion; and the first depth report's compression and excess-energy supplements. Their separate hashes, page counts, and rebuild results are in the JSON. The conditional-impossibility abstract follow-up is recorded there separately.
