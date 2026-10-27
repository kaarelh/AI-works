# Referee report: boxes-tilting (counterexample lens)

**Verdict.** contains false statements. The three assigned results (thm:boxes, prop:tilting, thm:janson) are correct as stated, apart from small constant and convention slips. Two claims built on them are false: the relative-error claim for the geometric-mean estimate right after thm:janson, and the use of prop:tilting for integer-weight thresholds in sec-part2.

**What was checked.** Scratch scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad: tilt.py, tilt2.py, tilt3.py, wtilt.py, wsearch.py, jan.py, jan2.py, boxes.py. No repository file was edited.

thm:boxes, checked by hand:
- I re-derived Q̂(x) = D(x)/Ẑ · Σ_{T∋x} ρ(T) and the identity Ẑ·E W = Σ_x D(x)C(x)·avg_{T∋x} ρ(T), which lies in [ρ_min, ρ_max]·p.
- The min/max-product pass is correct: each derivation uses each box at most once by decomposability, so per derivation the extremes are ∏ m̂_j/u_j and ∏ m̂_j/ℓ_j.
- The union bound δ/2 + δ/2 is correct.
- Edge cases m̂_j = 0 and ℓ_j = 0 only loosen the output (ρ_min = 0 or ρ_max = ∞), so soundness survives.
- Without domination the lower bound still holds.
- The bound ρ_max/ρ_min ≤ (1+ε/(4L))^{2L} ≤ e^{ε/2} is correct, provided m̂_j lies in [ℓ_j, u_j], which holds for KL intervals.

thm:boxes, checked numerically (boxes.py): I enumerated a 9-variable envelope with 4 overlapping boxes and 5 derivations. Over 2000 random product distributions, biased m̂ and random intervals, p always lay in [Ẑ·EW/ρ_max, Ẑ·EW/ρ_min], with E W computed exactly.

prop:tilting, checked by hand:
- θ exists by monotonicity and the intermediate value theorem on [E_D S, k_+).
- The Darroch step is correct: with an integer mean t, every mode m has |m − t| < 1, so the mode is uniquely t.
- The Chebyshev window of 4σ+1 integers, σ ≤ √k/2, and p ≥ Z_θ·Q_θ(S=t) all check out.

prop:tilting, checked numerically:
- tilt.py: 20,000 random instances (heterogeneous, tiny, mixed p_j). The mode equalled t every time, and the largest K/bound was 0.44. Asymptotically K ≈ 1.25√k.
- tilt2.py: with some p_j in {0,1}, the largest K/bound was 0.39.
- tilt3.py: if θ is off so that |E_Q S − t| = 1/(4k), the mode was still t in all 39,903 cases.

thm:janson, checked by hand:
- The bound matches Alon–Spencer Thm 8.1.1, which sums Δ over ordered pairs and uses the exponent Δ/(2(1−ε)). It is consistent with thm:janson-general, which uses unordered pairs and Δ/(1−b).
- The O(Σ|cl_i|²·d) cost holds, since Σ_i Σ_{j~i}(|cl_i|+|cl_j|) ≤ 2Σ_i|cl_i|²d.

thm:janson, checked numerically:
- jan.py: exhaustive enumeration on 2,860 random unate CNFs (n ≤ 12), including repeated clauses, q_i in {0,1}, and q_i near 1. No violations of the stated sandwich.
- jan2.py: the ordered product form ∏(1−b_i+d_i) from thm:janson-general, with clauses sorted by decreasing b_i, had no violations on 3,000 more instances and was far narrower when ε_0 is near 1.
- Example sentence: Δ ≈ 0.309 gives ratio e^{0.155} = 1.167, which matches the table.

Weighted-threshold counterexample: wtilt.py and wsearch.py compute the optimal Chernoff K exactly.

Citations: the Darroch, Alon–Spencer, Janson 1990, Harris 1960 and Riordan–Warnke bibliographic data look right. I could not fetch arXiv (no DNS), so I could not check the scope of the GKM 2010 and GKMSVV 2011 results.

## Findings

