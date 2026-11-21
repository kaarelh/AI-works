# Thread J: is slack imitation optimal, and what is necessary?

*Research note by Claude (Anthropic), thread J of the follow-up to [`../slack-imitation.md`](../slack-imitation.md) (version 2). Draft; not refereed. Checks: [`threadJ_checks.py`](threadJ_checks.py), output [`threadJ_checks.out`](threadJ_checks.out). Status marks: **[proved]** full proof here; **[sketch]** argument given, details not checked; **[conjecture]**.*

## Answers in brief

1. **Slack imitation is optimal for bounded-setback humans, up to logarithms** (Theorem J1) **[proved]**. For all n, ρ = σ/n, D ≤ n₀/2 and ε there is a class 𝒲 of humans with bounded setback D on *every* notebook and *every* entry. On 𝒲, every task-only protocol needs Ω((1−ρ)·Λ·K/(ε log(n/ε))) task queries, with Λ = min{n, (D+1)n/(σ+1)}. Online, one query per round gives Ω((1−ρ)ΛK/log n) failed runs.
   * Theorem 2 of slack-imitation gives at most ΛK failed runs, and Corollary 3 gives O(ΛK log(K/δ)/ε) queries. So the gap is only logs and a factor 1/(1−ρ).
   * Counted per insight there is no log at all: on 𝒲, slack imitation is within a factor 32/(1−ρ) of every protocol that makes one query per round.
   * The lower bound covers every protocol: BIS, MIX, LAST, end-weighting, uncertainty sampling, synthetic states and asks. On 𝒲, LAST never learns, and MIX costs about twice slack imitation (Part B).
2. **Slack is necessary** (Corollary J2) **[proved]**. With σ = 0, the class 𝒲 has setback D = 0 everywhere and still forces Ω(nK/(ε log(n/ε))). That is note.md's Theorem 3 bound, now on humans who lose only the step itself. For D = 0 the optimal cost per insight is Θ̃(n/(σ+1)), so each unit of slack buys a proportional saving.
3. **"BIS generalized" is the location protocol** (Theorem J3) **[proved]**. Let L, the *location number* of a round, be the fractional transversal number of the mistake sets of the failing hypotheses on the decoder's run. Query step k with probability z_k/L, where z is an optimal transversal. Then E Σ_t 1[fail_t]/L_t ≤ K.
   * In thread C's CHAIN class, L = 1 at every reachable state, with or without slack. The protocol asks at the step just before the decoder writes k_p, or at the last step if it writes nothing. It then has at most K failed runs on every path, with no slack and no bisection.
   * Persistence alone does not bound L **[sketch]** (§2.3).
4. **Asking (Proposition 5) is tight in three senses** (Proposition J5, Theorem J6).
   * The ask budget K/log₂(1/(1−α)) is attained exactly **[proved]**.
   * On 𝒲, with α at the decoder's doubt, the failure bound ΛK/log₂(1/α) of Proposition 5(b) is attained by every one-query-per-round protocol, up to a constant when the window is sparse **[proved]**.
   * Confident commissions accepted by a fooled human at unpredictable steps cost every task-only protocol, asks included, Ω(n) queries per such deviation. Each ask on the current problem lowers the failure probability by at most 2η/n. This makes thread E §4 a theorem **[proved]**.
