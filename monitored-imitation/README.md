# Monitored imitation

A research note on a question from Kaarel Hänni about **principled human imitation** (section 3.2 of his talk *Simpler versions of the alignment problem we still can't solve*, MISO, 16 November 2026).

* **The question.** The talk's best protocol, *chained imitation*, does Solomonoff function induction on a human's input–output pairs, chains the learned map as in task decomposition, and queries the human on the distribution this induces ("train on test"). Find a protocol more likely to work, for a human that is a fixed deterministic program, under assumptions likely to be true of humans. Ideally, show that O(K(human)) reasonable queries suffice.
* **The note:** [`note.md`](note.md): definitions, theorems, proofs and two experiments.
* **Author:** Claude (Anthropic), in response to the question.
* **Status:** a draft. One independent AI referee checked every numbered statement and the experiments ([`verification/`](verification/)). No human has checked the mathematics.

## Answers in brief

1. **Chained imitation loses a factor n over runs of n steps.** It needs about n·K/ε task queries for run failure ε, where K is the human's complexity.
2. **No protocol that asks only for task steps does much better.** Some humans of complexity K need Ω(n·K/(ε log(n/ε))) task queries, however the queries are chosen, synthetic inputs and uncertainty sampling included.
   * The hard humans spend their complexity on problem-specific insights at unpredictable steps. Until the learner has found such a step, all steps of a run look alike to it.
   * So chained imitation is optimal up to a log factor.
3. **The two optimizations in the question don't get around this.**
   * Querying where the predictor is uncertain cannot find mistakes made with confidence, which are the ones that matter.
   * "The first time the run has a new simple property" is, in Solomonoff induction, a special case of uncertainty: small separation complexity, in the notation of [`../ultranatural/`](../ultranatural/). It fires at almost every step of a run that writes new things, or misses the properties that matter.
4. **Monitored imitation with bisection.** Suppose the human can *check* a state, saying whether it looks off track, and never turns a state it judges fine into one it judges off track.
   * **Protocol.** Check the end of each imitator run. If it fails, binary-search the run with checks for the step where the verdict flips. Ask the human for that one step and update.
   * **Online guarantee.** Then:
     * no failing run is ever output;
     * at most K runs fail in total;
     * the protocol makes at most K task queries, plus about log₂ n checks per failure and one check per output.
   * **Frozen-imitator guarantee.** With batched checks, O(K·(log(K/δ) + log(n/ε))) queries in total give an imitator that fails on fewer than an ε fraction of future problems.
   * **Every task query lands on a mistake.** So each teaches at least a bit, and typically many: the "many bits per query" the talk hoped for.
5. **Why the check helps.** The check is where the human's knowledge enters. A Bayesian imitator's mistakes come from hypotheses that agree with everything the human has said, so nothing computed from the imitator's beliefs can flag them.
   * The weakest useful check, "nothing bizarre here", is very plausibly preserved by a careful human.
   * It already covers the talk's "no bizarre behaviour" desideratum.
6. **Robustness.**
   * *Imperfect checks.* The extra failures are runs that pass through states from which the human itself would go off track.
   * *Silent deviations.* Deviations no check can see are bounded at chained imitation's rate by adding its random queries.
   * *No optimization against the check.* The check decides only where to ask, never which output to keep.
   * *Trees.* For decomposition trees, a failure is located with about log(number of calls) checks.
7. **Experiments.**
   * *E1, the lower-bound class.* Chained imitation needs 5k → 316k task queries as n goes 16 → 1024. Monitored bisection needs about 48 task queries at every n.
   * *E2, rules triggered by simple properties.* Monitored bisection needs about 15 task queries; chained imitation needs hundreds. The "new simple property" rule either misses rare rules or queries almost every step.
8. **Open.**
   * Stochastic humans.
   * Deviations no human check can see.
   * Learned checks.
   * Malign hypotheses that no check sees.

## Layout

| path | contents |
|---|---|
| `note.md` | The note. |
| `code/hidden_insights.py` | E1: the class of Theorem 3 (hidden insights), exact posteriors; protocols CI, US, CS, MB. |
| `code/property_rules.py` | E2: a human whose rules are triggered by conjunctions of literals on 12-bit content; protocols CI, US, NOV, CS, MB. |
| `code/make_figures.py` | Tables and figures from the saved outputs, and the novelty-firing curve. |
| `results/hidden_insights_summary.json`, `results/hidden_insights_curves.json`, `results/hidden_insights.png` | E1 outputs. |
| `results/property_rules.out`, `results/property_rules_summary.json`, `results/property_rules_curves.json`, `results/property_rules.png`, `results/property_rules.time` | E2 outputs. |
| `results/tables.md` | The tables quoted in the note. |
| `verification/` | The referee's report, its scripts and outputs, and the response. |

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

All three are seeded and reproduce the saved outputs.
