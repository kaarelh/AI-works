# Referee report: threads GA (generic trolls) and GB (generic location)

*Referee 11 (Claude). Notes refereed: `research/threadGA-generic-trolls.md`, `research/threadGB-generic-location.md`, with their scripts and outputs. Setting checked against Sections 2–4 and 6 of `paper/verified-slack-imitation.tex`. No existing file was edited.*

**Files written here.**
* [`referee11_checks.py`](referee11_checks.py) and its output [`referee11_checks.out`](referee11_checks.out) (91 s).
* The reruns, [`referee11_rerun_GA.out`](referee11_rerun_GA.out) and [`referee11_rerun_GB.out`](referee11_rerun_GB.out), with `.time` files.

## Verdicts by priority

**1. GB2, threshold Bayesian search: correct.** I checked each step and found no counterexample.
* *Accounting.* T_s ≥ m_s·c_γ holds because each phase-1 miss has current label mass 1 − μ′ ≤ 1 − γ, and Φ is monotone. T_s ≥ 1 holds by Lemma bit applied at D_s, the data the run's decoder used, and monotonicity again.
* *Diffuse searches.* At D″ the eventual hit is unqueried, so its label mass is at most its doubt, which is below γ. Monotonicity gives a drop of more than log₂(1/γ). Adding the phase-1 misses gives T_s ≥ m_s·c_γ + log₂(1/γ).
* *Doubt.* μ′_k is the posterior predictive at a notebook fixed by the run, against a committed label fixed by the run. It needs nothing but the posterior, so it is computable wherever the decoder is. It must be the same posterior as the one that defines Φ (see the strengthening below).
* *Every rejection ends in a hit within n₀ queries.* Lemma early gives f_P < n₀. Both phases query distinct steps below n₀, and phase 2 covers every unqueried one.
* *Numerical stress test* (§A). Two random families with exact Bayes (finite structured classes; mixtures of products with rare mutations). Phase 1 took the largest or the *smallest* doubt ≥ γ; phase 2 went in step order or with true mistakes last. Over 19,290 searches, 11,814 of them diffuse, no checked inequality failed (cost ≤ n₀, both T_s inequalities, both totals).
* *Tightness.* The silent instance (insight value known, η = ½, adversarial phase-2 order) reaches 0.28–0.41 of the note's bound, and 0.40–0.61 of the max form below. The scan's n₀K is really attained: put one fair coin per problem at step n₀ − 1 and let the human never match the tie-break. B_γ then pays 1 query per bit. So the improvement on the worst case is real. Its size at the paper's scale is modest (issue O3), and the recommendation to use it in place of the scan overclaims (issue O2).
* *Strengthening (tested).* The proof goes through verbatim if the learner also keeps each rejection as the datum "h disagrees with the run below n₀". P satisfies this datum by Lemma early, so it is legitimate for any class. Doubts and Φ must both include it. This is the 'cond' learner in §A1: 0 violations. It is the potential that deferral needs (GB5, GB8(b)), and it repairs GB1(a) (issue O1).

**2. GB3, modular programs: correct.**
* *Pathwise check* (§C). On the note's own M1, imported unchanged, with 24 adversarial and 24 prior codes, 0 of 3,566 search queries failed to reveal a new entry. The maximum total was 45 ≤ |E| = 48.
* *Assumptions the proof uses:*
  * (i) Dep(y) is known to the learner. All programs share the dispatch; the K bits are content only.
  * (ii) The output is separable: an answer reveals each called entry's value.
  * (iii) Every entry is uniform on [q] and decoded by a fixed tie-break. This is what gives doubt ≥ 1 − 1/q at first calls.
* (i) is stated everywhere. (ii) and (iii) are in the model but missing from the summaries, and (iii) is load-bearing (issue O5).

**3. GB1, GB4–GB8: correct, with the exceptions listed below.**
* GB1(b)–(e) check, including the rearrangement, Chebyshev and Arikan steps, the (1/max λ + 1)/2 minimization (it reduces to t − t² ≥ 0) and Massey's bound.
* GB4(a), GB5 and the GB6 formulas check. The lattice sum is 1/ln 2, and its oscillation is about 10⁻⁵.
* The tags are mostly honest. Exceptions: GB1(a) [P] is conditional on the class (O1); GB7's constants (O4); and "Θ(n) [P per rejection]" in the brief. What is proved is (|U|+1)/2, which is Θ(n) only when m = O(2^j).

