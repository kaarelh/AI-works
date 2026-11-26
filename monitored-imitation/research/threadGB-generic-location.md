# Thread GB: does genericity make mistakes cheap to locate?

*Working note by Claude (Anthropic), for the location half of Kaarel Hänni's question about generic humans. A parallel thread handles the trolling and calibration half. Draft; not refereed. No existing file was changed.*
* *Code:* [`threadGB_location.py`](threadGB_location.py). *Output:* [`threadGB_location.out`](threadGB_location.out). Runtime about 3 minutes (`python3 -B threadGB_location.py`).
* *Status tags:* **[P]** proved here (proofs in §7), **[S]** sketched, **[C]** conjectured, **[N]** numerical. The toys check bookkeeping and bounds; they test no assumption about real humans.
* *Numbering:* results GB0–GB8 are this thread's. "Lemma bit", "Lemma early" and Theorems lb-task and lb-verify are the paper's Lemmas 2.1 and 4.2 and Theorems 6.1 and 6.2 (`paper/verified-slack-imitation.tex`).

## Answers in brief

**The question, for location.** If the human is a generic program of its complexity, are its mistakes cheap to find? The short answer is no, if "most programs are easy" means O(K) or O(K log n) queries. What makes location cheap is a structural property, *exposure*, not genericity.

1. **Genericity buys the best search order, at no risk** (Theorem GB1) [P]. If P is drawn from the learner's prior, the posterior is calibrated. On a rejected run the learner knows λ(k), the probability that step k is the first mistake.
   * *Bayesian search* queries steps in decreasing λ. Its expected cost per rejection is at most the guessing cost G(λ) = Σᵢ i·λ₍ᵢ₎.
   * *Cost bounds.* G is at most the scan's expected cost and at most (N+1)/2, where N is the number of *suspect steps* (steps where some posterior mass disagrees with the run). Also G ≤ 2^{H½(λ)}, and E[log₂ cost] ≤ H(λ).
   * *Guarantees.* The search costs at most n₀ on every path, for every human in the class. When the run has a single mistake, it is optimal among searches of the run's steps.
2. **A worst-case dividend, with no genericity assumed** (Theorem GB2) [P].
   * *The search.* Query steps whose current doubt is at least γ, recomputing after each miss; each such miss pays at least log₂(1/(1−γ)) bits. Then fall back to any order; a fallback hit pays more than log₂(1/γ) bits.
   * *Total cost:* (1 + 1/c_γ)K + n₀·R_γ, where R_γ ≤ K/log₂(1/γ) counts the *diffuse* rejections.
   * *Worst case.* With γ = log₂n₀/n₀ this is O(n₀K/log n₀), with at most n₀ per rejection. That is a log factor below VSI's 2n₀K, and within a constant of Theorem lb-verify when q = poly(n).
3. **What decides the cost is how a generic program spends its bits** (GB3–GB5).
   * *Content of shared code is cheap.* In a modular model (random code tables; which code a step runs is visible), every program is easy, generic or not. Bayesian search makes at most K/log₂q queries in all, and q/(q−1) per rejection in expectation [P]. Rare calls hurt only the scan and chained imitation.
   * *Rare triggers are expensive.* In decision lists over notebook features with log-uniform branch frequencies, consider the first firing of a rule of frequency below 1/n. Every search of the run must test its fresh steps one by one: Θ(n) [P per rejection], about n/4 in the toy [S, N].
   * *Reuse rescues them.* If the rule fires in two problems, a learner that defers the first rejection and conditions on it finds the second firing in 1 + n²/2^{j+1} expected queries [P, idealized]. A rule that fires in only one problem is exactly a silent insight.
4. **Is silence generic? Yes, at a rate that keeps the cost linear in n** (GB6, GB7).
   * *How common.* Under log-uniform frequencies, a fraction 1/ln(nT) of the exercised rules fire in exactly one problem: 7–12% in E4. Under a universal-type prior (scale j costs about 2 log j bits), 0.2–0.6%.
   * *What it costs.* Each such rule costs Θ(n), so expected location cost is about c·n·K_ex/log²(nT) [S], where K_ex counts the bits of the rules the deployment exercises. That is a log factor below the silent worst case, but linear in n. So "most programs are easy" fails asymptotically.
   * *At moderate n.* Under the universal-type prior the linear term stays below a query per bit up to n ≈ 10⁴ [S].
5. **The right assumption is exposure** (GB8) [P].
   * *Theorem.* If at most R rejections are γ-diffuse (at some point every unqueried step has doubt below γ), the cost is at most (1+1/c_γ)K + n₀R.
   * *What gives it.* Visible dispatch gives R = 0. Reuse of rare triggers across problems, with deferral, makes R about the number of single-use rare behaviours.
   * *Necessary.* Each single-use, unpredictable, rare behaviour costs Ω(n) for any task-only protocol with few verifications.
   * *In words:* location is cheap when every bit of the program that matters is used at steps the learner can flag, or in more than one problem.
