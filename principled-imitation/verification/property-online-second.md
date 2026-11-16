# Second check of the part property-online

Second checker's report on `proofs/property-online.md` (the proof file) and on Sections 8.4 and 8.5 of `note.md` (source: `research/sections/property-online.md`, where they are numbered 8.3 and 8.4). I did not edit the note, the section source or the proof file.

**How I checked.** I read Sections 0 to 4, 6, 7.3 to 8.2 and 11 of the proof file in full, and the section source and the assembled note (Sections 8.4 and 8.5 of `note.md` are identical to the section source apart from the two headings; I compared them with `diff`). Every statement listed in Part 1 I re-derived by hand, step by step, recomputing every constant. Where it was cheap I tested it with my own script, `verification/code/property-online_second_checks.py` (saved output: `verification/code/property-online_second_checks.out`), written independently of the scripts in `proofs/code/`: scores are computed from the definitions of the tests as sets, not from the score tables in the proofs. I read the editor's saved output `proofs/code/property-online_editor_checks.out` but did not rely on it. I did not read any of the cited literature in this session; no statement below depends on it.

## Part 1. The statements examined, with verdicts

**Which statements.** From Section 11.2 and 11.4 of the proof file: statements the note uses and that were seen by the editor only, or by one checker besides the editor: Example 2.5 (editor only), Proposition 3.9 (adversary and editor; not the check report), Proposition 6.7 (editor only), the numbers of answers needed after Theorem 6.2 (adversary and editor), Proposition 4.2 in its restricted form (changed after verification; both verifiers asked for the restriction). Statements written or changed by the editor after verification that the note does not use: Proposition 2.4 (new proof), Proposition 3.10, Proposition 6.6 (repaired), Lemma 1.4(b) (second form on [−1, 1]). In addition, as asked: Theorem 3.3 (Rule NH, Theorem Pr5 of the note) and Theorem 6.2 (with Lemma 6.1 and Theorem 6.3, Theorem Pr6 of the note), re-derived once more.

### 1.1 Example 2.5 (editor only; used in the note) — CORRECT

*Statement.* For every way of choosing among the minimisers of the rule of Theorem 2.1 there are a stateless deterministic human f: X → {0, 2} and distinct questions with N_n(B) ≥ min(⌊n/2⌋, N*) for every n; for η = 1/√n, δ = 1/2, β = 1/(2n) the right side is at least ½·√n·ln n.

*Re-derivation.* (1) The score table: I recomputed the scores of the answers 0, 1, 2 from the definitions of B and D at the three types. Type e: (x, 1) ∈ B only, (x, 2) ∈ D only, so 0, β·sinh(ηN), δ·sinh(η·S(D)). Type o: (x, 1) is in B and in D, so 0, β·sinh(ηN) + δ·sinh(η·S(D)), 0. Type ō: (x, 0), (x, 2) ∈ D, (x, 1) ∈ B, so δ·sinh(η·S(D)), β·sinh(ηN), δ·sinh(η·S(D)). All as stated. Since f never takes the value 1, S(B) = N_t(B).
(2) Round 2k + 1 (type e, S(D) = 0, N < N*). The minimisers are 0 and 2, and also 1 when N = 0 (all three scores vanish; the proof covers this case, since it treats a_t(x) = 1). The three increments: a = 0, f = 2: g(B) = 0, g(D) = 0 − 1 = −1; a = 2, f = 0: g(D) = 1 − 0 = +1; a = 1, f = 2: g(B) = 1, g(D) = 0 − 1 = −1. Correct.
(3) Round 2k + 2. S(D) = −1, type o, f = 0: middle score β·sinh(ηN) − δ·sinh(η) < 0 exactly because N < N* (N* is the least N with β·sinh(ηN) ≥ δ·sinh(η), and sinh is increasing); the answer 1 is the unique minimiser; g(B) = 1, g(D) = 1[(x, 1) ∈ D] − 1[(x, 0) ∈ D] = 1. S(D) = +1, type ō, f = 0: scores δ·sinh(η), β·sinh(ηN), δ·sinh(η), the middle strictly least; g(D) = 0 − 1 = −1. In both cases S(D) returns to 0 and N grows by 1. Correct.
(4) The claim "after round 2k, N ≥ N* or (S(D) = 0 and N ≥ k)" follows by induction; N never decreases because the human is never in B. Hence N_{2k}(B) ≥ min(k, N*) and N_n(B) ≥ min(⌊n/2⌋, N*). f is a well-defined function because every question is used once and the play is determined by the (deterministic) rule; the game of Definition 1.1 allows y_t to depend on a_t.
(5) Constants: β·sinh(ηN*) ≥ δ·sinh η ≥ δη gives N* ≥ arcsinh(ηδ/β)/η = √n·arcsinh(√n) ≥ √n·ln(2√n) ≥ ½·√n·ln n. And ⌊n/2⌋ ≥ ½·√n·ln n for all n ≥ 1: my script finds no violation for n ≤ 2·10⁶; for larger n, n − 1 ≥ √n·ln n follows from √n ≥ ln n + 1, which (my script) fails for 2 ≤ n ≤ 12 and holds for every n ≥ 13 (√n − ln n is increasing for n > 4), so the proof's appeal to it for n > 10⁶ is valid.
(6) Remark (1) (against a fixed f the tie rule "take f(x) if it is a minimiser" keeps all books at 0): correct, since all slopes are sinh(0) = 0 while all books are 0.

