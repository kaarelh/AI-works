# Collection verification

## Further depth improvement, 29 October 2026

[Further depth improvement: bounded-density and factor coding, 29 October 2026](factored-depth-2026-10-29.md) records the conventional C⁵L¹² all-scale theorem, its independent checks, and the unchanged quartic bound.

## Quadratic-width and improved-depth results, 29 October 2026

Two [new manuscripts](depth-improvements-2026-10-29.md) give a literal `dC+LC²` sample polynomial under a digital-population prior, analog variants near that rate, and sequential-quantization depth improvements under the unchanged original robust support. Their proofs have independent mathematical reviews and isolated build checks; neither is Lean formalized. The catalog now has 68 canonical manuscripts.

## FAQ and joint width–depth polynomials, 29 October 2026

The [FAQ review](faq-refresh-2026-10-29.md) makes teacher width and depth explicit in the improved sample bounds, with derivations from each paper's budgets and separate formal-coverage labels. The general pass updates the conditional depth obstruction, finite-width subcritical upper bound, confidence constants, empirical scope, and extension status. Papers and Lean sources are unchanged.

## Remaining papers: standalone and mathematical review, 29 October 2026

The [second review](remaining-papers-2026-10-29.md) covers the other 48 canonical manuscripts and six companions/supplements, with local mathematical corrections, detailed review limits, and isolated rebuilds. Together with the first pass below, it covers all 66 canonical manuscripts. The conditional-impossibility abstract was also clarified to state its prescribed width-dependent scale. No Lean sources changed. The new record supplies current manuscript hashes; older records remain snapshots of their stated dates.

## Standalone writing review, 29 October 2026

The [editorial review and correspondence checks](standalone-writing-2026-10-29.md) cover the sixteen papers with formalized main results and two papers with component-level coverage, including one companion note. All nineteen PDFs were rebuilt from their packaged sources. The Lean sources are unchanged; earlier formal build records remain valid for those sources. The linked revision record supplies the updated manuscript hashes and distinguishes prose clarifications from unchanged mathematical statements.

## Conditional nonpolynomial learning, 29 October 2026

The [conditional impossibility paper](../works-in-progress/conditional-nonpolynomial-learning/verification/) has a closed Lean proof of its central theorem for the actual Gaussian tanh posterior. The proof includes the scale-uniform posterior circuit ceiling, finite circuit compiler and circuit-class reduction. Its separate package preserves the original five-result and second-batch numbering; the linked record states the exact scope, source hashes and fresh-build checks.

This record concerns packaging and source reproducibility. Mathematical review records are retained in the relevant paper folders.

The [19 October 2026 review](review-2026-10-19.md) records a collection-wide check of the Lean statements and of the unformalized mathematics, with the resulting revisions.

The [SLT comparison review](slt-bounds-comparison-2026-10-19.md) records the primary sources, targeted checks of Claude's reports, and counterexamples to a finite-sample reduction to local asymptotic data. Its reassessment also links the [standard fan-in finite-sample theorem and mathematical review](../works-in-progress/slt-finite-sample/verification/README.md). It is a source and mathematical review, not an extension of the Lean verification.

On 20 October 2026 the collection's attribution was revised. Every paper and note with more than one author lists them in alphabetical order, with a footnote saying so, and names the AI models: ChatGPT-6 Astra wherever OpenAI Codex or ChatGPT was listed; Claude Fable 5 and Opus 5 on the strong-prior, above-mean-field and robust-depth papers and the two depth reports; Claude Opus 5.5 on the standard-scaling NNGP paper and the beyond-parity notes. The footnotes describing the AI authors' contributions were removed. Kaarel Hänni and Dmitry Vaintrob were added as authors of the standard-scaling NNGP paper. Citations within the collection that name these authors were updated to match; citations of external works keep their published author order. All 41 catalogued paper PDFs were rebuilt; only author lines, PDF metadata and author-naming citations changed. The author lists and PDF hashes in the 19 October [authorship record](claude-authorship-2026-10-19.json) are superseded. Copies kept for provenance keep their original attribution: the technical-check supplements of the first depth report and the source copies in `works-in-progress/depth-experiments/`.

