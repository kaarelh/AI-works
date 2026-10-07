# What follows from what: learning inference rules from imitation, coherence and the world

Prepared by Claude (Anthropic) in response to questions posed by Kaarel Hänni. It is a draft, and authorship and publication are for him to decide.

**Start with [the report (PDF)](paper/main.pdf).** It contains:
* the introduction and the answers in brief (§1);
* the main argument (§§2–7);
* the two questions taken from Hänni's notes (§§8–9);
* informal mathematics (§10);
* contexts and physics checking (§11);
* experiments (§12);
* justification beyond proof (§13);
* open problems (§14);
* full proofs and the Lean map in the appendices.

## The question

A learner learns *which inferences are valid* in three stages:

1. It imitates human inferences, from formal or informal proofs or from physics solutions.
2. It is conditioned on **coherence**: no good arguments for both P and ¬P.
3. It receives occasional truth values from **the world**.

Arguments live in **contexts**, including idealized contexts that contradict background knowledge, such as "assume air pressure is 0".

The question is whether this can be made to work, provably, in three settings:
* formal mathematics;
* mathematics as it was before anyone knew how to formalize it;
* physics olympiad problems, whether by solving them or by checking solutions.

Behind it is a larger question: what does principled justification look like beyond proof?

## The answer in brief

It works in a specific shape, and each learning signal has provable strengths and a provable residue.

| Signal | What it provably fixes | What it provably cannot fix |
|---|---|---|
| Imitation (positive steps) | The rules actually followed. A schematic calculus is identified exactly at coupon-collector rates (for rules cited by name), and this generalizes to derivations of any size. | Systematic human errors, which are indistinguishable from rules. |
| Cautious acceptance | Soundness against every adaptive prover, under realizability. Its price is a combinatorial dimension of the class: linear in step size for named schemas, exponential for unstructured classes. | Nothing new by itself. A cautious learner never even sees a contradiction. |
| Coherence (derivations of ⊥ from contexts certified consistent) | Every error that is incoherent with the target. Classical logic is pinned exactly, by a single coherence datum (Post-completeness). The classical meanings of the connectives are fixed once denials are allowed: Carnap's problem read as Gold's problem. | Coherent uniform alternatives (the Kripkensteinian residue). Intermediate logics. Σ₁-unsound arithmetic. Which valuation is actual. |
| Simplicity (steeper penalty) | Expensive, idiosyncratic errors, through a rate threshold. | Cheap frequent fallacies. Rare valid rules get lost. The threshold cannot be calibrated from imitation data. |
| World (objects, computation, simulation) | Step-level blame by descent: log₂\|H\| counterexamples suffice, against up to \|H\|−1 paradoxes on some classes. Calibration of top models. | Errors invisible on every presentable object. Effects outside the top model. |
| Contexts (filter semantics) | Reasoning under contradictory idealizations without explosion. Coherence only where it belongs. Certified exports. | The reading of the problem and the adequacy of the top model, both provably ineliminable. |

How the three success criteria come out:
* **Formal mathematics.** Yes for classical propositional logic. For complete decidable theories, only conditionally, on a realizability hypothesis that is not yet established. Arithmetic is Popperian, with sharp limits at Σ₂.
* **Before formalization.** Conditionally. If the latent formalization lies in the learner's class, a bounded-gap verifier is sound against adaptive provers and brackets meaning. History broke that condition at its decisive steps. The open problem is affordable soundness when the learner must invent language.
* **Physics.** There is a principled checker design with a relative soundness theorem, illustrated on one EuPhO problem. It is not a general system. We deliberately built a checker, not a solver.

On the philosophical side, every learning signal is one-sided. Principled justification is therefore a *set* of signals that jointly cover every direction of error, together with a declared residue. Mathematical and physical justification differ in degree, measured by the size of an explicit judgment layer, not in kind.

## How the results were established

* **Theory.** Seven theory documents (`research/theory/T1…T7`), with literature memos in `research/lit/`.
* **Adversarial verification.** Referees tried to refute every main result. Problems were repaired, then re-checked by fresh referees. Records are in `research/verification/` and in each theory document's Verification log.
* **Lean 4 + Mathlib** (`lean/`). About 50 paper results are formalized in 17 modules and about 14,600 lines, with no `sorry`. The axiom audit is in `lean/audit-output.txt`, and the theorem map is in `lean/README.md` and in the paper's appendix.
* **Experiments** (`code/`):
  * school algebra with simulated systematic errors;
  * propositional natural deduction;
  * adversarial proof search against learned verifiers;
  * a physics prototype checker.

  These are illustrations, not evidence of scalability.
* **Whole-paper review.** Reports are in `research/paper-review/`.

## Layout

| path | contents |
|---|---|
| `paper/` | LaTeX sources (`main.tex`, `sections/`, `bib/`), the build script `build.sh`, and `main.pdf` |
| `lean/` | Lean 4 formalization, library `InfLearn`. Build with `lake build`; run the audit with `lake build Audit` |
| `code/` | Python package `cil`, experiments, results and tests (`code/README.md`; `run_all_quick.sh`) |
| `research/00-brief.md` | the question as posed, and the working hypotheses |
| `research/lit/` | literature memos L1–L11, including a digest of Hänni's notes (L10) |
| `research/theory/` | theory documents T1–T7 with their check scripts |
| `research/verification/` | adversarial verification records |
| `research/paper-review/` | whole-paper review reports and issue lists |
| `research/scratch/` | unreviewed working scripts and outputs from the theory and verification rounds, some cited by name in `research/verification/`; see its README |
| `research/workflows/` | the orchestration scripts that ran the research, verification, writing and review agents |
| `web/what-follows.html` | the results web page, as a standalone HTML file |

## Building

* Paper: `cd paper && ./build.sh` (needs TeX Live with `latexmk`-style tools; `pdflatex` and `bibtex` are enough).
* Lean: `cd lean && lake exe cache get && lake build`. See `lean/README.md` for building without the Mathlib cache.
* Code: `cd code && python -m pytest -q && ./run_all_quick.sh`.

## Follow-up

The questions asked after this report, about Peano arithmetic, rules versus axioms, Gold's theorem and learning the induction schema, and the answers given, are in [`../axiom-schemas/research/conversation.md`](../axiom-schemas/research/conversation.md). They led to the standalone paper in [`../axiom-schemas/`](../axiom-schemas/).