*Numerical test (Part A of my script).* The adversary of the proof against the rule implemented generically from the set definitions, with five tie-breaking rules (least, greatest, random with five seeds, "prefer the answer 1", and a history-dependent rule), for n = 100, 900, 10⁴ and β = 1/(2n) and 10⁻⁹: in every play N_t(B) ≥ min(⌊t/2⌋, N*) at every t ≤ n, with equality at t = n (for example 530 at n = 10⁴). N* agrees with √n·arcsinh(√n) to within 1.

*Observation (not a defect).* The human of the example depends on the tie-breaking (as Remark (1) says it must), and so does the sequence of questions; the statement says so ("there are a function f … and a sequence of distinct questions").

### 1.2 Proposition 3.9 (adversary and editor; used in the note) — CORRECT (and the bound can be sharpened)

*Re-derivation.* Every round with a question of type τ adds 1 at the imitator's answer and subtracts 1 at the human's, so Σ_y D_τ(y) = 0. The imitator raises a least entry, which is ≤ 0 because the mean is 0, so after the raise it is ≤ 1; the human only lowers. Hence every entry is ≤ 1 and therefore ≥ −(|Y| − 1). S_n(B) = Σ_τ Σ_{y∈B_τ} D_τ(y) because all questions of a type have the same section; for a non-trivial section the inner sum lies in [−(|Y| − |B_τ|), |B_τ|] ⊆ [−(|Y| − 1), |Y| − 1]. Summing over the M types gives |S_n(B)| ≤ M·(|Y| − 1). The proof is correct, and the tie-breaking among least entries is irrelevant.

*Sharper bound (my observation).* In fact every entry stays in {−1, 0, 1}, with at most one −1 (and so at most one +1) per type: if a −1 exists it is the unique least entry and is raised to 0, after which the human can create at most one −1; if no −1 exists all entries are 0 (they are in {0, 1} and sum to 0), the imitator creates one +1 and the human at most one −1. Hence Σ_{y∈B_τ} D_τ(y) ∈ {−1, 0, 1} and |S_n(B)| ≤ M, independent of |Y| (indeed ≤ the number of types whose section of B is neither empty nor Y). This does not change any conclusion; the stated bound is true.

*Numerical test (Part C).* For 12 random small instances I enumerated the full set of reachable ledger states (the state space is finite, so this covers every sequence of questions and answers of every length): the largest reachable |S(B)| is within M·(|Y| − 1) in every instance, and the sharper invariant (entries in {−1, 0, 1}, at most one −1, |S(B)| ≤ M) holds in every reachable state.

### 1.3 Proposition 6.7 (editor only; used in the note) — CORRECT

