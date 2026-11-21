# Response to referee 6 and to the second red team (thread S)

* *The reports:*
  * the referee's, [`referee-report-verified-slack.md`](referee-report-verified-slack.md);
  * the second red team's, [`../research/threadS-redteam2.md`](../research/threadS-redteam2.md).

  Both reviewed the first draft of `verified-slack.md`.
* *What held.* Both found the core mathematics correct: Lemmas 1–3, Theorem 5 (b)–(e) and Theorem 6 (a)–(b). The referee confirmed that every hit is worth b_α bits on every route, that the 3n₀ bound held surely, and that "the first mistake comes early" holds with asks.
* *What changed.*
  * The verifiers are covered more carefully, with two predicates S_V and S\*.
  * Several hypotheses were added.
  * Thread results are quoted at their actual strength.
  * A termination rule was added.
  * The search is now weighted towards the scan.
  * The probabilities fall to thread S's.
  * The recommendation is narrowed to a machine verifier on a formally stated goal.

Item by item:

## Referee 6

### A. Errors

* **A1 (the imitated verifier is not covered by (A4)).** Accepted.
  * Theorem 5(a) now says correctness holds when V is consulted on every output.
  * Theorem 6 states the imitated verifier's guarantee: expected failed outputs at most (1−β_V)K_V/β_V plus the failures V_H itself passes.
  * The §7 table says "the human's soundness, plus ε if imitated".
* **A2 (V-cone: (A4) is vacuous).** Accepted.
  * The note now uses two predicates: S_V, what V decides, used by Lemma 1, Lemma S and τ; and S\*, the goal.
  * Correctness is (A4′): S_V implies S\* on the imitator's final notebooks. For V-cone, (A4′) is L's soundness (L2); this is stated in §6.
  * (A3) is weakened to (A3′), which is what Lemma 1 uses.
* **A3 (Proposition 7).** Accepted. It now assumes (L0), (L1) and (L2). It has disjoint categories (invalid; else ripe or hedge; else other), a per-run d_t, and states exactly where (B_D) is assumed.
* **A4 ((B_D) at bizarre entries).** Accepted. Theorem 5(d) and 5(f) say "bizarre entries included".
* **A5 (Theorem Q1 misquoted).** Accepted. It now reads: "using fewer than about q/16 verifications per insight problem … Ω(nK/log(nq/ε))". It also notes that VSI uses about one verification per problem, and that Q1's verifications are stronger than VSI's.
* **A6 (Theorem 6(c)).** Accepted: "in expectation", and β_V = K_V/(εT) needs T or a doubling schedule.
* **A7 (the J1 sketch).** Accepted, with the referee's count: a point query among about N/s ≈ Λ candidates.

### B. Overclaims

* **B1.** Accepted.
  * Correctness is "every output satisfies S_V; under (A4′) it satisfies S\*". The note says what (A4′) means for each verifier, and that it uses neither determinism nor any property of the human.
  * The output is the verified artifact.
  * The phrase "no assumption about how the human reacts" is gone. §6 says V-human rests on a human judgment of the final state.
* **B2.** Accepted. A paragraph after Theorem 6 says when imitating the verifier pays, and that on distinct research problems one should budget about one human verification per problem.
* **B3.** Accepted:
  * J4, not J3, gives the lower bound, on faithful hiding classes;
  * G3 covers task queries and steps that depend only on the work processed;
  * G1's corollary is a guaranteed gain;
  * trees: T4 is written out in outline and T8 is a sketch, and a node verifier costs 1 + min{r, (D+1)r/(s+1)};
  * J1 has setback "at most D", with the online bound's protocol class;
  * F3 is n₀, with its conditions;
  * the deployment remark is attributed to SI-ABC, and its extension to Proposition 7 is listed as open;
  * "four places only" is now "in these threads", with concentration added.
* **B4.** Accepted.
  * The column is now "guarantee on task queries", and the no-verifier rows carry Theorem H1's 1/α.
  * V-machine requires the human's chain to end with the checkable artifact (§2.1).
  * Proof assistants and tests have separate rows.
  * The V-cone and V-human numbers now follow thread S.
* **B5.** Accepted.
  * §7 compares guarantees, states the factor-2 margin with the default weights, counts verification separately, and adds the human-does-it baseline.
  * Theorem 5(e) lists verifications and post-mortems.
* **B6.** Accepted.
  * "Most weak-link failures end with no claimed solution" is removed.
  * Answer 5 and §5 discuss p·w·f, and conditioning, citing note.md §6.3.
  * Asking at the final-answer slot is an optional guard (§2.2).