### 1. [major] sec-envelopes.tex, paragraph after thm:janson: 'the deterministic estimate sqrt(M·Me^{Δ/(2(1−ε_0))}) has relative error O(ε), however small p is'

**Problem.** This is false unless ε_0 stays bounded away from 1. The width of the sandwich is e^{Δ/(2(1−ε_0))}, which is unbounded as ε_0 → 1 even when Δ ≤ ε. That is exactly the tiny-p regime where p is small because one clause is almost always violated.

Counterexample: clauses (¬s∨¬a) and (¬s∨¬b), with q_s = q_a = sqrt(1−η) and q_b = 0.005. Then Δ ≈ 0.0100, ε_0 = 1−η and p/M = 1.0025. But the upper bound over M is e^{Δ/(2η)}:
- η = 1e-4 gives e^{50}, and the geometric-mean estimate is off by a factor e^{25};
- η = 1e-6 gives e^{5000}, and the estimate is off by e^{2500}.
(jan.py)

**Proposed fix.** Either add the hypothesis ε_0 ≤ 1/2 (then the ratio is at most e^{Δ}, and the geometric mean has relative error at most e^{Δ/2}−1), or use the ordered product form already proved in thm:janson-general.

Order the clauses by decreasing b_i = D(B_i), set d_i = Σ_{j<i, j~i} D(B_i∧B_j), and state
  M ≤ p ≤ ∏_i(1−b_i+d_i) ≤ M·exp(Σ_i d_i/(1−b_i)).
In the example this gives width 1.005. On 3,000 random instances the product form was never violated, and its largest log-width was 38 against 5·10^4 for the standard form (jan2.py).

State the relative-error claim for this form, or under ε_0 ≤ 1/2.

### 2. [major] sec-part2.tex (≈ line 172, 'Thresholds with side conditions'): 'the soft envelope β^{w·x−θ} … give K=O(√n) (\cref{prop:tilting})'. This is outside my assigned section, but it uses prop:tilting.

**Problem.** prop:tilting covers only sums of unit-weight {0,1} blocks. For integer weights under a product D, the best Chernoff/tilting envelope can have K = p^{−Θ(1)}, so the cited O(√n) does not follow and is false in general.

Counterexample: S = (k+1)·y + Σ_{i≤k} x_i with q_y = η, q_x = 1/2 and t = k+1, so p = η exactly. Minimising over θ gives:
- K = 2^{25.7} at k = 20, p = 2^{−40};
- K = 2^{52.1} at k = 40, p = 2^{−80};
- K = 2^{131} at k = 100, p = 2^{−200}.
(wtilt.py)

Even under the uniform D, a threshold t that w·x cannot reach exactly inflates K by e^{θ·gap}. For example, w = (1, 58×26) with t = 1462 gives K = 35.8 at n = 27 (wsearch.py).

**Proposed fix.** Restrict the claim to unit weights (or weights bounded by a constant, with t replaced by the least achievable value of w·x that is ≥ t), and prove that weighted analogue. Otherwise drop '(prop:tilting)' and report K = 37 only as an empirical observation for that instance.

### 3. [minor] sec-envelopes.tex, thm:boxes, last step of the proof: 'ρ_max/ρ_min ≤ e^{ε/2}, and thm:envelope(iv) applies … with ε/3'

**Problem.** The output ratio is (u/ℓ)(ρ_max/ρ_min) ≤ (1+ε/3)e^{ε/2}. This is at most 1+ε only for ε ≤ 0.511; at ε = 1 it is 2.198 > 2. So 'tight' (U ≤ (1+ε)L) is not proved for ε in (0.51, 1].

The code is inconsistent with the paper: envelope.py's envelope_estimate uses eps_is = eps/2 together with box_eps = eps/(4L). The resulting ratio (1+ε/2)e^{ε/2} exceeds 1+ε for every ε > 0, for example 1.1038 at ε = 0.1.

'Relative width' is also undefined: it could mean u_j/ℓ_j − 1 or (u_j−ℓ_j)/m̂_j.