6. **Simulation** (exact Bayes; n = 64; 12 humans × 300 problems) [N]. Search cost per rejection, scan → Bayesian:
   * *Modular (M1):* 25.9 → 1.15 (about 14 of 64 steps suspect). Per human, 813 → 36 queries in all.
   * *Decision lists (FV):* 25.5 → 8.7, and 187 → 63 per human. First firings of rare rules: 30.4 → 17.6. Mistakes of known rules: 28.7 → 1.06.
   * *Silent humans:* 33.1 for every search. G(λ) = 32.5 = (n+1)/2, and all 64 steps are suspect.
   * *Deferral:* when a rare rule fires in two or more problems, its first discovery costs 4.5–5.8 queries instead of 19.5–21.5 (j = 10, 12). Single-shot rules cost 19.6 either way.
   * *Chained imitation,* with no verifier and the same budget of 300 queries, outputs 30–80% wrong runs. It pays 16 (M1) to 240 (silent) queries per hit.
7. **For VSI.** Use threshold Bayesian search with λ-order fallback in place of the scan. It costs nothing in the worst case and helps a great deal on humans whose bits sit in reused code with visible dispatch. It cannot help on single-use rare insights. Neither can any other protocol of task queries with few verifications; only other signals, such as recovery, pointers or local checks, can.

## 1. Setting and notation

* *From the paper.* H, w, K = log₂(1/w(P)), data D, posterior π_D, decoder G_D, run x′₀…x′_{n−1} with committed labels ℓ_k = G_D(x′_k), and the potential Φ(D) = log₂(W(D)/w(P)) ∈ [0, K]. Lemma bit: a query that lands on a mistake lowers Φ by at least 1. Lemma early: under (A1)–(A3′), every rejected run has a mistake below n₀. For simplicity there are no asks; σ ≥ 0 is allowed.
* *First mistake.* For a hypothesis h, f_h = min{k : h(x′_k) ≠ ℓ_k}. The human's first mistake is f_P.
* *Doubt.* μ_k(D) = π_D(h(x′_k) ≠ ℓ_k). A step is *suspect* if μ_k > 0.
* *(G1), the genericity assumption.*
  * (a) P is drawn from w.
  * (b) Problems and the protocol's choices depend on P only through the transcript τ (answers and verdicts) and independent randomness.
  * (c) The learner conditions on each verdict with its correct likelihood v(h, run). This holds in two cases. In the first, V is a machine and w is supported on *valid* hypotheses, those satisfying (A2)–(A3′) on every problem; then the verdict does not depend on h. In the second, the toy case, V is chain equality and v(h, run) = 1[f_h ≥ n].
* *Location law.* λ(k) = π_τ(f_h = k), for the posterior π_τ given the transcript including the current rejection.
* *Guessing cost.* G(λ) = Σᵢ i·λ₍ᵢ₎, with λ sorted in decreasing order.

**Lemma GB0 (calibration)** [P]. Under (G1), P given τ is distributed as π_τ = w restricted to the hypotheses consistent with τ, normalized. In particular f_P given τ is distributed as λ.

## 2. Bayesian search (Task 1)

**Bayesian search B.** On a rejection, compute λ once and query the steps of supp λ in decreasing λ (ties by step), stopping at the first query that lands on a mistake. Add every answer and rerun. This is the paper's VSI with the scan replaced by B.

**Theorem GB1 (Bayesian search)** [P]. Assume (A1)–(A3′) and the verdict model (G1c).
* (a) *Every path.* The cost is at most rank_λ(f_P) ≤ |supp λ|. Moreover supp λ ⊆ {k < n₀ : μ_k > 0}, so the cost is at most n₀, for every P in the class, not only random ones.
* (b) *Expected cost.* Under (G1), E[cost | τ] ≤ G(λ) ≤ E[f_P + 1 | τ], which is the scan's expected cost. Over the deployment, E[total] ≤ E[Σ_rejections G(λ_r)].
* (c) *Bounds.* With N = |supp λ| ≤ #suspect steps below n₀:
  * G(λ) ≤ (N+1)/2;
  * G(λ) ≤ (Σ_k √λ(k))² = 2^{H½(λ)} ≤ (Σ_k √μ^τ_k)², where μ^τ is the doubt under π_τ;
  * E[log₂ cost | τ] ≤ H(λ).
* (d) *Optimality.* If π_τ-almost surely the run has exactly one mistake, every search of the run's steps, adaptive or randomized, has expected cost at least G(λ). Moreover G(λ) ≥ (1/max λ + 1)/2, and G(λ) ≥ 2^{H(λ)−2} + 1 when H(λ) ≥ 2 (Massey).
* (e) *Interleaving.* Alternating scan and B (S, B, S, B, …, skipping steps already asked) costs at most min{2f_P + 1, 2·rank_λ(f_P)} on every path. That is at most 2n₀ − 1 for every P satisfying (A1)–(A3′), and in expectation at most 2G(λ).

