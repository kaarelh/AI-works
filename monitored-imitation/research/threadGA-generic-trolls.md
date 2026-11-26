# Thread GA: generic humans, trolls and backstabs

*Working note by Claude (Anthropic) on Kaarel Hänni's question about generic humans: the trolling and backstabbing half. It builds on Sections 2–5 of the paper ([`../paper/verified-slack-imitation.tex`](../paper/verified-slack-imitation.tex)) and on the calibration and time-bound results of `malign-prior-toy` (its README on `main`). Draft. Not refereed. No existing file was changed.*
* *Code:* [`threadGA_generic.py`](threadGA_generic.py). *Output:* [`threadGA_generic.out`](threadGA_generic.out). It takes 34 s to run (`python3 -B threadGA_generic.py`).
* *Status tags:* **[P]** proved here (proofs in §8), **[S]** sketched, **[C]** conjectured, **[N]** numerical. "Standard" marks a textbook fact recalled from memory and not rechecked.
* *Numbering:* GA0–GA12 are this thread's. Lemma 2.1 (a bit per mistake), Lemma 4.2 (the first mistake comes early), Theorem 4.7(b) (the counts, with its reordering of a round's data), Remark 4.9 (asks are optional with a verifier), Theorem 6.1 (silent humans) and Theorem 7.1 (no optimization pressure) are the paper's.

**The question** (verbatim): "i wonder if one can prove something like: assuming the human is a generic program of its complexity (and maybe runtime), such and such a scheme works well? like maybe some programs can be constructed which get trolled by shorter guys who then backstab, but most programs aren't trolled this way?"

## Answers in brief

