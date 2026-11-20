# Response to referee 4 and to the red team (thread E)

* *The reports:*
  * the referee's, [`referee-report-slack-imitation.md`](referee-report-slack-imitation.md), on `slack-imitation.md` as of 23:03 on 20 November;
  * the red team's, [`../research/threadE-redteam.md`](../research/threadE-redteam.md), on the version with Lemma S and Proposition 4.
* *What held.* Both found the main mathematics correct: Lemma S, Theorem 2, Corollary 3 and Proposition 4. The referee re-ran 50 cells of E6, and all matched to the digit.
* *What did not.*
  * Three errors in secondary claims, and two factual errors about E6 (referee).
  * A misreading of thread C's Proposition 2, which changed Section 4 and my confidence numbers (red team).
  * A better design, ask-before-committing, now Proposition 5 and part of the recommended scheme (red team).
* *The result* is version 2 of the note. Item by item:

## Referee 4

### A. Errors

* **A1 (read-out).** Accepted. Remark 3 now states (R), the referee's counterexample, and that slack makes (R) harder (thread E's V14).
* **A2 ("omissions are uncertain steps").** Accepted, and it was backwards (thread E §1 too). Section 4 now opens with the confident/unconfident axis: certainly-due slots are filled with guesses at any confidence, and rare content is omitted confidently. The "two optimizations" paragraph is replaced by ask-before-committing (Proposition 5).
* **A3 (the fallback).** Accepted.
  * Answer 7 and Remark 2 now give n₀K/(1−ρ), twice chained imitation's guarantee for ρ = ½.
  * Theorem 2 states min{n, (D+1)n/(σ+1)}·K, and Lemma S gives |M| ≥ max{1, (σ+1)/(D+1)}.
  * E6's reading cites the factor 2 for silent humans.

### B. Overclaims

* **B1.** Accepted. The three kinds are replaced by the confidence axis, presented as exact for product posteriors and a heuristic otherwise. "Predictable" is now "plurality", and paraphrase is folded into (B-commit).
* **B2.** Accepted.
  * The empty-step argument is described as true in the model by definition.
  * The hidden clock "removes stated deadlines, not every deadline effect", and the scaffold strips dates and step markers.
  * Remark 4 says that with a visible step, (B-omit) for g = ∅ is a real assumption.
* **B3.** Accepted. Hedges and substitutes (thread C §6) are listed as a second exception to (B-omit), with thread E's by-product construction.
* **B4.** Accepted.
  * Section 3 has a paragraph "How learner-relative this is": (B_D) is quantified over the imitator's notebooks, like (C_r); its advantages are locality and measurability.
  * The table row for end-weighting no longer holds learner-relativity against (C_r) alone, and the slack rows say "learner-relative, but local and measurable".
* **B5.** Accepted. Answer 9 and the table credit:
  * thread C's Corollary (slack) as the case D = 0;
  * the third note's Theorem 1 as the counting.

  The note now cites `robust-runs.md`, and says the restriction to the imitator's actual replacements is what its answer 4 asked for.
* **B6.** Accepted. Answer 6 and Section 5 are restricted to unpredictable, problem-specific insights, and list the other ways round the factor n. Slack is described as enlarging the defect set (the mistake-mass frame), not as a threshold test.
* **B7.** Accepted.
  * The probabilities are restated on the graded reading, as a table with version 1, thread E and version 2.
  * The 75% is replaced, with its reasoning corrected.
  * "Refereed below" is replaced by a link.
* **B8.** Accepted: "O(K) for fixed ε, δ, D and ρ, and truly O(K) task queries with a verifier".
* **B9.** Accepted. Proposition 4's ancestors are now check-and-scan (note.md, Proposition 8) with uniform search, and thread D's Scheme B, whose scan runs over the last r steps.
* **B10.** Accepted. Section 2 says what the check costs. Answer 1 no longer says the changes are free of queries.
* **B11.** Accepted:
  * the thread B row mentions located probes (Theorem 5(b));
  * the thread D Scheme C row gives the human's effort (K+1)(c+1);
  * the class-prior qualifier is added in Section 5.

### C. Experiment