**What a miss buys.** A query at a step that is not a mistake lowers Φ by log₂(1/(1−μ′_k)), where μ′_k is the step's doubt at query time.
* *Exposed search.* The steps tried have substantial doubt, so each miss is paid for in bits and charged to K, like a hit.
* *Diffuse search.* For silent humans, doubt is about η/n at every step, so a miss pays about 0 bits. The queries are not repaid; that is why silence is expensive.

The next theorem makes this an amortized bound with no genericity assumed.

**Threshold Bayesian search B_γ.** Fix γ ∈ (0,1) and query only steps below n₀.
* *Phase 1.* While some unqueried step has current doubt μ′_k(D′) ≥ γ, query one of them (in the toy, the one of largest doubt). D′ is the current data, including this search's misses.
* *Phase 2.* Once none has, query the remaining steps in any order (in the toy, the λ-order recomputed at that moment), until a hit.
* *Diffuse.* A search that reaches phase 2 is *γ-diffuse*. R_γ counts them.

**Theorem GB2 (amortized location)** [P]. Assume (A1)–(A3′) only: no (G1), and any P. Let c_γ = log₂(1/(1−γ)). Then:
* (a) every rejection costs at most n₀ queries;
* (b) total search queries ≤ (1 + 1/c_γ)·K + n₀·R_γ, and R_γ ≤ K/log₂(1/γ);
* (c) hence total ≤ K·(1 + 1/c_γ + n₀/log₂(1/γ)). With γ = log₂n₀/n₀ (n₀ ≥ 4) this is at most K·(1 + n₀ ln2/log₂n₀ + n₀/log₂(n₀/log₂n₀)) = O(n₀K/log n₀).

**Corollary (worst-case optimality)** [P, given Theorem lb-verify]. On the silent class with q ≥ 16/η, Theorem lb-verify gives Ω(nK/log(nq/ε)) for protocols with as few verifications as VSI uses, at any constant ε. So for q = poly(n) and σ = 0, B_γ is optimal up to a constant factor. This tightens the paper's "optimal up to the logarithm" for the scan.

The bound (c) covers the worst case; on typical humans it is loose (1729 against 62 for FV in E1). The informative form is (b): O(K), plus n₀ per diffuse rejection.

## 3. Two random-program models (Task 2)

### 3.1 M1: modular programs with visible dispatch

* *Code.* A fixed set of entries E (subroutine × input; |E| = 48 in the toy). The program is its code c ∈ [q]^E, uniform: K = |E|·log₂q.
* *Steps.* At notebook y, a known dispatch Dep(y) ⊆ E (r = 2 calls in the toy) selects entries, and the step writes (c_e)_{e∈Dep(y)}.
* *Call frequencies* are spread across scales: f_e ∝ 2^{−u_e}, with u_e uniform on [0, 14].
* *Decoder.* It writes a fixed tie-break value for unknown entries.

**Theorem GB3 (modular programs)** [P].
* (a) For **every** program in M1 and every problem sequence, B queries, on each rejection, the run's first calls of unconfirmed entries in run order. Each query reveals at least one entry never revealed before. Total search queries ≤ |E| = K/log₂q.
* (b) Under (G1), E[cost per rejection | τ] ≤ q/(q−1).
* (c) Every suspect step has doubt at least 1 − 1/q ≥ ½. So B_{1/2} never reaches phase 2, and costs at most 2K in all.

*The scan and chained imitation* [S]. Late in learning, the unconfirmed entries are the rarely called ones.
* *The scan.* A rejection caused by an entry called less than once per run puts the first mistake at a roughly uniform step, so the scan pays about n/2 for each such entry.
* *Chained imitation* finds a run's single wrong call with probability 1/n.
* *Numbers* (E1, n = 64) [N]. Scan 25.9 per rejection, Bayesian 1.15. Chained imitation pays 16 queries per hit and outputs 210 wrong runs out of 300.

The K bits of M1 are content, and where each bit is used is visible. So rare use costs rejections but never location, whatever the program.

### 3.2 FV: decision lists over notebook features, branch frequencies across scales

* *Features.* Feature z^{(j)} of a notebook is a j-bit field of its hash, so each value has frequency 2^{−j}. (Idealization (RO): fresh notebooks have independent uniform features.)
* *Rules.* A program is L rules (j_i, v_i, o_i). Rule i writes o_i in its own field if z^{(j_i)} = v_i, and "." otherwise.
* *Prior.* j uniform on 1..d (log-uniform branch frequencies), v uniform, o uniform on [q]. A rule costs log₂d + j + log₂q bits: rarity is paid in bits, so the triggers are incompressible.
* *Posterior.* A product over rules, computed exactly. The toy has d = 14, L = 5, q = 3.

