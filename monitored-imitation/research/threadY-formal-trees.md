# Thread Y: verified slack imitation on formal blueprint trees

*Working note by Claude (Anthropic), for [`../verified-slack.md`](../verified-slack.md) §9 and [`threadN-trees.md`](threadN-trees.md) §4. Draft; not refereed.*
* *Code:* [`threadY_trees.py`](threadY_trees.py); *output:* [`threadY_trees.out`](threadY_trees.out) (about 30 s).
* *Status tags:* **[P]** proved here, **[S]** sketched, **[C]** conjectured, **[N]** numerical. The simulation checks bookkeeping and bounds on a toy; it cannot test any assumption about humans.
* *Evidence tags:* **[checked]** I read the primary text, or computed the number myself from the public repository; **[page summary]** I fetched the paper's page but read it through a summarizing tool; **[search summary]** from search-result summaries only.

## Answers in brief

1. **Model** (§1).
   * *Calls.* A call's question is a Lean statement (with its definitions), plus hints and a visible fuel. Its first terminal entry (a proof, a disproof, or ABANDON) fixes its *record*: proved, disproved or open.
   * *Proof irrelevance.* Parents see only records. Decided records on the same statement coincide, if the logic is consistent.
   * *Consequence.* A transcript with correct rounds and decided subanswers *is* the human's own (Lemma Y0) [P].
   * *Verifiers.* Node verifiers are the records the scaffold computes anyway, so they cost nothing.
2. **Main theorem** (Theorem Y1) [P].
   * *The assumption* concerns only the human's own isolated tree T*. **(A2-tree):** every call of T* proves its statement within r₀ rounds.
   * *The search* scans a failing call's rounds from the start. At the first round that poses a failing lemma it descends, since a mistake-free prefix certifies that lemma as the human's own.
   * *The result:* at most ⌊K⌋ rejections, each costing surely at most **Σ_ℓ π_ℓ + t_L ≤ p·d + r₀** task queries.
     * π_ℓ is the human's own posing round of the ℓ-th lemma on the search path.
     * t_L ≤ r₀ is the human's terminal round of the last call.
     * p is the latest posing round in T*, and d the depth of T*.
   * *Slack.* The cost does not depend on slack or on the size of the tree. With within-call bounded setback, the last call's term falls to 2r/c.
