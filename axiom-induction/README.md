# Bayesian axiom induction from instances

This folder is a follow-up to `../axiom-schemas/` and `../inferential-learning/`. Claude (Anthropic) prepared it in response to a question from Kaarel Hänni (8 October 2026). The question asks whether there is a good Solomonoff-style axiom inducer, with three ingredients:
* a prior over axiom systems built from templates;
* a likelihood that makes statements with short derivations probable;
* a time penalty.

It also asks what such an inducer does when it sees instances φ(t) of ∀xφ, and whether it robustly finds the actual axioms, a deductively equivalent system, or at least gives them a lot of posterior mass.

It is a draft. Authorship and publication are his to decide.

**Start with [the paper (PDF)](paper/main.pdf)**, 147 pages. Page 1 holds a short answer. The main text, §§1–9, is about 43 pages; Appendices A–H hold the proofs, the computations and the record of how the results were checked.

## Answers in brief

1. **There is a coherent version.** The prior is 2^(−code length) over finite sets of templates, such as φ(z) or the induction template. The likelihood of a datum is the probability that a random derivation process outputs it. The process cites an axiom, fills its metavariables from a grammar, and applies MP, Gen and ∀-elimination. A normaliser that does not depend on the data does the work: a theory pays for the probability it spends on sentences that are never observed. Hänni's 0/1 scores, "proves the givens" and "does not contradict", have no normaliser.
2. **From φ(t) to ∀xφ, prediction is confirmed but derivability is not.**
   * Instances push mass off memorisers and off over-general schemas. They do not make ∀xφ more probable than the instance schema φ(z), which is just as simple and implies exactly the data.
   * A derivation likelihood even favours φ(z) by a constant factor per datum.
   * "All future data are instances" tends to probability 1. "The axioms prove ∀xφ" tends to a prior share, or to 0. This is a Bayesian ω-gap.
   * A single instance at a free parameter, or one quantified datum that entails ∀xφ, licenses ∀xφ.
3. **Data drawn from the model.** The posterior finds the generator: a deductively equivalent system, with no bound on the number of axioms. It does not find the particular axioms, because the prior decides among theories with the same law. A thresholded verifier is sound against adaptive provers with probability 1 − δ/π(C*). This needs fixed weights. With learned (Dirichlet) weights it holds only on average over the weight prior, or with a threshold that shrinks with n.
4. **Human-stated theorems are not such data.** The posterior goes to the best-fitting generator, which can be weaker than the axioms behind the data, or unsound.
   * For PA it finds the axioms that are used. PA-equivalents win on broad direct-use practice, within the candidate theories scored.
   * Narrow or atomic induction practice ends on weaker theories.
   * Theorem streams are memorised as axioms.
5. **Time penalty.** Which computation is free decides.
   * A penalty on checking or generating axioms leaves Hänni's collapse intact in the direction from function induction to axiom induction: padded Craig sets turn every consistent assigner, however slow, into axioms at constant cost (under a Kt-style penalty, log₂(|f| + 1) + O(1) bits). Templates do not block it either: over PA, one reflection sentence suffices for Σn-sound assigners.
   * Penalising function induction but not proof search makes axiom induction strictly stronger than time-penalised consistent function induction: for every computable predictor there is a computable sequence of arithmetic sentences on which it loses at least n − 0.37 bits while axiom induction loses a constant. The gain comes from free deduction, not from the axioms, and penalties on checking or generating axioms do not make the posterior prefer genuine axiom systems. (An earlier summary of ours, "the time penalty doesn't block your collapse", conflated the two directions; Hänni pointed this out.)
   * Charging deduction prices the collapse. If the axiom instances of each derivation, logical ones included, must be short in total, axiom induction becomes function induction with short certificates (on literal data at polynomial budgets: NP ∩ coNP); if each instance must be short, exponential-time function induction (EXPTIME); if only the theory's own axioms must be short, there is no time limit. For the grammar's own code length, only a logarithmic charge is proved.
6. **Hänni's trichotomy.** Keep (belief, plausibility). Renormalising and the 50/50 split are incoherent in general.

## How it was produced

* **Four research tracks** are in `research/tracks/`: `model`, `universal`, `pa` and `experiments`. Each was developed, then attacked by an adversarial referee who wrote independent code, then revised. Each final record is a `notes-final.md` ending in a verification log. The referee reports are the `referee.md` files.
* **Two follow-up tracks** on the time penalty, `time-followup` and `short-derivations`, answer Hänni's objection to the time-penalty summary and his proposal to require derivations from short axioms. Each was refereed once, by two referees (`referee-*.md`), and revised into its `notes-final.md`; the revisions were not refereed again.
* **The paper** was planned from a claims ledger and written section by section. Five reviewers then went over the whole draft (three on the mathematics, one on consistency, one on readability). A lead editor verified their fatal and major issues against the sources, editors applied the fixes, and a fresh final check followed. Appendix H lists every correction and everything that no referee checked.
* **Limits of the checking.** All roles were played by separate Claude instances. No human checked the mathematics, and nothing was verified in a proof assistant.

## Layout

| path | contents |
|---|---|
| `paper/` | LaTeX sources (`main.tex`, `sections/`, `bib/`, `preamble.tex`), `build.sh` and `main.pdf`. Also the planning files `OUTLINE.md`, `NOTATION.md` and `CLAIMS.md` (the claims ledger and the cross-track conflicts with their resolutions). |
| `code/` | Python package `bai` (Bayesian axiom induction over DT° template theories, reusing `../axiom-schemas/code/dtrc`), its tests, experiments E1–E8 and their results. See `code/README.md`. |
| `research/00-brief.md` | The question verbatim, the prior results used, and the starting hypotheses H1–H7. |
| `research/prior/` | Copies of Hänni's notes on Solomonoff axiom induction, time-bounded Solomonoff induction and function induction, from `kaarelh/notes`. |
| `research/tracks/` | The four research records and the two follow-ups, with referee reports, check scripts and referee code. |
| `research/paper-review/` | The whole-paper reviews, the issue lists, the editor decisions and logs, and the final check. |
| `research/workflows/` | *(on the working branch `claude/sleepy-gauss-u4kem1` only, not on `main`)* The orchestration scripts that ran the research, writing, review and editing agents. |

## Building and reproducing

* **Paper:** `cd paper && ./build.sh`. It needs `pdflatex` and `bibtex`.
* **Code:**
  * `cd code && python3 -m pytest -q tests` runs the 21 tests.
  * `sh run_all.sh` runs E1–E8, in about an hour on 4 cores.
* **Track checks:** each script in `research/tracks/*/checks/` is seeded, and its output is saved next to it as `.out`.