*Re-derivation.* κ = KL(Ber(½ + θ) ‖ Ber(½ − θ)) = (½ + θ)·ln((1 + 2θ)/(1 − 2θ)) + (½ − θ)·ln((1 − 2θ)/(1 + 2θ)) = 2θ·ln((1 + 2θ)/(1 − 2θ)). For 0 < u ≤ ½: ln((1 + u)/(1 − u)) = 2(u + u³/3 + …) ≤ 2u/(1 − u²) ≤ (8/3)·u. With u = 2θ = 1/(2√n) ≤ ½: κ ≤ (32/3)·θ² = 2/(3n), so n·κ ≤ 2/3. The record consists of the protocol's randomness, whose law does not depend on the human, and n answers at the single question x₀, each a fresh Bernoulli draw; by the chain rule KL between the two laws of the record is n·κ even if the protocol's later coins depend on earlier answers. Pinsker: TV ≤ √(n·κ/2) ≤ 1/√3 < 0.578. r̂ is a function of the record (it is defined as a conditional probability given the record). With A = {r̂ ≤ ½}: under P₊ on A, |r̂ − ½ − θ| ≥ θ; under P₋ off A, r̂ − (½ − θ) > θ; and Pr₊[A] + Pr₋[Aᶜ] ≥ 1 − TV ≥ 0.422, so one of the two is at least 0.211. Correct. For the deployment of Section 6.1, r̂ is the fraction of rounds with a_t(x₀) = 1 and Δ_n(B) = r̂ − P(1|x₀) (L = 1, one call per run): correct.

