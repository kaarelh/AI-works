# Track "history": history-aware predictors, SFI^hist and the chronological semimeasure (final notes)

Brief items H3 and H4, and the question "what can SFI exploit, and what not?".

This is the revised version of `notes.md`, written after the referee report `referee.md` (the second report, which replaces the first and also lists the status of an earlier partial draft of this file). It is self-contained: every result used is stated here, and every result marked **[proved]** is proved here, except results imported from the foundations track, which are cited by number. Theorem numbers follow `notes.md` wherever a result survived, so that the other tracks' references stay valid. New results have new numbers. §9 answers the referee point by point; §8 aligns definitions and results with the other tracks.

Scripts: `checks/c1`–`c10` (this track) and `referee_code/r1`–`r7`, `s1`–`s4` (the referee's). All are seeded or deterministic, run with `python3`, and save their output next to themselves as `*.out`. The verification log at the end records a full re-run.

Status labels: **[proved]** (full proof here), **[computed]** (script and saved output), **[known]** (exact reference; *unverified* when not checked against the source), **[proof sketch]**, **[conjecture]**, **[open]**, **[refuted]** (kept with its counterexample).

---

## 0. Summary of results

**Convention.** L_SFI(D) := −log M_F(D) is the cumulative loss of SFI's raw conditionals (the *semimeasure convention*, §1.2). Upper bounds on L_SFI also hold for the per-step normalised predictor. Lower bounds do not transfer automatically. Each lower bound below says which convention it is for. For the chain and the skipped strings the normalised predictor is handled separately (Prop. 2.4).

| # | Claim | Status |
|---|---|---|
| 2.1 | **Chain** (Hänni). Let ω be Martin-Löf random, cut into blocks x_i of computable increasing lengths ℓ_i, with L_k := Σ_{i≤k} ℓ_i. On (x_1,ε),(x_2,x_1),…,(x_n,x_{n−1}): L_{n−1} − K(ℓ_n) − c_ω ≤ L_SFI ≤ L_{n−1} + K(n) + c (semimeasure convention). A deterministic set-based predictor of constant size has loss 0. With ℓ_i = i the loss is n(n−1)/2 up to 2 log n + c_ω. Hänni's belief "unbounded loss" is correct. | proved |
| 2.2 | **Skipped strings** (Hänni). After all strings of length ≤ ℓ: K(s_1…s_ℓ ∣ ℓ) − c ≤ L_SFI ≤ ℓ(ℓ+1)/2 + c. If the s_ℓ are consecutive blocks of an ML-random ω: L_SFI ≥ ℓ(ℓ+1)/2 − K(ℓ) − c_ω (semimeasure convention). A deterministic set-based predictor of constant size has loss 0. | proved |
| 2.3 | The lower bounds of 2.1 and 2.2 hold for **every** order-free predictor (weak function semimeasure), for example M^w, M_prod and W, with K(ν) subtracted for lower-semicomputable ν. In expectation they hold for every order-free predictor, computable or not. | proved |
| 2.4 | **Normalised predictor** (new; answers Q4 for these two examples). Per step, the normalised SFI predictor pays at least the raw loss minus the cost of one total "broom" hypothesis that dominates the normaliser. Chain with ℓ_i = i, ω ML-random: normalised cumulative loss ≥ n(n−1)/2 − n(4 log n + c_ω + c). Skipped strings: ≥ ℓ(ℓ+1)/2 − ℓ(4 log ℓ + c_ω + c). In expectation over independent uniform blocks, step t of the chain costs ≥ ℓ_{t−1} − K(t−2) − c. So Hänni's "unbounded loss" holds for the normalised predictor too, at a quadratic rate. | proved; finite proxy computed (c9) |
| 3.0 | **Private memory** (new). A reveal law that does not see f may keep private memory. Given the history, f and the next input are still independent, and only the reveal-sequence law Δ(x_{1:n}‖y_{1:n−1}) enters. For a sampler that halts almost surely with inputs in finite sets this law has computable values. | proved |
| 3.1 | The private-randomness simulator in the draft's proof sketch can lose more than P (the brief's example: 2 bits against 1). The sketch has two errors: it drops cross-input correlations, and it averages over simulated histories, whose labels come from P rather than from f. | computed (c1) |
| 3.2–3.4 | Shared-randomness simulator. For all computable samplers Δ (inputs) and P (labels), defective ones included, on every consistent sequence: L_SFI ≤ L_P + L_Δ + K(Δ) + K(P) + c. For a deterministic computable reveal policy δ: L_SFI ≤ L_P + K(δ) + K(P) + c. Also L_SFI ≤ −log M(code(x_1y_1…x_ny_n)) + c. | proved |
| 3.5 | Bayes form. Let f ~ π, a computable random function, and let the inputs depend on f only through revealed labels (any mechanism, even non-computable). Then L_SFI ≤ −log π(D_n) + K(π) + c on every path, and E[L_SFI] ≤ E[L_P] + K(π) + c for every predictor P. | proved |
| 3.6 | Directed information. If the input choice may also depend on f: E[L_SFI] ≤ E[L_P] + I(f → x_{1:n}) + K(π) + c. The excess of E[−log π(D_n)] over the Bayes loss is exactly I(f → x) minus an expected KL term. | proved; identity computed (c2, r1) |
| 3.7 | **Hänni's own remark, made rigorous.** He says a "simple reveal law" version fails when the reveal choice informs about f. Example: the randomized chain. The reveal policy has complexity O(1) relative to an oracle for f, E[L_P] = 0, and E[L_SFI] ≥ n(n−1)/2 − c (also for the normalised predictor, up to O(n log n), by Prop. 2.4). This refutes Thm 1 under the oracle reading (Reading B), which Hänni's text does not intend. | proved |
| 3.8 | **Minimax theorem** (a reveal law that does not see f, possibly with private memory; arbitrary f). Hypotheses: finite label set; finite input sets A_n given by a computable map of complexity K(A). For every f: E[L_SFI] ≤ E[L_P] + K(P) + K(Δ) + K(n) + K(A) + c (+ C_dir if the reveal law sees f). This holds (a) for P and the reveal-sequence law Δ with rational values computable from their arguments, and (b) for computable real values, which includes every computable sampler that halts with probability 1. | (a) proved; (b) proved for reveal laws that do not see f, proof sketch for those that do; computed (c3, r2, c8) |
| 3.9 | **Hänni's Thm 1 under Reading C** (his intended reading: for each f the reveal law Δ_f is a standalone sampler). Under the hypotheses of 3.8: E_{x∣f}[L_SFI] ≤ E_{x∣f}[L_P] + K(P) + K(Δ_f) + K(n) + K(A) + c. For deterministic Δ_f it holds pathwise, with no K(n) or K(A), for every sampler P. **Open:** samplers that diverge with positive probability, infinite alphabets, and whether K(n) + K(A) can be dropped. | proved under the stated hypotheses; rest open |
| 3.10 | **Shannon form of Hänni's mutual-information question.** Let (f, Θ) be jointly random, f ~ π computable, and let the inputs, given Θ, come from a reveal law Δ_Θ that does not see f. Then I(f → x) ≤ I(f; Θ), so E[L_SFI] ≤ E[L_P] + I(f; Θ) + K(π) + c. | proved; computed (c7) |
| 3.11 | Algorithmic form under Reading C: K(Δ_f) can be replaced by I(Δ_f : f) + O(log). | conjecture (untested) |
| 3.12 | No pathwise version of Reading A with only K(P) + K(Δ). | proved |
| 4.1–4.3 | SFI^hist (hypotheses see the list of previous inputs) is SFI on list-valued inputs. Its law M_H is a universal lower-semicomputable chronological semimeasure: every such ρ is generated **exactly** by a history-oracle function machine, at every non-root node. We define ξ := M_H. Then L_ξ ≤ L_P + K(P) + c on every sequence, for every lower-semicomputable history-aware predictor P. Hänni's conjecture H4 holds in this sense. That ξ equals Hutter's universal chronological semimeasure up to constants is known but unverified. Whether Thm 4.2 is in the literature, and what Hutter's "supervised learning from examples" section contains, are unverified (§4.6). | proved; identification known (unverified); computed (c4, r5) |
| 4.4–4.5 | Variants. Oracle access to previous (x,y) pairs gives the same class as SFI^hist. Access to the count i is the foundations track's stamped SFI. Access to the set of previous inputs lies strictly between. So SFI ≺ SFI^count ≺ SFI^set ≺ SFI^hist. For each gap there are finite sequences with gap linear in n (4.5), and also single infinite sequences along which the gap grows linearly (4.5′). | proved; lemma computed (c6, r4) |
| 4.6 | Relation to Solomonoff's M on x_1y_1x_2y_2…: L_ξ ≤ L_M^joint + c and L_M^joint ≤ L_ξ + L_ξ′^x + c. For inputs from a computable deterministic policy δ: L_M^joint ≤ L_ξ + K(δ) + c. | proved |
| 4.7 | **Input-loss identity** (new). For a computable deterministic input policy δ, on every δ-consistent sequence: L_M^x − K(δ) − c ≤ L_ξ − L_M^y ≤ L_M^x + c. So "ξ ≈ SI's conditional label predictions" is equivalent to "M predicts the δ-determined inputs with bounded loss". Lattimore–Hutter–Gavane (ALT 2011) show that unnormalised M can fail on simple selected sub-patterns. If their failure transfers to the prefix-coded block format used here, then **neither** L_M^y ≤ L_ξ + O(1) **nor** L_ξ ≤ L_M^y + O(1) holds on all sequences (labels copying inputs, and inputs copying labels). The normalised-M versions are open. | identity proved; LHG known (unverified beyond the abstract); consequences conditional on the transfer |
| 4.8 | Cyclic permutation (H5): SFI^hist's loss is ≤ c on every instance. | proved |
| 4.9 | Operator induction (Solomonoff 2008), as secondary sources describe it, is the per-query mixture M_pq of x-only operators (foundations Def 4.1). It is a lower-semicomputable chronological semimeasure that ignores the history, so M_H dominates it. On data with distinct inputs it equals M_prod ≤ 2^c M_F, so the separations of §2 apply to it. | proved, given the unverified description |
| 4.10 | Deterministic programs for SFI^hist: with binary labels the program mixture W_hist loses at most τ(n) := −log Σ_{N≥n} 2^{−K(N)} + c ≤ κ(n) + c bits against fair-coin labels, and τ(n) ≤ g(n) + K(g) + c for every computable nondecreasing unbounded g. So the extra cost grows more slowly than every computable unbounded function, not like K(n). The single shortest program pays more: its worst-case excess is > log n + log log n for infinitely many n and ≤ K(n) + c. | proved (corrects notes.md §7); toy computed (s2, c10) |
| 5.1 | SFI's loss depends only on the set D_n, so it cannot use the order of the data. | proved |
| 5.2–5.3 | Sandwich: max_σ L_ξ(D_σ) − c ≤ L_SFI(D) ≤ min_τ [L_ξ(D_τ) + KH(x_τ)] + c. Equality up to K(e) + c for initial segments of a computable enumeration e. | proved |
| 5.4 | GF(2^m): L_ξ ≤ m + c in both orders. L_SFI ≥ 3m/2 − k − c for all but a 2^{1−k} fraction of triples, and E[L_SFI] ≥ 3m/2 − 2 (semimeasure convention). The exact optimum over all random functions is 2.708 bits (m = 2) and 4.348 bits (m = 3), against ξ's m. So SFI's deficit is not only order information. | proved; computed (c5, r3, s4) |
| 5.6 | −c ≤ E[L_SFI] − E[L_ξ] ≤ I(f → x) + K(π) + c. Attained up to the last input's entropy in the randomized chain; not attained in the GF process. | proved |
| 5.7 | **Individual-sequence information bound.** L_SFI(D) ≤ L_ξ(D_σ) + I(x_σ : D) + c for every order σ (new). The conjecture Q2 of `notes.md`, L_SFI ≤ L_ξ(D_σ) + I(x_σ : y_σ) + O(log), is **refuted**: on the construction of Prop. 4.5(i) the gap is ≥ n − log(n+1) − K(n) − c. | (a) proved; (b) refuted (s1) |

**What changed from `notes.md`** (details in §9).
* **Hänni's Thm 1 is now read as his text intends (Reading C).** Under that reading it is **true** under the hypotheses of Cor. 3.9, and only the proof sketch is wrong. The "refutation" in `notes.md` was of Reading B, which his preceding sentence rules out. Thm 3.7 makes his own remark rigorous (referee M1).
* Thm 3.8 states all its hypotheses, including the K(A) term, covers reveal laws with private memory (Lemma 3.0), and is extended to computable real-valued P and Δ, so it covers every almost surely halting sampler (M2).
* Q2 of `notes.md` is **refuted** by the notes' own Prop. 4.5(i); a weaker correct bound replaces it (Prop. 5.7; M3).
* The comparison with SI's conditional label loss gains an exact identity for deterministic policies (Prop. 4.7). With it, the LHG phenomenon decides Q3 negatively for unnormalised M, conditional on the format transfer (M4).
* The remark that deterministic programs pay ≈ K(n) is false and is replaced by Prop. 4.10 (M5).
* The literature for H4 now includes Hutter's "supervised learning from examples" section, operator induction and Wood–Sunehag–Hutter (§4.6; M6).
* New: Prop. 2.3 (order-free predictors), Prop. 2.4 (normalised predictor on the chain and skipped strings), Lemma 3.0, Prop. 3.10, Conjecture 3.11, Prop. 4.5′ (single infinite sequences), Prop. 4.7, Prop. 4.10(d) (the single shortest program for SFI^hist pays more than log n + log log n infinitely often), Prop. 5.7.
* All minor issues m1–m21 are handled (§9).

---

## 1. Setting

### 1.1 Notation

