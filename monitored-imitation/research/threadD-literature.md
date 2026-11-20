# Thread D: literature, and mechanisms not yet in the notes

*Research note for the monitored-imitation project (Claude, 20 November 2026). Draft, not refereed.*

**Sources.** The network was available. For Foster, Block and Misra (2024), Cohen, Hutter and Nanda (2022) and Brown-Cohen, Irving and Piliouras (2024) I read the theorem statements in the papers. For Spencer et al. (2020), Bi et al. (2020), ThriftyDAgger, RLIF, Sekhari et al. (2023), Jia, Rakhlin and Xie (2025), Botta et al. (2025) and prover–estimator debate (2025) I checked the abstracts. Everything else is from memory and marked †. "Ours" below means the projects' setting: a deterministic human P, runs of n steps, a Bayes or Solomonoff majority decoder, expensive task queries, complexity K = K(P).

## Summary

1. **One frame covers almost everything: point queries versus threshold or group queries (Section 1).** Finding one silent defect among n steps takes Θ(n) *point* queries ("is the defect exactly here?"). It takes ⌈log₂ n⌉ *threshold* queries ("has it happened by step j?") or *group* queries ("is it in this set?").
   * Asked for a task step, a silent human gives a point query. Theorem 3 of `note.md` is the point-query lower bound.
   * Every escape, in the notes and in the literature, gets threshold or group structure from somewhere:
     * a preserved check (threshold);
     * a batch look (group);
     * persistence (threshold, through repair);
     * hybrid membership queries (threshold, but each costs a human run);
     * an honest party that holds the computation (debate, refereed games);
     * white-box algebraic structure (interactive proofs).
2. **No surveyed result gives an n-free, poly(K) bound on task queries without some human judgment of states.**
   * *Exponential in K.* KWIK, and Cohen–Hutter–Nanda: never wrong, about |A|·2^{4K} queries for a deterministic human.
   * *Horizon-free in whole trajectories, which is n·K/ε labels.* Foster–Block–Misra. Their lower bound says online access does not help in general.
   * *Debate.* Needs an honest party that can already predict the human.
   * *Recoverability.* Gets past the factor n only under persistence-type assumptions.
3. **Four candidate schemes (Section 3), ranked by how sure I am that they work for careful researchers:**
   * **(A) Endorsed logs.** The check is "would I endorse each entry as a step from what preceded it". Preservation becomes the near-tautology "the human endorses its own steps". The outcome condition becomes a condition on the human alone.
   * **(B) Detect at the end, repair near the end.** An outcome check plus persistence (C_r) gives r·K task queries, with no preservation and no 1/ε.
   * **(C) The human as equivalence oracle.** At most K counterexamples, n-free, if the human can find where the imitator lacks its self-known knowledge.
   * **(D) Position-aware chained imitation.** q ∝ √π replaces n by the Rényi-½ effective number of positions (Σ√π)², optimal up to a factor O(log n) for finding every insight. It is never worse than twice chained imitation's guarantee.

## 1. The frame: point, threshold and group queries

