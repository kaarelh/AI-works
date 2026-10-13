# Solomonoff function induction

Two companion papers on Solomonoff function induction (SFI): Bayesian prediction of labels from input–output pairs under a universal prior over random functions. Kaarel Hänni asked for a paper that would:
* define SFI;
* prove its basic properties;
* explain why it is of interest, for example as ideal supervised learning, and through the link to neural-network Bayes.

He also listed specific questions and examples. The papers were developed and written with extensive assistance from Claude (Anthropic), under his direction. They are drafts in arXiv form, with Kaarel Hänni as author and the AI assistance disclosed in each paper. Submission is his decision.

* **[Paper 1: *Solomonoff Function Induction: Definitions, Versions and Basic Theorems* (PDF)](paper/main.pdf)**, 90 pages: a 44-page main text plus appendices with the proofs.
* **[Paper 2: *Steeper Simplicity Priors in Solomonoff Function Induction: Absorption, the Teacher's Mistakes and the Model–Randomness Split* (PDF)](paper-steeper/main.pdf)**, 57 pages: a 28-page main text plus appendices with the proofs.

## Answers in brief

1. **Definition.**
   * Feed one infinite sequence of fair coin flips to a universal Turing machine. On each query x it runs afresh, reads the same sequence from its first bit, as many bits as it needs, and outputs a label or diverges. This gives a random partial function; its law M_F is the prior of SFI, and SFI conditions it on the data. There is one source of randomness: reading the tape's first self-delimiting block as a program and the rest as its coin flips is only a representation of M_F as a mixture.
   * M_F dominates the law of every *function machine* (any Turing machine reading one random tape, the same for all queries) up to the factor 2^{−K(ν)}, and it changes by at most a constant factor when the universal machine changes.
   * The coin-free version, the prior 2^{−|p|} on deterministic programs (W), never exceeds M_F by more than a constant factor and falls short of it by at most K(dom D) + O(1) bits. The gap is unbounded, but on two-point data sets over d-bit inputs it is at most K^pad(2^{d+1}) + O(1), which grows more slowly than 2 log h(d) for every computable unbounded nondecreasing h (Paper 1, Section 4).
   * On every consistent data sequence, however the inputs are chosen, SFI's cumulative log loss exceeds that of every computable random labeller ν by at most K(ν) + O(1).
   * With i.i.d. inputs and a computable deterministic target f, the averaged predictor has risk O(K(f)/n).
2. **Kolmogorov version versus semimeasure version: not equivalent.** There is no coding theorem for function programs.
   * For every d there are two inputs on which every program with the given two labels has length at least log d − 2, while SFI's loss on them is O(1).
   * The shortest consistent program, the program mixture, the mixture of product laws and SFI agree up to K(dom D) + O(1) bits on every data set D.
   * Paper 1, Section 4 gives the full comparison, including the gaps that remain open.
3. **Order, and access to the previous inputs.**
   * Measured on its unnormalised predictive probabilities, SFI's loss does not depend on the order of the data, so it cannot use information that only the order carries.
   * If the hypotheses also see the list of previous inputs (but not the previous labels), the result is a universal chronological semimeasure. On the interleaved sequence x₁y₁x₂y₂… its loss is at most that of Solomonoff induction (SI) plus a constant.
   * The dominance theorem for computable reveal laws in the notes holds pathwise for deterministic laws. For randomised laws it holds in expectation, under finiteness assumptions and with an extra K(n) + K(A) term; the sketched proof in the notes does not work as written.
4. **The two examples.**
   * *Random cyclic permutation of {0,1}^d, revealed backwards along its cycle.* SFI pays about (d − log₂ e)·2^d bits, and this is sharp. SI, with self-delimiting blocks, pays O(1) bits in expectation.
   * *Sam Eisenstat's coin example.* SFI's expected loss is (h(1/3)/2)·n ± O(log n) bits, which is optimal among order-independent predictors. SI pays at most 2.4 bits plus a constant.
5. **Neural-network Bayes as circuit SFI.** Paper 1, Section 10 builds on the slides with Dmitry Vaintrob:
   * circuit Bayes makes a number of mistakes polynomial in the circuit size on every ordering of the inputs;
   * Gaussian-process limits are separated from SFI on sparse parities;
   * bias-free two-layer ReLU kernels fail on odd parities.
6. **Steeper simplicity priors (Paper 2).** The proposal is to penalise program length λ > 1 times more steeply than log-likelihood, for hypotheses with private randomness at each input.
   * *Absorption.* A universal mixture taken as one hypothesis absorbs all structure in every class that contains its own mixture (SI, SFI with shared randomness). No private-randomness hypothesis is universal.
   * *The teacher's mistakes.* The setting is a random parity whose labels are flipped, at a rate below 0.056, on an error set of product form that is incompressible relative to the parity. With λ = cn and c in an explicit window, every hypothesis that is near-optimal for the population objective knows the parity and, when the error rule is large, gives the erroneous labels much less probability than a memoriser does. λ must grow in proportion to n.
   * *Model versus randomness.* For fixed λ > 1, private randomness selects samplers over programs that fill in the sampled bits. With shared randomness, a universal mixture beats every long enough sampler.
   * *Product sophistication.* Sophistication defined with product models exceeds the set sophistication of algorithmic statistics by d − O(log d) bits on a random parity whose labels are flipped on a random set of fixed density below 1/4.

## How it was produced

* **Research.** Five research tracks are in `research/tracks/`: `foundations`, `history`, `examples`, `context` and `steeper`. Each was developed and then attacked by an adversarial referee who wrote independent code (`referee.md`, `referee_code/`). Each was then revised into a final record, `notes-final.md`, ending in a verification log. The `steeper` track was refereed twice.
* **Writing.** The papers were planned from claims ledgers (`paper*/CLAIMS.md`) and a shared notation (`paper/NOTATION.md`), and written section by section.
* **Review.**
  * Six reviewers went over both drafts: three on Paper 1's mathematics, one on Paper 2's mathematics, and one per paper on consistency and arXiv-readiness, including a search check of every bibliography entry.
  * A lead editor verified every fatal and major issue against the sources and wrote binding decisions.
  * Six editor groups applied them, and a fresh checker per paper verified the result.
  * A last pass, at the author's request, rewrote the framing so that the papers present the material directly rather than as a reply to his working notes, which are now credited in footnotes and the acknowledgements (`research/paper-review/REFRAME.md`). Editors rewrote the text; per paper, a fresh reader and a diff checker confirmed that nothing reads as a reply to the notes and that no mathematics changed.
  * Everything is in `research/paper-review/`.
* **Limits of the checking.** All roles were played by separate Claude instances. No human has checked all of the mathematics, and nothing was verified in a proof assistant.

## Layout

| path | contents |
|---|---|
| `paper/`, `paper-steeper/` | LaTeX sources (`main.tex`, `sections/`, `bib/`, `preamble.tex`), `build.sh` and `main.pdf` for each paper, plus the planning files `OUTLINE.md`, `CLAIMS.md` and `NOTATION.md`. The working sources keep a `\status{…}` tag and a `\src{…}` note on each result, recording whether it is proved, computed or conjectured and which track record it comes from. Both macros print nothing in the PDF. |
| `research/script-map.md` | Every result that rests on a computation, by its printed number in either paper, with the scripts behind it. Generated by `research/make_script_map.py`. |
| `research/tracks/` | The five research records with referee reports, check scripts (`checks/`), independent re-implementations (`referee_code/`) and their saved outputs. |
| `code/` | A small enumerated program class (`sfi_dsl.py`) and shared helpers for the examples (`sfi_examples.py`). |
| `research/paper-review/` | The reviews of both papers (`p1/`, `p2/`), the lead editor's decisions (`DECISIONS.md`), the editor groups' issue lists and logs (`edits/`), the final checks (`final-check-p1.md`, `final-check-p2.md`), the reframing brief and its logs and checks (`REFRAME.md`, `reframe/`), and the reviewers' scripts (`scratch/`). |
| `research/00-brief.md` | The request, the sources, the starting hypotheses and the conventions. |
| `research/prior/` | Copies of the author's notes on SFI and related topics, from [kaarelh/notes](https://github.com/kaarelh/notes), and the slides with Dmitry Vaintrob. |
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