**Proposed fix.** Define relative width as u_j/ℓ_j − 1. Then either assume ε ≤ 1/2, or use box widths ε/(8L) (so ρ_max/ρ_min ≤ e^{ε/4}) and run the importance-sampling stage at ε/4. Since (1+ε/4)e^{ε/4} ≤ 1+ε for all ε ≤ 3, the box cost becomes O(rL²R log(r/δ)/ε²) with a 4× larger constant. Align the code with whichever split the paper states.

### 4. [minor] sec-envelopes.tex, thm:boxes, cost claims: 'tight after O(K log(1/δ)/ε²) samples' and 'estimating the boxes costs O(rL²R log(r/δ)/ε²)'

**Problem.** Three gaps:
- K is unknown, so the importance-sampling stage has to be the sequential doubling procedure of thm:envelope(iv). That procedure costs O(K(log(1/δ)+log log K)/ε²), and the theorem drops the log log K term. The theorem also speaks of 'a level-δ/2 KL interval', but the sequential version needs per-stage levels summing to δ/2.
- The fixed box sample sizes Θ(L²R log(r/δ)/ε²) need R to be known. If it is not, a sequential rule adds log log terms.
- The relative-width condition holds only with probability 1−δ/2, so the completeness probability is 1−O(δ).

**Proposed fix.** State the sample bound as O(K(log(1/δ)+log log K)/ε²) using the sequential procedure at total level δ/2. Say that R is an input (or that box estimation is sequential), and give the completeness probability as 1−2δ.

### 5. [minor] sec-envelopes.tex, thm:boxes: 'each costing O(|C|+|Φ|+LR max_j|B_j|) in expectation'

**Problem.** Computing W = C(x)/φ(x) requires evaluating φ(x), which counts the satisfied derivations. That means evaluating every box leaf B_1,…,B_r at x, at cost Σ_j|B_j| (up to r·max|B_j|). The stated bound does not include this unless |Φ| is meant to include the box circuits; the definition of |Φ| does not say so.

**Proposed fix.** Give the per-sample cost as O(|C| + |Φ| + Σ_j|B_j| + LR·max_j|B_j|), or define |Φ| to include the sizes of its box circuits. φ only needs evaluating when C(x) = 1, but in the worst case the cost is the same.

### 6. [minor] sec-envelopes.tex, prop:tilting: 'choose θ ≥ 0 with E_{Q_θ}S = t' and the proof step 'so its mode is t'

**Problem.** θ is the root of a transcendental equation, so an algorithm can only approximate it. The proof needs E_Q S = t exactly to conclude that the mode is t. If the mean lands in (t, t+1), the mode may be t+1, and the fallback bound loses a factor e^{θ}.

The efficiency claims around the proposition also lack hypotheses:
- Z_θ needs the exact p_j, but for unit weights and exact p_j, p itself is computable exactly by an O(k²) DP.
- Exact block-by-block sampling of Q_θ needs samples from D | g_j = b, and rejection sampling costs 1/min(p_j, 1−p_j), which can be exponential.
So statements such as 'sampled block by block', 'explains all but O(log k) bits … sampling pays for the rest' and 'applies verbatim … (boxes)' are only meaningful under extra hypotheses that are never stated.

**Proposed fix.** Compute θ by bisection until |E_{Q_θ}S − t| ≤ 1/(4k). Darroch's refined intervals keep t as the mode; in 39,903 perturbed instances the mode was always t (tilt3.py).

State the operative setting explicitly: the g_j are boxes with min(p_j, 1−p_j) ≥ 1/R. Each derivation then has L = k box leaves, θ is chosen from the estimates p̂_j, and the same mode argument applied to Q̂ gives K ≤ e^{ε/2}·(4/3)(2√k+1), with box cost O(k³R log(k/δ)/ε²) by thm:boxes. The alternative is blocks small enough to enumerate exactly, as in tilting.py.

### 7. [minor] sec-envelopes.tex, proof of thm:janson: 'Flip the variables that occur negatively; then every B_i is a principal up-set {x : x_{S_i}=1}'