The current catalog contains **66 canonical manuscripts**; counts below describe earlier publication snapshots. The [latest Boolean-depth revision record](boolean-depth-structure-2026-10-18.json) covers the unrestricted-depth and critical-depth works in progress: independently reviewed structural theorems, a stronger actual parity learning lower bound, exact source hashes, and clean isolated rebuilds with matching PDF text. These additions are not Lean verified. These were the unconditional bounds available at that snapshot. The later conditional-impossibility result above rules out a universal polynomial guarantee under its circuit-complexity assumption; an exponential depth lower bound for exact tanh is not proved. The [earlier revision record](boolean-depth-progress-2026-10-18.json) preserves the preceding circuit-rate and finite-bottleneck snapshot; counts in older records refer to their publication snapshots.

To check the catalog, PDF checksums, and local Markdown links:

```sh
python verify_collection.py
```

To additionally rebuild all papers in isolated temporary directories:

```sh
python verify_collection.py --rebuild --jobs 4
```

Run these commands from the collection root. They require Python 3, `pdflatex`, `pdfinfo`, and `pdftotext`; no network access is needed. Published PDFs are not changed by the verification script.

The latest full collection rebuild is recorded in [depth-publication-all-builds.json](depth-publication-all-builds.json). The five main papers were subsequently revised editorially and independently rebuilt; their source and PDF hashes are in the [editorial revision record](main-papers-editorial-revision-2026-10-18.json). A subsequent [robust-paper abstract clarification](robust-abstract-revision-2026-10-18.json) records that paper's current hashes and independent rebuild. The earlier `build-results.json` remains the 16 October snapshot.

The non-Gaussian extension was added separately after that full rebuild. Its [review and build record](../side-results/non-gaussian-priors/verification/README.md) includes an isolated source rebuild with identical extracted PDF text and no unresolved references or LaTeX warnings. The collection contains 38 catalogued papers after this addition; the historical counts below describe their respective publication snapshots. At that publication date the extension was not Lean verified; its two main learning statements are now included in the second formalization batch.

The continuous-domain regression paper brings the inventory to 39 papers. Its [review and build record](../side-results/continuous-domains/verification/README.md) covers the tolerance-regression and iterated exact-interpolation statements, independent mathematical reviews, and an isolated source rebuild with matching PDF text. At that publication date it was outside the Lean verification; its two main regression statements are now included in the second formalization batch.

## Publication checks, 16 October 2026

- All 30 papers rebuilt successfully from the copied source dependencies using two LaTeX passes. No unresolved references or LaTeX warnings were reported.
- Extracted PDF text matched the copied canonical PDF for 29 papers. The earlier positive-subcritical standalone draft had unresolved references in its old one-pass PDF. Its unchanged source was rebuilt to resolve those references; a fresh isolated rebuild now matches the published PDF text. No mathematical source edits were made.
- The four main-result descriptions and the complete 30-paper catalog received separate scope reviews against the manuscripts.
- Both computational certificate ZIPs passed archive-integrity checks. Their original scripts and exact data are preserved; the long certificate enumerations were not rerun for this packaging task.
- Local Markdown links, PDF checksums, and the final Git diff were checked before publication.

[Detailed build results](build-results.json) · [Excluded duplicates and external references](excluded-duplicates-and-references.json)

To verify all published file checksums, run `sha256sum -c SHA256SUMS` from the collection root. The checksum file excludes itself and ignored build output.

## Publication checks, 18 October 2026

