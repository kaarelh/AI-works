# Thread AA: noisy blueprints and research-shaped trees

*Working note by Claude (Anthropic). It combines thread Y's blueprint search ([`threadY-formal-trees.md`](threadY-formal-trees.md), the paper's Section 5) with model (ii) of thread Z ([`threadZ-stochastic-human.md`](threadZ-stochastic-human.md)), and examines trees shaped like research. Draft; not refereed. No existing file was changed.*
* *Code:* [`threadAA_noisy_trees.py`](threadAA_noisy_trees.py), which imports thread Y's tree generator unchanged. *Output:* [`threadAA_noisy_trees.out`](threadAA_noisy_trees.out). Runtime 88 s (`python3 -B threadAA_noisy_trees.py`).
* *Status tags:* **[P]** proved here (proofs in §8), **[S]** sketched, **[C]** conjectured, **[N]** numerical, **[J]** judgment. The toy checks bookkeeping and bounds; it tests no assumption about humans.
* *Numbering:* Lemmas S and B and results AA1–AA9 are this thread's.
  * From thread Y: Lemma Y0, Theorems Y1 and Y3, Corollary Y3a and Theorem Y2 (the lower bound).
  * From thread Z: Lemmas Z0 and Z2, Theorems Z4 and Z4′, and Propositions Z10–Z12.
* *Notation:* h is the binary entropy and kl the binary KL divergence, both in bits. ρ = δ/(1 − δ).

## Answers in brief

1. **What replaces certification.**
   * *The reference tree.* The noisy human's own tree is random. The reference is its **mode tree** T*_m, in which every call writes the human's most likely label. Under model (ii), T*_m is the core's tree.
   * *Certification* means a mode-correct prefix with records equal to T*_m's. It is only analytical: one answer cannot establish it.
   * *The run's records* come from the kernel, so they carry no noise. They select a set S of at most p·d + r₀ rounds that must contain the first mode mistake (Lemma S). **Records route; answers only teach.**
2. **Main theorem (AA1)** [P].
   * *Protocol.* Decode the posterior mode. On a rejection, ask once at every round of S, add every answer, and rerun.
   * *Result.* E[rejections] ≤ K/(1 − h(δ)), and each rejection costs surely ≤ p·d + r₀. So **E[task queries] ≤ (p·d + r₀)·K/(1 − h(δ))**, with no term in the number of problems.
   * *Assumptions:* realizability over stochastic round-level hypotheses; memoryless re-asks; a mode of probability ≥ 1 − δ on the mode tree's transcripts only; and every call of T*_m proves within r₀ rounds.
   * *Benign ties.* With k plausible labels per round, 1 − h(δ) becomes kl(1 − δ‖k/(k+1)).
3. **Early stopping and abandonment** (AA2, AA3) [P].
   * *A sequential search.* Thread Z's sequential test, walked along thread Y's S_cert order, needs no parameters and handles abandonment by the mode tree. E[rejections] ≤ K/((1 − h(δ))π_r), with π_r ≈ 0.85. The cost per rejection is ≈ (Σπ + t* + A + r)/(1 − 2δ) + 1.
4. **A core lemma that the noisy human sometimes fails to prove.**
   * *By slips:* free.
   * *By a plausible dead-end choice:* abandonment accounting over every tree of plausible choices (AA3).
   * *By a fatal choice:* thread Z's coin, which no decoder protocol handles.
5. **What is necessary** (AA4):
   * re-asks with fresh noise;
   * stochastic hypotheses;
   * no stopping at the first differing answer;
   * a dominant label or benign ties;
   * the factor p·d + r₀, up to a logarithm [S].
6. **Lemmas posed late (2a).**
   * *Σπ_ℓ is necessary* for searches that task-query the run's rounds (AA5) [P].
   * *Pointers* from the human's own next round after a failure give 2d + r₀. They need an assumption about corrupted transcripts and are kept safe by interleaving (AA6) [P].
   * *Binary search* needs a prefix check that the setting lacks (AA7).
7. **Context crossing calls (2b)** (AA8) [P].
   * *Frozen downward hints are free.*
   * *Upward text beyond records breaks agreement* (CE-up). Abandonment reasons are the exception.
8. **Lemma requests mid-call (2c)** (AA9) [P].
   * *The cost* is the ancestral prefix of the first mode mistake in the human's own tree.
   * *The enforceable rule* "pose a lemma no later than the round that first cites it" bounds π by the human's own round of first reliance.
   * *Nothing better* is possible while the working order is fixed.
