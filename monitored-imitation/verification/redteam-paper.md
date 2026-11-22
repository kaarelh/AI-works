# Red team of the paper *Verified slack imitation*

*Reviewer: Claude (AI red team), 22 November 2026. Target: `paper/verified-slack-imitation.tex` at commit 640cb577 (583 lines, md5 1797b8cb…). Line numbers refer to that version. I changed no file other than this one.*

**Method.** I read the paper as its reader would and checked the blind-spot material against `research/threadQ2-freshlook.md`, its script, and threads S, T, U and W. I reran Part C of `threadQ2_blindspot.py` (same draws, `threadU_verify.py` unchanged) with one change: `rbar * cbar / TK` replaced by `rbar * (cbar + 1) / TK`. Where referee 9 (`verification/referee9_checks.out`) already found something, I say so and keep it short.

**Summary.** Nothing here is fatal to the machine-verifier headline: correctness from V, at most 2n₀K queries under (A1)–(A3′), 70% conditional. Two issues are fatal to the VSI-R half of the headline as it is written.

---

## 1. FATAL (VSI-R): Theorem 4.13 does not deliver the jump from 46% to 58%, or from 60% to 66%

**Where:** abstract l.46; §1 l.66; §4 l.286; Table 1 l.412 and caption l.421; §9 l.492. Source: `threadQ2_blindspot.py`, `F["kinds"] = np.minimum(F["orig"], rbar * cbar / TK)`.

**What is wrong.**
* *The theorem's constant was dropped.* Theorem 4.13(a) proves E[wrong] ≤ (c+1)K/b. The "kinds" column that feeds the VSI-R row uses r̄·c̄·K/T: the "+1" is gone.
* *The +1 is needed.* Reruns of rejected problems are not fresh draws from μ, so (C_c) does not cover them. Q2's Part A sets the +1 to zero only by assuming that every rerun succeeds.
* *Rerun with the +1,* the theory "kinds, β=0.1" term falls from 76% to 68% with thread U's w. With thread W's w (0.4–0.8), which the paper adopts at l.500, it falls to 62%. Q2's formula then gives:
  * theory: about 52%, or about 49% with thread W's w (paper: 58%);
  * software: about 62% (paper: 66%).
* *The theorem then contributes nothing.* The (c+1) term equals the no-theorem baseline at β = 0.1 (67.6% against 67.5%). What remains above 46% comes entirely from dropping audits, which thread U's model never credits with reducing failures.
* *Why it cannot help here.* (c+1)K/(bT) ≤ 5% needs T/K ≥ 20(c+1)/b, about 22–27. That is the top 8% of the model's T/K range of 3–30.
* *The new caveat is unpriced.* The paragraph at l.292 concedes that part (a) is plausible only for a product of kinds, each learned as a unit. That caveat is not reflected in q = 0.65.

**Fix.** Choose one:
* prove the sharper bound under an extra stated condition: (C_c) also holds on reruns of rejected problems, which is essentially part (b)'s per-claim condition;
* or report VSI-R at about 50% for theory and 62% for software, and say the gain over the fixed verifier is within the noise of the estimates.

Abstract wording: *"…and, for informal theory and software, about 50–60% with a randomized pool of verifiers (Theorem 4.13 adds monitoring, not sureness, at realistic numbers of problems)."*

## 2. FATAL (VSI-R as specified): rejections that end without a hit break the K/b budget and the monitor

**Where:**
* the hypothesis (A3′) of Thm 4.13, l.274, used in its proof at l.281;
* protocol step 3(iii), l.125;
* §6.2, l.357–364, which has no (A3′) bullet for human verifiers;
* §9: VSI-R's caching and monitoring rules, l.472 and l.474, and "Critics can only add rejections", l.489;
* heavy tails, l.360.

