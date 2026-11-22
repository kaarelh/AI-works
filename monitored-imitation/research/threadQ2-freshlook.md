# Thread Q2: a fresh look for a scheme that beats verified slack imitation

*Research note by Claude (Anthropic) on [`../verified-slack.md`](../verified-slack.md) (VSI), read with note.md, slack-imitation.md and threads F, G, J, Q, S, T and U. Draft; not refereed.*
* *Code:* [`threadQ2_blindspot.py`](threadQ2_blindspot.py). *Output:* [`threadQ2_blindspot.out`](threadQ2_blindspot.out). It takes about 20 s with fixed seeds, and imports `threadU_verify.py` unchanged.
* *Status marks:* **[proved]**, full proof here; **[sketch]**, argument given.
* No existing file was changed.

*Notation is VSI's (§1, §3).*
* K, b, n₀, n, assumptions (A1)–(A4′), Lemma 1 (the first mistake comes before n₀) and Theorem 5 are as there.
* R is the number of rejections. Under (A2) and (A3′) every rejection ends in a hit, so R ≤ K/b on every path (Theorem 5(b)).
* T is the number of problems.
* p is the first-run failure rate, w the share of failed runs that carry a claimed solution, and f the verifier's miss rate on the imitator's wrong claims.

## Answers in brief

1. **Verdict.** I found no scheme that dominates VSI. But VSI's correctness needs much less than the folder says, and two additions come with theorems.
   * *First* remains VSI with a proof assistant on a reviewed formal goal: 70%, unchanged.
   * *Second,* on a far wider domain, is VSI-R: VSI with thread U's combined verifier, run as in §6. It reaches about **59% for informal theory and 66% for software without a full specification**, against 50% and 60% now.