This follows the foundations track (`../foundations/notes-final.md` §1); §8.1 lists the correspondences with all tracks.
* X = Y = {0,1}* unless a finite label set is stated. The results hold for any countable decidable X and Y with |Y| ≥ 2, unless a statement says otherwise. ε is the empty string.
* A *data set* is a finite partial function D ⊆ X × Y, with domain dom D. A sequence (x_1,y_1),…,(x_n,y_n) is *consistent* if x_i = x_j implies y_i = y_j. (`notes.md` said "function-consistent".) D_n := {(x_i,y_i) : i ≤ n} and h_i := (x_1,y_1,…,x_i,y_i).
* λ is the uniform measure on {0,1}^ℕ, and [w] is the cylinder of the finite string w.
* log is log₂. K(·) and K(·∣·) are prefix complexities with respect to a fixed universal prefix machine V. c, c′, c″ are constants that depend only on the fixed machines and encodings. c_ω depends also on ω.
* s̄ is a fixed prefix-free code for strings (for example 1^{|s|}0s), and code(x_1y_1…x_ny_n) := x̄_1ȳ_1…x̄_nȳ_n.
* κ(N) := min_{L ≥ N} K(L) (the foundations track's "padded length", same symbol and meaning) and τ(N) := −log Σ_{L ≥ N} 2^{−K(L)}. Both are used only in Prop. 4.10. Trivially τ(N) ≤ κ(N).
* D + (x,y) := D ∪ {(x,y)} for x ∉ dom D, and ⊥ means "undefined", as in the foundations track.

### 1.2 Function machines and SFI

**Function machine** (foundations Def 2.5). A c.e. set T ⊆ X × {0,1}* × Y of triples that is *consistent*: if (x,w,y) and (x,w′,y′) are in T and w, w′ are comparable, then y = y′. For ω ∈ {0,1}^ℕ put f^T_ω(x) := y if some prefix w of ω has (x,w,y) ∈ T, and leave it undefined otherwise. The *machine law* is ν_T(D) := λ{ω : f^T_ω ⊇ D}.

The same object is a Turing machine with a one-way read-only random tape ω. All queries share the tape. On query x the machine reads finitely many tape bits and then halts with a label or diverges. (`notes.md` used this form; the two forms convert into each other uniformly.) ν_T is lower semicomputable (LSC), uniformly in D and in an index of T (foundations Prop 2.6). K(T) is the complexity of an index of T in the effective list of function machines (foundations §1, "complexity of a law").

**Universal SFI.** M_F := ν_{T_U} is the law of the universal function machine. It reads a V-program p from the tape and then runs T_{V(p)} on the rest of the tape. Facts used:
* (F1) M_F(D) ≥ 2^{−K(T)} ν_T(D) for every function machine T and every D ≠ ∅ (foundations Thm 3.2).
* (F2) M_F is the law of a random partial function. So D ⊆ D′ implies M_F(D′) ≤ M_F(D); Σ_y M_F(D ∪ {(x,y)}) ≤ M_F(D) for x ∉ dom D; and for a finite set S the events {f_ω ⊇ l}, dom l = S, are pairwise disjoint.
* (F3) A partial computable g with g ⊇ D gives M_F(D) ≥ 2^{−K(g)−c} (foundations Prop 3.3(b)).
* (F3′) For a LSC conditional semimeasure P(y∣x), the product law ν_P(D) := Π_{(x,y)∈D} P(y∣x) is a machine law with K(ν_P) ≤ K(P) + c (foundations Prop 3.3(a)). These are Hänni's x-only samplers.
* A *computable random function* is a function machine T_π whose f_ω is total for λ-almost every ω. Put π(D) := ν_{T_π}(D) and K(π) := K(T_π). For every countable Y these are exactly the computable laws of random total functions (foundations Lemma 6.5a and Prop 3.3(c)). A law on Y^A with A finite and rational probabilities is a machine law, realised by rejection sampling from the tape (foundations Prop 3.3(c)).

**Loss (semimeasure convention).** L_SFI(D) := −log M_F(D). For a consistent sequence,
  Σ_i −log [M_F(D_i)/M_F(D_{i−1})] = L_SFI(D_n)
by telescoping, with M_F(∅) = 1. It depends only on the set D_n (foundations Prop 5.2). In the *normalised convention* one predicts with M̄_F(y_i ∣ D_{i−1}, x_i) := M_F(D_i)/S_i, where S_i := Σ_y M_F(D_{i−1} + (x_i,y)) is the *normaliser* (for a new input x_i). So the normalised per-step loss is exactly
  l̄_i = −log M_F(D_i) + log S_i.
Since S_i ≤ M_F(D_{i−1}), the normalised cumulative loss L̄_SFI is at most L_SFI(D_n), and it can depend on the order (foundations Prop 5.3). So upper bounds on L_SFI transfer to the normalised predictor. Lower bounds do not transfer automatically; Prop. 2.4 proves the chain and skipped-string lower bounds for the normalised predictor directly.

`notes.md` wrote L_F for L_SFI, M_T for ν_T and "function-consistent" for "consistent". The examples track writes L_SFI, and these notes follow it.

### 1.3 History-aware predictors and chronological semimeasures

* A *history-aware predictor* gives P(y ∣ h, x) ≥ 0 with Σ_y P(y∣h,x) ≤ 1. Its loss on a sequence is L_P := −log P(y_{1:n} ‖ x_{1:n}), where P(y_{1:n} ‖ x_{1:n}) := Π_i P(y_i ∣ h_{i−1}, x_i).
* A *computable sampler* (Hänni's class C) is a probabilistic machine. Given (h, x), it reads random bits and either halts with a label or diverges. An *input sampler* does the same given h, and outputs an input. P(y∣h,x) := Pr[output y] is LSC, uniformly in the arguments. The sampler is *defective* if it diverges with positive probability.
* **Lemma 1.0 [proved].** A sampler that halts with probability 1 on every argument has computable probabilities, uniformly in the arguments.
  *Proof.* P(y∣h,x) is LSC, and P(y∣h,x) = 1 − Σ_{y′≠y} P(y′∣h,x) is the difference of 1 and a LSC sum, hence upper semicomputable. ∎
* A *chronological semimeasure* is ρ(y_{1:n} ‖ x_{1:n}) ≥ 0 with ρ(ε‖ε) ≤ 1 and Σ_y ρ(y_{1:n}y ‖ x_{1:n}x) ≤ ρ(y_{1:n} ‖ x_{1:n}) for every x. Every predictor P gives one, ρ_P(y‖x) := P(y‖x). Conversely, every ρ gives the predictor ρ(y_{1:i}‖x_{1:i})/ρ(y_{<i}‖x_{<i}), whose loss is −log ρ(y‖x) + log ρ(ε‖ε) ≤ −log ρ(y‖x). For LSC ρ, K(ρ) is the complexity of an index of a lower approximation of ρ.
* **The universal chronological semimeasure.** It is defined in §4 as ξ := M_H, the law of the universal history-oracle function machine. Lemma 4.1 and Thm 4.2 show that M_H is LSC, chronological, and dominates every LSC chronological semimeasure. Hutter's ξ (*Universal Artificial Intelligence*, Springer 2005, ch. 5; arXiv cs/0004001) is defined for actions and percepts. Here the roles are swapped: our **inputs play the actions and our labels play the percepts**. That Hutter's ξ agrees with M_H up to constants is **[known, unverified]**. Nothing below depends on it (§4.6).

### 1.4 Facts used

* **(F4) Conditional coding theorem** [known; Levin 1974, Gács 1974, Chaitin 1975; Li & Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed., Springer 2008, §4.3; section numbers unverified]. Let ν(·∣w) be discrete semimeasures (Σ_z ν(z∣w) ≤ 1) that are LSC uniformly in w. Then K(z∣w) ≤ −log ν(z∣w) + K(ν) + c.
* **(F5) Levin–Schnorr** [known; Li & Vitányi 2008 §3.6; numbering unverified]. ω is Martin-Löf random (for λ) iff there is c_ω with K(ω_{1:ℓ}) ≥ ℓ − c_ω for all ℓ.
* **(F6) Conditional Kraft bound** [proved]. For discrete random variables Z, W: E[K(Z∣W)] ≥ H(Z∣W).
  *Proof.* For each w, Σ_z 2^{−K(z∣w)} ≤ 1. Gibbs' inequality gives E[K(Z∣w) ∣ W = w] ≥ H(Z ∣ W = w). Average over w. ∎
* **(F7)** K(a,b) ≤ K(b) + K(a∣b) + c, and K(s) ≤ |s| + K(|s|) + c [known; Li & Vitányi 2008 ch. 3].
* **(F8) Universal monotone semimeasure** [known; Zvonkin & Levin 1970, *Russian Math. Surveys* 25(6):83–124; Li & Vitányi 2008 §4.5; numbering unverified]. M(z) := λ{ω : U_mono(ω) ⊒ z}, for a universal monotone machine, is a LSC semimeasure on {0,1}*. It satisfies M ≥ 2^{−K(ν)−c}ν for every LSC semimeasure ν.
* **(F9) Sion's minimax theorem** [known; M. Sion, "On general minimax theorems", *Pacific J. Math.* 8 (1958) 171–176; unverified]. We use only the finite-dimensional case: compact convex sets, and a continuous payoff that is convex in one variable and affine in the other.

### 1.5 Two basic lemmas

**Lemma 1.1 (domain lower bound) [proved].** For every data set D: L_SFI(D) ≥ K(D ∣ dom D) − c, where dom D is given as a finite set. This is the left side of foundations Thm 6.3(a). For a LSC weak function semimeasure ν: −log ν(D) ≥ K(D ∣ dom D) − K(ν) − c.

*Proof.* Fix a finite set S. The labellings l of S give pairwise disjoint events {ω : f_ω ⊇ l} (F2), so ν_S(l) := M_F(l) is a discrete semimeasure. It is LSC uniformly in S. Apply (F4). For a weak ν, foundations Def 2.1, consequence (b), gives Σ_{dom l = S} ν(l) ≤ ν(∅) ≤ 1. ∎

**Lemma 1.2 (SFI is a chronological semimeasure) [proved].** Put ρ_F(y_{1:n}‖x_{1:n}) := λ{ω : f_ω(x_i) = y_i ∀i ≤ n}. This equals M_F(D_n) for consistent data and is 0 otherwise. ρ_F is a LSC chronological semimeasure. Hence L_ξ(D in order σ) ≤ L_SFI(D) + c for **every** order σ (using Cor. 4.3). This is foundations Prop 7.2(b). By foundations Prop 7.2(c), the order-free LSC chronological semimeasures are exactly the LSC weak function semimeasures, so the same holds with M_F replaced by any of these (with K(ν) added).

*Proof.* The events for different y_{n+1} are disjoint subsets of the event for y_{1:n}. If x_{n+1} repeats an earlier input, only one label survives. Lower semicomputability holds as in §1.2. Cor. 4.3(a) gives the second statement. ∎

---

## 2. Hänni's two counterexamples

The draft says: "let x_1, x_2, … be a deterministic sequence of increasingly long random strings … (x_1,0),(x_2,x_1),(x_3,x_2),… I'm pretty sure Solomonoff induction gets unbounded loss … I don't actually have a proof" (`prior/hanni-sfi-notes.md` line 24). The notes add: "you give 0 to everything except one string you've skipped among all strings of a certain length … solomonoff has nothing inside doing that — if it had, we could compress these incompressible strings!" (line 70).

We use ε as the first label of the chain, so that labels and inputs never collide; the draft's "0" could equal x_1.

### 2.1 The chain

**Lemma 2.0 (chain semimeasure) [proved].** For a string x and a finite sequence z = (z_1,…,z_k) of nonempty strings (k ≥ 0), put

  ν(z ∣ x) := λ{ω : f_ω(x) = z_1, f_ω(z_1) = z_2, …, f_ω(z_{k−1}) = z_k, f_ω(z_k) = ε}

(for k = 0 this means f_ω(x) = ε). Then Σ_z ν(z∣x) ≤ 1, and ν is LSC uniformly in x.

*Proof.* Fix ω and x, and suppose that z ≠ z′ both satisfy the condition. Put z_0 = z′_0 = x. If they first differ at a position j ≥ 1, then z_j = f_ω(z_{j−1}) = z′_j, a contradiction. If z is a proper prefix of z′ (length k < k′), then f_ω(z_k) = ε and also f_ω(z_k) = f_ω(z′_k) = z′_{k+1} ≠ ε, a contradiction. So the events are disjoint. The events are effectively open, uniformly. ∎

**Theorem 2.1 (chain) [proved].** Let x_1,…,x_n (n ≥ 2) be distinct nonempty strings. Put D_n := {(x_1, ε)} ∪ {(x_{i+1}, x_i) : i < n}, revealed in the order (x_1,ε),(x_2,x_1),….

(a) L_SFI(D_n) ≥ K(x_1,…,x_{n−1} ∣ x_n) − c and L_SFI(D_n) ≤ K(x_1,…,x_{n−1}) + c.

(b) Let 1 ≤ ℓ_1 < ℓ_2 < ⋯ be computable, ω Martin-Löf random, x_i the i-th block of ω of length ℓ_i, and L_k := Σ_{i≤k} ℓ_i. Then
  L_{n−1} − K(ℓ_n) − c_ω ≤ L_SFI(D_n) ≤ L_{n−1} + K(n) + c.
For ℓ_i = i: n(n−1)/2 − 2 log n − c_ω ≤ L_SFI(D_n) ≤ n(n−1)/2 + 2 log n + c (for n ≥ 2, with K(n) ≤ log n + 2 log log n + c).

(c) The predictor P = "predict ε on the empty history; otherwise predict the unique input of the history that is not a label of the history" (the draft's predictor) has loss 0 on this sequence. It is deterministic, has K(P) = O(1), and uses only the *set* of revealed pairs.

*Proof.* (a) Lower bound: every ω with f_ω ⊇ D_n satisfies the condition of Lemma 2.0 with x = x_n and z = (x_{n−1},…,x_1). So M_F(D_n) ≤ ν(z∣x_n) ≤ 2^{−K(z∣x_n)+c} by (F4), and K(z∣x_n) = K(x_1,…,x_{n−1}∣x_n) ± c. Upper bound: the program with the list x_1,…,x_{n−1} built in does the following on input x. It outputs ε if x = x_1, outputs x_{i−1} if x = x_i with 2 ≤ i ≤ n−1, and otherwise outputs x_{n−1}. It is consistent with D_n. Apply (F3).
(b) ω_{1:L_n} is computable from the tuple x_{1:n}, so (F5) gives K(x_{1:n}) ≥ L_n − c_ω − c. By (F7), K(x_{1:n}) ≤ K(x_n) + K(x_{1:n−1}∣x_n) + c ≤ ℓ_n + K(ℓ_n) + K(x_{1:n−1}∣x_n) + c′. Hence K(x_{1:n−1}∣x_n) ≥ L_{n−1} − K(ℓ_n) − c_ω − c″. For the upper bound, the tuple x_{1:n−1} is determined by n and ω_{1:L_{n−1}}, and L_{n−1} is computable from n.
(c) At step i ≥ 2 the history's inputs are x_1,…,x_{i−1} and its labels are ε, x_1,…,x_{i−2}. ∎

So the draft's belief is correct, with rate L_{n−1} up to logarithmic terms. The same bound holds in expectation when the blocks are uniform and independent (Thm 3.7). *Convention:* the lower bounds in (a) and (b) are for L_SFI = −log M_F(D_n), the semimeasure convention. For the per-step normalised predictor, Prop. 2.4(a) gives n(n−1)/2 − O(n log n) when ℓ_i = i.

### 2.2 Skipped strings

**Setup.** For each ℓ ≥ 1 fix s_ℓ ∈ {0,1}^ℓ. Put f_s(x) := 1 if x = s_{|x|}, and 0 otherwise (x nonempty). Reveal the strings in blocks ℓ = 1, 2, …. Block ℓ consists of all strings of length ℓ other than s_ℓ, in lexicographic order, followed by s_ℓ. Let D^{(ℓ)} be the data after blocks 1,…,ℓ, so dom D^{(ℓ)} = {0,1}^{1..ℓ}.

**Theorem 2.2 (skipped strings) [proved].**
(a) The predictor P = "predict 1 at x iff every other string of length |x| is already an input of the history, else 0" has loss 0. It is deterministic, has K(P) = O(1), and is set-based. (At ℓ = 1 the first string revealed has a sibling not yet seen, so P predicts 0, which is correct; the second is s_1, and P predicts 1.)
(b) L_SFI(D^{(ℓ)}) ≥ K(s_1,…,s_ℓ ∣ ℓ) − c.
(c) L_SFI(D^{(ℓ)}) ≤ ℓ(ℓ+1)/2 + c.
(d) Suppose s_1 s_2 s_3 … are the consecutive blocks of a Martin-Löf random ω. Then L_SFI(D^{(ℓ)}) ≥ ℓ(ℓ+1)/2 − K(ℓ) − c_ω. For each ℓ, all but a 2^{−k} fraction of the tuples (s_1,…,s_ℓ) give L_SFI(D^{(ℓ)}) ≥ ℓ(ℓ+1)/2 − k − c. Since L_SFI is nondecreasing in the data (F2), SFI's loss along the whole reveal sequence is unbounded.

*Proof.* (b) Lemma 1.1. The domain {0,1}^{1..ℓ} and ℓ are computable from each other. Given the domain, the labelling determines (s_1,…,s_ℓ).
(c) Let the function machine read, for each length j, its own block of j tape bits as a guess s′_j, and answer 1 at x iff x = s′_{|x|}. It is consistent with D^{(ℓ)} with probability Π_{j≤ℓ} 2^{−j}. Apply (F1).
(d) (F5) gives K(s_{1:ℓ}) ≥ ℓ(ℓ+1)/2 − c_ω. Then K(s_{1:ℓ} ∣ ℓ) ≥ K(s_{1:ℓ}) − K(ℓ) − c. The counting statement is the usual one: fewer than 2^{N−k} tuples have K(·∣ℓ) < N − k, where N = ℓ(ℓ+1)/2. ∎

*Convention:* the lower bounds in (b) and (d) are in the semimeasure convention. Prop. 2.4(b) gives ℓ(ℓ+1)/2 − O(ℓ log ℓ) for the normalised predictor.

**Remark.** dom D^{(ℓ)} is an initial segment of the length-lexicographic order. By Cor. 5.3, L_SFI(D^{(ℓ)}) = L_ξ(D^{(ℓ)} in length-lex order) ± c. In that order s_ℓ sits at its lexicographic place, not last. ξ's loss is O(1) in Hänni's order and ≈ ℓ(ℓ+1)/2 in length-lex order. The reveal order carries the information.

### 2.3 The cost is intrinsic to order-free prediction

A *weak function semimeasure* (foundations Def 2.1) is a map ν from data sets to [0,1] with ν(∅) ≤ 1 and Σ_y ν(D ∪ {(x,y)}) ≤ ν(D) for every x ∉ dom D. Weak semimeasures are the order-independent online predictors (foundations §2). They include M_F, M_prod, W and the universal weak semimeasure M^w (foundations Thm 3.4, Thm 4.2).

**Proposition 2.3 [proved].** Let ν be any weak function semimeasure.
(a) For every string x, Σ_z ν(D(x,z)) ≤ 1. Here D(x,z) := {(x,z_1),(z_1,z_2),…,(z_{k−1},z_k),(z_k,ε)}, and z ranges over finite sequences (k ≥ 0) of distinct nonempty strings different from x.
(b) If ν is LSC, then on the chain of Thm 2.1, −log ν(D_n) ≥ K(x_{1:n−1} ∣ x_n) − K(ν) − c. On the skipped strings of Thm 2.2, −log ν(D^{(ℓ)}) ≥ K(s_1,…,s_ℓ ∣ ℓ) − K(ν) − c. So the lower bounds of Thm 2.1(b) and Thm 2.2(d) hold for ν, with K(ν) subtracted.
(c) For every ν, computable or not: if the chain blocks x_i are independent and uniform on {0,1}^{ℓ_i}, then E[−log ν(D_n)] ≥ H(x_{1:n−1} ∣ x_n) = L_{n−1}. If the s_ℓ are independent and uniform, then E[−log ν(D^{(ℓ)})] ≥ ℓ(ℓ+1)/2.

*Proof.* (a) For j ≥ 0 and distinct nonempty z_1,…,z_j ≠ x, let O_j(z_{1:j}) := {(x,z_1),(z_1,z_2),…,(z_{j−1},z_j)}, with O_0 := ∅. Its last point z_j (x when j = 0) is not in dom O_j = {x, z_1,…,z_{j−1}}. The weak inequality at that point gives Σ_{y∈Y} ν(O_j ∪ {(z_j, y)}) ≤ ν(O_j). Among the terms, y = ε gives the terminal set D(x, z_{1:j}). Each nonempty y ∉ {x, z_1,…,z_j} gives O_{j+1}(z_{1:j}, y). The other terms are ≥ 0 and are dropped. Hence
  ν(O_j(z_{1:j})) ≥ ν(D(x, z_{1:j})) + Σ_y ν(O_{j+1}(z_{1:j}, y)).
Induction on J gives
  Σ_{k≤J} Σ_{|z|=k} ν(D(x,z)) + Σ_{|z|=J+1} ν(O_{J+1}(z)) ≤ ν(∅) ≤ 1.
So every partial sum of the terminal masses is ≤ 1. Let J → ∞.
(b) The chain data are D_n = D(x_n, (x_{n−1},…,x_1)). z ↦ ν(D(x,z)) is a discrete semimeasure by (a), LSC uniformly in x. Apply (F4), then the proof of Thm 2.1(b). For the skipped strings use Lemma 1.1 for weak ν, then the proof of Thm 2.2(d).
(c) Gibbs' inequality, applied conditionally on x_n to the sub-probability z ↦ ν(D(x_n,z)). For the skipped strings, apply it to the labellings of {0,1}^{1..ℓ}. ∎

So the chain and skipped-string losses are not caused by the universal prior or by shared randomness. Every predictor that sees the past only as a set **and** is order-independent pays them. Hänni's predictors are set-based but not order-independent. The examples track makes the same point for H5 (examples Prop 2.4).

### 2.4 The normalised predictor (referee m21; Q4 for these examples)

The per-step normalised SFI predictor M̄_F is not order-free (foundations Prop 5.3), and it is set-based in the sense that it sees the past only as the set D_{t−1}. Set-based predictors exist with loss 0 on both examples (Thm 2.1(c), Thm 2.2(a)). So Prop. 2.3 does not apply to it, and no information-theoretic argument alone can give a lower bound. The argument below uses the structure of M_F: the normaliser S_t is bounded below by one *total* hypothesis that knows the past, and that hypothesis is cheap to name. The method is the one the examples referee uses for H5 (its Prop R2).

**Lemma 2.4a (normaliser lower bound) [proved].** For every data set D, every x ∉ dom D and every function machine B,
  S(D, x) := Σ_y M_F(D + (x,y)) ≥ 2^{−K(B)−c} λ{ω : f^B_ω ⊇ D, f^B_ω(x) ≠ ⊥}.
If f^B_ω is total for every ω, the right side is 2^{−K(B)−c} ν_B(D).

*Proof.* (F1) gives M_F(D + (x,y)) ≥ 2^{−K(B)−c} ν_B(D + (x,y)) for each y. The events {f^B_ω ⊇ D, f^B_ω(x) = y} for different y are disjoint, and their union is {f^B_ω ⊇ D, f^B_ω(x) ≠ ⊥}. Sum over y. ∎

**Proposition 2.4 (normalised SFI on the chain and the skipped strings) [proved; finite proxy computed: c9].** Let l̄_t := −log M̄_F(y_t ∣ D_{t−1}, x_t) = −log M_F(D_t) + log S_t (§1.2), and let L̄ be the sum of the l̄_t.
(a) *Chain* (setting of Thm 2.1(b): ℓ computable and strictly increasing, ω Martin-Löf random). For every t ≥ 2,
  l̄_t ≥ −log M_F(D_t) − L_{t−2} − K(t−2) − c ≥ ℓ_{t−1} − K(ℓ_t) − K(t−2) − c_ω − c   (L_0 := 0).
Hence L̄_n ≥ Σ_{t=2}^n (ℓ_{t−1} − K(ℓ_t) − K(t−2) − c_ω − c)^+. For ℓ_i = i and n ≥ 2: L̄_n ≥ n(n−1)/2 − n(4 log n + c_ω + c′).
If instead the blocks x_i are independent and uniform on {0,1}^{ℓ_i} (the randomized chain of Thm 3.7), then E[l̄_t] ≥ ℓ_{t−1} − K(t−2) − c for t ≥ 2, so E[L̄_n] ≥ Σ_{t=2}^n (ℓ_{t−1} − K(t−2) − c)^+, which is n(n−1)/2 − n(2 log n + c′) for ℓ_i = i.
(b) *Skipped strings* (setting of Thm 2.2(d)). At the last step of block ℓ (the query s_ℓ),
  l̄ ≥ −log M_F(D^{(ℓ)}) − ℓ(ℓ−1)/2 − K(ℓ) − c ≥ ℓ − 2K(ℓ) − c_ω − c.
Hence after block ℓ ≥ 2, L̄ ≥ Σ_{j≤ℓ} (j − 2K(j) − c_ω − c)^+ ≥ ℓ(ℓ+1)/2 − ℓ(4 log ℓ + c_ω + c′). If the s_j are independent and uniform, the expected normalised loss at s_ℓ is ≥ ℓ − K(ℓ) − c.

*Proof.* (a) *The broom B_j* (j ≥ 0) reads j consecutive tape blocks v_1, …, v_j of lengths ℓ_1, …, ℓ_j. It sets f(v_1) := ε, f(v_i) := v_{i−1} for 2 ≤ i ≤ j, and f(x) := v_j for every other x (for j = 0, f ≡ ε). The v_i have distinct lengths, so f is well defined. f is total for every tape, and B_j is computable from j, so K(B_j) ≤ K(j) + c. On the event {v_i = x_i for all i ≤ j}, of probability 2^{−L_j}, f ⊇ D_{j+1}: f(x_1) = ε, f(x_i) = x_{i−1} for 2 ≤ i ≤ j, and f(x_{j+1}) = v_j = x_j because |x_{j+1}| = ℓ_{j+1} is not among ℓ_1, …, ℓ_j. So ν_{B_j}(D_{j+1}) ≥ 2^{−L_j}. At step t ≥ 2, apply Lemma 2.4a with B = B_{t−2}, D = D_{t−1} and x = x_t ∉ dom D_{t−1}: S_t ≥ 2^{−K(t−2)−c−L_{t−2}}. Insert this in l̄_t = −log M_F(D_t) + log S_t; this is the first inequality. The second is Thm 2.1(b) at horizon t: −log M_F(D_t) ≥ L_{t−1} − K(ℓ_t) − c_ω. Each l̄_t is ≥ 0, so the positive parts may be summed. For ℓ_i = i use K(t), K(t−2) ≤ 2 log n + c for 2 ≤ t ≤ n, and Σ_{t=2}^n (t−1) = n(n−1)/2. For the expected bound, take expectations in the first inequality and use Prop. 2.3(c) at horizon t: E[−log M_F(D_t)] ≥ L_{t−1}.
(b) *The machine T_ℓ* reads, for each j < ℓ, a tape block g_j of length j. It outputs 1 at x iff |x| < ℓ and x = g_{|x|}, and 0 at every other x. It is total, and K(T_ℓ) ≤ K(ℓ) + c. Before the query s_ℓ the data are D′ := D^{(ℓ−1)} ∪ {(x, 0) : |x| = ℓ, x ≠ s_ℓ}, and f^{T_ℓ} ⊇ D′ exactly when g_j = s_j for all j < ℓ, which has probability 2^{−ℓ(ℓ−1)/2}. Lemma 2.4a gives S ≥ 2^{−K(ℓ)−c−ℓ(ℓ−1)/2}. Then use Thm 2.2(d) (pathwise) or Prop. 2.3(c) (expectation) for −log M_F(D^{(ℓ)}). The other steps have l̄ ≥ 0. ∎

*An equivalent form.* Foundations Prop 5.5(a) writes L̄_n = L_SFI(D_n) − Σ_t log(1/Z_t), where Z_t := S_t/M_F(D_{t−1}) is the posterior probability that f_ω(x_t) is defined. In the chain, Lemma 2.0 and the proof of Thm 2.1(b) give M_F(D_{t−1}) ≤ 2^{−L_{t−2}+K(ℓ_{t−1})+c_ω+c}, and the broom gives S_t ≥ 2^{−L_{t−2}−K(t−2)−c}. So log(1/Z_t) ≤ K(ℓ_{t−1}) + K(t−2) + c_ω + c: the posterior keeps probability at least 2^{−O(log t)−c_ω} on "defined at the next input", and the normalisation can save only O(log t) bits per step.

*What c9 checks.* c9 builds exact finite mixtures of random-function laws that contain the brooms (resp. the T_ℓ) and also heavy *partial* components, which make the normaliser small. On all 1024 chains with block lengths 1–4 and all 64 skipped-string tuples with lengths 1–3, in exact rationals, it confirms: the closed forms of the component masses; the telescoping of the raw losses; S_t ≥ w_B 2^{−L_{t−2}} (resp. w_T 2^{−ℓ(ℓ−1)/2}) on every path; the order-free expectation bounds of Prop. 2.3(c); and the pathwise inequality l̄_t ≥ −log ν(D_t) − L_{t−2} − log(1/w_B). With the partial components, the normalised cumulative loss is well below the raw loss (6.62 against 8.61 bits for the chain, 6.54 against 9.00 bits for the skipped strings), so the normaliser matters, but it stays above what the proposition guarantees. c9 is a check of the algebra on finite mixtures, not of M_F.

*Scope.* The method needs the information per step (ℓ_{t−1} bits for the chain, ℓ bits at the end of a skipped-string block) to exceed the O(log t) cost of naming the broom. It gives nothing for the separations of Prop. 4.5(i) and (iii), where the information is about one bit per step, or for the two-step GF example of Thm 5.4. For those, Q4 stays **[open]**. For the cyclic permutation (H5) the examples referee proves the analogous per-step bound for t ≤ 2^{(1−δ)n} by the same method.

---

## 3. The draft's Thm 1 (computable reveal distribution Δ)

> Thm 1. Let C be the set of computable samplers which get to see the revealed input-output data set so far … Suppose the data-generating process samples a function f : X → Y and then reveals a sequence of input-output pairs, with the sequence of inputs sampled from a distribution Δ. Then each predictor P in C can only beat solomonoff function induction in expected log loss by at most the complexity C_Δ of sampling from the reveal sequence distribution Δ plus a constant C_P.

**Three readings.**
* **Reading A (fixed reveal law that does not see f).** x_i ~ Δ(· ∣ h_{i−1}). The input choice sees f only through revealed labels. Δ may use private randomness and memory independent of f. f is arbitrary.
* **Reading C (a standalone reveal law for each f).** For each f there is a reveal law Δ_f(x ∣ h) that sees only the revealed history (with private randomness independent of f). The inputs are drawn from Δ_f, and C_Δ := K(Δ_f) is its complexity as a standalone sampler, or a bound on this uniform in f. Reading A is the case Δ_f = Δ for all f.
* **Reading B (oracle).** x_i ~ Δ(· ∣ f, h_{i−1}), with Δ computable relative to an oracle for f, and C_Δ the complexity of that oracle machine.

Hänni's Δ is "a distribution over reveal sequences". Such a law may keep private memory, for example "draw a random permutation of A, then reveal in that order". Lemma 3.0 reduces this to what the theorems use.

**Lemma 3.0 (private memory) [proved].** Let a reveal mechanism that does not see f be given by a random element R (the private memory, including any private coins) and selection maps x_i = sel_i(R, h_{i−1}). Let f have any law independent of R, and y_i = f(x_i). Write
  Δ(x_{1:n} ‖ y_{1:n−1}) := Pr_R[sel_i(R, h_{i−1}) = x_i for all i ≤ n],
the *reveal-sequence law* (h_{i−1} built from the given x's and y's). Then:
(a) The joint law of (f, R, h_n) factorises as [law(f) · Π_{i≤n} 1[y_i = f(x_i)]] · [law(R) · Π_{i≤n} 1[x_i = sel_i(R, h_{i−1})]].
(b) For every i, f and x_i are conditionally independent given h_{i−1}. So I(f → x_{1:n}) = 0 whenever the inputs and labels up to time n are finite-valued.
(c) Given f, the probability of the input sequence x_{1:n} is Δ(x_{1:n} ‖ f(x_1), …, f(x_{n−1})). The effective kernel Δ̄(x_i ∣ h_{i−1}) := Δ(x_{1:i} ‖ y_{1:i−1})/Δ(x_{1:i−1} ‖ y_{1:i−2}) (on histories of positive probability) depends neither on f nor on its law.
(d) If the mechanism is a computable sampler with private memory that halts with probability 1 at every step, whatever labels it is fed, and its inputs up to time n lie in a finite set A_n given as an explicit list, then Δ(x_{1:n} ‖ y_{1:n−1}) is a computable real, uniformly in (x_{1:n}, y_{1:n−1}).

*Proof.* (a) Given (f, R), the history is determined step by step, and it equals h_n exactly when both indicator products are 1. (b) Fix h_{i−1} and x_i. By (a), with n := i, the conditional law of (f, R) given (h_{i−1}, x_i) is proportional to a function of f times a function of R, and the f-factor law(f)·Π_{j<i} 1[y_j = f(x_j)] does not depend on x_i. So the conditional law of f given (h_{i−1}, x_i) is the same for every x_i of positive conditional probability, that is, f ⊥ x_i ∣ h_{i−1}, and each term I(f; x_i ∣ h_{i−1}) vanishes. (c) Sum the R-factor of (a) over R. (d) Δ(x_{1:n} ‖ y_{1:n−1}) is lower semicomputable: enumerate the halting computations of the sampler when it is fed the labels y. For upper semicomputability, feed the sampler the label strategy g that answers y_j at step j while the inputs so far agree with x_{1:j}, and a fixed label otherwise. Under g the sampler's input sequences x′_{1:n} ∈ A_n^n have total probability 1, because it halts almost surely at each step. The sequence x_{1:n} itself has probability Δ(x_{1:n} ‖ y_{1:n−1}) under g. So Δ(x_{1:n} ‖ y_{1:n−1}) = 1 − Σ_{x′ ≠ x} Pr_g[x′], a finite sum of lower semicomputable terms subtracted from 1. ∎

So private memory changes nothing in Readings A and C: the input choice still carries no information about f beyond the revealed labels, and the theorems below use Δ only through the reveal-sequence law Δ(x‖y). "Δ(x ∣ h)" below denotes the effective kernel, and Δ(x‖y) := Π_i Δ(x_i ∣ h_{i−1}) the reveal-sequence law. In Reading B the kernel may also depend on f.

**Hänni's text fixes Reading C.** The sentence before Thm 1 reads (`prior/hanni-sfi-notes.md` line 26; draft PDF text lines 117–129): "One could hope that there would at least be a version for simple reveal sequence distributions, but I think this will also fail if … the reveal sequence choice provide[s] information about the function — actually, one can just use the random string example above, except now putting the randomization inside the reveal sequence distribution, and letting the function depend on the chosen reveal sequence … However, we can get a version of Thm 1 in case … the reveal sequence distribution is simple to sample from conditional on any particular choice of function f".
* That example is the randomized chain of Thm 3.7. Under Reading B its oracle complexity is O(1). So under Reading B the condition "simple to sample from conditional on f" would not exclude the example that Hänni gives in the same breath as failing.
* Under Reading C, Δ_f is the point mass on the chain determined by f. So K(Δ_f) ≈ K(x_{1:n}) ≈ Σ ℓ_i, and the example is excluded.
* His proof sketch simulates Δ inside a function machine, which has no access to f. That too presupposes Reading C.

`notes.md` called Reading B "the literal reading" and reported Thm 1 as false in it. That framing is withdrawn (referee M1). Reading B is kept below as a stronger hypothetical variant. It fails, as Hänni himself said.

### 3.1 The proof sketch fails

**Proposition 3.1 [computed: c1].** Take X = {a,b}, f(a) = f(b) = β with β a uniform bit, and Δ showing a then b. P predicts y_1 uniform and y_2 = y_1, so P's loss is 1 bit. The private-randomness simulator g gives each input its own simulated history, so g(a) and g(b) are independent uniform bits and g's loss is 2 bits. The shared-randomness simulator and the mixture of the two constant functions both have loss 1 bit (`c1_brief_counterexample.out`, exact rationals).

The sketch makes two errors.
1. With private randomness the simulator is a product over inputs, so it loses the cross-input correlations that P exploits.
2. The Jensen step averages P's prediction at x over *simulated* histories, whose labels are sampled from P. The theorem would need the average over *true* histories, whose labels are f's. In the example the per-input loss at b is 0 bits under the true history (a, β) and 1 bit under the simulated one.

*Supplementary, c2(B).* On random finite instances (X = {0,1,2}, Y = {0,1}, n = 3, a reveal law that does not see f, f ~ π), a private simulator's expected loss exceeded E[L_P] in 60/60 instances when P is the Bayes predictor for π, and in 55/60 when P is Bayes for a perturbed prior. It never did for random (poor) P. The c2 simulator is the *normalised* one (conditioned on visiting x), with the horizon truncated at 3. Hänni's simulator is unnormalised with unbounded horizon. Normalising only lowers the loss, but the truncation makes it a different object. So c1 alone establishes Prop. 3.1, and c2(B) is supporting evidence only (referee m15).

The example does not refute Thm 1: SFI itself has loss 1 bit there.

### 3.2 The shared-randomness simulator

**Theorem 3.2 [proved].** Let Δ (input sampler, given h) and P (label sampler, given (h,x)) be computable samplers; defective ones are allowed. For every consistent sequence,

  M_F(D_n) ≥ 2^{−K(Δ,P)−c} · Δ(x_{1:n} ‖ y_{1:n−1}) · P(y_{1:n} ‖ x_{1:n}),

where Δ(x‖y) := Π_i Δ(x_i ∣ h_{i−1}). The samplers may keep private memory between calls; then Δ(x‖y) and P(y‖x) are their sequence laws (Lemma 3.0), and the proof is the same, with each call continuing from the stored state. If the inputs are distinct, the right-hand side may be replaced by 2^{−K(Δ,P)−c} Σ_σ Δ(x_σ‖y_σ)P(y_σ‖x_σ), summed over all orders σ of D_n. Hence

  L_SFI(D_n) ≤ L_P + L_Δ + K(Δ) + K(P) + c,  with L_Δ := −log Δ(x‖y).

*Proof.* The function machine T uses ω as one stream of random bits for one run of the alternating process. It samples x′_1 from Δ(·∣∅), then y′_1 from P(·∣∅,x′_1), then x′_2 from Δ(·∣h′_1), and so on. Each sampler call reads fresh consecutive bits. On query x, T runs the process until the first j with x′_j = x and outputs y′_j. It diverges if no such j appears. T's answer depends on a finite prefix of ω, so T is a function machine, and K(T) ≤ K(Δ,P) + c.

Suppose the simulated trajectory begins with x_1y_1…x_ny_n. Then every x ∈ dom D_n is first visited with D_n's label; a repeated input is first visited at its first occurrence. The tapes that produce this beginning form a disjoint union of cylinders [w_1v_1…w_nv_n], where w_i ranges over the halting computations of Δ on h_{i−1} that output x_i, and v_i over those of P on (h_{i−1}, x_i) that output y_i. Each such set is prefix-free, so the measure of the event is Π_i Δ(x_i∣h_{i−1})P(y_i∣h_{i−1},x_i). For distinct inputs, different orders give different trajectory prefixes, hence disjoint events. Apply (F1). ∎

**Corollary 3.3 (deterministic policies) [proved].** If x_i = δ(h_{i−1}) for a computable δ (adaptive choices allowed), then for every f, every sampler P and every n, L_SFI(D_n) ≤ L_P + K(δ) + K(P) + c on every path. In Reading C with deterministic Δ_f = δ_f this is Thm 1 pathwise, with C_Δ = K(δ_f) and no other term.

*Proof.* Thm 3.2 with the deterministic input sampler δ, for which L_Δ = 0 on the realised path. ∎

**Corollary 3.4 (SFI against Solomonoff on the joint sequence) [proved].**
(a) For every consistent sequence: L_SFI(D_n) ≤ −log M(code(x_1y_1…x_ny_n)) + c.
(b) If the inputs are distinct: L_SFI(D_n) ≤ −log Σ_σ M(code(D_n in order σ)) + c.

*Proof.* Take the construction of Thm 3.2, with the universal monotone machine run on ω as the sampler. Its output is parsed into alternating blocks x̄′, ȳ′, and T answers query x with the label after the first block x̄′ = x̄. (a) If the output extends code(x_1y_1…x_ny_n), then every input of the sequence is first met with its label in D_n (repeats included, since the sequence is consistent), so f_ω ⊇ D_n. The probability of that event is M(code(·)) by the definition in (F8). (b) For distinct inputs, the codes of different orders are pairwise incomparable, because the block code is prefix-free. So the events are disjoint, and their probabilities add. ∎

(`notes.md` derived (a) from (b), which fails when inputs repeat: then the actual sequence is not one of the "orders of D_n". Both parts are now proved separately; referee m2.)

So SFI's label loss is at most Solomonoff's loss on predicting *both* inputs and labels. The input part is what SFI pays for not seeing the inputs. With Thm 4.6(b) this gives L_SFI ≤ L_P + K(P) + L_ξ′^x + c for every sampler P, where L_ξ′^x is the universal chronological complexity of the input sequence given the labels.

### 3.3 Reading A with a computable prior: the Bayes form

**Theorem 3.5 [proved].** Let π be a computable random function (§1.2) and f ~ π. Choose inputs by any mechanism that sees f only through revealed labels: x_i = s_i(h_{i−1}, R) for arbitrary (not necessarily computable) maps s_i and a random element R independent of f. Let y_i = f(x_i).
(a) On every path of positive probability, the chronological Bayes predictor B(y ∣ h, x) := π(D_h ∪ {(x,y)})/π(D_h) is the conditional law of y_i given (h_{i−1}, x_i). If x ∈ dom D_h, then B gives the stored label probability 1. The loss of B is L_B = −log π(D_n), and L_SFI(D_n) ≤ L_B + K(π) + c on every path.
(b) For every history-aware predictor P, computable or not, E[L_P] ≥ E[L_B]. Hence E[L_SFI(D_n)] ≤ E[L_P] + K(π) + c, with no dependence on the selection mechanism or on P. In particular E[L_SFI] ≤ E[L_ξ] + K(π) + c.

*Proof.* (a) The joint law of (f, R, h_n) has the form π(df) · P_R(dR) · Π_i 1[x_i = s_i(h_{i−1}, R)] · 1[f ⊇ D_n]. For fixed h_{i−1} it is the product of a function of f and a function of R. So f and R are conditionally independent given h_{i−1}, and the conditional law of f given h_{i−1} (and given x_i, which is a function of h_{i−1} and R) is π restricted to {f ⊇ D_{i−1}} and renormalised. Its predictive probability for y_i is π(D_i)/π(D_{i−1}), and the product telescopes to π(D_n). (F1) gives M_F ≥ 2^{−K(π)}π.
(b) B is the true conditional law, so Gibbs' inequality gives E[−log P(y_i∣h_{i−1},x_i) ∣ h_{i−1}, x_i] ≥ E[−log B(y_i∣h_{i−1},x_i) ∣ h_{i−1}, x_i] at each step. If the right side is infinite, so is the left. Sum over i. For the last statement take P = ξ. ξ is a chronological semimeasure, so its conditionals are sub-probabilities and Gibbs applies. ∎

[computed: c2(C), random instances: the Bayes loss equals −log π(D_n) on every path, to 2·10^{−15}, and E[L_P] ≥ E[−log π(D_n)] in all instances. r1(A), a selector with private memory and exact rationals: the true conditional law equals B at every reachable (h, x) in 25 instances.]

### 3.4 When the input choice may depend on f

**Theorem 3.6 (directed information) [proved].** Let π be as in Thm 3.5 and f ~ π. Let the inputs have an arbitrary joint law with f, with y_i = f(x_i). In particular x_i may be drawn from any kernel Δ(· ∣ f, h_{i−1}) that may use private randomness. Assume that the inputs and labels up to time n take values in finite sets A and B, so that H(h_n) < ∞. Let μ be the joint law, L_B := −log μ(y‖x) the chronological Bayes loss (μ(y‖x) := Π_i μ(y_i ∣ h_{i−1}, x_i)), and

  I(f → x_{1:n}) := Σ_{i=1}^n I(f ; x_i ∣ h_{i−1})

the directed information from the function to the input choices. Then
(a) E[−log π(D_n)] − E[L_B] = I(f → x_{1:n}) − E[KL(μ(f ∈ · ∣ h_n) ‖ π(f ∈ · ∣ f ⊇ D_n))] ≤ I(f → x_{1:n});
(b) for every predictor P: E[L_SFI(D_n)] ≤ E[L_P] + I(f → x_{1:n}) + K(π) + c.

*Proof.* (a) No restriction of f is needed; the computation runs on the general probability space, with h_n finite-valued (referee m9). Let Q_f(x_{1:n}) := μ(x_{1:n} ∣ f) be a regular conditional probability of the input sequence given f. Given f, the labels are determined, so μ(h_n ∣ f) = Q_f(x_{1:n}) · 1[f ⊇ D_n]. Hence

  μ(h_n) = E_{f′∼π}[Q_{f′}(x) 1[f′ ⊇ D_n]] = π(D_n) · Q̄_D(x),  with Q̄_D(x) := E_{f′∼π}[Q_{f′}(x) ∣ f′ ⊇ D_n].

The posterior of f given h_n has density Q_f(x)/Q̄_D(x) with respect to π(· ∣ f ⊇ D_n). Therefore

  I(f; h_n) = E[log μ(h_n∣f)/μ(h_n)] = E[log Q_f(x)/Q̄_D(x)] + E[−log π(D_n)] = E[KL(μ(f∈·∣h_n) ‖ π(·∣f⊇D_n))] + E[−log π(D_n)].

By the chain rule, I(f; h_n) = Σ_i [I(f; x_i ∣ h_{i−1}) + I(f; y_i ∣ h_{i−1}, x_i)]. Since y_i is a function of (f, x_i), I(f; y_i ∣ h_{i−1}, x_i) = H(y_i ∣ h_{i−1}, x_i), and Σ_i H(y_i ∣ h_{i−1}, x_i) = E[L_B]. So I(f; h_n) = I(f → x) + E[L_B]. Subtracting the two expressions for I(f; h_n) gives (a). All terms are finite because I(f; h_n) ≤ H(h_n) < ∞.
(b) By (F1), E[L_SFI] ≤ E[−log π(D_n)] + K(π) + c. By (a) this is at most E[L_B] + I(f → x) + K(π) + c. Gibbs gives E[L_P] ≥ E[L_B]. ∎

[computed: c2(D), the identity holds to 3·10^{−15} on 40 random instances where the input choice sees f. r1(C), with private memory, alphabet size 3 and exact rationals: identity error ≤ 3·10^{−60} in 25 instances.]

In Readings A and C the input choice sees f only through revealed labels, so I(f → x) = 0 and Thm 3.6 reduces to Thm 3.5. The term I(f → x) cannot simply be dropped: the next theorem shows this.

**Theorem 3.7 (Hänni's randomized chain; Reading B is false) [proved].** Let x_i be uniform on {0,1}^i, independent. Define f(x_{i+1}) := x_i for i ≥ 1, and f(x) := ε otherwise. Reveal x_1, x_2, ….
* f is a computable random function with K(π) = O(1). The machine answers a query of length i by comparing it with tape block i (block i has i bits); if they agree and i ≥ 2 it returns tape block i−1, otherwise ε.
* Given an oracle for f, the reveal sequence is deterministic and computable by an O(1) program: for i ≥ 2, x_i is the unique string of length i with f(x) ≠ ε, and x_1 = f(x_2). So the oracle complexity of Reading B is C_Δ = O(1).
* The predictor P of Thm 2.1(c) has loss 0.
* E[L_SFI(D_n)] ≥ E[K(x_{1:n−1} ∣ x_n)] − c ≥ H(x_{1:n−1} ∣ x_n) − c = n(n−1)/2 − c, by Thm 2.1(a) and the conditional Kraft bound (F6).
* I(f → x_{1:n}) = n(n+1)/2: given f the input x_i is determined, and given h_{i−1} it is uniform on {0,1}^i.

*Proof.* Each bullet was proved where it is stated. For the third, f's graph on the revealed inputs is exactly the chain of Thm 2.1. ∎

This is the example Hänni describes in the sentence before Thm 1: "putting the randomization inside the reveal sequence distribution, and letting the function depend on the chosen reveal sequence". His remark that a "simple reveal law" version fails here is **correct**. Thm 3.7 makes it rigorous, with the rate n(n−1)/2. The theorem refutes only Reading B, which his text does not intend. Under Reading C the example is excluded: Δ_f is the point mass on the chain, and for all but a 2^{−k} fraction of chains K(Δ_f) ≥ n(n+1)/2 − k − c. [computed: r1(D), for n = 2, 3, 4, brute force gives E[−log π(D_n)] = I(f→x) = n(n+1)/2 and Bayes loss 0.]

For the same reason no bound through the algorithmic mutual information I(Δ : f) between the reveal *law* and f can hold in Reading B: here I(Δ : f) ≤ K(Δ) + c = O(1). That answers Hänni's open question ("can thm 1 be improved to a version that talks about the algorithmic mutual information of Δ and f") negatively **for Reading B only**. For Reading C, see §3.6.

§5.3 gives a second Reading-B example, with exact constants: E[L_SFI] ≥ 3m/2 − 2 while E[L_P] = m.

### 3.5 Readings A and C with arbitrary f: the minimax theorem

**Hypotheses.**
* (H1) Y is finite.
* (H2) There is a computable map j ↦ A_j to finite subsets of X, given as explicit lists, such that all inputs at steps ≤ n lie in A_n. K(A) denotes the complexity of an index of this map. If A_n = {0,1}^{≤g(n)} for a fixed computable g, then K(A) = K(g) + c.

The reveal law Δ enters only through its reveal-sequence law Δ(x_{1:n} ‖ y_{1:n−1}) (Lemma 3.0; private memory allowed), or Δ(x_{1:n} ‖ f, y_{1:n−1}) in the peeking case, where it may also depend on f|_{A_n}. Given f, the input sequence x_{1:n} has probability Δ(x_{1:n} ‖ f(x_1), …, f(x_{n−1})). For a predictor P put

  C_dir(Δ, n) := sup_π I_π(f → x_{1:n}),

with the supremum over laws π on Y^{A_n} and the inputs drawn from Δ. C_dir = 0 when Δ does not see f, by Lemma 3.0(b).

**Theorem 3.8 (minimax) [proved; (b) for kernels that see f: proof sketch].** Fix n, and assume (H1) and (H2). Assume either
(a) P(y ∣ h, x) and the reveal-sequence law Δ(x‖y) take rational values computable from their arguments (Hänni's "computable distribution in the first sense"); or
(b) they take computable real values, uniformly in their arguments. By Lemma 1.0 and Lemma 3.0(d) this includes every computable sampler that halts with probability 1, with or without private memory.
Then for **every** f : A_n → Y,

  E_{x∣f}[L_SFI(D_n)] ≤ E_{x∣f}[L_P] + C_dir(Δ,n) + K(P) + K(Δ) + K(n) + K(A) + c.

The bound also holds averaged over f ~ F, for any law F independent of the selector's private randomness. Here K(P) and K(Δ) are the complexities of programs that compute the values (exactly in (a), to any requested precision in (b)). For an almost surely halting label sampler, K(P) is at most the sampler's complexity plus c. For an almost surely halting reveal sampler with private memory, the program of Lemma 3.0(d) also uses the list A_n, so K(Δ) is at most the sampler's complexity plus K(A) + c; the K(A) is already in the bound.

*Proof.* Write Y^A for Y^{A_n} and let U be the uniform law on Y^A. Let 𝒢 := {½G_0 + ½U : G_0 a probability law on Y^A}. 𝒢 is compact and convex, and G(D) ≥ ½|Y|^{−|dom D|} ≥ ½|Y|^{−n} for every G ∈ 𝒢 and every D with at most n points. Let F_fin := {f ∈ Y^A : E_{x∣f}[L_P] < ∞}; for f ∉ F_fin the claim is trivial. For G ∈ 𝒢 and f ∈ F_fin put

  Φ_f(G) := E_{x∣f}[−log G(D_n)] − E_{x∣f}[L_P],  Φ(G, π) := Σ_{f∈F_fin} π(f) Φ_f(G)

for laws π on F_fin.

*Step 1 (minimax value).* Φ is continuous on 𝒢 × Δ(F_fin), convex in G (−log of a linear function, averaged) and affine in π. By (F9), min_G max_π Φ = max_π min_G Φ. Fix π and take G = ½π + ½U. Then −log G(D) ≤ 1 − log π(D). Thm 3.6(a), which does not need π computable, and Gibbs give

  Φ(G, π) ≤ 1 + E_π[−log π(D_n)] − E_π[L_P] ≤ 1 + E_π[−log π(D_n)] − E_π[L_B] ≤ 1 + I_π(f → x).

Hence V := min_{G∈𝒢} max_{f∈F_fin} Φ_f(G) ≤ 1 + C_dir.

*Step 2 (a rational point with slack).* For G = ½G_0 + ½U and G′ = ½G′_0 + ½U, and every D with at most n points,
  |log G(D) − log G′(D)| ≤ |G(D) − G′(D)| / (ln 2 · min(G(D), G′(D))) ≤ (½‖G_0 − G′_0‖_1) / (ln 2 · ½|Y|^{−n}) = |Y|^n ‖G_0 − G′_0‖_1 / ln 2.
So each Φ_f is Lipschitz in G_0, with constant |Y|^n/ln 2 in ℓ¹. Hence a rational G′_0 within ℓ¹-distance ln 2 · |Y|^{−n} of a minimiser has max_{f∈F_fin} Φ_f(G′) ≤ V + 1 ≤ 2 + C_dir.

*Step 3, case (a): compute V.* With rational P and Δ, the path probabilities given f are rationals computable from Δ. F_fin is decidable: f ∉ F_fin iff some positive-probability path has P(y_i∣h,x) = 0. For f ∈ F_fin, Φ_f(G) is computable to any precision for rational G. Each Φ_f is Lipschitz with the known constant of Step 2. So max_{f∈F_fin} Φ_f evaluated on a fine enough rational grid gives V to within ½. Return a grid point G′ with max_{f∈F_fin} Φ_f(G′) ≤ V + 1. This step is uniform in (P, Δ, n, A) and needs no knowledge of C_dir. (This is the argument of `notes.md`, which the referee checked.) So E_{x∣f}[−log G′(D_n)] ≤ E_{x∣f}[L_P] + 2 + C_dir for every f ∈ F_fin.

*Step 3, case (b): certified search.* Now F_fin need not be decidable, so V cannot be computed this way. Let q be a rational with C_dir ≤ q ≤ C_dir + 1; q = 0 when Δ does not see f. The search enumerates rational G′_0 and halts at the first G′ = ½G′_0 + ½U that is *certified* to satisfy

  (★) E_{x∣f}[−log G′(D_n)] < E_{x∣f}[L_P] + 3 + q  for every f ∈ Y^A.

* For each f the left side of (★) is a computable real.
* The right side is a finite sum of products Pr[path ∣ f] · L_P(path). Each Pr[path ∣ f] is a computable nonnegative real. Each L_P(path) = Σ_i −log P(y_i∣h,x) is lower semicomputable with values in [0, ∞], because P is computable and so upper semicomputable. With nondecreasing lower approximations and the convention 0·∞ = 0, each product is lower semicomputable. So the right side is lower semicomputable in [0, ∞].
* A true strict inequality "computable < lower semicomputable" is certified in finite time. When the right side is +∞ (f ∉ F_fin), its lower approximations eventually exceed the left side.
* The search dovetails over candidates and certification stages, since a candidate that violates (★) is never certified.
* By Step 2 some rational G′ has Φ_f(G′) ≤ 2 + C_dir < 3 + q for every f ∈ F_fin. That G′ satisfies (★), and its certification finishes in finite time. So the search halts, and the G′ it returns satisfies (★).
* When Δ does not see f, q = 0 and this is a complete proof. When Δ sees f, we need q, a computable value of C_dir to within 1. C_dir is the maximum over the simplex of π ↦ I_π(f → x). That function is a finite combination of terms u log(u/v), with u and v polynomial in π and in the computable values of Δ. Its maximum should be computable on a fine rational grid, using a modulus of continuity of entropy on a finite alphabet (Fannes-type). We have not written this out, so case (b) with a kernel that sees f is a **[proof sketch]**.

*Step 4 (conclusion).* In both cases the procedure is uniform in (P, Δ, n, A). So the returned G′ is a law on Y^A with rational probabilities, computable from these data. It is a function machine (rejection sampling on the tape, undefined outside A_n) with K(G′) ≤ K(P) + K(Δ) + K(n) + K(A) + c. For f ∈ F_fin, (F1) gives E_{x∣f}[L_SFI] ≤ E_{x∣f}[−log G′(D_n)] + K(G′) + c ≤ E_{x∣f}[L_P] + 4 + C_dir + K(G′) + c. For f ∉ F_fin the claim is trivial. ∎

[computed: c3 (SLSQP, 24 instances where Δ does not see f): the minimax value V was ≤ 0, with +0.000000 attained by Bayes predictors. For instances where Δ sees f, V ≤ the computed lower estimate of C_dir. A designed leak (first input = f(2)) gives V = 0.585 > 0 with C_dir ≥ 1. r2, the referee's independent certified brackets (72 instances where Δ does not see f, in three worlds, plus a hill-climb over predictors): the largest certified upper bound on V is 1.8·10^{−15}; where Δ sees f, V ≤ 0.006 against C_dir ≥ 0.81. c8: on 12 instances with irrational P and Δ, including exact zeros (so F_fin is a proper subset), the search step of case (b) was run. An approximate minimiser rounded to a dyadic grid satisfied all 8 strict inequalities (★), certified by interval arithmetic. The largest certified value of max_f Φ_f was −0.93. This illustrates Step 3; it is not a proof.]

**Corollary 3.9 (Hänni's Thm 1 in Reading C) [proved under the stated hypotheses].**
(a) Assume (H1) and (H2). Let P and the reveal-sequence law of every Δ_f have computable real values; private memory is allowed, and this includes every almost surely halting sampler (Lemma 1.0, Lemma 3.0(d)). Then for every f,
  E_{x∣f}[L_SFI(D_n)] ≤ E_{x∣f}[L_P] + K(P) + K(Δ_f) + K(n) + K(A) + c.
For f drawn from any law: E[L_SFI] ≤ E[L_P] + K(P) + E_f[K(Δ_f)] + K(n) + K(A) + c ≤ E[L_P] + K(P) + sup_f K(Δ_f) + K(n) + K(A) + c.
(b) If every Δ_f is deterministic, x_i = δ_f(h_{i−1}) with δ_f computable, then for every f, every sampler P (defective allowed) and every n, on every path, L_SFI(D_n) ≤ L_P + K(δ_f) + K(P) + c. No finiteness is needed.
(c) For all samplers P and Δ_f (defective allowed), with no finiteness assumptions: E_{x∣f}[L_SFI] ≤ E_{x∣f}[L_P] + H_f(x_{1:n}) + K(Δ_f) + K(P) + c. Here H_f(x_{1:n}) = E_{x∣f}[L_{Δ_f}] is the entropy of the reveal sequence given f.

*Proof.* (a) Thm 3.8(b) with Δ := Δ_f, which does not see f, applied to this f. Then average. (b) Cor. 3.3. (c) Take expectations in Thm 3.2. Given f the labels are determined, so the law of x_{1:n} given f is Δ_f(x‖y), and E_{x∣f}[−log Δ_f(x‖y)] = H_f(x_{1:n}). ∎

**Verdict on Thm 1.** In the reading Hänni's text supports, Thm 1 is **true** in each of the following cases:
* pathwise, with C_Δ = K(δ_f) and no other term, for deterministic reveal policies and all samplers (Cor. 3.9(b));
* in expectation, with C_Δ = K(Δ_f) and an extra K(n) + K(A), for random reveal laws, finite alphabets at each horizon, and samplers that halt almost surely (Cor. 3.9(a));
* in expectation, for all samplers and alphabets, if C_Δ is replaced by K(Δ_f) plus the reveal entropy (Cor. 3.9(c)).
Three things remain **[open]** (Q1, Q7):
* whether defective samplers P can be handled with K(P) alone;
* the case of infinite alphabets at a fixed horizon;
* whether K(n) + K(A) can be dropped.
The proof sketch is invalid (Prop. 3.1); the theorem needs a different proof (minimax). Thm 3.2, Cor. 3.3, Cor. 3.4 and Thm 3.5 need none of (H1), (H2) or computable values: they hold for all samplers, defective ones included, and all countable alphabets.

**Remarks.**
* *Why the K(n).* The minimax G depends on the horizon. The referee's r6 shows that horizon-specific minimax random functions are genuinely incompatible. In one small instance (the "random P" of r6, instance 0), the single-G value over horizons 1–4 is certified ≥ 0.026 bits, while every single-horizon value is ≤ 0.005 numerically and ≤ 0 by the theorem. So a horizon-free version needs a positive constant. r7 finds no growth of that constant up to horizon 6 in three instances: the upper brackets stay at 0.007, 0.013 and 0.022 bits. This is weak evidence that the K(n) is an artefact of the proof. It does not settle Q1.
* *Why compactness.* Finite A_n and Y make 𝒢 compact and the Lipschitz constant finite. The infinite case is **[open]**.
* *The slack* (referee m20). The ½U component costs at most 1 bit. It is used only to make Φ continuous and Lipschitz. Without it, c3 and r2 find V ≤ 0 (up to 1.8·10^{−15}) in every instance where Δ does not see f, so the constant 4 in Step 4 is an artefact of the proof.
* *Defective samplers.* For a LSC P that diverges with positive probability, E[L_P] is only upper semicomputable. Condition (★) is then co-c.e. and cannot be certified, and no argument is known that K(P) + K(Δ) still suffices. The lower approximations P_t of P give rational predictors, but E[L_{P_t}] approaches E[L_P] at a rate that is not computable. Naming a good stage t costs K(t). **[open]**

### 3.6 Hänni's mutual-information question in Reading C

Hänni asks whether "thm 1 [can] be improved to a version that talks about the algorithmic mutual information of Δ and f instead of the complexity of Δ". Thm 3.7 answers this negatively for Reading B. In Reading C the question is whether K(Δ_f) can be replaced by I(Δ_f : f). Thm 3.7 does not decide this: there K(Δ_f) and I(Δ_f : f) are both ≈ Σ ℓ_i. The Bayesian (Shannon) analogue holds.

**Proposition 3.10 (Shannon form) [proved; computed: c7].** Let (f, Θ) be jointly distributed, with Θ an arbitrary random element (the "reveal-law index"; the letter Θ avoids a clash with the complexity K). Given (f, Θ), draw a private memory R with R independent of f given Θ. Then draw the inputs by x_i ~ Δ_{Θ,R}(· ∣ h_{i−1}), a kernel that does not see f, and put y_i = f(x_i). Assume finite input and label sets up to time n.
(a) If I(f; Θ) < ∞, then
  I(f → x_{1:n}) = I(f; Θ) − I(f; Θ ∣ h_n) − Σ_{i≤n} I(y_i ; Θ ∣ h_{i−1}, x_i) ≤ I(f; Θ).
(If I(f; Θ) = ∞, the inequality is trivial.)
(b) If f has law π, a computable random function, then for every predictor P:
  E[L_SFI(D_n)] ≤ E[L_P] + I(f; Θ) + K(π) + c.
(c) If Θ = Δ_f is a function of f, as in Reading C, then I(f; Θ) = H(Δ_f), the entropy of the random reveal law. The bound is attained in the randomized chain (Thm 3.7): there I(f → x) = I(f; Δ_f) = H(Δ_f) = n(n+1)/2.

*Proof.* (a) *Step 1: x_i ⊥ f ∣ (Θ, h_{i−1}).* Conditionally on Θ = k, the joint law of (f, R, h_{i−1}) is
  p(df ∣ k) p(dR ∣ k) Π_{j<i} Δ_{k,R}(x_j ∣ h_{j−1}) 1[f(x_j) = y_j].
For fixed (k, h_{i−1}) this is a function of f times a function of R. So f ⊥ R ∣ (Θ, h_{i−1}). The law of x_i given (f, Θ, R, h_{i−1}) is Δ_{Θ,R}(· ∣ h_{i−1}), which does not involve f. Hence the law of x_i given (f, Θ, h_{i−1}) does not involve f.
*Step 2.* By the chain rule, I(f; Θ, h_n) = I(f; Θ) + Σ_i [I(f; x_i ∣ Θ, h_{i−1}) + I(f; y_i ∣ Θ, h_{i−1}, x_i)]. The first summand is 0 by Step 1. The second is H(y_i ∣ Θ, h_{i−1}, x_i), because y_i is a function of (f, x_i).
*Step 3.* Also I(f; Θ, h_n) = I(f; h_n) + I(f; Θ ∣ h_n), and, as in the proof of Thm 3.6, I(f; h_n) = I(f → x) + Σ_i H(y_i ∣ h_{i−1}, x_i).
*Step 4.* Equate the two expressions. Use H(y_i ∣ h_{i−1}, x_i) − H(y_i ∣ Θ, h_{i−1}, x_i) = I(y_i ; Θ ∣ h_{i−1}, x_i) ≥ 0. All terms are finite: I(f; h_n) ≤ H(h_n) < ∞, and I(f; Θ) < ∞ by assumption.
(b) The process is a special case of Thm 3.6: given f, the inputs have some joint law with f. Apply Thm 3.6(b) and (a).
(c) I(f; Θ) = H(Θ) − H(Θ ∣ f) = H(Θ) when Θ is a function of f. In Thm 3.7, Δ_f determines the chain, which is uniform on n(n+1)/2 bits. ∎

[computed: c7, 40 random instances with three reveal laws, private memory and f correlated with Θ: the identity in (a) holds to 2·10^{−14}; I(f;Θ) − I(f→x) ≥ 0.089; and (E[−log π(D_n)] − E[L_B]) − I(f;Θ) ≤ −0.18. On the randomized chain with n = 2, 3: I(f→x) = I(f;Θ) = H(Θ) = n(n+1)/2 and E[L_B] = 0.]

**Conjecture 3.11 (algorithmic form, Reading C) [conjecture; untested].** Under the hypotheses of Cor. 3.9(a), for every f:
  E_{x∣f}[L_SFI] ≤ E_{x∣f}[L_P] + I(Δ_f : f|_{A_n}) + K(P) + O(log K(Δ_f)) + K(n) + K(A) + c.
*What supports it.* Prop. 3.10 is its Bayesian analogue. It is consistent with the randomized chain (both sides ≈ n(n+1)/2) and with the GF example of §5.3. The intuition: when Δ_f is complex but carries no information about f, a history-aware P can exploit the inputs' order only through structure of f that P itself must encode. *What is missing.* A function machine can access neither f nor Δ_f. A proof would have to show that the part of Δ_f that is independent of f can be "averaged out" at logarithmic cost. We have neither a proof nor a counterexample.

### 3.7 No pathwise version of Reading A

**Proposition 3.12 [proved].** There is no bound of the form L_SFI(D_n) ≤ L_P + K(P) + K(Δ) + c that holds on every path for every fixed f and every reveal law Δ that does not see f.

*Proof.* Let ω be Martin-Löf random and let f be **the chain function of ω**: with b_i the i-th block of ω of length i, put f(b_{i+1}) := b_i, f(b_1) := ε, and f(x) := ε elsewhere. Let Δ draw independent uniform strings of lengths 1, 2, …; K(Δ) = O(1). Let P be the chain predictor of Thm 2.1(c); K(P) = O(1). The path x_i = b_i has positive probability Π_{i≤n} 2^{−i}. On it, P has loss 0, while L_SFI(D_n) ≥ n(n−1)/2 − 2 log n − c_ω by Thm 2.1(b). ∎

(`notes.md` said "take f fixed"; for a generic fixed f the chain paths need not exist, or x_{1:n−1} may be cheap given x_n. The proof needs f to be the chain function of a random ω, as above; referee m1.) Thm 3.2 is the pathwise statement. On this path it pays L_Δ = n(n+1)/2.

---

## 4. SFI^hist: oracle access to the previous inputs (H4)

### 4.1 Definitions

Let X_H be the set of nonempty finite lists (x_1,…,x_i) of inputs. It is a countable decidable set, so the foundations track's definitions apply with X replaced by X_H.

* A *history-oracle function machine* is a function machine T on the input set X_H (foundations Def 2.5). At time i it is queried at the list x_{1:i} and answers T^ω(x_{1:i}) ∈ Y, or diverges. It never sees labels, but it can recompute its own earlier labels from ω and the earlier inputs.
* Its law is the chronological function
  M^hist_T(y_{1:n} ‖ x_{1:n}) := λ{ω : T^ω(x_{1:i}) = y_i for all i ≤ n} = ν_T({(x_{1:i}, y_i) : i ≤ n})   (n ≥ 1),
  and M^hist_T(ε‖ε) := 1. The data set on the right has n distinct inputs (lists of different lengths), whatever the sequence, so it is always a data set over X_H.
* *SFI^hist* is SFI over X_H. Its law M_H := M^hist_{T_U^H} is the law of the universal function machine T_U^H for the input set X_H (foundations Thm 3.2, which holds for any countable decidable input set). Its loss is L_H := −log M_H(y‖x). (F1) for X_H reads: M_H(y‖x) ≥ 2^{−K(T)−c} M^hist_T(y‖x) for every history-oracle machine T and n ≥ 1.
* **Definition.** ξ := M_H, and L_ξ := L_H.

SFI^hist need not give a repeated input its earlier label. On a consistent sequence this costs nothing in the bounds below, because the copy predictor can enforce it.

**Lemma 4.1 [proved].** M^hist_T is a LSC chronological semimeasure, uniformly in an index of T.

*Proof.* For n ≥ 0 and any input x, the events {T^ω(x_{1:i}) = y_i for i ≤ n, T^ω(x_{1:n}x) = y} for different y are disjoint subsets of the event for (y_{1:n}, x_{1:n}); at the root the latter has measure 1. Each event is an effectively open set, enumerated from T, so its measure is LSC uniformly (foundations Prop 2.6). The label at time i depends only on x_{1:i}, so the value does not depend on later inputs. ∎

### 4.2 Representation theorem

**Theorem 4.2 [proved; construction computed: c4, r5].** For every LSC chronological semimeasure ρ there is a history-oracle function machine T_ρ with M^hist_{T_ρ}(y_{1:n} ‖ x_{1:n}) = ρ(y_{1:n} ‖ x_{1:n}) at every non-root node (n ≥ 1). At the root, M^hist_{T_ρ}(ε‖ε) = 1 ≥ ρ(ε‖ε). T_ρ is obtained uniformly from an index of a lower approximation of ρ, so K(T_ρ) ≤ K(ρ) + c.

*Proof (interval allocation, after Zvonkin–Levin; compare foundations Lemma 3.1).* Nodes are z = (x_{1:k}, y_{1:k}), with parent p(z) = (x_{1:k−1}, y_{1:k−1}). The *family* F(z) of a non-root node consists of the nodes with the same parent and the same last input x_k. Take a computable sequence ρ_t of finitely supported functions with dyadic values, nondecreasing in t, with ρ_t ↑ ρ pointwise. Take a computable enumeration z_1, z_2, … of the non-root nodes in which every node comes after its parent. Each node z carries a set S(z) ⊆ [0,1), a finite union of dyadic intervals (identified with cylinders of {0,1}^ℕ), initially empty, and S(root) := [0,1).

*Stage t.* Process z_1, …, z_t in this order. To process z, let free(z) := S(p(z)) ∖ ⋃_{z′∈F(z)} S(z′), with the current sets (z itself included in the union). If a := min(ρ_t(z) − λ(S(z)), λ(free(z))) is positive, add to S(z) a dyadic sub-union of free(z) of measure exactly a; this is possible because all quantities involved are dyadic.

*Invariants.* (I1) S(z) ⊆ S(p(z)). (I2) The members of a family are pairwise disjoint. (I3) λ(S_t(z)) ≤ ρ_t(z), where S_t(z) is the set after stage t. (I4) S_t(z) ⊆ S_{t+1}(z). (I1), (I2) and (I4) hold by construction. (I3) holds because the amount added never exceeds ρ_t(z) − λ(S(z)), and ρ_t is nondecreasing in t.

*Limit.* Put S(z) := ⋃_t S_t(z). We show λ(S(z)) = ρ(z) for every non-root z, by induction along the enumeration. Let p := p(z). By the induction hypothesis (or, for p = root, because λ(S(root)) = 1 ≥ ρ(ε‖ε)) and the chronological inequality, λ(S(p)) ≥ Σ_{z′∈F(z)} ρ(z′). Within a stage, S(p) changes only when p is processed, and p is processed before z. So when z is processed at stage t ≥ (index of z), S(p) = S_t(p), and the siblings z′ have measure ≤ ρ_t(z′) ≤ ρ(z′) at that moment, by (I3). If the amount added is ρ_t(z) − λ(S(z)), then λ(S(z)) = ρ_t(z) afterwards. Otherwise S(z) absorbs all of free(z). In both cases, since z is not changed again during stage t,
  λ(S_t(z)) ≥ min(ρ_t(z), λ(S_t(p)) − Σ_{z′∈F(z)∖{z}} ρ(z′)).
(Only "≥" holds: a sibling processed later in the same stage may still grow, so the right-hand side uses the bound ρ(z′), not the siblings' final measures; referee m4.) As t → ∞, ρ_t(z) → ρ(z) and λ(S_t(p)) → λ(S(p)) ≥ Σ_{z′∈F(z)} ρ(z′). So lim inf_t λ(S_t(z)) ≥ ρ(z), and (I3) gives equality.

*Machine.* T_ρ^ω(x_{1:k}) first recomputes y_i := T_ρ^ω(x_{1:i}) for i < k, and diverges if one of these diverges. It then searches for t and y with ω ∈ S_t((x_{1:k}, y_{1:k−1}y)); membership in a finite union of cylinders depends on a finite prefix of ω. It outputs the first y found. By (I2) at most one y can ever be found. By induction on n, using (I1) and (I2), {ω : T_ρ^ω(x_{1:i}) = y_i for all i ≤ n} = S((x_{1:n}, y_{1:n})), whose measure is ρ(y_{1:n} ‖ x_{1:n}) for n ≥ 1. (At the root the machine's law is 1 by definition, which can exceed ρ(ε‖ε); referee m5.) ∎

[computed: c4 runs the construction with exact rational arithmetic on a random dyadic chronological semimeasure (X = {0,1}, Y = {0,1,2}, depth 3, 6 stages, 237 stage–node pairs where a child's approximation ran ahead of its parent's). Every node ends with λ(S(z)) = ρ(z) exactly; there are no nesting, disjointness or growth violations; Monte Carlo runs of the machine match ρ to within 0.0056. c4 processes every node at every stage, not the prefix z_1, …, z_t of the proof's enumeration; for a finite instance this changes nothing essential (referee m19). The referee's r5 implements the literal construction and finds 0 mismatches.]

**Corollary 4.3 (H4) [proved; identification with Hutter's ξ known, unverified].**
(a) M_H ≥ 2^{−K(ρ)−c} ρ for every LSC chronological semimeasure ρ, on every sequence. M_H is itself one (Lemma 4.1). So M_H is a universal element of this class. Every other universal element, for example the foundations track's trimming mixture (foundations Prop 7.2(a)), agrees with M_H up to multiplicative constants.
(b) For every LSC history-aware predictor P, in particular every computable sampler that sees the history (defective ones included), and **every** sequence (adversarial, non-computable, consistent or not): L_H ≤ L_P + K(P) + c.
(c) L_H ≤ L_SFI(D_n) + c on every consistent sequence, in every order.

*Proof.* (a) Thm 4.2 and (F1) for X_H at non-root nodes; at the root M_H(ε‖ε) = 1 ≥ ρ(ε‖ε). Two universal elements dominate each other. (b) ρ_P(y‖x) := P(y‖x) is a LSC chronological semimeasure with K(ρ_P) ≤ K(P) + c. (c) Lemma 1.2 and (a). ∎

So Hänni's conjecture H4 holds in this precise sense: once the hypotheses see the list of previous inputs, SFI becomes the universal chronological semimeasure, and it competes with every computable history-aware predictor on every sequence.

### 4.3 Variants of the oracle

In this subsection the inputs are distinct, which is the case of interest for function learning and is needed for "the set determines the count".
* **SFI^pairs:** the hypothesis sees the previous inputs *and labels*, T^ω(h_{i−1}, x_i).
* **SFI^count:** it sees only the time i, T^ω(i, x_i).
* **SFI^set:** it sees the set {x_1,…,x_{i−1}}, T^ω({x_{<i}}, x_i).
Each is SFI over the corresponding input set, with universal law M_pairs, M_count, M_set and loss L_pairs, L_count, L_set.

**Proposition 4.4 [proved].**
(a) SFI^pairs and SFI^hist define the same laws. Given a pairs-machine T, put T′^ω(x_{1:i}) := T^ω(x_1, T′^ω(x_1), …, x_{i−1}, T′^ω(x_{<i}), x_i). On the event that T′ outputs y_{1:n}, the recursion reproduces the true history, so T outputs y_{1:n}; the converse holds by induction on i. So M^hist_{T′} = M^pairs_T, with K(T′) ≤ K(T) + c. Conversely, a hist-machine is a pairs-machine that ignores labels. Hence M_pairs and M_H agree up to multiplicative constants.
(b) SFI^count is SFI on time-stamped inputs (i, x_i), the foundations track's stamped SFI (foundations Thm 6.7(b), Prop 6.9(d)). It dominates Solomonoff's M on the label sequence alone: L_count ≤ −log M(ȳ_1…ȳ_n) + c. (The hypothesis outputs the i-th ȳ-block of the universal monotone machine's output.)
(c) SFI ≼ SFI^count ≼ SFI^set ≼ SFI^hist, where ν ≼ ν′ means ν ≤ 2^c ν′ on every sequence with distinct inputs. Each oracle is computable from the next: a hypothesis may ignore the count; the count is the size of the set plus one; the set is computed from the list.

**Proposition 4.5 (the hierarchy is strict) [proved; lemma in (iii) computed: c6, r4].**
(i) *SFI vs SFI^count.* For every set S of n ≥ 2 strings there is an order such that, with labels y_i = [i even], L_SFI ≥ n − log(n+1) − c while L_count ≤ c.
(ii) *SFI^count vs SFI^set.* On the chain of Thm 2.1(b), L_count ≥ L_{n−1} − K(ℓ_n) − c_ω while L_set ≤ c.
(iii) *SFI^set vs SFI^hist.* For every set S of n ≥ 2 strings there is an order such that, with labels y_1 = ε and y_i = x_{i−1}, L_set ≥ log n! − log n − c while L_H ≤ c.
All lower bounds are in the semimeasure convention.

*Proof.* (i) L_SFI depends only on the set D (§1.2). Let A := {x_i : i even}, a subset of S with ⌊n/2⌋ elements. D is computable from (S, A) and conversely. By Lemma 1.1, L_SFI ≥ K(A ∣ S) − c. Fewer than half of the C(n, ⌊n/2⌋) subsets have K(A ∣ S) < log C(n, ⌊n/2⌋) − 1, so some A has K(A∣S) ≥ log C(n, ⌊n/2⌋) − 1 ≥ n − log(n+1) − 1. Place A at the even positions. The deterministic count-hypothesis g(i, x) := [i even] gives L_count ≤ c.
(ii) Lemma 2.0 with time stamps: put ν(z ∣ x, n) := λ{ω : U^ω(n, x) = z_1, U^ω(n−1, z_1) = z_2, …, U^ω(2, z_{n−2}) = z_{n−1}, U^ω(1, z_{n−1}) = ε} for sequences z of length n − 1, with U the universal count-machine. For fixed ω and (x, n) the sequence z is determined by iteration, so Σ_z ν(z ∣ x, n) ≤ 1, and ν is LSC uniformly in (x, n). Hence L_count ≥ K(x_{1:n−1} ∣ x_n, n) − c. Since ℓ is computable and strictly increasing, n is computable from |x_n|, so K(x_{1:n−1} ∣ x_n, n) ≥ K(x_{1:n−1} ∣ x_n) − c (referee m18: `notes.md` subtracted a superfluous K(n)). The proof of Thm 2.1(b) finishes. For SFI^set, the hypothesis "output the longest element of the set, or ε if it is empty" is correct because lengths increase.
(iii) Fix S and a tape ω of the universal set-machine U. An order σ is consistent with ω iff U^ω(∅, x_1) = ε and U^ω({x_{<i}}, x_i) = x_{i−1} for i ≥ 2. *Backward reconstruction:* x_n determines x_{n−1} = U^ω(S ∖ {x_n}, x_n), which determines x_{n−2} = U^ω(S ∖ {x_n, x_{n−1}}, x_{n−1}), and so on. So at most n orders are consistent with one ω, and ν_S(σ) := M_set(labels of σ ‖ σ) satisfies Σ_σ ν_S(σ) ≤ n. ν_S/n is a discrete semimeasure, LSC uniformly in S, so (F4) gives L_set ≥ K(σ ∣ S) − log n − c. Choose σ with K(σ ∣ S) ≥ log n! − 1. The predictor "y_1 = ε, y_i = x_{i−1}" gives L_H ≤ c. ∎

[computed: c6 finds, by exhaustive maximum-clique search over the compatibility graph of orders, that at most n orders can be consistent with one set-hypothesis for n = 2,…,5, and that n is attained. r4 confirms n = 6, 7.]

The constructions in (i) and (iii) are families of finite sequences indexed by n (referee m17). Single infinite sequences also exist.

**Proposition 4.5′ (single infinite sequences) [proved].** Let ω be Martin-Löf random. Let u_j, v_j be the strings with indices 2j−1 and 2j in the length-lexicographic enumeration of {0,1}*. Block j reveals {u_j, v_j}, in the order (u_j, v_j) if ω_j = 0 and (v_j, u_j) otherwise. Write σ_k for the resulting order of S_k := {u_1, v_1, …, u_k, v_k}.
(i) With labels y_i = [i even]: L_SFI(D_{2k}) ≥ k − K(k) − c_ω for every k, while L_count ≤ c at every time.
(ii) The chain of Thm 2.1(b) is a single infinite sequence, and Prop. 4.5(ii) applies along it.
(iii) With labels y_1 = ε, y_i = x_{i−1}: L_set(2k) ≥ k − K(k) − c_ω for every k, while L_H ≤ c at every time.
Since the universal laws are nonincreasing along a sequence, each gap is unbounded along the single sequence, and grows linearly in n.

*Proof.* (i) dom D_{2k} = S_k is computable from k and conversely. The labelling determines ω_{1:k}: ω_j = 0 iff u_j has label 0. So by Lemma 1.1, L_SFI(D_{2k}) ≥ K(ω_{1:k} ∣ k) − c ≥ K(ω_{1:k}) − K(k) − c′ ≥ k − K(k) − c_ω, using (F5). The count-hypothesis [i even] has loss 0. (iii) For a fixed tape of the universal set-machine, backward reconstruction (proof of Prop. 4.5(iii)) shows that the order of S_k is determined by its last element, which is u_k or v_k. So at most two of the 2^k block orders σ_b (b ∈ {0,1}^k) are consistent with one tape, and Σ_b M_set(σ_b) ≤ 2. (F4), applied to the discrete semimeasure b ↦ M_set(σ_b)/2, LSC uniformly in k, gives L_set(σ_b) ≥ K(b ∣ k) − 1 − c. Take b = ω_{1:k} and use (F5). The predictor "y_1 = ε, y_i = x_{i−1}" gives L_H ≤ c. ∎

### 4.4 "As good as SI": comparison with Solomonoff's M on x_1y_1x_2y_2…

Let M be as in (F8), applied to code(x_1y_1…) := x̄_1ȳ_1x̄_2ȳ_2… for a fixed prefix-free code s ↦ s̄ with nonempty codewords. (Everything in this subsection holds for any such code. For X = Y = {0,1} one may take the identity code on single bits, so that code(x_1y_1…) is the raw interleaved bit sequence.) Write

* L_M^joint := −log M(code(x_1y_1…x_ny_n));
* L_M^x := −Σ_i log [M(code(h_{i−1})x̄_i) / M(code(h_{i−1}))] (M's loss on the inputs);
* L_M^y := −Σ_i log [M(code(h_{i−1})x̄_iȳ_i) / M(code(h_{i−1})x̄_i)] (SI's conditional label loss, unnormalised).

So L_M^joint = L_M^x + L_M^y, and both parts are ≥ 0 because M is monotone. Let ξ′ be the universal chronological semimeasure for *inputs given previous labels*: the law of the universal function machine on the input set Y* of label lists (the empty list included), whose answer at the list y_{1:i−1} is the input x_i. By Thm 4.2 with the roles exchanged (same proof), ξ′ dominates every LSC chronological semimeasure ρ′(x_{1:n} ‖ y_{1:n−1}) for inputs given labels. Put L_ξ′^x := −log ξ′(x_{1:n} ‖ y_{1:n−1}).

**Lemma B (block codes) [proved].** Let ν be a LSC semimeasure on alternating block sequences b = (x_1, y_1, x_2, …), which may end after an x-block: ν(∅) ≤ 1 and Σ_β ν(bβ) ≤ ν(b), where β ranges over X or Y according to the parity of the length of b. For z ∈ {0,1}* let B(z) be the set of block sequences b with code(b) ⊒ z such that b = ∅ or code(b⁻) ⋣ z, where b⁻ is b without its last block. Then ν_bin(z) := Σ_{b∈B(z)} ν(b) is a LSC semimeasure on {0,1}*, ν_bin(code(b)) = ν(b) for every b, and hence M(code(b)) ≥ 2^{−K(ν)−c} ν(b).

*Proof.* *B(code(b)) = {b}.* Codes are prefix-free and nonempty, so code(b′) ⊒ code(b) forces b′ to extend b blockwise. If b′ ≠ b, then b′⁻ extends b, so code(b′⁻) ⊒ code(b) and b′ ∉ B(code(b)). *Semimeasure.* B(ε) = {∅}, so ν_bin(ε) = ν(∅) ≤ 1. Let b ∈ B(z0) ∪ B(z1); the two sets are disjoint. Either code(b⁻) ⋣ z, and then b ∈ B(z) with code(b) ≠ z; or code(b⁻) ⊒ z. In the second case code(b⁻) and za are both prefixes of code(b), and code(b⁻) ⋣ za, so code(b⁻) = z, and b is a one-block extension of the element b′ := b⁻ of B(z) with code(b′) = z. Conversely each b ∈ B(z) with code(b) ≠ z lies in exactly one B(za). Hence ν_bin(z0) + ν_bin(z1) ≤ Σ_{b∈B(z), code(b)≠z} ν(b) + Σ_{b′∈B(z), code(b′)=z} Σ_β ν(b′β) ≤ ν_bin(z). Lower semicomputability is clear. Apply (F8). ∎

**Theorem 4.6 [proved].** On every sequence:
(a) L_ξ ≤ L_M^joint + c and L_ξ′^x ≤ L_M^joint + c;
(b) L_M^joint ≤ L_ξ + L_ξ′^x + c;
(c) L_ξ − L_M^y ≤ L_M^x + c and L_M^y − L_ξ ≤ L_ξ′^x − L_M^x + c;
(d) if x_i = δ(h_{i−1}) for a partial computable δ, then L_M^joint ≤ L_ξ + K(δ) + c; in particular L_M^y ≤ L_ξ + K(δ) + c and L_M^x ≤ L_ξ + K(δ) + c.

*Proof.* (a) ρ(y_{1:n} ‖ x_{1:n}) := M(code(x_1y_1…x_ny_n)) is a LSC chronological semimeasure: ρ(ε‖ε) = M(ε) ≤ 1, and with z := code(h_n), Σ_y M(z x̄ ȳ) ≤ M(z x̄) ≤ M(z), because {ȳ} is prefix-free and M is a monotone semimeasure. Apply Cor. 4.3(a). Likewise ρ′(x_{1:n} ‖ y_{1:n−1}) := M(code(h_{n−1}) x̄_n) is a LSC chronological semimeasure for inputs given labels, and ρ′ ≥ M(code(h_n)). (b) ν(h_n) := ξ′(x_{1:n} ‖ y_{1:n−1}) ξ(y_{1:n} ‖ x_{1:n}) and ν(h_{n−1}x_n) := ξ′(x_{1:n} ‖ y_{1:n−1}) ξ(y_{1:n−1} ‖ x_{1:n−1}) define a LSC semimeasure on block sequences: summing over y_n uses ξ's chronological inequality, and summing over x_n uses ξ′'s. Apply Lemma B. (c) Combine (a), (b) and L_M^joint = L_M^x + L_M^y. (d) This is Prop. 4.7 below; L_M^x, L_M^y ≥ 0. ∎

**Proposition 4.7 (input-loss identity for deterministic policies) [proved; toy computed: s3].** Let δ be a partial computable map from histories to inputs, and call a sequence δ-consistent if x_i = δ(h_{i−1}) for all i. On every δ-consistent sequence,
  L_M^joint ≤ L_ξ + K(δ) + c,  and hence  L_M^x − K(δ) − c ≤ L_ξ − L_M^y ≤ L_M^x + c.
So for computable deterministic input policies, "L_ξ ≤ L_M^y + O(1) on all δ-consistent sequences" is equivalent to "M predicts the δ-determined inputs with bounded loss on all of them", up to K(δ).

*Proof.* Put ν(h_n) := 1[x_i = δ(h_{i−1}) for all i ≤ n] · ξ(y_{1:n} ‖ x_{1:n}) and ν(h_{n−1}x_n) := 1[x_i = δ(h_{i−1}) for all i ≤ n] · ξ(y_{1:n−1} ‖ x_{1:n−1}). The indicator is c.e. uniformly, so ν is LSC with K(ν) ≤ K(δ) + c. It is a semimeasure on block sequences: summing over the next input leaves only x_n = δ(h_{n−1}), whose term equals ν(h_{n−1}); summing over the next label uses ξ's chronological inequality; and ν(∅) = 1·ξ(ε‖ε) ≤ 1. Lemma B gives M(code(h_n)) ≥ 2^{−K(δ)−c} ξ(y‖x) on δ-consistent sequences, which is the first inequality. With L_M^joint = L_M^x + L_M^y it gives L_ξ − L_M^y ≥ L_M^x − K(δ) − c. Thm 4.6(a) gives L_ξ − L_M^y ≤ L_M^joint + c − L_M^y = L_M^x + c. ∎

[computed: s3 (referee), an exact two-component toy mixture that satisfies both domination facts used above (M ≥ ½·1[δ]·ξ_toy and M(h) ≤ ξ_toy(y‖x)). In it L_M^x = L_ξ − L_M^y = n log(4/3), 16.601 bits at n = 40, and L_M^x + L_M^y = L_ξ. So nothing structural keeps L_M^x bounded. The toy is not universal; whether the universal M behaves like this is the question below.]

*By-product (Q5 for deterministic policies).* On δ-consistent sequences, L_ξ′^x ≤ K(δ) + c (the deterministic input predictor), so Thm 4.6(a),(b) give L_ξ + L_ξ′^x − K(δ) − c ≤ L_M^joint ≤ L_ξ + L_ξ′^x + c.

**What is known: Lattimore–Hutter–Gavane.** [known: T. Lattimore, M. Hutter, V. Gavane, "Universal Prediction of Selected Bits", ALT 2011, *Lecture Notes in Artificial Intelligence* 6925, pp. 262–276, doi:10.1007/978-3-642-24412-4_22, arXiv:1107.5531. Bibliographic data and abstract wording confirmed by search snippets; theorem statements and the construction of the counterexample **unverified**.] The abstract says that online classification can be cast as sequence prediction of input/target pairs; that the normalised Solomonoff measure "can detect any recursive sub-pattern (regularity) within an otherwise completely unstructured sequence"; and that "the unnormalised version can fail to predict very simple recursive sub-patterns". Their motivating pattern is a sequence in which every even bit repeats the preceding odd bit. Snippets attribute the failure to the defect of M (M(z0) + M(z1) < M(z)) and describe it as non-convergence to 1 on the selected bits.

*Non-convergence already means unbounded loss* (referee M4, m6). If the conditional probability of the selected bits does not converge to 1, it is at most 1 − ε at infinitely many selected positions, for some ε > 0, and each of these positions costs at least log(1/(1−ε)) bits. So the hedge of `notes.md` ("if LHG's failure means unbounded loss") was misplaced. The unverified steps are the exact form of their theorem and the position of the selected bits. Take X = Y = {0,1} and the identity block code, so that code(x_1y_1x_2y_2…) is the raw interleaved sequence. Consider:
* **(LHG-even)** there is ω ∈ {0,1}^ℕ such that unnormalised M, on ω_1ω_1ω_2ω_2…, has unbounded cumulative loss on the copied bits (positions 2, 4, 6, …);
* **(LHG-odd)** there is ω such that unnormalised M, on 0ω_1ω_1ω_2ω_2…, has unbounded cumulative loss on the copied bits (positions 3, 5, 7, …).
LHG's abstract supports (LHG-even). (LHG-odd) is the same pattern shifted by one fixed leading bit; we have not checked that their construction covers it. For a code with framing bits, such as s̄ = 1^{|s|}0s, both would additionally need the transfer to framed blocks.

**Consequences for Q3 [proved, conditional on the hypotheses named].**
* Under (LHG-even): **L_M^y ≤ L_ξ + O(1) fails.** Take inputs x_i := ω_i and labels y_i := x_i. Then L_ξ ≤ c on every input sequence (the copy predictor), while L_M^y is M's loss on the copied bits, which is unbounded.
* Under (LHG-odd): **L_ξ ≤ L_M^y + O(1) fails.** Take δ(∅) := 0 and δ(h) := the last label of h, so x_1 = 0 and x_{i+1} = y_i, and labels y_i := ω_i. The joint sequence is 0ω_1ω_1ω_2ω_2…, and the inputs x_2, x_3, … are the copied bits. So L_M^x is unbounded, and Prop. 4.7 gives L_ξ − L_M^y ≥ L_M^x − K(δ) − c → ∞, with K(δ) = O(1).
In the second case SI's unnormalised conditional label probabilities beat ξ's by an unbounded factor. This does not contradict the universality of ξ: the conditionals M(z x̄ ȳ)/M(z x̄) are ratios of LSC quantities and need not be LSC.
* For the normalised Solomonoff measure both directions are **[open]**. LHG's positive result for the normalised measure is (per the abstract) a convergence statement, not a bound on cumulative loss.

**Verdict on H4.** In the precise sense of Cor. 4.3, SFI^hist is the universal chronological semimeasure. It is as good as every computable history-aware predictor on every sequence, and its label loss is at most Solomonoff's *joint* loss on x_1y_1x_2y_2… plus a constant (Thm 4.6(a)). Its relation to SI's *conditional* label predictions is governed by M's loss on the inputs (Thm 4.6(c)); for computable deterministic input policies the difference L_ξ − L_M^y equals L_M^x up to K(δ) + O(1) (Prop. 4.7). For unnormalised M, and conditional on the LHG phenomenon in the forms (LHG-even) and (LHG-odd), neither L_M^y ≤ L_ξ + O(1) nor L_ξ ≤ L_M^y + O(1) holds on all sequences. So "as good as SI" is true against SI's joint loss, and false in general against SI's unnormalised conditional label loss, in both directions (conditionally). The normalised-M versions are open (Q3).

### 4.5 The cyclic permutation, operator induction and deterministic programs

**Proposition 4.8 (H5 for SFI^hist) [proved].** In the brief's cyclic-permutation example (examples §2.1: f a cyclic permutation of {0,1}^n, x_1 = f^{−1}(0^n), x_{k+1} = f^{−1}(x_k), y_1 = 0^n, y_k = x_{k−1}), L_H ≤ c for every n, every cyclic f and every number of steps up to the whole cycle.

*Proof.* The predictor "at time 1 output 0^{|x_1|}; at time i ≥ 2 output x_{i−1}" is deterministic, computable, of complexity O(1), and has loss 0 on every instance. Apply Cor. 4.3(b). ∎

For comparison: SFI pays about log((2^n−1)!) ≈ (n − log e)2^n bits over the cycle in the semimeasure convention (examples Thm 2.1), and SI's label loss on the interleaved sequence is at most K(n) + m + c with probability ≥ 1 − 2^{−m} (examples Prop 2.6).

**Proposition 4.9 (operator induction) [proved, given the unverified description].** [known: R. J. Solomonoff, "Three kinds of probabilistic induction: universal distributions and convergence theorems", *The Computer Journal* 51(5):566–570, 2008, doi:10.1093/comjnl/bxm120. Title, venue, DOI and abstract confirmed by search snippets. The abstract describes the third kind as extrapolating "an unordered set of ordered pairs of elements … given the first element of a new pair, to get a probability distribution on possible second elements of the pair". The formula Σ_j a_j Π_i O^j(A_i ∣ Q_i) is from secondary sources (as cited by the foundations track); the paper's content is **unverified**.] Read this way, operator induction is the per-query mixture M_pq(y_{1:n} ‖ x_{1:n}) := Σ_i **m**(i) Π_t P_i(y_t ∣ x_t) of the foundations track (Def 4.1). Then:
(a) M_pq is a LSC chronological semimeasure that ignores the history (foundations Prop 6.9(a)). So M_H ≥ 2^{−c} M_pq and L_H ≤ L_pq + c on every sequence (Cor. 4.3(a)).
(b) On sequences with distinct inputs, M_pq = M_prod(D_n) ≤ 2^c M_F(D_n) (foundations Prop 6.9(a), Thm 4.2). M_prod is a weak function semimeasure, so Prop. 2.3 applies to it directly: on the chain and the skipped strings, operator induction pays the lower bounds of Thms 2.1(b) and 2.2(d) (semimeasure convention).

*Proof.* Cited facts, Cor. 4.3(a) and Prop. 2.3(b). ∎

So operator induction, the historical precursor of SFI, is a mixture of x-only operators with private randomness. It cannot use the history and pays the §2 separations. It is dominated by SFI^hist and, on distinct inputs, by SFI.

**Proposition 4.10 (deterministic programs for SFI^hist) [proved; toy computed: s2, c10].** Let φ_e be the e-th partial computable function on X_H, and put
  W_hist(y_{1:n} ‖ x_{1:n}) := Σ_{p∈dom V} 2^{−|p|} 1[φ_{V(p)}(x_{1:i}) = y_i for all i ≤ n].
W_hist is a LSC chronological semimeasure (deterministic programs consistent with different next labels are different). Let {0,1} ⊆ Y. For every n, every input list x_{1:n} and every y ∈ {0,1}^n,
  W_hist(y‖x) ≥ 2^{−n−c} Σ_{N≥n} 2^{−K(N)} = 2^{−n−τ(n)−c}.
So against fair-coin labels the program mixture pays at most τ(n) + c extra bits. Moreover:
(a) τ(n) ≤ κ(n) ≤ K(n), and τ(n) ≤ K(⌈log n⌉) + c;
(b) τ(n) ≤ g(n) + K(g) + c for every computable nondecreasing unbounded g : ℕ → ℕ;
(c) τ(n) → ∞.
So the extra cost grows more slowly than every computable unbounded function, while K(n) ≥ log n for most n.
(d) *The single shortest program pays more.* Put K_hist(y‖x) := min{|p| : p ∈ dom V, φ_{V(p)}(x_{1:i}) = y_i for all i ≤ n}. Then n − c ≤ max_{y∈{0,1}^n} K_hist(y‖x) ≤ n + K(n) + c for every input list, and for every fixed infinite input sequence x_1, x_2, …, the excess e(n) := max_{y∈{0,1}^n} K_hist(y‖x_{1:n}) − n satisfies Σ_n 2^{−e*(n)} ≤ 2, where e*(n) := max_{m≤n} e(m). Hence e(n) > log n + log log n for infinitely many n.

*Proof.* For N ≥ 1 and w ∈ {0,1}^N let φ_{N,w}(x_{1:i}) := w_i for i ≤ N, undefined for longer lists. Let V′ be the prefix machine that reads a V-program for N, then N more bits w, and outputs an index of φ_{N,w}. By universality V(rs) = V′(s) for a fixed string r. Using a shortest program q_N for N, the strings r q_N w are distinct elements of dom V (dom V is prefix-free, so q_N ≠ q_{N′} are incomparable for N ≠ N′), of length |r| + K(N) + N. For N ≥ n, φ_{N,w} is consistent with (x, y) iff w_{1:n} = y, which holds for 2^{N−n} strings w. So W_hist(y‖x) ≥ Σ_{N≥n} 2^{N−n} 2^{−|r|−K(N)−N} = 2^{−n−|r|} Σ_{N≥n} 2^{−K(N)}. (a) One term of the sum, and N = 2^{⌈log n⌉}. (b) q(N) := 2^{−g(N)} − 2^{−g(N+1)} ≥ 0 is a computable discrete measure with Σ_{N≥n} q(N) = 2^{−g(n)}, because g is nondecreasing and unbounded. The coding theorem (F4) gives 2^{−K(N)} ≥ 2^{−K(g)−c} q(N). Sum over N ≥ n. (c) Σ_N 2^{−K(N)} ≤ 1 converges, so its tails tend to 0.
(d) Upper bound: the single program r q_n y. Lower bound n − c: given x_{1:n}, a consistent program determines y, so K_hist(y‖x) ≥ K(y ∣ x_{1:n}) − c, and some y has K(y ∣ x_{1:n}) ≥ n. For the growth statement fix the input sequence, and let C(L) be the number of programs p ∈ dom V with |p| ≤ L. Distinct labellings y ∈ {0,1}^n need distinct consistent programs (a program determines the labels it gives), and each has a consistent program of length ≤ n + e(n) ≤ n + e*(n). So C(n + e*(n)) ≥ 2^n. By Kraft and summation by parts, with k_L the number of programs of length exactly L, Σ_{L≤M} C(L) 2^{−L−1} ≤ Σ_{L≤M} k_L 2^{−L} ≤ 1 for every M. The numbers L_n := n + e*(n) are strictly increasing in n, because e* is nondecreasing. So Σ_n 2^n 2^{−n−e*(n)−1} ≤ Σ_n C(L_n) 2^{−L_n−1} ≤ 1. If e(n) ≤ log n + log log n held for all n ≥ n_0, then e*(n) ≤ log n + log log n + O(1) for all n, and Σ_n 2^{−e*(n)} ≥ 2^{−O(1)} Σ_{n≥2} 1/(n log n) = ∞; contradiction. So e(n) > log n + log log n for infinitely many n. ∎

[computed: s2 (referee), a toy prefix-free program language ⟨N⟩_δ w with Elias-δ codes (for which K(N) ≤ len_δ(N) + c): for n ≤ 6, brute force gives W(y)·2^n = Σ_{N≥n} 2^{−len_δ(N)} exactly for every label string; the extra cost stays ≤ log(log n + 1) + 2 up to n = 2^200 (7.48 bits there, against len_δ(n) = 215).]

This corrects `notes.md` §7, which claimed an extra ≈ K(n) with the sketch "a prefix-free program that outputs n random labels must encode n". The premise is false: a consistent program need not stop after n labels. It is the SFI^hist analogue of the foundations track's tape-length bound (foundations Prop 4.4(b,c)), where the program mixture W pays only for a padded tape length. The *single shortest program* behaves differently (part (d)): along every fixed input sequence its worst-case excess over n exceeds log n + log log n infinitely often, while it is always at most K(n) + c ≤ log n + 2 log log n + c. So for SFI^hist the Kolmogorov version and the mixture version differ unboundedly, by roughly log n bits at some lengths. This parallels the foundations track's Thm 4.7 (no coding theorem for function programs), where the single shortest program loses about log n bits against W on two-point data sets. (`notes.md` §7's "≈ K(n)" is thus roughly right for the single program, though only for infinitely many n and for the worst labels, and wrong for the mixture.)

### 4.6 Literature for H4 (referee M6)

The brief asks to check what is known (Hutter's 2005 book; universal prediction with side information or actions). arxiv.org, hutter1.net and the publishers' sites do not resolve from here; the following rests on search snippets.

1. **Hutter's universal chronological semimeasure.** [known: M. Hutter, "A theory of universal artificial intelligence based on algorithmic complexity", arXiv cs.AI/0004001, 2000; M. Hutter, *Universal Artificial Intelligence*, Springer 2005, ch. 5 (chapter number unverified).] A snippet of cs/0004001 confirms the chronological setting and that the class of enumerable chronological semimeasures is enumerable. From memory, and **unverified**: Hutter defines the universal prior both through chronological programs and as a mixture over enumerable chronological semimeasures, and states that they agree up to constants. Thm 4.2 is the analogue, for history-oracle function machines with one shared random tape, of that agreement; whether it is in the literature in this form is **unverified**, and we make no novelty claim for it. Hutter's setting has finite alphabets (from memory, unverified); here X and Y are countable. This is why ξ is *defined* here as M_H, and the identification with Hutter's ξ is not used.
2. **Hutter's "Supervised Learning from Examples (EX)".** [known: M. Hutter, "Universal Algorithmic Intelligence: A mathematical top→down approach", in *Artificial General Intelligence* (B. Goertzel, C. Pennachin, eds.), Springer 2007, pp. 227–290; arXiv cs/0701125 (IDSIA-01-03). A table-of-contents snippet lists a section "Supervised Learning from Examples (EX)" (§5.4 by one snippet); the abstract lists "sequence prediction, strategic games, function minimization, reinforcement and supervised learning" among the problem classes the AIXI model can formally solve. The content of the section is **unverified**; I believe, unverified, that the same section is in cs/0004001 and in the 2005 book, ch. 6.] This is the closest prior use of the universal chronological mixture for learning a function or relation from presented examples. So the observation behind Cor. 4.3, that a history-aware universal mixture is the natural ideal learner from examples and dominates all computable history-aware predictors, is prior work in substance. What these notes add, as far as we know (unverified), is: the function-machine form of the universal chronological semimeasure (Thm 4.2), its precise relation to SFI (Lemma 1.2, the separations of §2 and §4.3, and §5), and the comparisons with SI on the interleaved sequence (Thm 4.6, Prop. 4.7).
3. **Wood–Sunehag–Hutter.** [known: I. Wood, P. Sunehag, M. Hutter, "(Non-)Equivalence of Universal Priors", arXiv 1111.3854; Solomonoff 85th Memorial Conference, Springer LNAI/LNCS, doi:10.1007/978-3-642-44958-1_33 (volume number not confirmed). Snippets confirm the abstract: "the constructions of Solomonoff and Levin define an identical class of priors", while the class of universally dominant priors is strictly larger.] This is the sequence-case analogue of Thm 4.2: machine-generated priors and LSC semimeasures coincide as classes. Thm 4.2 proves the corresponding exact statement for chronological semimeasures and history-oracle function machines. Context only; not used in proofs.
4. **Lattimore–Hutter–Gavane**, ALT 2011 (§4.4): the venue is *Lecture Notes in Artificial Intelligence* 6925 (a subseries of LNCS), pp. 262–276, doi:10.1007/978-3-642-24412-4_22, confirmed by snippets.
5. **Solomonoff's operator induction** (2008): Prop. 4.9.
6. *Not found:* a published statement of Hänni's conjecture H4 for function machines, or of the separations between SFI and SFI^hist. The search was limited to snippets, so this is weak evidence of absence.

---

## 5. What SFI can and cannot exploit

### 5.1 Order

**Proposition 5.1 [proved].** L_SFI depends only on the set D_n (§1.2; foundations Prop 5.2). So SFI, in the semimeasure convention, cannot use the order in which the data arrive.

*Remark (informal; not a theorem; referee m11).* Each hypothesis of SFI answers each query without seeing the other inputs; the queries are coupled only through the shared tape. Shared randomness does let SFI correlate a label with a *guess* about the other inputs. The brooms of Prop. 2.4 do this, and so does the optimal random function for the GF example of §5.3, which mixes 42 maximal "masks" at m = 3 (r3). What SFI cannot do is let a label depend on the inputs actually present. Thm 5.4 quantifies the cost in one example, and Thm 5.2 bounds it in general.

### 5.2 Sandwich bounds for individual data sets

**Theorem 5.2 (sandwich) [proved].** Let D be a data set with distinct inputs, and write D_σ for D in order σ. Let KH(x_{1:n}) := min{|p| : U(p, x_i) = ⟨x_1,…,x_{i−1}⟩ for all i ≤ n}, where U is a fixed universal prefix machine with input: the complexity of recovering each input's list of predecessors from the input. Then

  max_σ L_ξ(D_σ) − c ≤ L_SFI(D) ≤ min_τ [L_ξ(D_τ) + KH(x_τ)] + c.

*Proof.* The left inequality is Lemma 1.2. For the right one, fix τ and a program p attaining KH(x_τ). Let T be the following function machine, which does not depend on p. On query x it reads the tape as a program for U(·, x), running U(·, x) on the tape bits one at a time until it halts; it obtains a list ⟨x′_1,…,x′_k⟩ = U(q, x), where q is the part of the tape read. It then runs the universal history-oracle machine U_H on the rest of the tape, at the list (x′_1,…,x′_k, x), and outputs its answer. On tapes ω = pω′ and for every x ∈ dom D, U(·, x) halts after reading exactly p, because p ∈ dom U(·, x) and that domain is prefix-free. So every query in dom D sees the same remaining tape ω′, and at x_{τ,i} the machine outputs U_H^{ω′}(x_{τ,1:i}). Hence ν_T(D) ≥ 2^{−|p|} M_H(y_τ ‖ x_τ), and (F1) with K(T) = O(1) gives L_SFI(D) ≤ KH(x_τ) + L_ξ(D_τ) + c. (`notes.md` appealed to (F1) for the |p| cost, which only gives K(p) + c; referee m3.) ∎

**Corollary 5.3 (initial segments) [proved].** If dom D = {e_1,…,e_N} for a computable injective sequence e, then |L_SFI(D) − L_ξ(D in e-order)| ≤ K(e) + c, and L_ξ(D_σ) ≤ L_ξ(D in e-order) + K(e) + c for every σ. So the e-order is the worst order for ξ, up to K(e) + c.

*Proof.* KH(e-order) ≤ K(e) + c: given x, enumerate e until x appears and list its predecessors. Combine with Thm 5.2 and Lemma 1.2. ∎

This covers the skipped-string example (dom D^{(ℓ)} is an initial segment of the length-lexicographic order, K(e) = O(1)) and the brief's cyclic permutation (all strings of length n in lexicographic order, K(e) ≤ K(n) + c). In both, SFI's loss equals ξ's loss in the canonical order, up to c and K(n) + c respectively.

**Gap bounds.** For an order σ put gap(σ) := L_SFI(D) − L_ξ(D_σ). Then [proved]:
* gap(σ) ≥ max_τ L_ξ(D_τ) − L_ξ(D_σ) − c: at least the advantage of σ over the worst order (Lemma 1.2);
* gap(σ) ≤ KH(x_σ) + c ≤ K(x_{1:n−1}) + c′ (Thm 5.2);
* gap(σ) ≤ L_ξ′^x(x_σ ‖ y_σ) + c: at most the chronological complexity of the input sequence given the labels (Cor. 3.4(a) and Thm 4.6(b));
* gap(σ) ≤ I(x_σ : D) + c (Prop. 5.7(a)).

### 5.3 The upper term is needed: a GF(2^m) example

Identify {0,1}^m with F = GF(2^m), using the polynomial basis modulo the lexicographically least irreducible polynomial of degree m, which is computable from m. For a ≠ b ∈ F and r ∈ F let D_{abr} := {(a, r), (b, r + ab)}.

**Lemma 5.5 (character-sum bound) [proved; computed: c5, s4].** For every partial G : F → F,
  N(G) := #{(a,b) : a ≠ b, G(a), G(b) defined, G(a) + G(b) = ab} < 2^m + 2^{3m/2}.

*Proof.* Extend G to a total function and include the pairs a = b; neither decreases the count. Let χ_u(z) := (−1)^{Tr(uz)}. Then Σ_u χ_u(z) = 2^m·1[z = 0], so
  N ≤ 2^{−m} Σ_u Σ_{a,b} χ_u(G(a)) χ_u(G(b)) χ_u(ab).
The u = 0 term is 2^{2m}. For u ≠ 0, the matrix H_{ab} := χ_u(ab) satisfies HHᵀ = 2^m I, because Σ_b χ_u((a+a′)b) = 2^m·1[a = a′]. So |vᵀHv| ≤ |v|²·2^{m/2} = 2^{3m/2} for v_a := χ_u(G(a)) ∈ {±1}. Hence N ≤ 2^{−m}(2^{2m} + (2^m − 1)2^{3m/2}) < 2^m + 2^{3m/2}. ∎

[computed: c5 verifies HHᵀ = 2^m I for m = 2,…,6 and all u ≠ 0; exhaustive search gives max_G N(G) = 8 for m = 2 and 22 for m = 3, against the bounds 12 and 30.6; local search for m = 4,…,7 found at most 56, 142, 322, 740, against 80, 213, 576, 1576. s4 (referee) proves the values 8 and 22 optimal by mixed-integer programming and, for m = 4, leaves max N in [56, 80].]

**Theorem 5.4 [proved].**
(a) In both orders, L_ξ(D_{abr}) ≤ m + c, with c independent of m.
(b) L_SFI(D_{abr}) ≥ K(a,b,r ∣ m) − 3m/2 − 1 − c. So for all but a 2^{1−k} fraction of the triples, L_SFI ≥ 3m/2 − k − c′ ≥ max_σ L_ξ + m/2 − k − c″.
(c) For uniform (a, b, r) with a ≠ b: E[L_SFI(D_{abr})] ≥ 3m/2 − 2 for every m ≥ 1.
The lower bounds are in the semimeasure convention; for the normalised predictor they are **[open]** (Q4).

*Proof.* (a) Let P predict y_1 uniformly on {0,1}^{|x_1|}, and then y_2 = y_1 + x_1x_2 in GF(2^{|x_1|}). In the order (a, b) its loss is m. In the order (b, a) it predicts (r + ab) + ba = r, again with loss m, since ab = ba and the characteristic is 2. Apply Cor. 4.3(b).
(b) Σ_{a≠b, r} M_F(D_{abr}) = E_ω #{(a,b) : a ≠ b, U^ω(a) + U^ω(b) = ab} ≤ max_G N(G) < 2^{3m/2+1}, where r = U^ω(a) is determined by ω, and outputs outside {0,1}^m do not count. Both sides count ordered pairs; D_{abr} = D_{b,a,r+ab} is harmless. So M_F(D_{abr})·2^{−3m/2−1} is a discrete semimeasure on triples, LSC uniformly in m. Apply (F4). There are 2^m(2^m − 1)2^m ≥ 2^{3m−1} triples, and fewer than 2^{3m−k} of them have K(a,b,r ∣ m) < 3m − k.
(c) Jensen: E[L_SFI] ≥ −log E[M_F(D)] ≥ log(2^{2m}(2^m − 1)) − (3m/2 + 1) ≥ 3m/2 − 2. ∎

[computed: r3 (referee, earlier run) computes the exact optimum over *all* random functions on F, OPT_m := min_w E[−log w(D_{abr})]: 2.708 bits for m = 2 and 4.348 bits for m = 3, against ξ's m = 2 and 3. Since U restricted to F is a random partial function, E[L_SFI] ≥ OPT_m with no additive constant, and E[L_SFI] ≤ OPT_m + K(m) + O(1).]

**Interpretation.** In every order, ξ sees the first input when it predicts the second label, and the second label depends on it. SFI's hypotheses never see it. So L_SFI can exceed ξ's loss in its *worst* order by about m/2 bits (Thm 5.4(b)). For small m, the exact optimum over all random functions (r3) exceeds ξ's m by 0.71 bits (m = 2) and 1.35 bits (m = 3) in expectation. SFI's deficit is therefore not only the information carried by the order.

*Q6 (an observation, not a claim; referee m16).* The local-search values of c5 for m ≤ 7 suggest that max_G N(G) grows like about 2^{1.35m}, which would make the gap about 0.65m rather than m/2. Only m ≤ 3 is certified (s4); at m = 4 the true value lies in [56, 80]. The exponent is not determined.

*As a Reading-B process.* Let (a, b, r) be uniform, let f be the function with f(a) = r, f(b) = r + ab and a fixed marker value elsewhere, and reveal a and b in a uniformly random order. The reveal law is O(1)-simple given an oracle for f, E[L_P] = m for the predictor of (a), and E[L_SFI] ≥ 3m/2 − 2. This is a second example of Reading B failing, with exact constants. It is consistent with Thm 3.6: I(f → x) = (m − 1) + log(2^m − 1) ≈ 2m, because x_1 has entropy m and conditional entropy 1 given f, and x_2 is uniform on the other 2^m − 1 points given h_1 but determined given f.

### 5.4 Expected-value characterisation

**Theorem 5.6 [proved].** Let f ~ π, a computable random function, and let the inputs be drawn by any kernel Δ(· ∣ f, h_{i−1}), under the finiteness assumption of Thm 3.6. Then

  −c ≤ E[L_SFI(D_n)] − E[L_ξ] ≤ I(f → x_{1:n}) + K(π) + c.

If the input choice does not see f (Lemma 3.0), the gap is at most K(π) + c.

*Proof.* The lower bound is Lemma 1.2, pathwise. The upper bound is Thm 3.6(b) with P = ξ, whose conditionals are sub-probabilities, so Gibbs applies. ∎

*Tightness (referee m10).* In the randomized chain (Thm 3.7), E[L_SFI] − E[L_ξ] ≥ n(n−1)/2 − c, since ξ's loss is ≤ c (the chain predictor), while I(f → x) = n(n+1)/2. So the upper bound is attained there up to n, the entropy of the last input. It is not attained in general. In the GF process of §5.3, I(f → x) ≈ 2m, but E[L_SFI] − E[L_ξ] ≤ m + c, because E[L_SFI] ≤ 2m + c (uniform labels) and E[L_ξ] ≥ E[L_B] = m (r1(E)).

For arbitrary non-computable f, Thm 3.8 gives the analogous statement against every computable P, with C_dir and the extra K(n) + K(A).

### 5.5 Individual sequences: an information bound, and Q2 refuted

`notes.md` asked (Q2) whether an individual-sequence analogue of Thm 3.6 holds, for example L_SFI(D) ≤ L_ξ(D_σ) + I(x_σ : y_σ) + O(log), with algorithmic mutual information I(a : b) := K(b) − K(b ∣ a). It does not.

**Proposition 5.7 [(a) proved; (b) refuted with counterexample; computed: s1].**
(a) For every data set D with distinct inputs and every order σ:
  L_SFI(D) ≤ L_ξ(D_σ) + I(x_σ : D) + c.
(b) The bound with I(x_σ : y_σ) in place of I(x_σ : D) is false, even with an additive O(log n). For every set S of n ≥ 2 strings, the order σ and labels y_i = [i even] of Prop. 4.5(i) give
  L_SFI(D) − L_ξ(D_σ) − I(x_σ : y_σ) ≥ n − log(n+1) − K(n) − c.
In expectation, with the even-position set A ⊆ S of size ⌊n/2⌋ drawn uniformly, E_A[L_SFI(D_A)] ≥ log C(n, ⌊n/2⌋) ≥ n − log(n+1) exactly, while L_ξ ≤ c and I(x_σ : y_σ) ≤ K(n) + c on every instance.

*Proof.* (a) The lookup table of D is a partial computable function computable from D, so (F3) gives L_SFI(D) ≤ K(D) + c. For a fixed input list x_{1:n}, y_{1:n} ↦ ξ(y_{1:n} ‖ x_{1:n}) is a discrete semimeasure on Y^n (iterate the chronological inequality from step n down to the root), LSC uniformly in x_{1:n}. So (F4) gives K(y_σ ∣ x_σ) ≤ L_ξ(D_σ) + c, and D is computable from (x_σ, y_σ), so K(D ∣ x_σ) ≤ L_ξ(D_σ) + c′. Hence L_SFI(D) ≤ K(D) + c = I(x_σ : D) + K(D ∣ x_σ) + c ≤ I(x_σ : D) + L_ξ(D_σ) + c″.
(b) By the proof of Prop. 4.5(i), L_SFI(D) ≥ n − log(n+1) − 1 − c, and L_ξ(D_σ) ≤ c (the predictor "[i even]" is history-aware, since it knows i). y_σ = 0101… is computable from n, so I(x_σ : y_σ) ≤ K(y_σ) + c ≤ K(n) + c. For the expectation: the D_A are labellings of the same domain S, so the events {f_ω ⊇ D_A} are disjoint and Σ_A M_F(D_A) ≤ 1. Gibbs' inequality against the uniform law on the C(n, ⌊n/2⌋) sets A gives E_A[−log M_F(D_A)] ≥ log C(n, ⌊n/2⌋). ∎

[computed: s1 (referee) checks the disjointness and Gibbs steps over all labellings for n ≤ 14 (on random laws of random functions), log C(n, ⌊n/2⌋) ≥ n − log(n+1) for 2 ≤ n ≤ 4096, and tabulates the gap with Elias-δ as a computable upper bound on K(n): ≥ 1 048 536 − c bits at n = 2^20.]

*Why (a) is weak.* I(x_σ : D) also counts what x_σ says about dom D. For constant labels, for example, it is about K(dom D), although SFI's loss is O(1) there. Which individual-sequence quantity is tight is **[open]** (Q9). The sandwich of Thm 5.2 is one answer, in terms of KH; Thm 5.4 shows that order information alone is not the right quantity.

**What SFI can and cannot exploit, in one paragraph.** SFI can exploit any structure of the labels that a single random function with shared randomness can express: the dependence of each label on its own input, and correlations between labels through the shared tape, including correlations with guesses about the other inputs. In the semimeasure convention it cannot exploit the order of the data (Prop. 5.1), and it cannot let a label depend on which other inputs are present (Thm 5.4). In expectation, the loss this costs relative to the history-aware optimum (SFI^hist = ξ, or the Bayes predictor) is at most the directed information I(f → x_{1:n}) that the input choices carry about f beyond the revealed labels, plus K(π) (Thm 5.6). That bound is attained up to the last input's entropy in the randomized chain, and not in general. On individual sequences, the cost lies between "advantage of the actual order over the worst order" and "complexity of recovering the history from each input" (Thm 5.2). The two coincide up to K(e) for initial segments of a computable enumeration (Cor. 5.3), and they can differ by about m/2 (Thm 5.4). The information bound of Prop. 5.7(a) is a third upper bound; the naive information form with I(x_σ : y_σ) is false (Prop. 5.7(b)). For the chain and the skipped strings the per-step normalised predictor pays the same quadratic loss up to O(n log n) (Prop. 2.4).

---

## 6. Open questions

* **Q1 (the K(n) + K(A) term).** In Thm 3.8 and Cor. 3.9(a), can K(n) + K(A) be replaced by a constant, as Hänni's Thm 1 asserts? Evidence: the referee's r6 certifies that a single random function for horizons 1–4 needs a positive constant (≥ 0.026 bits in one instance), and r7 finds no growth of that constant up to horizon 6. This is weak evidence that the K(n) is an artefact of the proof.
* **Q2 [refuted].** `notes.md` conjectured L_SFI(D) ≤ L_ξ(D_σ) + I(x_σ : y_σ) + O(log). Refuted by Prop. 5.7(b): the gap is ≥ n − log(n+1) − K(n) − c on the construction of Prop. 4.5(i). Kept here with its counterexample.
* **Q3 (SI's conditional label loss).** For unnormalised M, both directions of L_ξ = L_M^y ± O(1) fail, conditional on (LHG-even) and (LHG-odd) (§4.4). Open: whether these hypotheses hold as stated (in particular the odd-position version and framed block codes), and both directions for the normalised Solomonoff measure.
* **Q4 (normalised SFI).** Prop. 2.4 settles the chain and the skipped strings: the lower bounds hold for the per-step normalised predictor up to O(n log n) (resp. O(ℓ log ℓ)). Open: the separations of Prop. 4.5(i), (iii) and 4.5′, and the GF example (Thm 5.4), where the information per step is too small for the broom argument.
* **Q5.** Is L_M^joint = L_ξ + L_ξ′^x ± O(1) in general? Only ≤ is proved (Thm 4.6(b)). For computable deterministic input policies it holds up to K(δ) + c (Prop. 4.7, by-product). In general we expect a logarithmic correction, by analogy with symmetry of information; unproved.
* **Q6 (an observation).** The growth exponent of max_G N(G) in Lemma 5.5. Only m ≤ 3 is certified; the local-search values suggest about 2^{1.35m}.
* **Q7 (Reading C, remaining cases).** Defective samplers P with K(P) alone; infinite input or label alphabets at a fixed horizon; reveal laws that see f in case (b) of Thm 3.8 (a computable value of C_dir to within 1 is needed).
* **Q8 (Conjecture 3.11).** Can K(Δ_f) be replaced by I(Δ_f : f) + O(log K(Δ_f)) in Reading C? Untested.
* **Q9.** Which individual-sequence quantity measures SFI's gap to ξ tightly? Candidates: KH (Thm 5.2), I(x_σ : D) (Prop. 5.7(a)), L_ξ′^x (§5.2).
* **Q10 [resolved].** `notes.md` asked, in effect, whether the single shortest program for SFI^hist pays an unbounded excess over n on fair-coin labels. Yes: more than log n + log log n bits for infinitely many n, along every input sequence, and at most K(n) + c (Prop. 4.10(d)); the mixture pays at most τ(n) + c. Open: the exact rate between log n + log log n and log n + 2 log log n.

---

## 7. Relation to the brief and to Hänni's text

* **H3, chain:** proved (Thm 2.1), with rate L_{n−1} ± O(log) in the semimeasure convention; for the normalised predictor, n(n−1)/2 − O(n log n) with ℓ_i = i (Prop. 2.4). Hänni's predictor uses only the set of revealed pairs. Every order-free predictor pays the same (Prop. 2.3).
* **H3, skipped strings:** proved (Thm 2.2), via incompressibility as Hänni indicated; normalised version in Prop. 2.4(b).
* **H3, Thm 1:**
  * the proof sketch is invalid (Prop. 3.1): it drops cross-input correlations and averages over simulated rather than true histories;
  * in the reading his text supports (Reading C), the theorem is **true**: pathwise for deterministic reveal policies with C_Δ = K(δ_f) (Cor. 3.9(b)); in expectation with C_Δ = K(Δ_f) plus K(n) + K(A) for almost surely halting samplers and finite alphabets at the horizon (Cor. 3.9(a)); in general with the reveal entropy added (Cor. 3.9(c));
  * his remark that a "simple reveal law" version fails when the reveal choice informs about f is correct and is made rigorous by Thm 3.7 (Reading B is false);
  * with a computable prior, a Δ-free and P-free form holds (Thm 3.5), and the correct extra term for f-dependent input choice is the directed information (Thm 3.6), attained in the randomized chain;
  * his mutual-information question: answered negatively in Reading B (Thm 3.7); its Shannon form holds in Reading C (Prop. 3.10); the algorithmic form is Conjecture 3.11.
* **H4:** proved in the form of Cor. 4.3: with oracle access to the previous inputs, SFI is the universal chronological semimeasure (Thm 4.2). "As good as SI" holds against SI's joint loss (Thm 4.6(a)), and its relation to SI's conditional label loss is the input-loss identity (Prop. 4.7); for unnormalised M it fails in both directions, conditional on the LHG phenomenon (§4.4). The literature status is in §4.6: Hutter's universal chronological semimeasure and his "supervised learning from examples" section are prior work in substance (content unverified).
* **H5:** SFI^hist has loss ≤ c on the cyclic permutation (Prop. 4.8).
* **"Kolmogorov vs semimeasure versions"** (Hänni's §2.2): the foundations track's subject. For SFI^hist, the program mixture pays at most τ(n) + c extra on fair-coin labels (Prop. 4.10), not K(n); the single shortest program pays more than log n + log log n infinitely often (Prop. 4.10(d)). So the Kolmogorov and semimeasure versions of SFI^hist are not equivalent up to a constant.
* **"What can SFI exploit?":** §5.

---

## 8. Cross-track consistency

Read against: `../foundations/notes-final.md`, `../context/notes-final.md`, `../steeper/notes-final.md`, and `../examples/notes.md` with its `referee.md` (the examples track has no `notes-final.md` yet; its revision is in progress, so its item numbers may change).

### 8.1 Definitions and notation

| Object | Here | Foundations | Examples | Context | Steeper |
|---|---|---|---|---|---|
| data set, consistent sequence, D_n, D + (x,y), ⊥ | §1.1 | §1 (same) | §1.1 (same) | §1.1 (same) | §8.1 (same) |
| function machine T, law ν_T | §1.2 (Def 2.5 cited) | Def 2.5, Prop 2.6 | §1.1 | §1.1 | §1.2 |
| SFI, M_F, loss | M_F, L_SFI := −log M_F (§1.2) | M_F (Def 5.1), L_n (Prop 5.2) | M_F, L_SFI | M_F, L_ν | mixture of Π_F |
| normalised predictor | M̄_F, S_t, l̄_t, L̄ (§1.2) | M̄_F, Z_t, L̄_n (Props 5.3, 5.5) | caveat in §0; open problem in §7 | ν̄ (§1.2) | — |
| order-free predictors | weak function semimeasures (§2.3) | Def 2.1, Prop 2.1a | Prop 2.4 | Prop 5.1(a) | Π_w |
| history-aware universal | ξ := M_H, the law of SFI^hist (§4.1) | ξ by trimming (Prop 7.2(a)); equal to M_H up to constants (Prop 7.2(d)) | L_hist, (F7) | SFI^hist (cited) | mixture of Π_chr = M_H |
| operator induction | per-query mixture M_pq (Prop. 4.9) | M_pq (Def 4.1, Prop 6.9) | — | per-query mixture S (§6 item 1) | — |
| padded length | κ(N) := min_{L≥N} K(L); τ(N) (§1.1) | κ (same) | — | — | κ is a machine constant |
| tape measure | λ | λ | λ | λ | λ is the steepness exponent |
| SI on (x, y) streams | M on code(x_1y_1…), any fixed prefix-free code (§4.4) | Prop 7.1 (sequence case) | c(h_t) with prefix-free codes (Lemma 1.3); n-bit blocks without delimiters (Prop 2.6) | — | Π_SI |

* All tracks use the same objects with the same definitions. This revision adopts the foundations notation (D + (x,y), ⊥, M̄_F, κ) where `notes.md` differed.
* **The universal chronological semimeasure.** Foundations constructs one by trimming (its Prop 7.2(a)); here ξ is *defined* as M_H, the law of SFI^hist. Each is universal in the same class, so they agree up to multiplicative constants (foundations Prop 7.2(d), Cor. 4.3(a) here). Both tracks mark the identification with Hutter's ξ as known but unverified, and neither depends on it. For the paper I suggest defining ξ := M_H, because it is an explicit machine (SFI^hist) and Thm 4.2 shows that nothing is lost, and mentioning trimming as an alternative construction.
* **Notation clashes for the paper.** The random reveal-law index of Prop. 3.10 is written Θ, not K as in the partial draft, to avoid a clash with prefix complexity. m is the field size of GF(2^m) here and in Thm 5.4, a confidence parameter in the examples track's bounds (cited in §4.5), **m**(i) in foundations, a sample size in context and a junta size in steeper. λ and κ clash with the steeper track, as the foundations, context and steeper tracks all note.
* **Encodings for SI.** Thm 4.6 and Prop. 4.7 hold for every fixed prefix-free block code with nonempty codewords, including the identity code on single bits when X = Y = {0,1}. The examples track's Prop 2.6 uses undelimited n-bit blocks, which are prefix-free only once n is known; its referee (M3) attributes the K(n) there to this choice. The paper should fix one encoding for "SI on x_1y_1x_2y_2…".

### 8.2 Items of this track cited elsewhere, checked against this revision

All numbers are kept from `notes.md`; content changes are listed.
* Lemma 1.1 (examples, context), Lemma 1.2 (foundations Prop 7.2(b)): unchanged.
* Lemma 2.0 (examples, adapted to a fixed end point), Thm 2.1 and 2.2 with parts (a), (c) (foundations Remark 5.6 and §6.7, context Remark 3.2, examples Remark 2.8): unchanged in content; the convention is now stated next to each lower bound, and Prop. 2.4 adds the normalised version.
* Prop. 2.3 (context §8.2): unchanged.
* Thm 3.5(b) (foundations Prop 5.5(c)), Thm 3.6 (foundations §6.4): unchanged.
* Cor. 3.9 (context §8.2): unchanged in content; the reveal law may now keep private memory (Lemma 3.0).
* Lemma 4.1, Thm 4.2, Cor. 4.3 (foundations Prop 7.2(d), steeper §1.2 and §8.3, context, examples (F7)): unchanged in content. Thm 4.2 now states exactness "at every non-root node" (referee m5); as the steeper track notes, this does not affect dominance.
* Prop. 4.4(a), Prop. 4.5(iii) (examples (F7) and §2.6): unchanged. Prop. 4.5(ii) loses a superfluous K(n) (m18).
* Thm 4.6 (examples Lemma 1.3): (a)–(c) unchanged; (d) is strengthened to L_M^joint ≤ L_ξ + K(δ) + c (Prop. 4.7).
* §4.4, LHG (examples Lemma 1.3): now contains Prop. 4.7 and the two conditional consequences. The examples track's remark that LHG's failure concerns particular sequences, while its Lemma 1.3 holds in expectation, is consistent with Prop. 4.7: the failing sequences are specific, and in expectation over a computable input law SI's label loss is within K(μ) + c of the Bayes loss.
* Claim 4.9 (foundations Def 4.1 and Prop 6.9, context §6 item 1): now Prop. 4.9, same content, stated with the foundations notation M_pq. All four tracks read operator induction as the per-query mixture, equal to M_prod on distinct inputs.
* Thm 5.2 (context §8.2, Prop 2.14), Thm 5.4 (foundations Remark 5.6): unchanged in content (m3 changes only the proof).
* Q4 (examples §7, context §8.1, foundations Remark 5.6): now partly answered by Prop. 2.4.

### 8.3 Results of other tracks used here

* Foundations: Def 2.1 (weak semimeasures) and its consequence (b); Def 2.5 and Prop 2.6 (function machines); Thm 3.2 (universality, used as (F1), also over X_H and Y*); Prop 3.3(a,b,c) (product laws, programs, computable laws); Thm 3.4 (M^w); Def 4.1, Thm 4.2 (W, M_prod, M_pq); Prop 4.4 (tape-length bound, compared in Prop. 4.10); Props 5.2, 5.3, 5.5(a) (conventions); Thm 6.3(a) (domain lower bound); Lemma 6.5a (computable random functions); Thm 6.7(b) (stamped SFI); Prop 6.9(a,d) (per-query mixture); Prop 7.2 (chronological semimeasures). I checked each statement against the current foundations file; the numbers above are its current numbers.
* Examples: the setup of the cyclic permutation (§2.1), Thm 2.1 and Prop 2.6 (cited for comparison in §4.5), Prop 2.4 (cited in §2.3). Prop. 2.4 follows the broom method of the examples referee's Prop R2 (normalised predictor for H5), which that referee also suggested for the chain; the skipped-string case and the pathwise forms are added here.
* Context and steeper: no result is used in a proof here.

### 8.4 Agreements, and updates the other tracks may want

* **Normalised convention.** Foundations Remark 5.6, the context track's §8.1 and the examples track's caveat list the chain and the skipped strings as "semimeasure convention only". After Prop. 2.4 they also hold for the per-step normalised predictor, up to O(n log n) (resp. O(ℓ log ℓ)) bits, with ℓ_i = i. The GF example (Thm 5.4) and the separations of Prop. 4.5 remain semimeasure-only. The examples referee's Prop R2 does the same for H5 for t ≤ 2^{(1−δ)n}.
* **Deterministic programs.** Foundations Prop 4.4 (W pays κ(L_{1/2}) against any machine law), Prop. 4.10 here (W_hist pays τ(n) ≤ κ(n) on fair-coin labels) and the steeper track's Lemma 3.2′ (2 log(t+1)) agree: the program mixture pays only for naming a padded length, never K(n). For the single shortest program, foundations Thm 4.7 (about log n on two-point data sets) and Prop. 4.10(d) here (more than log n + log log n infinitely often) agree in kind: one program must be chosen, and the counting bound bites.
* **H4.** Foundations Prop 7.2 and Cor. 4.3 here agree; the steeper track uses only the universality of M_H. The context track's remark that x-only dominance does not cover generalisers that use the data they have seen is consistent with Cor. 3.9 and Cor. 4.3.
* **Operator induction.** Resolved: all tracks use the per-query reading (Prop. 4.9; foundations Def 4.1; context §6 item 1).
* **Disagreements.** None outstanding. The partial draft of this file promised a "§4.6" record of a Wyeth–Hutter 2025 paper. The only such paper found by search, "Value Under Ignorance in Universal Artificial Intelligence" (arXiv 2512.17086; abstract only), is about semimeasure loss as a chance of death in AIXI; it does not bear on Thm 4.2, so it is not cited.

---

## 9. Response to the referee

The report (`referee.md`) found no fatal error and six major issues. Each is accepted; none is disputed.

| Issue | Action | Where |
|---|---|---|
| **M1** Reading B presented as Hänni's reading | Reading C adopted as the reading his text supports; Reading B kept as a stronger variant that fails; Thm 3.7 credited as Hänni's own remark made rigorous; Thm 1 stated as true under the hypotheses of Cor. 3.9; the Reading-C mutual-information question stated as Conjecture 3.11, with its Shannon form proved (Prop. 3.10). | §0 rows 3.7–3.11, §3 intro, Thm 3.7, Cor. 3.9, §3.6, §5.3, §7 |
| **M2** Thm 3.8 quoted without hypotheses | (H1), (H2) and the K(A) term stated in the theorem, the summary and §7; private-memory reduction proved (Lemma 3.0); case (b), computable real values, proved for reveal laws that do not see f, proof sketch for those that do; remark that Thm 3.2, Cor. 3.3, 3.4 and Thm 3.5 need none of this. | Lemma 3.0, Thm 3.8, Cor. 3.9, verdict on Thm 1 |
| **M3** Q2 refuted by Prop. 4.5(i) | Q2 marked refuted with the counterexample and the expectation version; the weaker correct bound L_SFI ≤ L_ξ(D_σ) + I(x_σ : D) + c proved. | Prop. 5.7, Q2, Q9 |
| **M4** missing reduction; Q3 | Input-loss identity proved (Prop. 4.7); Thm 4.6(d) strengthened; Q5 for deterministic policies; the LHG hedge moved from "unbounded loss" (which non-convergence already implies) to the exact form and position of the selected bits; both directions of Q3 fail for unnormalised M conditional on (LHG-even) and (LHG-odd); H4 verdict rewritten. *Addition:* for X = Y = {0,1} the identity block code is prefix-free, so the framing issue disappears there; what remains unverified is LHG's theorem itself and its odd-position version. | §4.4, Q3, Q5 |
| **M5** "≈ K(n)" for deterministic programs | Replaced by Prop. 4.10 with the tail form τ(n) ≤ κ(n), and the bound τ(n) ≤ g(n) + K(g) + c for every computable unbounded g. *Addition:* the single-shortest-program version, which the referee left unsettled, is settled by a Kraft counting argument: its worst-case excess exceeds log n + log log n infinitely often (Prop. 4.10(d)). | Prop. 4.10 |
| **M6** literature for H4 | Hutter's "Supervised Learning from Examples (EX)" cited as prior work in substance (content unverified) and the novelty claim for Cor. 4.3 withdrawn; operator induction (Prop. 4.9); Wood–Sunehag–Hutter as context for Thm 4.2; Thm 4.2 marked "literature status unverified"; LHG venue corrected to LNAI 6925. | §4.6, Prop. 4.9 |

| Minor | Action |
|---|---|
| m1 | Prop. 3.12 uses the chain function of an ML-random ω. |
| m2 | Cor. 3.4(a) and (b) proved separately. |
| m3 | Thm 5.2: the cost of p, its length, now comes from a fixed machine that reads p as a self-delimiting program for U(·, x). |
| m4 | Thm 4.2 proof: "≥" with the siblings' bounds ρ(z′), explained. |
| m5 | Thm 4.2: exact "at every non-root node". |
| m6 | LHG hedge rephrased (§4.4). |
| m7 | c_ω written in rows 2.1, 2.2 and in Thms 2.1(b), 2.2(d). |
| m8 | (F6) stated and proved in conditional form. |
| m9 | Thm 3.6 proof runs on the general space; no restriction of f. |
| m10 | Thm 5.6: "attained in the randomized chain, up to the last input's entropy; not attained in the GF process", with the reason. |
| m11 | Prop. 5.1 keeps only the order statement as proved; the rest is an informal remark, which now mentions guesses through shared randomness and the r3 optimum. |
| m12 | = M2. |
| m13 | ξ defined as M_H (§1.3, §4.1); Hutter cited only for the identification. |
| m14 | All scripts re-run; outputs byte-identical (verification log). |
| m15 | c2(B)'s simulator described as normalised and truncated (§3.1 and log); c1 alone establishes Prop. 3.1. |
| m16 | Q6 kept as an observation; s4's certified range for m = 4 recorded. |
| m17 | "Supremum over finite sequences is infinite" for Prop. 4.5(i),(iii); single-sequence versions proved (Prop. 4.5′). |
| m18 | K(n) dropped from Prop. 4.5(ii). |
| m19 | c4's deviation from the literal construction noted; r5 cited. |
| m20 | Remark on the ½U slack added after Cor. 3.9. |
| m21 | Convention stated next to each lower bound; for the chain and skipped strings the normalised versions are proved (Prop. 2.4). |

**The referee's "important questions".** (1) Reading C and its MI question: §3.6, Conjecture 3.11. (2) Thm 1 for computable samplers and private memory: Thm 3.8(b), Lemma 3.0. (3) H4 versus SI: Prop. 4.7. (4) Literature for H4: §4.6. (5) H5 for SFI^hist: Prop. 4.8. (6) Individual-sequence characterisation: Prop. 5.7(a), Q9. (7) The K(n) term: Q1, with r6 and r7. (8) Normalised SFI: Prop. 2.4 for the chain and skipped strings; Q4 for the rest.

---

## Verification log

**Environment.** Python 3.11.15, numpy 2.4.6, scipy 1.17.1 (s4 uses scipy's HiGHS interface). All scripts are seeded or deterministic. c1–c6, r1–r7 and s1–s4 print their results, which were saved to `*.out`; c7–c9 write their own `.out`.

**Re-run for this revision (referee m14).** Every script was copied to a scratch directory and run again; its output was compared byte for byte with the saved `*.out`. Result: **all identical**, for c1–c9, r1, r2, r3, r4, r5, r6, r7, s1, s2 and s3. s4 is time-limited (600 s of HiGHS at m = 4), so its output is not deterministic: the re-run reproduces m = 2, 3 exactly except for the timings, and at m = 4 the same incumbent 56 and the same optimiser, with dual bound 184 instead of 186; the conclusion (max N at m = 4 in [56, 80], from the analytic bound) is unchanged. c10 was written in this revision and run once; a second run in the scratch copy is byte-identical. The docstrings of c2, c3, c5 and c6 were edited after their outputs were first saved (as the referee noted); the re-run shows that the outputs are unchanged. c9 was written during an interrupted earlier attempt at this revision; its docstring changed after its first output, so it was re-run in place at the start of this revision, and a second run in the scratch copy is byte-identical.

### This track's scripts (`checks/`)

| Script | Seed | What it checks | Result |
|---|---|---|---|
| `c1_brief_counterexample.py` | 0 (exact) | Prop. 3.1: losses of P, the private simulator, the shared simulator and the constant-function mixture in the brief's {a,b} example, in exact rationals. | P: 1 bit; private: 2 bits; shared: 1; mixture: 1. Per-input loss at b: 0 bits (true history) vs 1 bit (simulated). |
| `c2_simulators_bayes.py` | 20261011 | (A) Thm 3.2 on 40 random instances: G(D) ≥ Δ·P on all consistent paths; G(D) ≥ Σ_σ for distinct inputs; G is a function semimeasure. (B) private-simulator violations of "E[sim loss] ≤ E[L_P]" (normalised simulator, horizon 3; supporting evidence only, referee m15). (C) Thm 3.5: Bayes loss = −log π(D_n) pathwise; E[L_P] ≥ E[−log π(D)]. (D) Thm 3.6 identity on 40 instances where the input choice sees f. | (A) min margins 1.1e−5 and −2.8e−17 (rounding); semimeasure max −1.1e−5. (B) violations 60/60 (Bayes P), 55/60 (perturbed Bayes), 0/60 (random P). (C) deviation 1.8e−15. (D) identity error 2.1e−15; min E[L_P] − E[L_B] = 1.69. |
| `c3_minimax.py` | 7 | Thm 3.8: minimax value V by SLSQP on 24 instances where Δ does not see f, 4 random instances where it does, and one designed leak; lower estimates of C_dir. | Non-peeking max V = +0.000000 (V = 0 for Bayes P). Peeking: V ≤ the C_dir estimate; designed leak V = 0.585 with C_dir ≥ 1. |
| `c4_chrono_representation.py` | 11 | Thm 4.2 construction in exact rationals; invariants (I1), (I2), (I4); exactness of the limit; Monte Carlo of the machine. Processes every node at every stage (not the literal prefix order; m19). | All nodes exact; 0 violations; Monte Carlo deviation 0.0056. |
| `c5_gf_agreement.py` | 5 | Lemma 5.5: HHᵀ = 2^m I (m ≤ 6); exact max N for m = 2, 3; local search for m = 4,…,7; implied E[L_SFI] bounds. | All below the bound; exact maxima 8 and 22; local search 56, 142, 322, 740; implied E[L_SFI] ≥ 2.585 (m = 2), 4.348 (m = 3). |
| `c6_set_order_lemma.py` | 0 (exact) | Lemma in Prop. 4.5(iii): the maximum number of orders consistent with one set-hypothesis, by exhaustive maximum-clique search, n = 2,…,5. | Equal to n in each case. |
| `c7_mi_shannon.py` | 20261012 | Prop. 3.10: the identity in (a) on 40 random instances with three reveal laws, private memory and f correlated with Θ; the inequalities; the randomized chain for n = 2, 3. | Identity error 2.0e−14; min slack I(f;Θ) − I(f→x) = 0.089; (E[−log π] − E[L_B]) − I(f;Θ) ≤ −0.18; chain: I(f→x) = I(f;Θ) = H(Θ) = n(n+1)/2, E[L_B] = 0. |
| `c8_certified_minimax.py` | 20261013 | Step 3 of Thm 3.8(b) on 12 instances with irrational P and Δ and exact zeros (F_fin a proper subset): a dyadic candidate certified against all 8 strict inequalities (★) by interval arithmetic. | All certified; largest certified max_f Φ_f = −0.930 (the proof guarantees ≤ 2). Illustration, not proof. |
| `c9_normalised_lower_bounds.py` (new) | 0 (exact) | Prop. 2.4 on finite mixtures with total brooms (resp. T_ℓ) and heavy partial components: closed forms vs enumeration, telescoping, the normaliser bound, Prop. 2.3(c) in expectation, the pathwise inequality; chain with block lengths 1–4 (all 1024 chains) and closed forms up to t = 40; skipped strings with lengths 1–3 (all 64 tuples). | All checks pass. Normalised vs raw cumulative loss: 6.62 vs 8.61 bits (chain), 6.54 vs 9.00 bits (skipped strings). The finite mixtures are not M_F. |
| `c10_single_program_counting.py` (new) | 20261014 | Prop. 4.10(d): the summation-by-parts identity on 200 random prefix-free sets (exact); the counting bound Σ_n 2^{−e*(n)} ≤ 2 on the toy language ⟨n⟩_δ y (n ≤ 2^16) and on 30 random prefix-free families covering all labellings of length ≤ 10; len_δ(n) > log n + log log n for 4 ≤ n < 2^20. | All checks pass. Toy language: partial sums 0.94 at n = 2^16. The random families are far from optimal (sums ≤ 0.07), so they test only consistency. Illustration of the counting argument, not of the universal machine. |

### Referee scripts (`referee_code/`) used here

| Script | Seed | Used for | Re-run |
|---|---|---|---|
| `r1_exact_bayes_directed.py` | 101 | Thms 3.5, 3.6, 3.7 (exact rationals, private memory); r1(E) for Thm 5.6 | identical |
| `r2_minimax_bracket.py` | 2027 | Thm 3.8: certified brackets, V ≤ 1.8·10^{−15} on 72 non-peeking instances | identical |
| `r3_gf_optimal_mixture.py` | 0 | Thm 5.4: OPT_m = 2.708 (m = 2), 4.348 (m = 3) | identical (265 s) |
| `r4_combinatorial_lemmas.py` | 4242 | Prop. 4.5(iii) for n = 6, 7; Lemma B | identical |
| `r5_chrono_literal.py` | 55 | Thm 4.2, literal construction, 0 mismatches | identical |
| `r6_horizon_free.py` | 606 | Q1: single-G value over horizons 1–4 certified ≥ 0.0262 bits | identical |
| `r7_horizon_growth.py` | 707 | Q1: no growth up to horizon 6 (upper brackets 0.0066, 0.0126, 0.0215) | identical |
| `s1_q2_counterexample.py` | 31415 | Prop. 5.7(b) | identical |
| `s2_prefix_mixture_extra.py` | 0 | Prop. 4.10 (toy language) | identical |
| `s3_defect_transfer_toy.py` | 2718 | Prop. 4.7 (toy mixture) | identical |
| `s4_gf_maxN_milp.py` | 0 | Lemma 5.5: max N = 8, 22 certified; m = 4 in [56, 80] | same results; timings and the m = 4 dual bound differ (time limit) |

### What is not machine-checked

* Every statement about K, M, ξ = M_H, M_F or M_H's universality is proved by hand. The scripts check only finite combinatorial, analytic or information-theoretic steps, as listed.
* Proofs new in this revision, checked by me line by line but not yet refereed: Prop. 2.4 and Lemma 2.4a; Lemma 3.0; the private-memory form of Thm 3.8; Prop. 4.5′; Prop. 4.10(d); the X_H formulation of §4.1 and the rewritten proof of Thm 4.2; the rewritten proof of Thm 5.2. Thm 3.8(b), Prop. 3.10 and Conjecture 3.11 were in the partial draft; the referee read Thm 3.8(b) "quickly and found no error". Prop. 4.7, Prop. 4.10's tail form and Prop. 5.7 follow the referee's own arguments, re-derived here.
* Case (b) of Thm 3.8 for reveal laws that see f is a proof sketch (computability of C_dir to within 1 is not written out).

### Literature checks (search snippets only)

arxiv.org, ar5iv, hutter1.net, link.springer.com, mlanthology.org and semanticscholar.org do not resolve from here (connection fails). Confirmed by snippets in this revision or by the referee:
* Lattimore–Hutter–Gavane, ALT 2011: authors, title, LNAI 6925 pp. 262–276, DOI, abstract wording, the even-bits motivating example. Theorem statements and the construction are **not** seen.
* Hutter, arXiv cs/0701125: published in *Artificial General Intelligence*, Springer 2007, pp. 227–290; a table-of-contents snippet lists a supervised-learning section (§5.4); the abstract lists supervised learning among the problem classes. The section's content is **not** seen.
* Hutter, arXiv cs.AI/0004001: chronological semimeasures; enumerability of the enumerable ones. The 2005 book is not reachable; chapter numbers unverified.
* Solomonoff, *Comput. J.* 51(5):566–570, 2008: title, venue, DOI, abstract (the third kind of induction). Content **not** seen.
* Wood–Sunehag–Hutter, arXiv 1111.3854: authors, venue (Solomonoff 85th Memorial Conference), DOI of the chapter, abstract. Volume number not confirmed.
* Wyeth–Hutter, arXiv 2512.17086 (2025): title and abstract only; judged not relevant to Thm 4.2 and not cited in the results.
* Coding theorem, Levin–Schnorr, Zvonkin–Levin, Sion: standard; cited from memory with section numbers unverified.

### Assumptions to flag to the writers

* (i) Lower bounds on SFI are in the semimeasure convention unless stated; the normalised versions are proved only for the chain and the skipped strings (Prop. 2.4).
* (ii) Thms 3.6, 3.8 and 5.6 need finite input and label sets at the horizon (or finite entropies).
* (iii) Thm 3.8 and Cor. 3.9(a) need (H1), (H2), computable values, and pay K(n) + K(A); Cor. 3.9(b),(c), Thm 3.2 and Thm 3.5 do not.
* (iv) ξ is defined as M_H. Its identification with Hutter's ξ, and the literature status of Thm 4.2 and of Hutter's supervised-learning section, are unverified.
* (v) The failure of "ξ ≈ SI's conditional label loss" (§4.4) is conditional on (LHG-even) and (LHG-odd).
* (vi) The constants c and c_ω can be large; statements of the form "loss ≤ c" are qualitative.