9. **Simulation** [N]. Thread Y's toy at δ = 0, 0.05 and 0.1.
   * *Ask-all:* 40, 44 and 49 rejections per seed, at 12.9 task queries per rejection (maximum 13 = p·d + r₀). The noise factor is 1.09–1.17 and 1.22–1.33, against 1.40 and 1.88.
   * *Baselines:* the chain scan pays 202–234 per rejection; a deterministic learner abstains on 99% of problems; stopping at the first differing answer multiplies rejections by 2.3–12.
10. **Probability** [J]. **About 25% (15–35%),** conditional on realizability, not on determinism: about 35% for formalization-style work and 15% for research. Thread Y gave 45% conditional on determinism.

## 1. Model

**The blueprint** is thread Y's (§1 there): isolated calls on Lean questions, records from the hardened pipeline, proof irrelevance, caching, and a final check of the assembled output. A label is everything a round writes.

**The noisy human** P(·|y) is a stochastic program on call transcripts.
* **(R)** P ∈ H, a countable class of stochastic round-level programs, with K = log₂(1/w(P)). The learner is exact Bayes with predictive ξ_D, and the imitator is the mode decoder G_D(y) = argmax ξ_D(·|y), fixed during a run and its search. Φ and Lemma Z0 are thread Z's.
* **(M)** A task query at y returns a fresh draw from P(·|y), independent of everything before, including earlier answers at y.

**The mode tree.** Let m(y) be P's most likely label at y.
* *Definition.* T*_m(q) is the deterministic tree in which every call writes m(y) at each of its transcripts y. Thread Y's t*(u), π(u′), p and d are computed on it.
* **(ii-m)** P(m(y)|y) ≥ 1 − δ > 1/2 at every transcript y of T*_m, for every root question.
* **(A2-m)** Every call of T*_m proves within r₀ rounds.
* **(A2-m-ab)** Every call of T*_m writes a terminal entry within r₀ rounds, and the root proves.
* **(No-lucky-m)** No certified run call is proved while its T*_m counterpart abandons.

All four are own-tree assumptions. Under model (ii) everywhere, T*_m = T*_C.

**Certification and mistakes.**
* *Certified.* A run call is **certified** if it is the root, or the i-th lemma of round j of a certified call whose transcript before round j equals its counterpart's and whose round-j label is m(·) there.
* *Mode mistake.* A **mode mistake** is a round of a certified call, at a transcript equal to its counterpart's, whose label is not m(·).
* Both notions evaluate m only on T*_m.

**Benign ties.**
* *Plausible sets.* M(y) is a set of at most k labels with P(M(y)|y) ≥ 1 − δ > k/(k+1).
* *Selections.* A **selection** C′ writes a label of M(y) at every transcript of its own tree.
* *Assumptions.* (ii-M) and (A2-M) say that (ii-m) and (A2-m) hold for every selection's tree, with common p, d and r₀.
* *The mistake.* An **implausible round**, where G(y) ∉ M(y), replaces the mode mistake. k = 1 is (ii-m).

**The record-path set S(run)**, computed from records alone. Start at the root, with ℓ = 0. At u_ℓ, let j_ℓ be the first round posing a lemma not recorded "proved" (∞ if none).
* *Descend* if j_ℓ ≤ p and ℓ < d: put rounds 1..j_ℓ in S, and let u_{ℓ+1} be that lemma.
* *Otherwise stop:* put rounds 1..min(j_ℓ, r₀, end of u_ℓ) in S.

## 2. The noisy blueprint search

**Lemma S (the first mode mistake lies in S)** [P]. Assume (A2-m), and let G be any deterministic decoder whose run is rejected. Then:
* S contains a mode mistake;
* the first one in S's order sits at position Σ_{ℓ<L} π_ℓ + j_L, with j_L ≤ t*(u_L) its round in the last certified path call: thread Y's quantity;
* |S| ≤ p·d + r₀.

**Lemma B (a bit per implausible round)** [P]. If G_D(y) ∉ M(y) with |M(y)| ≤ k, then KL(P(·|y)‖ξ_D(·|y)) ≥ kl(1 − δ‖k/(k+1)). For k = 1 this is Lemma Z2, 1 − h(δ).

