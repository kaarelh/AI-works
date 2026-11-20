# Response to the referee report

The report ([`referee-report.md`](referee-report.md)) reviewed the note at commit `1915959e`. It found no error in the numbered theorems. It found:
* four errors or gaps: A1–A4;
* overclaims: B1–B14;
* departures of the code from the protocols, and missing caveats: C1–C8;
* minor points: D1–D15.

Every item was addressed. The changes, item by item:

## A. Errors

* **A1 (rejection sampling vs MB).** Accepted: the contrast was wrong. Section 6.3 now says:
  * removing visible failures raises the share of silent ones for any filter, MB and rejection sampling alike, and with a binary check neither changes the ratio of silent failures to correct runs;
  * the real differences are that MB's corrections persist and generalize, and can incidentally refute silent deviants;
  * selection by a graded or manipulable judgment is what favours outputs that score well without being right, and MB never selects among outputs.

  It includes the referee's three-hypothesis example. Answers item 6 and the Section 7 remarks on persuasive states and optimism were rephrased to match.
* **A2 (§4.2).** Accepted.
  * The section now uses the relative floor for the program mixture, ξ_D(y | x) ≥ 2^(−sep(x;A) − K(y) − c), with no deficit term (ultranatural Remark 1.1).
  * For W_tot it states the deficit form, K_tot(D) − L(D).
  * It drops the mis-cited "both directions" sentence, and says explicitly that the converse is not shown.
  * The heading and Answers item 3 now say that the second signal is a case of the first.
* **A3 (Proposition 10).** Accepted.
  * Audits are now made only on output runs, where the audit is the only task query on the run.
  * The proposition assumes (M1) and (M2).
  * A sentence explains why auditing failed runs would interact with the bisection query.
* **A4 (Remark 1.1).** Accepted: "Proposition 2, and the audit bound of Proposition 10, hold for samplers".

## B. Overclaims

* **B1.** Accepted.
  * The subtitle and Answers item 4 now separate looks at results, O(K log(K/δ)/ε), from batched queries.
  * Batching is a stated assumption, (M3).
  * Theorem 7's remarks give the referee's numbers for what batching hides.
  * Section 8 was reworded.
* **B2.** Accepted. "Optimal up to a log factor" became "in the worst case over humans of complexity K, within a factor O(log(n/ε)) of every task-only protocol". The answers note that on particular humans other task-only protocols can be cheaper by constants (E1: scanning is 4× cheaper than CI), and Theorem 3 notes that its class depends on ε.
* **B3.** See A2.
* **B4.** Accepted. The table in Answers item 5 now has a caption saying what failure means in each row, and what kind of bound it is. The subtitle says "never to output a run that fails the human's check".
* **B5.** Accepted. "Never worse than chained imitation" was replaced by "has chained imitation's guarantee for the deviations the monitor cannot see". The answers say that this is about upper bounds.
* **B6.** Accepted. The text now says that posterior-based signals can flag mistakes the learner is unsure of but cannot tell a confident mistake from a confident correct answer (Answers 3 and 5, §4.2, §7).
* **B7.** Accepted. Answers item 8 and Section 10 now say that both experiments' main runs use the strongest possible check. A new part of E2 uses a **weak check** that sees only half of the human's rules (one rule of each size). It shows:
  * what MB alone does about silent deviations (nothing);
  * what audits add (Proposition 10).
* **B8.** Accepted. "Typically many" was removed, and "if every mistake carries at least b bits" made precise. The answers and Section 5.2 now say that part of what a task query teaches was found by the checks, with the E1 example.
* **B9.** Accepted. Section 5.2 has a new remark: final-state checks do not constrain intermediate states. Prefix checks extend the guarantee to every state at the same bisection cost; Lemma 5 applies at the first failing state. Answers item 7 and Section 7 say "for final results, and with prefix checks for every state".
* **B10.** Accepted: "16 of 30 cases (10 humans at 3 run lengths)", and "usually" removed.
* **B11.** Accepted: the cost of the scan is given as about (n+1)/2 per problem with an insight and n per problem without one, about 1.5·n per insight found in E1.
* **B12.** Accepted. Section 6.1 now says that false flags produce marked outputs, and that a false flag on a start state violates (M1). Section 5.1 states that V is a fixed function of the state; inconsistent verdicts are not covered.
* **B13.** Accepted: "with the class prior as its prior"; for Solomonoff's prior only the general bound.
* **B14.** Accepted: Answers 1 and Proposition 2(b) mention the random stopping round and that choosing N needs K(P).

## C. Experiments

* **C1.** Accepted. Both experiments now implement Protocol MB as written, rerunning the problem after each task query:
  * E1's check counts are 554 / 645 / 770 / 864, matching the referee's replay;
  * in E2, MB and CS rerun until the check passes.
* **C2.** Accepted. Protocol CS now says "skipping states whose answer is already in D", and E2's CS does so.
* **C3.** Thanks. Theorem 3's lower bound for E1's setting (0.48·n·m) is now a column of the E1 table, with the observation that CI is about 6.5× above it and the scan about 1.5×.
* **C4.** Accepted. The E2 caption says that for humans that did not reach the target the values are at the cap. The table reports reached/humans.
* **C5.** Accepted. Section 10 gives both reasons for fewer than 18 task queries.
* **C6.** Accepted. CI, CS and MB in E2 now use 40 humans; US and NOV keep 10.
* **C7.** Accepted. A comment in `property_rules.py`'s `novel` explains the equivalence of "size ≤ s" and "size exactly s".
* **C8.** Accepted.
  * `K_bits_expected` was replaced by Theorem 3's lower bound.
  * The figure's axis label says that Q = 0 is drawn at 1.
  * The E1 text says that η = 1/2 is outside Theorem 3's η = 8ε regime, so the comparison is a sanity check.

## D. Minor

* **D1.** Lemma 5 now assumes (M2).
* **D2.** Lemma 1 now says D₀ is labelled by P, with the floor ⌊K(P)⌋.
* **D3.** Proposition 4 now states the bound without the min.
* **D4.** "Less than γ".
* **D5.** Greedy decoding now has an end symbol and a length bound, with the non-termination example.
* **D6.** K(m, n, q, η).
* **D7.** Added as a remark to Theorem 3.
* **D8.** Added to Protocol CI.
* **D9.** "Batch checks", needing (M3).
* **D10.** O(K·log(K/δ)/ε) looks.
* **D11.** Reworded.
* **D12.** "At n = 64".
* **D13.** Reworded.
* **D14.** Added to Section 7.
* **D15.** Labelled a heuristic, with the link to Section 4.2.