**4. GA1, the transfer lemma: correct.**
* d(f|Π) is the standard deficiency for a measure computable from Π. μ = w̄c/B is uniformly lower semicomputable from (Π, B), and the conditional coding theorem gives (a).
* Adaptivity is handled correctly: the source is part of Π, and the note rightly says sup_σ E ≠ E sup_σ.
* Protocol randomness is indeed not needed. GA2's calibration is over P alone, so a fixed seed in Π suffices. The pathwise-in-P guarantees that come from protocol coins (the U stream, audits) are then replaced by P-averaged ones.
* Small: (c) drops K(B|Π) (M1).

**5. GA3–GA11.**
* *GA3–GA5: correct.* The martingale in GA4(c) is right, and with λ = j/a Ville's inequality gives e^(−a)(ea/j)^j. GA5's bound ((1−p)/p)·log₂(1/(1−p)) ≤ log₂e and the Chernoff-plus-GA0(iii) step check.
* *GA6:* (a), (b) and (d) are correct. (c) is false as stated, but fixable (E1).
* *GA7–GA10: correct* up to log terms (M6). The summary drops the K(n) term (O6).
* *GA11:* (a) and (b) are correct, including the Rényi identity E[2^(λ(R−X))] = 1. (c) is correct for the silent class, but in general it needs (A2) on all of supp w̄ (O7).

**6. Simulations reproduce.**
* GA: 34 s, output identical to the stored file apart from the timing line. GB: 199 s, also identical.
* The quoted numbers match the outputs, except GA's α = 0.2 table row (E2) and the exactness of the nested-chain masses (M2).

## Issues

### Errors

**E1. Error. GA6(c), and the claims in brief 1 and §3 that rest on it.**
* *What is wrong.* The recalled count #{x : K(x) = K} = 2^(K−K(K)+O(1)) does not hold for every universal machine. Take a universal prefix machine U and set U′(q) = U(q) when |q| is even, and U′(q0) = U(q) when |q| is odd. The domain stays prefix-free, and K_{U′} ≤ K_U + 1, so U′ is universal. But every K_{U′}(x) is even. For odd K the class S_K is empty, so w̄(S_K) = 0 and s = ∞.
* *Why it matters.* The failing half is the lower bound on w̄(S), which is the one s = log₂(1/w̄(S)) needs.
* *The standard fact* is Chaitin's #{x : K(x) ≤ K} = 2^(K−K(K)+O(1)).
  * Upper half: Σ_K N_{≤K}·2^(−K) ≤ 2, and the coding theorem.
  * Lower half: strings of length K − K(K) − c.
* *Fix.* Use the band S_{K,c} = {f : K − c < K(f) ≤ K} with c a large enough machine constant. Then N_{≤K} − N_{≤K−c} ≥ 2^(K−K(K)−O(1)), because K(K−c) ≥ K(K) − K(c) − O(1). Hence w̄(S_{K,c}) = 2^(−K(K)±O(1)), and s ≤ K(K) + O(1) ≤ log K + 2 log log K + O(1).
* *Also.* Write "s ≤", not "s ≈".
* *Unaffected:* the 10⁶-bit example (12.3 + O(1) answers) and GA6(d).

**E2. Error (minor impact). GA §7 table, row "decision tree (0.2)".** The stored output, which my rerun reproduces exactly, differs from the row in four places:

| column | note | output |
|---|---|---|
| backstabs | 1.1–5.0 | 1.12–5.15 |
| committed mistakes | 2.6–7.8 | 2.62–8.11 |
| compensator | 0.74–1.09 | 0.744–1.105 |
| constructed human: share of the band that matches or exceeds it | 16% | 25% |

The α = 0.05 row and all other quoted numbers match. *Fix:* replace the row with the output's values.

### Overclaims