*Numerical test (Part E).* max over u ∈ (0, ½] of ln((1 + u)/(1 − u))/((8/3)u) is below 1; the exact TV of the two binomial laws is 0.500 at n = 1 and about 0.383 for large n (the editor's 0.38 and 0.31 are confirmed), always below 1/√3; n·κ is about 0.50 to 0.55, below 2/3. A Monte Carlo with the empirical frequency as r̂ at n = 400 gives probabilities 0.62 and 0.66 for the two humans, consistent with the bound 0.21.

*Remark on use.* The proposition is a statement about the imitator after one rehearsal (with high probability), not about the expectation over rehearsals; the proof file says so after the proof. The note's use of it is discussed in Part 2, finding F5.

### 1.4 The numbers of answers needed (adversary and editor; used in the note) — CORRECT

From Theorem 6.2(a): L·√((1 + 1/n)·W/n) ≤ γ with W = 2Λ(B) + 1.39 + ln(n + 1) needs n of order L²·(2Λ(B) + ln n)/γ²; from (c): L·(K(B) + 2)/n ≤ γ iff n ≥ L·(K(B) + 2)/γ. The comparison with the mixture: R1 bounds the expected sum over the calls of a deployed run of KL in nats by L·K·ln 2/n; Pinsker per call and Cauchy–Schwarz over at most L calls give E Σ_j TV ≤ √(L·(L·K·ln 2/n)/2) = L·√(K·ln 2/(2n)), which needs n of order L²·K/γ². Correct (I did not re-check Theorem R1 itself, which belongs to rehearsal-core).

### 1.5 Proposition 4.2, restricted form (changed after verification; used in the note) — CORRECT

With set tests decided uniformly in k (or exact rational values), the histories γ_{t−1}(B_k), and in particular the counts v, are computed exactly; the slopes of Lemma 1.4(a) to (e), of Rule N and of Rule NH are then computable reals bounded by the computable C_{t−1} (for Rule NH: an integer power of 2 plus a difference of values of G, which are computable). Truncation at N(j) with C_{t−1}·2^(−j) ≤ 2^(−t)/6, approximation of the finite sum to within 2^(−t)/6 for each candidate, and choice of the least approximate value give a true value at most 2·(2^(−t)/6 + 2^(−t)/6) = 4·2^(−t)/6 above the minimum over Y(x). Correct. Two points of reading: (a) the rule is an approximate minimiser, so the bounds of Pr5 hold for it with π(B)/(1 + E_n) ≥ π(B)/2 (Proposition 4.1(a)), not with π(B); (b) the hypothesis (iv) (the human's answers lie in the computable finite set Y(x)) is part of the hypotheses. Both bear on the note's sentence "The rule is computable" (finding F7 in Part 2).

### 1.6 Theorem 3.3 (Rule NH; Theorem Pr5 of the note), re-derived — CORRECT

(1) Lemma 1.3 (re-read): Ψ_t ≤ Ψ_{t−1} + Σ_B π(B)·c(γ_{t−1}(B))·g_t(B), and the last sum equals F_t(x_t, a_t(x_t)) − F_t(x_t, y_t) ≤ ε_t because the human's answer is among the answers minimised over; absolute convergence holds because |c| ≤ C_{t−1} and Σ π ≤ 1. Correct.
(2) The potential: Lemma 1.4(c) (normal mixture) holds on [−1, 1], hence on {−1, 0, 1}; I re-derived it both via the mixture representation (1.4) (completing the square, ∫ e^(ηs − vη²/2)·φ(η) dη = (v + 1)^(−1/2)·e^(s²/(2(v+1)))) and directly (convexity of G_{v+1} and cosh η ≤ e^(η²/2) under the integral). Lemma 1.4(d) (halving): I re-checked the three cases v = 0, pure, not pure; (1.1) holds with equality. The half-half mixture is a balancing potential by (f) with ρ = (½, ½).
(3) The rule: slope c^NH = ½·c^N + ½·c^H. The note's slope ¼·(G_{V+1}(S + 1) − G_{V+1}(S − 1)) + σ·2^(V−2) is exactly this. With Y finite an exact minimiser exists.
(4) Conclusion: ½·G_{V}(S) + ½·u^H ≤ 1/π(B), both terms ≥ 0. From G_V(S) ≤ 2/π(B): S²/(2(V + 1)) − ½·ln(V + 1) ≤ ln 2 + Λ(B), i.e. S² ≤ (V + 1)(2Λ(B) + 2·ln 2 + ln(V + 1)); 2·ln 2 = 1.3863 ≤ 1.39, and the right side increases in V ≤ n. From u^H = 2^(V−1) ≤ 2/π(B) for a pure history with V ≥ 1: V ≤ K(B) + 2. If the human is never in B every non-zero increment is +1 and V = N_n(B); if always in B, every non-zero increment is −1. Correct. With ε_t-minimisers the factor 1 + E_n appears as stated.
*Numerical test (Part F).* Six small games (two questions, three answers, three random set tests, weights with total 1 or 2/3, in three games one weight divided by 64): an exhaustive search over all 6⁷ sequences of (question, answer) of length 7 for Rule NH implemented from the definitions. The largest ratios of S² to the right side of (i), and of V to K(B) + 2 over pure histories, are 0.27 and 0.53. The search is exhaustive but short (length 7), so it is weak evidence; the proof is what carries the theorem.

### 1.7 Theorem 6.2 with Lemma 6.1 and Theorem 6.3 (Theorem Pr6 of the note), re-derived — CORRECT

(1) Lemma 6.1: a_t is 𝔉_{t−1}-measurable; given 𝔉_{t−1}, (z_t, ρ_t) and J_t the run and the asked question are fixed, and by (H2) E[g_t(B) | …] = 1[J_t ≤ T_t]·(b_B(x_{J_t}, a_t(x_{J_t})) − (Pb_B)(x_{J_t})). Averaging over J_t uniform on {1, …, L}, independent of the rest, gives (1/L)·Σ_{j≤T_t}(…); averaging over (z_t, ρ_t), independent of 𝔉_{t−1}, gives d_B(a_t)/L. The second claim: g_t² ≤ b_B(x_t, a_t(x_t)) + b_B(x_t, y_t) for set tests. Correct. The point that matters is the factor 1/L: it needs J uniform on the L positions (a uniformly chosen call of the run would give 1/T, as the check report showed).
(2) Theorem 6.2(a): E S_n(B) = Σ_t E[d_B(a_t)]/L = (n/L)·E Δ_n(B), and |E S_n| ≤ E|S_n| ≤ √((n + 1)·W), so |E Δ_n(B)| ≤ (L/n)·√((n + 1)W) = L·√((1 + 1/n)·W/n) with W = 2Λ(B) + 1.39 + ln(n + 1). (b): concavity of the root and E V_n = Σ E g_t² ≤ n(p̄ + q̄). (c): if (Pb_B)(x_t) = 0 at the asked questions, every increment is 0 or +1 almost surely, Theorem 3.3(ii) gives N_n(B) ≤ K(B) + 2 surely on that event, and E[(1/n)Σ_t n_B(a_t)] = (L/n)·E N_n(B) ≤ L(K(B) + 2)/n. (d) is (c) for B_f with weight w(f)/2, K(B_f) = K + 1. Correct.
(3) Theorem 6.3: M_k = S_k − Σ_{t≤k} d_B(a_t)/L is a martingale with increments in intervals of length 2; Hoeffding's lemma gives the conditional m.g.f. bound e^(θ²/2); Markov with θ = λ/n gives Pr[|M_n| ≥ λ] ≤ 2e^(−λ²/(2n)); with λ² = 2n·ln(2/(π(B)δ)) the probability is π(B)δ; the union bound costs Σ π(B)δ ≤ δ; and (n/L)|Δ_n| = |S_n − M_n| ≤ |S_n| + λ. For (6.2): e^(−x) ≤ 1 − (1 − e^(−1))x on [0, 1] and 1 − u ≤ e^(−u) make Z_k a supermartingale; Ville (or Markov at time n) gives the bound with e/(e − 1) = 1.58198 < 1.582. Correct.
*Numerical test (Part G).* A scaffold with L = 3 and runs of length 1, 2 or 3 that depend on the answers, four set tests (one never satisfied by the human), a human with fixed answer laws, Rule NH, n = 60, 4000 rehearsals; d_B(a_t) computed exactly by enumeration of the top-level input. The Monte Carlo averages of (L/n)·S_n(B) and of Δ_n(B) agree to within the Monte Carlo error for all four tests (for example +0.0454 and +0.0456 for the one-sided test; the largest difference is 0.004) and lie far within the bound (a); for the test the human never satisfies, N_n ≤ 1 ≤ K(B) + 2 = 5.32 in every rehearsal, and the expected number of deployed calls with an answer in it is 0.046, below L(K(B) + 2)/n = 0.266.

### 1.8 Proposition 2.4, new proof (editor; not used in the note) — CORRECT

Step (1): by (1.3) with rate η_t and the choice of a_t (which minimises with the slopes sinh(η_t·S_{t−1}(B))), W_t(η_t) ≤ cosh(η_t)·W_{t−1}(η_t); with ln cosh η ≤ η²/2 this is Γ_t(η_t) ≤ Γ_{t−1}(η_t) + η_t/2. Step (2): W_t(η) = Σ_i p_i e^(η z_i) over the signed tests; Jensen for u ↦ u^r (r = η′/η ≤ 1) with the probability weights p_i/s gives Σ p_i e^(η′ z_i) ≤ s^(1−r)(Σ p_i e^(η z_i))^r ≤ (Σ p_i e^(η z_i))^r since s ≤ 1; taking logarithms and dividing by η′ > 0 gives Γ_t(η′) ≤ Γ_t(η) (valid whatever the sign of ln W). Chaining with η_t ≤ η_{t−1} and Γ_0(η_1) = ln(Σπ)/η_1 ≤ 0 gives Γ_n(η_n) ≤ ½Σ_{t≤n} η_t, and W_n(η_n) ≥ π(B)e^(η_n|S_n(B)|)/2 gives the bound. For η_t = c/√t: Σ t^(−1/2) ≤ 2√n gives √n(ln(2/π(B))/c + c). The constant 1.70 for c = 1 (1 + ln 2 = 1.693) and the crossover "ln(n + 1) > 2.87" (1.693² = 2.866) are right. *Numerical test (Part B):* 24 random games with greedy adversaries, n = 1500: largest ratio of |S_t(B)| to the bound 0.64.

### 1.9 Proposition 3.10 (editor; not used in the note) — CORRECT

b_k(v, a) − b_k(v, 1 − a) = (2a − 1)·v_k, checked for a = 0 and a = 1. If S = 0, v = (1, 1); otherwise v = (−S_2, S_1)/max(|S_1|, |S_2|) is rational, lies in [−1, 1]², is orthogonal to S and has ‖v‖₂ ≥ 1. With y_t = 1 − a_t(v_t), ‖S_t‖₂² = ‖S_{t−1}‖₂² + ‖v_t‖₂² ≥ ‖S_{t−1}‖₂² + 1. So ‖S_n‖₂² ≥ n and max_k |S_n(B_k)| ≥ √(n/2). Weights play no role. *Numerical test (Part D):* exact rational arithmetic with three imitators, n = 16 (the sizes of the rational numbers grow exponentially with n, so n is small): ‖S_n‖₂² ≥ n in all three.

### 1.10 Proposition 6.6, repaired (editor; not used in the note) — CORRECT

I re-derived every step. (1) |r_t − r_{t−1}| ≤ ‖g_t‖_π ≤ 1. (2) Lemma 6.1 summed with the weights π(B)S_{t−1}(B) (the interchange is justified by Σ π|S| ≤ ‖S‖_π) and the minimising property of a_t give E[⟨S_{t−1}, g_t⟩_π | 𝔉_{t−1}] = −(1/L)E Σ_j m_{x_j}(S_{t−1}) ≤ −μ₀ r_{t−1}; condition (I) applies because every increment vector (b_B(x_t, a_t(x_t)) − b_B(x_t, y_t))_B, and the zero vector of a void round, is of the form defining 𝒮, so S_{t−1} ∈ 𝒮. (3) m_x(S) ≤ Σ_B π(B)|S(B)| ≤ ‖S‖_π, so μ₀ ≤ 1 may be assumed (simpler: (I) for μ₀ implies (I) for min(μ₀, 1)); for r ≥ 1/μ₀, √(r² − 2μ₀r + 1) ≤ r − μ₀ + 1/(2r) ≤ r − μ₀/2 (the radicand is ≥ 1 − μ₀² ≥ 0). (4) λ = μ₀/(2e) ≤ 1, e^u ≤ 1 + u + (e/2)u² on [−1, 1] (indeed with e − 2 in place of e/2), ϱ = 1 − λμ₀/2 + (e/2)λ² = 1 − μ₀²/(8e); on {r_{t−1} < 1/μ₀}, e^(λ r_t) ≤ e^((1+μ₀)/(2e)) ≤ e^(1/e); the recursion a_t ≤ ϱa_{t−1} + e^(1/e) with a_0 = 1 ≤ e^(1/e)/(1 − ϱ) gives a_n ≤ 8e·e^(1/e)/μ₀². (5) Jensen gives E r_n ≤ (2e/μ₀)(1/e + ln(8e/μ₀²)) = C(μ₀). Part H of my script checks this algebra. The examples in "Reading (i)": Example 6.5 has m_x(S) = |S|/2 and ratio 1/2; with the complement added (weights ½) 𝒮 = {(k, −k)}, m = |k|/2, ‖S‖_π = |k|, ratio ½, and ratio 0 at (1, 1) ∉ 𝒮. The sentence that (I) still fails for a one-sided test when some question has two answers that differ only in membership of B is also right (with S = c·e_B, c > 0, every m_x(S) = 0). So the repaired hypothesis is honest but restrictive: it excludes every family that contains a test the human never satisfies and that some question separates on its own. The proof file says so.

### 1.11 Lemma 1.4(b), second form on [−1, 1] (editor; not used in the note) — CORRECT

For g ≠ 0, v(γg) = v + 1, and dividing (1.3) by cosh(η)^(v+1) gives cosh(η(s + g))/cosh(η)^(v+1) ≤ cosh(ηs)/cosh(η)^v + g·tanh(η)·sinh(ηs)/cosh(η)^v for every g ∈ [−1, 1], with equality at g = ±1; for g = 0 both sides equal u(γ).

### 1.12 Summary of Part 1

| Statement | Seen before by | Verdict |
|---|---|---|
| Example 2.5 | editor only | CORRECT |
| Proposition 3.9 | adversary, editor | CORRECT (the bound can be sharpened to M) |
| Proposition 6.7 | editor only | CORRECT |
| Numbers of answers needed (after Theorem 6.2) | adversary, editor | CORRECT |
| Proposition 4.2 (restricted) | both, before the change; editor | CORRECT |
| Theorem 3.3 (Pr5) | both, editor | CORRECT |
| Lemma 6.1, Theorem 6.2, Theorem 6.3 (Pr6) | both, editor | CORRECT |
| Proposition 2.4 (new proof) | editor (bound proposed by the adversary) | CORRECT |
| Proposition 3.10 | editor (finding of the adversary) | CORRECT |
| Proposition 6.6 (repaired) | editor | CORRECT |
| Lemma 1.4(b), second form | check report observed it; editor | CORRECT |

So Example 2.5, Propositions 3.9 and 6.7 and the other statements of this table have now been read by a second, independent checker. The editor's sentence in Section 11.2 and in the section source's assembly note ("seen by no verifier") may be updated accordingly; this is for the editor or lead to decide.

## Part 2. The note's text (Sections 8.4 and 8.5 of `note.md`)

I read the two sections statement by statement against the proof file. Every pointer exists: Lemmas 1.3 and 1.4, Theorem 2.1, Examples 2.3, 2.5, 6.5, 7.1, Propositions 3.5, 3.6, 3.9, 4.2, 4.4, 6.7, 7.3, 8.1, Corollary 3.4, Theorems 3.3, 6.2, 6.3, 7.6 are in `proofs/property-online.md` and say what the note attributes to them; Theorems R1, R2, N1 and Section 2 exist in the note and are used as they state (I did not check their proofs). "Λ(B) as in Section 8.2" is defined in Section 8.2 of the note. The labels Pr5 and Pr6 agree with `research/outline.md`, Addendum 3, and with the header of the proof file. The statuses "proved here" for Pr5 and Pr6 and for the lower bounds agree with Section 11 of the proof file. Theorem Pr5 (both parts, the constant 1.39 ≥ 2·ln 2, the hypothesis that Y is finite so that exact minimisers exist), the slope of Rule NH, the idea of the proof, the corollary with the tests "the answer is not ν(x)" (K + 3), Theorem Pr6 (a) to (c) with its protocol and assumptions, the sentence on the numbers of answers needed, Example 6.5, the toy figures (62% and 48%: `results/toy_property.out` has 0.6197 and 0.4773 for the rule with one rate at n = 64 000), the tilt (Theorem 7.6(ii): the one-rate bound plus E Σ κ_t/(β·η)) and the comparison with memorisers (Proposition 8.1: probability (1 − p)·μ_k ≥ (1 − p)/2 at each new question while at most k* = ⌊(K − 1)/log₂(A/p)⌋ have been answered, so at each of the first k* + 1 ≥ (K − 1)/log₂(A/p); Rule NH with R at weight ½ at most K(R) + 2 = 3) are all correct as stated. I checked by hand that Example 7.1 holds for Rule NH (the rule of the bullet): with ties to the least answer the play alternates 0, 1, 0, 1, …, the book alternates −1, 0, and the slope at S = 0 is 0 also for Rule NH because the history is not pure after round 2.

The findings follow, most important first.

**F1 (prose claims more than is proved; the most important).** Section 8.5, bullet "Against the mixture":

> For a human who varies, both match frequencies at order 1/√n, which no imitator built from n answers can beat (Proposition 6.7; Le Cam's two-point argument, standard); K ln 2/n is the mixture's rate for the divergence.

Proposition 6.7 is a statement about the imitator after one rehearsal, with probability at least 0.21. In expectation over the rehearsal it is false that 1/√n cannot be beaten: Proposition 6.6 gives E|Δ_n(B)| of order 1/n for the quadratic rule under its interior condition, and Pr6(a), the bound the sentence refers to for this imitator, is itself an expectation over the rehearsal. Also, Rule NH's bound is of order √(ln n/n), and the mixture's needs A2. Proposed replacement:

> For a human who varies, both match the frequencies of tests at order 1/√n up to logarithms (the mixture only under A2), and given the rehearsal no imitator built from n answers does better with high probability: for a single test, one of two humans whose rates differ by 1/(2√n) leaves an error of at least 1/(4√n) with probability at least 0.21 (Proposition 6.7; Le Cam's two-point argument, standard). In expectation over the rehearsal the discrepancy can be smaller (Proposition 6.6). K ln 2/n is the mixture's rate for the divergence.

If the length matters, the minimal fix is to replace "which no imitator built from n answers can beat" by "which, given the rehearsal, no imitator built from n answers can beat with high probability".

**F2 (statement of the examples incomplete).** Section 8.4, paragraph "One rate":

> It has no fast one-sided rate: however its ties are broken, some human never satisfies a test of weight 1/(2n) in which the rule gives at least ½·√n·ln n answers (Examples 2.3 and 2.5); Rule NH gives at most log₂ n + 3.

The examples need a second test (D, of weight ½) in the family, the rate η = 1/√n, and n rounds; the human and the questions depend on how the ties are broken (Example 2.5, Remark (1) shows this cannot be avoided). Proposed replacement:

> It has no fast one-sided rate: for η = 1/√n and a family of two tests, one of weight 1/(2n), however its ties are broken there are a deterministic human who never satisfies that test and questions on which the rule gives at least ½·√n·ln n answers in it within n rounds (Examples 2.3 and 2.5; the human depends on the tie-breaking); on the same family Rule NH gives at most log₂ n + 3 on every sequence.

**F3 (overstatement in "Computation").** Section 8.5, bullet "Computation":

> The rule is computable for decidable tests, computable weights with a computable tail bound, and a known finite set of candidate answers for each question, such as answers of bounded length (Proposition 4.2); with an unbounded answer set no rule that always halts works, even for one decidable test (Proposition 4.4).

Proposition 4.2 gives a computable rule that minimises up to 2^(−t), not the exact minimiser of Rule NH; by Proposition 4.1(a) it satisfies Pr5 with π(B)/2 in place of π(B) (one more bit in (ii)). The candidate sets must contain every answer the human gives. And Proposition 4.4 uses a human who is not computable. Proposed replacement:

> A rule that minimises the score up to 2^(−t) is computable for decidable tests, computable weights with a computable tail bound, and a known finite set of candidate answers for each question that contains the human's answers, such as answers of bounded length (Proposition 4.2); it satisfies Pr5 with π(B)/2 in place of π(B) (Proposition 4.1). With an unbounded answer set no rule that always halts works, even for one decidable test and a stateless deterministic (not computable) human (Proposition 4.4).

**F4 (overstatement in "Runs").** Section 8.5, bullet "Runs":

> … total variation at least 1/2 from the human system for every n, with all tests matched (Proposition 7.3).

Proposition 7.3 says that the tests of single calls of the family are matched as in Theorem 6.2, not "all tests"; the test "the two answers of the run agree" is not matched. Proposed replacement: "… total variation at least 1/2 from the human system for every n, while the tests of single calls are matched as in Pr6 (Proposition 7.3)."

**F5 (wording, lower bound).** Section 8.4, "Lower bounds":

> In (i), √n is forced in general: for some family of √n tests every rule lets a book reach (√2 − 1)·√n within n rounds (Proposition 3.6).

Proposition 3.6 needs d ≥ √n tests, so d = ⌈√n⌉, and its family (with 2^d questions) depends on n. Proposed replacement: "In (i), √n is forced in general: for a family of ⌈√n⌉ tests, chosen for the horizon n, every rule lets some book reach (√2 − 1)·√n within n rounds (Proposition 3.6)."

**F6 (wording, optional).** Section 8.4, "Lower bounds": "For a fixed finite family it is not: another rule keeps the books bounded, exponentially in the family's size (Proposition 3.9)." Correct, but "bounded, exponentially in the family's size" is hard to parse. Proposed: "For a fixed finite family it is not: another rule keeps every book bounded for all n, by a bound that can be exponential in the size of the family (Proposition 3.9)." (By my observation in 1.2 the bound can be taken to be the number of kinds of question the family distinguishes; that sharpening is not in the proof file and I do not propose it for the note.)

**F7 (status, information only).** The note cites Example 2.5, Proposition 3.9 and Proposition 6.7 without a status word; the proof file (Section 11.2) records that no verifier had seen them. I have now checked all three (Part 1) and found them correct, so no status qualification is needed in the note. The other statements cited in the two sections were checked by both verifiers according to Section 11.2; I re-derived Pr5 and Pr6 in addition.

**F8 (attribution, not checked).** "This is the halving algorithm (Littlestone 1988; standard)". From memory (not checked in this session), the halving algorithm is usually credited to Barzdin and Freivalds (1972) and to Angluin (1988), and Littlestone (1988) states and analyses it in the mistake-bound model. "(see Littlestone 1988; standard)" would be safer. I did not verify this and give it only as a point for the lead to check.

## Part 3. What I did not check

* The literature: I read none of the sources cited in the proof file or the note in this session; the attribution paragraph of Section 8.4 and Section 5 of the proof file are not checked by me.
* Theorems R1, R2 and N1 and Hoeffding's lemma in `proofs/rehearsal-core.md`, which the note and the proof file quote from other parts.
* Statements of the proof file that the note uses and that both verifiers checked, which I read but did not re-derive in full: Corollary 3.4 and Proposition 3.5 (read; short and correct as far as I read), Proposition 3.6 (proof read, constants of (a) recomputed: D² + (2n/d)D − n ≥ 0 gives the stated bound; (b) not recomputed), Propositions 4.4, 7.3 (read), Theorem 7.6 (statement compared with the note; proof read, not re-derived), Proposition 8.1 (statement compared with the note; the weight computation ½·(p/A)^k re-done, the rest read), Proposition 8.2 (read).
* Not read: Sections 5, 7.4 beyond Theorem 7.6, Theorem 7.8, Remarks 7.9 except item 5, Section 9 (numerical checks) beyond the editor's output file, Section 10, and Corollary 3.2, Propositions 3.7, 3.8, 4.1, 4.3, 7.4 in detail (Proposition 4.1(a) was used in F3 and read).
* The toy computation behind the figures 62% and 48% was not rerun; I read the numbers in `results/toy_property.out`.
* My numerical tests are small (Part F is an exhaustive search of length 7 only; Part G is a Monte Carlo with 4000 rehearsals of length 60). They test the statements; they do not replace the proofs, which I re-derived by hand.