**Theorem GB4 (first discoveries of rare rules)** [P]. Consider a rejection at which rule i has never been seen firing, and every other rule's field is certain on the run. Let U be the set of distinct values of z^{(j_i)} on the run that the data have not excluded.
* (a) Given τ and j_i, v_i is uniform on U. Every search of the run's steps, even one told j_i, has expected cost at least (|U|+1)/2. Bayesian search attains it for a learner told j_i.
* (b) Under (RO), if the learner has seen m contexts at which the rule did not fire, E|U| ≥ n(1 − n/2^{j+1})(1 − 2^{−j})^m.
* (c) [S] At a rule's first firing, (1 − 2^{−j})^m is roughly uniform on (0,1). So a first discovery costs about n/4 when 2^j ≫ n. In E2 it cost 17.6 at n = 64, with G(λ) = 16.7.

*After discovery* [P for the first claim, S for the second]. Every later mistake of rule i is at a step whose doubt is at least π(j_i | data). That posterior grows as frequent candidate features are excluded, so the mistakes of known rules are exposed. In E2 they cost 1.06 queries with Bayesian search and 28.7 with the scan [N].

**Theorem GB5 (two strikes)** [P under (RO), for a learner told j; S otherwise]. In the setting of GB4, suppose the protocol defers a rejected run R₁ instead of searching it, and conditions on its rejection ("v ∈ U(R₁)"). Suppose the same rule later causes the rejection of a run R₂ on another problem.
* Then v ∈ I = U(R₁) ∩ U(R₂).
* E[|I| − 1] ≤ n²/2^j, so searching R₂ costs at most 1 + n²/2^{j+1} in expectation.
* Once v is found, R₁'s problem passes on rerun.
* A rule that fires in only one problem leaves only R₁. Searching it costs (|U|+1)/2, as in GB4.

The price is latency: R₁ waits about 2^j/n problems. In E3 (unknown j) [N], deferral cuts the first-discovery cost of rules that fire in two or more problems:
* j = 8: from 19.2 to 10.6;
* j = 10: from 19.5 to 5.8;
* j = 12: from 21.5 to 4.5;
* j = 14: from 33.5 to 10.8.

Single-shot rules cost 19.6 either way.

**Costs in the two models** (expected search queries; |M| is the number of mistakes in a failed run, R_rare the number of exercised rules with 2^j > n, R_1 the number exercised in one problem only):

| | chained imitation | VSI, scan | VSI, Bayesian | VSI, Bayesian with deferral |
|---|---|---|---|---|
| M1 | ≈ n/|M| per hit, plus the 1/ε | ≈ (n/2)·#rarely called entries | ≤ K/log₂q | same |
| FV | ≈ n/|M| per hit, plus the 1/ε | ≈ n/2 per rejection | ≈ (n/4)·R_rare + O(K) | ≈ (n/4)·R_1 + O(K) |
| silent | Θ(nK/(ε log)) | (n/2) per insight | (n/2) per insight | (n/2) per insight |

The M1 Bayesian entry is [P]. The FV and silent entries are [S], with [N] support from E1–E3.

## 4. Is the silent class generic? (Task 3)

*What makes a branch silent.* Three properties together:
* (i) **rare**: frequency below about 1/n per step, so a run usually contains at most one firing;
* (ii) **incompressible** relative to the learner: its trigger set costs about log(1/frequency) bits, so the posterior spreads its doubt evenly over the run's fresh steps;
* (iii) **single-use**: it fires in only one problem of the deployment, so no second rejection can be intersected with the first.

Compressible rare triggers fail (ii): the universal prior puts more doubt on steps with simple new properties, so Bayesian search tries those first. Branches that fire in two or more problems fail (iii), and GB5 handles them.

**Proposition GB6 (how often generic decision lists have silent rules)** [P formula, N constants]. Under (RO), a rule of rarity j fires in a run of n fresh steps with probability π_j = 1 − (1 − 2^{−j})^n. It fires in exactly one of T problems with probability Tπ_j(1 − π_j)^{T−1}.
* *Log-uniform prior* (j uniform on 1..d, d ≥ log₂(nT) + 6): the expected number of single-use rules is 1.443·L/d, which is L/(d ln 2) [N]. This is a fraction 1/ln(nT) of the exercised rules: 7–12% in E4.
* *Universal-type prior* (P(j) ∝ 1/j²): the fraction is about 0.88/log₂²(nT) per rule [S], 0.2–0.6% of the exercised rules in E4.

**Corollary GB7 (generic location cost)** [S]. Combine GB4–GB6 with Theorem lb-verify. Let K_ex be the bits of the exercised rules. The expected location cost of a generic FV program is:
* with deferral, about 0.7·n·K_ex/log₂²(nT) under the log-uniform prior;
* without deferral, about n·log₂T·K_ex/(2 log₂²(nT));
* under the universal-type prior, about 18 times less.

