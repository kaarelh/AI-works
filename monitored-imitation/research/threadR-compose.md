# Thread R: how the components of the final scheme compose

*Research note by Claude (Anthropic), thread R of the follow-up to [`../slack-imitation.md`](../slack-imitation.md), version 2. Draft; not refereed.*
* *Code:* [`threadR_compose.py`](threadR_compose.py), experiment R1, exact posteriors. It imports E6's, G1's and F1's classes unchanged from [`../code/slack_imitation.py`](../code/slack_imitation.py), [`threadG_byproducts_sim.py`](threadG_byproducts_sim.py) and [`threadF_certified.py`](threadF_certified.py). Only the hedge class is new.
* *Outputs:* [`threadR_compose.out`](threadR_compose.out) and [`threadR_compose.json`](threadR_compose.json) (every cell, with standard errors). The `.out` file holds all the tables, the reproduction checks, the interference ratios and three structural checks.
* *Runtime:* 44 minutes on 4 cores from scratch, 2.9 CPU hours. Run with `python3 -B threadR_compose.py`.

Setting and notation are those of slack-imitation.md §§1–3, with thread Q's VSP (threadQ-alternatives.md §3), thread G's reviews and labelled decisions (threadG-byproducts.md §§4–5), and thread F's certified notebook (threadF-certified.md §§2, 4, 5).

## Answers in brief

1. **The table.** Each cell is a mean over the same 40 humans (20 for M7 and M8), at n₀ = 8 → 32 → 128. For G1's classes the horizon is the routine length N = 8 → 32 → 128. Brackets give asks per problem.

   | mechanism | SI: failed runs | SI-ABC+D: failed runs | SI-V: task queries | **VSI: task queries** |
   |---|---|---|---|---|
   | M1 persistent idea, noticing | 12.5 → 14.5 → 14.3 | 1.7 → 0.8 → 0.3 [3.0–7.5] | 13 → 14 → 14 | **15 → 20 → 20** |
   | M2 fooled commission at a verdict | 114 → 245 → 436 | 16 → 17 → 47 [3.0–7.5] | 181 → 750 → 2,636 | **40 → 55 → 54** |
   | M3 silent | 1,428 → 6,304 → 25,629 | 1,032 → 5,908 → 25,407 | 1,610 → 6,450 → 26,091 | **663 → 2,497 → 9,734** |
   | M4 readable by-product, reviews | 227 → 309 → 331 | 0 → 32 → 36 [2.1–3.8] | 221 → 288 → 338 | **122 → 129 → 137** |
   | M5 doing-only by-product | 979 → 3,930 → 15,622 | 1,662 → 6,957 → 28,603 | 1,029 → 3,795 → 16,127 | **424 → 1,528 → 6,246** |
   | M6 pre-empting hedge at a decision | 73 → 329 → 1,239 | 17 → 19 → 20 [0.2] | 76 → 315 → 1,439 | **24 → 29 → 31** |
   | M7 invalid checkable claim | 139 → 693 → 2,635 | 9.5 → 10.8 → 10.2 [1.7–7.5] | 136 → 582 → 2,868 | **10 → 11 → 10** |
   | M8 false negative as a valid obstruction | 139 → 693 → 2,635 | 152 → 710 → 2,408 [1.7–7.4] | 136 → 582 → 2,868 | **34 → 33 → 31** |

   The failed runs are counted during R = 4·M·n online rounds (n = 2n₀). The task queries are the total needed to solve all 100 problems with every output correct. Chained imitation without slack, on the same humans, fails 567 → 2,554 → 10,089 times on M1.
2. **Which component handles which mechanism.** Each mechanism has one component that makes it cheap:
   * M1: slack;
   * M2: the verifier with the verdict-step pointer. Without a verifier, asking, which E6's prior flatters;
   * M4: the last-review query;
   * M6: the decision-step query;
   * M7: the local check L;
   * M8: the verifier with the obstruction record in the pointer list. Without a verifier nothing helps (Theorem F3).
   * M3 and M5 stay at about n₀ per insight under every protocol. VSI's scan stream removes slack's factor 2 there, and nothing else helps.