3. **r + d, yes; 1 + r, no.**
   * *Plan first* (state a call's lemmas in its first round) gives **d + r₀** [P].
   * *Lower bound* [S] (Theorem Y2). Under own-tree assumptions, Ω(p·d + r₀) queries per insight problem are necessary, up to a logarithm.
   * *So T6's 1 + r* rests on thread N's (Budget) at corrupted transcripts, and dropping (Budget) costs exactly Σπ_ℓ.
4. **Abandoned lemmas** (§3) [P].
   * *Abandon only with a Lean disproof:* the theorem holds verbatim with "decided" as the good record. Abandonment then costs only through π_ℓ.
   * *Too-hard abandonment* (explicit ABANDON) adds A, the human's own failure skeleton hanging off the path: abandoned calls, recursively, but never their proved children. This needs *no lucky proofs*: the run never proves a lemma that the human abandons.
   * *Interleaving with a depth-first scan* caps every case at 2·min{that, N*_r}.
   * *Most natural:* disproofs for false-as-stated lemmas, the usual kind in formalization, and ABANDON with A charged in research.
5. **Lower bounds** (§4) [S].
   * *The r₀ term is necessary* when a leaf's first mistake is silent.
   * *The factor d is necessary* under own-tree assumptions, even with zero setback inside calls: a planning mistake does all its damage through a corrupted lemma.
6. **Simulation** [N] (§5). Exact Bayes over 40 insight types, on trees of 200–1,200 human rounds; task queries per rejection.
   * *Plan-first trees, no abandonment:* the own-tree search costs 6.7–7.7 (maximum 13–14 = p·d + r₀), against 120–351 for chain VSI.
   * *Lemmas posed late:* 10.6–17.4.
   * *Abandonment:* 7.2 with disproofs; 10.4–20.9 with too-hard abandonment.
   * *T6* stalls (finds no mistake) on 2–22% of rejections without abandonment, and on 66–84% with it.
7. **Blueprints** (§6).
   * *Carleson* [checked]: 179 lemmas over 13 months, by 28 people. Statements were formalized first, and contributors worked lemma by lemma from local information. Several statements needed new hypotheses or constants, always fixable locally.
   * *Shape* [checked, my computation]. Dependency chains run 11–26 deep, with about 2 lemma uses per node. The depth of the call tree is a design choice, about 2–3.
   * *Restatement* hit about 3–15% of lemmas when formalizing known mathematics. For research I guess 20–50%.
   * *Cost* of the discipline: 1.2–2× the human's time for formalization-style work, 1.5–3× for research [guess].
8. **What it changes** (§7).
   * *Queries:* total task queries ≤ (Σπ_ℓ + t_L + A)·K/b, against chain VSI's 2N*_r·K/b.
   * *Correctness:* it rests on the root statement, the kernel and the final check of the assembled development.
   * *Intermediate statements:* misformalized ones cannot cause wrong outputs [P].
9. **Probability.** About **45%** that "VSI on formal blueprint trees" meets *output failure ≤ 5% and task queries ≤ 3(p·d + r₀)K* on a real careful mathematician, conditional on the idealizations.
   * *By kind of work:* about 55% for formalization-style work, about 35% for new research.
   * *Against the paper:* it sits between the paper's 70% (effort ≤ ⅕ of chained imitation) and its 25% (queries truly O(K)).

## 1. The model

**Questions and records.**
* *A question* is q = (Γ, φ, η, h):
  * Γ is a block of Lean definitions over a pinned environment E₀;
  * φ is a proposition elaborated in E₀ + Γ;
  * η are informal hints;
  * h is the visible fuel.
* *Calls* are as in thread N §1: rounds, labels g = L(y_{j−1}) consisting of entries and fuel-(h−1) questions, isolation, a hidden clock, and append-only transcripts. L = P for the human, and L = G for the imitator, with G fixed during a run.
* *Proof irrelevance.* The scaffold appends each child's **record**, never its answer.
* *Terminal entries.* "PROOF π" is valid if the kernel accepts π : φ, with hypotheses ψ for each earlier record "proved: ψ" and ¬ψ for each earlier record "disproved: ψ". "DISPROOF π" is the same for ¬φ. ABANDON is always terminal.
* *The record.* The call stops at its first terminal entry, which fixes its record: proved, disproved, or open (ABANDON, or no terminal entry within r(h) = r₀(h) + s(h) rounds).
* *Records are sound and complete.* By induction on fuel, a record is sound and complete for "this subtree yields a proof (or a disproof)". It is the node verifier's verdict.
* *Caching.* Identical questions get identical calls, so a lemma used by several parents is cached. This turns DAG-shaped blueprints into trees.
* *Good records.* Good means proved (the plain variant), or decided at internal calls (the disproof variant). The root must prove.
* *Output.* For an accepted root, the scaffold assembles one Lean development and checks it with the hardened pipeline against the *reference* root statement: Comparator, an axiom whitelist, two kernels. A failure of this check is a rejection.

**Runs, mistakes, data.**
* *A mistake* is a round with G(y) ≠ P(y) at the imitator's transcript. A non-good record is not a mistake of the parent.
* *A task query* shows the human one round's transcript y and records P(y).
* *The potential.* Φ = log₂(W/w(P)) and Lemma 1 of note.md apply unchanged.

**The human's own tree.**
* *Definition.* T*(q) is the tree in which P makes every call. By isolation and determinism, the subtree at a call with question q′ is T*(q′).
* *Notation.* t*(u) is the human's terminal round of its call u, and π(u′) the round in which u* poses u′'s question.
* *Certified.* A run call u is **certified** if its question is that of the T* call u* at the same position, posed after a transcript prefix equal to u*'s.

**Assumptions about T* only.**
* **(A1)** P is deterministic, and P ∈ H.
* **(A2-tree)** every call of T*(q_root) writes a valid proof by round t* ≤ r₀(h).
* **(A2-tree-dec)** every call of T* is decided by round r₀(h), and the root proves.
* **(A2-tree-ab)** every call of T* writes a terminal entry by round r₀(h), and the root proves.

These concern one finite tree, the one the human would build, and do not depend on the learner. Thread N's (Budget) also quantifies over questions posed in correct rounds of *corrupted* transcripts.

**Lemma Y0 (unique records; agreement)** [P]. Assume that E₀ plus the whitelisted axioms is consistent.
* (i) Two decided records on the same question coincide.
* (ii) Let u be certified. Suppose its rounds 1…j have correct labels, and each child posed there has the same record as the corresponding child of u*. Then u's transcript after round j equals u*'s. This holds in particular when all those children are decided in both trees.

*Proof.*
* (i) "proved" and "disproved" on the same φ would give a proof of ⊥.
* (ii) Induction. Equal transcripts and a correct label give G(y) = P(y) = P(y*): the same entries and the same questions. The records agree by hypothesis, or by (i). ∎

## 2. The main theorem

**Search S_own** (at a failing call u):
* query u's rounds 1, 2, … in order, and stop at the first mistake;
* after querying round j, if j posed a child whose record is not good, run S_own on the first such child.

**Theorem Y1 (own-tree search)** [P]. Assume the plain scaffold, (A1), and (A2-tree) for every root question. For every sequence of problems, chosen adaptively:
* **(a) Correctness.** Every output is a kernel-checked proof of the reference root statement. No property of P or G is used.
* **(b) Counts.** Every search ends with a hit, so there are at most ⌊K⌋ rejections (K/b with asks at unconfident rounds).
* **(c) Cost per rejection, surely.** Let u₀, …, u_L be the search path. The cost is
  Σ_{ℓ<L} π_ℓ + j_L ≤ Σ_{ℓ<L} π_ℓ + t*(u_L) ≤ p·d + r₀.
  * π_ℓ = π(u_{ℓ+1}), and j_L is the round of the hit.
  * p = max π and d = depth, both over T*.
  * There are no verifier calls beyond the records.
* **(d) Slack.** (c) does not depend on s. Suppose u_L poses no non-good lemma, and that the human's setback inside u_L is at most D at label mistakes. Setback is measured in τ(y), the human's rounds to its proof when every lemma it poses is proved.
  * Then u_L has at least c = ⌈(s+1)/(D+1)⌉ mistakes.
  * Interleaving S and U (uniform rounds) at calls with no non-good child gives E[cost] ≤ Σπ_ℓ + min{2t*(u_L), 2r/c}.
* **(e) Totals.** E[task queries] ≤ ⌊K/b⌋·(p·d + r₀) + asks.

*Proof.* **Claim:** every call u on the path is certified and fails, while u* proves.
* *Base.* At the root: the same question, a rejection, and (A2-tree).
* *Step.* Let j₀ be u's first round that is a label mistake or that poses a non-good child.
  * *j₀ ≤ t*(u).* Otherwise rounds 1…t* are correct and their children are proved, as are u*'s, by (A2-tree). Then Lemma Y0 makes the transcripts equal through t*, so u holds u*'s first terminal entry, a valid proof, and does not fail.
  * *Before j₀,* the search finds neither mistakes nor non-good children.
  * *At j₀,* either it hits (cost j₀ ≤ t* in this call), or round j₀ is correct and poses a non-good child.
  * *In the second case,* the transcripts agree before j₀ (Lemma Y0), and round j₀'s label is P's. So its questions are u*'s round-j₀ questions, and the first non-good child k is certified with π(k) = j₀. It fails, while k* proves.
* *Termination.* Fuel decreases, and at a leaf j₀ must be a mistake.
* *Cost.* The cost is Σπ_ℓ + j_L, with j_L ≤ t*(u_L) ≤ r₀, π_ℓ ≤ p and L ≤ d.
* *(b) and (e):* Lemma 1 of note.md, since the decoder is fixed during the run and its search, every answer added is P's, and Φ never increases.
* *(a):* the final check.
* *(d):* Lemma S inside u_L.
  * Certification gives τ(y₀) = t*(u_L) ≤ r₀.
  * With all subanswers good, a correct round lowers τ by exactly 1 (T1′), and a mistake raises it by at most D.
  * A failed call keeps τ ≥ 1, so 1 ≤ t* − (r − M) + DM, and M ≥ (s+1)/(D+1).
  * The scan reaches round t* by query 2t* − 1, and each uniform draw hits with probability at least M/r.
  * The records tell the search which calls have no non-good child, and a certified failing call with none contains the hit. ∎

**Remarks.**
1. **Ancestry.** This is note.md's Corollary 12 and the paper's lemma "the first mistake comes early", applied call by call. *Certification is the scan itself*: a lemma's question is trusted only once the prefix that posed it has been shown mistake-free.
2. **T6, redone.** Under (Budget), T6 with a scan costs at most 1 + t* ≤ 1 + r₀ [P, same proof]. Under own-tree assumptions alone, T6 can stall: the call whose children all pass may be uncertified, with no mistake in it (§5).
3. **Time.** A query is one round of human work. So a rejection costs the human's time on the path's planning prefixes plus the last call's prefix. Finer rounds stop the scan earlier and do not change K.

## 3. Abandoned lemmas

**Corollary Y3a (abandon only with a disproof)** [P]. In the disproof variant (good = decided), under (A2-tree-dec), Theorem Y1 holds verbatim.
* *The search never enters a disproved lemma.*
* *Where abandonment shows.* Only in π_ℓ: the rounds a parent spends before posing the lemma that works, including those that posed lemmas later disproved.

*Proof.* Read "decided" for "proved" in the claim. The root cannot be "disproved", since T* proves it, and decided children agree with the human's by Lemma Y0(i). ∎

**Search S_cert** (explicit ABANDON allowed). search(u): for j = 1, 2, …
* query round j, and return HIT if it is a mistake;
* for each non-good child k of round j, return HIT if search(k) does;
* return CERT at u's terminal round in the run, or when its rounds run out.

A *lucky proof* is a certified call whose run record is "proved" while the human abandons it. **(No-lucky)** says there is none.

**Theorem Y3 (too-hard abandonment)** [P]. Under (A1), (A2-tree-ab) and (No-lucky), every search of a rejected run ends with a hit (so at most ⌊K⌋ rejections), at cost at most

  **Σ_{ℓ<L} π_ℓ + t*(u_L) + Σ_{k∈Ab} W(k).**

* Ab is the set of calls that the human abandons in T*, posed at path calls before the path lemma.
* W(k) = t*(k) + Σ W(k′) over k*'s abandoned children within its rounds. This is the human's *failure skeleton*: proved children are never scanned.

*Proof.*
* *Certification.* If search(k) returns CERT at a certified k, then k's record equals k*'s. Induction on fuel:
  * the scanned rounds have no mistake, and non-good children returned CERT, so their records agree by induction;
  * proved children agree by (No-lucky) and (A2-tree-ab), and disproved ones by Lemma Y0(i);
  * so the transcripts agree through the run's terminal round. A timeout at r ≥ r₀ would contradict (A2-tree-ab).
* *Termination.* A certified call whose record differs from the human's therefore returns HIT. The root is one.
* *Cost.* The cost along the path is as in Theorem Y1. Each CERT on the way is an abandoned certified call posed before the path lemma, and costs at most W(k). ∎

**Proposition Y3c (lucky proofs)** [P]. Without (No-lucky), S_cert may end with CERT at the root. Alternate its queries with a depth-first scan of the run, caching and stopping at the first hit. Under (A1) and (A2-tree-ab) alone, a rejection costs at most

  2·min{C_cert, f + 1} ≤ 2·min{C_cert, N*_r},

where f < N*_r is the first mistake in depth-first order, and N*_r the number of rounds in T*.

*Proof.* The first disagreement between the run's depth-first sequence and T*'s is a label mistake: a child's record comes after its rounds, which contain an earlier disagreement. If the first N*_r positions agreed, the run would reproduce T*'s root proof. The alternation gives each stream half the queries. ∎

So chain VSI on the linearized tree (2N*_r) is a floor that the tree search never falls below by more than a factor 2.

**Which version is natural.**
* *Disproofs for false-as-stated lemmas.* These are the bulk of restatements in formalization (§6): edge cases, missing hypotheses, constants. They usually have short counterexamples, and the cost model is then clean, with no A and no lucky proofs.
* *ABANDON, with A charged, for too-hard lemmas,* which dominate research. A is the human's own abandoned work directly off the path, not the whole tree: small when giving up is quick, large when a failed approach grew a deep subtree.
* *Lucky proofs* are then a real risk, and the interleaving caps them at twice chain VSI.
* *A machine-checkable "located reason"* for a too-hard abandonment exists only rarely, for example a reduction to a listed open problem.

## 4. Lower bounds

**Theorem Y2 (planning prefixes are necessary)** [S; by reduction to the paper's Theorems 5.1–5.2, with positions redefined, as thread N did for T4].
* *The class.* For every d, r₀ ≥ 2, 1 ≤ p < r₀ and q, there is a class of humans with:
  * (A1) and (A2-tree);
  * proof irrelevance, and free sound and complete node verdicts;
  * one lemma per call, posed within the first p rounds, and depth d.
* *The bound.* On it, every task-only protocol with fewer than about q/16 verifications per insight problem needs Ω((p·d + r₀)K/log₂((p·d + r₀)q/ε)) task queries.
* *With zero setback.* Within-call setback D = 0 holds at every internal call, and Ω(p·d·K/log) remains.

*Construction.*
* *The witness.* With probability η, problem x hides a witness k ∈ [q] at a uniformly random one of the n = p·d + r₀ − 1 positions: the first p rounds of the d internal calls on a path, and the leaf's first r₀ − 1 rounds.
* *The statements.* The root states ∃y R_x(y), with k the only witness. Each later round carries its value into the lemma it poses, "R_x(value)", and the leaf proves R_x(k) by evaluation.
* *A missed witness* makes every lower lemma false. Off T*, the human tries false lemmas and abandons them without disproof, and parents do not recover. So the whole path fails whatever the position, and the verdicts reveal nothing.
* *Point queries.* A query reveals k only at its position, on a transcript lacking k. So Theorem 5.2's proof applies with n positions.
* *Setback.* Under the all-proved oracle a planning mistake costs its own call nothing, so D = 0, and (Budget) fails exactly there.

**What is necessary.**
* *The r₀ term* is necessary for silent leaves: with d = 0 this is the paper's chain bound. With within-call bounded setback it falls to about (D+1)r/(s+1) (Y1(d)), which Theorem 5.3 shows necessary.
* *The factor d* is necessary under own-tree assumptions. Only assumptions about corrupted transcripts remove it: (Budget) or (B-sub), as in T6. A small p only brings p·d down to d, which is tight.
* So Theorem Y1 is optimal up to the logarithm, and (Budget) is worth exactly Σπ_ℓ per rejection.

## 5. Simulation [N]

**The toy.**
* *Calls.* Internal calls pose b = 3 lemmas over p planning rounds, then assemble. Leaves take 3–10 rounds (r₀ = 10), with slack s = 10.
* *Insights.* Poisson(1) per problem, at random rounds of T*, of 40 types. Exact Bayes over the product class gives at most 40 rejections.
* *Corruption.* A missed insight corrupts every lemma posed at or after it. Corrupted lemmas fail and contain no mistakes, and parents do not recover.
* *Abandonment.* With probability q_ab a planned lemma is first posed as a false trial, which the human abandons or disproves; the corrected lemma follows one round later.
* *Runs.* 300 problems × 5 seeds, with a separate trajectory per method. The table gives task queries per rejection, mean (maximum).

| setting | N*_r | chain VSI | T6 (stall %) | own-tree | share certifying abandoned work | chain / own |
|---|---|---|---|---|---|---|
| plan-first (p=1), d=3 | 203 | 120 (281) | 32 (2%) | **6.7 (13)** | 0 | 18× |
| plan-first, d=4 | 605 | 351 (851) | 39 (3%) | **7.7 (14)** | 0 | 46× |
| p=4, d=3 | 233 | 143 (340) | 72 (11%) | **10.6 (21)** | 0 | 14× |
| p=9, d=3 | 282 | 171 (411) | 132 (22%) | **17.4 (33)** | 0 | 10× |
| p=1, d=3, 20% ABANDON | 344 | 200 (629) | 429 (66%) | **10.4 (35)** | 34% | 19× |
| p=1, d=3, 20% disproofs | 344 | 220 (715) | 28 (2%) | **7.2 (14)** | 0 | 31× |
| p=4, d=3, 30% ABANDON | 492 | 314 (1316) | 607 (84%) | **20.9 (60)** | 47% | 15× |
| p=4, d=3, 30% disproofs | 529 | 307 (1105) | 47 (4%) | **12.1 (24)** | 0 | 25× |
| p=1, d=4, 20% ABANDON | 1,224 | 782 (2416) | 940 (77%) | **13.4 (42)** | 38% | 58× |

* **Bounds checked on every rejection.**
  * chain VSI: cost ≤ 2N*_r, with the first mistake before N*_r;
  * own-tree: cost − A ≤ Σπ_ℓ + t_L;
  * every path lemma is the human's own lemma, posed after a mistake-free prefix;
  * own-tree: cost ≤ p_max·d + t_max when A = 0.

  The maxima 13, 14, 21 and 33 are within p·d + r₀ = 13, 14, 22 and 37.
* **T6 stalls** whenever a planning round above the last level is the mistake. With too-hard abandonment it also walks into the human's own abandoned lemmas. Its cost includes the fallback to the chain scan.
* **Lucky proofs.** Abandoned lemmas are true, and a deviating run proves them, at rate 50% or 100%. The own-tree search alone then ends without a hit on 29% and 49% of rejections. Interleaved with a depth-first scan it costs 112 and 227, against chain VSI's 220 and 314, and 2(f+1) held throughout.
* **Adversarial placement** (one insight at the last planning round of each level in turn; p = 4, d = 3).

  | insight at depth | own-tree | T6 | chain VSI |
  |---|---|---|---|
  | 0 | 4 | 423 (stalled) | 212 |
  | 1 | 8 | 681 (stalled) | 280 |
  | 2 | 12 | 1 | 295 |
  | 3 | 19 | 54 | 316 |

  This is Theorem Y2's Σπ_ℓ in miniature.

## 6. The case for humans

### 6.1 Evidence

| source | finding | tag |
|---|---|---|
| **Carleson** (arXiv 2609.31334) | June 2024 to July 2025; 28 contributors; 35.6k lines. "The proof in the blueprint was divided into 179 lemmas"; one author "formalized the statements of most lemmas" first. The blueprint aimed that "the statement and proof of any lemma … along with all the definitions and lemmas that were explicitly referenced by that lemma … alone would provide enough information"; "the precise way that this lemma fits into the rest of the proof was usually not specified". Most tasks were "formalizing a single lemma". Lemmas 6.2.3, 6.3.3/4, 11.1.6 and 8.0.1 needed statement changes, some by experts. Fixes were local: "the stronger assumptions were always satisfied at the places where the lemmas were used". Most flaws entered while writing the detailed blueprint. | checked |
| Carleson repository history (my computation) | From June 2024 to July 2025, 79 lemma statements were edited after their Lean statement existed: an upper bound, which includes cosmetic edits. At least 6 of the 10 largest edits change hypotheses or constants. | checked |
| **PFR** | Finished 5 Dec 2023, about three weeks after the blueprint started; about 25 contributors. Tao: contributors could "work on one localized subtask without necessarily understanding the global proof"; he wrote about 5% of the lines; only minor typos were found in the paper. | search summary |
| PFR repository history (my computation) | 87 statements at completion; 37 edited after their Lean statement existed. The largest edits are splits, generalizations and notation. | checked |
| **Equational Theories** (arXiv 2512.07087) | September 2024 to April 2025; more than 50 contributors, with one claimant per task. New research: "we could not prepare the blueprint of the project in advance". The hardest implication "took several months", and one stayed open. | page summary |
| **Sphere packing**, dimension 8 (arXiv 2604.23468) | About 20k human lines along a blueprint; then Gauss produced a sorry-free proof in five days. How closely it followed the blueprint "is still being investigated". | page summary |
| **FLT** | Blueprint-driven, 2024–2029. A literature gap in crystalline cohomology reportedly forced a change of route. | search summary |
| **53 blueprints** (DAPS, arXiv 2610.41536) | 3,805 nodes and 4,651 edges; median 35 nodes per project, mean 72. | checked |

**Shapes** [checked, my computation from `\uses` and `\ref` in the blueprint sources, so approximate].

| project | lemma-like nodes | longest dependency chain | lemma uses per internal node, mean (maximum) | leaves |
|---|---|---|---|---|
| Carleson | 179 | 26 | 2.1 (13) | 32% |
| PFR, with later extensions | 189 | 22 (17 from the main result) | 2.5 (11) | 15% |
| sphere packing | 105 | 16 | 2.3 (11) | 36% |
| FLT, in progress | 211 | 11 | 1.6 (10) | 45% |
| Brownian motion | 507 | 17 | 1.9 (14) | 38% |
| Equational Theories | 128 | 5 | 1.4 (5) | 62% |

### 6.2 Typical d, r and abandonment

* **d is a design choice.** Dependency chains are 11–26 deep, but a call need not pose its dependencies: it can pose B and "B → A" side by side.
  * *This is how the contributors worked:* they proved each lemma assuming the statements of the lemmas it cites.
  * *The natural call tree* follows the document (theorem, sections, lemmas): d ≈ 2–3, with b ≈ 5–20 per call.
  * *The trade-off.* Flatter trees mean longer planning, and so larger π.
* **r in time** (my estimates).
  * *Leaf lemmas* took days to weeks of human Lean work in 2023–25: about 1–3 weeks per lemma at Carleson, a day or two at PFR. With 2026 tools, hours to days.
  * *Planning a call* (5–20 statements with sketches) takes days to weeks.
  * *With a round of one working day:* r₀ ≈ 3–15, p ≈ 2–10 and d ≈ 2–3, so **p·d + r₀ ≈ 7–45 days per rejection**. Against 2N*_r ≈ 1–30 person-years (about 230 working days each), that is about 5–100×.
* **Abandonment.**
  * *Formalizing known mathematics:* about **3–15%** of lemmas were restated substantively. The low end is the Carleson paper's named cases; the high end my reading of the diffs. They were mostly false in edge cases, with local fixes, which suits disproofs. Polished proofs (PFR) had fewer.
  * *New research:* **20–50%** of posed lemmas abandoned, mostly as too hard [guess; no data].

### 6.3 How plausible is (A2-tree-ab) with isolation?

Strict (A2-tree) fails on any large project, because some lemmas get restated. The relevant forms are (A2-tree-dec) and (A2-tree-ab).

* **(a) Formalizing known mathematics: about 75%.**
  * *Isolation and statements-first* are the blueprint workflow itself (Carleson, PFR).
  * *Restatements* are abandonments in T*, cheap with disproofs.
  * *Expert fixes* ("harmonic analysis experts with a deep understanding of the overall proof strategy") must travel in hints or happen at the parent.
  * *Heavy-tailed lemmas* exceed any fixed r₀. A timeout is an abandonment, charged in A.
* **(b) New research: about 55%.**
  * *Mathematicians do decompose,* but the right statement is often what research finds. So expect late lemmas (p ≈ r₀) and frequent abandonment.
  * *Isolation hides context,* which hints can partly carry.
  * *Degradation is graceful:* d·r₀, then the chain floor. The gain shrinks, but correctness never moves.

### 6.4 The instruction (part of every question, so it holds in T*)

1. Work only from the call's statement, definitions and hints.
2. Before relying on a lemma, state it in Lean and pose it as a subcall. Never read sub-proofs; use only the records proved, disproved and not proved.
3. Plan first: state the lemmas you expect to need in the first round.
4. Flatten: pose dependencies yourself, as hypotheses, unless a lemma is a genuine sub-project.
5. If a lemma is false as stated, disprove it and restate. Otherwise write ABANDON with a reason. Never run past budget silently.
6. End each call with a Lean proof of its statement from the proved lemmas.
7. The root statement goes through the paper's statement protocol. Intermediate statements need no review.

### 6.5 What it costs

* *Formal statements for every lemma:* a modest share of Carleson's effort; days per hundred statements with 2026 AI drafting, plus checking.
* *A Lean proof at every node:* thread T's ι per node, about 1.1–1.5× in covered fields. A formalizer inside V at the leaves lowers it, but turns false rejections into abandonments and makes lucky proofs plausible.
* *Overall multiplier on human time* (guess): **1.2–2× for formalization-style work, 1.5–3× for research.** It inflates N*_r and each query, not the K bound.

## 7. What it changes

**Headline.** Total task queries ≤ (Σπ_ℓ + t_L + A)·K/b ≤ (p·d + r₀ + A)·K/b, against chain VSI's 2N*_r·K/b on the same tree, and never worse than twice that (Y3c).
* *Plan first, with disproofs:* (d + r₀)·K/b. As far as I know, this is the first bound in the series that is independent of the human's total work and whose assumptions concern only the human's own work.

**Correctness** rests on the root statement, the kernel, and the final check of the assembled development. Node records only route the search: a wrong record could misdirect it, but cannot produce an output.

**Misformalized intermediate lemmas cannot cause wrong outputs** [P, under the conditions below]. A misformalized lemma ψ′ is one of three things:
* false, and then unprovable, which costs only an abandonment or a rejection;
* true but useless, which costs only rounds;
* true and usable, in which case the assembled proof still proves the reference root statement.

The conditions:
* records carry elaborated statements;
* the final check compares the root theorem's type with the reference statement, elaborated before any node's code;
* node definitions, instances and notation cannot alter it;
* the axiom whitelist excludes `sorry`, new axioms and unreviewed `native_decide`/`implemented_by`.

Without the whole-development check, the same text elaborated differently in a child and in its parent could be exploited. So that check is mandatory.

**Probability** [judgment]. The claim: on a careful mathematician following §6.4, conditional on determinism and realizability, output failure is at most 5% and total task queries are at most 3(p·d + r₀)K, abandonment and fallbacks included.

| factor | formalization-style | new research |
|---|---|---|
| output failure ≤ 5% (statement protocol, hardened checking) | 0.95 | 0.95 |
| T* fits: isolation, statements first, budgets, root proves | 0.75 | 0.55 |
| abandonment manageable (disproofs, or A ≤ about 2 attempts per path call) | 0.85 | 0.70 |
| no costly lucky-proof fallbacks | 0.90 | 0.85 |
| **product** | **≈ 55%** | **≈ 31%, say 35%** |

Overall, in the formal domain, weighting the two kinds of work equally: **about 45%**.
* *Against the paper's 70%.* This claim is stronger than the paper's 70%, and the tree scaffold does not lower that 70%, by Y3c, except through the discipline's cost.
* *Against the paper's 25%.* It replaces the paper's 25% for "truly O(K)" with about 45% for O((p·d + r₀)K).

**Main risks.**
1. Research is not tree-shaped (p → r₀, context crosses calls).
2. Too-hard abandonment and lucky proofs, especially with a formalizer inside V.
3. Heavy-tailed calls; a root timeout means abstention.
4. The discipline's 1.2–3× multiplier on human time.
5. Root statement fidelity and the checker, as in the paper.

## 8. Open

1. Remove (No-lucky) without the factor N*_r: find which proved child of a path call holds the lucky proof.
2. Abandoned lemmas whose partial results the parent reuses, which breaks the uniqueness of records.
3. Measure p, abandonment and call durations on a live blueprint project (task logs, git history), and run a research project under §6.4.
4. An exact-Bayes experiment with a class richer than the product class.