Every task-only protocol with few verifications pays at least the single-use term. So location for a generic program costs Θ(n·K_ex/log²(nT)): a log factor below the silent worst case, but linear in n. *"Most programs are easy" (O(K) or O(K log n)) is false for location under these natural priors* [S].

At the paper's scale the linear term is small. With n₀ = 20–40 three-month steps and the universal-type prior, it is about 0.01 queries per bit, so the O(1)-per-rejection part dominates; Bayesian search achieves that part when mistakes are exposed. Under the log-uniform prior, at n = 64 and T = 300, it is about 0.2 queries per bit with deferral and about 1.3 without.

**Theorem GB8 (exposure is the right assumption)** [P for (a); (b) and (c) cite GB3, GB5 and Theorem lb-verify].
* (a) *Exposure suffices, on every path.* If at most R rejections are γ-diffuse, VSI with B_γ costs at most (1 + 1/c_γ)·K + n₀·R task queries in all, and at most n₀ per rejection.
* (b) *Program properties that give exposure:*
  * *visible dispatch,* with every unconfirmed piece of code having substantial prior doubt (M1): R = 0;
  * *reuse:* every rare, incompressible behaviour that the deployment exercises is exercised in at least two problems. With deferral, R is then about the number of first strikes that are never intersected: [P] for one rule (GB5), [C] in general.
* (c) *Exposure is necessary.* Each single-use, rare, incompressible behaviour is a hidden insight. Every task-only protocol with fewer than about q/16 verifications per such behaviour pays Ω(n) for it [S, via Theorem lb-verify].

So the assumption to make about the human is not "generic program". It is this: **each bit of the program that the work depends on is used either at steps the learner can flag with non-negligible doubt, or in more than one problem.** Modularity with visible dispatch gives the first; reuse across problems gives the second.

## 5. Simulation (Task 4) [N]

[`threadGB_location.py`](threadGB_location.py) runs exact Bayes on M1, FV and the silent class SIL.
* *Setup.* 12 humans per row, 300 problems each, n ∈ {16, 64}, and a chain-equality verifier.
* *Verdict data.* VSI variants add accepted runs' labels as data, as a calibrated learner must with this verifier.
* *Protocols.* Chained imitation (one uniform query per problem, no verifier), the scan, B, and B_γ with γ = log₂n/n.
* *Statistics.* Recorded before each search; the full set is in the output file.

**E1 (n = 64).** Rejections and queries are per human; the other columns are per rejection. Prior humans unless noted.

| class | protocol | rej | queries | Q/rej (max) | G | suspect | f+1 | rank |
|---|---|---|---|---|---|---|---|---|
| M1 | scan | 31.4 | 813 | 25.9 (64) | 1.14 | 13.7 | 25.9 | 1.1 |
| M1 | Bayesian | 31.4 | 36 | 1.15 (5) | 1.14 | 13.7 | 25.9 | 1.1 |
| M1 | threshold | 28.6 | 31 | 1.08 (3) | 1.14 | 13.2 | 24.0 | 1.2 |
| M1 adversarial | Bayesian | 42.7 | 43 | 1.00 (1) | 1.14 | 12.2 | 26.3 | 1.0 |
| FV | scan | 7.3 | 187 | 25.5 (64) | 9.1 | 52.4 | 25.5 | 8.3 |
| FV | Bayesian | 7.2 | 63 | 8.7 (53) | 9.8 | 54.8 | 24.2 | 8.8 |
| FV | threshold | 7.6 | 62 | 8.2 (53) | 9.8 | 55.2 | 23.8 | 8.6 |
| FV rare-only | scan | 7.8 | 256 | 33.0 (64) | 12.4 | 58.5 | 33.0 | 15.2 |
| FV rare-only | Bayesian | 8.2 | 112 | 13.8 (63) | 12.4 | 59.4 | 31.5 | 15.4 |
| SIL | all three | 147.3 | 4875 | 33.1 (64) | 32.5 | 64 | 33.1 | 33.1 |

* *Chained imitation* (300 queries per human). Wrong outputs per human: M1 210, FV 89, FV rare-only 106, SIL 147. Queries per hit: 16, 64, 144 and 240.
* *At n = 16,* scan against Bayesian: M1 8.0 against 1.11, FV 7.6 against 3.2, SIL 8.65 for both.
* *Calibration (GB1(b)).* Mean Bayesian cost is at most mean G, up to sampling error: 1.15 vs 1.14 for M1, 8.7 vs 9.8 for FV.
* *GB2's worst-case bound* holds with room to spare: at most 95 queries per FV human, against a bound of 1729.
* *E2–E4* (cost by kind of mistake, deferral, prior counts) are quoted in §§3–4.

## 6. Limits and open problems