3. **The full VSI stays bounded and roughly flat on every mechanism except M3 and M5.** Over a 16-fold increase in n₀ its cost changes by a factor of 0.9–1.3 on M1, M2, M4, M6, M7 and M8. On M3 and M5 it grows by 14.7. Each M3 or M5 rejection costs about 0.8n₀ queries, against Theorem Q4's worst case of 3n₀. That is the factor theory says cannot be avoided (Theorems 3 of note.md and G3).
4. **Without a verifier the full scheme (SI-ABC+D) is bounded on M1, M2, M4, M6 and M7.** It grows in proportion to n₀ on M3 and M5, as theory says it must, and also on M8. M8 is the case of Theorem F3: a true obstruction record that a trusting human never revisits. No component without a verifier touches it.
5. **Interference is small among VSI's components, and large only for asking.**
   * *VSI's extra streams* cost the bounded-setback humans of M1 a factor of 1.2–1.4. That is well within Lemma Q2's factor 3, and they cut the cost by 1.8 to almost 300 times on every other mechanism.
   * *The L-first step* never fires except on M7, and it costs nothing elsewhere.
   * *The last-review query* costs doing-only humans (M5) a factor of 1.7–2.1, because half of the queries are spent on a step that is never a mistake. The review scaffold itself lengthens their horizon, adding another 1.25.
   * *Asking on top of VSI* costs 5–35 times as much on M1, M2, M7 and M8, and 1.5 on M4 and M6. It never helps there, because in these classes almost all of K is problem-specific (slack-imitation.md §6).
6. **Reproduction.** All 120 published numbers the code can regenerate reproduce exactly. These are E6's CI, SI, SI-V and SI-V-ABC cells, EQ's U and USH, referee 5's online test, G1's oracle and online tables, and F1's n₀ = 32 column (§4).
7. **The caveat.** The pointer list is perfect in M2, M6 and M8. Each run has one verdict, one decision, or one obstruction record, and on a failed run it is a mistake. That is checked in the output: on 4,958 failed M6 runs and 8,603 failed M8 runs, the first list entry is always a mistake. A real post-mortem list is weaker. On TRUST-like notebooks with many obstruction records (Theorem F3), the list would cost in proportion to their number.

## 1. Setup

### 1.1 Mechanisms

| | mechanism | class | source |
|---|---|---|---|
| M1 | persistent idea, noticing human (D = 0) | E6 "noticing" | E6, unchanged |
| M2 | fooled commission at a verdict step | E6 "fooled" | E6, unchanged |
| M3 | silent human: the idea is writable at one step only | E6 "silent" | E6, unchanged |
| M4 | readable by-product insight, recovered at reviews | G1 REVIEW: L = 4, η = ½, q = 2 | G1, unchanged |
| M5 | doing-only by-product insight, in the review scaffold | G1's DO humans on G1's REVIEW schedule | **new variant:** reviews reread the records, but reading does not trigger the insight |
| M5′ | the same humans without reviews | G1 DO (slack), DO0 (no slack) | G1, unchanged; for reproduction and comparison |
| M6 | pre-empting hedge at a labelled decision | HEDGE | **new** (below) |
| M7 | invalid checkable claim, trusting human | F1 type C, trusting | F1, unchanged |
| M8 | false negative recorded as a valid obstruction, then a valid weaker result, trusting human | F1 type W, trusting, r = 1 | F1, unchanged |

*Why M5 has reviews.* The final scheme puts content-triggered reviews in every human's instruction, so a doing-only human also takes review steps. They simply do not help it. Using G1's DO class alone (M5′) would hide what the review query costs such humans. Both are run, on the same problems (the same draws of t_p and k_p) as M4.

**HEDGE** (threadG-byproducts.md §5, Proposition G7). G's BP-hedge is not implemented in G1, so this is a small version.
* *Structure.* Steps 0, …, d−1 are routine. The decision step is d = n₀ − 1, triggered by content ("the routine is done; choose the plan").
* *The idea.* With probability 0.1 a problem has a problem-specific idea A (k = 2), available from step t_A, uniform on {d−3, …, d}: a late trigger. Otherwise it has none (k = 1).
* *The human.*
  * On a notebook with neither A nor a decision, it writes A once A is available (persistent).
  * At d it writes "A; decision A" if A is available, "decision A" if A is already written, and otherwise the default "decision B".
  * On a notebook holding decision B it never writes A (pre-emption). After the decision every step is routine.
* *Success:* A with decision A (k = 2), or decision B (k = 1).
* *Learner:* exact posterior over (t_A, k), majority decoder, ties to routine and then to B.
* *Check.* On every one of 4,958 failed runs during learning, the mistakes are exactly the steps t_A, …, d, and the decision step is one of them, as Proposition G7(a) says.
* *Why a late trigger.* With t_A uniform over the whole routine, uniform queries cost only about (n/d)·H_d per failure, which grows like log n₀. A late trigger makes the hedge a commission at a confident decision with at most 4 mistakes, so that only the decision-step query or the pointer locates it.
* *Why prior rate 0.1.* It is below α = 0.3 (the base rate 0.9 of E6 and F1), so asking does not fire at the decision (Proposition G7(c)).

### 1.2 Protocols

