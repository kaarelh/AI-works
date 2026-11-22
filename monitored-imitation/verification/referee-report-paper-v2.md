# Referee report on the revised paper `paper/verified-slack-imitation.tex` (referee 10)

## About this review

* **Version.** 670 lines, md5 `f048d66c…`. It compiles cleanly in a scratch directory: 26 pages, no undefined references, one overfull line of 1.2 pt (l. 380). Theorem numbers below are those of the PDF; line numbers refer to the .tex.
* **Scripts.**
  * `research/threadY_trees.py`, rerun unchanged in 25.6 s. Its output, [`referee10_threadY_rerun.out`](referee10_threadY_rerun.out), is byte-identical to `threadY_trees.out`.
  * [`referee10_checks.py`](referee10_checks.py) → [`referee10_checks.out`](referee10_checks.out) (standard library, under 10 s). It contains:
    * Part A, a stress test of Theorem 5.1 under general deviations;
    * Part B, the final-check gap and two fixes;
    * Part C, Proposition 4.10(b) with adversarial learners;
    * Part D, the numbers.
* No existing file was edited. Nothing was committed.

## Verdict

**Minor revision, with one error in Section 5 to fix.**

* **Theorem 5.1's induction is correct** for rejections whose root record is not "proved". I checked it line by line.
  * Part A covers 736 such rejections, with several lemmas per round, mistakes at the proof round, slack rounds, recoveries and alternative proofs. Every search hit, every path call was the human's own, and the cost was at most Σπ_ℓ + t*(u_L) ≤ pd + r₀ every time (the largest ratio to the bound was 1.00).
  * **But the model also makes a failure of the final whole-development check a rejection, and such a rejection need not end in a hit (E1).** The fix is a one-line change to the model.
* **Proposition 4.10 and Theorem 4.13 are now correct.** Referee 9's counterexamples A1 and A2 no longer apply.
* **The headline figures are consistent everywhere** (70/40, 45, 50/60, 15/20, 25). The summaries of Section 5 in the abstract, introduction and Verdict overstate its assumptions and its lower bound (O1–O3).
* **The earlier reports were addressed** almost completely. Two small residues remain (§4).

---

## 1. Section 5 (Theorem 5.1)

### E1 (error). A rejection by the final check need not end in a hit

**Location.** "The model", the Output bullet (l. 342) and the Records bullet (l. 340). The proof, l. 360: "At the root this is the rejection and (A2-tree)."

**What is wrong.**
* Node records are checked only "by the kernel" (l. 340). The final check uses the hardened pipeline: an axiom whitelist and two kernels.
* The proof's base case assumes that the rejected root *fails*, that is, that its record is not "proved". A final-check rejection breaks this. Suppose a mistake inside a child writes a proof that the node kernel accepts but the hardened pipeline rejects: a non-whitelisted axiom, `native_decide`, or a bug in one kernel. Then every record can be "proved".
* The search then scans the root's rounds, never descends, and ends with no hit. Nothing is learned, so the decoder is unchanged, and the rerun repeats the same rejection forever.
* (b), (c) and (d) all fail for such problems, even though the human's own blueprint succeeds.

**Evidence (Part B).**
* *Minimal case.* Root R poses lemma A in round 1 and proves R from A in round 2. The imitator writes a "dirty" proof of A. Both records are "proved", and the final check fails. The search makes 2 queries and finds no hit. A depth-first scan finds the mistake at position 2.
* *Random model, with dirty proofs at 15% of mistakes.*
  * 66 of 242 rejections were final-check failures.
  * 49 of those ended without a hit. All 49 reran identically, so their problems would loop forever.
* *Thread Y's toy* never models the final check, so it could not see this.

