# Monitored imitation

A research note on a question from Kaarel Hänni about **principled human imitation** (section 3.2 of his talk *Simpler versions of the alignment problem we still can't solve*, MISO, 16 November 2026).

* **The question.** The talk's best protocol, *chained imitation*, does Solomonoff function induction on a human's input–output pairs, chains the learned map as in task decomposition, and queries the human on the distribution this induces ("train on test"). Find a protocol more likely to work, for a human that is a fixed deterministic program, under assumptions likely to be true of humans. Ideally, show that O(K(human)) reasonable queries suffice.
* **The fifth note, the answer to the latest question:** [`verified-slack.md`](verified-slack.md). It recommends *verified slack imitation*: slack imitation, plus a verifier of finished results, plus a multi-stream search on rejected runs. Correctness rests only on the verifier's soundness, and the cost is at most 3n₀K task queries in the worst case. It synthesizes eleven research threads (A–H, J, L, N, Q, R) in [`research/`](research/), with lower bounds showing what no scheme can do.
* **The fourth note:** [`slack-imitation.md`](slack-imitation.md), version 2: slack imitation and its theorems, used by the fifth note. It gives the scheme I am most sure would work with a deterministic human, a proof that it works if the human has *bounded setback*, the case that humans have it, and experiment E6. It synthesizes the earlier notes and five research threads in [`research/`](research/) (working branch only).
* **The fourth note's referee and red team** ([`verification/referee-report-slack-imitation.md`](verification/referee-report-slack-imitation.md), [`research/threadE-redteam.md`](research/threadE-redteam.md), [`verification/response-slack-imitation.md`](verification/response-slack-imitation.md)). Both found the main theorems correct, and the referee reproduced E6 exactly. The referee found:
  * three errors in secondary claims: the read-out premise, "omissions are uncertain", and a factor 1/(1−ρ) in the fallback;
  * two factual errors about E6;
  * overclaims.

  The red team found a misreading of the decoder's behaviour, which lowered my confidence numbers, and proposed ask-before-committing, now part of the scheme. All have been addressed.
* **Referee 5, on the fourth note's version 2** ([`verification/referee-report-slack-imitation-v2.md`](verification/referee-report-slack-imitation-v2.md)), found Proposition 5 (ask-before-committing) correct, checking it on 116,612 runs, and the new E6 cells reproduced exactly. It found:
  * two errors: "O(K)" should be O(K log K) on i.i.d. problems, and a frozen imitator that keeps asking is not within the ask budget;
  * overclaims about E6's fooled humans under asking, whose flattening is partly an artifact of the class;
  * the missing trade-off for asking when a verifier is available.

  All have been corrected, and its online test of ask-before-committing without a verifier is quoted.
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

## Answers in brief: the fifth note

1. **The scheme: verified slack imitation (VSI).** Slack imitation, with these additions:
   * *A verifier of finished results:* a machine check, a referee's check of the claimed solution's dependency cone, or the human's verification, imitated.
   * *Reruns.* Each problem is rerun until its result is verified.
   * *A search on rejected runs:* an invalid entry, if the local check finds one; otherwise uniform steps, a scan from step 0, and a list made of the last review, the labelled decisions and the human's post-mortem pointers.
   * *The notebook instruction,* also part of the reference chain: typed, certified entries; obstruction records instead of verdicts; raw records; content-triggered reviews; labelled decisions.
2. **The theorem.**
   * *Correctness:* if the verifier never passes a wrong result, no failed run is ever output, whatever the human's setbacks.
   * *Rejections:* at most K.
   * *Cost per rejection:* at most 3n₀ task queries whatever the human. It is 1 when the cone check finds an invalid entry, and a constant for ripe by-product failures and hedges. Under bounded setback it is at most 3(D+1)n/(σ+1).
   * *No factor 1/ε,* and no dependence on the number of problems.
3. **Lower bounds** (threads G, J, Q, F):
   * slack imitation is optimal for bounded-setback humans up to logarithms, and slack is necessary;
   * verification removes the 1/ε but not the n;
   * insights triggered only by doing cost every protocol about n per insight;
   * so do trusted true records of failed attempts, and confident commissions accepted by a fooled human.

   In VSI these cost queries, never correctness.
4. **How sure I am.** Probabilities that the scheme works on a real careful researcher:
   * VSI with a machine verifier: 85% for theory and software;
   * VSI with a referee's cone check: 70%;
   * VSI with a human verifier: 65% for theory and software, 30% for empirical work;
   * without a verifier: 45% and 20%.

   The evidence (thread L) is that setbacks are bimodal, which is why the verifier version is the one I am sure of.

## Answers in brief: the fourth note

1. **The scheme: slack imitation with ask-before-committing.**
   * *The scaffold.* Chained imitation with an append-only notebook, a hidden clock, and more steps than the human needs (n = n₀ + σ, σ = ρn).
   * *Ask before committing.* During a run, ask the human for any step where the imitator's top output has posterior mass below 1 − α; this is the question's first optimization, made safe by slack.
   * *After the run,* one task query at a uniformly random step. An optional "nothing bizarre" check catches junk.
   * *With a verifier of results,* rerun each problem until its result is verified.
2. **The theorems.** The assumption is *bounded setback D* at the imitator's confident mistakes: an entry the human would not have written costs it at most D extra steps, and part of its own next step costs it nothing. Then:
   * the expected number of failed runs is at most min{n, (D+1)n/(σ+1)}·K ≤ (D+1)K/ρ, over any sequence of problems;
   * asking costs at most about 0.69K/α queries over the whole lifetime;
   * on i.i.d. problems, O((D+1)·K·log(K/δ)/(ρε)) task queries suffice: O(K log K) for fixed ε, δ, D and ρ;
   * with a verifier, no failed run is ever output, and at most K runs are rejected.
3. **Why.** With slack, a run fails only if it has at least (σ+1)/(D+1) wrong steps, so a uniform query finds one with probability at least ρ/(D+1). Asking removes the steps the imitator is unsure of.
4. **The case for humans, after a red team (thread E).** The axis that matters is confidence:
   * unconfident steps are asked;
   * confident omissions need the human to recover the idea later, which fails for by-product insights and hedges;
   * confident commissions need the human not to be fooled for long. The worst case is a confident negative result, "tried A; it fails", where A is what would have worked.

   My graded probabilities, for theoretical work: 70% for omissions, and 55% for commissions (with asking). I put 50% on a 5× gain over chained imitation for a real human. With a verifier, all of this affects only cost, never correctness: that is the version I am most sure of.
5. **E6, on the same humans,** in task queries until at most 2% of runs fail, for n₀ = 8 → 128:
   * chained imitation: 2,900 → 51,000 for bounded-setback humans;
   * slack imitation: about 200;
   * fooled humans: 1,600 → 4,300;
   * silent humans: slack doubles the cost.

   With a verifier, bounded-setback humans need about 14 task queries for all 100 problems. Asking (α = 0.3) makes fooled humans grow much more slowly (240 → 360, against 180 → 2,600), partly because of how the class is built. Without a verifier, asking cut failed runs 3–18× in referee 5's online test.

## Answers in brief: the first note

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
| `verified-slack.md` | The fifth note: verified slack imitation, the scheme I am most sure of (version 3). |
| `slack-imitation.md` | The fourth note: slack imitation and its theorems (version 2 of the answer). |
| `code/slack_imitation.py` | E6: slack imitation on noticing, misled, fooled and silent humans, exact posteriors; protocols CI with and without slack, LAST, MIX, SI-V and SI-V-ABC. |
| `code/setback_check.py` | An arithmetic sanity check of the bookkeeping in the fourth note's Lemma S, on random append-only humans. It cannot test bounded setback. |
| `results/slack_imitation.out`, `results/slack_imitation_summary.json`, `results/slack_imitation_mix.out`, `results/slack_imitation_mix.json`, `results/slack_imitation_table.md`, `results/slack_imitation.time` | E6 outputs, and the table quoted in the fourth note. |
| `results/slack_imitation_verifier.out`, `results/slack_imitation_verifier.json` | E6 with a verifier (Protocol SI-V). |
| `results/slack_imitation_verifier_abc.out`, `results/slack_imitation_verifier_abc.json`, `results/slack_imitation_verifier_abc.time` | E6 with a verifier and ask-before-committing (SI-V-ABC, α = 0.1 and 0.3). |
| `results/slack_imitation_same.out`, `results/slack_imitation_same.json`, `results/slack_imitation_same.time` | E6: chained imitation without slack on the same humans as the slack cells. |
| `results/setback_check.out` | Output of the arithmetic check. |
| `verification/referee-report-slack-imitation.md`, `verification/response-slack-imitation.md` | Referee 4's report on the fourth note, and the response to it and to the red team. |
| `verification/referee4_*.py`, `verification/referee4_*.out`, `verification/referee4_rerun/` | Referee 4's re-run of E6, its run-level setback check, and its same-humans comparison. |
| `verification/referee-report-slack-imitation-v2.md` | Referee 5's report on the fourth note's version 2. |
| `verification/referee5_*.py`, `verification/referee5_*.out` | Referee 5's re-run of the new E6 cells, its run-level check of Proposition 5, the mechanism behind the fooled humans' costs under asking, and its online test of ask-before-committing without a verifier. |
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

**Working branch only:** `research/` stays on the working branch `claude/compassionate-edison-1o8ihs`. It holds the research threads behind the fourth and fifth notes, with their scripts and outputs:
* A: checks;
* B: knowledge elicitation;
* C: persistence;
* D: literature;
* E: the red team of the fourth note;
* F: the certified notebook;
* G: by-product insights;
* H: deployment and other learners;
* J: optimality;
* L: evidence on researchers;
* N: trees;
* Q: alternatives;
* R: the composition experiment;
* S: the red team of the fifth note.

The fifth note gives the proofs of its main results itself, and cites the threads for the full proofs of its lower bounds. Remove `research/` when publishing, or publish it as supporting records if the user prefers.

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

For the third note (about 10 minutes):

```bash
python3 robust_runs.py ../results > ../results/robust_runs.out
```

For the second note (about 2 minutes, with 200 catch-up humans per n):

```bash
python3 end_weighted.py ../results > ../results/end_weighted.out
```

For the fourth note (on 4 cores: E6 about 25 minutes, MIX about 7, same humans about 7, ask-before-committing about 3, the verifier under a minute, the table and the check about a second):

```bash
python3 slack_imitation.py ../results > ../results/slack_imitation.out
```

```bash
python3 slack_imitation.py ../results --mix > ../results/slack_imitation_mix.out
```

```bash
python3 slack_imitation.py ../results --same > ../results/slack_imitation_same.out
```

```bash
python3 slack_imitation.py ../results --abc > ../results/slack_imitation_verifier_abc.out
```

```bash
python3 slack_imitation.py ../results --table
```

```bash
python3 slack_imitation.py ../results --verifier > ../results/slack_imitation_verifier.out
```

```bash
python3 setback_check.py > ../results/setback_check.out
```

All are seeded and reproduce the saved outputs.