**Theorem AA1 (noisy blueprint search)** [P].
* *Assumptions:* (R), (M), (ii-m) and (A2-m); p, d and r₀ known, or upper bounds in their place.
* *Protocol.* Decode G_D and output an accepted root after the final check. On a rejection, ask once at every round of S, add all the answers, and rerun.
* *Guarantees,* for every adaptive sequence of problems:
  * **(a)** every output is a proof of the reviewed root statement accepted by the hardened pipeline (no assumption is used);
  * **(b)** E[#rejections] ≤ K/(1 − h(δ));
  * **(c)** each rejection costs surely |S| ≤ p·d + r₀;
  * **(d)** E[task queries] ≤ (p·d + r₀)K/(1 − h(δ));
  * **(e)** every problem ends with an output almost surely. There is no term in T, and no dependence on the noisy human's success rate.
* *Under (ii-M) and (A2-M),* (b) and (d) hold with kl(1 − δ‖k/(k+1)) in place of 1 − h(δ). That is 0.22 against 0.53 at k = 2 and δ = 0.1.

**Theorem AA2 (sequential search, with abandonment)** [P].
* *Assumptions:* (R), (M), (ii-m), (A2-m-ab) and (No-lucky-m). No parameter need be known.
* *Protocol.* On a rejection, walk the run's S_cert order: rounds in order, with each non-good lemma's order inserted after the round that posed it. At each round, ask until the answers equal to the run's label lead by 1 (pass) or trail by r (alarm). At the first alarm, discard the detection answers, add one fresh answer there, and rerun.
* *Notation.*
  * k* is the first mode mistake's position. By Theorem Y3 on T*_m, k* ≤ λ_A := Σπ + t* + A, with A the mode tree's abandoned work off the path.
  * π_r = 1 − (λ̄ − 1)ρ^r − ρ, for a bound λ̄ ≥ λ_A.
  * τ̄_r is the largest expected length of one test over all agreement probabilities: 2.15 at r = 2 and 3.41 at r = 3.
* *Guarantees:*
  * **(a)** as in AA1;
  * **(b)** E[#rejections] ≤ K/((1 − h(δ))π_r);
  * **(c)** E[cost | past] ≤ (k* − 1 + r)/(1 − 2δ) + 1 + ρτ̄_r(N − k*), where N is the order's length; a cap at a known B ≥ λ̄ replaces N by B.
* *Numbers.* At δ = 0.1 and r = 3, π_r = 0.87 for λ̄ = 13 and 0.84 for λ̄ = 40.

**Proposition AA3 (ask-all with abandonment and ties)** [P].
* *Assumptions:* (R), (M) and (ii-M). For every selection's tree, Theorem Y3's assumptions hold, with Σπ + t* + A ≤ B for a known B.
* *Protocol.* Ask once at each of the first B positions of the S_cert order.
* *Guarantees:* E[#rejections] ≤ K/kl(1 − δ‖k/(k+1)), at cost B per rejection.

**What it says.**
* *Location.* Thread Z's Z4 asks at all n₀ notebooks of a chain. Here noise-free records cut n₀ to p·d + r₀.
* *Ask-all versus sequential.* Ask-all pays near p·d + r₀ on every rejection, while the sequential test pays ≈ (λ + r)/(1 − 2δ).
* *Own-tree assumptions.* The first mode mistake follows a mode-correct prefix, so it lies on T*_m. Off the tree, fresh answers cannot raise E[Φ].

## 3. Failing lemmas, and what is necessary

**A core lemma that the noisy human sometimes fails to prove.** There are three cases.
1. **Slips** (deviations of probability ≤ δ that the human does not recover from) cost nothing.
   * (A2-m) concerns the mode tree, and the imitator converges to the mode.
   * In the toy the noisy human's own tree fails on 5–9% of problems, while the proved protocols output on all of them.
   * Observed failure rates alone cannot separate this case from the next.
2. **A plausible choice that fails.** With probability ≥ η the human tries a dead end and abandons.
   * *Why model (ii) does not cover it.* A decoder that follows the minority choice makes no implausible mistake.
   * *The fix.* Put both choices in M(y) and use AA3. The cost then adds A over the tree that follows the decoder's choices, at most max over selections C′ of A(C′) [P].
   * *The price.* A factor 2.5 in bits per mistake at k = 2 and δ = 0.1, and no sequential test (AA4(vi)).
3. **A fatal plausible choice** is Proposition Z10 placed in a root's first round. Every decoder protocol pays Ω(T). What is left is sampling (§7).

**Proposition AA4 (what is necessary)** [P unless marked].
* **(i) Re-asks with fresh noise.** By Z12 on a one-round leaf, one ask per transcript can leave the decoder wrong forever. Ask-all re-asks automatically.
* **(ii) Stochastic hypotheses.** A deterministic class is refuted at the first deviation a scan sees. In the toy, it abstains on 99.2–99.8% of problems.
* **(iii) Not stopping at the first differing answer.** If each earlier round differs from the label with probability δ′ and such false stops leave the decoder unchanged, reaching a mistake at position k* takes ≥ (1 − δ′)^−(k*−1) rejections.
* **(iv) A dominant label, or benign ties** (Z10).
* **(v) The factor p·d + r₀** up to a logarithm [S]: Theorem Y2 transfers by simulating the noise (Z11).
* **(vi) The sequential test needs k = 1.** At a correct round with two labels of probability 0.45, the test with r = 3 alarms with probability 0.33.
* **Open:** whether 1/(1 − h(δ)) is needed. It exceeds 1/kl(1 − δ‖δ) by 4.8 at δ = 0.1.

## 4. Research-shaped trees

### 4.1 Lemmas posed late (task 2a)

**Proposition AA5 (Σπ_ℓ is necessary)** [P].
* *The class* is Theorem Y2's: one lemma per call, with the witness at a uniform one of n = p·d + r₀ − 1 positions on a path.
* *Why the records do not help.* For a fixed learner state, the run and its records do not depend on the witness's position, and a task query at a run round reveals the witness only at its position.
* *The bound.* Every search over the run's rounds needs ≥ (n + 1)/2 queries in expectation. With synthetic queries, the bound holds up to a logarithm [S].

**Proposition AA6 (pointers from the call's own later round)** [P].
* **(Diag)** Let u be a certified call whose first open lemma X was posed in round j. If u's rounds 1..j contain a mistake, the human's label at u's transcript after X's open record names a round of u, at or before j, that is a mistake.
  * This is an assumption about transcripts off T*, like thread N's (Budget). It fails for silent humans.
* *The pointer search* asks the human at that transcript (one task query), then queries the round it names, and descends into X if that round is correct.
* *Cost:*
  * ≤ 2d + r₀ per rejection under (A1), (A2-tree) and (Diag);
  * without (Diag), interleaved with S_own: ≤ 2·min{pointer cost, Σπ + t*}, since every hit is worth a bit.

**Proposition AA7 (binary search)** [P].
* *The result.* Given a sound check of whether a certified call's transcript through round j equals its counterpart's, the cost per rejection falls to Σ⌈log₂(π_ℓ + 1)⌉ + ⌈log₂(r + 1)⌉ checks and ≤ L + 1 task queries.
* *But no cheap sound check exists* [S]. Task queries cannot provide it (AA5). A human judgment "is this my prefix?" judges the run's state, which the constraint excludes. A machine has never seen the prefix.

### 4.2 Context crossing calls (task 2b)

**Proposition AA8 (downward hints are free)** [P].
* *The claim.* Let a question be (Γ, φ, η, h), with η any text written in the posing round. All the theorems above, and thread Y's, hold verbatim provided:
  * **(H1)** η is frozen at posing: a copy, not a live reference;
  * **(H2)** caching keys on the full question.
* *Why.* The proofs use a question only through two facts: equal transcripts and an equal posing label give an equal question, and a question determines its subtree. Records concern φ alone. A wrong hint is a label mistake of the posing round, found before the descent.

What breaks:
* **CE-up: upward context** [P].
  * *Setup.* The root poses A, reads a note ν that A returns with its record, and then poses B(ν). The imitator errs inside A in a way that keeps A proved but changes ν.
  * *What happens.* The root's later rounds are correct, B(ν) is not the human's lemma, and the search descends into it and stalls. No record flags A.
  * *Fixes:* (F1) certify fully every child whose text was read, at the cost of its whole subtree; or (F2) return only data that the statement determines uniquely, such as c with IsLeast Q c.
* **Abandonment reasons are fine,** because S_cert certifies every non-good child up to its terminal entry, the reason included.
* **Live references and sibling channels** break (H1) or are CE-up again.
* **Noise.** Free-text hints spread the mode over paraphrases [S].

**The instruction should allow:**
* frozen hints of any length (notes, sibling statements and records, intended use), in a canonical structured form for noisy humans;
* nothing returned upward but records and ABANDON reasons;
* computed data only through statements with unique answers.

### 4.3 Lemma requests mid-call (task 2c)

**Proposition AA9** [P].
* **(a) The cost in terms of the human's own tree.** For a round x of T*_m, let λ(x), its ancestral prefix, be the sum over its ancestor calls of each one's posing round of the next call on the path, plus x's index in its own call. Then:
  * the deterministic search costs exactly λ(x*), at the first mistake x*;
  * ask-all costs |S| ≥ λ(x*);
  * the sequential test costs ≤ (λ(x*) + r)/(1 − 2δ) + 1 + O(ρ);
  * λ ≤ p·d + r₀ always.
* **(b) The reliance rule.** "Pose a lemma no later than the first round that cites it." The pipeline enforces it for formal citations, by elaborating each round's Lean against the statements posed so far. Then π(u′) ≤ ρ*(u′), the human's own round of first reliance, and a rejection costs at most Σ_ℓ ρ*_ℓ + t*(u_L).
  * Without the rule, a human who states lemmas only when writing the final proof pays about (d + 1)r₀.
* **(c) Nothing better while the working order is fixed.** Theorem Y2's class obeys the rule, so AA5 applies [P]. Three restructurings move the same prefix elsewhere [S]:
  * continuation calls;
  * conditional proofs ("proved assuming X"), which are upward context;
  * abandon-and-restart, which moves it into A.

**What helps** is changing T* itself: stating early (restatements are free with disproofs, and charged as A with ABANDON), or planning first.

## 5. Simulation [N]

**The toy** is thread Y's: b = 3, d = 3, leaves of 3–10 rounds (r₀ = 10), slack 10, and 40 insight types with V = 64 values, so K = 240 bits.

**The noisy human.** Each answer is, with probability δ, a uniform symbol drawn afresh.

**The learner** is exact Bayes with δ known, with ties broken against the truth.

**The runs:** 300 problems × 10 seeds. Each cell gives rejections per seed · task queries per rejection, mean (maximum).

| tree (p·d + r₀) | protocol | δ = 0 | δ = 0.05 | δ = 0.1 |
|---|---|---|---|---|
| p = 1 (13) | ask-all (AA1) | 39.9 · 12.9 (13) | 43.9 · 12.9 (13) | 49.0 · 12.9 (13) |
| | sequential, r = 3 (AA2) | 40.0 · 9.6 (16) | 43.6 · 10.4 (21) | 50.9 · 11.0 (100) |
| | sequential, r = 2, all answers added [C] | 40.0 · 7.6 | 45.0 · 8.4 | 49.3 · 8.6 |
| | stop at first differing answer | 40.0 · 6.6 | 60.0 · 5.8 | 93.3 · 5.2 |
| | deterministic learner | 40.0 · 6.6 | abstains 99.2% | abstains 99.6% |
| | chain, Z4 with n₀ = N*_r | 36.2 · 202 | 41.4 · 203 | 47.6 · 202 |
| p = 4 (22) | ask-all | 39.8 · 17.4 (22) | 44.1 · 17.3 (22) | 49.5 · 17.4 (22) |
| | sequential, r = 3 | 39.9 · 13.7 | 45.4 · 15.1 | 51.7 · 16.0 |
| | stop at first differing answer | 39.9 · 10.7 | 78.5 · 8.6 | 145.4 · 6.9 |
| p = 9 (37) | ask-all | 39.8 · 24.9 (36) | 44.4 · 24.9 (36) | 49.3 · 24.7 (36) |
| | sequential, r = 3 | 39.9 · 20.2 | 45.3 · 21.9 | 49.3 · 24.0 |
| | stop at first differing answer | 39.9 · 17.2 | 112.0 · 11.9 | 317.7 · 8.7 |
| p = 1, 20% ABANDON (13) | ask-all on the record path | loops on 18.4% of problems | same | same |
| | ask-all on the first B = 39 positions of S_cert (AA3) | 39.1 · 38.9 | 43.0 · 38.9 | 48.2 · 38.8 |
| | sequential, r = 3 | 39.6 · 13.8 | 43.6 · 15.1 | 49.6 · 16.5 |
| | stop at first differing answer | 39.6 · 10.8 | 81.9 · 9.1 | 182.9 · 7.5 |
| p = 4, 30% ABANDON (22) | ask-all, B = 66 | 42.1 · 66 (1 problem loops) | 46.4 · 66 | 51.3 · 66 |
| | sequential, r = 3 | 39.0 · 24.0 | 42.9 · 26.0 | 51.8 · 29.3 |
| | stop at first differing answer | 39.0 · 21.0 | 154.5 · 14.4 | 464.7 · 9.1 |

**Checks, on every rejection:**
* every S held a mistake and had |S| ≤ p·d + r₀;
* k* ≤ Σπ + t* + A held;
* sequential costs averaged 9.6–29.3, against Theorem AA2(c)'s bound of 9.6–118, computed with the toy's per-round constants, since the toy satisfies model (ii) everywhere;
* rejections stayed far below K/(1 − h(δ)) = 240–452, because one hit teaches log₂ 64 bits here.

**Readings.**
* *Noise is cheap here.* The proved protocols need 1.09–1.17 times their δ = 0 rejections at δ = 0.05, and 1.22–1.33 times at δ = 0.1. At δ = 0.1, ask-all totals 634–860 task queries per seed, against 9,626–11,792 for the chain.
* *The faults are the predicted ones.* Record-path ask-all loops when the core abandons, since Lemma S needs (A2-m). Capped ask-all loops once, where k* = 81 > B. The uncapped test never loops.
* *Cost.* The proved protocols cost about twice the deterministic search (12.9 and 11.0 against 6.6).

## 6. Probability [J]

**The claim.** The noisy blueprint version (AA1 or AA2, a stochastic-hypothesis learner, and thread Y's instruction plus §4.2–4.3) has, on a careful mathematician:
* output failure ≤ 5%;
* task queries ≤ 3(p·d + r₀)K/(1 − h(δ)), abandonment and fallbacks included.

**The conditioning.** Conditional on realizability (a stationary stochastic human in the class, exact Bayes), but not on determinism.

| factor | formalization-style | research |
|---|---|---|
| output failure ≤ 5% (unchanged: kernel, statement protocol) | 0.95 | 0.95 |
| the mode tree fits: isolation, statements first, budgets, (A2-m-ab) | 0.75 | 0.55 |
| abandonment manageable, plausible-choice failures included | 0.85 | 0.70 |
| no costly lucky-proof fallbacks | 0.90 | 0.85 |
| **new:** a dominant label at each mode-tree round, after canonicalizing rounds to decisions, or benign ties with k ≤ 2 | 0.70 | 0.50 |
| **new:** re-asks effectively fresh, so that memory does not lock in a deviation | 0.85 | 0.80 |
| **product** | **≈ 0.32** | **≈ 0.12** |

**About 25% (15–35%) overall,** allowing for correlated factors and for slack: the toy's totals sit 6–14 times below (p·d + r₀)K/(1 − h(δ)).

**Why lower than thread Y's 45%.**
* *Determinism gave the round-level mode for free.* A working day bundles decisions: five 90%-repeatable decisions repeat jointly 59% of the time. Lemma statements are also open-ended. Finer rounds and canonical hints help. The criterion's factor 1/(1 − h(δ)) absorbs how large δ is, but not a missing mode.
* *Memory is new.* Ask-all re-asks the same on-tree transcripts on every rejection of a problem, and a human who repeats a deviation can lock the decoder (Z12).

**Why lower than thread Z's 60%.** That figure is for the weaker "works" criterion, met by VSI-D, which needs no mode. No analog of VSI-D with cost O(p·d + r₀) per demonstration is known.

**To measure first:** the joint repeatability of canonicalized working-day rounds, and the independence of delayed repeats.

## 7. Open

1. **Call-level VSI-D.** When a call fails, the human demonstrates that call, with lemma records from the imitator, and the call-level KL is charged. This might give about (d + 1)r₀K/s² with no mode [C].
2. **Adding the detection answers** (the cheapest variant here) breaks Z4′'s exchange argument [C].
3. **Memory.** A model in which the human repeats an earlier answer with probability μ. Also, evidence for (Diag).

## 8. Proofs

**Lemma S.**
* *Claim.* Fix a certified path call u_ℓ whose run record is not proved, with counterpart u*_ℓ proving at t* ≤ r₀. Let j₀ be its first round that is a mode mistake or poses a lemma recorded non-proved (j₀ = ∞ if none). Then either:
  * (A) round j₀ ≤ t* is a mode mistake and lies in S; or
  * (B) rounds 1..j_ℓ are correct, j_ℓ = π(u*_{ℓ+1}) ≤ p, ℓ < d, and u_{ℓ+1} is certified and not proved.
* *Agreement before j₀,* by induction on rounds i < j₀. Equal transcripts and a correct label give the same entries and lemma questions. The lemmas are proved in the run (since i < j₀) and in T*_m (by (A2-m)). Records agree, so transcripts agree before round i + 1. In particular every transcript at which m is evaluated lies on T*_m.
* *j₀ ≤ t*.* Otherwise transcripts agree through round t*. The run writes u*'s accepted proof against the same proved hypotheses, and no earlier terminal entry, since the labels are u*'s. So u_ℓ is proved, a contradiction (and r ≥ r₀ ≥ t*).
* *Case (A): j₀ is a mistake.* In the descending branch, S holds rounds 1..j_ℓ, and j₀ ≤ j_ℓ by minimality. In the stopping branch, S holds rounds 1..min(j_ℓ, r₀, e_ℓ), and j₀ is at most each of these:
  * j₀ ≤ j_ℓ by minimality;
  * j₀ ≤ t* ≤ r₀;
  * j₀ ≤ e_ℓ, since the run cannot stop before j₀, its labels there being u*'s, which hold no terminal entry before t*.
* *Case (B): j₀ is not a mistake.*
  * j₀ = j_ℓ, since j₀ poses a non-proved lemma and none is posed earlier.
  * Round j_ℓ is correct at an on-tree transcript, so its lemmas are u*'s round-j_ℓ lemmas. Hence j_ℓ ≤ p, u*_ℓ is internal and ℓ < d, and the descending branch applies.
  * u_{ℓ+1} is certified, not proved in the run, and proved in T*_m.
* *Conclusion.* The root is certified and not proved. Case (B) cannot occur at ℓ = d, so case (A) occurs at some ℓ* ≤ d.
  * *Position.* Earlier path calls contribute Σ_{ℓ<ℓ*} j_ℓ = Σπ_ℓ correct rounds, so the first mistake in S sits at position ≤ Σπ_ℓ + t*(u*_ℓ*).
  * *Size.* Each descent adds j_ℓ ≤ p rounds, there are at most d descents, and the stop adds ≤ r₀. ∎

**Lemma B.**
* *The masses.* Let ℓ = G_D(y) ∉ M. For each a ∈ M, ξ(a) ≤ ξ(ℓ). So ξ(M) ≤ k·ξ(ℓ) ≤ k(1 − ξ(M)), which gives ξ(M) ≤ k/(k+1).
* *The coarsening.* Data processing on the partition {M, Mᶜ} gives KL ≥ kl(P(M)‖ξ(M)).
* *Monotonicity.* kl(a‖b) increases in a on [b, 1] and decreases in b on [0, a]. With P(M) ≥ 1 − δ > k/(k+1) ≥ ξ(M), this gives KL ≥ kl(1 − δ‖k/(k+1)). ∎

**Theorem AA1.**
* *(a)* The final check.
* *(b), one rejection.* Fix a rejection, with data D and run (both determined before the round's answers). By Lemma S, S contains a mode mistake y*, on T*_m.
  * Φ depends only on the multiset of data (Lemma Z0), so compute the round's change by adding y*'s answer first. By (M) it is a fresh draw from P(·|y*). Its expected change is −KL(P(·|y*)‖ξ_D(·|y*)) ≤ −(1 − h(δ)), by Lemma Z2 and (ii-m) at y*.
  * Every other answer is a fresh draw at a fixed transcript, independent of the answers added before it, so its conditional expected change is −KL ≤ 0. This uses only (R) and (M), wherever the transcript lies.
  * So E[ΔΦ_round | past] ≤ −(1 − h(δ)).
* *(b), all rejections.* Accepted runs add no data. Lemma Z0, with the charge (1 − h(δ))·1[rejected], gives the bound.
* *(c)* Lemma S; S is computed from records alone.
* *(d)* E[Σ_i cost_i] ≤ (p·d + r₀)·E[#rejections], since each search's cost is surely bounded.
* *(e)* E[#rejections] < ∞.
* *Plausible sets.* Let C_G(y) = G(y) if G(y) ∈ M(y), and a fixed element of M(y) otherwise. C_G is a selection, fixed during the run. Apply Lemma S to T*_{C_G} under (A2-M): S holds a round where G ≠ C_G, which means G(y) ∉ M(y). Lemma B gives the bit. ∎

**Theorem AA2.**
* *Where the first mistake is.* Fix a rejection. The S_cert order (with no alarms) is a fixed function of the run. Theorem Y3's argument evaluates the human only at transcripts of its own tree, so it applies to the deterministic program m on T*_m (under (A2-m-ab) and (No-lucky-m)): thread Y's S_cert hits first at a mode mistake at position k* ≤ λ_A. Every earlier position is a correct round of a certified call, so it lies on T*_m.
* *The tests* are independent across positions, by (M).
  * *At an on-tree correct round* the agreement probability is ≥ 1 − δ, so gambler's ruin gives false-alarm probability ≤ ρ^r. By Wald, the expected length is ≤ 1/(1 − 2δ).
  * *At k** the agreement probability is ≤ δ. So the test passes with probability ≤ ρ and has expected length ≤ r/(1 − 2δ).
  * *Off the tree* the agreement probability q is arbitrary, and the expected length is ≤ τ̄_r = sup_q E_q[exit time of (−r, 1)]. This is finite, and computed numerically.
* *The bit.*
  * P[first alarm at k* | past] ≥ 1 − (k* − 1)ρ^r − ρ ≥ π_r.
  * D is unchanged during detection, since detection answers are discarded. Given the detection answers, the alarm position j is fixed, and the fresh answer there is a new draw. Its expected change is −KL ≤ 0 in general, and ≤ −(1 − h(δ)) if j = k* (Lemma Z2 at an on-tree transcript).
  * So E[ΔΦ | past] ≤ −(1 − h(δ))π_r. Lemma Z0 then gives (b).
* *The cost (c).* Positions before k* are reached with probability ≤ 1 and k* with probability ≤ 1. Later positions are reached only if k* passed, with probability ≤ ρ. Adding the expected lengths and the fresh answer gives (c). (d) is as in AA1. ∎

**Proposition AA3.** Define C_G as in AA1 and apply Theorem Y3 to T*_{C_G}. The first round of the S_cert order where G ≠ C_G, which is an implausible round, sits at position ≤ B. Lemma B and the multiset argument of AA1 finish the proof. ∎

**Proposition AA4.**
* *(i)* Z12 verbatim, on a leaf of one round.
* *(ii)* Elimination removes every hypothesis that disagrees with a deviating answer, including P's deterministic projection.
* *(iii)* The probability of no false stop before k* is ≤ (1 − δ′)^(k*−1). False stops leave the decoder, and hence the next run, unchanged. So the wait for a stop at k* is geometric.
* *(iv)* Z10 in a root's first round: two lemma choices of probability 1/2 each, with the hidden one the only provable one and no recovery.
* *(vi)* Gambler's ruin with up-probability 0.45 and barriers +1 and −3: the pass probability is (1 − x³)/(1 − x⁴) with x = 0.55/0.45, which is 0.67. ∎

**Proposition AA5.**
* *The construction.* In Theorem Y2's construction, a missed witness makes every lower lemma false, and parents do not recover. So every record on the path is "open" wherever the witness is.
* *The run.* The run's labels are the learner's, a fixed function of its data. So the run, its records and the human's answers off the witness position are independent of the position. (Off the witness position, the human's label is a function of the run's transcript, which lacks the witness.)
* *The search.* The search is therefore an adaptive point search for a uniform needle among n positions. Its expected number of probes is ≥ (n + 1)/2. ∎

**Proposition AA6.**
* *Under (Diag).* At a certified path call, if rounds 1..j hold a mistake, the named round is one, a hit. Otherwise the named round is not a mistake, and (Diag)'s contrapositive gives rounds 1..j correct. As in Theorem Y1, rounds before j pose only proved lemmas and transcripts agree, so X is certified.
* *The cost.* Two queries per level, and the last call is scanned (≤ t*).
* *Interleaving.* Any hit is a mistake at a transcript the human answers, worth ≥ 1 bit. Alternating the streams, with cached answers, gives each stream half the queries. ∎

**Proposition AA7.**
* *Monotonicity.* Transcripts are append-only, so Chk is monotone in j.
* *The ends of the interval.* Chk(0) holds for a certified call. Chk(j_ℓ) fails: otherwise the lemma posed in round j_ℓ would carry T*'s record "proved".
* *At the first failing j.* Transcripts agree before round j. If the labels differ, it is a hit. Otherwise a lemma posed in round j has a record different from T*'s, so it is certified and non-proved, and the search descends.
* *Without a non-proved lemma* (the last call), search over [0, r]: Chk fails at t*, as in Theorem Y1. ∎

**Proposition AA8.**
* *Verbatim.* Inspect the proofs. Questions enter only through (1) equal transcripts and labels giving equal questions, which holds whatever the question contains, and (2) the subtree at a question being determined by it, which holds under (H1) and (H2). Lemma Y0(i) uses φ only.
* *CE-up* is described in §4.2. The stall occurs because the root's transcript leaves the human's at a "proved" record, so the root has no mistake, and the lemma the search enters holds no mistake.
* *(F2).* If the datum is unique given the statement, two proved records carry equal data, by consistency. ∎

**Proposition AA9.**
* *(a)* S_own's cost is Σ_{ℓ<L} π_ℓ + j_L (Theorem Y1's proof), with the path calls being x*'s ancestors in T*_m. For the noisy protocols, the bounds follow from Lemma S and Theorem AA2(c).
* *(b)* The pipeline rejects a round whose Lean entries cite an unposed statement, so u′ is posed by the first round that cites it.
* *(c)* Theorem Y2's class poses at round π the lemma carrying the value computed there, so it is posed in the round that relies on it. AA5 then applies. ∎