**Fix (preferred).** Check records with the hardened pipeline.
* *Records bullet:* "a proof of its statement that the hardened pipeline (axiom whitelist, two kernels) accepts, with the elaborated statements of the lemmas recorded as proved as hypotheses".
* *(A2-tree):* "Every call of the human's own tree proves its statement, by that check, within r₀ rounds."
* *Output bullet:* "…a failure of this check can then come only from a fault in the scaffold, and halts the protocol for review."

**Alternative fix.**
* Keep the rejection, and assume that the human's own assembled development passes the check.
* On a final-check failure, scan the run depth-first. Its first mistake comes within N*_r queries, by the argument of the lucky-proof bullet.
* State (c) only for rejections whose root record is not "proved".

Part B tests both fixes: every search hits and every bound holds.

### O1 (overclaim). "Assuming only that the human's own blueprint succeeds"

**Location.** Abstract (l. 47), introduction (l. 67), Verdict (l. 600).

**What is wrong.**
* (A2-tree) requires *every* lemma the human poses to be proved within r₀ rounds, so the human never restates a lemma. Thread Y §6.3 says: "Strict (A2-tree) fails on any large project."
* The variants need more:
  * the disproof variant needs every lemma decided;
  * too-hard abandonment adds A and needs (No-lucky), which is an assumption about the imitator.

**Fix.** "…assuming that every lemma of the human's own blueprint is proved, or disproved, within r₀ rounds (with too-hard abandonment the cost grows by the human's abandoned work next to the search path)". Add thread Y's sentence on strict (A2-tree) to "Abandoned lemmas".

### O2 (overclaim). The lower bound is a sketch

**Location.**
* "this is necessary up to a logarithm" (l. 47);
* "optimal up to a logarithm" (l. 67);
* "dropping it costs exactly Σπ_ℓ" (l. 366).

**What is wrong.**
* Thread Y's Theorem Y2 is tagged [S], and §5 itself says "a sketch".
* T6's bound and Theorem 5.1's bound differ by Σπ_ℓ − 1, and only the sketch says that this difference is necessary.

**Fix.** Write "a sketched lower bound suggests this is necessary up to a logarithm". At l. 366: "costs at most Σπ_ℓ, which the sketched lower bound says is needed".

### O3 (inconsistency). Units and granularity

**Location.** The abstract, l. 67, l. 600, and Table 1's 45% row.

**What is wrong.**
* Elsewhere in the abstract, a task query is a three-month step. In §5 it is one round, which thread Y estimates at a working day.
* K is then the complexity of the round-level program.
* Determinism and cold start per round are stronger idealizations than per three months: the human keeps nothing unwritten between rounds.

**Fix.**
* Abstract: "…at most pd + r₀ task queries of one round each (say a working day) per rejection…".
* Model bullet: "(A1) is for P as a function of call transcripts, and K is its complexity."
* §5 "How sure": "conditional on the idealizations at the granularity of rounds".

### What checks out

* *The induction.*
  * j₀ ≤ t*: otherwise the transcripts agree through t* and u writes u*'s proof.
  * At j₀ the search either hits or meets a correct round, which poses u*'s lemmas. The first lemma not proved is certified, with π = j₀.
  * Fuel decreases, and at a call that poses nothing, j₀ is a mistake.
* *Several lemmas per round* (descent into the first lemma not proved), *a mistake at the proof round* (a hit at cost at most t*), and *slack rounds after t\** (never scanned) are all handled; Part A exercises each many times.
* *Consistency of the logic* is not needed for the plain variant: a disproof before j₀ would be the human's own.
* *A hit inside a child call* is a mistake of the decoder at a transcript the human answers, so Lemma 2.1 gives at least one bit (but see M4).
* *The variants.* The disproof variant holds verbatim. The too-hard and lucky-proof bullets match Theorems Y3 and Y3c.

### Minor

* **M1 (l. 340).** "So equal records on equal questions give equal transcripts" is garbled. Replace with: "the lemmas a round poses are run, in order, when the round ends, and only their records are appended to the parent's transcript before its next round; so a call's transcript depends on its lemmas only through their records."
* **M2.** Say three things that the proof uses:
  * a proof entry is terminal only if the check accepts it;
  * it may cite only lemmas recorded before its round;
  * a call with no terminal entry within r rounds is "open".