- The collection now contains **37 papers and notes: five main results, 25 side results, and seven works in progress**. The recent unrestricted-depth research remains a work in progress.
- All 37 papers rebuilt in isolated temporary directories. Extracted PDF text matched the published PDFs, with no unresolved references or LaTeX warnings. [Full build results](depth-publication-all-builds.json) and the [seven-paper addition check](depth-publication-builds.json) record these checks. The robustness paper was subsequently rebuilt after one editorial sentence updated its Lean verification status; a separate isolated rebuild of that revised source again matched the published text. Its [revision record](robust-publication-revision-build.json) preserves the original build evidence and revised source hashes; mathematical content was unchanged.
- The empirical package preserves 473 original files byte for byte. Of these, 470 also match the original full archive manifest; the other three are packaging records generated after the archive contents were selected. All 70 abridged model records match their original records after removal of the two explicitly declared per-example output arrays.
- Five original model checkpoints and full records are included (105, 301, 500, 504, and 505); the other 65 are omitted. The full original archive inventory is preserved, but its ZIP volumes have no public download URL. [Reproduction scope](../works-in-progress/depth-experiments/REPRODUCTION.md) states what can be replayed directly and what must be regenerated.
- The selected exact model-105 counterexample, model-500 all-domain certificate, and model-301 global certificate were replayed from the packaged inputs. Their computational checks are separate from Lean verification. [Representative replay](../works-in-progress/depth-experiments/reproducibility/representative-replay.json) · [Model-301 replay](../works-in-progress/depth-experiments/reproducibility/model301-replay.json).

The Lean theorem gate and its precise scope are recorded separately in [the Lean verification record](../lean/VERIFICATION.md). Package checks do not establish mathematical correctness or extend the scope of a formal theorem.

## Main-paper editorial revision, 18 October 2026

- All five main papers now introduce their learning question, prior, prediction convention, and quantifiers before the technical proof machinery. The robust-prior paper is retitled **A polynomial-depth learning bound for NNBayes on robust networks** and collects variants and detailed experiments in appendices.
- All five published PDFs match independent clean builds of their revised source after text extraction, with no unresolved references. The [revision record](main-papers-editorial-revision-2026-10-18.json) records the current hashes and per-paper checks. Earlier records describe earlier snapshots.
- Every formal theorem, lemma, proposition, corollary, definition, remark, and proof environment in the LaTeX source was compared with the preceding Git version and is unchanged. All non-entry source dependencies are byte-for-byte unchanged. Section numbering changes in the robust and mean-field papers. These comparisons establish the scope of the editorial changes, not a new correctness proof.
- The Lean sources and their verification scope are unchanged; the Lean build was not rerun for this editorial revision.

## Likelihood-based learning note, 19 October 2026