1. **The answer for this half: yes for trolling, no for the cost.**
   * *Yes: trolling needs deficiency.* Measure genericity by the human's randomness deficiency d under the learner's own prior, conditional on the whole protocol. For every program P, the bits P can still lose to impostors equal, up to d, the information in P's behaviour that the data have not yet exercised (GA8).
     * A generic human is backstabbed only through its honest unknowns.
     * A human that keeps being backstabbed after its behaviour is pinned down needs deficiency at least the bits it loses; such humans have prior mass at most 2^(−deficiency). The victim an adversary builds from the protocol has d = K − O(1).
     * If the human is drawn from the learner's prior, every confident committed step is wrong with probability at most α given the history, whichever troll or malign coalition holds the majority (GA3).
   * *No: genericity does not make the scheme cheap.* Under a prior of independent rare insights (the structure of the paper's silent humans), the typical human is backstabbed about K/(log₂(1/α) + 1.44) times: the worst-case bound, short by 1.44 bits per backstab (GA5). The impostor there is honest ("P without its rare insight"), and the paper's lower bounds, being averages over such priors, survive genericity.
   * *A third effect, which we did not expect: Occam mismatch.* "Generic of its complexity" is generic for the learner only if the learner's prior gives the human's complexity class about the mass the humans have. A prior more concentrated on short programs trolls typical complex humans with simpler consistent explanations.
     * In the toy: about a third of the worst-case rate, with committed mistakes 7–25 times the learner's own estimate (α = 0.05). The band's own prior, or a prior flat over complexity bands, removes nearly all of it (GA6, [N]).
     * Under the universal prior the mismatch is only about K(K) ≈ log K bits. This warns against practical priors more Occam than humans, not against Solomonoff's.
2. **Definitions.** (G2) is the notion: d(P) = log₂(1/w̄(f_P)) − K(f_P | Π), with w̄ the learner's own prior, f_P the behaviour and Π the whole protocol. (G1), P ~ w̄, gives d ≤ c with probability 1 − 2^(−c) and is the proof tool; (G1) on a class S and (G3) cost log₂(1/w̄(S)) + K(S) bits (GA0). Under a universal prior, d = I(f_P : Π) + O(1): a generic human shares little information with the learner, the protocol and the problem source.
3. **Transfer lemma** (GA1) [P]. If c is lower semicomputable given Π and E_w̄[c] ≤ B, then c(f) ≤ B·2^(d(f) + K(B|Π) + O(1)), the O(1) a constant of the universal machine. An adaptive problem source is part of Π; z bits of advice about the human cost a factor 2^|z|; protocol randomness is not needed; an incomputable learner needs an oracle.
4. **Calibration** (GA2–GA4) [P]. Under (G1), given the data, P is a posterior sample.
   * A coalition writing ℓ with posterior mass π delivers a payload (a committed label other than the human's) with probability at most min{α, 1 − π}. For a human drawn from the non-malign part of the prior the bound is α/(1 − π_Mal).
   * Expected committed mistakes equal the learner's own cumulative uncertainty at committed steps; backstabs have a Poisson-type tail in a compensator the learner computes.
   * In the worst case, a constructed P is wrong at every confident step until refuted, up to K/log₂(1/α) times.
5. **"Most programs aren't trolled", quantified.**
   * No bound in j, α and K alone beats the trivial one: under the rare-insight prior almost every human has about K/(b + 1.44) backstabs, b = log₂(1/α) (GA5).
   * Trolling beyond the unexercised information r is exponentially rare: the prior mass of humans with at least j backstabs after the n-th answer and residual r_n ≤ r is at most 2^(−(jb − r − K(n)) + O(1)) (GA8f).
   * In the nested troll chain the mass with at least j backstabs is exactly (α/3)^j [N].
6. **Identification** (GA7–GA10) [P].
   * r_n − O(1) ≤ Φ ≤ d + r_n + K(n) + O(1), with r_n = K(f_P | D_n, Π). So no consistent impostor is more than d + r_n + K(n) + O(1) bits shorter, a confident mistake needs r_n ≥ b − d − K(n) − O(1), and each backstab exercises at least that many bits.
   * Conversely, in a universal class there is an impostor r − K(Q|f_P) − O(log K) bits shorter (a lookup table of the data), and in any class "P with an unexercised branch deleted" is shorter and no slower.
   * The asked-for "K + c bits" form is vacuous in the complexity sense (labels carry at most K + O(1) bits about P) and true as a counting statement: if the transcript has min-entropy K′ + c, impostors shorter than K′ survive with probability at most 2^(−c) (GA10).
7. **Asks** (GA11) [P]. E[asks] ≤ H(w̄)/h(α), against the worst-case K/log₂(1/(1−α)): 2.2×, 3.9×, 5.6× better at α = 0.2, 0.05, 0.01; individually, asks·H_{1+λ}(α) ≤ K + (d + O(1))/λ. With a verifier this barely matters (asks are optional). Without one it matters: asking below 1 − ε/n gives failure at most ε on every run, with no audits, and E[asks] ≤ H·n/(ε log₂(n/ε)), which is Theorem 6.1's lower bound up to its constant.
8. **Runtime** (GA12). It excludes slow malign simulators (`malign-prior-toy`'s time-bound result) and humans that diagonalize against the learner, and it makes the learner computable. It does not exclude the honest impostor "P minus its branch" or wrappers around it, which are as fast as P; silent humans run in linear time; and a time-bounded prior makes deep humans non-generic.
9. **Simulation** [N] (exact Bayes over all 2^16 functions on 16 states, 34 s). Under the learner's own prior, committed mistakes match the compensator (0.723 against 0.720; 0.168 against 0.167). Rare insights: E[backstabs]·b/E[K] = 0.735 and 0.804 (exact 0.735, 0.807). Occam learner on complexity-band humans: 0.29–0.37 of K/b, stable from 6 to 45 bits; greedy adversary 0.60 and 0.42; the band's own prior 0.000–0.045.
10. **Open.** The surprise profile of natural priors (does a typical program under a universal or speed prior carry its information at uncertain steps, or as rare confident surprises?); Occam mismatch under the universal prior beyond the K(K)/kl bound; calibration when the human is generic only among (A2)-satisfying programs; individual versions of the Poisson tail.

## 1. Setting

**Standing assumptions.**
* **(F)** The notebooks form a finite set Y (bounded length), so a behaviour f ∈ L^Y is a finite table.
* **The class and the prior.** H is a computable family of total programs, with a computable prior w, Σw ≤ 1, and w̄ = w/w(H).
  * The behaviour prior is w̄(f) = Σ_{h computes f} w̄(h).
  * Write K_F = log₂(1/w̄(f_P)) ≤ K and Φ_F(D) = log₂(W(D)/w(f_P)) ∈ [0, K_F].
  * Every program computing f_P stays consistent forever, so Lemma 2.1 and all the paper's counts hold with K_F in place of K.
* **The protocol Π** is everything but the human: the learner, the scaffold, the rules, the problem source, the verifier and the coins. **(C)** The learner's decisions are computable from Π and the answers. This holds for finite H, and is needed only for the (G2) statements; otherwise, relativize to an oracle for Π.
* **(Ind)** Every action (problem, query location, verdict, coin, pointer) is drawn from a kernel that depends on the history and on nothing else about P.
  * It holds for VSI with a machine verifier, a problem source that does not know the human, and pointers written from the record by someone who does not know the human.
  * It fails for a P-aware problem source or pointer writer, for the human choosing follow-up problems, and for a verifier whose verdicts depend on P.
* **(U)** The decoder and the ask rule at each step condition on every answer received so far, including earlier asks in the same run.
* **Notation.**
  * b = log₂(1/α), and u_k = 1 − (top mass) at a committed step k.
  * h is the binary entropy and H_a the Rényi entropy of order a.
  * A backstab is a hit at a committed step: a confident mistake, found.

**Notions of genericity.**
* **(G1)** P ~ w̄: the learner's own prior.
* **(G1_S)** P ~ w̄(·|S): length ≤ K, runtime ≤ t, a complexity band, or the programs satisfying (A2).
* **(G2)** d(f|Π) = log₂(1/w̄(f)) − K(f|Π) is small; within S, d_S(f|Π) = log₂(1/w̄_S(f)) − K(f|S,Π).
* **(G3)** Uniform over programs of length K is (G1_S) for S = {|h| = K} under a length prior. Uniform over behaviours of complexity K is a different measure, related to it by how many programs compute each behaviour.

**Lemma GA0** [P].
* (i) d ≥ −O(1).
* (ii) w̄{f : d(f|Π) ≥ c} ≤ 2^(−c), so (G1) implies (G2) with probability at least 1 − 2^(−c).
* (iii) d(f|Π) ≤ d_S(f|Π) + log₂(1/w̄(S)) + K(S|Π) + O(1). Conversely, every member of a decidable S has d(f|Π) ≥ log₂(1/w̄(S)) − K(S|Π) − O(1).
* (iv) Under the universal prior (all prefix programs on a universal machine, w = 2^(−|h|)), d(f|Π) = K(f) − K(f|Π) + O(1) = I(f:Π) + O(1). This uses the coding theorem, which is standard.

**The choice.**
* (G2) relative to the learner's own prior is the notion to use, because it is the individual statement; (G1) is the proof tool; (G1_S) and (G3) are (G1) for particular S, and cost log₂(1/w̄(S)) bits by (iii).
* (G3) is a poor primary notion for two reasons.
  * Uniform measure over a structured class can be the rare-insight prior itself: uniform on the vectors with s ones among m, with s/m ≪ α, gives a typical member about s ≈ K/(b + 1.44) backstabs (GA5).
  * "Of complexity K" against a learner whose prior is more Occam than that is exactly the mismatch of GA6.
* One caveat. If the human is generic only within the (A2)-satisfying programs S, the honest impostors are often outside S. A learner could discard every hypothesis whose own chain fails V, which restores calibration on S [S]. But that lets the verifier into the decoder and gives up Theorem 7.1's no-pressure property.

## 2. Transfer (GA1)

**Theorem GA1** [P]. Let c ≥ 0 be lower semicomputable given (Π, B) and E_w̄[c] ≤ B (B > 0 rational).
* (a) For every f, c(f) ≤ B·2^(d(f|Π,B) + O(1)) ≤ B·2^(d(f|Π) + K(B|Π) + O(1)), with an O(1) that depends only on the universal machine.
* (b) Without any computability, w̄{c ≥ λB} ≤ 1/λ.
* (c) If the problem source uses a prefix-free advice string z chosen with knowledge of P, and each fixed z gives E_w̄[c_z] ≤ B, then c_z(f) ≤ 2^|z|·B·2^(d(f|Π) + O(1)) for every z.

**The careful checks.**
* *Adaptivity.* An adaptive source that sees only the history is part of Π. Its complexity sits in the condition, not in the constant. Without the condition, 2^K(Π) appears, which is astronomically large for a real learner.
  * A P-aware source does not break the transfer. It breaks the bound B, which comes from calibration; (c) prices it at a factor 2 per bit of information about P.
  * sup_σ E[c_σ] ≤ B does not give a bound on E[sup_σ c_σ]. A worst-case adversary is not covered.
* *Internal randomness.* c(f) = E_ρ[N(f,ρ)] is lower semicomputable when each round uses finitely many coins.
  * For realized coins, apply Markov's inequality in ρ, or apply GA1 to (f, ρ) jointly.
  * GA2 needs no protocol randomness, so a fixed seed is fine, provided it is in Π. A human who knows the seed has high I(f : Π).
* *Lower semicomputability.* Expected counts over an infinite horizon are sums of computable probabilities, hence lower semicomputable. Costs that need the exact posterior of an incomputable learner are not; they need the oracle.
* *Strength.* The factor 2^d is multiplicative. GA1 helps only when B is far below the worst case, and it is useless under the rare-insight prior.

## 3. Calibration and amplification

**Lemma GA2 (calibration)** [P].
* Under (G1) and (Ind), for every history H_t of positive probability, Pr[f_P = f | H_t] = w̄(f)·1[f consistent with D_t]/W̄(D_t). Hence Pr[P(y) = ℓ | H_t] = ξ_{D_t}(ℓ|y) for every notebook y that is fixed by the history.
* Under (G1_S), the law of f_P given H_t is the posterior restricted to S. So Pr_S[E | H_t] ≤ ξ_{D_t}(E)/π_S(D_t) for every event E, where π_S is the posterior mass of S.

This is the imitation form of `malign-prior-toy`'s calibration result. There, a world drawn from the predictor's own prior has, given the context, a continuation with the same law as the predictor's sample.

**Theorem GA3 (confident steps)** [P]. Assume (G1), (Ind) and (U).
* (a) At every committed step k, Pr[mistake | H_k] = u_k ≤ α.
* (b) For any coalition C, the label ℓ_k it writes at a committed step satisfies Pr[the decoder writes ℓ_k ≠ P(y_k) | H_k] ≤ 1[decoder writes ℓ_k]·min{α, 1 − π_{C,k}}. Here π_{C,k} is the posterior mass of C's members that write ℓ_k.
* (c) If the human is drawn from w̄(·|S), the bound in (a) is α/π_S(H_k). For S the non-malign programs, it is α/(1 − π_Mal(H_k)).
* (d) E[#payloads of C] ≤ α·E[#committed steps carrying C's label], and E[#committed mistakes] = E[Σ_committed u_k].

*The worst case, by contrast.* A constructed P can be wrong at every committed step whose top mass is at least 1 − α, until each refutation costs it b bits: up to K/b refutations, with payloads at every confident step in between, including those never queried.
* (b) says that the malign mass at a step *is* the probability that the human writes the same label. Under (G1) the malign hypotheses are possible humans.
* The malign-prior worry is that real humans are drawn from somewhere else. (c) prices that exactly: the bound degrades only where the malign coalition holds posterior mass, so the question becomes the malign-prior question of the toy (its κ and its fate at uses).
* Averaged over humans, a change of measure gives E_{non-malign}[payloads] ≤ E_w̄[committed mistakes]/(1 − w̄(Mal)). Payloads are confined to contexts that a prior-random human rarely reaches.

**Theorem GA4 (backstabs)** [P]. Let q_r = Pr[run r ends in a backstab | history at its start].
* (a) q_r ≤ E[U_r | start], where U_r = Σ_{committed k in r} u_k ≤ αn.
* (b) E[#backstabs] = E[Σ_r q_r].
* (c) For all a and j ≥ a, Pr[#backstabs ≥ j and Σ_r q_r ≤ a] ≤ e^(−a)·(ea/j)^j.
* (d) Surely #backstabs ≤ K_F/b, so E[#backstabs] ≤ H(w̄_F)/b, where H(w̄_F) = E[K_F] is the entropy of the behaviour prior.

The compensator Σ_r q_r is computable by the learner online. It is the honest diagnostic: under calibration, backstabs are Poisson-like in it, whoever holds the majority.

**Theorem GA5 (the bound is attained by generic humans)** [P]. The prior: problems i = 1..m. On problem i the human writes a fixed insight at step 0 iff b_i = 1, where the b_i ~ Bernoulli(p) are independent and p ≤ α. The default chain fails V exactly when b_i = 1.
* Under (G1), E[backstabs] = mp and E[K_F] = m·h(p). So E[backstabs] = E[K_F]·p/h(p) ≥ E[K_F]/(log₂(1/p) + log₂e), which is at least E[K_F]/(b + log₂e) at p = α.
* Almost surely, backstabs/K_F → p/h(p).
* Every (G2)-generic human with d ≤ c has backstabs ≥ (1−ε)·K_F·p/h(p) once m is large enough, given c and ε.
* So the worst-case bound K/b is attained by typical humans, up to the factor b/(b + 1.44): 0.75 at α = 0.05 and 0.82 at α = 0.01, tending to 1 as α → 0.

**What rules it out.** E[backstabs] = E[Σ_r q_r] exactly.
* So K/b in expectation needs the prior to put its entropy into events whose predictive probability at confident steps is close to α. This is a property of the prior, the problem source and α together.
* It is ruled out when the prior has no large family of nearly independent behaviours with predictive probability in (ε, α] that the problems exercise at confident steps.
  * Such a prior is uncertain wherever it could be wrong.
  * The decision-tree bands with their own prior are an example [N].
* The threshold α moves the boundary. A feature with p > α is asked rather than backstabbed.
  * Under calibration, a feature of probability p costs about min{1/p asks, one rejection}.
  * So α ≈ 1/(2n₀) balances the two in VSI [S].
* The rare-insight structure is the silent-human structure. The property that rules it out is the absence of silence, the same property the paper's lower bounds point to, and genericity adds nothing to it.

**Theorem GA6 (Occam mismatch)** [P]. Let f_P ~ w̄(·|S), and let s = log₂(1/w̄(S)).
* (a) Under (Ind), Σ_{answers i} E[KL(ξ^S_i ‖ ξ_i)] ≤ s, with answers in the order they arrive. Here ξ^S_i is the human's true conditional law and ξ_i the learner's.
* (b) For β > α, the expected number of answers at which the learner's top label had mass ≥ 1 − α while its true probability was ≤ 1 − β is at most s/kl(β‖α).
* (c) Under the universal prior, the class S_K of behaviours of complexity K has w̄(S_K) = 2^(−K(K) + O(1)). This rests on the standard count #{x : K(x) = K} = 2^(K − K(K) + O(1)). So s ≈ log K + 2 log log K + O(1).
  * Example: at K = 10⁶ bits, s ≈ 28 + O(1). With α = 0.01 and β = 1/2, the bound is at most about 12 + O(1) badly miscalibrated confident answers, against K/b ≈ 150,000.
* (d) [N] The decision-tree prior is far more Occam than counting. Its bands have s = 6.3, 12.8 and 23.6 bits at K_F ≈ 15, 27 and 39.
  * With the full prior, band humans are backstabbed at 0.29–0.37 of K_F/b.
  * The learner is miscalibrated: at α = 0.05, its committed mistakes are 1.0–4.4 against a compensator of 0.12–0.18.
  * With the band's own prior the rate is 0.000–0.045; with a prior flat over 6-bit bands it is 0.001–0.08.
  * The price is more asks: 9–15 against 7–9 at α = 0.05, and 8–14 against 3–4 at α = 0.2.

**Reading.** The "shorter guys" that troll a *typical* complex human are not constructed adversaries. They are the simpler explanations that an over-Occam prior prefers.
* The remedy is a hyperprior flat over complexity scales. It costs log₂(#bands) bits.
* The universal prior already has this property up to K(K) bits.

## 4. Identification

**Theorem GA7 (data side)** [P]. For a deterministic Π (or fixed coins in Π), every human P and every n:
* Φ_F(D_n) ≤ K_F − K(a_{≤n} | Π, n) + O(1), where a_{≤n} is the sequence of answers.

**Theorem GA8 (residual information)** [P]. With r_n = K(f_P | D_n, Π), the information in P's behaviour that the data have not exercised:

  r_n − O(1) ≤ Φ_F(D_n) ≤ d(f_P|Π) + r_n + K(n) + O(1).

The corollaries [P]:
* (a) Every consistent impostor h has log₂(w(f_h)/w(f_P)) ≤ d + r_n + K(n) + O(1). No impostor is more than that many bits shorter.
* (b) A confident mistake at data D_n, where P's label has mass at most α, needs Φ_F ≥ b. Hence r_n ≥ b − d − K(n) − O(1).
* (c) After D_n, future backstabs ≤ Φ_F(D_n)/b ≤ (d + r_n + K(n) + O(1))/b.
* (d) j backstabs between answer n and answer n′ exercise information: r_{n′} ≤ r_n + d + K(n) − jb + O(1).
* (e) The troll surplus is Φ_F − r_n ≤ d + K(n) + O(1). The adversary's constructed human is computed from Π, so K(f|Π) = O(1) and d = K_F − O(1): all of its potential is surplus.
* (f) w̄{f : at least j backstabs after the n-th answer, and r_n(f) ≤ r} ≤ 2^(−(jb − r − K(n)) + O(1)).

**The probabilistic twin** [P]. Under (G1), E[Φ_F(D_n) | H_n] = H(posterior of f_P given H_n). So the expected number of remaining backstabs is at most the posterior entropy divided by b.
* Amplification means Φ_F far above this entropy, which is atypicality.
* Under a universal prior, a troll chain with geometrically decaying weights needs members with incompressible extra bits. With hardwired members of weight about 2^(−2 log i), no member dominates, and the learner asks instead.

**Theorem GA9 (where the information sits)** [P].
* (a) In the time-unbounded universal class, if r_n > K(Q_n | f_P) + c₀ log K_F, there is an h consistent with D_n with f_h ≠ f_P and log₂(w(h)/w̄(f_P)) ≥ r_n − K(Q_n | f_P) − O(log K_F). Here Q_n is the set of queried notebooks, and K(Q_n | f_P) ≤ K(Π) + O(1) for a computable Π.
* (b) In any class that is closed under deleting a branch: if P's code contains a branch of β bits that fires on no notebook of Q_n, then "P with the branch deleted" is consistent, is β − O(1) bits shorter, and runs no slower.

So, up to d + K(Q_n | f_P) + O(log K):
* the best impostor's advantage in bits equals P's unexercised information r_n;
* consistent shorter impostors exist exactly when P's information sits in behaviour that the data never exercise.

**Theorem GA10 (counting; the form with "K + c bits")** [P]. Let f_P ~ μ, let I be a fixed set of hypotheses (for example the fewer than 2^K′ programs shorter than K′), and let Π be deterministic.
* Then Pr_μ[some h ∈ I with f_h ≠ f_P is consistent with D_n] ≤ |I|·2^(−H_∞(a_{≤n})).
* So if the transcript has min-entropy at least K′ + c, impostors shorter than K′ survive with probability at most 2^(−c).

*The complexity form is vacuous.* K(a | Π, n) ≤ K_F + O(1), so labels never carry more than K + O(1) bits about P. GA7 gives the correct threshold: once they carry K_F − c bits, impostors weigh at most 2^(c + O(1)) times P.

## 5. Asks under calibration

**Theorem GA11** [P]. Assume (Ind) and (U), and α ≤ 1/2.
* (a) Under (G1), an ask at minority mass u ≥ α yields expected information H(ξ_y) ≥ max{h(u), log₂(1/(1−u))} ≥ h(α). So E[#asks] ≤ H(w̄_F)/h(α).
* (b) For every P, every λ > 0 fixed in Π, and a computable learner with finite H: #asks·H_{1+λ}(α) ≤ K_F(P) + (d(f_P|Π) + O(1))/λ.
* (c) Without a verifier, with α = ε/n and n ≥ n₀ under (A2):
  * every run fails with probability at most ε given the history at its start;
  * E[#asks] ≤ H/h(ε/n) ≤ H·n/(ε log₂(n/ε)).

**Does it matter?**
* *The gains.* h(α)/log₂(1/(1−α)) is 2.2, 3.9, 5.6 and 7.4 at α = 0.2, 0.05, 0.01 and 1/600. The individual Rényi version, before its d/λ term, gives 2.1–5.6× over the worst case at the same α (output §ASKS).
* *With a verifier*, VSI's default asks only at the claim step (Remark 4.9), so the gain is minor.
* *Without a verifier*, the gain is the whole logarithm.
  * The worst-case analysis of ask-before-committing gives K·n/(ε log₂e) asks. At ε = 0.05 and n = 30 that is 416K.
  * Calibrated, it is H/h(1/600) = 56H, against Theorem 6.1's n/(ε log₂(n/ε)) = 65 (times its constant).
  * So for silent humans drawn from their own prior, ask-before-committing alone is optimal up to a constant, with per-run failure at most ε and no audits.
  * For an individual generic human, GA1 gives at most 2^(d + O(1))·εT failed runs among T.

## 6. Runtime

**GA12.**
* *What a runtime bound buys:*
  * (i) [P in `malign-prior-toy`] Seekers and simulated inhabitants print nothing until their search finds the program they follow, or their world has produced the inhabitants. A schedule whose first deadline falls below that start-up gives them no mass. Then π_Mal = 0 for them, and GA3(c) gives back the full per-step bound α for non-malign humans.
  * (ii) [P] A human that diagonalizes against the learner must run exact Bayes over H. If that takes longer than t, the human is not in the class "runtime ≤ t".
  * (iii) [P] The learner becomes computable, so GA1, GA7, GA8 and GA11(b) need no oracle.
* *What it does not buy:*
  * (iv) [P] The honest impostor of GA9(b) runs no slower than P.
  * (v) [P in `malign-prior-toy`, and here] The wrapper floor survives resource bounds when the explanations have room to spare. A trigger plus payload around the honest impostor runs in time(P₀) + time(trigger). By GA8(a) its weight relative to P is at most 2^(d + r_n + K(n) + O(1)), so it can supply a confident payload only while r_n ≥ b − d − K(n) − O(1).
  * (vi) [P] The silent class of Theorem 6.1 and the rare-insight prior of GA5 run in linear time. So runtime leaves the cost picture unchanged.
  * (vii) [P, by definition] Under a time-t prior, d = log₂(1/w_t(f)) − K(f|Π) includes the depth gap. A deep human, whose short descriptions are slow, is not generic, and fast shallow impostors can outweigh it.
  * *Open:* whether some fast hypothesis collects the base rate of uses within a tight schedule (open in the toy too).
* *So:* runtime removes the hypotheses that troll *by computation*: seekers and diagonalizers. It leaves the ones that troll *by omission*: P minus its unexercised parts, and wrappers around them. GA8 says the latter are bounded by the unexercised information.

## 7. Simulation [N]

**The setting** (`threadGA_generic.py`, 34 s).
* States {0,1}⁴, and H is all 2^16 functions. Exact Bayes, majority decoder, asks below 1 − α, decoder updated at every answer.
* Runs of n steps with z ↦ rot(z) ⊕ label; every run is scanned until its first mistake, and a hit causes a rerun.
* Humans are drawn from the stated prior. The adversary answers lazily and greedily, choosing at each scan the feasible committed step of largest minority mass. Its final human is the heaviest consistent function, and its transcript is replayed and checked.
* Every human met hits ≤ K_F/b and total information ≤ K_F.

| prior (α) | humans | E[K] | E[backstabs] | E[bs]·b/E[K] | committed mistakes / compensator | constructed: bs·b/K |
|---|---|---|---|---|---|---|
| rare insights p = 0.045 (0.05) | own prior | 4.25 | 0.723 | 0.735 (exact 0.735) | 0.723 / 0.720 | 0.97 |
| rare insights p = 0.009 (0.01) | own prior | 1.17 | 0.141 | 0.804 (exact 0.807) | 0.141 / 0.144 | 0.98 |
| nested chain (0.05) | own prior, exact | 0.12 | 0.017 | — | mass ≥ j = (α/3)^j | 0.73 (h₁₆: 16) |
| decision tree (0.05) | full prior | 2.43 | 0.10 | 0.18 | 0.168 / 0.167 | — |
| decision tree (0.05) | bands 6–45 bits, Occam learner | 7–33 | 0.6–2.7 | 0.29–0.35 | 1.0–3.7 / 0.12–0.18 | 0.60 (2% of the band match it) |
| decision tree (0.2) | same | 7–33 | 1.1–5.0 | 0.35–0.37 | 2.6–7.8 / 0.74–1.09 | 0.42 (16% match or exceed) |
| decision tree (0.05), bands [12,18), [24,30), [36,42) | band's own prior | 8–14 | 0.000–0.005 | 0.000–0.002 | ≈0 / ≈0.01 | 0 |
| same | flat over 6-bit bands | 12–17 | 0.005–0.045 | 0.001–0.012 | 0.005–0.055 / 0.001–0.025 | — |

**What the toy shows.**
* Calibration holds exactly under the learner's own prior.
* The rare-insight prior gives typical humans nearly the worst case: 0.74–0.80 of K/b in expectation.
* An Occam learner backstabs generic complex humans at about a third of the worst case, and the greedy adversary does at most about twice as well as a typical human.
* Matching the prior's complexity profile removes the effect.

**What it does not show.** Anything about natural priors at scale. With 16 states, every human is identified after at most 16 answers.

## 8. Proofs

**GA0.**
* (i) w̄ is computable given Π, so by the coding theorem K(f|Π) ≤ log₂(1/w̄(f)) + O(1).
* (ii) Σ_f w̄(f)·2^(d(f)) = Σ_f 2^(−K(f|Π)) ≤ 1 by Kraft, since distinct f have distinct shortest programs; then apply Markov's inequality.
* (iii) The first claim follows from K(f|Π) ≥ K(f|S,Π) − K(S|Π) − O(1). For the converse, if S is decidable, w̄(·|S) is computable given (S, Π), so K(f|Π) ≤ log₂(1/w̄(f|S)) + K(S|Π) + O(1).
* (iv) The coding theorem gives w̄(f) = 2^(−K(f) + O(1)).

**GA1.**
* (a) μ(f) = w̄(f)c(f)/B is lower semicomputable given (Π, B), uniformly (the same program for every Π), and Σμ ≤ 1. The conditional coding theorem gives K(f|Π,B) ≤ log₂(1/μ(f)) + O(1); rearrange, then use K(f|Π,B) ≥ K(f|Π) − K(B|Π) − O(1).
* (b) This is Markov's inequality.
* (c) c̃ = Σ_z 2^(−|z|)c_z is lower semicomputable, with E[c̃] ≤ B·Σ_z 2^(−|z|) ≤ B. Apply (a) to c̃, then use c_z ≤ 2^|z|·c̃.

**GA2.** The joint probability of (f_P = f, H_t) is w̄(f)·Π_i κ_i(action_i | H_{<i})·Π_{answers}1[f(y_i) = a_i]. By (Ind) the kernels do not depend on f, and normalizing gives the claim. For (G1_S), use the prior w̄(·|S) instead; then Pr_S[E|H_t] = ξ(E ∩ S)/ξ(S) ≤ ξ(E)/π_S.

**GA3.**
* (a) At step k the decoder writes the top label ℓ of ξ_{D_k}, where D_k contains every answer so far by (U). By GA2, Pr[P(y_k) ≠ ℓ | H_k] = 1 − ξ_{D_k}(ℓ) ≤ α.
* (b) ξ_{D_k}(ℓ_k) is at least the mass of C's consistent members that write ℓ_k, and at least 1 − α when the step is committed.
* (c) This is GA2's restricted form with E = {P(y_k) ≠ ℓ}. For the averaged statement, E_{w̄(·|S)}[N] ≤ E_w̄[N]/w̄(S) holds for every N ≥ 0.
* (d) Use linearity and the tower property.

**GA4.**
* (a) A backstab needs a committed mistake. So q_r ≤ Σ_k Pr[committed mistake at k | start] = E[Σ_k 1[committed]·u_k | start], by the tower property and GA3(a).
* (b) Let Z_r be the indicator that run r ends in a backstab. Z_r is observed, and E[Z_r | start] = q_r.
* (c) M_r = Π_{s≤r} λ^(Z_s)/(1 + (λ−1)q_s) is a nonnegative martingale with M₀ = 1. On the event, M_∞ ≥ λ^j·e^(−(λ−1)a). Ville's inequality (Fatou for an infinite horizon) bounds the probability by λ^(−j)·e^((λ−1)a). Take λ = j/a.
* (d) Each backstab lowers Φ_F by at least b. This is Theorem 4.7(b)'s reordering: the hit is listed right after the data the decoder used, where P's label had mass at most α. And Φ_F ∈ [0, K_F]. Finally E[K_F] = H(w̄_F).

**GA5.**
* *The posterior is confident.* By independence, the posterior of b_i before problem i is Bernoulli(p). So step 0 is committed with the default and is a mistake iff b_i = 1.
* *Each mistake is found at once.* The scan's first query finds it, so there is exactly one backstab per i with b_i = 1. The rerun has b_i in the data and succeeds.
* *Counting.* E[backstabs] = mp, and E[K_F] = Σ_i E[log₂(1/Pr(b_i))] = m·h(p). Also p/h(p) = 1/(log₂(1/p) + ((1−p)/p)·log₂(1/(1−p))), and ((1−p)/p)·log₂(1/(1−p)) ≤ log₂e because −ln(1−p) ≤ p/(1−p).
* *Concentration.* Apply the law of large numbers to #ones and to K_F = #ones·log₂(1/p) + #zeros·log₂(1/(1−p)).
* *(G2).* The set B_ε of vectors whose ratio is below (1−ε)·p/h(p) is decidable given (m, p, ε). By Chernoff, w̄(B_ε) ≤ 2^(−Ω(ε²mp)). By GA0(iii), its members have d ≥ Ω(ε²mp) − O(log m), which exceeds c for large m.

**GA6.**
* (a) Let ν(a) = w̄(cons(a)) and ν_S(a) = w̄(cons(a) ∩ S)/w̄(S) ≤ ν(a)/w̄(S) be the laws of the answer sequence under the learner and under the truth. The kernel factors cancel, by (Ind). So log₂(ν_S/ν) ≤ s surely. By the chain rule for relative entropy over answers whose locations are predictable, E_S[log₂(ν_S/ν)] = Σ_i E_S[KL(ξ^S_i ‖ ξ_i)].
* (b) Data processing onto {ℓ, not ℓ} gives KL ≥ kl(x‖y) with x ≥ β > α ≥ y. The binary kl is increasing in x and decreasing in y away from x = y, so kl(x‖y) ≥ kl(β‖α). Hence kl(β‖α)·E[count] ≤ Σ_i E[KL_i] ≤ s.
* (c) w̄(S_K) = Σ_{K(f)=K} 2^(−K(f) + O(1)) = 2^(−K) · 2^(K − K(K) + O(1)).

**GA7.** For a deterministic Π, h is consistent with D_n iff h's own transcript of length n equals a. So ν(a) = Σ_h w̄(h)·1[transcript_n(h) = a] is a semimeasure on L^n, and it is computable given (Π, n). Since W̄(D_n) = ν(a), the coding theorem gives K(a|Π,n) ≤ log₂(1/W̄(D_n)) + O(1). Add K_F.

**GA8.**
* *Upper bound.* K(f_P|Π) ≤ K(n) + K(a|Π,n) + K(f_P|a,n,Π) + O(1), and the last term is r_n + O(1), because D_n and (a, n) determine each other given Π. Substituting into GA7 gives Φ_F ≤ K_F − K(f_P|Π) + K(n) + r_n + O(1) = d + r_n + K(n) + O(1).
* *Lower bound.* The posterior ξ_{D_n}(f) = w̄(f)/W̄(D_n) is a computable distribution given (D_n, Π). So r_n ≤ log₂(1/ξ_{D_n}(f_P)) + O(1) = Φ_F + O(1).
* *(a)* follows from w(f_h) ≤ W(D_n).
* *(b)* ξ_{D_n}(P(y)) ≥ w(f_P)/W(D_n) = 2^(−Φ_F).
* *(c)* is GA4(d)'s argument.
* *(d)* r_{n′} ≤ Φ_F(D_{n′}) + O(1) ≤ Φ_F(D_n) − jb + O(1).
* *(f)* On that set, d ≥ jb − r − K(n) − O(1), by (c). Then apply GA0(ii).
* *The twin.* Φ_F = log₂(1/ξ_{D_n}(f_P)) with f_P ~ ξ_{D_n} given H_n, by GA2.

**GA9.**
* (a) The program "decode D from a shortest description; answer D's label on Q, and a fixed label elsewhere" has length K(D) + O(1). By symmetry of information (standard), K(D) = K(f_P) + K(D | f_P, K(f_P)) − K(f_P | D, K(D)) + O(1). Here K(D | f_P) ≤ K(Q_n | f_P) + O(1), and K(f_P | D, K(D)) ≥ r_n − O(log K_F). Under the universal prior K(f_P) = K_F + O(1). If the length is below K(f_P) − O(1), the program computes a different behaviour.
* (b) Deleting the branch changes no label on Q_n, removes β bits, and adds no steps.

**GA10.** For a fixed h with f_h ≠ f_P, consistency means that f_P's transcript equals h's. That has μ-probability at most max_a μ(transcript = a) = 2^(−H_∞). Take a union bound over I.

**GA11.**
* (a) By GA2, an answer at y carries information X with E[X | H] = H(ξ_y). The grouping {top, rest} gives H(ξ_y) ≥ h(u). The min-entropy gives H(ξ_y) ≥ log₂(1/top) ≥ log₂(1/(1−u)), which is at least 1 when u ≥ 1/2. The sum over all answers telescopes to log₂(1/W̄(D)) ≤ K_F; take expectations, using X ≥ 0 and the predictability of {i ≤ N}.
* (b) Let R_i = H_{1+λ}(ξ_i) and X_i = log₂(1/ξ_i(a_i)). Then E[2^(λ(R_i − X_i)) | H] = 2^(λR_i)·Σ_ℓ ξ(ℓ)^(1+λ) = 1, so Z = 2^(λΣ_{i≤N}(R_i − X_i)) has E_w̄[Z] = 1, and N is bounded for finite H. Z is computable given (Π, λ), so GA1 gives λ(ΣR − ΣX) ≤ d + O(1). Also ΣX ≤ K_F. At an ask, R_i ≥ H_{1+λ}(Bern(α)): grouping cannot raise a Rényi entropy, and H_{1+λ} ≥ H_∞ ≥ 1 if top < 1/2.
* (c) A run with no committed mistake is the human's chain and succeeds under (A2). So failure ≤ Σ_k E[1[committed]·u_k | start] ≤ nα = ε. Then h(ε/n) ≥ (ε/n)·log₂(n/ε).

**GA12.**
* (ii) Being the diagonal requires computing the decoder.
* (iv) and (vi) follow by inspection.
* (vii) is the definition with w_t.
* (i) and (v) are quoted from `malign-prior-toy` (its sections on time bounds and on the wrapper floor). They are not reproved here.