* **M3.** Define "certified" recursively: "the root, or a lemma posed at the same index of the same round by a certified call whose transcript before that round equals its human counterpart's".
* **M4 (l. 360).** "The decoder is fixed during the run" is false with asks at every unconfident round, which is when b = log₂(1/α). Use Theorem 4.7(b)'s reordering instead: list first the asks made before the hit, in execution order. Without asks the sentence is correct.
* **M5.** p, d and r₀ depend on the problem, so (d)'s total needs their maxima over problems.
* **M6. Notation collisions.**
  * p, the posing round, is also the first-run failure rate in pwf (l. 313, 424, 558).
  * c (l. 368) is also Definition 4.12's constant.
  * d, the depth, is also Theorem 4.7(d)'s number of decisions.
  * L, the path length, is also the local check.
* **M7 (l. 368).** The slack bound needs the last call to pose no failing lemma (thread Y, Y1(d)). Add that condition.
* **M8 (l. 365).** "6.7–17 … 120–351" holds for the four configurations without abandonment; I reproduced it exactly. With abandonment the figures are 7.2–20.9 against 200–782. Say "without abandonment".
* **M9. Evidence.**
  * "3–15% (from the Carleson and PFR repository histories)": the low end is the Carleson paper's named cases, and the high end is thread Y's reading of the diffs. 79 of 179 and 37 of 87 statements were edited at all.
  * "Chains run 11–26 deep" omits Equational Theories (5).
  * "35% for new research" is thread Y's product of 31%, rounded up ("say 35%"). With 31%, the average is 43%.
* **M10 (l. 65).** "What we prove" omits Theorem 5.1. Add one sentence.

---

## 2. Proposition 4.10 and Theorem 4.13

**Proposition 4.10 is correct.**
* *Referee 9's A1 no longer applies:* route (i) and the bizarre check are excluded, the protocol now says the scan skips cached notebooks without using up its turn (l. 130), and the last paragraph explains why.
* *The proof checks out:*
  * scan queries fall on uncached chain notebooks c_i with i < n₀;
  * non-scan queries are at most the scan queries, and one fewer after a scan hit;
  * the scan reaches c_{n₀−1} only as a hit;
  * so the searches cost at most 2n₀−1, and one audit fits.
* *The new clause "2n without (A3′)" holds (Part C).* Four adversarial learners were run against verifiers that never accept or accept only after n₀. The worst per-problem count stayed within its cap: within 2n₀ under (A3′) and within 2n otherwise.
* **Minor (l. 255).** In "at most 2n₀M̄ + βT", βT is an expectation inside a sure bound. Write "plus the number of audits (βT in expectation)".

**Theorem 4.13 is correct.**
* *Part (a).* First runs are bounded by c, through i.i.d. problems and the definition at the current state. Reruns contribute at most one output per problem that has an informative rejection. The windowed form holds if a round is a problem.
* *Part (b).* A wrong first claim implies a committed mistake, because the human's first claim is right. With caching, each claim gets one fresh verification.
* *Referee 9's counterexamples.* A2 is answered by the first-claim rule. The formula (1−f̄)^{−k} − 1 at l. 300 is right (Part D). B1 is answered: "informative" removes (A3′), the monitor counts only informative rejections, and VSI-R has a second judge.

**Minor issues in Section 4.**
* **Overclaim (l. 314).** "The condition can hold at every reachable state only if the class is a product of kinds" is false for a verifier randomized per claim. With single-claim runs, such a verifier gives c ≤ f̄/(1−f̄) at every state, whatever the class, as the next paragraph says. Write: "With a deterministic verifier, the condition is plausible at every reachable state mainly when the class is a product of kinds…"
* **l. 307.** "About 25": 20(c+1) is 27 at c = 0.35.
* **l. 65.** "At most (c+1) times the number of rejections" should be "times the expected number".