2. **Theorem Q2.1: wrong outputs are paid for by rejections [proved].** Take i.i.d. problems and *any* verifier, sound or not. Suppose V has *no total blind spot*: for every decoder the learner can reach, the wrong claims V passes are at most c times the runs V rejects. Then E[#wrong outputs] ≤ (c+1)·E[R] ≤ (c+1)K/b, over any number of problems.
   * *What it does without:* audits, bounded setback and soundness.
   * *So the failure rate* is at most (c+1)K/(bT), and in any window at most (c+1) times the observed rejection rate.
   * *Product classes:* the bound holds kind by kind, Σ_κ(c_κ+1)K_κ/b. So thread S's "allocation" (learning leaves the errors V misses) is paid for per kind.
   * *A randomized verifier* that passes each wrong claim with probability at most f̄ gives E[#wrong] ≤ f̄K/((1−f̄)b) on *every* problem sequence.
   * *Why c is finite even for weak verifiers.* Failed runs without a claim are always rejected, so a kind of error with claim share w and miss rate f has c = wf/(1−wf). For one careful reader in theory that is 0.24.
3. **A total blind spot brings back the hidden-insight price** (Proposition Q2.2) **[sketch].** On a kind that V always passes, V's verdicts carry no information, and Theorem 3's n·K/ε returns on that kind. So the dichotomy is "c finite" against "c infinite", not "f small" against "f large".
4. **What correctness now rests on.**
   * *Before:* "V catches the imitator's most plausible wrong answers", that is, f small.
   * *After:* "V catches *every kind* of imitator error *sometimes*", that is, c finite, together with T ≫ K.
   * *T ≫ K* is the regime in which imitation saves effort at all. A deployment that saves a factor S over the human doing every problem has output failure at most (c+1)/(sS), where s is the mean search cost per rejection in units of n₀. *Worth using* and *rarely wrong* become one condition.
5. **Thread U's sureness model is inconsistent with Theorem 5(b).**
   * *The flaw.* It draws p ∈ [0.1, 0.5] independently of T/K ∈ [3, 30]. A steady p needs about p(1−wf)T rejections, more than the K allowed in 66–82% of its no-transfer draws.
   * *Correcting it,* with errors counted kind by kind, raises the model's P(works) (Part C):
     * theory, combined verifier: 62% → 70% (76% with audits cut to β = 0.1);
     * theory, one reader: 35% → 47%;
     * software: 73% → 78% (82%);
     * empirical: 23% → 26%;
     * judgment: 28% → 32%.
   * *The pessimistic reading,* every error of the hardest type, lowers every row. Which reading holds is the unmeasured crux.
6. **Theorem Q2.3: falsification by use [proved].** This is deferred, use-based verification, as in software maintenance.
   * *The setup.* Keep the library equal to the current imitator's outputs, and let later work cite it. Suppose every use that relies on a false claim yields, with probability at least e, a located and certified counterexample.
   * *The result.* Every exposure is a hit. Uses of false outputs number at most K/(be) in expectation, for ever, with at most 2n₀ task queries per exposure.
   * *What it covers.* It reaches V's total blind spots, which audits reach only at rate |M|/n.
7. **(i) Domain.** Nothing is as sure as the formal row on goals that are not crisp: without a crisp signal there is no detection, and Theorem 3 applies.
   * *Crisp but informal goals:* VSI-R closes most of the gap for software and about half of it for informal theory.
   * *Empirical and engineering claims:* falsification by use reaches them only where later uses produce certified contradictions.
8. **(ii) Sureness without a machine verifier.** Yes, in the sense of item 4, and the new assumption can be measured. But it trades V's soundness for the idealizations: the K budget needs determinism and realizability, which VSI-machine's correctness did not. *Certification by independent solution* (§5.1) is the one check whose evidence survives their loss.
9. **(iii) Cost.** There is no better worst case: on silent humans, Theorem Q1 binds every scheme with task queries and verifications.
   * *Extra streams.* Hints, diff pointers and a second granularity are risk-free streams at best.
   * *The one saving.* With c finite, VSI's β = 1 audits are unnecessary, which saves up to T task queries.
10. **(iv) Simpler.** Verified check-and-scan has a better worst case, n₀K/b against 2n₀K/b, with the same correctness. It loses the O(1) pointers that matter in E7, so it is not a strict improvement.
11. **The other directions** (§5).
    * *Two imitated humans as generators,* agreement checks and two granularities give no location (Proposition Q6), and their blind spots are correlated.
    * *Diversity pays in the verifier:* a randomly assigned pool of people and model families, which Theorem Q2.1(c) rewards.
    * *"Endorsed after a step of checking"* is verifiable by definition and means human parity. Its gap to truth is exactly Theorem Q2.1's c.

## 1. Where VSI's sureness and cost come from

* *Output failure* is F ≈ p·w·r̄·f (thread S; thread U), with r̄ the number of distinct wrong claims verified per failing problem.
* *Cost* is R searches of up to 2n₀ each, plus T verifications and βT audits.
* *Three levers:* the verifier (f), learning (p) and the search.
* *The folder's analysis holds p fixed: "no transfer".* But R ≤ K/b caps the time average of p(1−wf) at K/(bT), so p and T/K are not independent.
  * *No transfer means K grows with T:* the knowledge is problem-specific. That is also the regime in which VSI saves little over the human doing the problems, a factor of about 1/(ps).
  * *When T ≫ K,* p must fall. What then matters is not how often V misses, but whether its misses ever teach.

## 2. Theorem Q2.1: wrong outputs are paid for by rejections

*Setting.*
* *The protocol:* VSI (§2.3 there) with any verifier V: human, imitated, combined or randomized. Verdicts are cached on canonical claims (§5 there).
* *Assumptions:* (A1); (A2) and (A3′) for every problem. S\* is any goal.
* *Terms.* The *first run* of problem t is the run of the decoder in use when t arrives. A *state* of the protocol is its data plus its verdict cache.

**(C_c) No total blind spot.** For every state the protocol can reach, with decoder G, the probabilities below being over p ∼ μ and V's own coins:

  Pr[G's run on p ends with a claim that V passes and that fails S\*] ≤ c · Pr[V rejects G's run on p].

**Theorem Q2.1.** Assume (A1), (A2) and (A3′).
* **(a)** Let problems be i.i.d. from μ, and assume (C_c). For every T, and within every window of rounds,

  E[#wrong outputs] ≤ c·E[#first-run rejections] + E[#problems with a rejection] ≤ (c+1)·E[R] ≤ (c+1)K/b.

* **(b) Product classes.** Let the class be a product over kinds κ, as in thread J's Definition 0: a problem's runs depend only on its kind's parameter, and the prior is a product. Let (C_c) hold for each kind, with μ conditioned on κ and constant c_κ. Then E[#wrong outputs] ≤ Σ_κ(c_κ+1)·K_κ/b, where Σ_κ K_κ = K.
* **(c) Randomized verifier, any problem sequence.** Suppose each fresh verification draws new coins, and passes every wrong claim with probability at most f̄ given the past. Then E[#wrong outputs] ≤ (f̄/(1−f̄))·E[R] ≤ f̄K/((1−f̄)b), with no i.i.d. assumption.

*Proof.*
* *Every rejection is a hit.* The cache holds only verdicts V gave, and V never rejects the human's claim (A3′). So Lemma 1 holds for the cached V, the search ends in a hit, and R ≤ K/b on every path.
* *(a).* Given the past, p_t is independent of the state. So the probability that round t outputs a wrong claim with no rejection is at most c times the probability that its first run is rejected. Sum over rounds. A problem with a rejection has one output, right or wrong.
* *(b).* Under a product prior the potential is Φ = Σ_κ Φ_κ. The decoder on a kind-κ problem depends only on κ's data, and a hit there lowers Φ_κ by at least b. So kind κ has at most K_κ/b rejections. Apply (a) to the thinned i.i.d. stream of kind-κ problems.
* *(c).* Caching verifies each claim at most once. Let N be the number of fresh verifications of wrong claims. Each passes with conditional probability at most f̄, so E[#passed] ≤ f̄·E[N] and E[#rejected] ≥ (1−f̄)·E[N]. Every wrong output is a passed one, and every rejected one is a rejection. ∎

*Remarks.*
* **What c is.** For a kind of error with claim share w_κ and miss rate f_κ, c_κ = w_κf_κ/(1 − w_κf_κ).
  * *Examples:* 0.24 for one careful reader in theory (w = 0.45, f = 0.43), and 0.68 for deep errors (f = 0.9).
  * *What c = ∞ takes:* w_κf_κ = 1, a kind that always ends with a claim and is never caught.
* **Allocation is paid for.** Learning removes the errors V catches and leaves the rest (thread S). In (b) each kind still contributes at most c_κ+1 wrong outputs per rejection it causes, whenever they come. In (a), c must cover the worst mix the learner can reach.
* **No audits.** Theorem 5(f) needs β = 1 audits, and bounded setback in τ\*, to bound V's misses: an audit finds a missed run at rate |M|/n. Theorem Q2.1 instead locates the *kind* through rejections on other problems.
* **Checks** (Part A of the output; the bounds are attained).

  | case, T = 10⁵ | wrong outputs | bound | comment |
  |---|---|---|---|
  | uniform w = 0.5, f = 0.4 | 97 | Σ_κ c_κ = 100 | |
  | heterogeneous w, f | 260 | 266 | |
  | an unmasked second layer at f = 0.9 | 3,430 | 3,644 | still rising |
  | one total blind spot | 2,008 | – | linear in T: a 2% rate |
  | 30% of problems with fresh, problem-specific kinds | – | – | rate 6% at every T, which is p·w·f |

  The last row is thread S's "the rate need not decay": K then grows with T.
* **Practical learners.** A learner that resamples up to k times inflates c by up to k. The theorem is for exact Bayes with the majority decoder.

**Proposition Q2.2 (a total blind spot costs the hidden-insight price) [sketch].**
* *The setting.* Take a faithful hiding product class (thread J, Definition 4) and a set B of its problems. On B, V passes every final notebook the decoder can produce before a hit; for example, V checks only the format, or shares the imitator's misreading of the goal.
* *The argument.* On B, V's verdicts are a known constant, so any protocol of task queries and verifications is task-only there. Lemma J0 gives failure on B at least (1−γ)η(1 − 2Q_B/(ℓ·m_B)), where Q_B counts the task queries on B, m_B the problems in B, and the load ℓ is at least the location number L.
* *The consequence.* Reaching ε on B needs Ω(L·K_B/(ε log)) task queries. VSI without audits never repairs B, and its audits repair it only at chained imitation's rate.

**Corollary Q2.2b (monitoring, and the savings coupling).**
* *Monitoring.* Under (C_c), E[wrong outputs in a window] ≤ (c+1)·E[rejections in it], and the rejection rate is observed. Once planted-error tests bound c, the deployment knows when F is below 5%: when (c+1) times the rejection rate is.
* *The savings coupling.* Let searches cost s·n₀ per rejection, and verification c_V per problem. VSI's effort relative to the human doing every problem is then 1/S = s·R/T + c_V/n₀, so F ≤ (c+1)/(sS).
  * *In product classes,* F ≲ r̄·c̄/(sS), with c̄ the kind-average of c_κ.
  * *Example:* c̄ = 0.24, s = 1 and S = 10 give F ≲ 3%.
  * *The caveat:* cheap searches (good pointers, small s) weaken the coupling.

**Is "no total blind spot" believable?**
* *For.*
  * It asks that each kind be caught sometimes, not usually.
  * Planted-error studies find partial catch rates, 30–60% for reading (thread L), rarely zero for a kind.
  * Thread U's own model attaches difficulty to instances: its latent factors are drawn per claim, so no kind has f = 1.
  * Diverse methods make a shared total blind spot rarer, and randomization (part (c)) removes a fixed one that a resampling learner could find.
* *Against.*
  * A misreading of the goal shared by V and the imitator.
  * Empirical claims false in the world that follow from the data: every reading method misses them (f ≈ 0.85–0.95, thread U), and only later data reach them.
  * An AI imitator sharing AI critics' blind spots.
  * Malign hypotheses aiming at a fixed V.
* *My probability q* that the combined verifier has no total blind spot that matters on the imitator's errors: 65% in theory, 70% in software, 25% in empirical work, 30% in judgment work.
* *Measurable.* Plant several instances of each kind of error. Are catch rates bimodal by kind (systematic), or spread by instance?

## 3. Correcting the sureness estimates (Part C)

* *Thread U's model* reproduces the folder's human-verifier rows (its §2).
* *The constraint it misses.* Under (A2) and (A3′), R ≤ K, taking b = 1 as its effort term does. A steady p makes about p(1−wf)T rejections, but thread U draws p independently of T/K.
* *Part C* reruns that model with the same draws, which reproduces its figures exactly, in four ways:
  * **cap:** p ≤ 1/(T/K·(1−wf)), with the mixed f;
  * **kinds:** F ≤ r̄·c̄/(T/K), Theorem Q2.1(b) with thread U's type shares as kinds;
  * **kinds, β = 0.1:** the same, with audits cut from one per output to 0.1;
  * **worst:** every error of the protocol's hardest type, from the start.

| protocol (thread U's names) | thread U | cap | kinds | kinds, β = 0.1 | worst |
|---|---|---|---|---|---|
| theory: one expert reads | 35% | 48% | 47% | 55% | 30% |
| theory: read + 3 AI critics | 64% | 74% | 73% | 78% | 49% |
| theory: LEAN (machine, 3 critics, adversarial reader) | 62% | 71% | 70% | 76% | 45% |
| software: fixed tests only | 39% | 63% | 59% | 59% | 30% |
| software: LEAN (tests, independent tests, fuzzing, 3 critics) | 73% | 79% | 78% | 82% | 48% |
| empirical: one expert reads | 9% | 11% | 11% | 13% | 9% |
| empirical: FAST | 23% | 28% | 26% | 30% | 15% |
| empirical, goal narrowed to the analysis: FAST | 28% | 34% | 31% | 36% | 15% |
| judgment: red team, pre-mortem, judge, fact checks | 28% | 36% | 32% | 36% | 16% |

*My figures.*
* *The formula:* P = q·(kinds, β = 0.1, less thread U's shading) + (1−q)·(thread U's own figure). The shading is thread U's 8–13 points; q is §2's.
* *The results:*
  * informal theory with LEAN: 0.65·(76−12) + 0.35·50 ≈ **59%**;
  * software with LEAN: 0.70·(82−13) + 0.30·60 ≈ **66%**;
  * empirical work: 0.25·(30−8) + 0.75·15 ≈ 17%, plus about a point for falsification by use in later experiments: **18%**;
  * empirical work with the goal narrowed to the analysis: q = 0.45, since narrowing removes the "false in the world" kind, so 0.45·(36−8) + 0.55·25 ≈ 26%, plus 1–2 points for use: **28%**;
  * judgment work: 0.30·(36−8) + 0.70·20 ≈ **22%**;
  * one expert reader in theory: a single method is likelier to have a total blind spot, so q = 0.5, with a shading of 6 points and the folder's 40% as the fallback: 0.5·(55−6) + 0.5·40 ≈ **45%**.
* *What these assume.* They keep thread U's conditioning: determinism, realizability, and the human's chain succeeding.
* *Without the idealizations,* Theorem Q2.1's route is void, and the rows fall back to thread U's.

## 4. Theorem Q2.3: falsification by use

**Protocol VSI-U.** VSI, with any V or none, plus three things:
* *The library:* the current decoder's accepted outputs on all problems so far. It is recomputed after every hit (compute is free), with downstream outputs recomputed in dependency order.
* *Uses:* later runs cite library claims. At each citation the scaffold may also test the claim on instances, as machine records (thread F's Δ4).
* *Exposures:* a located, certified counterexample to one cited claim, such as a machine-checked computation, a failing test with its record, or a checkable contradiction. The claim enters the rejection cache, and its problem's current run is searched as in §2.3.

**Assumptions.**
* **(E1)** Only false claims are exposed.
* **(E2)** On every problem, the human's own chain reaches within n₀ a claim that V passes and that is never exposed. This is (A2) and (A3′) for the verifier "V passes it and it is not exposed".
* **(E3)** Every use that relies on a false claim, at a point where it is false, exposes it with probability at least e given the past.

**Theorem Q2.3 [proved].** Assume (A1) and (E1)–(E3). On any problem sequence:
* (a) every exposure ends in a hit. So exposures and rejections together number at most K/b, each search costing at most 2n₀ task queries;
* (b) E[#harmful uses] ≤ K/(be), where a harmful use relies on a false claim where it is false.

*Proof.*
* (a) The exposed claim is the current decoder's output on its problem, so that run is now rejected. By (E2), Lemma 1 applies, and the search ends in a hit.
* (b) Each harmful use is a trial that exposes with probability at least e, given the past. By optional stopping, e·E[#harmful uses] ≤ E[#exposures] ≤ K/b. ∎

*Remarks.*
* **A different guarantee.** Not "every output is correct", but "total reliance on false outputs is bounded, for ever". The consumer's own use counts as a use.
* **Complementary to Theorem Q2.1.** It needs no (C_c), and reaches V's total blind spots at rate e per use. Its weak point is (E3), the use analogue of part (c): a false claim that uses rely on but cannot expose defeats it.
* **Check** (Part B). V has 50 total blind spots, and e is 0.05, 0.2 and 0.5.
  * *Harmful uses* number 1,020, 264 and 102, against the bound 50/e, which is attained within sampling error.
  * *Without uses,* 81% of problems stay wrong for ever.
* **The human's own later work** is a special case. In later searches the human's task answers see cited outputs; a careful human who writes "Lemma L is false; here is a counterexample" exposes L at no extra query. Dedicated re-use by the human costs n₀ per check and does not pay.
* **Where e is large:** software (tests and runs in later work), computational mathematics, engineering components, and predictions tested by later experiments.
* **Where e is small:** proofs that cite lemmas without computing, and judgment work.
* **Costs:** outputs stay provisional, and dependencies must be tracked. This is thread U §3.5's "delayed checks by consequence", with a K budget on what they cost.

## 5. The other directions

**5.1 Certification by independent solution.**
* *Protocol.* Freeze the imitator and draw m outputs at random. For each, a second researcher first solves the problem (n₀ task steps, which are also fully labelled data), then judges the output. Certify only if none fails.
* *Result [standard].* If F > ε, the certificate passes with probability at most (1 − (1−f_g)ε)^m. So m ≈ 3/((1−f_g)ε), about 60–70, gives 95% confidence at ε = 5%.
* *What it rests on.* "Someone who has solved the problem can tell whether another's solution is right", with miss rate f_g ≈ 0.05–0.15 by my estimate. That is more believable than a cold reader's 0.43.
* *Cost.* About 65·n₀ once per certificate, comparable to the search budget 2n₀K/b at K/b ≈ 30.
* *Why have it.* It is the only evidence here that survives the loss of determinism and realizability, and it measures c.

**5.2 Asking for less than a step: hints.**
* *Protocol.* On a rejection, a second researcher reads the failed run and V's located objection, and writes a hint h of a few lines. Rerun the problem as x₀ + h, and output it if V accepts. Otherwise search the original run.
* *Result [proved; immediate].* Correctness is still V's. A hint costs at most one extra verification, which is one more chance for V to miss.
* *The gain.* Minutes of a peer's time replace a search, for a deficiency that a peer can name.
* *The limits.*
  * *No learning:* a recurring deficiency costs a hint each time, unless the hint's location also feeds the post-mortem stream.
  * *No worst-case gain:* thread B's Theorem 4 (insights reportable with probability φ cut the price only by 1−φ), and Theorem G3 (no one can name an insight triggered by doing). A hint is thread J's "confession state", available only when someone can answer it.
* *Believability* that hints resolve half the rejections in research: 25%.

**5.3 Ensembles of different humans.**
* *As generators.* Imitate P₁ and P₂, and accept when both reach the same answer.
  * *Location:* none, since a rule built from imitator runs is task-only (Proposition Q6(a)).
  * *Detection:* its blind spot is "both wrong the same way", which is correlated, as readers' misses are (r ≈ 0.45–0.75, thread U).
  * *Cost:* K₁ + K₂.
* *As verifiers.* A pool drawn from different people and model families, assigned at random per claim, is Theorem Q2.1(c)'s randomized V. Its f̄ is the largest share of the pool that misses one claim. Diversity pays here: it shrinks the total blind spots.

**5.4 Two granularities.** Imitate at three-month and one-week steps, and compare the two runs at the coarse boundaries.
* *Disagreement* locates only knowledge one imitator has and the other lacks. An insight that neither posterior holds gives agreement (Proposition Q6(d)).
* *Fine queries* buy location at the same human time per step (Proposition Q7; thread J §5).
* *So there is no worst-case gain;* this follows from Q6 and Q7.

**5.5 Problem families.** They help in three ways, none new in kind:
* they make T/K large, which is Theorem Q2.1's regime;
* "the solution of one checks another" is a use (Theorem Q2.3), with e the chance that a related problem exposes a false solution, through special cases or consistency relations;
* consistency checks are a verifier whose total blind spot is "consistently wrong", so they are useful only inside a diverse V.

**5.6 Endorsement after a step of checking, as the success notion.**
* *Verifiable by definition:* VSI with V = that check satisfies the notion on every output.
* *What it means:* human parity, since outputs meet the standard a careful peer applies.
* *Its gap to truth* is the endorsement's misses. Under exact Bayes, rerunning selects for them by at most log₂(1+R_p) bits per problem (thread S), and Theorem Q2.1 bounds their total by (c+1)K/b.
* *So* it is V-human relabelled (thread S), with Theorem Q2.1 attached.

**5.7 A simpler scheme: verified check-and-scan.**
* *Protocol:* run, verify, and on a rejection scan from step 0.
* *Cost:* Lemma 1 caps each search at n₀, so task queries are at most n₀K/b, half VSI's, with the same correctness.
* *What it loses:* the uniform stream's O(Λ) under bounded setback, and the pointers' O(1). In EQ, fooled humans cost 105–1,562 task queries with scan and uniform streams alone, against 40–55 with the hint stream.
* *The compromise:* thread S's 8:1:1 schedule, with worst case 1.25n₀.

**5.8 Blind re-derivation.**
* *The idea:* a verifier shown only the claimed statement cannot be fooled by the argument's plausibility. Its misses are its own false proofs (h, 3–10%).
* *The catch:* it costs the hard step, about n₀ on research problems. It pays only where finding the answer is the hard part, and there a machine check usually exists.

## 6. The four questions, and VSI-R

**Protocol VSI-R.** VSI (§2.3), with six changes.
1. *V is a pool.*
   * *Its members:* machine checks of every computation and citation; AI critics of at least three families, with hidden, rotated prompts; and an expert reader other than the imitated human, who judges the critics' located objections (thread U's LEAN).
   * *Assignment:* draw the prompts, and the reader where there are several, at random per claim.
2. *Cache verdicts on canonical claims.*
3. *Audit at β ≈ 0.1, not 1.*
4. *Monitor.* Mark outputs as within the rate bound only while (ĉ+1)·r_W ≤ 5%. Here r_W is the rejection rate over a sliding window, and ĉ comes from per-kind planted-error tests and from step 5.
5. *Certify* a frozen deployment by independent solution (§5.1).
6. *Run Theorem Q2.3's loop* wherever later work uses outputs.

No step judges whether a run is on track. V and the certificate check finished results, and exposures are machine-certified.

* **(i) Domain: no.** On goals with no crisp criterion, V must judge value. The deficiency "shallow but fine-looking" is then plausibly a total blind spot, so Theorem Q2.1 does not apply, and task-only learning pays Theorem 3. On crisp but informal goals, VSI-R comes within about 4 points of the formal row for software and about 11 for informal theory.
* **(ii) A more believable property: yes, conditionally.** "V catches every kind sometimes" replaces "V catches almost everything". It can be measured, and the deployment can monitor its own rate. The price is that correctness again leans on the idealizations, through the K budget, and the certificate is what guards against that.
* **(iii) Cost: no better worst case.**
  * *Silent humans:* 2n₀K/b is optimal up to a log (Theorem Q1).
  * *Other lower bounds:* G3, F3, J1 and J6 bound every scheme here as they bound VSI. None of my results touches task-query counts, except that audits drop from T to about 0.1T.
* **(iv) Simpler: no strict improvement.** Verified check-and-scan trades typical-case pointers for a better worst case.

## 7. Ranking and verdict

Same "works" and conditioning as verified-slack.md §7: output failure at most 5%, effort at most a fifth of chained imitation's, determinism, realizability, and a chain that succeeds.

| rank | scheme | correctness rests on | worst-case task queries | theory | software | empirical | judgment |
|---|---|---|---|---|---|---|---|
| 1 | VSI, proof assistant on a reviewed formal goal | the statement and the checker; its residual, misformalization, is a per-problem total blind spot that Theorem Q2.1 does not reduce | 2n₀K/b | **70%** | – | – | – |
| 2 | **VSI-R** (§6) | c finite with T ≫ K (Theorem Q2.1), or f small; certified by independent solution | 2n₀K/b, audits 0.1T | **59%** | **66%** | **18%** (28% narrowed) | **22%** |
| 3 | VSI with thread U's combined verifier (verified-slack.md today) | f small | 2n₀K/b, audits T | 50% | 60% | 15% (25%) | 20% |
| 4 | VSI-R with one expert reader | c finite for one reader | as row 2 | 45% | – | 10% | – |
| 5 | VSI with a human verifier (folder) | f small | 2n₀K/b | 40% | – | 10% | – |
| 6 | VSI with a test suite | the tests | 2n₀K/b | – | 45% | – | – |
| 7 | verified check-and-scan | as VSI | n₀K/b | row 3 less 2 | row 3 less 2 | – | – |
| 8 | falsification by use alone, with no verifier at release | (E1)–(E3); bounds reliance, not outputs | 2n₀K/b | 15% | 35% | 12% | 8% |
| 9 | Proposition 7 (slack imitation, asking, design elements) | (B_D), (R-rev), (A-pers), (L2) | n per bit | 30% | – | 10% | – |
| 10 | hints as the main engine; two humans as generators | V; correlated agreement | 2n₀K/b | ≤ 25% | ≤ 30% | ≤ 10% | ≤ 10% |
| – | two granularities | no gain (Q6, Q7) | – | – | – | – | – |
| – | chained imitation | nothing | n₀K/ε | baseline | baseline | baseline | baseline |

**Verdict.**
* **Nothing beats VSI as a scheme.** The worst-case cost is optimal up to a log (Q1). No signal that avoids on-track judgments locates silent omissions (Q1, Q6, G3, thread A's Theorem C). And outside crisp goals nothing detects at all.
* **What I found is a better-founded VSI.**
  * *Correctness* needs only that V have no total blind spot, in the regime where imitation saves effort.
  * *Its rate* is bounded by its own observed rejection rate.
  * *Its β = 1 audits* can go.
  * *Uses* bound reliance on whatever V never catches.
  * *Consequence:* the non-formal rows rise by 2–9 points, and sureness becomes monitorable.
* **The scheme I am most sure of is unchanged:** VSI with a proof assistant on a reviewed formal goal, at 70%. For software without a full specification, VSI-R at 66% is nearly as sure, on a far wider domain.

## 8. What to measure first

1. **Per-kind catch rates.** Plant several instances of each kind of imitator error, and run the combined verifier on them. Is any kind never caught? Are misses systematic by kind, or spread by instance? This decides between the "kinds" and "worst" columns.
2. **The rejection-rate trajectory** in a pilot. Does it fall like K/T?
3. **c on the current decoder,** from gold-standard audits (§5.1).
4. **e in software and computational work.** What share of later uses of a planted false function or lemma produce a certified counterexample?
5. **Whether a resampling learner inflates c.**

## 9. Limits

* *Theorem Q2.1's assumptions.* It needs i.i.d. problems (or part (c)'s randomized V), the idealizations (through R ≤ K/b), and exact Bayes with a deterministic decoder. Like (B_D), (C_c) is learner-relative.
* *The corrected figures* inherit thread U's judgment inputs. Only the rejection-budget correction and the q weights are new.
* *Parts A and B are bookkeeping models,* in which one hit teaches a kind, not exact-Bayes classes. They check the counting, not that real verifiers have finite c.
