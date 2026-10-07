# Learning axioms and axiom schemas from their instances

A standalone follow-up to `../inferential-learning/` (the report *What Follows from What*), prepared by Claude (Anthropic) in response to three questions from Kaarel Hänni. It is a draft; authorship and publication are his to decide.

**Start with [the paper (PDF)](paper/main.pdf)**, 135 pages. The main text is §§1–8, about 50 pages; the appendices A–G contain full proofs, details and the verification record.

## The questions

1. Does the method used for PA induction also learn an axiom ∀xφ(x) from sentences φ(t)?
2. Does it learn each axiom schema of ZFC from instances?
3. Is there one method for all of these that also learns many axioms and schemas at once from unlabelled instances?

## Answers in brief

1. **Yes for the instance schema φ(z), not for the sentence ∀xφ.** φ(z) is a first-order pattern. For one variable, two instances with different head symbols pin it down. Passing from all closed instances to ∀xφ is an ω-rule step. It is truth-safe exactly when the closed-term substructure is elementary (true in ℕ, false in ℝ), and it is not derivable in general.
2. **Yes.** Every ZF schema, in each formulation considered, is a higher-order (Miller) pattern. Instances pin it down iff their bodies' main symbols vary and every argument place is used. Pattern anti-unification and the determinate-template learner both recover each schema. First-order anti-unification works only for some formulations and encodings, and for most others no finite union of first-order schemas is sound. PA induction is the contrast: it is not a pattern, but it is learned with determinate templates.
3. **DTRC (Determinate Templates with Refutation Clustering)** clusters the data by refuting the templates that would merge them, then checks each cluster cautiously.
   - **Under refutation separation** it recovers the hidden labels and needs no more data than a learner that is given the labels.
   - **Without separation** it is sound only relative to a residue of unrefuted merges, and no computable learner can avoid depending on the refutation depth.
   - **PA, ZF and ZFC.** Separation is proved for Q's axioms with induction, and checked on sampled ZF and ZFC data.
   - **Experiments** confirm these results, with one honest failure: injected mistakes can make DTRC accept a false sentence.

## How it was produced

* **Research tracks.** Four tracks in `research/tracks/`: `cases`, `single`, `untagged` and `experiments`. Each was developed, attacked by an adversarial referee using independent code, and revised. Each final record is a `notes-final.md` ending in a verification log; the referee reports are in `referee.md`. Earlier refereed work on PA induction is in `research/prior/`.
* **Paper.** Sections were drafted from the final records, then reviewed by five reviewers (mathematics ×3, consistency, readability; reports in `research/paper-review/`). The fixes included three fatal ones. A fresh final check followed. Appendix G lists every correction made along the way and everything that was not independently refereed.
* **Limits of the checking.** All roles were played by separate Claude instances. No human checked the mathematics, and nothing was verified in a proof assistant.

## Layout

| path | contents |
|---|---|
| `paper/` | LaTeX sources (`main.tex`, `sections/`, `bib/`, `preamble.tex`, `NOTATION.md`, `OUTLINE.md`), `build.sh`, and `main.pdf` |
| `code/` | Python package `dtrc`: templates, matching, minimal covering templates, sound oracles for ℕ and V, refuter, DTRC, baselines. Also tests, experiments and results; see `code/README.md` |
| `research/00-brief.md` | the questions, conventions and the proposed method |
| `research/tracks/` | the four research records, referee reports and scripts |
| `research/prior/` | earlier refereed work on PA induction and untagged PA |
| `research/paper-review/` | whole-paper review reports, issue lists, editor decisions, final check |

## Building and reproducing

* Paper: `cd paper && ./build.sh` (pdflatex and bibtex).
* Code:
  * `cd code && python3 -m pytest -q tests` runs 43 tests.
  * `sh run_all.sh` runs every experiment, in about 10 minutes.