* *Calibration is an idealization.* Theorems GB1(b) and GB5 use (G1); GB1(a, e), GB2 and GB3(a) do not.
  * A misspecified prior makes λ wrong, but never unsafe: B stays within n₀ and B_γ keeps its pathwise bound.
  * Computing λ needs the first-mistake law over the run. For a Solomonoff-type mixture that is the same simulation the decoder already does, so it adds no new computability issue. It is expensive, but no more so than decoding.
* *The toy verifier is chain equality.* With slack and a real verifier, accepted runs certify less, rejections certify less than "f_P < n", and the verdict likelihood is harder to compute.
* *The models are narrow.* The general reuse theorem (GB8(b), second case) is conjectured. The idealization (RO) treats notebooks as random oracles.
* *Rarity.* Real humans' rare triggers may be compressible: "I notice when two results contradict" is a simple trigger. Such triggers make location cheaper than FV suggests. How much of a real researcher's K is single-use and incompressible is an empirical question. The silent component is exactly what the lower bounds say cannot be located.
* *Deferral costs latency.* A deployed system must decide how long a rejected problem may wait.
* *Open.*
  * A tight lower bound matching Corollary GB7 for general protocols, beyond searches of the run.
  * The trolling half: whether calibration (G1) is consistent with malign hypotheses that are short and backstab. That is the parallel thread.

## 7. Proofs

**Lemma GB0.** Let ω be all randomness independent of P: the protocol's coins and the problem draws. The transcript τ is a function of ω and of P's answers and verdicts. Given ω, the transcript equals τ iff P is consistent with τ. Hence Pr[τ | P = h] = Pr[ω ∈ Ω_τ]·1[h ∼ τ], where Ω_τ, the set of coins that produce τ's queries and problems given τ's answers, does not depend on h. Bayes' rule gives Pr[P = h | τ] ∝ w(h)·1[h ∼ τ]. f_P is a function of P and the run, and the run is a function of τ. ∎

**Theorem GB1.**
* (a) Let σ be the λ-order. The search stops at its first hit, and f_P is a hit, so the cost is at most σ(f_P) if f_P ∈ supp λ. Now λ(f_P) ≥ π_τ(P) > 0, since P ∼ τ and w(P) > 0. For every consistent h:
  * in the toy, f_h < n by the verdict;
  * otherwise h is valid, so Lemma early applied to h gives f_h < n₀;
  * and h(x′_{f_h}) ≠ ℓ_{f_h}, so μ_{f_h} > 0.

  Hence supp λ ⊆ {k < n₀ : μ_k > 0}.
* (b) By Lemma GB0, E[σ(f_P) | τ] = Σ_k λ(k)σ(k) = G(λ). By the rearrangement inequality, G(λ) is the minimum of Σ_k λ(k)π(k) over bijections π from supp λ to {1..N}. Scanning supp λ in step order is one such bijection, with π(f_P) ≤ f_P + 1. Summing over rejections: their number is at most K by Lemma bit, so the tower property applies.
* (c) *First bound.* Sort λ decreasingly as p₁ ≥ … ≥ p_N. The sequences (i) and (p_i) are oppositely ordered, so Chebyshev's sum inequality gives Σ i p_i ≤ (1/N)(Σ i)(Σ p_i) = (N+1)/2.

  *Arikan.* Every k′ ranked at or before k has λ(k′) ≥ λ(k), so σ(k) ≤ Σ_{k′} (λ(k′)/λ(k))^{1/2}. Multiplying by λ(k) and summing gives G ≤ (Σ√λ)². Since λ(k) ≤ π_τ(k ∈ M) = μ^τ_k, the doubt form follows.

  *Logarithm.* The σ(k) largest values are each at least λ(k) and sum to at most 1, so σ(k) ≤ 1/λ(k). Then E[log₂σ(f_P) | τ] ≤ Σ_k λ(k)log₂(1/λ(k)) = H(λ).
* (d) A query at a step that is not a mistake returns ℓ_k, which is determined. If π_τ(|M| = 1) = 1, every observation before the hit is therefore determined. A search, possibly randomized, is a mixture of fixed orders π of the run's steps, each with cost π(f_P), and E[π(f_P)] ≥ G(λ) by (b).

  *The bound (1/max λ + 1)/2.* Write p₁ = max λ, x = 1/p₁ = m + t with m an integer and t ∈ [0,1). Subject to p_i ≤ p₁, Σ i p_i is smallest when the first m ranks get p₁ and rank m+1 gets tp₁. That minimum is (m(m+1)/2 + t(m+1))/x, and it is at least (x+1)/2 iff 2t ≥ t² + t, which holds.

  *Massey's bound* is Massey (1994, ISIT), "Guessing and entropy".
* (e) With S at odd and B at even queries, and steps already asked skipped without using a turn, the scan's (f_P+1)-th step is at query at most 2f_P + 1. B's σ(f_P)-th step is at query at most 2σ(f_P). Lemma early gives f_P ≤ n₀ − 1 for every P satisfying (A1)–(A3′). ∎