Slack is σ = n/2 everywhere except CI.

| protocol | runs | query or search |
|---|---|---|
| CI | no slack, n = n₀ | one uniform task query per round |
| SI | slack | one uniform task query per round |
| SI+D (extra row) | slack | the design elements, in order: (1) if L flags a committed entry, query the first flagged step (CSI); (2) else, if the run has a last review step or a labelled decision step, query it with probability ½ (MIX-REV; Proposition G7(b)); (3) else a uniform step |
| SI-ABC | slack, asking at α = 0.3 | uniform |
| SI-ABC+D | slack, asking at α = 0.3 | the design elements |
| SI-V (reference) | slack, rerun until accepted | uniform search on each rejected run (E6's SI-V) |
| SI-V-ABC (reference) | the same, with asking | uniform over all n steps, as in E6 |
| **VSI** | slack, rerun until accepted | (1) if L flags a committed entry, query it; (2) else round robin over three streams: U, uniform committed steps; S, a scan from step 0; and a list holding the last review step, the labelled decision steps and the verdict steps (Lemma Q2) |
| **VSI+ABC** | VSI's runs with asking at α = 0.3 | as VSI |

**Where each element exists.**

| | reviews | labelled decisions | checkable entries (L) | verdict steps in VSI's list |
|---|---|---|---|---|
| M1–M3 | – | – | – | the decoder's value entries, exactly EQ's "H" stream |
| M4, M5 | yes | – | – | the insight entry |
| M5′ | – | – | – | the insight entry |
| M6 | – | the decision step | – | the decision step and A's entry |
| M7, M8 | – | – | yes (F1's L) | every claim or record entry: obstruction record, value, weak result |

E6's value entries are verdicts, not labelled decisions. So no design element applies to M1–M3: there SI+D ≡ SI and SI-ABC+D ≡ SI-ABC by construction. These cells, and the same pairs for M5′, are copied, not rerun. The verifier is a perfect success oracle, as in E6 and EQ, and its calls are free.

### 1.3 Measurement

**Without a verifier: failed runs online, over a fixed budget of R = 4·M·n rounds** (n = 2n₀, the slack run length; the same R for CI). Each round draws a uniform problem, builds its run, records whether the run fails, and makes one task query. Asks are counted separately. This is referee 5's and F1's design, and R = 4·M·n is F1's rule.

*Why this and not oracle stopping:*
* *It works for asking protocols.* Oracle stopping is not meaningful there (referee 5): the run whose failure it scores asks the human.
* *It is what the theorems bound.* Theorem 2, Proposition 5(b), Theorem G4, Proposition G7(b) and Theorem F2 all bound the expected number of failed runs online.
* *One measure fits all.* It is the same for all five protocols, so the components can be compared.
* *R grows with n.* So a mechanism whose cost grows like n₀ shows it, instead of saturating at R as referee 5's fixed 3,000 rounds would at n₀ = 128.
* *It reproduces earlier work.* The first 3,000 rounds reproduce referee 5's numbers.

*Oracle stopping is reported as well.* For the protocols that never ask (CI, SI, SI+D), the same run also records E6's and G1's oracle-stopping cost: task queries until at most 2% of problems fail. Where that takes more than R rounds, the run continues past R (Table 3 in the output). These columns reproduce E6 and G1 exactly.

*Convergence.* By the end of R, learning has converged everywhere except on the slow mechanisms (output, Table 4).
* *Converged.* Failures in the last quarter of the rounds are 0 for M1 and M4 under every slack protocol, and for M6 and M7 under their handling component.
* *Not converged.* At the largest horizon they are 424–2,969 for M3, M5 and M5′ under the slack protocols (CI, which needs half the queries there, has converged). They are 52–118 for M7/M8 under SI or SI-ABC, and 16 for M6 under SI.
* *So* those counts are lower bounds on the totals. Their growth with n₀ is visible all the same.

**With a verifier:** total task queries (asks plus searches plus L-flagged queries) until every one of the 100 problems has an accepted run.

**Humans and seeds.** The same humans are used in every protocol of a mechanism and horizon, and the seeds are those of the earlier experiments:
* *E6 classes:* 1000n + s, 40 humans;
* *G classes:* 7919N + s, 40 humans (G1's oracle table);
* *F classes:* 5000n + s, 20 humans;
* *HEDGE:* 4243n + s, 40 humans.

## 2. The composition table

### 2.1 Without a verifier

Failed runs during R rounds, mean ± standard error, with asks per problem in brackets. For G classes the horizon is N, and n₀ = 1.25N with reviews, N without.

| mech. | n₀ (G: N) | R | CI | SI | SI+D | SI-ABC | SI-ABC+D |
|---|---|---|---|---|---|---|---|
| M1 | 8 | 6,400 | 567 ± 10 | 12.5 ± 0.7 | ≡ SI | 1.7 ± 0.3 [3.0] | ≡ SI-ABC |
| M1 | 32 | 25,600 | 2,554 ± 41 | 14.5 ± 0.7 | ≡ SI | 0.8 ± 0.2 [5.2] | ≡ SI-ABC |
| M1 | 128 | 102,400 | 10,089 ± 136 | 14.3 ± 0.7 | ≡ SI | 0.3 ± 0.1 [7.5] | ≡ SI-ABC |
| M2 | 8 | 6,400 | 585 ± 10 | 114 ± 8 | ≡ SI | 15.8 ± 2.5 [3.0] | ≡ SI-ABC |
| M2 | 32 | 25,600 | 2,627 ± 42 | 245 ± 22 | ≡ SI | 17.1 ± 5.0 [5.2] | ≡ SI-ABC |
| M2 | 128 | 102,400 | 10,176 ± 136 | 436 ± 48 | ≡ SI | 46.7 ± 19.6 [7.5] | ≡ SI-ABC |
| M3 | 8 | 6,400 | 705 ± 7 | 1,428 ± 19 | ≡ SI | 1,032 ± 11 [0.6] | ≡ SI-ABC |
| M3 | 32 | 25,600 | 3,146 ± 41 | 6,304 ± 109 | ≡ SI | 5,908 ± 100 [0.2] | ≡ SI-ABC |
| M3 | 128 | 102,400 | 12,619 ± 140 | 25,629 ± 396 | ≡ SI | 25,407 ± 386 [0.0] | ≡ SI-ABC |
| M4 | 8 | 8,000 | 205 ± 6 | 227 ± 6 | 79.9 ± 1.6 | 0.0 [2.1] | 0.0 [2.1] |
| M4 | 32 | 32,000 | 443 ± 14 | 309 ± 8 | 83.1 ± 1.9 | 136 ± 6 [2.5] | 32.4 ± 1.2 [2.6] |
| M4 | 128 | 128,000 | 762 ± 29 | 331 ± 9 | 88.5 ± 2.2 | 153 ± 7 [3.7] | 35.6 ± 1.5 [3.8] |
| M5 | 8 | 8,000 | 512 ± 12 | 979 ± 28 | 1,662 ± 45 | 979 ± 28 [0.0] | 1,662 ± 45 [0.0] |
| M5 | 32 | 32,000 | 1,972 ± 48 | 3,930 ± 95 | 6,957 ± 132 | 3,930 ± 95 [0.0] | 6,957 ± 132 [0.0] |
| M5 | 128 | 128,000 | 8,206 ± 270 | 15,622 ± 423 | 28,603 ± 624 | 15,622 ± 423 [0.0] | 28,603 ± 624 [0.0] |
| M5′ | 8 | 6,400 | 415 ± 11 | 803 ± 23 | ≡ SI | 803 ± 23 [0.0] | ≡ SI-ABC |
| M5′ | 32 | 25,600 | 1,572 ± 35 | 3,208 ± 79 | ≡ SI | 3,208 ± 79 [0.0] | ≡ SI-ABC |
| M5′ | 128 | 102,400 | 6,469 ± 145 | 12,536 ± 347 | ≡ SI | 12,536 ± 347 [0.0] | ≡ SI-ABC |
| M6 | 8 | 6,400 | 39.0 ± 3.4 | 72.5 ± 5.4 | 16.6 ± 1.1 | 72.5 ± 5.4 [0.1] | 16.6 ± 1.1 [0.2] |
| M6 | 32 | 25,600 | 157 ± 11 | 329 ± 27 | 18.9 ± 1.5 | 329 ± 27 [0.1] | 18.9 ± 1.5 [0.2] |
| M6 | 128 | 102,400 | 681 ± 52 | 1,239 ± 98 | 19.7 ± 1.1 | 1,239 ± 98 [0.1] | 19.7 ± 1.1 [0.2] |
| M7 | 8 | 6,400 | 440 ± 14 | 139 ± 12 | 9.5 ± 0.6 | 152 ± 13 [1.7] | 9.5 ± 0.6 [1.7] |
| M7 | 32 | 25,600 | 2,716 ± 71 | 693 ± 72 | 10.8 ± 0.7 | 710 ± 62 [4.9] | 10.8 ± 0.7 [4.9] |
| M7 | 128 | 102,400 | 11,182 ± 312 | 2,635 ± 247 | 10.2 ± 0.7 | 2,408 ± 215 [7.4] | 10.2 ± 0.7 [7.5] |
| M8 | 8 | 6,400 | 440 ± 14 | 139 ± 12 | 139 ± 12 | 152 ± 13 [1.7] | 152 ± 13 [1.7] |
| M8 | 32 | 25,600 | 2,716 ± 71 | 693 ± 72 | 693 ± 72 | 710 ± 62 [4.9] | 710 ± 62 [4.9] |
| M8 | 128 | 102,400 | 11,182 ± 312 | 2,635 ± 247 | 2,635 ± 247 | 2,408 ± 215 [7.4] | 2,408 ± 215 [7.4] |

*Common random numbers.* M7 and M8 coincide wherever L is not used, as in F1: the classes have the same structure and seeds, and C's invalid value plays the role of W's obstruction record.

**Oracle stopping, on the same runs** (task queries until at most 2% of problems fail; selected rows; the full table is in the output):

| | CI | SI | SI+D |
|---|---|---|---|
| M1 | 2,915 → 12,724 → 51,365 | 160 → 204 → 204 | ≡ SI |
| M4 | 1,240 → 2,922 → 5,980 | 1,391 → 1,833 → 2,018 | 473 → 515 → 554 |
| M5 | 3,072 → 11,493 → 48,946 | 6,062 → 25,207 → 92,880 | 11,332 → 48,023 → 199,028 |
| M6 | 544 → 1,980 → 8,756 | 1,013 → 3,994 → 15,914 | 235 → 274 → 252 |
| M7 | 2,679 → 12,513 → 50,655 | 1,965 → 10,019 → 37,608 | 130 → 144 → 133 |

### 2.2 With a verifier

Total task queries for all 100 problems, mean ± standard error, with asks, rejected runs and L-flagged queries in parentheses.

| mech. | n₀ (G: N) | SI-V | **VSI** | SI-V-ABC | VSI+ABC |
|---|---|---|---|---|---|
| M1 | 8 | 13 ± 1 (9.9 rej.) | **15 ± 1** (11.0 rej.) | 223 ± 2 (221 asks; 1.1 rej.) | 223 ± 2 (221 asks; 1.1 rej.) |
| M1 | 32 | 14 ± 1 (10.4) | **20 ± 1** (12.9) | 285 ± 2 (284; 0.5) | 285 ± 2 (284; 0.5) |
| M1 | 128 | 14 ± 1 (10.1) | **20 ± 1** (12.7) | 319 ± 4 (318; 0.1) | 319 ± 4 (318; 0.1) |
| M2 | 8 | 181 ± 13 (14.6) | **40 ± 2** (14.6) | 236 ± 3 (221; 1.1) | 224 ± 2 (221; 1.1) |
| M2 | 32 | 750 ± 76 (19.2) | **55 ± 3** (19.2) | 318 ± 13 (284; 0.5) | 285 ± 2 (284; 0.5) |
| M2 | 128 | 2,636 ± 238 (18.5) | **54 ± 3** (18.5) | 360 ± 19 (318; 0.1) | 319 ± 4 (318; 0.1) |
| M3 | 8 | 1,610 ± 24 (100) | **663 ± 6** (100) | 1,602 ± 22 (0; 100) | 669 ± 5 (0; 100) |
| M3 | 32 | 6,450 ± 111 (100) | **2,497 ± 19** (100) | 6,375 ± 79 (0; 100) | 2,468 ± 18 (0; 100) |
| M3 | 128 | 26,091 ± 385 (100) | **9,734 ± 89** (100) | 25,864 ± 441 (0; 100) | 9,720 ± 82 (0; 100) |
| M4 | 8 | 221 ± 5 (50.4) | **122 ± 2** (50.4) | 100 ± 0 (100; 0) | 100 ± 0 (100; 0) |
| M4 | 32 | 288 ± 8 (49.0) | **129 ± 2** (49.0) | 263 ± 8 (125; 18.5) | 180 ± 3 (130; 18.5) |
| M4 | 128 | 338 ± 9 (51.0) | **137 ± 3** (51.0) | 314 ± 11 (144; 19.6) | 202 ± 4 (148; 19.6) |
| M5 | 8 | 1,029 ± 27 (50.4) | **424 ± 7** (50.4) | 1,024 ± 25 (0; 50.4) | 420 ± 8 (0; 50.4) |
| M5 | 32 | 3,795 ± 99 (49.0) | **1,528 ± 30** (49.0) | 3,757 ± 105 (0; 49.0) | 1,542 ± 32 (0; 49.0) |
| M5 | 128 | 16,127 ± 461 (51.0) | **6,246 ± 136** (51.0) | 16,342 ± 399 (0; 51.0) | 6,236 ± 125 (0; 51.0) |
| M5′ | 8 | 773 ± 20 (50.4) | **337 ± 7** (50.4) | 824 ± 22 (0; 50.4) | 340 ± 7 (0; 50.4) |
| M5′ | 32 | 3,080 ± 90 (49.0) | **1,216 ± 25** (49.0) | 2,981 ± 97 (0; 49.0) | 1,221 ± 23 (0; 49.0) |
| M5′ | 128 | 12,866 ± 395 (51.0) | **4,996 ± 109** (51.0) | 12,703 ± 427 (0; 51.0) | 4,933 ± 104 (0; 51.0) |
| M6 | 8 | 76 ± 7 (9.1) | **24 ± 1** (9.1) | 87 ± 7 (10; 9.1) | 38 ± 2 (14; 9.1) |
| M6 | 32 | 315 ± 31 (10.0) | **29 ± 2** (10.0) | 340 ± 29 (10; 10.0) | 44 ± 3 (15; 10.0) |
| M6 | 128 | 1,439 ± 119 (10.2) | **31 ± 1** (10.2) | 1,400 ± 93 (10; 10.2) | 45 ± 2 (15; 10.2) |
| M7 | 8 | 136 ± 13 (12.6) | **10 ± 1** (9.5; 9.5 L) | 312 ± 14 (166; 9.5) | 176 ± 2 (166; 9.5; 9.5 L) |
| M7 | 32 | 582 ± 54 (20.9) | **11 ± 1** (10.8; 10.8 L) | 936 ± 44 (288; 16.9) | 303 ± 4 (293; 10.8; 10.8 L) |
| M7 | 128 | 2,868 ± 222 (24.6) | **10 ± 1** (10.2; 10.2 L) | 2,874 ± 293 (344; 19.4) | 357 ± 6 (346; 10.2; 10.2 L) |
| M8 | 8 | 136 ± 13 (12.6) | **34 ± 2** (12.8) | 312 ± 14 (166; 9.5) | 187 ± 2 (166; 9.5) |
| M8 | 32 | 582 ± 54 (20.9) | **33 ± 2** (11.9) | 936 ± 44 (288; 16.9) | 325 ± 5 (292; 11.5) |
| M8 | 128 | 2,868 ± 222 (24.6) | **31 ± 2** (10.8) | 2,874 ± 293 (344; 19.4) | 378 ± 7 (347; 11.0) |

## 3. Reading

### 3.1 Which component handles which mechanism

* **M1 (persistent, noticing): slack.**
  * CI fails 567 → 2,554 → 10,089 times, and SI 12.5–14.5 at every n₀ (oracle stopping: 2,915 → 51,365 against 160–204, E6's numbers).
  * Asking cuts SI's failures further, to 1.7 → 0.3, at 3.0 → 7.5 asks per problem.
  * With a verifier, uniform search alone is cheapest (13–14).
* **M2 (fooled at a verdict): the verifier's pointer at verdict steps.**
  * VSI costs 40 → 55 → 54, against 181 → 2,636 for uniform search. This is EQ's result.
  * Without a verifier, asking brings failures from 114 → 436 down to 16 → 47. That is E6's artifact (referee 5): every confident wrong commitment comes at t_p = n₀ − 1.
  * The residue is heavy-tailed, as slack-imitation.md §5 predicts for confident commissions. At n₀ = 128, 34 of 40 humans have no failure and 3 have 320–475: single-mistake runs, found at rate 1/n.
* **M3 (silent): nothing makes it flat.**
  * Slack doubles the cost under uniform queries (CI 705 → 12,619 against SI 1,428 → 25,629; Remark 2).
  * Asking barely fires (0.6 → 0.2 → 0.0 asks per problem) and barely helps.
  * VSI's scan stream cuts the verifier's cost 2.4–2.7×, to about 0.8n₀ per insight (Lemma Q3).
* **M4 (readable by-product, reviews): the last-review query.**
  * SI+D stays at 80–89 failed runs, against SI's 227–331 (Theorem G4). Its oracle cost is 473–554, G1's MIX-REV.
  * Asking alone halves SI's failures at N ≥ 32, and the review query removes most of the rest: 36 at N = 128, G1's result.
  * With a verifier, the list's last-review entry gives 122–137, about 2.5 queries per rejection. On all 5,284 failed runs checked, the last review step was a mistake, as Theorem G4's ripeness says.
* **M5 (doing-only by-product): nothing.**
  * Every protocol costs in proportion to n₀, as Theorem G3 requires. Asking never fires (Proposition G6(a)).
  * VSI's scan is the only help, 2.4–2.6×.
  * The review query is a cost here (§3.3).
* **M6 (hedge at a labelled decision): the decision-step query.**
  * SI+D fails 17–20 times at every n₀, against SI's 73 → 1,239 and CI's 39 → 681. Its oracle cost is 235–274, against 1,013 → 15,914.
  * Asking does not help: the idea's prior rate, 0.1, is below α, so the default decision is confident (Proposition G7(c)). It fires only about 0.1–0.2 times per problem, after learning.
  * With a verifier the list's decision entry gives 24–31.
* **M7 (invalid checkable claim): the local check.**
  * CSI fails 9.5–10.8 times, about the number of problems with k = 2, against SI's 139 → 2,635 (Theorem F2).
  * In VSI every rejection is caught by L-first at one task query, 10–11 in all (Proposition F5). No search is ever needed.
* **M8 (false negative as a valid obstruction, trusting human): nothing without a verifier.**
  * SI, SI+D and SI-ABC+D all grow in proportion to n₀ (139 → 2,635; Theorem F3).
  * With a verifier, VSI costs 31–34, because the list holds the obstruction record, and on every failed run that record is the first mistake in the list.

### 3.2 Does the full VSI stay bounded?

Yes, on every mechanism except M3 and M5.
* *The bounded mechanisms.* From n₀ = 8 to 128 (×16), VSI changes by ×1.3 (M1), ×1.3 (M2), ×1.1 (M4), ×1.3 (M6), ×1.0 (M7) and ×0.9 (M8). The drift on M1, M2 and M6 is a small rise in rejections and per-rejection cost between n₀ = 8 and 32, flat afterwards.
* *M3 and M5.* VSI grows ×14.7 on both, for ×16 in n₀. Per rejection it costs 6.6 → 25 → 97 on M3 and 8.4 → 31 → 122 on M5: about 0.8n₀ (0.84 → 0.77). Theorem Q4's worst case is 3n₀ per rejection. The scan stream reaches the single mistake at t_p < n₀ in about n₀/2 scan steps, so about n₀ queries in round robin, less what the uniform stream finds first.
* *What it means.* This is the cost theory says cannot be avoided: Theorem 3 of note.md and Theorem Q1 for silent humans, Theorem G3 for doing-only insights. VSI pays it at about n₀ per insight, not 2n₀.

### 3.3 Interference

* **VSI's extra streams on bounded-setback humans: ×1.2–1.4 (M1).** This is within Lemma Q2's factor 3. Part of the cost is extra rejections (10.4 → 12.9), because a hit at a verdict step teaches less than a hit later in the run (EQ). On every other mechanism the streams cut the cost: ×0.4–0.55 on M3, M4, M5 and M5′; ×0.003–0.3 on M2, M6, M7 and M8.
* **L-first: no cost.** It never fires outside M7, since nothing else is checkable.
* **The list's last-review entry on doing-only humans: at most one query per search.** A stream with nothing left is skipped, so VSI on M5 pays nothing measurable for it (424 against M5′'s 337 is the scaffold, below).
* **The last-review query without a verifier on doing-only humans (M5): ×1.7–1.8 failed runs, ×1.9–2.1 oracle cost.** Half of the queries go to a review step that is never a mistake for them. Theorem G4 charges other failures at half the uniform rate for this reason. This is the one design element that costs a mechanism it does not help, and the cost is bounded by about 2.
* **The review scaffold itself: ×1.25.** It lengthens the doing-only human's horizon by 1 + 1/L (M5 against M5′: VSI 424/337, 1,528/1,216, 6,246/4,996; SI 979/803 to 15,622/12,536).
* **Asking.**
  * *With a verifier* it adds 3–7.5 asks per problem, a per-problem cost that never amortizes here. That makes VSI+ABC ×14–16 the cost of VSI on M1, ×5–6 on M2, ×18–35 on M7, ×5.5–12 on M8, and ×1.5 on M4 and M6. It is cheaper only on M4 at N = 8 (100 against 122, one ask per problem), and it is neutral on M3 and M5, where it never fires.
  * *In VSI+ABC on M7* the asks do not even replace the check, since the wrong value is committed at mass 0.9.
  * *Without a verifier* asking is the only component that helps M2, and it also helps M1 and M4.
  * This agrees with slack-imitation.md and thread Q: with a verifier, ask only if pointers turn out poor.
* **No component makes another mechanism worse beyond these factors.** In particular, slack (×2 on M3, M5 and M6 under uniform queries) is repaired by VSI's scan or pointer, and asking never breaks the check or the review query (SI-ABC+D equals SI+D on M5, M6 and M7, and improves on it on M4).

### 3.4 What the classes flatter

* **The pointer.** M2, M6 and M8 each have one verdict, decision or obstruction record per run, and it is always a mistake on a failed run. In 8,603 failed M8 runs at n₀ = 8 and 32, the first list entry was a mistake every time. A real post-mortem list will be weaker. On TRUST-like notebooks with many obstruction records per run (Theorem F3's class), the list stream would cost in proportion to their number, and M8's VSI cost would grow like n₀.
* **Asking on M2.** E6's prior flatters it (referee 5).
* **Scale.** K is small and almost entirely problem-specific in every class, so asks never amortize. In a real human much of K is shared, which favours asking more than here.
* **The verifier.** It is perfect: (A3) and (A4) of Theorem Q4 hold exactly.

## 4. What is reproduced, what is new, and the deviations

### 4.1 Reproduced exactly

All 120 published numbers that the code can regenerate agree exactly, to the last decimal printed. The list is in the output.
* **E6** (slack-imitation.md §6, `results/*.json`), 36 numbers:
  * CI on the same humans, SI, SI-V and SI-V-ABC (α = 0.3) for noticing, fooled and silent humans at n₀ = 8, 32 and 128.
  * Here they are columns CI and SI of the oracle table (M1–M3), and SI-V and SI-V-ABC.
* **EQ** (threadQ-alternatives.md §8), 18 numbers: U and USH for the same kinds and horizons. VSI on M1–M3 *is* EQ's U+S+H, since nothing there is checkable and there are no reviews or decisions.
* **Referee 5's online test** (`verification/referee5_si_abc_online.out`), 20 numbers: failed runs and asks in the first 3,000 rounds of SI and SI-ABC. At n₀ = 32 referee 5 used 20 humans, so the comparison there is with the first 20 of the 40 here.
* **G1's oracle table** (threadG-byproducts.md §7), 12 numbers: DO0 and DO (M5′'s CI and SI), REVIEW with uniform and MIX-REV queries (M4's SI and SI+D).
* **G1's online table**, 18 numbers: from a separate run with G1's online seeds (104729N + s, 20 humans, 3,000 rounds), since G1's two tables used different humans.
* **F1's n₀ = 32 column** (threadF-certified.md §8), 16 numbers: SI, SI-ABC, CSI (= SI+D) and CSI-ABC (= SI-ABC+D), failed runs and asks, for C and W with trusting humans.

### 4.2 New

* Every VSI and VSI+ABC cell outside M1–M3.
* Everything on M5 (the review scaffold) and M6 (HEDGE).
* CI on M4, M6, M7 and M8.
* The online failure counts at R = 4·M·n for E6's and G1's classes. Their first 3,000 rounds are referee 5's.
* F1's classes at n₀ = 8 and 128, and the oracle costs for F1's classes.
* SI-V and SI-V-ABC outside M1–M3.

### 4.3 Deviations from the earlier setups

1. **F1's horizons.** F1 ran n₀ = 16, 32 and 64; here they are 8, 32 and 128, so only the n₀ = 32 column is F1's. At n₀ = 8, F1's class has only 3 setup times (t_p < n₀ − 5).
2. **G1's horizons** are the routine length N. With reviews n₀ = 1.25N; R = 4·M·n uses that n.
3. **M5** is a new variant of G1's DO, on G1's REVIEW schedule with empty trigger sets at reviews. G1's own DO is M5′.
4. **M6** is a new class (§1.1). Its late trigger window and prior rate 0.1 are choices, explained there.
5. **The measurement** without a verifier is online failed runs (F1's rule), not E6's and G1's oracle stopping. Oracle stopping is also reported for the protocols that never ask, and it reproduces E6 and G1.
6. **VSI's uniform stream draws only committed steps,** as Lemma Q2 says. E6's SI-V-ABC draws all n steps, and the SI-V-ABC column keeps E6's rule. Without asking the two coincide.
7. **VSI's list.** For F1's classes, "verdict steps" means every claim or record entry, the obstruction record included. That is the post-mortem target thread Q names. For E6 it is the value entries (EQ's H), for G the insight entry, for HEDGE the decision and A's entry.
8. **SI+D was not requested.** It isolates the design elements from asking. E6's verdicts are not treated as labelled decisions, so the decision query does not apply to M2. The pointer at verdicts enters only VSI's list, as in EQ.

## 5. What R1 does not show

* **Whether real humans have these mechanisms,** in what proportions, or whether their pointers are as good as here (§3.4). The classes are tiny and K is small.
* **Mixtures.** Each class carries one mechanism. A human with several runs the components side by side, and by Lemma Q2 VSI's cost on it is at most 3 times the best stream's for each rejection. That is not simulated.
* **An imitated verifier** (Theorem Q5), a human referee as L, or a verifier that is not sound. Here both are exact.
* **Deployment of a frozen imitator.**