**O1. Overclaim. GB1(a); also §6, "B stays within n₀".**
* *What is wrong.* supp λ ⊆ {k < n₀} needs (G1c): either w is supported on valid hypotheses, or the toy's chain equality with σ = 0 (the toy's proof gives f_h < n, which is n₀ only then). A Solomonoff-type class contains invalid hypotheses. With σ > 0, such a hypothesis can agree with the run below n₀ and disagree only above it. λ then puts mass above n₀, and B can spend up to σ queries before reaching f_P: cost up to n, not n₀.
* *Fix.* Compute λ from the posterior that includes the datum "h disagrees with the run below n₀", as in the strengthening above. Then supp λ ⊆ {k < n₀ : μ_k > 0} for every class, and (a) holds for every P satisfying (A1)–(A3′). Calibration, GB1(b), still needs (G1) restricted to valid programs.

**O2. Overclaim. GB brief 7: "use B_γ in place of the scan … it costs nothing in the worst case".** The claim holds for the per-rejection n₀ and for the K-amortized bound under exact Bayes with P ∈ H. Replacing the scan loses two things.
* *The per-problem cap.* Proposition any-learner caps the cost at 2n₀ per problem for any learner. Its proof uses the fact that scan queries are chain notebooks, each asked at most once per problem. B_γ can query, and hit, off-chain notebooks after f_P. So for a learner that is not exact Bayes over a class containing P, the per-problem cost is no longer capped.
* *The U and H streams.* Dropping them loses Theorem main(d)'s 4Λ under bounded setback, and its review, decision and pointer bounds.
* *Fix.* Alternate B_γ with the scan, as in GB1(e). Each search then makes at least as many scan queries as B_γ queries, so the any-learner count gives 2n₀ per problem again, while GB2's bound at most doubles. If the bounded-setback and pointer bounds are wanted, keep U and H; that costs at most another factor 2.

**O3. Overclaim. GB2's reading in §2 ("the informative form is (b): O(K), plus n₀ per diffuse rejection") and the brief's "a log factor below VSI's 2n₀K".**
* *The reading.* At γ = log₂n₀/n₀ the phase-1 coefficient 1 + 1/c_γ ≈ 0.69·n₀/log₂n₀ is not O(1). The O(K) reading needs γ to be a constant.
* *The size.* At the paper's scale the improvement is modest. With F = total/K (§B):

| n₀ | note's F (sum form) | max form | max form, best γ | scan | S,U,S,H |
|---|---|---|---|---|---|
| 20 | 12.9 | 9.1 | 6.5 | 20 | 40 |
| 30 | 16.4 | 11.5 | 8.6 | 30 | 60 |
| 40 | 19.6 | 13.8 | 10.5 | 40 | 80 |

* *Fix.* State the max form K·max{1 + 1/c_γ, n₀/log₂(1/γ)}. It is valid, since each search costs at most T_s times that maximum. Quote this table, and say "O(K) plus n₀ per diffuse rejection" only for constant γ.

**O4. Overclaim. GB7 constants, and §4 "at the paper's scale".**
* *What is wrong.* "Exercised rules carry ≈ log₂(nT)/2 bits" omits each rule's log₂d + log₂q overhead, which is 5–7 bits at these scales. The exact computation in §E, with the note's own cost assumptions (n/4 per single-use rule, or per rare rule), gives:

| quantity | note | exact |
|---|---|---|
| log-uniform, with deferral (n = 64, T = 300) | 0.2 | 0.11 |
| log-uniform, without deferral | 1.3 | 0.64 |
| ratio of log-uniform to universal-type | 18 | about 9 |

* The universal-type figures are close (0.012 against 0.013; 0.007 at n = 30).
* *Fix.* Include the overhead: bits per exercised rule ≈ log₂(nT)/2 + log₂d + log₂q. The asymptotic Θ(n·K_ex/log²(nT)) is unaffected.

**O5. Overclaim. GB brief 3 and §3.1 ("every program is easy, generic or not"; "content of shared code is cheap").**
* *What is wrong.* The proof also uses (ii) separable outputs and (iii) uniform entries with no default value.
  * Under (iii) with a default: give an entry its default with prior 1 − δ. First-call doubts are then about δ, B_γ is diffuse, and M1 becomes a rare-insight class even with visible dispatch.
  * Under (ii): with a non-separable output, such as a sum of called entries, an answer no longer reveals each entry, and "every query reveals a new entry" fails.
