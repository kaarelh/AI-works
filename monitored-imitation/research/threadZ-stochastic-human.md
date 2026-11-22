# Thread Z: verified slack imitation with a stochastic human

*Research note by Claude (Anthropic) on [`../paper/verified-slack-imitation.tex`](../paper/verified-slack-imitation.tex) (Sections 2–6 and 8). Draft; not refereed. No existing file was changed.*
* *Code:* [`threadZ_stochastic.py`](threadZ_stochastic.py), output [`threadZ_stochastic.out`](threadZ_stochastic.out) (27 s; `python3 -B threadZ_stochastic.py`).
* *Tags:* **[P]** proved here (proofs in §8); **[S]** sketched; **[C]** conjectured; **[N]** numerical, in the toy; **[J]** judgment.
* *Numbering:* Z0–Z12 are this thread's results. Lemma 2.1 (a bit per mistake), Lemma 4.2 (the first mistake comes early), Theorem 4.7, Proposition 4.10 (any learner), Corollary 4.15 ("works"), Theorems 6.1–6.2 (lower bounds) and Theorem 7.2 (bits of selection) are the paper's.
* *Notation:* h is the binary entropy and kl(p‖q) the binary KL divergence, both in bits.

## Answers in brief

1. **Correctness rests on V alone, unchanged** [P, the paper's proof]. Everything below is about cost and human-likeness.
2. **Model (i), stochastic style.** The paper's theorems transfer verbatim to the content map C, with K_C ≤ K(P) + K(π) + O(1) (Theorem Z1, [P]). The conditions: canonicalization removes all the noise; the scaffold stores and shows only canonical entries; V reads only canonical notebooks; and (A1)–(A3′) hold for C. Three-month steps vary mostly in content, so this covers little of the real noise.
3. **Model (ii), a deterministic core C plus memoryless deviations at rate δ < 1/2.**
   * *The bit.* One differing answer certifies nothing. The replacement for Lemma 2.1 (Lemma Z2, [P]): a task query where the Bayes decoder disagrees with the human's mode lowers the expected potential by at least **1 − h(δ)** bits (0.71, 0.53 and 0.28 at δ = 0.05, 0.1 and 0.2). This holds in expectation, not pathwise.
   * *The first mistake.* Lemma 4.2 holds for the mode chain (Z3).
   * *Theorem Z4 [P].* Decode the mode; on each rejection ask once at each of the run's first n₀ notebooks; add every answer. Then E[rejections] ≤ K/(1 − h(δ)) and E[task queries] ≤ n₀K/(1 − h(δ)), which is 1.9n₀K at δ = 0.1 against the paper's 2n₀K.
     * There is **no term in T**: the mode imitator is more reliable than the human.
     * It needs memoryless re-asks (necessary: Z12), a mode chain that succeeds, and a dominant mode at the granularity of a query: plausible for categorical decisions and blueprint rounds, false for open-ended three-month steps [J].
   * *Early stopping.* A sequential test keeps "stop at the first mistake" (Theorem Z4′, [P]).
4. **Model (iii), a general stochastic program.**
   * *With a mode margin γ,* Z4 holds with 1 − h(δ) replaced by f(p₁, p₂) ≥ γ²/(2 ln 2) (Z6, [P]).
   * *If no mode succeeds, no deterministic imitator works* (Proposition Z10, [P]). On a class with K = 0, every decoder-based protocol needs Ω(T) task queries or abstentions. Every protocol with verified outputs then carries Ω(T) bits of verifier selection relative to the unconditioned human, so Theorem 7.2's logarithmic bound cannot survive.
   * *VSI-D, the best protocol found (Theorem Z8, [P]).* Posterior-sample a hypothesis and run it, up to m reruns; if all are rejected, the human demonstrates (works the problem from the start). Then, for every θ ∈ (0, 1),

     E[demonstrations] ≤ (ln 2/2)·K/((1 − θ)²s²) + Σₜ(1 − θs)^m,

     each costing at most n task queries: about 0.43K/s² at θ = 0.1, plus a term in T that is exponentially small in the compute m.
     * *It needs* only problem-level realizability and s; not determinism, the cold start, memorylessness, or queries at synthetic notebooks.
     * *Its price:* per output, V raises a hypothesis's odds against the human's by at most a factor 1/s, as the human retrying until success would.
5. **The safety net survives** (Proposition Z9, [P]). Proposition 4.10, with caching and for any learner: at most 2n₀ task queries per problem with probability s, else at most 2n and an abstention.
6. **Lower bounds** [P]. Deterministic lower bounds transfer to model (ii) by simulating the noise (Z11), so Theorem 6.2's Ω(nK/log) stands. Mode imitation needs re-asks (Z12). Without a successful mode, randomization and Ω(T) selection are forced (Z10).
7. **Simulation [N]** (§6; silent human; δ = 0, 0.05, 0.1, 0.2).
   * *Correctness.* Unverified chained imitation is correct 21%, 22%, 11% and 3% of the time; every verified protocol, 100%. The paper's VSI with a deterministic learner abstains on 0–63% of problems.
   * *Task queries per problem.* Z4: 1.20–2.60; the sequential test: 0.79–1.61; VSI-D: 0.69–1.12, at 4–8 runs per problem. Every bound holds, with room.
8. **Probability.**
   * *Conditional on realizability only* (a stationary stochastic human in the class, exact Bayes), not on determinism or the cold start: VSI with a proof assistant works with **about 60%** (50–65%), against about 45% for the paper's decoder protocol, which has no cost guarantee for a noisy human.
   * *Unconditionally:* **about 45%** (38–50%), against the paper's 40%. Without realizability neither version has a cost guarantee.

## 1. Setting and accounting

As in the paper, with these changes.
* **Stochastic hypotheses.** H is a countable class of stochastic programs ν with prior w, P ∈ H, and K = log₂(1/w(P)). A datum (y, a) is an answer a drawn from P(·|y).
* **Posterior predictive and potential.** The posterior predictive is ξ_D(a|y) = W(D + (y,a))/W(D), with W(D) = Σ_ν w(ν)Πν(a|y), and G_D is its argmax. The potential is Φ(D) = log₂W(D) − log₂(w(P)P(D)) ≥ 0, with Φ(∅) ≤ K; it depends only on the multiset D.
* **(M), memorylessness.** Each query returns a fresh draw, even at a notebook asked before.
* **Model (ii).** P(C(y)|y) ≥ 1 − δ > 1/2. The mode chain is the human's chain with every deviation removed.
  * (A2-C): the mode chain reaches S_V within n₀.
  * (A3′-C): V accepts every extension of the mode chain's notebook at n₀.
* **The human's own success probability** s(x₀) is the probability that its own n-step chain reaches S_V. It absorbs (A2) and (A3′).

**Lemma Z0 (log-loss accounting) [P].**
* A fresh answer changes Φ by log₂(ξ_D(a|y)/P(a|y)), with expectation −KL(P(·|y)‖ξ_D(·|y)).
* On every path, Σₜ log₂(P(aₜ|yₜ)/ξₜ(aₜ|yₜ)) ≤ K.
* If round t lowers E[Φ | past] by at least bₜ ≥ 0, with bₜ fixed before the round's answers, then E[Σₜ bₜ] ≤ K. In particular, if every "charged" round lowers E[Φ] by at least b, then E[#charged] ≤ K/b and P[#charged ≥ cK/b] ≤ 1/c.

**What replaces "a mistake is worth a bit".**

| device | what one hit certifies | worth per query | needs |
|---|---|---|---|
| one answer that differs from the label | nothing: this happens with probability ≥ δ even at the mode | — | — |
| r repeated answers (a sequential test) | "not the mode", with error ≤ ρ^r, where ρ = δ/(1 − δ) | a locator (Z4′) | (M) |
| decoder, at a mode mistake | — | ≥ 1 − h(δ); ≥ γ²/(2 ln 2) at margin γ (Z2, Z6) | a dominant mode |
| α-confident decoder | — | ≥ kl(δ‖1 − α) at a confident mode mistake; ≥ kl(ε‖1 − α) where the human writes the label with probability ≤ ε | α > δ, else it asks everywhere |
| per-step sampler | — | ≥ (2/ln 2)·TV² | — |
| posterior sampler, per demonstration | — | ≥ (2/ln 2)(s − a)² (Z8) | demonstrations |
| log loss, any data | — | Σ log(P/ξ) ≤ K pathwise | realizability |

The α-decoder row answers the note's open problem ("events unlikely under the demonstrator stay unlikely"): confident commitments to labels that the human writes with probability ≤ ε cost at most K/kl(ε‖1 − α) queries in expectation. In model (ii), asks must not append a single sample, since a deviation breaks Lemma Z3. Drop them, or append the majority of several re-asks.

## 2. Model (i)

**Theorem Z1 [P].** Assume:
* (S1) π(P(y)) = C(y) almost surely;
* (S2) the scaffold stores and shows only canonical entries (or the human's content is style-blind, C(y) = C(π(y)));
* (S3) V reads only the canonical notebook;
* (S4) C ∈ H_canon with weight 2^(−K_C), and (A2)–(A3′) hold for C.

Then VSI's runs, verdicts and answers have the law of VSI with the deterministic human C. So Theorem 4.7, Proposition 4.10, Theorem 5.1 and Theorem 7.2 hold with K_C, and K_C ≤ K(P) + K(π) + O(1) for a total stochastic P.

If noise leaks through π with probability η, this is model (ii) with δ = η. Comparing steps becomes syntactic equality of canonical forms, not a judgment, so the constraint survives. (S2) fails if the human reacts to its own wording; (S4) fails if π discards content that later steps need.

## 3. Model (ii)

**Lemma Z2 [P].** If G_D(y) ≠ C(y), then KL(P(·|y)‖ξ_D(·|y)) ≥ kl(1 − δ‖1/2) = 1 − h(δ). With an α-confident decoder, the bound is kl(δ‖1 − α).

Two differences from Lemma 2.1.
* *A deviation can raise Φ,* so "at most K rejections on every path" becomes a bound in expectation, with a tail that is only Markov-like.
* *One answer need not flip the decoder:* the prior odds against C(y) can exceed the likelihood ratio (1 − δ)/δ of one answer. So the same notebook must be asked again.

**Lemma Z3 [P].** Under (A2-C) and (A3′-C), with no asks, every rejected run of G_D has a committed step k < n₀ at which G_D(x′_k) ≠ C(x′_k).

**Theorem Z4 (VSI-full) [P].** Assume model (ii) (Q arbitrary, even adversarial), (M), P ∈ H, (A2-C) and (A3′-C), and no asks.
* *The protocol:* decode G_D; on a rejection, ask once at each of x′₀, …, x′_{n₀−1}, add all answers, and rerun.
* *The guarantee,* for every adaptive sequence of problems:
  * (a) every output passes V;
  * (b) E[#rejections] ≤ K/(1 − h(δ));
  * (c) E[task queries] ≤ n₀K/(1 − h(δ));
  * (d) every problem ends with an output, almost surely.

There is no term in T and no dependence on s. The cost is 1.40, 1.88 and 3.60 times n₀K at δ = 0.05, 0.1 and 0.2, against the paper's 2n₀K, so Corollary 4.15's ratio to chained imitation is preserved up to that factor.

**Theorem Z4′ (VSI-split: early stopping) [P].**
* *The scan.* At step k, ask until the answers that equal the run's label lead by 1 (pass) or trail by r (alarm). Discard these detection answers.
* *At the first alarm,* add one fresh answer there and rerun.
* *The guarantee.* With π = 1 − n₀ρ^r − ρ > 0: E[#rejections] ≤ K/((1 − h(δ))π), with π ≈ 0.85 at δ = 0.1, r = 3 and n₀ = 30. A round whose alarm falls at the first mistake k* costs at most (k* + r)/(1 − 2δ) + 1 queries in expectation.
* *Two open points.* Adding the detection answers (as one would, and as the toy's cheaper "sequential test" does) breaks the proof's exchange argument; whether the bound survives is [C]. Uniform draws through the same test should restore the paper's O(Λ) under bounded setback [S].

*Granularity.* A three-month step bundles many decisions: at 90% repeatability, 20 decisions repeat jointly with probability 0.12, so the step has no dominant mode. Z4 suits categorical decisions, blueprint rounds, or steps canonicalized down to decisions, with many but cheaper queries [S].

## 4. Model (iii)

**Theorem Z6 [P].** Let p₁ ≥ p₂ be the two largest values of P(·|y), and let f(p₁, p₂) = (p₁ + p₂)(1 − h(p₁/(p₁ + p₂))) ≥ (p₁ − p₂)²/(2 ln 2). If the mode chains satisfy the analogues of (A2-C) and (A3′-C), and b = inf f > 0 along them below n₀, then Theorem Z4 holds with b in place of 1 − h(δ). Theorem Z4′ also holds when inf p₁ > 1/2, with δ = 1 − inf p₁; without a majority mode its sequential test has no drift.

**Proposition Z10 (the coin) [P].** Take H = {P}, so K = 0. Problem t hides a bit λₜ, and V accepts iff the first entry is λₜ. The human picks A or B at random, so s = 1/2.
* (a) Consider any deterministic imitator whose label depends on the data only through the posterior and the answers at that notebook (Bayes decoders, cache-first, majority of re-asks). Its label at problem t's first notebook, before any answer there, is independent of λₜ. So E[task queries] + E[abstentions] ≥ T/2.
* (b) A posterior sampler needs no task queries and 2 runs per problem.
* (c) Every protocol that outputs a verified result on every problem writes λ₁, …, λ_T, a likelihood ratio of 2^T against any verdict-independent script. So no bound 2^(o(T)) of Theorem 7.2's kind holds, and the human retrying until success has the same ratio. Selection must be measured against the human's success-conditioned process.

**Lemma Z7 (the stochastic "first mistake") [P].**
* (a) A per-step sampler with a frozen posterior has |a − s| ≤ E_run Σ_{k<n} TV(P(·|x′_k), ξ(·|x′_k)): the excess rejection is carried by variation along the imitator's own run.
* (b) A posterior sampler (draw ν, then run it) has a ≥ 2^(−Φ(D))s and |a − s| ≤ √((ln 2/2)Φ(D)).
* (c) The frozen per-step sampler can be exponentially worse: a = 2^(1−n) against 1 in a two-hypothesis example.

**Theorem Z8 (VSI-D) [P].**
* *The setting.* Hypotheses are problem-level stochastic processes (internal state allowed), with P ∈ H. A demonstration is the human working problem x₀ from the start until S_V holds or for n steps: a fresh draw of its chain, made without seeing any imitator run.
* *The protocol.* For each problem: draw ν from w(·|D) and run it, up to m times, and output the first accepted run. If none is accepted, the human demonstrates, and its result is output if accepted (else the problem is abstained); the demonstration is added to D.
* *The guarantee,* for every adaptive sequence, every θ ∈ (0, 1) and every s₀ ≤ sₜ:
  * (a) every output passes V;
  * (b) E[#demos] ≤ Σₜ(1 − θs₀)^m + (ln 2/2)K/((1 − θ)²s₀²); problems with sₜ < s₀ add at most one demonstration each;
  * (c) E[task queries] ≤ n·E[#demos], with at most m runs per problem;
  * (d) an output is a draw from M_{Dₜ}(·|accepted), so any hypothesis's odds against the human's rise by at most a factor 1/sₜ.
* *A deterministic human.* If sₜ = 1, (b) sharpens to E[#demos] ≤ K/log₂(1/θ) + Σₜ(1 − θ)^m.

What Theorem Z8 says:
* *The scan becomes a demonstration.* For a deterministic human, scanning a rejected decoder run from step 0 *is* the human's chain up to the first mistake. For a stochastic human the two diverge at once, and only the human's own chain gives a clean bound: its information is the chain-level KL, which Pinsker ties to s − a.
* *Free reruns remove the term in T,* which searching every rejection would pay (about T(1 − s)).
* *Constants.* At θ = 0.1 the bound is 0.67nK at s = 0.8 and 1.7nK at s = 0.5, against the paper's 2n₀K. There is no conflict with Theorem 6.2, since VSI-D verifies up to m times per problem.
* *A trade the paper declined.* Even for a deterministic human, reruns trade task queries (a factor log₂(1/θ)) for compute and selection; the decoder declines that trade. For a stochastic human, Z10 removes the choice.
* *Two limits [S].* It stops learning once acceptance is adequate (in the toy the posterior stays near 0.45 on the truth); audits at rate β would fix that at a cost of βnT. Under misspecification, demonstrations still stop if the KL-closest hypothesis is accepted at least θs of the time.

**Proposition Z9 (the safety net) [P].** Run the paper's VSI with cached answers, cache-first decoding, any learner, and no asks, local check or bizarre check. Assume the answers at distinct notebooks are independent draws.
* *The bound.* The lazily revealed answers define a deterministic P̃ whose chain is distributed as the human's own chain. With probability s at n₀, VSI asks at most 2n₀ task queries on the problem; otherwise at most 2n, then it abstains.
* *No K bound across problems.* A hit shows only that the imitator differs from one sample, so the abstention term T(1 − s) stays.

## 5. Lower bounds and obstructions

* **Proposition Z11 (noise never helps) [P].** With δ and Q known, a protocol for the noisy class yields one for the deterministic class with the same cost and failure: simulate the noise. So Theorems 6.1 and 6.2 hold in model (ii), and Z4's factor n₀ is unavoidable on silent humans up to a logarithm.
* **Proposition Z12 (mode imitation needs re-asks) [P].** Take one notebook and two hypotheses, with modes A (the truth, weight 2^(−K)) and B, and deviation δ.
  * If K′ = log₂((1 − 2^(−K))/2^(−K)) > log₂((1 − δ)/δ), a single ask per notebook leaves the decoder wrong forever.
  * With re-asks, at least K′/((1 − 2δ)log₂((1 − δ)/δ)) answers are needed there (about 8 at K = 20 and δ = 0.1).
  * A human who remembers its answers breaks (M). VSI-D never repeats a notebook.
* **Proposition Z10 [P]**, above: without a mode that succeeds, randomization and Ω(T) selection are forced.
* **The margin [S].** Identifying a mode of margin γ takes Ω(log(1/err)/γ²) samples, so Z6's 1/γ² is the right order. In model (ii), 1/(1 − h(δ)) exceeds the per-sample information bound 1/kl(1 − δ‖δ) by a factor of 4.3–5.4 for δ ≤ 0.2. With a verifier, trying the human's samples may pay only about 1/(1 − δ) [C].

## 6. Simulation [N]

*The toy.* There are M = 6 insight types, each with a hidden value (q = 256) and step (n₀ = 12). The **silent** core writes the value at its step only; the **noticing** core writes it at the first later step at which it is absent. With probability δ the human writes a uniform symbol instead, freshly at every query. V accepts iff the value appears within n = 18 steps. The learner is exact Bayes with δ known (K = 69.5 bits). 60 problems, 30 seeds.

*The silent human* (s = 1.00, 0.95, 0.90, 0.82). Each cell gives queries per problem, then rejections per seed.

| protocol | δ = 0 | 0.05 | 0.1 | 0.2 | outputs correct | notes |
|---|---|---|---|---|---|---|
| chained imitation, no verifier | 1.00 | 1.00 | 1.00 | 1.00 | 0.21 / 0.22 / 0.11 / 0.03 | unverified |
| paper's VSI, deterministic learner | 0.69 | 0.66 | 0.61 | 0.51 | 1.00 | abstains on 0 / 29 / 50 / 63%: a deviation refutes the truth |
| paper's stopping rule, stochastic learner | 0.69 / 6 | 1.18 / 12 | 1.49 / 17 | 4.15 / 61 | 1.00 | false hits |
| Z4 (VSI-full) | 1.20 / 6 | 1.75 / 9 | 2.21 / 11 | 2.60 / 13 | 1.00 | bounds 70 / 97 / 131 / 250 |
| sequential test, r = 2, all answers added | 0.79 / 6 | 0.89 / 6 | 1.07 / 7 | 1.61 / 11 | 1.00 | — |
| Z4′ (VSI-split, r = 3) | 0.99 / 6 | 1.15 / 7 | 2.55 / 14 | 3.56 / 16 | 1.00 | bounds 70 / 103 / 150 / 444 |
| Z8 (VSI-D, m = 30) | 0.69 | 0.72 | 0.86 | 1.12 | 1.00 | 6.0 / 6.1 / 6.6 / 7.5 demonstrations (bounds 33–49); 4.1 / 4.9 / 6.1 / 8.4 runs per problem |

* *The noticing human:* Z4 asks 1.19–1.30 queries per problem and the sequential test 0.79–1.62.
* *No term in T.* From T = 30 to T = 240, Z4's rejections per seed stay at 5.9–6.0, 10.8–11.5 and 13.0–13.4 (δ = 0, 0.1, 0.2). VSI-D's demonstrations stay at 5.9–8.1, and its runs per problem fall from 7.1 to 1.8 (δ = 0) and from 9.7 to 3.6 (δ = 0.1).
* *The coin.* A decoder asks 1.00 queries per problem and abstains on 50.5% of problems; cache-first asks 0.51 and abstains on 25%; a sampler asks none and needs 1.96 runs.
* *Reading.* The best stochastic protocols cost 1.25–1.35 times the noiseless cost at δ = 0.1 and 1.6–2.0 times at δ = 0.2. The toy (one insight per problem, known δ) says nothing about real humans.

## 7. What it changes

**For the paper.**
1. **Use a learner over stochastic hypotheses.** A deterministic-class learner refutes a noisy human at its first deviation.
2. **The decoder protocol's guarantee (Z4)** needs a dominant mode per query and memoryless re-asks, which open-ended three-month steps lack.
3. **VSI-D has a guarantee for any problem-level-realizable stochastic human,** at the price of selection (≤ log₂(1/s) bits of odds per output) and compute. For a human whose success depends on its randomness, that price is unavoidable (Z10).
4. **Theorem 7.2 must be stated against the human's success-conditioned process.** Proposition 4.10 holds with probability s.

**The probability [J].** Thread T's 70% is the correctness half (0.96 × 0.995, unchanged here) times an effort factor of 0.76.
* *Effort.* VSI-D's guarantee (ιn ≈ 1.5ιn₀ steps per demonstration) is below a fifth of chained imitation's 20n₀K when ι(n/n₀)/s² < 9.3, which needs s ≳ 0.57 at ι = 2.
  * *My weights on typical s at horizon n* are 0.8 (50%), 0.65 (30%) and 0.5 (20%). With thread T's ι, that gives P(guarantee) ≈ 0.86; times 0.87 for the other cost issues, the effort factor is ≈ 0.75, about as before.
  * *A discount of 0.85.* The protocol is new and unrefereed, the bound is a worst case, s must be estimated, and the human must stay stationary.
  * The effort factor is then ≈ 0.64.
* *Conditional on realizability.* This gives **P(works | realizability) ≈ 0.955 × 0.64 ≈ 60%** (50–65%). Here realizability means a stationary stochastic human in the class, learned by exact Bayes. That is the standard Solomonoff assumption, and more plausible than deterministic realizability, which is false of real humans.
  * The paper's decoder protocol at three-month granularity gets about 45% on the same conditioning: it may still work in practice, as in the toy, but it has no guarantee.
* *Unconditional.* **About 45%** (38–50%), against the paper's 40%. Drift, a human who learns from doing problems, and practical learners dominate what remains, and this thread does not touch them.
* **How much of the gap closes.** On realizability alone, about 15 points (45% → 60%). Unconditionally, about 5 of the 30 points between the paper's 70% and 40%.

**What to measure.**
* s within n on problems in the domain.
* Whether delayed cold starts of single decisions are memoryless (thread L: partly; false negatives repeat 30% of the time).
* VSI-D's acceptance rate a against s, which estimates the excess selection log₂(s/a).

## 8. Proofs

**Lemma Z0.**
* *The change.* Φ(D + (y,a)) − Φ(D) = log₂(W(D + (y,a))/W(D)) − log₂P(a|y) = log₂(ξ_D(a|y)/P(a|y)). If a is drawn from P(·|y) independently of D, its expectation is −KL(P(·|y)‖ξ_D(·|y)).
* *Nonnegative, bounded at the start, order-free.* Φ ≥ 0 because W(D) ≥ w(P)P(D). Φ(∅) = log₂(W(∅)/w(P)) ≤ K. W and P(D) are products over the multiset, so Φ depends only on the multiset.
* *The pathwise bound.* Summing the change over the data in the order they arrive, Σₜ log₂(P(aₜ|yₜ)/ξₜ(aₜ|yₜ)) = Φ(∅) − Φ(D_T) ≤ K.
* *The count.* If E[ΔΦₜ | past] ≤ −bₜ with bₜ ≥ 0 predictable, then Yₜ = Φₜ + Σ_{u≤t} b_u is a nonnegative supermartingale with Y₀ ≤ K. So E[Σ_{u≤t} b_u] ≤ E[Yₜ] ≤ K for every finite horizon, and the total follows by monotone convergence. With bₜ = b·1[charged], Yₜ ≥ b·Nₜ, and Ville's inequality gives P[sup Y ≥ cK] ≤ 1/c.

**Theorem Z1.**
* *The process is the deterministic one.* Under (S2), every notebook the protocol or the human ever sees is canonical. Under (S1), a task query at a canonical y returns C(y) almost surely, and the human's own chain is C's chain. Under (S3), every verdict is a function of the canonical notebook. So the joint law of runs, verdicts and answers is that of VSI with the deterministic human C. The paper's proofs use the human only through answers and its own chain.
* *The complexity bound.* Fix any random string r₀ on which P halts. Then C(y) = π(P(y; r₀)), so a program for C is a program for P, one for π, and O(1) bits.

**Lemma Z2.**
* *The decoder at a mode mistake.* ξ(C(y)|y) ≤ ξ(G(y)|y), and the two add up to at most 1, so ξ(C(y)|y) ≤ 1/2.
* *The coarsening.* By data processing on the partition {C(y)} versus the rest, KL ≥ kl(P(C(y)|y)‖ξ(C(y)|y)).
* *Monotonicity.* kl(p‖q) increases in p on [q, 1] and decreases in q on [0, p]. With p ≥ 1 − δ > 1/2 ≥ q, this gives KL ≥ kl(1 − δ‖1/2) = 1 − h(δ).
* *The α-decoder.* Here the committed label ℓ has ξ(ℓ) ≥ 1 − α. If ℓ ≠ C(y), then P(ℓ) ≤ δ < 1 − α, so KL ≥ kl(P(ℓ)‖ξ(ℓ)) ≥ kl(δ‖1 − α). If instead P(ℓ) ≤ ε < 1 − α, then KL ≥ kl(ε‖1 − α).

**Lemma Z3.** As Lemma 4.2. Correct committed steps append C's label. If no committed step below n₀ is a mode mistake, the notebook at n₀ is c^C_{n₀}, and V accepts its extension by (A3′-C).

**Theorem Z4.**
* *(a)* is the paper's argument: V accepted every output.
* *(b), one round.* Fix rejection i, with data D and run x′ (both determined before the round's answers). By Lemma Z3, there is k* < n₀ with G_D(x′_{k*}) ≠ C(x′_{k*}). The round adds n₀ answers at fixed notebooks; by (M) they are independent draws, independent of D.
  * Since Φ depends only on the multiset, compute the round's change by adding the answer at x′_{k*} first. Its conditional expected change is −KL(P(·|x′_{k*})‖ξ_D(·|x′_{k*})) ≤ −(1 − h(δ)), by Lemma Z2.
  * Each remaining answer is a fresh draw at a fixed notebook, independent of those added before it, so its conditional expected change is ≤ 0.
  * So E[ΔΦ_round | past] ≤ −(1 − h(δ)).
* *(b), all rounds.* Accepted rounds add no data. Lemma Z0, with "charged" meaning "rejected", gives E[#rejections] ≤ K/(1 − h(δ)).
* *(c)* follows, since each rejection costs n₀ queries.
* *(d)* The number of rejections is finite almost surely, and a problem is rerun only after a rejection.

**Theorem Z4′.**
* *At a step with the run's label g.* Let p = P(g|x′_k) and ρ′ = (1 − p)/p.
  * *A correct step (g = C).* Here p ≥ 1 − δ. The gambler's-ruin probability of reaching −r before +1 is ρ′^r(1 − ρ′)/(1 − ρ′^(r+1)) ≤ ρ′^r ≤ ρ^r. The expected length is at most that of reaching +1 without the lower barrier, 1/(2p − 1) ≤ 1/(1 − 2δ), by Wald.
  * *A mistake step.* Here g ≠ C(x′_k), so p ≤ 1 − P(C) ≤ δ < 1/2. The probability of ever reaching +1 is p/(1 − p) ≤ ρ. The expected length is at most r/(1 − 2p) ≤ r/(1 − 2δ).
* *Where the alarm falls.* By the union bound, P[the alarm is at a decoder mistake | past] ≥ 1 − k*ρ^r − ρ ≥ π.
* *The charge.* D does not change during detection, since the detection answers are discarded. The learning answer at the alarm step j is a fresh draw, independent of the detection answers given j. So E[ΔΦ | past, detection] = −KL(P(·|x′_j)‖ξ_D(·|x′_j)) ≤ −(1 − h(δ))·1[j is a mistake], and taking expectations gives E[ΔΦ | past] ≤ −(1 − h(δ))π. Lemma Z0 concludes.
* *The cost per round* is the sum of the expected lengths over the scanned steps, plus 1.

**Theorem Z6.**
* *The coarsening.* Coarsen to the partition {m}, {G(y)}, rest. With q₁ = ξ(m) ≤ q₂ = ξ(G(y)) and P-masses p₁, p_g, p₃, data processing gives KL ≥ p₁log(p₁/q₁) + p_g log(p_g/q₂) + p₃log(p₃/q₃).
* *The minimum.* For fixed S = q₁ + q₂, the unconstrained minimizer has q₁ > q₂, so the constrained one is q₁ = q₂ = S/2. Minimizing over S then gives p₁ + p_g, leaving (p₁ + p_g)·kl(p₁/(p₁ + p_g)‖1/2) = f(p₁, p_g).
* *Monotonicity.* ∂f/∂x = log₂(2x/(p₁ + x)) < 0 for x < p₁, so f(p₁, p_g) ≥ f(p₁, p₂). Also ∂f/∂p₁ = log₂(2p₁/(p₁ + x)) > 0, so model (ii) gives f ≥ f(1 − δ, δ) = 1 − h(δ).
* *The quadratic bound.* 1 − h(1/2 + ε) ≥ (2/ln 2)ε² gives f ≥ (p₁ − p₂)²/(2 ln 2·(p₁ + p₂)).
* *The rest is Theorem Z4,* since the first mistake lies on a mode chain (Lemma Z3 with m in place of C).

**Lemma Z7.**
* *(a) The hybrid argument.* Let H_k use ξ for steps below k and P after. H_k and H_{k+1} differ only in the kernel at step k, after a prefix drawn from ξ and before a common suffix kernel. So TV(H_k, H_{k+1}) ≤ E_{ξ-run} TV(P(·|x′_k), ξ(·|x′_k)). Sum, and use |a − s| ≤ TV(ξⁿ, Pⁿ).
* *(b) The posterior sampler.* Mⁿ_D(c) = Σ_ν w(ν|D)νⁿ(c) ≥ w(P|D)Pⁿ(c), and w(P|D) = 2^(−Φ(D)). This gives both a ≥ 2^(−Φ)s and KL(Pⁿ‖Mⁿ_D) ≤ Φ(D). Pinsker in bits then bounds the TV, which bounds |a − s|.
* *(c) The example.* With ν_b writing b at every step and weights 1/2, the frozen predictive is 1/2 per step, so a run is constant with probability 2^(1−n). The posterior sampler's run is always constant.

**Theorem Z8.**
* *(a)* Only accepted results are output.
* *(b), one problem.* Given Dₜ, the m runs are independent draws from M_{Dₜ}, each accepted with probability aₜ. A demonstration happens with probability (1 − aₜ)^m, independently of its content. The demonstration c (stopped by a rule common to all hypotheses) adds Φ(Dₜ ∪ c) − Φ(Dₜ) = log₂(M_{Dₜ}(c)/P(c)), with conditional expectation −KL(P^stop‖M^stop_{Dₜ}).
* *(b), the gap in acceptance.* S_V is preserved by appending, so "S_V within n" is measurable for the stopped chains and has probabilities sₜ and aₜ. Hence TV ≥ |sₜ − aₜ|, and Pinsker gives KL ≥ (2/ln 2)(sₜ − aₜ)².
  * *Bad problems* (aₜ < θsₜ) give KL ≥ (2/ln 2)(1 − θ)²s₀². Apply Lemma Z0 with the predictable charge bₜ = (2/ln 2)(1 − θ)²s₀²·P[demoₜ | Dₜ]·1[badₜ]: E[#demos on bad problems] = E[Σₜ P[demoₜ | Dₜ]·1[badₜ]] ≤ (ln 2/2)K/((1 − θ)²s₀²).
  * *Good problems* demonstrate with probability (1 − aₜ)^m ≤ (1 − θs₀)^m.
* *(b), the deterministic case.* Hypotheses consistent with c reach S_V at the same notebook, so M_{Dₜ}(c) ≤ aₜ < θ, and each demonstration on a bad problem lowers Φ by at least log₂(1/θ).
* *(c)* is immediate.
* *(d)* The first accepted run is a draw from M(·|A). It comes from ν with probability ∝ w(ν|D)a_ν, so its odds against P are multiplied by a_ν/sₜ ≤ 1/sₜ.

**Proposition Z9.** As Proposition 4.10, with P̃ in place of P.
* *The frozen chain is the human's chain.* Each notebook is asked at most once, so P̃ is a well-defined deterministic function. c̃ is distributed as the human's own chain, because each of its steps is a fresh draw at its notebook.
* *Before the first difference* with P̃, a run follows c̃. Cache-first decoding never errs at a cached notebook.
* *The count.* On the event that c̃ reaches S_V within n₀, the scan asks only uncached notebooks c̃ᵢ with i < n₀, each once, and the S, U, S, H counting of Proposition 4.10 gives at most 2n₀. Otherwise the notebooks are c̃ᵢ with i < n, which gives at most 2n.

**Proposition Z10.**
* *(a)* With H = {P}, the posterior never changes, so the decoder's label at problem t's first notebook is a fixed function of the visible notebook until an answer at that very notebook is added. The human's answers are independent of λₜ. So that label is independent of λₜ, and the run is rejected with probability 1/2. Until an answer at that notebook is added, every rerun is identical. Either such an answer is asked for, or the problem is abstained. Summing over t gives at least T/2 in expectation.
* *(b)* Each run is accepted with probability 1/2.
* *(c)* is stated in the text.

**Proposition Z11.** The protocol for H_det runs the noisy-class protocol. Whenever that protocol asks at y, it asks the deterministic human, then with probability δ replaces the answer by a draw from Q(·|y). This is exactly a query to the noisy human, so cost and output law are identical.

**Proposition Z12.**
* *The posterior.* After a answers A and b answers B, the posterior log-odds of A against B are −K′ + (a − b)·log₂((1 − δ)/δ). The decoder writes A iff these are positive.
* *One ask.* With one ask, |a − b| ≤ 1 < K′/log₂((1 − δ)/δ). The run is rejected and identical forever.
* *Re-asks.* a − b is a walk with drift 1 − 2δ. By Wald, the expected time to reach K′/log₂((1 − δ)/δ) is at least that level divided by 1 − 2δ.