**What is wrong.** Every result used for VSI-R assumes that every rejection ends in a hit. The paper's own sources give two large sources of rejections without a hit.
* *False rejections of the human's own correct claim.*
  * Thread U's model gives 0.41 upheld false objections per verification of a correct result for the recommended theory pool. It gives 0.30 for software, 0.48 for empirical work and 0.56 for judgment work. So about a third of correct claims draw at least one.
  * Thread U neutralizes these with a second judge, called after a task query shows the located step to be the human's own (`threadU-nonformal.md`, item 8). It charges 1.05 task steps each.
  * The paper's protocol has no such step. It scans the whole run (about 2n queries) and abstains.
  * Caching verdicts on canonical claims (l.472) makes a false rejection permanent.
* *Heavy tails.* By l.360, 6–11% of problems are not finished within n = 2n₀. They are rejected on every run.
* *Consequences.*
  * R ≤ K/b fails, since R grows linearly in T, so the bound (c+1)K/b is void.
  * The monitoring rule "(ĉ+1)×windowed rejection rate ≤ 5%" can never certify, because the rejection rate has a floor of about 10–20%. Referee 9 (F5) found the half due to false objections.
  * The claim "at most 2n₀K, independent of the number of problems" (l.46, l.64) fails at the paper's own (A2) failure rate.

**Fix.**
* *Protocol.* Add step 3(iv): *"If V's objection is located at a committed step that a task query shows to be the human's own, a second judge decides; a dismissed objection is not a rejection."* Cap the scan at n₀ and abstain there, at a cost of at most 2n₀. Never cache a rejection whose search found no mistake.
* *Theory.* Replace (A3′) for human verifiers with this located-and-dismissed version, and re-prove Lemma 4.2. Restate (C_c), and the monitor, with only rejections that end in a hit in the denominator.
* *Case.* Add an (A3′) bullet to §6.2 with thread U's false-objection numbers.

## 3. MAJOR: "every kind of error caught sometimes" is not the theorem's hypothesis

**Where:** abstract l.46; §1 l.64; §4 l.286; §6.1 l.355. Partly corrected at l.292.

**What is wrong.**
* *What the theorem actually needs:*
  * i.i.d. problems;
  * (A1)–(A3′);
  * exact Bayes with a majority decoder;
  * (C_c) at every reachable state, which l.292 concedes holds only for products of kinds, each learned in one hit.
* *Three ways it fails for a real researcher:*
  * **The order of problems adapts.** Research problems are follow-ups to accepted outputs. A wrong output that V passed spawns follow-ups that reuse the same wrong idea, and V misses them again. So independence fails in exactly the harmful direction. VSI-R's own falsification by use (l.480) makes problems cite the current library, which depends on the state; that contradicts the proof step "the next problem is independent of the state" (l.282).
  * **Knowledge is problem-specific.** This is the paper's own motivating case (l.55). Then K grows with T, and the failure rate stays at p·w·f. Q2's own simulation gives 6.1% at every T.
  * **Selection happens within a kind** when the reader is deterministic. Hits remove only hypotheses whose errors V catches, so the remaining errors are exactly the ones V passes. The learner does not learn to fool V; it simply never collects data where V is blind. The result is the same.

**Fix.** Replace the gloss everywhere with the conditions. Suggested abstract wording: *"…whose failure rate is at most (c+1) times the rejection rate when problems are i.i.d., when knowledge is shared across problems in units each learned from one located mistake, and when V catches each unit's errors at a rate bounded away from zero at every stage of learning."*

## 4. MAJOR: the abstract drops the conditioning on the idealizations

**Where:** abstract l.46 (*"our calibrated probability that the scheme works on a real careful researcher: about 70%"*); against §7 l.400 (*"conditional on … determinism, a learner whose class contains the human, and a cold-start chain …"*).

**What is wrong.**
* A real careful researcher is not deterministic. Thread S (`threadS-redteam2.md` l.249) puts the unconditional machine row at about 40%.
* "Calibrated" implies a track record that no estimate here has.
* L.425 says "the remaining doubt is in the idealizations", which contradicts l.400's statement that the figures are conditional on them.

