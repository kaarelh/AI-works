# Monitored imitation

A research note on a question from Kaarel Hänni about **principled human imitation** (section 3.2 of his talk *Simpler versions of the alignment problem we still can't solve*, MISO, 16 November 2026).

* **The question.** The talk's best protocol, *chained imitation*, does Solomonoff function induction on a human's input–output pairs, chains the learned map as in task decomposition, and queries the human on the distribution this induces ("train on test"). Find a protocol more likely to work, for a human that is a fixed deterministic program, under assumptions likely to be true of humans. Ideally, show that O(K(human)) reasonable queries suffice.
* **The first note:** [`note.md`](note.md): definitions, theorems, proofs and two experiments. Its protocol needs the human to *check* states.
* **The third note:** [`robust-runs.md`](robust-runs.md): which properties of the human's runs chained imitation keeps.
  * Its runs are the human's process with the wrong steps replaced, so they keep every property that survives the replacements.
  * Under arbitrary replacements that covers counting properties, with no factor n, but not outcomes.
  * It has experiment E4.
* **The second note:** [`without-a-check.md`](without-a-check.md): a follow-up question, whether there is a better protocol than chained imitation without such a check. It has a theorem on where in a run to ask, the end-weighted protocol, and experiment E3.
* **Author:** Claude (Anthropic), in response to the question.
* **Status:** drafts. Each note was checked by one independent AI referee, who checked every numbered statement and re-ran the experiments ([`verification/`](verification/)). No human has checked the mathematics.
* **The first note's referee** ([`verification/referee-report.md`](verification/referee-report.md), [`verification/response.md`](verification/response.md)): It found no error in the theorems. It found four errors or gaps in other statements and proofs: the selection argument of Section 6.3, the strength of the bound in Section 4.2, the proof of Proposition 10, and a claim about samplers. It also found a number of overclaims, a departure of the code from the protocol, and the experiments' use of a perfect check. All have been corrected or added.
* **The second note's referee** ([`verification/referee-report-without-a-check.md`](verification/referee-report-without-a-check.md), [`verification/response-without-a-check.md`](verification/response-without-a-check.md)) found the core mathematics correct. It found:
  * a missing standing assumption, that the human's own runs succeed;
  * an unproved claim, now Lemma 5;
  * a comparison with chained imitation that holds only between guarantees, not on every human;
  * an overclaim about what any better protocol must assume;
  * a missing condition in Proposition 4;
  * overclaims;
  * too few humans for a heavy-tailed column of E3.

  All have been corrected.
* **The third note's referee** ([`verification/referee-report-robust-runs.md`](verification/referee-report-robust-runs.md), [`verification/response-robust-runs.md`](verification/response-robust-runs.md)) found Sections 1–2 correct for the majority decoder. It found:
  * that no outcome property is robust to arbitrary replacements, which changed the note's conclusion;
  * that the main theorem fails for the per-run sampler;
  * a wrong statement about the per-step question;
  * an inverted conditional;
  * a seed artefact in E4.

  All have been corrected.

## Answers in brief

1. **Chained imitation loses a factor n over runs of n steps.** It needs about n·K/ε task queries for runs to match the human's with probability 1 − ε, where K is the human's complexity.
2. **In the worst case, no protocol that asks only for task steps does much better.** For every n and ε there is a class of humans of complexity about K on which every task-only protocol needs Ω(n·K/(ε log(n/ε))) task queries. This holds however the queries are chosen, synthetic inputs and uncertainty sampling included.
   * The hard humans spend their complexity on problem-specific insights at unpredictable steps.
   * So in the worst case chained imitation is within a log factor of every task-only protocol. On particular humans, others can be cheaper by constants.
3. **The two optimizations in the question don't get around this.**
   * Uncertainty sampling cannot tell a confident mistake from a confident correct answer.
   * In the program mixture, "the first time the run has a new simple property" (small separation complexity, as in [`../ultranatural/`](../ultranatural/)) forces posterior doubt, so it is a case of uncertainty. It fires at almost every step of a run that writes new things, or misses the properties that matter.
4. **Monitored imitation with bisection.** Suppose the human can *check* a state, saying whether it looks off track, and never turns a state it judges fine into one it judges off track.
   * **Protocol.** Check the end of each imitator run. If it fails, binary-search the run with checks for a step where the verdict flips. Ask the human for that one step, update, and rerun.
   * **Online guarantee.** Then:
     * no run that fails the check is ever output;
     * at most K runs fail the check in total;
     * the protocol makes at most K task queries, plus about log₂ n checks per failure and one check per output.
   * **Frozen-imitator guarantee.** An imitator whose runs fail the check with probability below ε, with probability 1 − δ. The cost is at most K task queries and O(K·log(K/δ)/ε) looks at results. Batched 1/ε results per query, that is O(K·(log(K/δ) + log(n/ε))) queries.
   * **Bits per task query.** Every task query lands on a mistake, so each teaches at least a bit; random queries mostly teach nothing.
5. **Why the check helps.** The check is where the human's knowledge enters.
   * The weakest useful check, "nothing bizarre here", is plausibly preserved by a careful human, and addresses the talk's "no bizarre behaviour" desideratum.
   * The check does nothing for deviations the human cannot see. Adding chained imitation's random queries bounds those at chained imitation's rate.
   * The check decides only where to ask, never which output to keep.
6. **Trees.** For decomposition trees, a failure is located with about log(number of calls) batch checks.
7. **Experiments.** Both use exact posteriors.
   * *E1, the lower-bound class.* Chained imitation needs 5k → 316k task queries as n goes 16 → 1024. Monitored bisection needs about 48 at every n.
   * *E2, rules triggered by simple properties.* Monitored bisection needs about 15 task queries; chained imitation needs 370–840.
   * *Caveat.* The main runs use the strongest possible check.
   * *A weak check* that sees half the rules shows the gap: monitored bisection alone leaves 84% of runs differing from the human's. Adding audits closes it, with about as many task queries as chained imitation.
8. **Open.**
   * Stochastic humans.
   * Deviations no human check can see.
   * Learned checks.
   * Malign hypotheses that no check sees.

## Answers in brief: the second note

1. **Not without some assumption.** The first note's lower bound holds for humans whose insights are rare, problem-specific, at unpredictable steps, and *silent*. Handed a state that lacks something they would have contributed by now, silent humans carry on without it. A better protocol must assume something that excludes this, for example:
   * predictable steps;
   * shared knowledge;
   * a check;
   * isolation;
   * persistence.
2. **What a protocol is charged for.** Asking for one step per run, drawn from a distribution q, the total over rounds of q(steps where the imitator erred) is at most K. Chained imitation's bound charges a failed run up to n only when it has a single mistake.
3. **Persistence instead of a check.** Assume that from any state the imitator reaches with r steps to go, the human's own continuation still succeeds: it repairs what is missing.
   * Then every failed run has a mistake in its last r steps.
   * This needs no new kind of query, but it is a substantive assumption, and a joint property of the human and the learner.
4. **End-weighted chained imitation.** Ask at a uniform step half the time, otherwise at distance d from the end with probability ∝ 1/(d+1).
   * Its guarantee is within a factor 2 of chained imitation's (on a particular human it can be worse).
   * Under persistence it needs 2r·ln(n)·K/ε task queries.
   * Asking at the last step alone gives K/ε under persistence.
   * Binary search with task queries, on a fixed decoder, finds the first mistake.
5. **Experiment E3:** the hidden-insight class, silent versus *catch-up* humans, who write a missing insight at any later step.
   * *Silent humans:* end-weighting costs 1.2–1.5× chained imitation.
   * *Catch-up humans,* 200 per n: the last step needs about 300 task queries at every n, end-weighting 540–650. Chained imitation needs 1,300–2,500, heavy-tailed.

## Answers in brief: the third note

1. **Chained imitation keeps every property that survives its mistakes.** Its runs are the human's process with the mistaken steps replaced by the decoder's guesses. If a property survives any ⌊ρn⌋ replaced steps, at most n⌊K⌋/(⌊ρn⌋+1) ≤ K/ρ rounds lose it, in expectation. That is no factor n for a fixed fraction ρ. This holds for the majority decoder, not for an imitator that samples one hypothesis per run.
2. **But outcomes are never robust to arbitrary replacements.** Replacing the last step spoils any property of the final state, and earlier misleading content can too. So a condition on the human alone gives the result only for counting properties, such as "at most ρn steps differ from the human's".
3. **For "a nice run that solves the problem",** a condition has to restrict the replacements to the guesses an imitator actually makes, which brings the learner back in.
   * It is believable when the guesses are inconsequential or fall at effectively random places.
   * It fails for decisive, rarely shown knowledge, the hidden-insight case.
   * I know of no such condition I would vouch for.
4. **E4.** On E2's human, the expected number of bad rounds grows with n for "every step right" and stays flat for "at most 20% of steps wrong". This is the favourable, random-placement regime.
5. **Generic, in the Bayesian sense.** An imitator that samples one hypothesis per run produces nice runs exactly as often as the learner believes the human would. That imitator lacks the first guarantee.

## Layout

| path | contents |
|---|---|
| `note.md` | The first note. |
| `without-a-check.md` | The second note: protocols without a check. |
| `robust-runs.md` | The third note: which properties chained imitation keeps. |
| `code/hidden_insights.py` | E1: the class of Theorem 3 (hidden insights), exact posteriors; protocols CI, US, CS, MB. |
| `code/property_rules.py` | E2: a human whose rules are triggered by conjunctions of literals on 12-bit content; protocols CI, US, NOV, CS, MB. |
| `code/end_weighted.py` | E3: silent and catch-up versions of the hidden-insight class; protocols CI, EW (end-weighted), LAST, BIS. |
| `code/robust_runs.py` | E4: chained imitation on E2's human, judged by fragile and robust properties. |
| `code/make_figures.py` | Tables and figures from the saved outputs, and the novelty-firing curve. |
| `results/hidden_insights_summary.json`, `results/hidden_insights_curves.json`, `results/hidden_insights.png` | E1 outputs. |
| `results/property_rules.out`, `results/property_rules_summary.json`, `results/property_rules_curves.json`, `results/property_rules.png`, `results/property_rules.time` | E2 outputs. |
| `results/tables.md` | The tables quoted in the first note. |
| `results/robust_runs.out`, `results/robust_runs_summary.json`, `results/robust_runs.time` | E4 outputs. |
| `results/end_weighted.out`, `results/end_weighted_summary.json`, `results/end_weighted_curves.json`, `results/end_weighted_table.md`, `results/end_weighted.time` | E3 outputs, and the table quoted in the second note. |
| `verification/referee-report.md`, `verification/response.md` | The referee's report on the first note, and what was changed in response. |
| `verification/referee-report-without-a-check.md`, `verification/response-without-a-check.md` | The same for the second note. |
| `verification/referee-report-robust-runs.md`, `verification/response-robust-runs.md` | The same for the third note. |
| `verification/referee3_*.py`, `verification/referee3_*.out`, `verification/referee3_*.json`, `verification/referee3_rerun/` | The third referee's checks, its counterexample for the per-run sampler, and its re-run of E4 from the reviewed draft. |
| `verification/referee2_*.py`, `verification/referee2_*.out`, `verification/referee2_rerun/` | The second referee's checks, its counterexample computations, and its re-run of E3 from the reviewed draft. |
| `verification/referee_*.py`, `verification/referee_*.out`, `verification/referee_rerun/` | The referee's own checks and outputs, and its re-run of both experiments from the first draft's code. |

Nothing in this folder is confined to the working branch `claude/compassionate-edison-1o8ihs`.

## Reproducing

Python 3 with NumPy and Matplotlib. From `code/`, the first takes about 10 seconds and the second about 4 minutes:

```bash
python3 hidden_insights.py ../results
```

```bash
python3 property_rules.py ../results > ../results/property_rules.out
```

```bash
python3 make_figures.py ../results
```

For the third note (about 15 minutes):

```bash
python3 robust_runs.py ../results > ../results/robust_runs.out
```

For the second note (about 2 minutes, with 200 catch-up humans per n):

```bash
python3 end_weighted.py ../results > ../results/end_weighted.out
```

All three are seeded and reproduce the saved outputs.