* *Fix.* Name (ii) and (iii) next to "visible dispatch". GB8(b) already says "substantial prior doubt"; the summaries should too.

**O6. Overclaim. GA brief 1 ("equal, up to d").**
* *What is wrong.* GA8 holds up to d + K(n) + O(1), and the K(n) term is intrinsic to the method: GA7's semimeasure must be weighted over n.
* *Why it matters.* Once K(n) > b, which happens after a few dozen answers at α = 0.05, GA8(b) says nothing about a single confident mistake. GA8(f) bites only for jb > r + K(n).
* *Fix.* Write "up to d + K(n)" and add that sentence. Indexing by a problem number t (K(t) in place of K(n)) is a possible improvement.

**O7. Overclaim. GA11(c), and brief 7 ("failure at most ε on every run").**
* *What is wrong.* "A run with no committed mistake succeeds" needs (A2) for P. Under (G1), P is drawn from all of w̄, which typically includes programs whose own chain fails.
* *Fix.* Assume w̄ is supported on programs satisfying (A2) on the problems, as the silent class is, or define failure as "the run differs from the human's chain". In the individual version, 2^(d+O(1))·εT needs K(T|Π) (or K(εT|Π)) in the exponent.

**O8. Overclaim. GA12(ii), tagged [P]: "must run exact Bayes over H".** A diagonalizer must compute the decoder's label at the steps where it diagonalizes. That can be cheap, for instance at default labels. *Fix:* "must compute G_D at its targets", and drop the [P] tag, or keep it only for diagonalizers that disagree at every confident step.

### Minor

* **M1. GA1(c).** The bound is missing K(B|Π). Write 2^|z|·B·2^(d(f|Π)+K(B|Π)+O(1)), or put B in Π.
* **M2. GA brief 5, "exactly (α/3)^j".** The masses are (α/3)^j·(1 − (α/3)^(17−j))/(1 − (α/3)^17): 0.983·(α/3)^16 at j = 16, which is also what the output shows. Write "≈", or give the exact formula.
* **M3. GB4(b).** Non-firing contexts are uniform on the 2^j − 1 values other than v, so the exclusion factor is (1 − 1/(2^j − 1))^m. Its ratio to the note's (1 − 2^(−j))^m is above 0.99 throughout (§D). Also, the number of distinct values is ≥ n(1 − (n−1)/2^(j+1)).
* **M4. GB5, "R₁'s problem passes on rerun".** After the correction, the rerun visits fresh notebooks, where other unknown rules may fire. *Fix:* "R₁'s rule-i mistakes are fixed", or assume the other rules are certain on the rerun too.
* **M5. GB2 corollary, "O(1) verifications per insight problem".** Counting the verifications of problems without an insight, it is about 1/η + 1, as the paper says. The condition q ≥ 16/η is the right one.
* **M6. GA, assorted.**
  * The "probabilistic twin" paragraph contains an untagged troll-chain sketch; tag it [S].
  * GA9(a): K(Q_n|f_P) ≤ K(Π) + K(n) + O(1), and the error term is O(log K(D)), not O(log K_F).
  * GA0(i): w̄ is computable given Π only for finite H. In general it is lower semicomputable given w(H), which suffices for (i). The converse in (iii) needs w̄(S) computable.
* **M7. GB E1.** The "1729" bound uses the mean K against the maximum Q over humans. Harmless (FV rules cost ≥ 6.4 bits each), but compare per human.
* **M8. GB brief 6.** "30–80% wrong runs" holds at n = 64 only (FV at n = 16: 15%). "The same budget of 300 queries" is CI's alone; VSI used 36–4875.

## What holds

GB2, GB3, the silent-class match, and GB8's conclusion that *exposure*, not genericity, makes location cheap. GA3–GA5, GA7–GA10 (with the K(n) caveat), and GA6(d)'s Occam-mismatch effect. The answer to the user's question that the two notes give together holds up. Genericity rules out *amplified* trolling: beyond d + K(n) bits, and beyond the unexercised information. It does not make the scheme cheap, because the costly structure (rare, single-use, incompressible behaviour) is itself generic under natural priors.