**Fix.** *"…our estimate, conditional on determinism, realizability and the human's own chain reaching the goal, that the scheme works: about 70% with a proof assistant … (about 40% without that conditioning)."* Then delete "in the idealizations" from l.425.

## 5. MAJOR: a failure mode the paper never mentions — mistakes are exact-label mismatches, so K includes style

**Where:** definition of a mistake, §2 l.85; the case, §6.2; orders of magnitude, §10 l.516; the paper never uses the word "wording". Thread S lists this (l.181, l.246) as a main reason O(K) gets only 25%.

**What is wrong.**
* *What counts as a mistake.* With a deterministic P, a step is three months of exact entries, and a "mistake" is any difference from them.
* *What the scan finds.* It stops at the earliest difference. For a realistic imitator, that is almost always a stylistic difference at step 0, not the error that made the run fail.
* *So K counts style.* A rejection teaches style; the theorems stay true but K is enormous. In the limit, VSI degenerates to the human redoing each failed problem, which Proposition 4.10 caps at 2n₀ per problem.
* *With a real human,* deciding "same step?" becomes a judgment of the imitator's step, close to the on-track judgment the question excludes.

**Fix.** Add to §6.2: *"Mistakes are label inequalities, so K counts everything that distinguishes P's exact entries, including style, unless the scaffold canonicalizes entries (typed records in normal form) so that labels compare content. Choosing that canonical form is a design decision the cost theory depends on."*

## 6. MAJOR (exposition): where Kaarel stops believing

* **O(K) is answered in a caption.**
  * His central ask was O(K) reasonable queries. The answer, "about 25%", appears only in the Table 1 caption (l.421).
  * The worst case is 2n₀ three-month queries per bit, 48 human-quarters (l.516).
  * Say in §1: *"We do not reach O(K). The worst case is 2n₀K task queries of three months each; O(K) holds only when pointers or local checks locate mistakes, which we put at about 25%."*
* **The 70% row lives where imitation is least needed.**
  * On a fixed formal statement, an optimizer plus a kernel already gives correct outputs. The paper itself puts an optimizing formalizer inside V (l.106, l.391) and calls that safe.
  * Say up front what imitation adds there: a human-like process with bounded selection.
  * Say also that for the work alignment needs, which is judgment-heavy, the answer is 15–22%.
* **The protocol box (l.115–130) is overloaded.** It mixes the core with six options: asks, the bizarre check, audits, route (i), a three-source H list, and statement halts. State minimal VSI in four lines first: run n₀+σ steps; verify; on rejection, query the human from step 0 until the first deviation; add it and rerun. List the options afterwards.
* **The cost case leans on judgments of runs.** M2 and M8 stay flat only with post-mortem pointers (l.463). Those are a second researcher's judgment of where a run went wrong. §6.4 should say that VSI's cost case, though not its correctness, uses such judgments.
* **There is no conclusion.** The paper ends with "what to measure". Add five lines of verdict.

## 7. MINOR: stale or inconsistent numbers

* *c uses the old w.* L.286 computes c = 0.24 from w = 0.45 (thread U), but §9 (l.500) adopts w ≈ 0.6 (thread W), which gives c ≈ 0.35 (referee 9, F3).
* *The two halves of the VSI-R formula use different w.* The VSI-R term uses thread U's w; its fallback (46%) uses thread W's. Even the uncorrected formula gives about 55% with thread W's w, not 58%.
* *Empirical and judgment figures disagree.* The abstract says "15–20%", §1 l.66 says "about 20%", and Table 1's VSI-R row says 18% / 22%.
* *The one-reader figure.* L.416's "43% as in VSI-R" compares with Q2's 45% (fallback 40%). Q2's formula with fallback 35% gives 42%.
* *An overgeneralized citation.* "Human researchers: about 0.3 of failed projects" (l.498) comes from 36 antidepressant trials (`threadW` l.23). Say "clinical trials".
* *Spot-checked citations that hold up:*
  * thread T: AnnalsChallenge 11 of 50 (22%), and 24% statable;
  * thread L: 30–60% of planted errors caught;
  * thread W: 54% → 9%, and 3.5%, 1.6%, 9%, 7%;
  * thread U: 0.29, 0.23, 0.17, 0.16; 0.24 against 0.16; 0.43 → 0.18;
  * thread Q2: q = 65%, 70%, 25%, 30%.

