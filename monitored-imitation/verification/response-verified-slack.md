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
