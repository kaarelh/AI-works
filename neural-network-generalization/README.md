# Bayesian neural-network generalization

Papers and notes by Dmitry Vaintrob, Kaarel Hänni, and OpenAI Codex (credited as ChatGPT in the earliest manuscripts), collected on 16 October 2026.

The four papers below are the main results. The remaining papers are listed as side results, earlier treatments, or works in progress. “Side result” does not mean unproved: several contain complete theorems, but they are not the main presentation of this project.

Every paper has a PDF, editable LaTeX source, and a build script. This collection contains 30 distinct papers and notes; duplicate builds, superseded versions of the same manuscript, and externally authored source material are omitted.

## Lean verification

The four main learning statements have Lean proofs for the actual Gaussian network model, including the all-input margin and strict `>2/3` confidence convention. The subcritical theorem covers **all gamma < 1, including gamma = 0 and gamma < 0**. The parity-network appendix is also formalized, with bounded-weight complexity at most `32*(d+1)^2` at every depth.

[Lean project and instructions](lean/) · [Exact statements](lean/NeuralGeneralization/Statements.lean) · [Verification record](lean/VERIFICATION.md) · [Coverage and auxiliary exclusions](lean/review/formal-coverage-inventory.txt)

The checked scope is the four exact main learning theorems and the stated parity supplement. Some formal proofs use different sufficient estimates from the papers. This does not certify every auxiliary result, sharp constant, or side paper.

## Main results

### 1. The strong-prior limit argument

[Paper (PDF)](main-results/strong-prior-generalization/paper.pdf) · [Source and build instructions](main-results/strong-prior-generalization/)