## 8. MINOR: Theorem 4.13(b) is still wrong for notebooks with several claims, and close to vacuous for the recommended pool

**Where:** l.277 and l.283.

**What is wrong.**
* V accepts if *some* claim passes. The proof counts rejections of individual claims as rejections of runs, but only run rejections end in hits. With two wrong claims per run, there are 0.56 wrong outputs per rejection against the bound's 0.25 (referee 9, F1).
* A per-claim f̄ < 1 is implausible for "deep" errors. Thread U puts the pool's miss rate on them at 0.86–0.95, with a correlated loading of 0.6.

**Fix.** State (b) for the first-claim variant (l.393), make VSI-R use that variant, and add one sentence on deep errors.

## 9. MINOR: what resampling does to c

**Where:** l.294.

**What is wrong.** "A resampling learner inflates c by up to its number of samples" is false. Referee 9 (F2) finds c multiplied by 5 with 2 samples and by 22 with 3.

**Fix.** *"Resampling inflates c roughly by x^{-(k-1)}, x the rejection probability; VSI-R must forbid it."*

## 10. MINOR: the monitor cannot be calibrated as described

**Where:** l.474 and l.288.

**What is wrong.**
* ĉ comes from planted-error tests. But l.353 argues that the imitator's wrong results are the most typical-looking ones, the hardest to catch, so planted errors underestimate c.
* c is a supremum over reachable states, which no planted test measures.
* The bounds hold in expectation. A windowed rate needs a concentration bound.

**Fix.** Estimate c from audits of accepted outputs by independent solution (§9's certification), with a confidence interval.

## 11. MINOR: VSI-R's fallback assumes audits that VSI-R does not run

**Where:** Table 1 l.411–412; §9 l.492.

**What is wrong.**
* The fallback is the full-audit row (β = 1), but VSI-R audits at β = 0.1.
* Proposition 4.11 says β = 1 is what bounds failures when V has blind spots.
* Thread U's model gives audits no effect on failure, so it cannot see the difference.

**Fix.** Keep β = 1 in the world without the theorem, or lower the fallback.

## 12. MINOR: "works" and the theorem's regime barely overlap

**Where:** §7 l.400; Corollary 4.15.

**What is wrong.**
* "Works" compares against chained imitation's worst-case bound (20n₀K) with a fixed total budget. In the model, that caps T/K at about 30.
* Theorem 4.13 needs T/K ≳ 25.

**Fix.** State the T/K range assumed, and say that the two regimes barely overlap.

---

## Verdict

* **The machine-verifier headline holds up,** as a conditional claim. Every output passes V; under (A1)–(A3′) there are at most K rejections at 2n₀ each; and 70% is reasonable *given* determinism, realizability and a chain that finishes.
* **A reader should hold it more loosely than the abstract invites,** for three reasons:
  * about 40% unconditionally (thread S);
  * a "mistake" that counts style (issue 5);
  * a domain where imitation adds least.
* **The VSI-R half is not yet supported:**
  * the recommended pool violates (A3′) about a third of the time by the paper's own source model;
  * the monitor can never certify against the floor of rejections without a hit;
  * with the theorem's actual constant, the 12-point uplift disappears (about 50% for theory, 62% for software).
* **The single most useful change:** take VSI-R's numbers and the "caught sometimes" gloss out of the abstract until the protocol has a dismissal rule for located false objections and the figures use (c+1). Lead instead with the conditional machine-verifier result and a plain answer to the O(K) question ("no: 2n₀K three-month queries in the worst case").