**Observation (sketch).** Take Theorem 3's hidden-insight class. Call a query a *point query* if, at every state (p, j, ⊥) of the decoder's runs, its answer depends on θ only through 1[t_p = j] (and on k_p when t_p = j).
* *The bound.* Theorem 3's bound holds for any protocol that uses Q point queries of any kinds, counting all of them. The proof is the same: each point query hits with probability at most 2η/n.
* *Point queries.* Task queries to silent humans are point queries, and so is the endorsement of a single transition (Scheme A).
* *Threshold queries.* A query whose answer depends on 1[t_p < j] allows binary search with ⌈log₂ n⌉ queries per insight. A preserved check is one (the note's V), and so is a catch-up human's step.
* *Group queries.* So does a query whose answer depends on 1[t_p ∈ S] for a set S: batch checks, batch endorsements, batch "turning-point" flags.
* *What follows.* An n-free protocol for silent humans needs a human answer that reveals *whether the human's contribution should already have happened*. Absence has to be visible to someone who knows what should be there. The same frame classifies the literature below.

## 2. The literature, translated

### 2.1 Interactive imitation and horizon

* **DAgger** (Ross, Gordon and Bagnell 2011†).
  * *What it proves.* No-regret learning on the induced distribution gives J(π̂) ≤ J(π*) + u·T·ε_N plus lower-order terms. Here u bounds how much one deviation can raise the expert's cost-to-go.
  * *Ours.* Chained imitation is DAgger with a Bayes mixture, and Proposition 2 (n·K/ε) is its run-level form. For 0/1 success u = 1, so the factor T = n stays.
  * *Earlier work.* Ross and Bagnell (2010†) give BC's T²ε and forward training's Tε.
* **AggreVaTe** (Ross and Bagnell 2014†) and **AggreVaTeD** (Sun et al. 2017†).
  * *What they prove.* The learner minimizes the expert's cost-to-go Q* on its own distribution. AggreVaTeD shows an exponential sample gap over pure RL.
  * *Ours.* This needs the human's value at imitator states: a rollout of up to n task queries, or a judgment, which is the "on track" check of `note.md` §7. It evaluates states.
  * *What theory shows.* Foster et al. (§4.3) note that existing theory shows value feedback to be no worse than DAgger. They prove gains only for representational reasons.
* **Recoverability.**
  * *Definition.* Foster et al.'s Definition 1.1 is μ = max (Q*(x, π*(x)) − Q*(x, a))₊. DAgger then gets μ·H·log|Π|/n.
  * *Known gaps.* Rajaraman et al. (2020†, 2021†) prove a μH versus H² gap for non-stationary tabular policies, as summarized by Foster et al.
  * *Ours.* μ is the largest drop in the human's success probability from one wrong step. It is 1 for 0/1 success unless the human recovers from *any* single deviation.
  * *Persistence.* A time-dependent version, μ_k = 0 for k < n − r, is the learner-free sufficient condition for `without-a-check.md`'s (C_r). The performance-difference lemma then charges only the last r steps, which is that note's Theorem 3(b).
* **Foster, Block and Misra (2024), "Is Behavior Cloning All You Need? Understanding Horizon in Imitation Learning"** (NeurIPS 2024). Read.
  * *Theorem 2.1.* For a deterministic expert, J(π*) − J(π̂) ≤ 4R·D²_H(P^π̂, P^π*).
  * *Corollary 2.1.* LogLossBC gets 8R·log(2|Π|/δ)/n with probability 1 − δ, where n is the number of expert *trajectories*, each annotated at every step.
  * *Theorem 2.2.* With dense rewards, every online or offline algorithm has regret Ω(H/n), even with |Π| = 2 and known stationary dynamics.
  * *Proposition 2.2.* Online access helps only for classes without parameter sharing, where it replaces R by μ.
  * *Ours.* R = 1 and log|Π| ↔ K, so they need K/ε human runs, which is n·K/ε task queries. That is chained imitation's count, or check-and-scan's n·K with a check.
  * *What it does not contradict.* The horizon-independence is per trajectory, not per label, so it does not contradict the factor n. Theorem 3 is the label-level counterpart of their "online does not help" result.
* **Sekhari, Sridharan, Sun and Wu (2023), "Selective Sampling and Imitation Learning via Online Regression"** (NeurIPS 2023).
  * *What it proves.* Query complexity scales with the eluder dimension and with how often the expert visits low-margin states.
  * *Ours.* The query rule is the learner's own uncertainty, which is blind to confident mistakes. The hidden-insight class has eluder dimension about n·m, by my count.
* **Judah, Fern, Dietterich and Tadepalli (2014)**† (JMLR). They reduce active imitation to i.i.d. active learning. The savings come from a version-space query rule, which on the hard class is uncertainty sampling.

### 2.2 Interventions and corrections

* **HG-DAgger** (Kelly et al. 2019†).
  * *What it does.* The expert watches and takes over when the run looks unsafe.
  * *Ours.* Watching is a check at every step, n looks per run. The takeover is a flip of the human's judgment.
  * *Relation to MB.* MB is HG-DAgger with bisection in place of watching. Bisection needs preservation.
* **Spencer et al. (2020), "Learning from Interventions: Human-robot interaction as both explicit and implicit feedback"** (RSS).
  * *What it does.* Expert Intervention Learning treats non-intervention as "good enough" and intervention as "bad state". These become constraints on the learner's value, learned online.
  * *Ours.* The implicit part is exactly a check verdict on the visited states. It is still a state evaluation.
* **Bi, Dhiman, Xiao and Xu (2020), "Learning from Interventions using Hierarchical Policies for Safe Learning"** (AAAI).
  * *What it does.* The human reacts late, so the error precedes the takeover. They propagate labels backwards and use sub-goals.
  * *Ours.* This is the gap between detection and culprit: (C_r)'s r, or a check's lag. Bisection on a preserved check finds the culprit exactly; their heuristic approximates it.
* **ThriftyDAgger** (Hoque et al., CoRL 2021).
  * *What it does.* It asks for help on novelty (out of distribution) or risk (a learned estimate of success), with thresholds set by a target rate.
  * *Ours.* Novelty cannot fire at a first mistake, because the first mistake is on the human's own distribution. Learned risk is a learned monitor (`note.md`, open problem 3).
* **RLIF** (Luo, Dong, Zhai, Ma and Levine, ICLR 2024). It uses the intervention event as a reward for RL. That optimizes against the human's judgment, which MB deliberately avoids (`note.md` §6.3). Its aim is improvement, not imitation.

### 2.3 Process versus outcome supervision

* **Uesato et al. (2022)**†.
  * *Finding.* Outcome-based and process-based feedback give similar final-answer error. Process supervision is needed for low error in the reasoning trace.
  * *Ours.* This is `robust-runs.md`'s point: runs with the right outcome and a wrong process.
* **Lightman et al. (2023), "Let's Verify Step by Step"**†.
  * *Finding.* Process reward models beat outcome reward models for best-of-N on MATH.
  * *Ours.* Every step is labelled, n looks per solution, and outputs are *selected*, which brings the Goodhart risk of `note.md` §6.3.
* **Jia, Rakhlin and Xie (2025), "Do We Need to Verify Step by Step?"** (ICML).
  * *What it proves.* Under coverage, outcome supervision is no harder statistically than process supervision, up to polynomial factors in the horizon. Any policy's advantage function is an optimal process reward model.
  * *Ours.* This is about statistical efficiency, not about locating errors. The human's advantage at imitator states needs rollouts or a value judgment.
* **Botta et al. (2025), "On the Query Complexity of Verifier-Assisted Language Generation"** (ICML).
  * *What it proves.* Without a process verifier, simple constrained generation can be intractable. A good prefix verifier makes it tractable, by tokenwise rejection with backtracking.
  * *Ours.* This is the point/threshold dichotomy on the generation side: a prefix verifier is a threshold query.

### 2.4 Debate and recursive oversight

* **Irving, Christiano and Amodei (2018)**†. Two debaters, and a judge who inspects one step.
* **Brown-Cohen, Irving and Piliouras (2024), "Scalable AI Safety via Doubly-Efficient Debate"** (ICML). Read.
  * *The provers.* Both provers run in polynomial time and have oracle access to human judgment O. That stands for the human judgment already in pretrained models.
  * *The verifier.* It makes O(1) queries to O (Theorems 5.1 and 5.3). Bisection on configurations bottoms out in one transition.
  * *Stochastic oracles.* These need a K-Lipschitz machine and cost O(K²) queries (Theorem 6.2).
  * *Ours.* P's run is the computation, with the human as the oracle at every step. The honest prover must answer those queries correctly, so it must already predict the human. Debate verifies a claimed run cheaply; it does not create the predictor.
  * *Lipschitz and robustness.* Their Lipschitz constant is `robust-runs.md`'s robustness: a run decided by one step has K of order n.
* **Obfuscated arguments** (Barnes and Christiano 2020†). A flaw that neither debater can locate is the analogue of omission.
* **Prover–estimator debate** (Brown-Cohen, Irving and Piliouras 2025). It needs a stability assumption, which is again a robustness condition.
* **Amplification** (Christiano, Shlegeris and Amodei 2018)†. The amplified overseer shares the model's blind spots (`note.md`, open problem 2).

### 2.5 Checking, self-correction, proofs

* **Blum and Kannan (1989/1995), "Designing programs that check their work"**†.
  * *What it gives.* A checker uses the program itself as an oracle. Checkers exist for functions with function-restricted interactive proofs.
  * *Ours.* The function, the run's outcome, is a black box, and the only reference is P, so checking means task queries. For silent humans Theorem 3 says that costs about n per run.
* **Blum, Luby and Rubinfeld (1990/1993), self-testing and correcting**†, and **Lipton (1991)**†.
  * *What they give.* For a random self-reducible f, a program right on most random inputs can be corrected everywhere with O(1) calls.
  * *Ours.* That needs the human's step at an insight state to be computable from its behaviour on typical states, which is "shared knowledge" and is excluded by the hard class.
  * *A weak analogue.* Invariances, such as paraphrased scaffolds, expose errors that are random across framings. Omissions from missing knowledge are invariant across framings and stay hidden.
* **Interactive proofs**† (Goldwasser, Micali and Rackoff 1985/1989; Lund, Fortnow, Karloff and Nisan 1992; Shamir 1992; Goldwasser, Kalai and Rothblum 2008/2015; Reingold, Rothblum and Rothblum 2016).
  * *How they do it.* Succinct verification exploits white-box algebraic structure: each query to a low-degree extension depends on every step.
  * *Ours.* A black-box step function has no such global queries. Brown-Cohen et al. note that RRR does not apply with black-box oracles.
* **Refereed delegation**† (Feige and Kilian 1997, "Making games short"; Canetti, Riva and Rothblum 2011/2013), and the bisection games of optimistic rollups† (TrueBit, 2017; Arbitrum, Kalodner et al. 2018).
  * *What they give.* With two servers, one honest, bisection on their disagreement plus one step check costs O(log T).
  * *Ours.* The honest server would be the human, and holding its run costs n task queries. A preserved check is a *lazy honest server*: it bisects without holding the run.
* **Proofs of sequential work**† (Mahmoody, Moran and Vadhan 2013; Cohen and Pietrzak 2018).
  * *What they give.* With black-box steps, spot checks certify only that most steps were done right.
  * *Ours.* That is `robust-runs.md` Theorem 1 (counting properties are cheap) together with Theorem 3 (single bad steps are not).

### 2.6 Knowing what you don't know

* **KWIK** (Li, Littman and Walsh 2008†).
  * *What it requires.* The learner abstains whenever the label is undetermined, which takes |H| − 1 abstentions for general finite classes.
  * *Ours.* On the hard class every unprobed step is undetermined, so it abstains everywhere: the cheating protocol.
* **Mistakes for abstentions** (Sayedi, Zadimoghaddam and Blum 2010†). They trade abstentions for k mistakes. The mistakes allowed are the confident omissions we care about.
* **Selective classification and PQ learning** (El-Yaniv and Wiener 2010†; Goldwasser, Kalai, Kalai and Montasser 2020†). They abstain on test points unlike the training data. In our setting there is no shift before the first mistake, so they cannot fire there.
* **Cohen, Hutter and Nanda (2022), "Fully General Online Imitation Learning"** (JMLR 23(334)). Read.
  * *The imitator.* Each action gets the minimum probability over the top-α models, and the imitator queries with the remaining probability.
  * *Theorem 1.* E Σ_t θ_q³ ≤ |A|·α⁻³·(24·w(π^d)⁻¹ + 12), with α < w(π^d). The authors call this effectively quartic in w(π^d)⁻¹.
  * *Theorem 5.* Events unlikely under the demonstrator stay unlikely under the imitator.
  * *Ours.* With deterministic hypotheses θ_q ∈ {0, 1}. So on the high-probability event no step differs from the human's, and the imitator makes about |A|·2^{4K} queries. That is n-free but exponential in K, and linear in the number |A| of possible three-month outputs.
  * *On the hard class.* It queries every unprobed step.
  * *Stochastic humans.* Its Theorem 5 is the right safety notion for them (`note.md`, open problem 1).

### 2.7 Exact learning and teaching

* **Angluin (1987, 1988)**† and **Littlestone (1988)**†. Membership and equivalence queries. Halving gives log₂|H| counterexamples, which is the note's Lemma 1.
* **Rivest and Schapire (1993)**†.
  * *What they do.* They find a counterexample's breakpoint by binary search over hybrids.
  * *Ours.* A hybrid membership query is the human's run from a midpoint, up to n task queries, so this costs Θ(n) per counterexample: check-and-scan.
  * *Cheaper hybrids.* A preserved check replaces the hybrid query by a look (MB). Persistence shortens it to r human steps (Scheme B).
* **Teaching** (Goldman and Kearns 1995†; Zhu 2015†). For the halving learner, any counterexample teaches at least one bit (Scheme C).

**Bottom line.** Nothing above gives an n-free, poly(K) bound without the human evaluating states, except under assumptions that exclude silent, rare insights at unpredictable steps:
* recoverability or persistence;
* random self-reducibility, which is shared knowledge;
* an honest strong predictor.

That agrees with Theorem 3 and with `without-a-check.md` §5.

## 3. Candidate schemes

### (A) Endorsed logs: a check whose preservation is automatic

*Status: sharpens MB (`note.md` §5) and its "looks right" monitor (§7). The proof is immediate from Theorems 6 and 7.*

* **States and endorsement.** States are append-only logs. E(x, y) ∈ {0, 1}: "y is an entry I would endorse as a step from x". That means careful and honest, nothing I object to, and, in the stricter version, nothing I would have contributed here is missing.
* **(E1) Self-endorsement.** E(x, P(x)) = 1 for every x reachable from a start state by endorsed transitions.
* **(E2) Batching.** The verdict on a set of transitions is their AND.
* **Success.** Every transition of the run is endorsed.
* **Protocol.** MB with the check V(x) = "every entry of log x is endorsed", bisecting on prefixes.
* **Why it works.**
  * V satisfies (M1), and (M2) for V on states with V = 1 is exactly (E1). So Theorems 6 and 7 hold verbatim: at most K task queries, at most K failed runs, ⌈log₂ n⌉ + 1 batch looks per failure, and the frozen version as before.
  * The culprit k has E(x′_k, x′_{k+1}) = 0, while E(x′_k, P(x′_k)) = 1.
* **What is new.**
  * Preservation becomes "the human endorses its own steps". This is local, involves no forecasting, and is needed only on endorsed-reachable states, not on all states.
  * The protocol itself restricts the imitator's replacements to endorsed ones. So the outcome condition becomes **(E3)**: every fully endorsed run from a start state ends in an outcome the human accepts. That is a condition on the human alone, which `robust-runs.md` §3 could not find against arbitrary replacements.
  * A transition judgment can see an omission *at that step* ("you skipped what I would have done here"), which a state-level "looks right" cannot. That this is easier for real people is plausible, but not shown.
* **Failure modes.**
  * *A lenient E* makes (E3) false: endorsed runs that lack the insight. Endorsing single transitions is a point query, so the log n comes only from (E2).
  * *A strict E* ("exactly what I would write") costs a task step per look.
  * *Self-rejection.* The human may reject its own step on rereading. Proposition 9's accounting then gives marked outputs.

### (B) Detect at the end, repair near the end

*Status: combines check-and-scan (`note.md` Proposition 8) with persistence (`without-a-check.md` Lemma 2). Neither note states the combination. Two-line proof.*

* **(S) Outcome check.** V_fin, which judges final outcomes only, passes on the human's runs.
* **(C_r^E) Repair.** For every imitator run all of whose steps are endorsed (or for every run, if Scheme A is not used), the human's own last r steps from the imitator's state at n − r give an outcome that passes V_fin.
* **Protocol.**
  1. Optionally apply (A) first.
  2. Check the outcome.
  3. On failure, task-query x′_{n−r}, x′_{n−r+1}, …, holding the decoder fixed, until the first k with P(x′_k) ≠ x′_{k+1}. Add that answer first, then the others.
  4. Rerun.
* **Guarantee.**
  * No run that fails V_fin is ever output, and at most K runs fail. By `without-a-check.md` Lemma 2, with success meaning that V_fin passes, a mistake lies in the window; the first answer added lands on a mistake of the current decoder (Lemma 1).
  * Task queries number at most r·K. If the mistakes in the window form an up-set (`without-a-check.md` Proposition 4), they number at most K(1 + ⌈log₂ r⌉).
  * The frozen version takes O(K log(K/δ)/ε) outcome looks.
* **Compared with the other protocols:**
  * check-and-scan: n·K;
  * end-weighting: 2r·H_n·K/ε;
  * last step only, under (C₁): K/ε;
  * MB: K, under preservation.

  Detection and localization are separated. Neither needs a judgment of intermediate states.
* **Why (C_r) might hold.**
  * In the model the human has no memory outside the state.
  * At the first mistake the state is the human's own (first divergence), so whatever triggered the omitted contribution is in it. With append-only logs it stays in every later state.
  * Silence then means ignoring a trigger the human would have acted on had it been the latest entry.
  * So (C_r) follows from three things:
    * triggers do not expire;
    * the downstream work that depends on the omitted contribution fits in r steps;
    * later entries do not mislead, which is what (A) is for.
* **Failure modes.**
  * A decisive early insight whose consequences take most of the project needs r of order n. The cost then degrades towards check-and-scan's n·K, and no further.
  * Outcome checks of research are slow and imperfect.
  * r can be measured with planted-deficit studies (`without-a-check.md`, open problem 3).

### (C) The human as equivalence oracle

*Status: new to the notes. The bound is the halving argument.*

* **Query.** The human gets the current imitator as a tool. It returns "none found", or a state x on a run it considers typical, with P(x) ≠ G(x), together with P(x).
* **Assumption (T_{ε,c}).** If the frozen imitator fails on at least an ε fraction of problems, the human finds a counterexample at cost at most c, in task-step units.
* **Guarantee.**
  * Every counterexample is a decoder mistake, so there are at most K in total (Lemma 1; Angluin, Littlestone). That means at most K + 1 requests.
  * The human's total effort is at most (K+1)(c+1), and the output fails with probability below ε.
  * n, T and ε enter only through c.
* **Where it is plausible.** Special knowledge that is declarative and known to the human: methods, unpublished results, standards. The human can probe the imitator directly: "how would you do X?".
* **Failure modes.**
  * The hard class's knowledge is not self-known: P has no access to (t_p, k_p) without doing the work. Then c is about the cost of running itself.
  * Probing states the runs never reach spends K on irrelevant behaviour (`note.md` §4.1).
* **Best use.** A cheap first phase that pays down the self-known part of K before (A) and (B).

### (D) Position-aware chained imitation

*Status: sharpens end-weighting (`without-a-check.md` §3) and its "predictable steps". Exact for fixed q; the adaptive lower bound is a sketch.*

* **Assumption.** The steps at which the human's rare contributions occur follow a position law π, shared across problems. π may depend on observable features of a state, such as phase markers, or turning points the human flags on its *own* runs.
* **Protocol.** One task query per run, at a step drawn from q = ½·uniform + ½·√π̂ / Σ√π̂. Estimate π̂ from the positions of the mistakes found, weighted by 1/q, or from turning-point flags.
* **Guarantee.**
  * *Always:* q ≥ 1/(2n), so by `without-a-check.md` Theorem 1 the guarantee is at most twice chained imitation's.
  * *On the hidden-insight class with t_p ~ π:* the expected number of failed runs per insight is Σ_k π_k/q_k ≤ 2·min{n, (Σ_k √π_k)²}. Among fixed q, √π is optimal by Cauchy–Schwarz.
  * *Adaptive protocols:* an adaptive scan needs the guessing number, whose expectation is at least (Σ√π)²/(1 + ln n) (Arikan 1996, with ρ = 1). So, for finding every insight, no task-only protocol beats √π-weighting by more than a factor 2(1 + ln n).
  * *For an ε target,* quantiles of π matter instead.
  * *Theorem 3* is the uniform case, where (Σ√π)² = n.
* **Failure modes.**
  * If insights come at unpredictable times, π is near uniform and nothing is gained.
  * If π is supported on a fraction f of steps, the gain is only the factor f.
  * Only a sharply concentrated π removes the factor n.
* **Turning-point flags as group tests.** "Would your next step at any of these states bring in something you rarely use?" is an OR query, so it localizes with log n looks. But the flags concern input states only. Without an endorsement, the learner cannot tell a flagged step it already knows from one it does not, and the cost grows with the number of flagged steps met. Use the flags as π̂ here, or to restrict (A)'s looks.

## 4. Ranking

| rank | scheme | what it delivers | what it assumes about the human | how sure for careful researchers |
|---|---|---|---|---|
| 1 | (A) endorsed logs | at most K task queries; no unendorsed step is ever output; outcomes only through (E3) | self-endorsement and AND-batching | high for the process guarantee; low to moderate for outcomes, because omissions pass a lenient E |
| 2 | (B) detect at the end, repair near the end | outcome-level runs with at most r·K task queries (K·log r with an up-set) | an outcome check, and repair within r steps | moderate: r is unknown but measurable; degrades to n·K |
| 3 | (C) equivalence oracle | at most K counterexamples, n-free | special knowledge the human knows it has | moderate as a complement; low as a solution, because insights arise in the work |
| 4 | (D) √π weighting | at most twice chained imitation always; (Σ√π)² instead of n | predictable positions of insights | sure it is safe; low that it gains more than constants |

**Recommendation.** Combine (A) and (B): endorse every step, detect at the end, repair near the end. It needs no preservation of state judgments.
* Then test on two things:
  * E3's class with an endorsement that sees only commissions, plus catch-up with lag r, to see the cost move between K and n·K;
  * a planted-deficit study that measures r.
* The Observation of Section 1 is cheap to state as a theorem, and would make precise the claim that an n-free protocol for silent humans needs a human signal of absence.

## References

* Angluin, D. (1987). Learning regular sets from queries and counterexamples. *Inform. Comput.* 75.
* Angluin, D. (1988). Queries and concept learning. *Mach. Learn.* 2.
* Arikan, E. (1996). An inequality on guessing and its application to sequential decoding. *IEEE Trans. Inf. Theory* 42(1).
* Barnes, B. and Christiano, P. (2020). Debate update: obfuscated arguments problem. AI Alignment Forum.
* Bi, J., Dhiman, V., Xiao, T. and Xu, C. (2020). Learning from interventions using hierarchical policies for safe learning. AAAI.
* Blum, M. and Kannan, S. (1995). Designing programs that check their work. *J. ACM* 42(1). STOC 1989.
* Blum, M., Luby, M. and Rubinfeld, R. (1993). Self-testing/correcting with applications to numerical problems. *JCSS* 47(3). STOC 1990.
* Botta, E., Li, Y., Mehta, A., Ash, J. T., Zhang, C. and Risteski, A. (2025). On the query complexity of verifier-assisted language generation. ICML.
* Brown-Cohen, J., Irving, G. and Piliouras, G. (2024). Scalable AI safety via doubly-efficient debate. ICML.
* Brown-Cohen, J., Irving, G. and Piliouras, G. (2025). Avoiding obfuscation with prover-estimator debate. arXiv:2506.13609.
* Canetti, R., Riva, B. and Rothblum, G. N. (2013). Refereed delegation of computation. *Inform. Comput.* 226. CCS 2011.
* Christiano, P., Shlegeris, B. and Amodei, D. (2018). Supervising strong learners by amplifying weak experts. arXiv:1810.08575.
* Cohen, B. and Pietrzak, K. (2018). Simple proofs of sequential work. EUROCRYPT.
* Cohen, M. K., Hutter, M. and Nanda, N. (2022). Fully general online imitation learning. *JMLR* 23(334).
* El-Yaniv, R. and Wiener, Y. (2010). On the foundations of noise-free selective classification. *JMLR* 11.
* Feige, U. and Kilian, J. (1997). Making games short. STOC.
* Foster, D. J., Block, A. and Misra, D. (2024). Is behavior cloning all you need? Understanding horizon in imitation learning. NeurIPS. arXiv:2407.15007.
* Goldman, S. and Kearns, M. (1995). On the complexity of teaching. *JCSS* 50(1).
* Goldwasser, S., Kalai, A. T., Kalai, Y. and Montasser, O. (2020). Beyond perturbations: learning guarantees with arbitrary adversarial test examples. NeurIPS.
* Goldwasser, S., Kalai, Y. T. and Rothblum, G. N. (2015). Delegating computation: interactive proofs for muggles. *J. ACM* 62(4). STOC 2008.
* Goldwasser, S., Micali, S. and Rackoff, C. (1989). The knowledge complexity of interactive proof systems. *SIAM J. Comput.* 18(1).
* Hoque, R., Balakrishna, A., Novoseller, E., Wilcox, A., Brown, D. and Goldberg, K. (2021). ThriftyDAgger: budget-aware novelty and risk gating for interactive imitation learning. CoRL.
* Irving, G., Christiano, P. and Amodei, D. (2018). AI safety via debate. arXiv:1805.00899.
* Jia, Z., Rakhlin, A. and Xie, T. (2025). Do we need to verify step by step? Rethinking process supervision from a theoretical perspective. ICML.
* Judah, K., Fern, A., Dietterich, T. and Tadepalli, P. (2014). Active imitation learning: formal and practical reductions to i.i.d. learning. *JMLR* 15.
* Kalodner, H., Goldfeder, S., Chen, X., Weinberg, S. M. and Felten, E. (2018). Arbitrum: scalable, private smart contracts. USENIX Security.
* Kelly, M., Sidrane, C., Driggs-Campbell, K. and Kochenderfer, M. (2019). HG-DAgger: interactive imitation learning with human experts. ICRA.
* Li, L., Littman, M. and Walsh, T. (2008). Knows what it knows: a framework for self-aware learning. ICML.
* Lightman, H. et al. (2023). Let's verify step by step. arXiv:2305.20050.
* Lipton, R. (1991). New directions in testing. DIMACS Series, vol. 2.
* Littlestone, N. (1988). Learning quickly when irrelevant attributes abound. *Mach. Learn.* 2.
* Luo, J., Dong, P., Zhai, Y., Ma, Y. and Levine, S. (2024). RLIF: interactive imitation learning as reinforcement learning. ICLR.
* Lund, C., Fortnow, L., Karloff, H. and Nisan, N. (1992). Algebraic methods for interactive proof systems. *J. ACM*.
* Mahmoody, M., Moran, T. and Vadhan, S. (2013). Publicly verifiable proofs of sequential work. ITCS.
* Rajaraman, N., Yang, L., Jiao, J. and Ramchandran, K. (2020). Toward the fundamental limits of imitation learning. NeurIPS.
* Rajaraman, N., Han, Y., Yang, L., Liu, J., Jiao, J. and Ramchandran, K. (2021). On the value of interaction and function approximation in imitation learning. NeurIPS.
* Reingold, O., Rothblum, G. N. and Rothblum, R. D. (2016). Constant-round interactive proofs for delegating computation. STOC.
* Rivest, R. and Schapire, R. (1993). Inference of finite automata using homing sequences. *Inform. Comput.* 103.
* Ross, S. and Bagnell, J. A. (2010). Efficient reductions for imitation learning. AISTATS.
* Ross, S. and Bagnell, J. A. (2014). Reinforcement and imitation learning via interactive no-regret learning. arXiv:1406.5979.
* Ross, S., Gordon, G. and Bagnell, J. A. (2011). A reduction of imitation learning and structured prediction to no-regret online learning. AISTATS.
* Sayedi, A., Zadimoghaddam, M. and Blum, A. (2010). Trading off mistakes and don't-know predictions. NeurIPS.
* Sekhari, A., Sridharan, K., Sun, W. and Wu, R. (2023). Selective sampling and imitation learning via online regression. NeurIPS.
* Shamir, A. (1992). IP = PSPACE. *J. ACM*.
* Spencer, J., Choudhury, S., Barnes, M., Schmittle, M., Chiang, M., Ramadge, P. and Srinivasa, S. (2020). Learning from interventions: human-robot interaction as both explicit and implicit feedback. RSS.
* Sun, W., Venkatraman, A., Gordon, G., Boots, B. and Bagnell, J. A. (2017). Deeply AggreVaTeD. ICML.
* Teutsch, J. and Reitwießner, C. (2017). A scalable verification solution for blockchains. TrueBit whitepaper.
* Uesato, J. et al. (2022). Solving math word problems with process- and outcome-based feedback. arXiv:2211.14275.
* Zhu, X. (2015). Machine teaching: an inverse problem to machine learning and an approach toward optimal education. AAAI.
