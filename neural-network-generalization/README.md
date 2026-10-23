# Bayesian neural network generalization

Papers and notes by ChatGPT-6 Astra, Claude (Fable 5, Opus 5, and Opus 5.5), Kaarel Hänni, and Dmitry Vaintrob. Authors are listed in alphabetical order, here and on every paper; each paper names its own authors. Public research snapshot, updated 23 October 2026.

**Start here:** [original main results](#main-results) · [second batch of formalized main results](#second-batch-of-formalized-main-results) · [technical FAQ: assumptions, interpretation, and open problems](TECHNICAL-FAQ.md) · [Lean verification](lean/VERIFICATION.md) · [improved polynomial bounds](#improved-polynomial-bounds) · [recent depth research](#recent-depth-research)

The original five main results retain their own section. A second section presents ten additional papers whose main statements now have Lean proofs. The remaining papers are listed as side results, earlier treatments, or works in progress. “Side result” does not mean unproved: several contain complete theorems, but they are not the main presentation of this project. These are research drafts, not externally peer-reviewed publications; the FAQ distinguishes proved statements from plausible extensions and open questions.

**Review status.** Most of this material has not yet been carefully reviewed by a human. The checks so far are the Lean proofs of the original five learning theorems and the ten-paper second batch, with the scope described [below](#lean-verification), and AI reviews. These include the audit records in the paper folders and a collection-wide review by Claude on 19 October 2026, recorded in [verification/review-2026-10-19.md](verification/review-2026-10-19.md). That review found and repaired several local errors but found no false theorem. It does not replace expert human review, and anything added or changed after the review was not part of it.

Every paper has a PDF, editable LaTeX source, and a build script. The collection contains 52 PDF manuscripts, additional research notes, experimental code, and selected exact certificates. The [catalog](catalog.json) identifies the canonical manuscripts; older treatments retain their historical scope and open-status remarks.

## Lean verification

The original five main learning statements and the main statements of the ten papers in the second batch have closed Lean proofs. [Second-batch coverage and exclusions](lean/review/BatchTwo-coverage.md) · [Entry point](lean/NeuralGeneralization/BatchTwoMain.lean) · [Axiom audit](lean/NeuralGeneralization/BatchTwoAudit.lean). The earlier four concern the original Gaussian model and its all-input margin convention; the stated strict `>2/3` confidence guarantees are part of the mean-field, subcritical, and robust statements, and are closed corollaries of the strong-prior and gamma > 1 statements in [CheckConfidence.lean](lean/CheckConfidence.lean). The subcritical theorem covers **all gamma < 1, including gamma = 0 and gamma < 0**. A polynomial version of the parity-network appendix is also formalized, with bounded-weight complexity at most `32*(d+1)^2` at every depth; the appendix's sharper weights are not formalized.

[Lean project and instructions](lean/) · [Exact statements](lean/NeuralGeneralization/Statements.lean) · [Verification record](lean/VERIFICATION.md) · [Coverage and auxiliary exclusions](lean/review/formal-coverage-inventory.txt)

The polynomial-depth generalization theorem is proved for its actual robustness-restricted Gaussian posterior, with one sample event uniform over every eligible width and variance. Its [exact statement](lean/NeuralGeneralization/RobustStatements.lean) and [closed proof](lean/NeuralGeneralization/RobustMain.lean) are included. The verification record identifies the checked scope and independent source rebuild. Some formal proofs use different sufficient estimates from the papers. Lean coverage does not extend automatically to every appendix, sharp constant, or side paper.

## Main results

### 1. The strong-prior limit argument

[Paper (PDF)](main-results/strong-prior-generalization/paper.pdf) · [Source and build instructions](main-results/strong-prior-generalization/)

**Width-independent generalization in the strong-prior limit of Bayesian neural networks.** A writeup of the main proof thread in [Dmitry and Kaarel's slides](https://kaarelh.github.io/ai/nnbayes-generalization.pdf), including the compression and circuit arguments. At fixed depth, the sample bound is polynomial in input dimension, target complexity, and the accuracy parameters, independently of learner width $N\ge C_L(f)$.

This paper takes the prior variance to zero at each fixed width. It does not claim a variance threshold uniform over all widths. The [separate appendix audit](side-results/strong-prior-appendix-audit/paper.pdf) records the treatment of each slide appendix and the mistakes and repairs found there.

### 2. $\gamma>1$: every width above target complexity

[Paper (PDF)](main-results/gamma-above-one/paper.pdf) · [Source and build instructions](main-results/gamma-above-one/)

**Width-uniform Bayesian generalization above the mean-field scaling.** For every fixed depth and every fixed $\gamma>1$, proves polynomial sample complexity at the specified nonzero Gaussian variance for **every width $`N\ge C_L(f)`$**. The result allows bounded 1-Lipschitz hidden activations and arbitrary input distributions. The polynomial may depend on depth and $\gamma$; there is no uniform claim as $\gamma$ approaches one.

### 3. $\gamma=1$: every width above target complexity

[Paper (PDF)](main-results/meanfield-all-width/paper.pdf) · [Source and build instructions](main-results/meanfield-all-width/)

**Mean-field Bayesian circuit learning at every width above target complexity.** A standalone finite-width proof for fixed-depth tanh networks, with polynomial sample complexity for **every width $`N\ge C_L(f)`$** and arbitrary input distributions. No infinite-width limit or extra minimum-width hypothesis is needed. This resolves the all-width question left open in the earlier mean-field papers.

### 4. $\gamma<1$: an exponential sample-complexity lower bound

[Paper (PDF)](main-results/subcritical-exponential/paper.pdf) · [Source and build instructions](main-results/subcritical-exponential/)

**Exponential parity sample complexity below the mean-field scaling.** For every fixed $\gamma<1$ and fixed depth, proves an $\exp(\Omega(k))$ sample lower bound for full $`k`$-bit parity under uniform IID training inputs. Here the ambient dimension is $d=k$.

More precisely, there are $c>0$ and $k_0$ such that, for every $k\ge k_0$ and each specified integer $0\le n\le e^{ck}$, with probability at least $3/4$ over the training sample, the limiting fraction of test inputs whose correct label has posterior probability at most $2/3$ is at least $1/16$ (in the liminf sense). Width tends to infinity first, with dimension, sample, margin, depth, and $\gamma$ fixed. The paper does not give a quantitative minimum width or a joint-limit theorem. The guarantee is for each specified sample size, not a simultaneous statement about all prefixes of one sample sequence.

This is the completed full-parity exponential theorem. The stronger fixed-depth sparse-parity target $\exp(\Omega(k\log(ed/k)))$ in the positive subcritical regime is still open; the partial results below do not replace that target with a solved claim.

### 5. Robust priors: polynomial dependence on depth

[Paper (PDF)](main-results/robust-polynomial-depth/paper.pdf) · [Source and build instructions](main-results/robust-polynomial-depth/) · [Robustness FAQ](TECHNICAL-FAQ.md#15-what-robustness-condition-gives-polynomial-depth-dependence)

**A polynomial-depth learning bound for NNBayes on robust networks.** Restrict the Gaussian prior to networks whose clipped predictions survive a calibrated ball of simultaneous internal activation and output perturbations. For layered Boolean-circuit targets of width $C$, one universal polynomial bounds sample complexity jointly in input dimension, depth, circuit width, robustness calibration, and statistical parameters, simultaneously at **every width $N\ge C$ and every $`\gamma\ge1`$**.

The learner conditions on signed training output above $1/2$ and controls posterior test-margin error at $1/4$, hence sign error and confidence failure. The main theorem needs no all-input clean-output margin; the manuscript also treats an optional extra conditioning variant, outside the original main-result-5 Lean statement and now covered by the second batch. The comparator is a layered Boolean circuit with constant wires and compilation overhead counted; this is not an unconditional polynomial-depth theorem for every small analog neural circuit.

A [new supporting paper](works-in-progress/improved-polynomials/original-support-all-scales/paper.pdf) sharpens the sufficient bound to $O(C^6\log^{13}(2+C))$ at fixed remaining parameters under this **same restriction**, for every $\gamma\ge1$ and every $N\ge C$. It also improves the conservative joint polynomial envelope to degree 46. These sharper exponents are Lean verified in the second batch; its separate printed numerical allocation is outside the checked scope.

The [experiments](works-in-progress/depth-experiments/) include genuine trained-network certificates and counterexamples. They support studying the condition, but do not establish it for arbitrary gradient-descent-trained networks or validate Bayesian posterior sample complexity empirically.

## Second batch of formalized main results

These ten papers were previously unformalized. Their main learning statements now have Lean proofs, with the original models and quantifier orders. [Coverage, exact theorem names and exclusions](lean/review/BatchTwo-coverage.md) · [Lean entry point](lean/NeuralGeneralization/BatchTwoMain.lean) · [Verification record](lean/VERIFICATION.md). Verification applies to the listed statements; some ancillary claims and numerical allocations remain outside its scope.

| Paper | Main result |
|---|---|
| [1. ReLU, GELU, and general Lipschitz activations](works-in-progress/unbounded-activations/paper.pdf) | Fixed-depth polynomial learning for every zero-at-zero Lipschitz activation, at every eligible width and every mean-field-or-stronger scale simultaneously. Includes the exact strong-prior capacity bound. |
| [2. Polynomial-depth ReLU/GELU learning](works-in-progress/relu-gelu-polynomial-depth/paper.pdf) | Under population-merging stability, quadratic Boolean teacher-width dependence up to logarithms, polynomial depth, and every `γ≥1`. |
| [3. Improved bounds with the original robust support](works-in-progress/improved-polynomials/original-support-all-scales/paper.pdf) | The same original restriction gives `C⁶ log¹³(C+2)` and a degree-46 joint envelope, simultaneously for all widths and scales. |
| [4. One hidden layer](works-in-progress/improved-polynomials/shallow/paper.pdf) | Sharper sample bounds in weighted teacher norm, including quadratic or quartic teacher-width consequences under the stated coefficient conventions. |
| [5. Polynomially many total mistakes](works-in-progress/online-mistakes/upper/paper.pdf) | Expected and high-probability bounds over the full learning process in the three original good regimes, for uniform IID inputs or a random permutation. |
| [6. Circuit-induction converses](works-in-progress/online-mistakes/circuit-converse/paper.pdf) | Few mistakes force a small NAND circuit for Occam induction and two specified Bayesian circuit priors, including infinite IID learning. |
| [7. Polynomial-depth neural converse](works-in-progress/online-mistakes/depth-polynomial-converse/paper.pdf) | Under an output cap and internal-gain restriction, few total mistakes imply a small same-depth tanh network, in the strong-prior-then-width limit. |
| [8. Non-Gaussian weight priors](side-results/non-gaussian-priors/paper.pdf) | The main fixed-depth learning upper bounds extend to independent smooth uniformly log-concave coordinates, at every width above complexity. |
| [9. Continuous input domains](side-results/continuous-domains/paper.pdf) | Real-valued teacher regression on compact unit-ball domains, at every eligible width, in the strong-prior limit and every finite `γ≥1` regime. |
| [10. Exponential depth dependence in regression](works-in-progress/continuous-depth-lower-bound/paper.pdf) | A fixed nonatomic unit-circle law and bounded width-three teachers require exponentially many samples in depth. Covers strong priors, finite `γ>1` with polynomial sufficient width, and width-first `γ=1`. |

The original five results above retain their numbering and presentation. The directory names `side-results` and `works-in-progress` are preserved so existing links continue to work.

## Shared conventions

In the four earlier main papers, the learner conditions the Gaussian parameter prior on a strict absolute output margin **at every input of the Boolean cube before observing training data**, then conditions on exact noiseless labels. Main result 5 uses the different, explicit robustness-support and training-margin conventions described above. These are information-theoretic results about the exact posterior; efficient posterior computation is not asserted.

At fixed depth, $C_L(f)$ is the bounded-weight network complexity defined in the papers: the smallest eligible width $C$ with weights bounded by $C$. Circuit simulations are proved where used; arbitrary circuit size is not silently identified with fixed-depth network complexity.

For prediction, the success criterion is correct-label posterior probability **strictly greater than $`2/3`$**. The first papers phrase their main bounds in posterior average error; the confidence guarantee follows by rescaling the accuracy parameter by three. The later papers state the confidence convention explicitly.

## Side results

These results develop the model, strengthen special cases, or analyze ingredients of the open sparse-parity problem. Each row links to the PDF and to its source folder.

| Paper | Scope |
|---|---|
| [Width-independent Bayesian neural-network learning on continuous input domains](side-results/continuous-domains/paper.pdf) · [source and reviews](side-results/continuous-domains/) | Real-valued regression on compact domains, including the full sphere, at every width above teacher width. Strong-prior and all finite $\gamma\ge1$ regimes; positive training tolerance and a larger test tolerance. Includes exact interpolation in an iterated strong-prior limit and classification with a teacher margin on the data support. The main regression statements are Lean verified; ancillary limits and classification are outside that certification. |
| [Bayesian neural-network learning with non-Gaussian weight priors](side-results/non-gaussian-priors/paper.pdf) · [source and reviews](side-results/non-gaussian-priors/) | Extends main results 1–3 to independent even, variance-one weight densities whose negative log has curvature bounded above and below by positive constants, at the original layer scales and every width above target complexity. Includes polynomial prior-complexity comparison and a broader strong-prior extension. The two main learning statements are Lean verified; broader extensions are outside that certification. |
| [Small circuits under Gaussian-process classification: what sample complexity follows from the actual posterior?](side-results/nngp-sample-complexity/paper.pdf) · [source](side-results/nngp-sample-complexity/) | NNGP regression, classification, and confidence are distinguished; a specified deep tanh family has an exponential confidence sample requirement. |
| [Parity under standard-scaling neural-network Gaussian processes: superpolynomial and nearly exponential sample lower bounds at fixed depth](side-results/standard-nngp-parity/paper.pdf) · [source and reviews](side-results/standard-nngp-parity/) | The usual NNGP scaling, exponent tuple $(0,1,\ldots,1,1)$, at fixed depth. With the global margin and for large $d$, tanh networks need more than $\exp(\frac1{20}\sqrt d\log d)$ uniform IID samples of full parity. Conditioned only on training signs, every bounded continuous nonconstant activation, depth and gain needs at least about $d^{\sqrt d/10}$ samples on every training set. For tanh, typical samples need more than $\exp(10^{-3}d\log\log d/\log d)$, beyond an explicit but astronomically large dimension. $\exp(\Omega(d))$ is open; the paper proves that one step of the subcritical proof fails here. Independent AI-agent checks; the coercivity input of the typical-sample bound is Lean verified, the rest is not. |
| [The fixed-kernel regime of a margin-conditioned Bayesian neural-network prior](side-results/gamma-below-one/paper.pdf) · [source](side-results/gamma-below-one/) | Kernel freezing and the three width-first limits for positive, zero, and negative gamma. Its original sample-bound discussion predates the main exponential theorem. |
| [Small circuits can have exponentially large prior complexity below the mean-field scaling](side-results/subcritical-circuit-prior/paper.pdf) · [source](side-results/subcritical-circuit-prior/) | Small circuits can have exponentially large normalized prior complexity. A prior-mass separation alone is not a sample lower bound. |
| [Gaussian conditioning below the mean-field scaling: a sharp fluctuation threshold](side-results/subcritical-gaussian-conditioning/paper.pdf) · [source](side-results/subcritical-gaussian-conditioning/) | Relative Gaussian conditioning below gamma=1/2, and a tanh counterexample at and above that threshold; leading rates and posterior probabilities are distinguished. |
| [Finite-width circuit learning below mean-field scaling](side-results/finite-width-subcritical/paper.pdf) · [source](side-results/finite-width-subcritical/) | A width-dependent finite-width sample upper bound. Polynomial widths can learn with polynomial samples, consistently with the width-first lower bounds. |
| [Global Margin Conditioning Amplifies a Gaussian Posterior Mean](side-results/gamma-zero-mean-energy/paper.pdf) · [source](side-results/gamma-zero-mean-energy/) | A counterexample, at depth $L\ge3$, to a proposed dimension-free posterior mean-energy estimate after global margin conditioning. |
| [Global-margin conditioning at the Gaussian endpoint: normalization, training loss, and output amplitude](side-results/zero-gamma-conditioning-note/paper.pdf) · [source](side-results/zero-gamma-conditioning-note/) | Gaussian endpoint conditioning-cost, latent-loss, and actual-output amplitude estimates. |
| [Sparse parity under globally conditioned neural priors](side-results/sparse-parity/paper.pdf) · [source](side-results/sparse-parity/) | Natural sparse-parity scale for gamma<0, with a small universal failure fraction at specified sample sizes; one-coordinate parity learns with O(log d) samples for 0<gamma<1. |
| [Exponential sample lower bounds for sparse parity under a globally separated neural prior](side-results/growing-sparse-positive/paper.pdf) · [source](side-results/growing-sparse-positive/) | An exponential-in-k lower bound and further dimension dependence for growing sparse parity in 0<gamma<1. |
| [Growing sparse parity under a globally separated neural prior](side-results/intermediate-parity/paper.pdf) · [source](side-results/intermediate-parity/) | The strongest current general fixed-depth sparse refinement for $0<\gamma<1$ and growing $k\le d^{1-\eta}$, at specified sample sizes. It does not assert failure at every smaller sample size. |
| [Natural sparse-parity lower bounds at slowly growing depth](side-results/growing-depth-parity/paper.pdf) · [source](side-results/growing-depth-parity/) | The natural sparse scale when depth grows as log₂ log log d + O(1) and $d^{\eta_1}\le k\le d^{1-\eta_2}$, at specified sample sizes. The fixed-depth target remains open. |
| [Symmetric parity predictors require large amplitudes: an exponential lower bound and a consequence for margin repairs](side-results/symmetric-parity-amplitudes/paper.pdf) · [source](side-results/symmetric-parity-amplitudes/) | Amplitude and repair-cost obstructions under explicit symmetric or block-symmetric assumptions. |
| [Homogeneous parity approximants have a strict local repair cost](side-results/homogeneous-cell-calibration/paper.pdf) · [source](side-results/homogeneous-cell-calibration/) | Repair-cost calibration for homogeneous, weighted homogeneous, affine, and two-level heads in the stated fixed-background model. |
| [Certified margin-repair bounds for structured parity predictors: cubic and quartic heads, exact certificates, and parity-block lifts](side-results/structured-parity-repair-certificates/paper.pdf) · [source](side-results/structured-parity-repair-certificates/) | Exact rational certificates for structured cubic and quartic families, including 49,149 sign-cone orbits. Reproduction data and verifiers included. |
| [Learning parity from selected examples under a globally separated neural kernel](side-results/selected-examples-parity/paper.pdf) · [source](side-results/selected-examples-parity/) | Selected $d^{O_\delta(\sqrt{k})}$ examples can teach sufficiently large odd $k$ when $d\ge(C_Lk)^{C_Lk}$. This is not uniform IID training. |
| [Degree and square-root energy on the Boolean cube: equivalent positive estimates and a signed obstruction](side-results/fisher-degree-reductions/paper.pdf) · [source](side-results/fisher-degree-reductions/) | Equivalences between positive energy bounds and sums-of-squares approximation; a signed obstruction. The positive inequality itself remains open. |
| [Parity, polynomial degree, and contact-weighted error costs](side-results/parity-contact-calibration/paper.pdf) · [source](side-results/parity-contact-calibration/) | A degree obstruction under an explicit contact-cost hypothesis. Establishing that hypothesis for a learner is a separate step. |

## Earlier treatments and works in progress

These manuscripts are retained because their proofs or scope can still be useful. The current main papers above are the recommended starting points. Statements in older manuscripts that a later result is open describe the state of the work when that manuscript was written.

| Paper | Scope |
|---|---|
| [Finite-sample learning under standard fan-in Gaussian priors](works-in-progress/slt-finite-sample/README.md) (Markdown research note) | Explicit variational bounds require samples linear in learner width and polynomial in depth and bounded-weight teacher resources. Final-posterior confidence for clean outputs under a fixed Gaussian likelihood; averaged predictive KL for Gaussian-noisy data. Can be useful below parameter count, but is not width independent or Lean verified. |
| [Smooth likelihoods, strong priors, and polynomial learning](works-in-progress/slt-likelihood/README.md) (Markdown research note) | Fixed smooth likelihoods can invalidate the hard-conditioning guarantees, including an explicit globally margined XOR counterexample. Co-scaling Gaussian observation variance with prior variance gives ordinary-Bayes polynomial learning at fixed depth and every width above teacher width, in the strong-prior limit and at every fixed finite exponent $\gamma\ge1$. Independent AI-agent checks; not Lean verified. |
| [Layerwise scaling and collapsed-layer priors](works-in-progress/scaling-tuples/README.md) (Markdown research note) | For a one-hidden-layer Gaussian prior with input exponent $a>b>1$ and readout exponent $b$, proves a hierarchy by odd-rounded polynomial threshold degree. Gives conjectured learning regions for other tuples. The prior-ordering theorem is not a sample-complexity classification; not Lean verified. |
| [Which targets are hard for the subcritical learners?](works-in-progress/beyond-parity/README.md) (Markdown research note) | Kernel regression's expected squared error depends only on the target's Fourier weight profile, so high-degree weight is costly even for leap-one targets that suit SGD. For the $\gamma<1$ sign posteriors, lower bounds hold for every target in terms of its distance from low-degree threshold functions. At $\gamma<0$ a fixed junta of threshold degree $t\ge2$ needs at least about $d^{t^*}$ samples on every training set, including leap-one targets. At $\gamma\ge0$ there are Gibbs-error analogues for typical samples. Halfspaces on a fixed set of coordinates, and majority of all $d$ bits, are learned at polynomial cost. $\mathrm{Leap}\le$ threshold degree. Short arguments with independent AI-agent checks; not Lean verified or human reviewed. |
| [Parity on a subcube: a target gradient descent can climb](works-in-progress/beyond-parity/subcube-parity.md) (Markdown research note) | Extends the subcritical paper's exponential lower bound to every target that equals a parity of linearly many bits on a subcube of constant codimension, whatever its other values. This covers a target $`f^*`$ that is a sign-staircase on half of the cube and full parity on the other half. A layerwise greedy learner provably learns $`f^*`$ from polynomially many samples. Adam on a two-head network learned it at every dimension tested (numerical, $d\le35$, a range that cannot separate polynomial from exponential growth); a plain fully connected network did not at $d=23$, 27, or 31. For a two-head Bayesian network the $\gamma<1$ limit splits over the halves, so its parity half fails as for parity. Short arguments with independent AI-agent checks; not Lean verified or human reviewed. |
| [Bayesian circuit learning at mean-field scaling: a variational principle and width-independent generalization](side-results/gamma-ge1-endpoint/paper.pdf) · [source](side-results/gamma-ge1-endpoint/) | Earlier mean-field variational proof, with an unquantified sufficiently-large-width threshold. Its all-width question is resolved by main result 3. |
| [An explicit sufficient width for mean-field Bayesian circuit learning](side-results/meanfield-quantified-width/paper.pdf) · [source](side-results/meanfield-quantified-width/) | Earlier quantified sufficient-width theorem. Main result 3 removes the extra width threshold. |
| [Superpolynomial sample lower bounds for globally margin-conditioned Bayesian neural networks below the mean-field scaling](side-results/subcritical-sample-complexity/paper.pdf) · [source](side-results/subcritical-sample-complexity/) | Earlier superpolynomial lower bound, valid for every training set of the indicated size. The stronger IID exponential theorem is main result 4. |
| [Superpolynomial sample lower bounds below the mean-field scaling (earlier positive-gamma version)](works-in-progress/positive-subcritical-sample-complexity/paper.pdf) · [source](works-in-progress/positive-subcritical-sample-complexity/) | Superseded standalone draft for 0<gamma<1. The unified and later exponential papers are the preferred statements. |
| [Failure of Bayesian Gaussian process classification at exponentially large sample sizes](side-results/gaussian-exponential-schedule/paper.pdf) · [source](side-results/gaussian-exponential-schedule/) | Earlier gamma<0 theorem at an exponential sample schedule; later papers extend the range of sample sizes. |
| [Exponential sample lower bounds for Bayesian Gaussian process classification](side-results/gaussian-exponential-lower-bound/paper.pdf) · [source](side-results/gaussian-exponential-lower-bound/) | Standalone gamma<0 full-parity proof, subsequently included and strengthened in the subcritical and sparse-parity papers. |
| [A certified margin-repair bound for cubic parity predictors: one arbitrary bit, twenty-six symmetric bits, and parity-block lifts](side-results/cubic-parity-repair-certificate/paper.pdf) · [source](side-results/cubic-parity-repair-certificate/) | Earlier cubic certificate, extended by the structured cubic-and-quartic paper above. Reproduction archive included. |

The principal unfinished target is the fixed-depth natural sparse-parity lower bound for $0<\gamma<1$, with uniform IID samples and the actual posterior-confidence criterion. Selected-example results, symmetry-restricted certificates, and analytic reductions are side results, not a resolution of that target.

## Improved polynomial bounds

[Five papers, sources, and independent reviews](works-in-progress/improved-polynomials/) · [FAQ: explicit polynomials](TECHNICAL-FAQ.md#23-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close)

These supporting papers improve the polynomial dependence on target width. Their proofs have independent AI-agent mathematical reviews. The original-support/all-scales and shallow papers are included in the second formalization batch; the other papers remain outside that certification.

| Paper | Sample bound and scope |
|---|---|
| [Original robust support, all mean-field-or-stronger scales](works-in-progress/improved-polynomials/original-support-all-scales/paper.pdf) | $O(C^6\log^{13}(2+C))$ at fixed remaining parameters, simultaneously for every $N\ge C$ and every $\gamma\ge1$. No extra restriction. Joint polynomial envelope of degree 46. |
| [Original robust support, stronger scales](works-in-progress/improved-polynomials/original-support/paper.pdf) | $O(C^4\log^9(2+C))$ at fixed remaining parameters, for every $N\ge C$ at $\gamma\ge2$ and in the strong-prior limit. |
| [Stable neuron populations](works-in-progress/improved-polynomials/neuron-averaging/paper.pdf) | Quadratic Boolean teacher-width dependence and polynomial depth dependence at every $\gamma\ge1$, with an **additional neuron-averaging restriction**. Its empirical relevance remains unestablished. |
| [Symmetry-invariant neuron merging](works-in-progress/improved-polynomials/neuron-merging-naturality/) | Quadratic width and polynomial depth at every `gamma >= 1`, allowing signed, unequal populations and a scale-normalized count budget. Boolean implementations have positive prior mass; trained-network study includes exhaustive interval certificates. |
| [One hidden layer](works-in-progress/improved-polynomials/shallow/paper.pdf) | A bound in the teacher's weighted squared norm, at every $\gamma\ge1$, including for the raw Gaussian prior. Quadratic width dependence with bounded readout coefficients; the full original coefficient convention gives a quartic sufficient bound. |

Quadratic dependence under the original robust restriction throughout all $\gamma\ge1$ remains open. The original formal theorem and its degree-10974 sufficient budget are unchanged.

[Alternative-restriction research notes](works-in-progress/robustness-alternatives/) compare numerical stability, path norms, and severe dropout with neuron merging. Internal-noise stability plus bounded noisy activity gives polynomial-depth ReLU/GELU learning with roughly sixth-power teacher width in the strong-prior limit and at every $\gamma\ge2$. A severe-dropout condition gives a quadratic-width tanh result in those regimes. A hard ReLU path-norm cap gives a quadratic-budget bound at every Gaussian scale, including a quadratic-width guarantee for Boolean formulas. Each alternative has a different scope; none establishes the desired natural quadratic-width restriction for all small circuits throughout $\gamma\ge1$.

## Total mistakes, unbounded activations, and depth

The [online-learning papers and neural converses](works-in-progress/online-mistakes/) study the full learning process. The [unified activation theorem](works-in-progress/unbounded-activations/) covers ReLU, GELU, and every fixed Lipschitz activation vanishing at zero at all mean-field-or-stronger scales. Separate restricted-prior results give polynomial depth dependence. The unified activation, ReLU/GELU polynomial-depth, online upper-bound, circuit-converse and polynomial-depth neural-converse papers are included in the second formalization batch, with the exclusions recorded there.

| Result | Scope |
|---|---|
| [Polynomially many total mistakes](works-in-progress/online-mistakes/upper/paper.pdf) | All three original good NNBayes regimes, at every eligible width, under uniform iid Boolean inputs or a random full-domain permutation. Expected and high-probability bounds for posterior sampling, majority, and strict `>2/3` confidence. Includes a nonuniform expectation extension and polynomial-depth neuron-merging variants. |
| [Circuit-induction converses](works-in-progress/online-mistakes/circuit-converse/paper.pdf) | Few mistakes force small unrestricted-depth NAND circuits: linear in mistakes for minimum-consistent-circuit induction, and polynomial in expected sampling mistakes for two explicit Bayesian circuit priors. Full-domain or support-relative coverage is required. |
| [Neural converse note](works-in-progress/online-mistakes/nn-converse.md) | An exponential converse under original support, and a polynomial converse with a fixed output cap, in the strong-prior-then-width limit. The original fixed-width polynomial converse remains open. |
| [ReLU learning: the simpler norm argument](works-in-progress/relu-learning/paper.pdf) | Earlier strong-prior and finite-scale results, with sharper explicit ReLU estimates. Its open deep-scaling range is covered by the unified paper below. |
| [ReLU, GELU, and general Lipschitz activations](works-in-progress/unbounded-activations/paper.pdf) | One fixed-depth polynomial sample bound, simultaneously for every `N >= C` and every mean-field-or-stronger Gaussian scale, including deep `gamma = 1`. Original global margins; no added robustness. Auxiliary activation classes handle large Gaussian contributions. |
| [Polynomial-depth ReLU/GELU learning](works-in-progress/relu-gelu-polynomial-depth/paper.pdf) | Quadratic Boolean teacher-width dependence up to logarithms, and polynomial depth, for every `gamma >= 1` under unsigned neuron-merging stability. All learner widths above compiled teacher width; positive-mass Boolean implementations. |
| [Polynomial-depth neural converse](works-in-progress/online-mistakes/depth-polynomial-converse/paper.pdf) | Few total mistakes imply a small tanh network, with fourth-power mistake dependence and polynomial depth. Requires an output cap and controlled internal amplification, complete input coverage, and the strong-prior-then-width limit. |

The FAQ has separate sections on [total mistakes](TECHNICAL-FAQ.md#30-can-we-bound-the-total-number-of-mistakes-during-online-learning) and [converses](TECHNICAL-FAQ.md#31-does-making-few-mistakes-imply-that-the-target-has-a-small-circuit), including the input-order, prediction-rule, and coverage assumptions.

## Label-noise research

[Exact noisy interpolation in the strong-prior limit](works-in-progress/noisy-interpolation/README.md) is a new supporting research note. For distinct uniformly sampled Boolean inputs, it proves a clean-error bound linear in the corrupted fraction, with a resource-dependent coefficient, for the original tanh/Gaussian exact-fit learner at every width of order at least $C+U^2d^2(s+1)$, where $U$ bounds the teacher's output; this threshold grows linearly with the number $s$ of corruptions. The proof covers arbitrary corruptions and posterior mixtures. For bounded-output Boolean-circuit implementations, the noise coefficient is independent of teacher width; polynomial dependence on dimension and depth remains. A noise bound uniform in dimension and target complexity is still open.

This note is not Lean verified and remains separate from the main results. The [label-noise FAQ](TECHNICAL-FAQ.md#33-do-the-good-generalization-results-survive-a-small-amount-of-label-noise) gives the conventions, width requirement, and remaining question.

## Recent depth research

These are supporting results and works in progress, retained separately from the main generalization theorem under a robustness restriction. The unrestricted Boolean-cube problem remains open. For continuous-output regression, a counterexample proves that exponential depth dependence is necessary in a general width-independent guarantee.

| Paper or package | Scope |
|---|---|
| [Exponential depth dependence in Bayesian neural-network regression](works-in-progress/continuous-depth-lower-bound/paper.pdf) · [source and reviews](works-in-progress/continuous-depth-lower-bound/) | Constant-width, bounded-weight teachers on a fixed nonatomic distribution on the unit circle require exponentially many samples. Covers the strong-prior limit and every fixed $\gamma>1$ at widths above thresholds polynomial in sample size (and depth), exact minimum-energy interpolation, and $\gamma=1$ in the width-first limit. Controls posterior mixtures; does not settle the Boolean-cube problem or uniform spherical inputs. |
| [Unrestricted depth](works-in-progress/unrestricted-depth/paper.pdf) · [source](works-in-progress/unrestricted-depth/) | Polynomial learner-depth bounds above mean-field scaling for substantial target classes, including teachers with polynomially many hidden states after a fixed prefix. Also gives general-circuit bounds and representation obstructions; arbitrary deep targets remain open. |
| [Critical depth and learning](works-in-progress/critical-depth/paper.pdf) · [source](works-in-progress/critical-depth/) | Polynomial learner-depth bounds at every realizable width for all parities and fixed-depth teachers, under explicit minimum-depth conditions. Threshold teachers need no bound on coefficient magnitudes. Includes finite-width target-mass estimates, stronger bounds for several sequential classes, and a quasipolynomial formula bound. Joint polynomial dependence on arbitrary teacher width and depth remains open. |
| [Earlier depth reports and standalone notes](works-in-progress/depth-supporting-notes/) | The first two depth research reports, the shallow-target treatment, and the earlier critical-rate note. Useful historical arguments and audits, with their original scope retained. |
| [Depth experiments and reproduction guide](works-in-progress/depth-experiments/) | All 70 model configurations and outcome summaries, training/certificate code, selected original weights, and independently replayable exact positive and negative certificates. Large omitted replay archives and their availability are explicitly documented. |

The [technical FAQ](TECHNICAL-FAQ.md) explains the distinction between teacher and learner depth, alternative robustness conditions, empirical evidence, and the remaining unrestricted problem.

## Companion audits

| Audit | Scope |
|---|---|
| [Strong-prior slide appendix audit](side-results/strong-prior-appendix-audit/paper.pdf) · [source](side-results/strong-prior-appendix-audit/) | Appendix-by-appendix review, including major errors, repairs, and editorial decisions. |
| [Finite-exponent proof audit](side-results/gamma-proof-audit/paper.pdf) · [source](side-results/gamma-proof-audit/) | Review of the supplied finite-exponent draft and the mean-field argument; later results supersede some historical open-status remarks. |

## Files and verification

Each paper folder contains `paper.pdf`, its complete source dependencies under `source/`, and `build.sh`. Run a paper's script to rebuild it with a standard TeX Live installation. The collection also includes relevant mathematical review records and the computational certificate archives used by the structured papers.

The earlier 41 catalogued PDFs were rebuilt from their included source on 20 October 2026. The four [improved-polynomial papers](works-in-progress/improved-polynomials/) were added on 21 October with clean isolated rebuilds and independent mathematical review; their [initial build record](works-in-progress/improved-polynomials/verification/publication-build.json) records that snapshot, and the [attribution-correction record](works-in-progress/improved-polynomials/verification/attribution-correction-2026-10-22.json) gives current source and PDF hashes. The second formalization batch now verifies the main all-scales original-support and shallow bounds; the other additions retain their earlier verification scope. For the earlier papers, [catalog.json](catalog.json) (`pdf_preparation`) records each PDF's earlier revisions. The [19 October review record](verification/review-2026-10-19.md) records the collection-wide mathematical review at that date. On 20 October every paper's author list was put in alphabetical order; the [verification record](verification/README.md) describes this attribution revision. The seven new depth manuscripts were independently rebuilt from their complete source and checked against the frozen manuscripts' extracted PDF text. Existing internal mathematical audits are retained where available; they are not external peer review. The separate Lean project has the precisely delimited scope described above. Packaging checks are recorded in [verification/README.md](verification/README.md); the new paper builds are recorded in [depth-publication-builds.json](verification/depth-publication-builds.json). [catalog.json](catalog.json) records the canonical paper inventory and PDF checksums; [SHA256SUMS](SHA256SUMS) records the published file checksums.

The non-Gaussian extension has its own [source-build and mathematical review record](side-results/non-gaussian-priors/verification/README.md). Its two main learning statements are now included in the second formalization batch.

The paper collection was assembled on `codex/neural-network-generalization-papers-2026-10-16`; the Lean formalization was prepared on `codex/neural-network-lean-2026-10-16`. This folder on `main` contains the papers and their supporting records; exploratory scratch work remains outside the published collection.

## Acknowledgments

We thank Lucius Bushnaq, Sam Eisenstat, Lawrence Chan, Jake Mendel, and Lauren Greenspan for discussion and ideas.
