# Principled human imitation

A research note on a question from Kaarel Hänni.

* **The question.** Model a human as a probabilistic program P that maps an input string to a random answer. From a reasonable number of question–answer pairs, build a sampler that can take the human's place inside a larger computation, such as a scaffold that splits a task into pieces and calls the human many times, so that the computation still behaves as it would with the human, also on the inputs that the imitator's own answers produce; or that at least fails only in ways that show. Unlimited compute is allowed; keeping the human in the loop for ever is not. Is there a protocol with a theorem? Can "the imitator keeps the properties that the data had", or "ask the human again, with some probability, on the inputs that task decomposition produces", be made to work?
* **The note:** [`note.md`](note.md). Section 0 states the question and the answers; Sections 9 and 10 say what remains a bet and how the proposal fares on the tests that the researcher applies to any such scheme.
* **Author:** Claude (Anthropic), in response to the question and under Hänni's direction.
* **Status:** a draft. The mathematics was checked by AI referees, not by a human. Each of the eight proof files was examined by a referee who went through it line by line and by a second who tried to break it; an editor then decided every finding and corrected the file; a further checker read the statements that only one of them had seen, and compared the note's text with the proofs. Five more referees read the assembled note (as its intended reader; for the mathematics as printed; for consistency; for the references; by re-running every script). Every report is in [`verification/`](verification/), and [`verification/README.md`](verification/README.md) says what was found and what was done. What nobody checked is listed there too.

## Answers in brief

1. **A protocol with a theorem exists for a computation that can be run in advance.** Rehearse: run the scaffold with the current Bayes mixture (the Solomonoff predictor for question–answer pairs) giving every answer; put one uniformly chosen call of that run to the human; update; after n rounds deploy the mixture of a uniformly chosen round. If the human has prior weight 2^(−K) and a run makes at most L calls, a deterministic human's run is reproduced exactly except with probability L·K ln 2/n, and for any human the law of the deployed run is within √(2·L·K ln 2/n) of the human system's in total variation, in expectation. The human answers n single questions and then leaves. This is the re-querying idea made exact. For a finite class and a deterministic human it is a published algorithm ("Stagger", Li and Zhang 2025; an instance of the reduction of Ross, Gordon and Bagnell 2011); the note adds the human who varies, two checks, and the limits.
2. **Two checks need no assumption about the class or the prior.** Coverage: a region of inputs fixed in advance is entered by the deployed run without ever having been asked about with probability at most L/n. Certificate: m further audited calls with no disagreement certify at most L·ln(1/δ)/m unfaithful calls per run; it can only be obtained for a human who is nearly deterministic on those inputs.
3. **When no single answer is critical, the price does not grow with the computation:** K ln 2/(θδ) questions if a fraction θ of the answers may be replaced, for a deterministic human; of the order of K/θ² in an example with a human who varies.
4. **In general nothing does better.** Where nothing was asked, anything can happen. If each of L calls can decide the outcome, some class of candidates of log₂(L/2δ) bits forces every protocol to ask at least L/(4δ) − L questions; the factor K is forced as well. Shifts of the task law cost the density ratio, and 2^ℓ for all shifts of ℓ bits. Rules that are never silently wrong either refuse almost every new input or rest on an assumption that the data cannot confirm.
5. **The property idea gives a second guarantee, cheaper and weaker.** An imitator built from a weighted family of tests alone, with no class of hypotheses, keeps the count of its answers in every test within about √(n·ln(1/π(B))) of the human's on any sequence of questions, and gives a kind of answer that the human never gives at most log₂(1/π(B)) + 2 times in all. A property costs its own complexity, not the human's. This is not imitation: a fair coin passes every such test that a sample can resolve, and tests of single answers do not control whole runs.
6. **Solomonoff induction is enough only together with rehearsal.** On questions from a fixed law the mixture stays free on the inputs that decomposition produces (in the toy system of Section 11 it is wrong in 35% to 100% of the runs after 10,000 questions), and it need not keep even a simple property of the data.
7. **What this does not give.** Every bound is in K, and for a person under a generic prior K is of the order of 10⁹ bits: there the bounds are empty. An hour per answer for a working life pays for about 1.4·10³ bits; a year per answer pays for less than one. The protocol works where the prior is already within an affordable K of the human, or for properties at their own price, or as a check of an imitator obtained in any way. It imitates behaviour on the inputs of one computation fixed in advance; it is not a copy of a person.

## Layout

| path | contents |
|---|---|
| `note.md` | The note: Sections 0 (answers), 1–3 (model, protocol, guarantees), 4 (limits), 5 (one program or a committee), 6–7 (shift; failing obviously), 8 (the property idea), 9–10 (what remains a bet; the seven tests), 11 (a toy system), 12–13 (related work; open questions). |
| `references.md` | Every work cited, with how its data were checked and where the statement used was read. |
| `proofs/` | Full proofs, one file for each part of the note: `rehearsal-core.md` (Sections 1–3), `hellinger-runs.md` (3.2, 5.2), `lower-bounds.md` (4 and part of 6), `one-mind.md` (5.1), `shift-abstain.md` (6–7), `property-batch.md` (8.1–8.3, 8.6, 8.7), `property-online.md` (8.4, 8.5), `assumptions.md` (the caveats of Section 1; Sections 9–10). Each ends with a section "Checking". |
| `proofs/code/` | The scripts behind the numerical claims of the proof files, with their saved outputs. |
| `verification/` | The reports: for each part a line-by-line check, an adversarial report and a second check; five reports on the assembled note; the scripts of the checkers in `verification/code/`. |
| `code/`, `results/` | The three computations of Section 11 and their outputs. |

Paths that begin with `research/` in the proof files and reports refer to working files (the provers' drafts, digests of the literature and of the researcher's notes, the orchestration scripts). They stay on the working branch `claude/eager-lamport-lo512k` and are not part of the published copy.

## Reproducing the computations

Python 3 with NumPy. From this folder:

```
python3 code/toy.py 60            > results/toy.out            # about 3 minutes
python3 code/toy_stakes.py 40     > results/toy_stakes.out
python3 code/toy_property.py      > results/toy_property.out
```

The scripts use fixed seeds. Each script in `proofs/code/` and `verification/code/` runs on its own and has its saved output next to it; `verification/reproduction.md` records a re-run of all of them.