The [SLT-likelihood FAQ](../TECHNICAL-FAQ.md#34-do-the-polynomial-bounds-survive-the-likelihood-based-setup-used-in-singular-learning-theory) and its [supporting proof note](../works-in-progress/slt-likelihood/README.md) distinguish fixed smooth likelihoods from likelihoods scaled together with prior strength. Two agents independently developed and cross-reviewed the positive co-scaled Gaussian theorem and the raw-prior and globally margined XOR obstructions. The parent and a separate agent independently derived the finite-exponent all-width extension from the published teacher-tube and output-cover estimates; a third agent checked that transfer argument. The [positive-result review](../works-in-progress/slt-likelihood/verification/positive-review.md) checks cloning, the energy cover, concentration, and statistical quantifiers; the [counterexample review](../works-in-progress/slt-likelihood/verification/obstructions-review.md) checks the equality case and posterior mixtures.

The [finite-exponent review](../works-in-progress/slt-likelihood/verification/finite-scale-review.md) records that additional check. These are conventional mathematical arguments, not Lean-verified additions to the main results. The existing PDFs, catalog, and Lean sources are unchanged. Local Markdown links, collection checksums, and the final source diff are checked for this publication.

## Targets beyond parity, 19–20 October 2026

The [FAQ question on targets other than parity](../TECHNICAL-FAQ.md#14-for-gamma1-is-the-bad-sample-complexity-specific-to-parity) and its [supporting note](../works-in-progress/beyond-parity/README.md) were added after the collection review. The note's propositions reuse lemmas of the subcritical paper and standard learning-theory bounds. Its [check script](../works-in-progress/beyond-parity/verification/check_beyond_parity.py) recomputes the kernel spectrum, the regression identity, the example table, and a four-bit census exactly, and the [sign-GP package](../works-in-progress/beyond-parity/verification/sign-gp/README.md) contains the exploratory sampler runs. The [review record](../works-in-progress/beyond-parity/verification/review.md) describes the independent AI-agent checks. A [second note](../works-in-progress/beyond-parity/subcube-parity.md), on parity on a subcube and a target that gradient descent can climb, was added on 20 October with its own [verification package](../works-in-progress/beyond-parity/verification/subcube-parity/README.md) and [review record](../works-in-progress/beyond-parity/verification/subcube-parity/review.md). These are conventional arguments and numerical illustrations. They are not Lean verified and have not been reviewed by a human. These additions do not change any PDF, the catalog, or the Lean sources.

## Standard-scaling NNGP parity, 19 October 2026

The [standard-scaling NNGP parity paper](../side-results/standard-nngp-parity/README.md) brings the inventory to 41 papers. It proves superpolynomial parity lower bounds at the usual NNGP scaling and identifies where the subcritical exponential proof breaks; $\exp(\Omega(d))$ remains open there. Its [review record](../side-results/standard-nngp-parity/verification/review.md) describes two rounds of independent AI-agent review. Its numerics folder contains the spectrum and posterior computations. The paper builds from source with two LaTeX passes, without warnings or unresolved references. It is a conventional proof, outside the Lean verification.

## Standard-scaling NNGP parity revision, 20 October 2026

The [standard-scaling NNGP parity paper](../side-results/standard-nngp-parity/README.md) was revised in two ways.

- **New theorem.** It adds a nearly exponential typical-sample lower bound for the learner conditioned only on training signs. The coercivity input of that bound is the Lean theorem `parity_squared_coercivity_probability`.
- **Correction.** The obstruction section is corrected: a conditional "matching upper bound" paragraph had a false premise. It is replaced by a sharper lower bound on the conditioning cost per sample.

The [revision record](../side-results/standard-nngp-parity/verification/review.md#revision-of-20-october-2026) describes the exploration, the independent AI-agent reviews and the supporting files. The revised paper builds from source in two LaTeX passes, without warnings or unresolved references. The inventory is unchanged at 41 papers.

## Improved polynomial bounds, 21 October 2026

Four [supporting papers](../works-in-progress/improved-polynomials/) were added, bringing the catalog to 45 manuscripts. They give a sixth-power width bound under the original robustness restriction for all mean-field-or-stronger scales; a quartic bound under that restriction at stronger scales; a quadratic bound with an additional neuron-averaging restriction; and a shallow-network norm bound with quadratic dependence in a specified coefficient class.

The all-scales theorem retains the original prior support, every-width quantifier, and finite mean-field endpoint. Its proof and final LaTeX sources received an [independent full mathematical audit](../works-in-progress/improved-polynomials/verification/all-scales-review.md), alongside a second derivation of its key reconstruction lemma. The other three papers have their own review records in the same folder. These are AI-agent mathematical reviews, not human peer review or Lean verification.

All four papers were rebuilt from their packaged sources and independently rebuilt in isolated temporary directories. Extracted text matches the published PDFs, without unresolved references or LaTeX warnings. The [publication record](../works-in-progress/improved-polynomials/verification/publication-build.json) records source and PDF hashes, exact build checks, and review scope. Earlier audit hashes identify their research snapshots; final attribution and PDF metadata changes are recorded separately in this publication record.

The FAQ's polynomial section, collection index, catalog, and file checksums were updated. Existing paper PDFs and Lean source files are unchanged. The degree-46 conventional envelope and sixth-power circuit-width rate do not replace the degree-10974 budget checked by the existing Lean proof. No Lean rebuild is claimed for this addition.

## Author-label correction, 22 October 2026

The four improved-polynomial manuscripts now use one **ChatGPT-6 Astra** author credit, following the collection's attribution convention. The duplicate **OpenAI Codex** entry was removed from the three affected author lists; the shallow paper's OpenAI credit was renamed and placed in alphabetical order. PDF metadata, the catalog, and overview descriptions were updated consistently. This corrects an attribution mistake, not a change in mathematical contributions.

All four PDFs were rebuilt and their sources checked to confirm that only author lines and PDF metadata changed. The [attribution correction record](../works-in-progress/improved-polynomials/verification/attribution-correction-2026-10-22.json) gives current hashes and isolated rebuild checks. The earlier publication record remains a historical snapshot and links to this correction. Mathematical content and Lean sources are unchanged.


## Neuron-merging naturality, 21 October 2026

The [signed-merging paper and empirical study](../works-in-progress/improved-polynomials/neuron-merging-naturality/) extend the quadratic theorem to signed, unequal populations, an output-normalized count budget, and a local sufficient certificate. The source received an independent mathematical audit, including the positive-mass Boolean implementation and every-width quantifiers. This is the 46th catalogued manuscript and is not Lean verified.

The empirical package retains every outcome from 40 fresh gradient-trained networks, the full search records, and three exhaustive interval certificates. Automatic identity-partition cases and failed searches are reported separately. An independent replay checks the included saved weights and witnesses. The [publication record](../works-in-progress/improved-polynomials/neuron-merging-naturality/verification/publication-build.json) records source/PDF hashes, isolated rebuilding, and replay scope.


## Cumulative mistakes, converses, and ReLU, 21 October 2026

Three supporting manuscripts bring the catalog to 49: [total online mistakes](../works-in-progress/online-mistakes/upper/), [circuit-induction converses](../works-in-progress/online-mistakes/circuit-converse/), and [ReLU learning](../works-in-progress/relu-learning/). A separate [neural converse note](../works-in-progress/online-mistakes/nn-converse.md) distinguishes a weak original-support converse from an output-capped polynomial variant, both in the strong-prior-then-width limit.

The new statistical proofs, exact circuit priors and repair costs, ReLU norm bound and Gaussian neighborhood argument, and neural singleton construction underwent independent AI-agent mathematical reviews. Each paper includes its audit and an isolated rebuild record. Sources reproduce the published PDF text; no unresolved references remain. These are conventional mathematical checks, not Lean verification. The five main formalized statements are unchanged.


## Unbounded activations and polynomial depth, 22 October 2026

Three supporting manuscripts bring the catalog to 52:

- [The unified activation theorem](../works-in-progress/unbounded-activations/) proves one fixed-depth polynomial sample bound simultaneously over every learner width above bounded-weight teacher complexity and every Gaussian scale at least as strong as mean field. It covers every fixed globally Lipschitz activation vanishing at zero, including deep ReLU and GELU at the mean-field endpoint. The original global-margin and exact-label conventions are retained. The generic proof counts auxiliary networks with neuron-specific activations; it does not claim a same-activation circuit converse.
- [Polynomial-depth ReLU/GELU learning](../works-in-progress/relu-gelu-polynomial-depth/) gives a quadratic-width bound up to logarithms, and an explicit literal quadratic envelope, under unsigned neuron-merging stability. All widths above compiled teacher width and all scales at least as strong as mean field are covered. Typical trained-network applicability is not established.
- [The polynomial-depth neural converse](../works-in-progress/online-mistakes/depth-polynomial-converse/) converts complete-domain total mistakes into bounded-weight tanh complexity, with fourth-power mistake dependence and polynomial depth. It assumes an output cap and an internal-amplification certificate, and takes the strong-prior limit before the width limit. It is not a fixed-width converse.

Several independent AI agents reviewed the mathematical arguments. The unified endpoint review found and corrected a covariance-diagonal bookkeeping issue by using layer-specific bounds; the final auxiliary atom statement also makes nonnegative coefficients explicit. The [integrated review](../works-in-progress/unbounded-activations/verification/meanfield-review.md) distinguishes the final theorem from earlier proof snapshots. A [fresh independent audit](../works-in-progress/unbounded-activations/verification/fresh-final-review.md), conducted without the other review reports, read all six final source files and found no defect requiring a mathematical correction or weaker theorem. It records the exact source hashes and checks the all-width, all-scale quantifiers. Each other paper has its own review record. These are AI mathematical reviews, not human peer review or Lean verification.

All three PDFs were independently rebuilt from their packaged sources in isolated temporary directories. Their extracted text matches the published files, with no unresolved references or LaTeX warnings. Per-paper `verification/publication-build.json` records exact source and PDF hashes. The collection catalog, local links, checksums, FAQ, and indexes were checked. Existing PDFs and all Lean sources are unchanged.

## Alternative prior restrictions and online FAQ, 22 October 2026

The FAQ now has separate prominent questions on total online mistakes and their converses, and an expanded activation explanation. The old combined-section anchor is preserved. The new [alternative-restriction notes](../works-in-progress/robustness-alternatives/) give three separately scoped results: internal-noise stability plus bounded noisy activity for ReLU/GELU at strong prior and `gamma >= 2`; a declared path-norm cap, with a quadratic ReLU formula guarantee; and severe-dropout stability for tanh at strong prior and `gamma >= 2`. These are Markdown research notes, so the PDF inventory remains 52.

Each learning argument received an independent AI-agent mathematical audit, and the parent researcher checked the derivations. The robust Boolean witnesses and operator-norm obstructions were checked separately. The [publication record](../works-in-progress/robustness-alternatives/verification/publication-check.json) maps reviewed research files to the GitHub-formatted copies and records reproduction of a twelve-checkpoint dropout diagnostic. The numerical replay uses the already published model weights; it is a small Monte Carlo study, not an exact robustness certificate or evidence that the theorem's conditions hold generally after training.

These additions are not Lean verified and do not change any existing PDF or formal theorem. The FAQ, relative links, file inventory, and collection checksums were checked before publication.

## Second formalized batch, 23 October 2026

Ten additional papers now have Lean proofs of their main learning statements, with the [exact scope and exclusions](../lean/review/BatchTwo-coverage.md) and [verification record](../lean/VERIFICATION.md) linked from the collection index. The original five main results retain their own section. The ten PDF sources were updated only to describe that formalization status; their mathematical statements are unchanged. [Direct PDF builds](second-batch-pdf-builds-2026-10-23.json) and [isolated PDF rebuilds](second-batch-isolated-pdf-builds-2026-10-23.json) pass for all ten, with matching extracted text and no unresolved references.

## Boolean depth continuation, 26 October 2026

The collection now contains 65 canonical manuscripts plus separately identified companions. The original unrestricted Boolean-depth question remains open. The new [structural-circuit paper](../works-in-progress/structural-boolean-depth/) gives positive bounds for narrow cuts, small treewidth, excluded-minor graphs, and formulas with bounded Strahler rank. The updated [finite-width paper](../works-in-progress/finite-width-posterior-bounds/) adds a Boolean-circuit mean-shift bound linear in learner width at mean-field scaling; it retains width dependence. The [positive-window paper](../works-in-progress/nearcritical-positive-window/) proves learning just above the critical prefactor for Fourier-controlled targets, and the [logistic/softplus package](../works-in-progress/shallow-logistic-softplus/) treats shallow targets in cold and fixed-above-mean-field regimes.

The [barrier paper](../works-in-progress/boolean-depth-barriers/) now permits polynomial logarithms of teacher weight magnitudes in its circuit-separation implication. The [arithmetic-formula package](../works-in-progress/tanh-arithmetic-formulas/) adds a Gaussian quadratic-occupation companion and research notes on general critical paths. Its positive feature calculations and its examples blocking particular proof shortcuts do not establish the missing unrestricted posterior theorem.

These additions have conventional mathematical proofs and independent AI-agent audits, with imported results and remaining gaps identified in each package. **None of the new complete papers is Lean verified.** The two existing formalized main-result sections and their Lean sources are unchanged. Publication checks cover all 65 catalog PDF hashes and page counts, package checksum inventories, and local links in the collection README and FAQ. The curated PDFs have clean builds; package records identify the exact source snapshots and review coverage.

## Conditional polynomial-learning obstruction, 26 October 2026

The [new nine-page paper](../works-in-progress/conditional-nonpolynomial-learning/) makes the conditional negative result central: assuming nonuniform P/poly differs from TC¹, the original Gaussian tanh learner has no universal width-independent polynomial sample bound jointly in input dimension, teacher width and depth. The collection now has 66 canonical manuscripts.

The exact concrete main statement and the complete finite/complexity reduction have been formalized in 16 new Lean modules, including actual Gaussian conditioning, constructive boosting, NAND-to-tanh teachers, threshold-to-NAND simulation, circuit composition and polynomial-family bookkeeping. The final checked theorem explicitly assumes the analytic posterior-circuit ceiling. **That analytic ceiling has no closed Lean proof, so the complete main theorem is not formally verified.** It is not added to either fully formalized main-result section. The [verification record](../works-in-progress/conditional-nonpolynomial-learning/verification/) records the successful source rebuild, exact statement audit, mathematical audit, and remaining dependency.
