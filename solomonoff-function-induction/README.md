# Solomonoff operator induction

Two companion papers on Solomonoff operator induction (SOI). The problem is Bayesian prediction of the answer to a new question, here the label at a new input, from question–answer pairs under a universal prior.
* **The problem is Solomonoff's.** He posed this operator-induction problem and gave universal-prior solutions with a convergence theorem (Solomonoff 1999, 2008).
* **The papers study several versions of such solutions:**
  * his per-query solution;
  * a one-tape version, in which randomness is shared across questions; the papers take this version as the default;
  * the coin-free, Kolmogorov and history-aware versions.
* **They ask** how the versions compare and what they do.

**Authors: Kaarel Hänni and Claude (Anthropic).** Claude did the research and writing, in response to questions from Kaarel Hänni and under his direction.
* **What Hänni asked for:** a paper that would
  * define the induction;
  * prove its basic properties;
  * explain why it is of interest, for example as ideal supervised learning, and through the link to neural-network Bayes.

  He also listed specific questions and examples.
* **Status:** the papers are drafts in arXiv form. Submission is his decision.
* **Earlier name:** they were first written under the name "Solomonoff function induction (SFI)", the name used in Hänni's notes.

* **[Paper 1: *Solomonoff Operator Induction: Definitions, Versions and Basic Theorems* (PDF)](paper/main.pdf)**, 90 pages: a 44-page main text plus appendices with the proofs.
* **[Paper 2: *Steeper Simplicity Priors in Solomonoff Operator Induction: The Model–Randomness Split and the Teacher's Mistakes* (PDF)](paper-steeper/main.pdf)**, 87 pages: a 40-page main text plus appendices with the proofs.

## Answers in brief

1. **Definition.**
   * Feed one infinite sequence of fair coin flips to a universal Turing machine. On each query x it runs afresh, reads the same sequence from its first bit, as many bits as it needs, and outputs a label or diverges. This gives a random partial function; its law M_F is the prior of the one-tape version of SOI, the papers' default, which conditions it on the data. There is one source of randomness: reading the tape's first self-delimiting block as a program and the rest as its coin flips is only a representation of M_F as a mixture.
   * M_F dominates the law of every *function machine* (any Turing machine reading one random tape, the same for all queries) up to the factor 2^{−K(ν)}, and it changes by at most a constant factor when the universal machine changes.
   * The coin-free version, the prior 2^{−|p|} on deterministic programs (W), never exceeds M_F by more than a constant factor and falls short of it by at most K(dom D) + O(1) bits. The gap is unbounded, but on two-point data sets over d-bit inputs it is at most K^pad(2^{d+1}) + O(1), which grows more slowly than 2 log h(d) for every computable unbounded nondecreasing h (Paper 1, Section 4).
   * On every consistent data sequence, however the inputs are chosen, SOI's cumulative log loss exceeds that of every computable random labeller ν by at most K(ν) + O(1).
   * With i.i.d. inputs and a computable deterministic target f, the averaged predictor has risk O(K(f)/n).
2. **Kolmogorov version versus semimeasure version: not equivalent.** There is no coding theorem for function programs.
   * For every d there are two inputs on which every program with the given two labels has length at least log d − 2, while SOI's loss on them is O(1).
   * The shortest consistent program, the program mixture, the mixture of product laws and the one-tape version agree up to K(dom D) + O(1) bits on every data set D.
   * Paper 1, Section 4 gives the full comparison, including the gaps that remain open.
   * *Relation to Solomonoff's work.*
     * Solomonoff's per-query solution (2008, eq. (10)) is the per-query mixture M_pq, which equals M_prod on distinct inputs. So on distinct inputs every version agrees up to K(dom D) + O(1) bits, and the examples' lower bounds hold for his solution too.
     * The versions differ on repeated inputs: the one-tape version gives a repeated input the same label, while the per-query solution draws fresh noise.
     * His convergence theorem (eq. (12)) is credited.
     * The one-tape, coin-free, Kolmogorov and history-aware versions, and the comparisons between them, are new as far as we know.
3. **Order, and access to the previous inputs.**
   * Measured on its unnormalised predictive probabilities, SOI's loss does not depend on the order of the data, so it cannot use information that only the order carries.
   * If the hypotheses also see the list of previous inputs (but not the previous labels), the result is a universal chronological semimeasure. On the interleaved sequence x₁y₁x₂y₂… its loss is at most that of Solomonoff induction (SI) plus a constant.
   * The dominance theorem for computable reveal laws in the notes holds pathwise for deterministic laws. For randomised laws it holds in expectation, under finiteness assumptions and with an extra K(n) + K(A) term; the sketched proof in the notes does not work as written.
4. **The two examples.**
   * *Random cyclic permutation of {0,1}^d, revealed backwards along its cycle.* SOI pays about (d − log₂ e)·2^d bits, and this is sharp. SI, with self-delimiting blocks, pays O(1) bits in expectation.
   * *Sam Eisenstat's coin example.* SOI's expected loss is (h(1/3)/2)·n ± O(log n) bits, which is optimal among order-independent predictors. SI pays at most 2.4 bits plus a constant.
5. **Neural-network Bayes as circuit SOI.** Paper 1, Section 10 builds on the slides with Dmitry Vaintrob:
   * circuit Bayes makes a number of mistakes polynomial in the circuit size on every ordering of the inputs;
   * Gaussian-process limits are separated from SOI on sparse parities;
   * bias-free two-layer ReLU kernels fail on odd parities.
6. **Steeper simplicity priors (Paper 2): two reasons to penalise program length λ > 1 times more steeply than log-likelihood,** for Solomonoff's per-query solution, whose hypotheses draw private randomness at each input.
   * *Why private randomness.* A universal mixture taken as one hypothesis absorbs all structure in every class that contains its own mixture (SI, the one-tape version of SOI with its shared randomness). No private-randomness hypothesis is universal.
   * **First and main reason: the model–randomness split.**
     * With i.i.d. inputs and a computable sampler that draws fresh coins at every query, for every schedule 1 ≤ λ_n = o(n) every λ_n-MAP is eventually exactly a shortest program for the sampler: the model is the program, the noise is the coins.
     * For fixed λ > 1 this happens with probability 1 − ε beyond a sample size depending only on λ, the program's length, a margin and ε. At λ = 1 no such bound exists, and in a parity class recovery is exponentially slower in the program's length.
     * On one data set, a kink of the product structure function at a sufficient program makes every λ between 1 and the kink's steepness select that program, up to explicit windows. Samples have such a kink; so, for large d, does the full table of a noisy random parity at every dyadic flip rate below 1/4. Set models have no steep kink there.
     * With labels frozen per distinct input, no procedure recovers every sampler; what survives is identification on the inputs actually seen.
   * **Second reason: not learning a teacher's mistakes,** the same geometry at a positive rate. An error rule is reused at many inputs, so λ must grow linearly in the sample size. For a random parity with labels flipped at a rate below 0.05596 on an error set of product form that is incompressible relative to the parity, every near-optimal hypothesis of the population objective with λ/n in an explicit window knows the parity and, for large error rules, gives the erroneous labels far less probability than a memoriser. Asymptotically, such windows exist for flip rates below 0.1233.
   * *λ ∝ n and weight decay.* With λ = cn the objective divided by n is the empirical risk plus c times program length, so the penalty does not fade with data; no fixed prior with full support gives these MAPs at every sample size. This is the structure of a fixed weight-decay coefficient: in the limit it can keep preferring a simpler hypothesis that fits worse.
   * *Imitation (toy).* If a person's coins are private, the person's sampler is recovered as in the first reason. If the environment drives the coins, programs that model the environment predict better, and any fixed λ eventually picks a program for the data, not a copy. Yet for λ/n in a window every near-optimal private-randomness hypothesis is behaviourally close to the person, whatever it computes internally, when the coupling is incompressible and spread over far more cells than the person has bits. Matching limits: data identify behaviour, not mechanism; an entangled person cannot be copied by any procedure; a coupling with a short description defeats every λ/n.
   * *Scope.* The paper does not claim to solve imitation or learning from a fallible teacher. It offers tools and solves toy cases; the introduction lists them and the discussion names the open conceptual problems.

## How it was produced

* **Research.** Seven research tracks are in `research/tracks/`: `foundations`, `history`, `examples`, `context`, `steeper`, `split` and `imitation` (robust recovery of a sampler and the weight-decay analogy; two sub-tracks, refereed, a synthesis, a final check and a final referee pass on the closeness lemma) (the model–randomness split; three sub-tracks `iid`, `kink` and `teacher`, each refereed twice, then a synthesis, a final check and independent verification of the post-referee results). Each was developed and then attacked by an adversarial referee who wrote independent code (`referee.md`, `referee_code/`). Each was then revised into a final record, `notes-final.md`, ending in a verification log. The `steeper` track was refereed twice.
* **Writing.** The papers were planned from claims ledgers (`paper*/CLAIMS.md`) and a shared notation (`paper/NOTATION.md`), and written section by section.
* **Review.**
  * Six reviewers went over both drafts: three on Paper 1's mathematics, one on Paper 2's mathematics, and one per paper on consistency and arXiv-readiness, including a search check of every bibliography entry.
  * A lead editor verified every fatal and major issue against the sources and wrote binding decisions.
  * Six editor groups applied them, and a fresh checker per paper verified the result.
  * A last pass, at Hänni's request, rewrote the framing so that the papers present the material directly rather than as a reply to his working notes, which are now credited in footnotes and the acknowledgements (`research/paper-review/REFRAME.md`). Editors rewrote the text; per paper, a fresh reader and a diff checker confirmed that nothing reads as a reply to the notes and that no mathematics changed.
  * Paper 2 was then restructured around its two threads after new research on the split (the `split` track): a plan with a label manifest, six section writers, three reviewers, a lead editor's decisions, fixes and a fresh final check (`research/paper-review/restructure/`).
  * The imitation section, the weight-decay remark and the caveats were then added, with a literature check, two reviews, fixes and a fresh final check (`research/paper-review/imitation-edit/`).
  * **The rename.** The papers were then renamed from "Solomonoff function induction" to "Solomonoff operator induction". Hänni suggested it, after it became clear how close the setting is to Solomonoff's operator induction.
    * Solomonoff's two papers were read in full first, from PDFs Hänni supplied.
    * Editors applied a binding brief (`research/paper-review/rename/RENAME.md`).
    * A fresh checker per paper verified three things: that every changed sentence names the right version, that every statement about Solomonoff matches his papers, and that the numbering of every result is unchanged.
  * **Authorship.** Both authors were then listed on both papers, at Hänni's request (`research/paper-review/rename/log-authorship-*.md`, `check-authorship.md`).
  * Everything is in `research/paper-review/`.
* **Limits of the checking.** All roles were played by separate Claude instances. No human has checked all of the mathematics, and nothing was verified in a proof assistant.

## Layout

| path | contents |
|---|---|
| `paper/`, `paper-steeper/` | LaTeX sources (`main.tex`, `sections/`, `bib/`, `preamble.tex`), `build.sh` and `main.pdf` for each paper, plus the planning files `OUTLINE.md`, `CLAIMS.md` and `NOTATION.md`. The working sources keep a `\status{…}` tag and a `\src{…}` note on each result, recording whether it is proved, computed or conjectured and which track record it comes from. Both macros print nothing in the PDF. |
| `research/script-map.md` | Every result that rests on a computation, by its printed number in either paper, with the scripts behind it. Generated by `research/make_script_map.py`. |
| `research/tracks/` | The five research records with referee reports, check scripts (`checks/`), independent re-implementations (`referee_code/`) and their saved outputs. |
| `code/` | A small enumerated program class (`sfi_dsl.py`) and shared helpers for the examples (`sfi_examples.py`). |
| `research/paper-review/` | The reviews of both papers (`p1/`, `p2/`), the lead editor's decisions (`DECISIONS.md`), the editor groups' issue lists and logs (`edits/`), the final checks (`final-check-p1.md`, `final-check-p2.md`), the reframing brief and its logs and checks (`REFRAME.md`, `reframe/`), the Paper 2 restructure (`restructure/`), the rename to Solomonoff operator induction and the authorship change (`rename/`), and the reviewers' scripts (`scratch/`). |
| `research/00-brief.md` | The request, the sources, the starting hypotheses and the conventions. |
| `research/prior/` | Copies of Hänni's notes on this setting (where it is called function induction) and related topics, from [kaarelh/notes](https://github.com/kaarelh/notes), and the slides with Dmitry Vaintrob. |
| `research/workflows/` | *(on the working branch `claude/sleepy-gauss-u4kem1` only, not on `main`)* The orchestration scripts that ran the research, writing, review and editing agents. |

The internal verification records that were part of the drafts (`paper*/sections/app-verification.tex`) are kept in the sources but switched off in the PDFs.

## Building and reproducing

* **Papers:** `cd paper && ./build.sh`, and the same in `paper-steeper/`. Both need `pdflatex` and `bibtex`. To compile one section with its appendix, run `./test-section.sh <section> <appendix>`.
* **Computations:**
  * Each script in `research/tracks/*/checks/` and `research/tracks/*/referee_code/` is deterministic or seeded. Its output is saved next to it, as `.out` or `.txt`.
  * They run with Python 3.11, NumPy, SciPy and mpmath; one history check uses `scipy.optimize.milp`.
  * Run a script from its own folder, for example `cd research/tracks/examples/checks && python3 e6_cyclic_sharp.py`, and compare the result with the saved output.
  * Re-running reproduces the saved outputs, apart from timing lines and one time-limited optimisation.
  * `research/script-map.md` says which script supports which result.