---

## 3. Consistency across the paper

| figure | abstract | intro | Table 1 / caption | §5 | §10 | Verdict |
|---|---|---|---|---|---|---|
| 70% conditional, ≈40% without | yes | yes | yes | — | — | yes |
| 45% (blueprint, 3(pd+r₀)K) | yes | yes | yes (55/35) | yes | — | yes |
| VSI-R 50% / 60%; 15% / 20% | yes | yes | yes | — | yes (46→50) | yes |
| 25%, O(K) on chains | — | yes | caption | — | — | yes |

There are no stale headline numbers. The no-theorem baseline at l. 566 (46%) and the caption's remark on 58%/66% are consistent with the VSI-R figures. Smaller residues:

* **Inconsistency (l. 500).** "Below a fifth of chained imitation's **whatever the human**" survives referee 9's B4. Write "for every human satisfying (A1)–(A3′)".
* **Inconsistency (l. 475).** The figures are said to be conditional on "a cold-start chain that reaches the informal goal within n₀". But l. 500 counts heavy tails among the remaining doubts, l. 431 says (A2) fails on a quarter of problems, and the abstract says "a chain that finishes". Write "a cold-start chain that finishes" at l. 475.
* **Minor (l. 71 and Appendix C).** The provenance says Section 5 was checked "by a final referee". Cite this report, and mark E1 as resolved once it is fixed.

---

## 4. Were the earlier reports addressed?

| item | status |
|---|---|
| Referee 9, A1: Prop. 4.10 fails with route (i) or the bizarre check | addressed (restricted; scan-skip rule; robust 2n clause) |
| Referee 9, A2: Thm 4.13(b) with several claims | addressed (first-claim rule; remark with the exact ratio) |
| Referee 9, A3, A4: B_T reference; resampling | addressed |
| Referee 9, B1: (A3′) under VSI-R | addressed ("informative"; second judge; monitor on informative rejections) |
| Referee 9, B4: "whatever the human" | mostly; **residue at l. 500** |
| Referee 9, B9: falsification by use | addressed ((A1), (E2), recomputed after every hit) |
| Referee 9, C1/C2/C4: thresholds, c, Table 2 caption | addressed (0.21/0.21/0.15/0.14; 0.35; 53–73, 42–46) |
| Referee 9, D3: overloaded symbols | partly: b→a is fixed, but §5 adds new collisions (M6) |
| Red team 1: VSI-R without the +1 | addressed (50% / 60%; caption explains) |
| Red team 2: rejections without a hit | addressed: second judge; no caching of no-hit rejections; (A3′) bullet. The n₀ scan cap was not adopted, which is acceptable at a cost of 2n |
| Red team 3: "caught sometimes" | addressed ("When the condition fails") |
| Red team 4, 5, 6, 10: conditioning; style in K; O(K) answer and Verdict; calibrating ĉ | addressed |
| Red team 11: β for VSI-R | partly ("β ≈ 0.1 where the condition is believed"). Acceptable, since the caption credits the gain to the design, not the theorem |

Nothing was addressed wrongly.

---

## 5. Summary of fixes, in order

1. **E1.** Check records with the hardened pipeline, put that check into (A2-tree), and make a final-check failure a halt (or use the depth-first fallback).
2. **O1–O3.** In the abstract, introduction and Verdict:
   * replace "assuming only that the human's own blueprint succeeds" with the (A2-tree) wording;
   * mark the lower bound as a sketch;
   * say that blueprint queries are rounds.
3. **M1–M4.** State the record timing, the terminal and citation rules, the recursive definition of "certified", and the reordering argument with asks.
4. **Residues.** l. 500, l. 475, l. 255, l. 314, l. 365, and the notation collisions (M6).