* **C1.** Noted, with thanks.
* **C2.** Accepted. Section 6 now states:
  * the tie-breaking;
  * that silent humans never correct;
  * that humans add work to their own value before it is available to them, which is generous to the bounded-setback kinds;
  * that the persistent kinds' ideas are late or wrong, never missing.

  The docstring's "keeps the draft unchanged" is fixed in the code.
* **C3.** Accepted.
  * A new mode `slack_imitation.py --same` runs chained imitation without slack on the same humans (n = n₀). Its numbers agree with the referee's: 2,915 and 12,724 for noticing humans at n₀ = 8 and 32, and 2,249 and 10,873 for silent ones. At n₀ = 128 it gives 51,365 and 47,065.
  * The tables lead with this row, and keep version 1's row, labelled "n₀ = n (different humans)".
  * Answer 8 and the reading use the same-humans numbers.
  * "Slack does not help silent humans at all" is replaced by "slack doubles their cost".
* **C4.** Accepted. Section 6 says the setback bounds hold on the decoder's runs, citing `referee4_setback_e6.out`, and not for the human alone.
* **C5.** Accepted. Section 6 says that E6's S is not preserved by appending, and that this is harmless on the runs that occur.
* **C6.** Accepted:
  * 142, not 143 (the table is now generated from the JSON);
  * "about n for silent humans, 0.56n–0.77n for fooled ones";
  * the misled-8 exception (38) is stated.
* **C7.** Accepted. Proposition 4's notes say:
  * the verifier is an uncounted oracle;
  * the guarantee covers verified problems only;
  * E6's SI uses an oracle stopping rule.
* **C8.** Accepted. `setback_check.py` is described, in the note and in the README, as an arithmetic sanity check of Lemma S's bookkeeping that cannot test (B_D). The referee's run-level check is cited as the substantive one.

### D. Minor