* **B7.** Accepted. The abstain rule (step 3(iii)): if the scan exhausts the run, report "not solved within n". After an excused flag the protocol continues with (ii). Theorem 5(c) proves termination.
* **B8.** Accepted. §6 discusses the constraint per verifier: V-machine fully, V-human as a weaker assumption of a final-state check, and V-cone as a local judgment with the first note's mechanism.

### C. Numbers

* **C1.** Accepted: 40 → 55 → 54 for U+S+H.
* **C2.** Accepted: 1.45× and 1.64×.
* **C3.** Accepted: 160–490 at n₀ = 8, then about 205; 2,915 → 12,724 → 51,365; 13–16, with 38 for misled-8.
* **C4.** The 6–23× figure is dropped. Asking is now optional at the final-answer slot only, and the trade-off is in slack-imitation.md.
* **C5.** Accepted: "under every protocol at α = 0.3", and "followed by a valid weaker result".
* **C6.** Accepted: 285–310.
* **C7.** Choice blindness is no longer quoted in this note.
* **C8.** Accepted. The thread list is in §12 without a count, and "Study 3" no longer appears.

### D. Minor

* **D1.** Accepted: (L0).
* **D2.** Accepted: the stricter definition, and committedness.
* **D3.** Accepted: the hedge definition is as the referee suggests.
* **D4.** Accepted: empty streams are skipped and the scan bound is sure; the weights are now explicit.
* **D5.** Accepted: β for audits, β_V for verifier audits, β_nr for the never-recovered share.
* **D6.** Accepted: reviews are triggered by entries.
* **D7.** Accepted: 4(1 + d).
* **D8.** Accepted (Theorem 5(e)).
* **D9.** The note's §1 says that Theorems 5 and 6 extend "by the same argument". The fix to thread H's proof wording is noted for that working file.
* **D10.** Accepted (as D9).
* **D11.** Superseded: the post-mortem is now written by a second researcher, who has no reason to recognize the style as its own.
* **D12.** Accepted: K/b_α, almost surely.
* **D13.** Accepted: Lemma 3 fixes the decoder.
* **D14.** Accepted (Section 4).

## Second red team (thread S)

* **The framing.** Accepted.
  * The recommendation is narrowed to VSI with a machine verifier on a formally stated goal. Elsewhere VSI is "the best scheme I have found, but not one to be sure of".
  * Answer 4 says the verifier deserves most of the credit.
* **Rerunning until accepted** (§1.3). Accepted. Answer 5 is the p·w·f caveat, and §5 discusses conditioning.
* **Imitator-style errors are hard to catch** (§1.2). Accepted. §6 quotes thread S's estimates of f.
* **Selection** (§2). Accepted. A new §5 lists:
  * conditioning;
  * repeated verification, mitigated by caching verdicts on a canonical form of the claim;
  * enrichment;
  * allocation, which is why β = 1 is recommended with human verifiers;
  * practical learners.
* **Post-mortem contamination** (§3). Accepted. Post-mortems are written by a second researcher. The leak through out-of-order queries is in §11, and is one reason for the scan-heavy default. Measurement 4 in §10 covers both.
* **The idealizations favour VSI with a machine verifier** (§4). Accepted, and said in §7. The (A2) tail is handled by the abstain rule. The heavy instruction is optional; the core keeps only what the verifier needs.
* **The 4/3 margin** (§6). Addressed. The default weights (½, ¼, ¼) give a sure 2n₀ per rejection, a factor-2 margin, with verification counted separately.
* **The user's constraint** (§5). Accepted, as B8 above.
* **Weighted streams** (§6). Adopted: Lemma 3 with weights, and the scan-heavy default.
* **Independent verifiers, verification by use, colleague framing for verification, the final "nothing bizarre" check.** Adopted:
  * independent verifiers and colleague framing, in §2.2;
  * verification by use, in §5;
  * the final "nothing bizarre" check, in the core (§2.1).
* **Probabilities** (§7). Adopted: the §7 table shows the draft, thread S and the final figures, which are thread S's.

## Referee 7 (the revised version)

The report is [`referee-report-verified-slack-v2.md`](referee-report-verified-slack-v2.md).
* *What held.* The headline holds: correctness of outputs rests on (A4′) alone, and the 2n₀K worst case stands once the schedule is fixed.
* *What did not.* The revision introduced four errors in Theorem 5, and left one gap in Proposition 7. All are fixed, item by item:

### A. Errors

