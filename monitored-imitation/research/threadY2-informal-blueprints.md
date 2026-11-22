# Thread Y2: informal blueprints with fallible node verifiers

*Working note by Claude (Anthropic), extending [`threadY-formal-trees.md`](threadY-formal-trees.md) (the paper's Section 5) to informal research, with Section 9's VSI-R as the root verifier. Draft; not refereed.*
* *Code:* [`threadY2_informal.py`](threadY2_informal.py); *output:* [`threadY2_informal.out`](threadY2_informal.out) (about 55 s, fixed seeds; run with `python3 -B threadY2_informal.py`).
* *Status tags:* **[P]** proved here, **[S]** sketched, **[C]** conjectured, **[N]** numerical. The simulation checks bookkeeping and bounds on a toy; it tests no assumption about humans or verifiers.
* *Scope:* cost only. Correctness stays with the root verifier V, as in Section 9; I note where the cost design touches it.

## Answers in brief

1. **Model** (§1).
   * *Setting.* Thread Y's isolated calls, with informal statements. A fallible node verifier N judges every proof a call submits. The parent sees only the lemma's statement and its record (proved or open), so proof irrelevance is now a scaffold rule.
   * *The root verifier.* V judges the assembled cone; when it rejects, it names the claim it objects to.
   * *Determinism is required.* Verdicts must be a fixed function of the canonical claim: cached, with all randomness seeded by the claim's hash. Only then is the human's own tree T*_N, built with the same N, a single tree. Randomized verdicts break agreement at the verdict step (CE1).
2. **What breaks** (§2) [P, N].
   * CE1: randomized verdicts reject a run with no mistake.
   * CE2: an unlocated V plus a false pass in the run leaves every record "proved", and the descent stalls.
   * CE3: the human's own slip, passed by N, sends the descent into the human's own work.
   * CE4: trusted disproofs.
   * CE5: false fails make the human abandon true lemmas, which breeds lucky proofs.
3. **Records in place of proofs** (Theorem Y2-1) [P].
   * *Assumptions:* deterministic N and V, a V that judges claims one by one, (A2-tree-N) (every call of T*_N is recorded proved within r₀ rounds) and (A3-tree) (V passes T*_N's claims).
   * *Result:* a located search costs at most **Σπ_ℓ + t*(u_L) ≤ p·d + r₀** per rejection. N's error rates on the run's claims do not enter.
   * *The false pass of task 3a* (a wrong sub-proof recorded "proved" on a lemma the human proved) gives the human's record. It costs nothing, and it harms correctness only if V also misses it.
4. **Best result: repair first** (Theorem Y2-2) [P].
   * *The rule.* When V names a claim and a judge upholds the objection, overwrite N's cached verdict on that claim with "fail" and rerun, with no task query. Search only runs whose root is open.
   * *Cost:* at most **(p·d + r₀ + D·φ_max)·K/b task queries in total**, with neither (A3-tree) nor claim-by-claim judging. The only node-verifier errors that cost task queries are false fails on the human's own claims in the last call of the search path, D each. The others cost reruns and rulings.
   * *Where the assumption comes from.* Lemma C derives it from the human's tree under an exact verifier plus bounded revision after a false fail.
   * *Price:* before a search, V can see up to k_sub invalid claims from each deviated call of a run, not one per search. A middle rule bounds this.
5. **Safety net** (Proposition Y2-3) [P]. Interleaving with a depth-first scan costs at most **2·min{tree cost, N*_r}**. It needs only determinism and that the human's own root proves.
6. **Necessity** [S].
   * *Location* (Proposition Y2-5): without it, about f_p^{k_sub}·N*_r/log task queries per rejection.
   * *Caching* (Proposition Y2-4): without it, uninformative rejections grow with the number of problems.
7. **Simulation** [N]. Thread Y's toy, 40 calls per tree, human slip rate 0.1, node error rates of 0, 5, 15 and 30%.
   * *Located search:* **6.3–6.8 task queries per hit at every rate, against 115–120 for the chain scan.**
   * *Repair first:* totals stay at the error-free level, 254–273 per seed.
   * *Unlocated V:* rises to 93 per hit and abstains on up to 72% of problems.
   * *Fresh verdicts:* up to 995 uninformative rejections per seed.
8. **Probability** (§6): **about 15%** (10–25%), conditional on the idealizations, for output failure ≤ 5% and task queries ≤ 3(p·d + r₀)K in informal theory. Thread Y gives 35% for formal research; the paper gives 50% for VSI-R under its weaker "works".

## 1. Model

**Calls.**
* *Questions.* A question is q = (Γ, φ, η, h): informal definitions, statement, hints and fuel. Rounds, isolation, the hidden clock and append-only transcripts are as in thread Y.
* *Submissions.* A label may contain PROOF(text) or ABANDON. On PROOF, the scaffold forms the **claim** c = (q, H, text), with H the statements of the lemmas recorded proved so far, and appends **N(c)**.
  * On "pass", the call stops: its record is **proved**, and c is its final claim.
  * ABANDON, or no pass within r = r₀ + s rounds, gives the record **open**.
* *Proof irrelevance* is a scaffold rule: a parent sees statements and records, never texts.

**Verifiers.**
* *Validity.* A claim is *valid* if its text proves φ from H, as an ideal referee would judge. N makes a **false pass** on an invalid claim it passes (rate f_p) and a **false fail** on a valid claim it fails (rate f_f).
* *The root verifier V.* For a run whose root is proved, the scaffold assembles the **cone**: the root's final claim and, recursively, the final claims of the lemmas in each H. V accepts the cone, or rejects it and names a claim of it.
  * The output is the cone. If all its claims are valid, the root statement holds (induction on fuel).
  * A run is *rejected* if its root is open or V names a claim.
* **(N-det)** N(c) is a fixed function of the canonical claim c.
  * *Realization.* Cache verdicts per claim, seed every random choice (pool member, prompts, sampling) by a hash of c, and pin the models.
  * *Why that is a table.* If a first verdict depends only on the claim, then by deferred decisions this is a table fixed in advance. For probabilities, its entries may be taken independent across claims, which is an idealization.
  * *Repairs* (§3.3) overwrite entries between runs; the table is fixed during a run and its search.
  * *(V-det)* is the same for V.

**The human's own tree T*_N(q).**
* *Definition.* P makes every call and N gives every verdict. Under (N-det), and by isolation, it is one tree; the subtree at a lemma q′ is T*_N(q′).
* *Its records may be wrong.* It contains the human's revisions after objections, its slips that N passed, and the rounds that false fails cost it.
* *Notation.* t*(u), π(u′), p, d and *certified* are as in thread Y. φ_N(u) counts N's false fails on u's claims.

**Search S_own** (thread Y): at a call, query rounds 1, 2, … and stop at the first mistake. After round j, if j posed a lemma whose record is not "proved", run S_own on the first such lemma.

**Assumptions.**
* (A1): P is deterministic, and P ∈ H.
* (N-det) and (V-det).
* **(A2-tree-N)**: every call of T*_N(q_root) is recorded proved by round t* ≤ r₀.
* **(A3-tree)**: V judges each claim of the cone by itself and passes every final claim of T*_N. This is the paper's (A3′), node by node.

## 2. What breaks

Frame: a root R poses leaf lemmas A (round 1) and B (round 2), and submits in round 3. The only mistake is in B's round 2, unless stated. The script reproduces CE1–CE3.

* **CE1: randomized verdicts** [N].
  * *Setup.* There is no mistake, and A's budget is tight.
  * *What happens.* A fresh draw fails the human's own valid claim in A, so A is open, though it was proved in the human's nominal tree. R leaves the human's transcript without a mistake.
  * *The search.* S_own descends into A and finds nothing, and the full depth-first scan finds nothing: an uninformative rejection.
  * *What fails.* Agreement (equal transcript and correct label give equal next transcript) fails at the verdict.
* **CE2: false pass in the run, unlocated V** [N].
  * *What happens.* B deviates and N passes its invalid proof. B's record is the human's, so R stays on track and proves, and V rejects the cone.
  * *The search.* S_own from R finds no mistake and no open lemma, and stalls. Nothing in the run says which of the b^d subtrees is wrong.
  * *With location.* If V names B, S_loc hits in 4 queries.
* **CE3: the human's own slip, passed by N** [N]. This is the failure of (A3-tree).
  * *What happens.* N passes the human's invalid proof in A, so every run that reproduces A reproduces it. V names A.
  * *The search.* S_loc certifies A and ends without a hit, though B holds a mistake. Without location, the human's own tree is rejected on every rerun. A kernel never passes a slip, so thread Y has no analog.
* **CE4: trusted disproofs** [P].
  * *What thread Y used.* Its disproof variant counts "disproved" as good, because decided records on one statement coincide (Lemma Y0(i)).
  * *What fails.* A fallible N can pass the human's proof of φ and the run's disproof. Then R leaves the human's transcript without a mistake, and the search does not descend, since the record is good. R's later rounds have correct labels on a foreign transcript, and the search can stall.
  * *Fix:* only "proved" is good, and the human's own disproofs count as abandonments.
* **CE5: false fails, then abandonment, then lucky proofs** [S].
  * *What happens.* If the human abandons after k_sub failed submissions, it abandons true lemmas with probability about f_f^{k_sub} per call, and (A2-tree-N) fails.
  * *In a run.* A run that deviates inside such a lemma may get a different *valid* proof passed. V does not flag it, and S_own can end without a hit.
  * *What is harmless.* An *invalid* lucky proof that V catches is harmless: V names it, and the scan finds its mistake.

## 3. Results

### 3.1 Agreement and descent

**Lemma A (agreement)** [P]. Assume (N-det) and (A2-tree-N). Let u be a certified run call with human counterpart u*. Suppose u's rounds 1…j have correct labels and every lemma posed in them is recorded proved in the run. Then u's transcript after round j equals u*'s; in particular u stops at a round ≤ j exactly when u* does, with the same final claim.

*Proof.* Induction on j. Equal transcripts and a correct label give the same entries, lemma questions and terminal entry. The lemmas' records are "proved" in both trees, by hypothesis and by (A2-tree-N). So H is the same, the claim is the same, and its verdict is the same by (N-det). ∎

This is the only place where records enter, and it needs them to be *the human's*, not *true*. In thread Y, the kernel's soundness and completeness supplied two things: determinism of the check, now supplied by (N-det), and the link from the final check to the root's record, now supplied by location.

**Claim 1 (descent)** [P]. Assume (A1), (N-det) and (A2-tree-N). If u is certified and its run record is open, S_own(u) ends with a hit. Every call on its path is certified, and the cost is Σ_{ℓ<L} π_ℓ + j_L with j_L ≤ t*(u_L).

*Proof.*
* Let j₀ be u's first round that is a mistake or poses a lemma recorded open.
* *j₀ ≤ t*(u*).* Otherwise Lemma A makes the transcripts equal through t*(u*), so u stops there, proved: a contradiction.
* *At j₀.* S_own finds nothing before j₀. At j₀ it hits, or round j₀ is correct and poses an open lemma k. In the second case the transcripts agree before j₀, so k's question is the one u* poses in round j₀: k is certified, π(k) = j₀ ≤ p, k is open, and k* is proved.
* *Termination.* Fuel decreases, and at fuel 0, j₀ is a mistake. ∎

### 3.2 Records in place of proofs

**Search S_loc.**
* *Target:* the root if it is open; otherwise the call k whose claim V names, with path u₀, …, u_m = k.
* *At a path call u_i (i < m):* query rounds 1, 2, …. Hit at a mistake. Run S_own on the first lemma recorded open. Move on at the round that posed u_{i+1}.
* *At the target:* proceed as S_own, up to its terminal round. With no hit, return CERT.

**Theorem Y2-1** [P]. Assume (A1), (N-det), (V-det), (A2-tree-N) and (A3-tree). For every sequence of problems, chosen adaptively:
* **(a)** every output is a cone that V accepts, which is correct if V is sound per claim. No other assumption is used.
* **(b)** every search ends with a hit, so there are at most K/b rejections;
* **(c)** each search costs surely at most **Σ_{ℓ<L} π_ℓ + t*(u_L) ≤ p·d + r₀**, with T*_N's parameters. The rates f_p and f_f on the run's claims do not appear;
* **(d)** the total is at most (p·d + r₀)·K/b.

*Proof.*
* *Root open:* Claim 1.
* *Otherwise, along the path.* u₀ is certified. At a certified u_i the scan hits, or descends by Claim 1, or reaches the round j that poses u_{i+1} with rounds 1…j correct and their lemmas proved. In the last case, Lemma A and the correct label of round j show that u_i* poses u_{i+1}'s question in round j, so u_{i+1} is certified, with π = j ≤ p.
* *At k.* If j₀ > t*(k*), Lemma A gives k's final claim equal to k*'s, which V passes by (A3-tree) and (V-det): a contradiction. So the scan hits by round t*(k*), or descends by Claim 1.
* *Depth.* L ≤ d, since certified calls sit at positions of T*_N.
* *Counting.* As in the paper's Theorem 4.7(b). ∎

**The false-pass question.**
* *What a false pass leaves behind.* A false pass in the run on a certified lemma whose human counterpart is proved gives the human's record. So the parent's transcript is the human's (proof irrelevance).
* *Cost: none.* The search visits that lemma only if V names it or a claim under it, and then the target step finds the mistake behind the invalid proof.
* *Correctness: only if V also misses it,* and V's relevant miss rate is the one conditional on N's pass. Calls revise against N, as the human does, and a deviated call gets k_sub tries, so the claims that reach V are selected to pass N.
* *Proof irrelevance helps:* invalid claims in an accepted run stay inside deviated calls.

**Variant Y2-1′ (certify, then repair)** [P].
* *The rule.* Drop (A3-tree). On a CERT, overwrite N's verdict on the named claim with "fail". By Lemma A, the CERT certifies that the claim is the human's own.
* *Cost.* Under (A2-tree-err) (§3.3), every search ends in a hit (at most K/b of them) or a CERT (at most E_h), each costing at most p·d + r₀ + D·φ.
* *What E_h is.* E_h counts the human's claims that N passes and V's upheld objection fails. In expectation it is about T·N̄_c·e_h·f_p·c_V:
  * T is the number of problems;
  * N̄_c is the number of lemma proofs per tree;
  * e_h is the human's slip rate;
  * c_V is V's catch rate on the slips that N passed.

  It grows with T, not with K.

### 3.3 The best result: repair first

**Rule.** When V objects to a claim c, a second judge J rules first (a verification, not a task query).
* *Upheld:* N's cached verdict on c becomes "fail".
* *Dismissed:* the dismissal is cached.

Then rerun with the same decoder. Only runs whose root is open are searched, with S_own from the root.

**(A2-tree-err).** For every table N′ obtainable by such repairs, every call u of T*_{N′}(q_root):
* is recorded proved by round t*(u) ≤ r₀ + D·φ_{N′}(u);
* poses its lemmas by round p;
* and T*_{N′} has depth at most d.

**Theorem Y2-2 (repair first)** [P]. Assume (A1), (N-det), (V-det) and (A2-tree-err). Neither (A3-tree) nor claim-by-claim judging by V is needed. For every sequence of problems, chosen adaptively:
* **(a)** every output is a cone that V accepts, after J's dismissals;
* **(b)** every search starts at an open root and ends with a hit, so there are at most K/b searches;
* **(c)** each search costs surely at most **Σ_{ℓ<L} π_ℓ + t*_{N′}(u_L) ≤ p·d + r₀ + D·φ_{N′}(u_L*)**, with u_L* the human's counterpart of the last call;
* **(d)** total task queries are at most **(p·d + r₀ + D·φ_max)·K/b**, independent of N's and V's errors on the imitator's claims and of N's false passes on the human's;
* **(e)** every problem ends with an output. The repairs number at most the distinct claims that N passes and J judges invalid, plus the dismissals: about T·N̄_c·e_h·f_p·c_V of the human's, and at most k_sub per deviated call per decoder state of the imitator's. Each costs a ruling and a rerun.

*Proof.*
* *A fixed table.* During a run and its search the table N′ is fixed and deterministic, and (A2-tree-err) gives (A2-tree-N) for T*_{N′}, with r₀ + D·φ in place of r₀.
* *(b) and (c).* A searched run's root is certified and open, while the human's root is proved. Claim 1 gives the rest.
* *Counting.* Repairs add no data, so each hit is a mistake of the decoder in use and is worth at least b bits.
* *(e).* For a fixed decoder and problem, the run is a function of the table. The claims it can submit are finitely many: fuel and rounds are bounded, and records and verdicts are bits. Each repair or dismissal settles one claim for good (N now fails it, or V's objection to it stands dismissed). So each decoder state yields finitely many reruns, then acceptance or an open root, which yields a hit. Hits are at most K/b. ∎

*Why repairs are free in task queries.* In a chain, a rejected run changes only through learning. In a blueprint, node verdicts are *inputs* to the run. Correcting one towards the truth changes the run without learning, and it only removes false passes from the human's tree.

**Lemma C (where (A2-tree-err) comes from)** [P, in a model where the call sees only "pass" or "fail"].
* *The exact tree.* Let T*_⊤ be the human's tree under an exact verifier, with parameters p, d and r₀.
* *(B-fail_D).* After a false fail, the human poses no lemma and does not abandon in its next D rounds, and within them submits a new valid claim.
* *Conclusion.* If budgets satisfy r ≥ r₀ + D·φ, then for every table N′, every call of T*_{N′}:
  * is proved by round t*_⊤(u) + D·φ_{N′}(u);
  * poses a subset of T*_⊤'s lemmas at the same rounds;
  * sits at depth at most d.

*Proof.* Induction on fuel.
* *Records below.* Every lemma u poses is proved in both trees, so u's transcripts agree until N′ first errs on one of u's claims.
* *Before t*_⊤(u).* All of u's claims there are invalid, since the exact verifier stops u at its first valid claim. So an error there is a false pass, and u stops early, proved, having posed a subset of the lemmas.
* *At t*_⊤(u).* Otherwise the first error is a false fail at t*_⊤(u). Then (B-fail_D) gives a new valid claim within D rounds and no new lemma, and valid claims cannot be falsely passed. So u stops by t*_⊤(u) + D·φ. ∎

With objections shown as text, (A2-tree-⊤) must hold for whatever text an exact verifier shows, a robustness assumption of the same kind.

**Remark (V's first look)** [S].
* *The price of repair first.* Repair first shows V more of the imitator's invalid claims. Before a run's root opens, V can see up to k_sub of them from every deviated or corrupted call of the run; S_loc searches, and learns, after the first. Each extra look is another chance for V to miss. In the toy, V judged 1.1–2.2 times as many invalid imitator claims as under S_loc.
* *A middle rule.* Allow one free repair per problem and decoder state, and run S_loc (with a repair after a CERT) at any further named claim.
  * V then sees at most one more invalid imitator claim per problem and decoder state than under S_loc.
  * Task queries rise only by CERT searches at a second human slip in the same problem and decoder state.

### 3.4 The depth-first safety net

**Proposition Y2-3** [P]. Assume (A1), (N-det), (V-det), and that the human's own root is recorded proved in T*_{N′} for every repaired table.
* *Where the first mistake is.* In every searched run, the first mistake in depth-first order lies before position N*_r, the number of rounds of T*_{N′}.
* *The interleaved cost.* Alternating any search with the depth-first scan (cached answers, stopping at the first hit) costs at most 2·min{C, f + 1} ≤ 2·min{C, N*_r}, where C is the search's own cost and f the position of the first depth-first mistake.
* *With S_own,* under Theorem Y2-2's assumptions, this is 2·min{p·d + r₀ + D·φ, N*_r}.
* *What it covers.* No assumption about internal calls is used, so it covers abandonment, lucky proofs and broken shape assumptions.

*Proof.*
* *Depth-first order:* a call's rounds in order, each lemma's call right after the round that posed it.
* *Why the first difference is a mistake.* A position's transcript is determined by earlier positions: lemma records come from earlier rounds in the order, and verdicts are functions of claims. So the first position where the run and T*_{N′} differ has equal transcripts and different labels, which is a mistake.
* *Why it comes early.* If the first N*_r positions agree, the run is T*_{N′}, whose root is proved, so the run is not searched.
* *The factor 2.* Each stream gets every other query. ∎

### 3.5 Necessity

**Proposition Y2-4 (caching)** [P for (i), S for (ii)].
* (i) By CE1, with fresh verdicts a run without a mistake can be rejected, and Lemma A, Claim 1 and Proposition Y2-3 all fail at the verdict step.
* (ii) Suppose that, whenever the decoder repeats the human's labels, each run is rejected with probability at least δ. For example, δ ≈ 1 − (1 − f_p)^σ when the human's tree has σ slips that N must catch. Then every problem without a mistake costs about δ/(1−δ) uninformative rejections. Their number grows with T, and without a cache nothing can be repaired.

**Proposition Y2-5 (location)** [S].
* *The class.* Thread Y's planning-prefix class (its Theorem Y2), with f_p = 1 and an unlocated V.
* *Why it is hard.* Every record is "proved", and the run differs from T*_N only inside the call holding the missed insight. So the witness is a point among N*_r rounds.
* *The bound.* The paper's Theorem 6.2 argument gives Ω(N*_r·K/log(N*_r q/ε)) task queries, the chain bound.
* *With f_p < 1,* the records reveal the deviated call with probability about (1 − f_p)^{k_sub}, so a rejection costs about f_p^{k_sub}·Ω(N*_r/log).

## 4. Simulation [N]

**The toy** is thread Y's, with these changes.
* *Shape.* b = 3 lemmas per internal call and d = 3, so 40 calls per tree.
* *The human.* Its first submission is a slip with probability e_h = 0.1. After a fail it revises in one round (D = 1) with a valid claim.
* *N.* Its false-pass and false-fail rates both equal f. It is cached through a hash of the claim, except in "fresh" mode.
* *The run.* Deviated calls submit k_dev = 2 invalid claims.
* *V* is exact and located.
* *Scale.* 300 problems × 5 seeds; at most 40 hits per seed.
* *Checks,* run on every rejection of the cached methods, all passed: the cost bound with t*_N; path lemmas the human's own; a CERT only at the human's own slip; the first depth-first mistake before N*_r; and the factor 2 of interleaving.

Task queries per search, mean (maximum), for plan-first trees (p = 1). The bound is p·d + r₀ = 13, plus revision rounds.

| f | chain: per hit | S_loc: per hit | S_loc: certifying searches per seed (cost) | repair first: per hit | repairs per seed (human / imitator) | unlocated + depth-first: per hit; problems abstained | fresh: uninformative rejections per seed |
|---|---|---|---|---|---|---|---|
| 0 | 115 (300) | 6.8 (13) | 0 | 6.8 (13) | 0 / 0 | 10.8; 0% | 0 |
| 0.05 | 120 (304) | 6.8 (13) | 64 (7.2) | 6.8 (13) | 64 / 16 | 32; 19% | 74 |
| 0.15 | 117 (309) | 6.7 (15) | 187 (7.5) | 6.7 (15) | 187 / 40 | 64; 47% | 297 |
| 0.30 | 116 (323) | 6.3 (12) | 375 (7.6) | 6.3 (12) | 375 / 82 | 93; 72% | 995 |

**Totals.** Total task queries per seed, against 3(p·d + r₀)·40 = 1,560:

| method | f = 0 | f = 0.05 | f = 0.15 | f = 0.30 |
|---|---|---|---|---|
| chain | 4,612 | 14,676 | 34,319 | 64,055 |
| S_loc | 273 | 740 | 1,674 | 3,108 |
| repair first | 273 | 273 | 269 | 254 |
| unlocated | 433 | 13,288 | 32,561 | 51,477 |
| fresh | 433 | 1,416 | 4,356 | 12,983 |

**Readings.**
* *The maximum of 15 at f = 0.15* exceeds 13 only by revision rounds.
* *Lemmas posed over 4 rounds* (p = 4, bound 22): S_loc costs 10.2–10.3 per hit (maximum 22), and repair first totals 407–414 against 2,640.
* *No human slips* (e_h = 0):
  * S_loc costs 6.5–6.8 per hit;
  * unlocated search costs 10.8, 31, 64 and 93;
  * thread Y's S_own from the root stalls on 0, 27, 62 and 88% of rejections.
* *Design B, where V's node verdicts are N's.* It needs no repairs, but the share of outputs with an invalid claim is 0, 24, 59 and 86%, more than half of it from the human's own slips. An independent V is what correctness needs. These rates are not calibrated.

## 5. Design consequences for VSI-R on a blueprint

1. **Cache node verdicts per canonical claim**, and seed all randomness by the claim's hash.
2. **Locate objections, and let a judge rule before any task query.** Upheld objections overwrite N's cache.
3. **Search only open roots, interleaved with a depth-first scan.**
4. **Count only "proved" as good.**
5. **The instruction.**
   * Revise or clarify within D rounds of a fail, in a new text.
   * Abandon only after k_sub tries, with a reason.
   * Budget s ≥ D·φ_max.
6. **Give V methods that differ from N's,** and use the middle repair rule (§3.3) to keep V's first look.
7. **Verification effort.** Expect one focused, expert-judged critic pass per node claim per problem (cached): in effect a cone check. It counts against the paper's "works", not against the task-query criterion here.

## 6. Probability

The claim: VSI-R on an informal blueprint, for informal theory, has output failure ≤ 5% and task queries ≤ 3(p·d + r₀)K, abandonment and fallbacks included. This is conditional on determinism, realizability and h = 0.

| factor | estimate |
|---|---|
| output failure ≤ 5%: the whole cone checked with located objections; claims selected to pass N; V's looks kept near S_loc's by the middle repair rule | 0.60 |
| T*_N fits: isolation with informal statements, statements first, depth 2–3, budgets that absorb revisions | 0.50 |
| abandonment manageable (A ≤ about two attempts per path call), including abandonment after false fails | 0.60 |
| the verifier design works as idealized: cached verdicts, located objections, a judge, D·φ ≤ r₀ | 0.85 |
| no costly fallbacks (lucky proofs, interleaving that lands on the chain scan) | 0.80 |
| **product** | **≈ 0.12** |

With positive correlation among the middle factors, **about 15% (10–25%)**.
* *Against thread Y's formal research (35%).* The difference is mostly output failure (0.6 against 0.95).
* *Against the paper's 50% for "works".* Under "works", the interleaving keeps the blueprint version within a factor 2 of chain VSI-R, plus the discipline's cost and the verification effort: perhaps 40%.
* *What would move it most:* N's false-fail rate on careful humans' lemma proofs, and whether humans abandon after false fails.

## 7. Open

1. A correctness theorem for trees with repairs: the analog of the paper's Theorem 4.13, with the selection against N.
2. A V that judges only whole documents: locate by verification on sub-cones, against the paper's Theorem 6.2.
3. The robustness of T* to the wording of objections.
4. Calibrate e_h, f_p, f_f and k_sub on a live informal blueprint.