**Theorem GB2.**
* *Setup.* Index searches by s. Let D_s be the data at the start of search s. Let m_s be its phase-1 misses, and T_s = Φ(D_s) − Φ(D_s ∪ answers of s).
* *Disjointness.* Φ never increases. Data added between searches (verdict data, other searches) only lower it. So Σ_s T_s ≤ Φ(start) ≤ K.
* *Three facts.*
  * (i) A phase-1 miss at step k, with current data D′ and μ′_k ≥ γ, returns ℓ_k. Its current mass is 1 − μ′_k ≤ 1 − γ, so it lowers Φ by at least c_γ.
  * (ii) The hit at step k satisfies P(x′_k) ≠ ℓ_k = G_{D_s}(x′_k). By Lemma bit, Φ(D_s) − Φ(D_s ∪ {hit}) ≥ 1. Since W is monotone in the data, T_s ≥ 1.
  * (iii) In a γ-diffuse search, let D″ be the data when phase 2 starts. Every unqueried step then has μ′ < γ, including the eventual hit k. So ξ_{D″}(P(x′_k) | x′_k) ≤ μ′_k(D″) < γ, and by monotonicity again the drop from D″ to the end of the search is more than log₂(1/γ).
* *Phase-1 searches.* A search that ends in phase 1 costs m_s + 1. By (i) and (ii), T_s ≥ max(1, m_s c_γ), so m_s + 1 ≤ T_s(1 + 1/c_γ).
* *Diffuse searches.* A γ-diffuse search queries distinct steps below n₀, so it costs at most n₀. Also m_s ≤ T_s/c_γ, and T_s ≥ log₂(1/γ) by (iii). Hence R_γ log₂(1/γ) ≤ K.
* *Totals.* Summing: total ≤ (1 + 1/c_γ)Σ_s T_s + n₀R_γ ≤ (1 + 1/c_γ)K + n₀R_γ. For (c), bound each search by T_s(1 + 1/c_γ + n₀/log₂(1/γ)) and sum.
* *Every rejection ends in a hit,* within n₀ queries. Lemma early puts f_P < n₀, and phase 2 covers every unqueried step below n₀.
* *The choice of γ.* For γ = log₂n₀/n₀, c_γ ≥ γ log₂e, so 1/c_γ ≤ n₀ ln2/log₂n₀.

*Corollary.* VSI with B_γ uses one verification per run, and a rejected insight problem is rerun once after its hit. So it uses O(1) verifications per insight problem, fewer than q/16 when q ≥ 16/η, and reaches output failure 0 ≤ ε. Theorem lb-verify then gives Ω(nK/log(nq/ε)), which is Ω(nK/log n) for q = poly(n) and constant ε. ∎

**Theorem GB3.**
* *Posterior.* The prior is a product over entries. Each answer reveals the values of the entries of one Dep(y). So the posterior is a product, with every unrevealed entry uniform and independent of the data.
* *First calls.* In a run, let k₁ < k₂ < … be the steps that call some unrevealed entry for the first time in the run, and New_i the set of such entries at k_i.
* *First mistake.* A hypothesis's first mistake is at k_i for the least i such that New_i contains an entry whose value differs from the tie-break. Revealed entries are decoded correctly. Unrevealed entries called after their first call repeat a guess that, by minimality, was right.
* *Location law.* So λ(k_i) ∝ Π_{i′<i} q^{−|New_{i′}|}·(1 − q^{−|New_i|}). The ratio λ(k_{i+1})/λ(k_i) = q^{−|New_i|}(1 − q^{−|New_{i+1}|})/(1 − q^{−|New_i|}) ≤ q^{−1}/(1 − q^{−1}) ≤ 1. The λ-order is therefore k₁, k₂, … in run order, whatever P's code. (For q = 2, ties are broken by step.)
* (a) The query at k_i reveals New_i. New_i was unrevealed when the run was made, and the search's earlier queries were at k₁ … k_{i−1} < k_i, which do not call New_i. So every query reveals a new entry, and entries stay revealed. Total ≤ |E|. This uses no property of P's code.
* (b) Given τ and the rejection, the index of the first hit is a geometric variable truncated at the number of indices. Its success probability per index is 1 − q^{−|New_i|} ≥ 1 − 1/q. Truncation lowers the mean, so E ≤ q/(q−1).
* (c) A step's doubt relative to the run's labels is 1 − q^{−u}, where u is the number of unrevealed entries it calls, and this is at least 1 − 1/q whenever u ≥ 1.

  *f_P stays above γ.* Let e be the entry whose wrong guess makes f_P a mistake. A phase-1 miss at another step that calls e would return c_e equal to the guess, which is false. So e stays unrevealed, and f_P's doubt stays at least ½ throughout the search. Phase 2 is never reached.

  *Total.* Theorem GB2(b) with R = 0 gives at most (1 + 1/c_{1/2})K = 2K. ∎