**Problem.** The sign convention is backwards. B_i = [cl_i = 0] requires positive literals to be 0 and negative literals to be 1. For an all-positive (monotone) clause nothing is flipped, and B_i = {x_{S_i} = 0} is a down-set. Flipping the negatively occurring variables turns every B_i into a principal down-set.

The same slip appears in sec-part1 ('after flipping the negative variables, every B_i is increasing'; after that flip the A_i are increasing, so the B_i are decreasing) and in the janson.py docstring. The conclusions survive, because Harris and Janson are invariant under flipping all coordinates, but the sentences as written are false.

**Proposed fix.** Say 'flip the variables that occur positively', or 'flip the variables so that every literal is negative; then B_i = {x_{S_i} = 1}'. Make the same correction in sec-part1 and the docstring.

### 8. [minor] sec-envelopes.tex, thm:janson statement: 'M ≤ p ≤ M exp(Δ/(2(1−ε_0)))'

**Problem.** If ε_0 = 1, the upper bound is undefined (0·e^{∞}). This happens with an empty clause, or when some clause's literals are all false almost surely because the relevant q_i are in {0,1}. The statement does not exclude this case.

**Proposed fix.** Add 'if ε_0 < 1; if some D(B_i) = 1 then p = M = 0'. Alternatively, use the product form ∏(1−b_i+d_i), which stays finite and tight in this case: for a duplicated clause with b = 1−η it gives exactly p = η.

### 9. [minor] sec-envelopes.tex, example after thm:janson: '…give p≈4.7·10^{-7} and an interval of ratio 1.17 in one second'

**Problem.** Table tab:janson (n = 2·10^5, 6·10^4 clauses, width 12) reports 30.8 s, not one second. The value 4.7·10^{-7} is the geometric mean of the certified interval [4.34, 5.06]·10^{-7}, not a known value of p.

**Proposed fix.** Write 'certify p ∈ [4.34, 5.06]·10^{-7} (ratio 1.167) in about 30 s of Python'.

### 10. [minor] sec-envelopes.tex, last sentence: 'with D(B_i) and D(B_i∧B_j) estimated rather than computed; we have not worked out the resulting error budget'

**Problem.** This contradicts thm:janson-general in sec-part1. That theorem states exactly this procedure (estimate b_i and Δ by sampling) with soundness, completeness conditions (max b_i ≤ 1/4, Δ ≤ ε/64) and a cost bound. It is also proved directly via the Boppana–Spencer argument, without needing Riordan–Warnke.

**Proposed fix.** Replace the sentence with a pointer to thm:janson-general.

### 11. [minor] sec-envelopes.tex, paragraph after prop:tilting: 'the integer-weight case can also be computed exactly by dynamic programming over S, and real weights have a deterministic FPTAS under product distributions \cite{gkm2010,gopalan2011fptas}'

**Problem.** The DP over S is pseudo-polynomial: it runs in time poly(k, Σ|w_j|), which is polynomial only for polynomially bounded weights. The two cited works state their FPTAS for counting knapsack solutions, which is the uniform measure with non-negative integer weights. I could not confirm, because I had no network access, that they state the arbitrary-product-distribution version that the sentence attributes to them.

**Proposed fix.** Say 'pseudo-polynomial'. For product distributions, cite the specific theorem, or give the reduction (weighted counting, or the ROBP construction under product measures).

### 12. [minor] sec-envelopes.tex, after lem:K: 'E=∧_{i≤m}(x_i∨y_i) … has relative variance (10/9)^m−1 under every reweighting of its ∨-edges' (not one of my assigned results, but in the same file)

**Problem.** Under the uniform D, reweighting the ∨-edges with a proposal probability α gives a per-clause relative second moment of (2/9)(1/α + 1/(1−α) + 1). This is at least 10/9, with equality only at α = 1/2. So the variance is at least (10/9)^m − 1, not exactly that under every reweighting. The constant 10/9 is also specific to q = 1/2: for q_x = q_y = q the per-clause factor is (4−3q)/(2−q)², which is about 1.073 at q = 0.3.

**Proposed fix.** Write 'has relative variance at least (10/9)^m − 1 under every reweighting of its ∨-edges (uniform D), with equality for the mass-proportional one'.