5. **The characterization** (Theorem J4) **[proved, within a stated model]**.
   * *Upper bound, for every class:* failed runs ≤ L*·K, where L* is the largest location number at any state the learner can reach. "Every failed run has mistake mass ≥ c under every reachable decoder" is the special case L* ≤ 1/c.
   * *Lower bound, for hiding product classes* (the hypotheses differ only at the mistake states; Definition 0): every task-only protocol pays Ω(L·K/log) on the same L.
   * The "iff" therefore uses L, not mass. The version stated with mass is **false**: CHAIN has single-mistake failures and L = 1. Outside hiding classes, no converse holds even for L (example: a "confession" state, off the runs, that reveals the human's secret).
6. **Human time** (§5).
   * In human time the minimax cost for bounded-setback humans is Θ̃((D_t + h)·K/(ρε)), where h is the step length and D_t the setback measured in time. For chained imitation on silent humans it is Θ̃(T·K/ε), with T the project length.
   * Finer steps help only down to the setback duration D_t. They raise the *number* of failed runs as D_t/h. They never lower K, since K(P_fine) ≥ K(P_coarse) − O(1).

## 0. Setting and the point-query lemma

Notation is that of slack-imitation §1: a deterministic human P on notebooks, a majority decoder G_D, mistake sets M_t, K = log₂(1/w(P)), and Theorem 1 of without-a-check (E Σ_t q_t(M_t) ≤ ⌊K⌋ when round t queries a step drawn from q_t after the run is fixed).

A *task-only protocol* may task-query any state, synthetic ones included, adaptively and at random. It may also ask during a run, in which case the human's answer becomes a step of the run. It may output any decoder that is a function of the transcript and independent coins.

**Definition 0 (hiding product class).** Fix m problems and a base human P₀ whose runs succeed. For each problem p there is a finite family 𝒜_p = (Δ_{p,i})_{i∈I_p} of sets of states of problem p, with a law λ_p on I_p and q content values. The hypotheses are P_θ, θ = (θ_p)_p, θ_p ∈ {0} ∪ I_p × [q]:
* **(H1)** P_θ(x) = P₀(x), unless θ_p = (i, k) for the problem p of x and x ∈ Δ_{p,i}. In that case P_θ(x) ≠ P₀(x).
* **(H2)** Success of a run of problem p depends on θ only through θ_p. The prior is a product: θ_p = 0 with probability 1 − η, otherwise (i, k) ~ λ_p ⊗ Unif[q].
* **(U) γ-unguessability.** For every p and i and every sequence of states R from x₀ᵖ, R succeeds under θ_p = (i, k) for at most γq values of k.
* The **load** is ℓ_p = 1/max_x λ_p({i : x ∈ Δ_{p,i}}), and ℓ = min_p ℓ_p.

Then E[K] = Σ_p (h(η) + η(H(λ_p) + log₂ q)), where h is the binary entropy. Under Solomonoff's prior, K(P_θ) exceeds −log₂ prior(θ) by at most the class description plus O(1). Theorem 3 of note.md is the instance Δ_{p,i} = {(p, i, ⊥)}, λ uniform, ℓ = n, γ = 1/q.

**Lemma J0 (point queries)** **[proved]**. Let η ≤ ½.
* (a) A protocol makes Q task queries in expectation, then outputs Ĝ. For a fresh uniform problem p, independent of everything else, Pr[Ĝ's run on p fails] ≥ (1−γ)·η·(1 − 2Q/(ℓm)).
* (b) Online, with problems i.i.d. uniform, let Q_{<t} be the queries before round t's run and A_t the asks during it. Then E[#failed runs in rounds 1..T] ≥ (1−γ)·η·Σ_{t≤T}(1 − 2E[Q_{<t}]/(ℓm) − 2E[A_t]/ℓ).

*Proof.*
1. By (H1) and the product prior, a query at a state x of problem p depends on θ only through θ_p. Its answer differs from P₀(x) iff θ_p = (i, ·) with x ∈ Δ_{p,i}; call this a *hit*. A non-hit answer is P₀(x), whatever k is. It excludes the indices i with x ∈ Δ_{p,i}, and never excludes a value k.
2. Take any history in which p has not been hit, and let E be the excluded indices. The query hits with probability η·λ_p({i∉E : x∈Δ_{p,i}}) / (1 − η + η·λ_p(I_p∖E)) ≤ η/(ℓ(1−η)) ≤ 2η/ℓ.
3. So E[#problems hit] ≤ E[#hits] ≤ 2ηQ/ℓ, and the fresh problem has been hit with probability at most 2ηQ/(ℓm).
4. Suppose θ_p ≠ 0 and p is not hit. Then given the transcript and i, k is uniform on [q]. Ĝ's run on p is a function of the transcript and independent coins, so by (U) it fails with probability at least 1 − γ. This proves (a).
5. For (b): p_t is uniform and independent of the history, so it was hit before its round with probability at most 2ηE[Q_{<t}]/(ℓm). Each ask in its round hits with probability at most 2η/ℓ, by step 2. If p_t is special and never hit, every asked step equals P₀'s output, so the hybrid run is a function of the transcript, and step 4 applies. ∎

## 1. A lower bound for bounded-setback humans

**The class 𝒲(m, n, σ, D, η)** (silent damage). Let n₀ = n − σ and 0 ≤ D ≤ n₀/2. Set s = ⌈(σ+1)/(D+1)⌉, N = n − s(D+1) + 1, q = 2s, and windows W_t = {t + i(D+1) : 0 ≤ i < s} for t ∈ [0, N).
* *Notebooks* are (p; a₀, …, a_{L−1}) with units a_i ∈ {0, 1, …, q}. Each step appends one unit.
* *The human* P_θ appends u_p(L), where u_p(j) = k_p if θ_p = (t_p, k_p) and j ∈ W_{t_p}, and u_p(j) = 0 otherwise.
* *Success.* Unit i is *wrong* if a_i ≠ u_p(i). It is *valid* if it is right and none of a_{i−D}, …, a_{i−1} is wrong. S means "at least n₀ valid units".
* *The story.* At an insight point, routine work in place of the insight wastes its own step and spoils the D steps built on it. The human never notices, and goes on with its plan. The human is a function of the notebook: its length is a count of routine units, as in thread E's V5.

**Proposition J1.0** **[proved; brute-force checked, Part A]**. For every θ:
* (i) S is preserved by appending.
* (ii) τ(x₀) = n₀.
* (iii) (B_D) holds at every notebook and every entry: τ(y ∪ g) ≤ τ(y) + D for every g ≠ u_p(L), and τ(y ∪ g) = 0 if τ(y) = 0.
* (iv) For special θ_p, the base run 0ⁿ fails with exactly s mistakes, so Lemma S is tight.

So Theorem 2, Corollary 3 and Proposition 5 of slack-imitation apply to 𝒲 with no check.

*Proof.*
* (i) The validity of unit i depends only on a_{≤i}, so the number of valid units v(y) never decreases.
* (ii), (iii) Let d(y) = max{0, D − (L−1−i*)}, where i* is the index of the last wrong unit. The human's next d(y) units are invalid and all later ones valid. So τ(y) = d(y) + n₀ − v(y) if v(y) < n₀, and 0 otherwise. A wrong g leaves v unchanged and sets d to D.
* (iv) The s window units are wrong. Their damage intervals [j, j+D] are disjoint and inside [0, n), since the window's last index plus D is at most n − 1. So at least s(D+1) ≥ σ+1 units are invalid. ∎

**Theorem J1** **[proved]**. Let Λ = min{n, (D+1)n/(σ+1)}, ρ = σ/n, ε ≤ 1/16, η = 8ε and L_ε = log₂(e·n²/(4ε)). On 𝒲:
* (a) Every task-only protocol with Q queries in expectation outputs a decoder with failure probability at least 4ε(1 − 2sQ/(Nm)). Failure ≤ 2ε needs Q ≥ Nm/(4s) ≥ (1−ρ)·Λ·E[K]/(128·ε·L_ε).
* (b) Suppose a protocol makes at most c queries per round, all after the round's run. Then its expected number of failed runs is at least 2ε·⌊Nm/(4cs)⌋ ≈ (N/(16cs))·E[#special problems] ≥ (1−ρ)·Λ·E[K]/(64·c·L_ε).
* (c) With asks, round t fails with probability at least 4ε(1 − 2sE[Q_{<t}]/(Nm) − 2sE[A_t]/N). To beat (b), a protocol must ask about N/(4s) ≥ (1−ρ)Λ/16 times per round.

*Proof.* 𝒲 is a hiding product class.
* *The sets.* I_p = [0, N) and λ uniform. Δ_{p,t} is the set of notebooks of problem p whose length lies in W_t.
* *The load.* A length j lies in at most s windows, so ℓ ≥ N/s.
* *Unguessability (U), with γ = s/q = ½.* If no window position carries k, the run fails as in J1.0(iv). So a run can succeed only for the at most |W_t| = s values of k that it writes in the window.
* *Applying Lemma J0.* It gives (a), (b) and (c), with (1−γ)η = 4ε. In (b), every round up to Nm/(4cs) has Q_{<t} ≤ Nm/(4s) and so fails with probability at least 2ε.
* *The arithmetic.*
  * N ≥ n₀ − D ≥ n₀/2 and s ≤ 2·max{(σ+1)/(D+1), 1}, so N/s ≥ (n₀/4)·min{(D+1)/(σ+1), 1} = ((1−ρ)/4)·Λ.
  * E[K] = m(h(η) + η log₂(2sN)) ≤ ηm·log₂(2esN/η) ≤ 8εm·L_ε, using h(η) ≤ η log₂(e/η) and sN ≤ n². ∎

**Remarks.**
* *Tightness.* The upper bounds are Theorem 2 (ΛK failed runs online) and Corollary 3 (O((D+1)K·log(K/δ)/(ρε)) ≥ ΛK·log/ε queries). Per insight, slack imitation pays about n/s failed runs: Part B measures 0.98–1.04 × E[#special]·n/s for D = 0, …, 15. Part (b) demands N/(16s). The ratio is 16n/N ≤ 32/(1−ρ), with no log.
* *Strongest assumption, weakest protocol.* (B_D) holds here in its learner-free form, on all notebooks and all entries, so no strengthening of (B_D) avoids the bound. Slack imitation needs (B_D) only on its own runs.
* *Fixed humans.* As in note.md's remark on Theorem 3, −log₂ prior(θ) concentrates. So for every protocol there is a fixed human of complexity at most 2E[K] on which it fails with probability at least 2ε (for m large).
* *Why nothing beats it.* The humans of 𝒲 are silent: a miss changes no later output, only the success predicate. Every query is a point query on length, hitting at most s offsets out of N. Uncertainty sampling sees doubt at most 2ηs/N at every window-capable step: it fires nowhere, or at about n steps per visit. LAST never hits for D ≥ 1, since n − 1 lies in no window, and stalls (Part B).

## 2. Is slack necessary?

### 2.1 Without slack, bounded setback buys nothing

**Corollary J2** **[proved]**. 𝒲(m, n, 0, 0, η) has setback D = 0 at every notebook and every entry, and n₀ = n, s = 1, N = n, Λ = n. On it, failure ≤ 2ε needs Q ≥ nm/4 ≥ n·E[K]/(32·ε·L_ε) task queries, for every task-only protocol.

More generally, for D = 0 the parameters are s = σ+1 and N = n − σ, so the bounds of Theorem J1 and Theorem 2 are both Θ̃(n/(σ+1)) per insight. In a silent bounded-setback class, slack is what buys the factor, linearly. *Proof:* Theorem J1 with σ = D = 0. ∎

The humans of note.md's Theorem 3 never recover. These recover at the cost of the step itself, and that does not help, because nothing absorbs the lost step.

### 2.2 What BIS generalizes to: the location number

For data D, a problem x₀ and the decoder G_D, let F(D, x₀) be the family of mistake sets M_{P′} ⊆ {0, …, n−1}, on G_D's run, of the hypotheses P′ ∈ H_D under which that run fails.
* The *location number* L(D, x₀) = τ*(F) is min Σ_k z_k over z ≥ 0 with z(M) ≥ 1 for every M ∈ F, and 1 if F is empty.
* Always 1 ≤ L ≤ n, and L ≤ 1/c if every M ∈ F has |M| ≥ cn.
* L = 1 iff the sets in F share a step. If τ* = 1, every M contains the support of the optimal z.

**Protocol LOC.** In round t, run G_t on x₀ᵗ, compute an optimal z for F(D_t, x₀ᵗ), and task-query step k with probability z_k/L_t.

**Theorem J3** **[proved]**. For every class H, every P ∈ H and every sequence of problems, E Σ_t 1[run t fails]/L_t ≤ ⌊K⌋. So:
* E[#failed runs] ≤ L*·⌊K⌋, with L* the largest L at any state the learner can reach;
* on i.i.d. problems, stopping at a uniform round among the first N gives expected failure at most L*K/N;
* mixing LOC half and half with the uniform query keeps both guarantees up to a factor 2.

*Proof.* P ∈ H_{D_t}, so if run t fails, M_P ∈ F and q_t(M_P) = z(M_P)/L_t ≥ 1/L_t. Apply Theorem 1 of without-a-check. The i.i.d. statement is the proof of note.md's Proposition 2(b). ∎

**Proposition J3′ (CHAIN)** **[proved]**. Take thread C's CHAIN class, with the class-prior decoder that never writes an unconfirmed insight value (Lemma 5 of without-a-check). At every reachable state, L = 1, and the following protocol has at most ⌊K⌋ failed runs **on every path**, for every σ ≥ 0, σ = 0 included. If the decoder's run writes k_p at step w, query step w − 1; otherwise query step n − 1.

*Proof.*
* *k_p unconfirmed.* The decoder writes nothing. Under every failing hypothesis (t_p ≤ n−1), the human at the decoder's state at step n−1 writes k_p, so n−1 ∈ M.
* *k_p confirmed, written at w.* Under t_p ≥ w the run's chain is at least the human's, so the run succeeds. Under t_p < w − σ it fails, with M = [t_p, w): there the human writes k_p, while elsewhere it writes what the decoder writes (nothing before t_p, the next chain unit after w). So w−1 lies in every failing M.
* *Conclusion.* The query is a point mass on a common step, so every failed run's query lands on a mistake. Lemma 1 of note.md bounds these by ⌊K⌋ on every path. ∎

Part C, at σ = 0 with m = 100, measures for n = 16 → 1024:

| protocol | failed runs | task queries |
|---|---|---|
| LOC | 150 → 290, at most 0.49·K | |
| BIS | about 50 | 300 → 590 |
| chained imitation | 780 → 48,000 | |

BIS finds t_p within one round, and so fails once per insight. LOC finds it across rounds, failing about once per halving.

**The general statement.**
* BIS and LOC remove the factor n exactly when the failing hypotheses' mistake sets have a small fractional transversal on the decoder's run.
* Persistence gives this for ripe failures, by thread C's Theorem A (the last step lies in every ripe M). CHAIN also gives it for lateness, because a late item's mistakes end where the decoder chose to write it.

### 2.3 Persistence alone does not suffice without slack **[sketch]**

*Construction (shortcut humans).* Units are written in order, one per step. At an unknown progress point t_p, the human writes two units at once: the next one, and the one after it done by method k_p, a shortcut found by insight. The decoder misses it, and from then on is one unit behind. The human, working on the decoder's notebooks, then writes exactly what the decoder writes. So the failure is unripe, with the single mistake at t_p, and every query reveals only 1[progress = t_p − 1].

*Properties.*
* Persistence (P₁) holds on all drafts in the version without methods (checked by hand: what is due at y stays due until written).
* Setback is D = 0 (B-omit): τ(y ∪ g) = τ(y).
* To block guessing, the shortcut unit must carry the method k_p, with q ≥ 2n. Then (P₁) holds only modulo "unit j done by an admissible method", which thread C's item-level (P₁) does not state.

If this is carried through, Lemma J0 with ℓ = n gives the factor n, so persistent humans with D = 0 still need slack. In the frame of §4: persistence makes due-ness a threshold for an item the run *lacks*; it says nothing about an opportunity the run *missed*.

## 3. Asking: is Proposition 5's trade-off tight?

**Proposition J5** **[proved]**.

(a) *The ask budget is attained.* Take m problems, each with one binary slot, prior Pr[b_p = 1] = α + δ, and the human b ≡ 0. SI-ABC asks once per problem, since the top mass there is 1 − α − δ < 1 − α, and never again. So it asks m times, with K = m·log₂(1/(1−α−δ)), and the ratio of asks to K/log₂(1/(1−α)) tends to 1 as δ → 0 (Part D: 0.9999). An ask can carry as little as log₂(1/(1−α)) ≈ 1.44α bits, so Proposition 5(a)'s lifetime budget of about 0.69K/α can be spent in full on answers that turn out to be the default.

(b) *At confident steps, log₂(1/α) is the most any protocol gains.*
* On 𝒲 with η = 8ε, every window-capable step has doubt at most α₀ = 2ηs/N = 16εs/N, so SI-ABC with α ≥ α₀ never asks.
* Proposition 5(b) then gives E[#failed] ≤ ΛK/log₂(1/α₀).
* Theorem J1(b) shows that every protocol with one query per round has at least (1−ρ)ΛE[K]/(64L_ε).
* The ratio is 64L_ε/((1−ρ)·log₂(N/(16εs))). It is O(1/((1−ρ)c)) whenever s ≤ n^{1−c} and ε ≤ n^{−c}, since then log₂(N/(16εs)) ≥ c′·L_ε.
* Theorem J1(c) adds that asks help only at about N/(4s) asks per round.

So once α is below the decoder's doubt at its mistakes, Proposition 5(b) is tight up to a constant. Asking cannot do better, because the mistakes it would need to ask about are confident.

**Theorem J6 (fooled commissions)** **[proved]**. Let 𝒟(m, n, η, q) have a decision slot at every step that the human always fills (π = 1). Problem p's human writes the default d₀ at every step, except that with probability η it writes d_{k_p} at one uniform step t_p. On any notebook it builds on the decision it finds and never revisits it (fooled). Success means the final notebook carries the human's decisions. Then:
* (i) Every mistake of the class-prior decoder is a confident commission, with doubt at most 2η/n. At it, setback is ∞ and (B-omit) is vacuous, so slack changes nothing.
* (ii) With η = 8ε and q = 2, every task-only protocol needs Q ≥ nm/4 ≥ n·E[K]/(32ε·log₂(en/(4ε))) for failure ≤ 2ε.
* (iii) Online, asks included: E[#failed in rounds ≤ T] ≥ (η/2)·Σ_t(1 − 2E[Q_{<t}]/(nm) − 2E[A_t]/n). Each ask on the current problem buys at most 2η/n of failure probability.
  * SI-ABC with α ≥ 2η/n never asks, and uniform queries find each deviation at rate 1/n.
  * With α < η/n it asks at all n steps of every unresolved problem.

*Proof.* 𝒟 is a hiding product class with Δ_{p,i} = the states of problem p at step i, λ uniform, ℓ = n and γ = 1/q. Apply Lemma J0. The bound on E[K] is note.md's. ∎

*What escapes.*
* *A human judgment.* Thread E §4's claim holds as stated: a confident commission accepted by a fooled human is found by task queries at rate O(1/n) per query, whatever the protocol. A preserved "on track" check finds it with ⌈log₂ n⌉ checks (MB), and AND-batched endorsements are group queries (thread D). A single-transition endorsement is a point query and does not help.
* *Kinds.* If deviations share a *kind* across problems, the posterior learns the kind's rate, its doubt exceeds α, and SI-ABC fires. The cost is then per kind, not per problem: thread E's "first surprise of each kind".