* **A1 (b_α with final-answer asks).** Accepted. Theorem 5 now uses b = 1 when asks are limited to the final-answer slot or absent, and b = b_α only with asks at every unconfident step. The proof of (b) says why.
* **A2 ((M1), (M2) for the check).** Accepted. (M1), (M2) and (M-prefix) are assumed when the check is used, and Theorem 5(c) says termination needs (M2).
* **A3 (Theorem 5(f) and S\*).** Accepted. (f) now assumes S\* preserved by appending, τ\*(x₀) ≤ n₀, and (B_D) in τ\*. Without the check it also assumes (B_D) for bizarre entries.
* **A4 (the schedule).** Accepted.
  * §2.3 fixes the order S, U, S, H; an empty or exhausted list's turn goes to S.
  * Lemma 3 is stated for periodic schedules, with exact constants for the default.
  * A random schedule is said to give the bounds in expectation only.
* **A5 (Proposition 7, bizarre entries).** Accepted.

### B. Overclaims

* **B1 (contamination through verification and checks).** Accepted. §2.2 asks that every reader of a run before it is searched or audited be someone other than the imitated human: a verifier, a referee, the checker. Otherwise the cost theory assumes the answers are unchanged. §10 item 4 and §11 are extended.
* **B2.** Accepted. §2.1 marks the check as optional, a human judgment on which correctness does not rest. §6 is reworded.
* **B3 (heavy tails).** Accepted. (A2) fails on a quarter of problems, of which 6–11% of all problems go unfinished even within 2n₀. Searches on the rest may cost up to 2n, and a higher quantile for n₀ is suggested. Theorem 5(d) and (e) include the 2n cost.
* **B4 (the effort margin).** Accepted. §7 states that the factor 2 is for search queries with V-machine and β = 0. With a human verifier, the bar holds only for T up to about 40–55K. The formalization cost is a condition of the 70% row.
* **B5 (Proposition 7's guarantee).** Accepted. The table now gives about max{d_max, n/c_r}·K/b_α, which is about n per bit with a small retry r.
* **B6 (which claim).** Accepted. V accepts if some claimed solution passes, and the first passing one is output; §5 notes multiple claims.
* **B7.** Accepted. Theorem 5(a) says that for V-human and a human referee, (A4′) is itself an assumption about a human judgment.
* **B8 (f_eff).** Accepted. Answer 5 uses p·w·f_eff with f_eff ≈ 1 − (1−f)^r.
* **B9 (which τ).** Accepted. τ_V and τ\* are defined in (A2). Proposition 7 uses τ\* and its own form of (A2).
* **B10 (V-cone's (A4′)).** Accepted. §6 lists L's soundness, the statement being the goal, and correct records.
* **B11.** Accepted: "does not reach a verifiable solution within n steps".

### C. Numbers

* **C1.** Accepted. §8 gives both the equal-weight and the default-schedule EQ figures, from referee 7's re-run, and states the price of the sure 2n₀ (up to 2.3× for bounded-setback humans).
* **C2.** Accepted: 204–227.
* **C3.** Accepted: "(ρ = ½, equal weights)".
* **C4.** Accepted: f_aimed = 0.9.
* **C5.** Accepted: "at most log₂ k".
* **C6.** As B3.
* **C7.** Accepted: 260–300 → 1,200.
* **C8.** Accepted. §7 notes that the V-human figure is for an imitated verifier, and that verifying every output should be at least as sure.

### D. Minor

* **D1.** Accepted: Lemma 3's proof uses bounded discrepancy.
* **D2.** Accepted: Lemma 1 assumes (A1) and (A3′).
* **D3.** Accepted: flagged steps are queried in turn, and excused ones cost one query each.
* **D4.** Accepted.
* **D5.** Accepted: the check is cited from slack-imitation.md §2.
* **D6.** Accepted (as A3).
* **D7.** Accepted.
* **D8.** Accepted: the final-answer slot is defined.
* **D9.** Accepted: Answer 6 says n₀, or the routine work.
* **D10.** Accepted: 2n₀.
* **D11.** Accepted: the tree bounds are in expectation, need bounded setback within a call, and b(D+1) ≥ 2ρ.
* **D12.** Accepted.
* **D13.** Accepted: f₁f₂ + Cov.
* **D14.** Accepted: n distinct steps with caching.
* **D15.** Accepted: the exact conditioning formula.
* **D16.** Accepted (Theorem 5(c)).
* **D17.** Accepted: located probes and the confession state are listed.
* **D18.** Accepted: §11 mentions heavy tails.