* **D1.** Accepted. (M3) is renamed (M-prefix), with a note that it is not note.md's (M3).
* **D2.** Accepted. Labels are the appended entries (thread C's (Y)).
* **D3.** Accepted. Corollary 3 states τ(x₀) ≤ n₀ and (M1), (M2), (M-prefix), with a sentence on the miscalibrated fallback.
* **D4.** Accepted (as A3).
* **D5.** Accepted. In Proposition 4:
  * (b) and (d) hold almost surely;
  * (c) assumes (B_D) for all entries;
  * there is a note on sampling without replacement.
* **D6.** Accepted.
  * The hidden-clock edge case, τ ∈ {0, ∞} when P(y) = y, is stated in Section 2.
  * E6's visible step and the reason for it are in Remark 4.
* **D7.** Accepted. "A mistake costs its step plus the setback, at most D + 1 steps of slack."
* **D8.** Accepted. "Proved on silent humans", and "for the class-prior decoder".
* **D9.** Not added. The read-out's different instruction is evident from Remark 3.
* **D10.** Accepted (as B11).
* **D11.** Accepted (as C7).
* **D12.** Accepted. The trees item says later subcalls see earlier commissions.

## The red team (thread E)

* **Proof gaps** (§3.5): Corollary 3's hypothesis, Proposition 4(c)'s bizarre entries, and the read-out premise (R). All three are fixed, as D3, D5 and A1 above.
* **The reading of Proposition 2** (§1). Accepted; this is the main change to Section 4. Most commissions are unconfident guesses in slots that are certainly due, and rare-insight omissions are confident.
* **The violations** (§2). The note now discusses:
  * V2, base-rate negative results, as the most damaging mechanism;
  * V5, by-product insights, including the silent human under a hidden clock, which refutes version 1's "the idea depends on the date" argument;
  * V3, sunk cost;
  * V4, anchoring;
  * V9, lossy paraphrase;
  * V12, leaked progress signals, now handled by stripping dates;
  * V14, commissions after success, under (R);
  * V15, laundered verification.
* **The graded reading** (§3.6). Accepted. Section 4 states the guaranteed gain ρn₀/(D+1) and the heuristic cap (1−ρ)/β.
* **Design variants** (§4). Accepted. Section 4 states the design law and lists the valid variants: the verify instruction, machine-checked entries, content-triggered audits, quarantine, stripping dates, and ask-before-committing.
* **Ask-before-committing.** Adopted. I checked the proof sketch and it holds; the order-independence of W is the key step. It is now Protocol SI-ABC and Proposition 5, extended to the verifier version (SI-V-ABC, part (c)). It is part of the recommended scheme.
  * *E6 now tests it* (`--abc`, α = 0.1 and 0.3). It removes the fooled humans' growth with n, at the cost of asking at uncertain steps. As predicted, it does not help silent humans, whose omissions are confident.
* **"(B-commit) cannot be dropped for free"** (§4). Adopted in Section 5.
* **The classification** (§5). Adopted, as B1.
* **Probabilities** (§6). Adopted. My version 2 numbers equal thread E's; the table in Section 4 shows all three columns.
* **Premises outside (B_D)** (§3.1–3.4). Section 8 now mentions cold-start chains, heavy-tailed research times, drift, familiarity with the imitator, fatigue and many humans.

## Referee 5 (version 2)

The report is [`referee-report-slack-imitation-v2.md`](referee-report-slack-imitation-v2.md).
* *What held.* Proposition 5 is correct: every step of its proof checks on 116,612 instrumented runs of E6, and on random classes with a check. The other numbered statements are correct after their edits, and the new E6 cells reproduce exactly.
* *Changes in response,* item by item:

### A. Errors

* **A1.** Accepted. Answer 2 now says O(K log K) task queries on i.i.d. problems for fixed ε, δ, D and ρ, O(K) failed runs online, and truly O(K) task queries with a verifier. (My earlier fix to referee 4's B8 was itself wrong.)
* **A2.** Accepted.
  * The deployment note now says a frozen imitator must abstain, since a frozen asker is outside the budget, and that no PAC theorem is proved for an asker that learns.
  * Answer 1 and the Section 7 row say what is proved for which use.

### B. Overclaims

* **B1.** Accepted.
  * "Flat" and "removes the growth" are replaced by "grows much more slowly", with the comparison against SI-V.
  * The reading explains the class artifact (every confident wrong commitment at t_p = n₀ − 1), citing `referee5_abc_mechanism.out`, and notes that at n₀ = 8 asking costs fooled humans more.
* **B2.** Accepted. The asks are added to the verifier version's cost in Answer 2 and in the Section 7 row.
* **B3.** Accepted. Answer 1 and the Section 7 row state the trade-off: with a verifier, add asks only if fooled commissions are expected to be common.
* **B4.** Accepted. Remark 1 states the gain condition D + 1 < (1−ρ)(σ+1).
* **B5.** Accepted: "argued".
* **B6.** Accepted. "What does not move" separates the statements checked by referee 4 and thread E from Proposition 5, which referee 5 checked.
* **B7.** Accepted. The Cost note and the E6 reading say that in E6 the asks are 2–9 per problem, because K is almost all problem-specific.

### C. Experiment

* **C1, C3, C4.** Noted.
* **C2.**
  * The search-on-committed-steps option is noted after Proposition 5.
  * The α = 0.1 tie is stated in the reading.
  * The table now prints rejections with two decimals.
* **C5.** Accepted, as B1.
* **C6.** Accepted. Referee 5's online test of SI-ABC without a verifier is quoted in Section 6, with its reason for not using oracle stopping, and is mentioned in Answer 8.

### D. Minor

* **D1.** Accepted. M_t and the decoder in use are defined in Proposition 5.
* **D2.** Accepted. Proposition 5 takes 0 < α < 1, with a note that the hit bound is K/max{1, log₂(1/α)}.
* **D3.** Accepted: "≤ (ln 2)·K/α ≈ 0.69K/α", and "(ln 2)·K/α" where a bound is meant.
* **D4.** Accepted.
* **D5.** Accepted.
* **D6.** Accepted: "by the argument of Theorem 1".
* **D7.** Accepted. Remark 3 now separates a wrong design written by the imitator (one commission, charged at the 1/n rate) from one written by the human's own chain. It also says that runs failing the check get the flip query.
* **D8.** Accepted. `robust-runs.md` is linked in Answer 9.
* **D9.** Accepted. Answer 8's slack line says "oracle stopping".
* **D10.** Accepted (as C2).
* **D11.** Accepted. The ≥ 5× row says which columns assume ask-before-committing.