**Theorem GB4.**
* (a) *Posterior on v.* Other rules are certain on the run, so the rejection means that rule i fires at some step. Given j, the prior on v is uniform, and the data exclude exactly the values at which the rule was seen not firing. So v given τ is uniform on the unexcluded values. Conditioning on the rejection restricts it to U.

  *Search cost.* A query at step k reveals only whether z_k^{(j)} = v, beyond things already certain. Steps sharing a value give the same answer. A search is therefore a guessing strategy for a uniform element of U, with expected cost at least (|U|+1)/2. Bayesian search for a learner told j guesses each first occurrence once, in any order, and so attains it.

  *A learner not told j* cannot do better: the informed learner can run its strategy.
* (b) Under (RO), each of the run's n values is unexcluded with probability (1 − 2^{−j})^m. The probability that it repeats an earlier value of the run is at most n/2^{j+1} on average.
* (c) [S] The rule fires at each observed context with probability 2^{−j}. So the index M of its first firing is geometric, and M/2^j is about Exp(1). If X ~ Exp(1), then e^{−X} is uniform on (0,1). The caveats: contexts in rejected runs that are never queried are not observed, so this overstates exclusions slightly, and the learner's j is unknown.

*After discovery.* Let z* be the firing context. The candidates are the features j′ whose value z*^{(j′)} has not been excluded, with posterior ∝ 2^{−j′}.
* *A commission* (predicted to fire, does not fire) has doubt 1 − p_fire ≥ π(j_i), because j_i does not match there.
* *An omission* (fires, predicted not to) has doubt p_fire ≥ π(j_i), because j_i matches.

∎

**Theorem GB5** (learner told j; (RO)).
* *The intersection.* After R₁'s rejection is conditioned on, v is uniform on U(R₁) minus the excluded values. R₂ is rejected iff v ∈ U(R₂), so afterwards v is uniform on I.
* *Its size.* Given that R₂ contains v, the other at most n − 1 values of R₂ are independent and uniform up to the conditioning. The conditioning only raises the chance of repeating v. Each falls in the at most n values of U(R₁) with probability at most n/2^j. So E[|I| − 1] ≤ n²/2^j.
* *Cost.* The search of R₂ is a guess among I, with expected cost at most (E|I| + 1)/2 ≤ 1 + n²/2^{j+1}.
* *R₁ passes.* After the hit, (j, v, o) is known, so R₁'s problem is decoded correctly on rerun. Other rules are certain, so the rerun matches the human's chain.

*Unknown j* [S]. The posterior is a mixture over j. Frequent features (2^{j′} ≲ the number of contexts seen) are excluded by accepted runs. Rarer ones contribute coincidences at rate n²/2^{j′}. E3 measures the net effect. ∎

**Proposition GB6 and Corollary GB7** [S beyond the formula].
* *Single-use rules.* With Λ_j = Tπ_j ≈ nT2^{−j}, the expected number of single-use rules per rule is (1/d)Σ_j Λ_j e^{−Λ_j}, up to binomial corrections. Over a geometric lattice, Σ_j Λ_j e^{−Λ_j} ≈ ∫ Λe^{−Λ} d(log₂Λ) = 1/ln2. The lattice oscillation is below 10⁻⁴; E4 gives 1.444 at d = 40.
* *Exercised rules.* Σ_j (1 − e^{−Λ_j}) ≈ log₂(nT) + O(1), so the single-use fraction of exercised rules is ≈ 1/(ln2·log₂(nT)) = 1/ln(nT).
* *Universal-type prior.* With weights 1/j², normalized by 6/π², the single-use rate is ≈ (6/π²)(1/ln2)/log₂²(nT).
* *Cost per exercised bit.* Exercised rules carry ≈ log₂(nT)/2 bits each under the log-uniform prior. Single-use ones cost ≈ n/4 to n/3 each (GB4(c); 19.6 at n = 64 in E3), and the rest O(1) (GB4, GB5). That gives ≈ (n/4)(1.44/d)/((log₂(nT)/d)(log₂(nT)/2)) ≈ 0.72·n/log₂²(nT) per exercised bit.

  Without deferral, every rare exercised rule pays n/4. Their number per rule is ≈ log₂T/d, giving ≈ n·log₂T/(2 log₂²(nT)).

  Under the universal-type prior, exercised rules have j = O(1) and ≈ 6 bits each. The single-use rate 0.88/log₂²(nT) then gives ≈ 0.04·n/log₂²(nT) per bit.
* *Lower bound.* For general protocols, each single-use rule is an instance of the hidden-insight class: a uniform location among about n fresh steps, an unknown value in [q], and no recurrence. The proof of Theorem lb-verify applies to it, per rule. ∎