**Width-independent generalization in the strong-prior limit of Bayesian neural networks.** A writeup of the main proof thread in [Dmitry and Kaarel's slides](https://kaarelh.github.io/ai/nnbayes-generalization.pdf), including the compression and circuit arguments. At fixed depth, the sample bound is polynomial in input dimension, target complexity, and the accuracy parameters, independently of learner width $N\ge C_L(f)$.

This paper takes the prior variance to zero at each fixed width. It does not claim a variance threshold uniform over all widths. The [separate appendix audit](side-results/strong-prior-appendix-audit/paper.pdf) records the treatment of each slide appendix and the mistakes and repairs found there.

### 2. $\gamma>1$: every width above target complexity

[Paper (PDF)](main-results/gamma-above-one/paper.pdf) · [Source and build instructions](main-results/gamma-above-one/)

**Width-uniform Bayesian generalization above the mean-field scaling.** For every fixed depth and every fixed $\gamma>1$, proves polynomial sample complexity at the specified nonzero Gaussian variance for **every width $N\ge C_L(f)$**. The result allows bounded 1-Lipschitz hidden activations and arbitrary input distributions. The polynomial may depend on depth and $\gamma$; there is no uniform claim as $\gamma$ approaches one.

### 3. $\gamma=1$: every width above target complexity

[Paper (PDF)](main-results/meanfield-all-width/paper.pdf) · [Source and build instructions](main-results/meanfield-all-width/)

**Mean-field Bayesian circuit learning at every width above target complexity.** A standalone finite-width proof for fixed-depth tanh networks, with polynomial sample complexity for **every width $N\ge C_L(f)$** and arbitrary input distributions. No infinite-width limit or extra minimum-width hypothesis is needed. This resolves the all-width question left open in the earlier mean-field papers.

### 4. $\gamma<1$: an exponential sample-complexity lower bound

[Paper (PDF)](main-results/subcritical-exponential/paper.pdf) · [Source and build instructions](main-results/subcritical-exponential/)

**Exponential parity sample complexity throughout the subcritical width regime.** For every fixed $\gamma<1$ and fixed depth, proves an $\exp(\Omega(k))$ sample lower bound for full $k$-bit parity under uniform IID training inputs. Here the ambient dimension is $d=k$.

More precisely, there are $c>0$ and $k_0$ such that, for every $k\ge k_0$ and each specified integer $0\le n\le e^{ck}$, with probability at least $3/4$ over the training sample, the limiting fraction of test inputs whose correct label has posterior probability at most $2/3$ is at least $1/16$ (in the liminf sense). Width tends to infinity first, with dimension, sample, margin, depth, and $\gamma$ fixed. The paper does not give a quantitative minimum width or a joint-limit theorem. The guarantee is for each specified sample size, not a simultaneous statement about all prefixes of one sample sequence.

This is the completed full-parity exponential theorem. The stronger fixed-depth sparse-parity target $\exp\{\Omega(k\log(ed/k))\}$ in the positive subcritical regime is still open; the partial results below do not replace that target with a solved claim.

## Shared conventions

In the four main papers, the learner conditions the Gaussian parameter prior on a strict absolute output margin **at every input of the Boolean cube before observing training data**, then conditions on exact noiseless labels. These are information-theoretic results about the exact posterior; efficient posterior computation is not asserted.

At fixed depth, $C_L(f)$ is the bounded-weight network complexity defined in the papers: the smallest eligible width $C$ with weights bounded by $C$. Circuit simulations are proved where used; arbitrary circuit size is not silently identified with fixed-depth network complexity.

For prediction, the success criterion is correct-label posterior probability **strictly greater than $2/3$**. The first papers phrase their main bounds in posterior average error; the confidence guarantee follows by rescaling the accuracy parameter by three. The later papers state the confidence convention explicitly.

## Side results

These results develop the model, strengthen special cases, or analyze ingredients of the open sparse-parity problem. Each row links to the PDF and to its source folder.

| Paper | Scope |
|---|---|
| [Small circuits under Gaussian-process classification: what sample complexity follows from the actual posterior?](side-results/nngp-sample-complexity/paper.pdf) · [source](side-results/nngp-sample-complexity/) | NNGP regression, classification, and confidence are distinguished; a specified deep tanh family has an exponential confidence sample requirement. |
| [The fixed-kernel regime of a margin-conditioned Bayesian neural-network prior](side-results/gamma-below-one/paper.pdf) · [source](side-results/gamma-below-one/) | Kernel freezing and the three width-first limits for positive, zero, and negative gamma. Its original sample-bound discussion predates the main exponential theorem. |
| [Small circuits can have exponentially large prior complexity below the mean-field scaling](side-results/subcritical-circuit-prior/paper.pdf) · [source](side-results/subcritical-circuit-prior/) | Small circuits can have exponentially large normalized prior complexity. A prior-mass separation alone is not a sample lower bound. |
| [Gaussian conditioning below the mean-field scaling: a sharp fluctuation threshold](side-results/subcritical-gaussian-conditioning/paper.pdf) · [source](side-results/subcritical-gaussian-conditioning/) | Relative Gaussian conditioning below gamma=1/2, and a tanh counterexample at and above that threshold; leading rates and posterior probabilities are distinguished. |
| [Finite-width circuit learning below mean-field scaling](side-results/finite-width-subcritical/paper.pdf) · [source](side-results/finite-width-subcritical/) | A width-dependent finite-width sample upper bound. Polynomial widths can learn with polynomial samples, consistently with the width-first lower bounds. |
| [Global Margin Conditioning Amplifies a Gaussian Posterior Mean](side-results/gamma-zero-mean-energy/paper.pdf) · [source](side-results/gamma-zero-mean-energy/) | A counterexample to a proposed dimension-free posterior mean-energy estimate after global margin conditioning. |
| [Global-margin conditioning at the Gaussian endpoint: normalization, training loss, and output amplitude](side-results/zero-gamma-conditioning-note/paper.pdf) · [source](side-results/zero-gamma-conditioning-note/) | Gaussian endpoint conditioning-cost, latent-loss, and actual-output amplitude estimates. |
| [Sparse parity under globally conditioned neural priors](side-results/sparse-parity/paper.pdf) · [source](side-results/sparse-parity/) | Natural sparse-parity hardness for gamma<0; one-coordinate parity learns with O(log d) samples for 0<gamma<1. |
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
| [Bayesian circuit learning at mean-field scaling: a variational principle and width-independent generalization](side-results/gamma-ge1-endpoint/paper.pdf) · [source](side-results/gamma-ge1-endpoint/) | Earlier mean-field variational proof, with an unquantified sufficiently-large-width threshold. Its all-width question is resolved by main result 3. |
| [An explicit sufficient width for mean-field Bayesian circuit learning](side-results/meanfield-quantified-width/paper.pdf) · [source](side-results/meanfield-quantified-width/) | Earlier quantified sufficient-width theorem. Main result 3 removes the extra width threshold. |
| [Superpolynomial sample lower bounds for globally margin-conditioned Bayesian neural networks below the mean-field scaling](side-results/subcritical-sample-complexity/paper.pdf) · [source](side-results/subcritical-sample-complexity/) | Earlier superpolynomial lower bound, valid for every training set of the indicated size. The stronger IID exponential theorem is main result 4. |
| [Superpolynomial sample lower bounds below the mean-field scaling (earlier positive-gamma version)](works-in-progress/positive-subcritical-sample-complexity/paper.pdf) · [source](works-in-progress/positive-subcritical-sample-complexity/) | Superseded standalone draft for 0<gamma<1. The unified and later exponential papers are the preferred statements. |
| [Failure of Bayesian Gaussian process classification at exponentially large sample sizes](side-results/gaussian-exponential-schedule/paper.pdf) · [source](side-results/gaussian-exponential-schedule/) | Earlier gamma<0 theorem at an exponential sample schedule; later papers extend the range of sample sizes. |
| [Exponential sample lower bounds for Bayesian Gaussian process classification](side-results/gaussian-exponential-lower-bound/paper.pdf) · [source](side-results/gaussian-exponential-lower-bound/) | Standalone gamma<0 full-parity proof, subsequently included and strengthened in the subcritical and sparse-parity papers. |
| [A certified margin-repair bound for cubic parity predictors: one arbitrary bit, twenty-six symmetric bits, and parity-block lifts](side-results/cubic-parity-repair-certificate/paper.pdf) · [source](side-results/cubic-parity-repair-certificate/) | Earlier cubic certificate, extended by the structured cubic-and-quartic paper above. Reproduction archive included. |

The principal unfinished target is the fixed-depth natural sparse-parity lower bound for $0<\gamma<1$, with uniform IID samples and the actual posterior-confidence criterion. Selected-example results, symmetry-restricted certificates, and analytic reductions are side results, not a resolution of that target.

## Companion audits

| Audit | Scope |
|---|---|
| [Strong-prior slide appendix audit](side-results/strong-prior-appendix-audit/paper.pdf) · [source](side-results/strong-prior-appendix-audit/) | Appendix-by-appendix review, including major errors, repairs, and editorial decisions. |
| [Finite-exponent proof audit](side-results/gamma-proof-audit/paper.pdf) · [source](side-results/gamma-proof-audit/) | Review of the supplied finite-exponent draft and the mean-field argument; later results supersede some historical open-status remarks. |

## Files and verification

Each paper folder contains `paper.pdf`, its complete source dependencies under `source/`, and `build.sh`. Run a paper's script to rebuild it with a standard TeX Live installation. The collection also includes relevant mathematical review records and the computational certificate archives used by the structured papers.

The manuscripts have not been rewritten for this collection. One earlier draft PDF was rebuilt from unchanged source to resolve missing cross-references; the other 29 PDFs are unchanged. Existing internal mathematical audits are retained where available; they are not external peer review. The separate Lean project verifies the main learning statements and the parity supplement as described above. Packaging checks are recorded in [verification/README.md](verification/README.md). [catalog.json](catalog.json) records the canonical paper inventory and PDF checksums; [SHA256SUMS](SHA256SUMS) records the published file checksums.

The paper collection was assembled on `codex/neural-network-generalization-papers-2026-10-16`; the Lean formalization was prepared on `codex/neural-network-lean-2026-10-16`. This folder on `main` contains the papers and their supporting records; exploratory scratch work remains outside the published collection.
