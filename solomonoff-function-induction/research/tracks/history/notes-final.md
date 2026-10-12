# Track "history": history-aware predictors, SFI^hist and the chronological semimeasure (final notes)

Brief items H3 and H4, and the question "what can SFI exploit, and what not?".

This is the revised version of `notes.md`, written after the referee report `referee.md`. It is self-contained: every result used is stated here, and every result marked **[proved]** is proved here. Theorem numbers follow `notes.md` wherever a result survived, so that the other tracks' references stay valid. New results have new numbers; §9 lists the changes.

Scripts: `checks/c1`–`c8` (this track) and `referee_code/r1`–`r7` (the referee's). All are seeded or deterministic, run with `python3`, and save their output next to themselves as `*.out`.

Status labels: **[proved]** (full proof here), **[computed]** (script and saved output), **[known]** (exact reference; *unverified* when not checked against the source), **[proof sketch]**, **[conjecture]**, **[open]**, **[refuted]** (kept with its counterexample).

---

## 0. Summary of results

All lower bounds on SFI are for the semimeasure convention L_SFI(D) = −log M_F(D) (§1.2). For the per-step normalised predictor they are **[open]** (Q4).

| # | Claim | Status |
|---|---|---|
| 2.1 | **Chain** (Hänni). Let ω be Martin-Löf random, cut into blocks x_i of computable increasing lengths ℓ_i, with L_k := Σ_{i≤k} ℓ_i. SFI's loss on (x_1,ε),(x_2,x_1),…,(x_n,x_{n−1}) satisfies L_{n−1} − K(ℓ_n) − c_ω ≤ L_SFI ≤ L_{n−1} + K(n) + c. A deterministic set-based predictor of constant size has loss 0. With ℓ_i = i the loss is n(n−1)/2 up to 2 log n + c_ω. Hänni's belief "unbounded loss" is correct. | proved |
| 2.2 | **Skipped strings** (Hänni). After all strings of length ≤ ℓ: K(s_1…s_ℓ ∣ ℓ) − c ≤ L_SFI ≤ ℓ(ℓ+1)/2 + c. If the s_ℓ are consecutive blocks of an ML-random ω: L_SFI ≥ ℓ(ℓ+1)/2 − K(ℓ) − c_ω. A deterministic set-based predictor of constant size has loss 0. | proved |
| 2.3 | The lower bounds of 2.1 and 2.2 hold for **every** order-free predictor (weak function semimeasure), for example M^w, M_prod and W, with K(ν) added for lower-semicomputable ν. In expectation they hold for every order-free predictor, computable or not. | proved (new) |
| 3.1 | The private-randomness simulator in the draft's proof sketch can lose more than P (the brief's example: 2 bits against 1). The sketch has two errors: it drops cross-input correlations, and it averages over simulated histories, whose labels come from P rather than from f. | computed (c1) |
| 3.2–3.4 | Shared-randomness simulator. For all computable samplers Δ (inputs) and P (labels), defective ones included, on every consistent sequence: L_SFI ≤ L_P + L_Δ + K(Δ) + K(P) + c. For a deterministic computable reveal policy δ: L_SFI ≤ L_P + K(δ) + K(P) + c. Also L_SFI ≤ −log M(code(x_1y_1…x_ny_n)) + c. | proved |
| 3.5 | Bayes form. Let f ~ π, a computable random function, and let the inputs depend on f only through revealed labels (any mechanism, even non-computable). Then L_SFI ≤ −log π(D_n) + K(π) + c on every path, and E[L_SFI] ≤ E[L_P] + K(π) + c for every predictor P. | proved |
| 3.6 | Directed information. If the input choice may also depend on f: E[L_SFI] ≤ E[L_P] + I(f → x_{1:n}) + K(π) + c. The excess of E[−log π(D_n)] over the Bayes loss is exactly I(f → x) minus an expected KL term. | proved (general proof); identity computed (c2, r1) |
| 3.7 | **Hänni's own remark, made rigorous.** He says a "simple reveal law" version fails when the reveal choice informs about f. Example: the randomized chain. The reveal policy has complexity O(1) relative to an oracle for f, E[L_P] = 0, and E[L_SFI] ≥ n(n−1)/2 − c. This refutes Thm 1 under the oracle reading (Reading B), which Hänni's text does not intend. | proved |
| 3.8 | **Minimax theorem** (a fixed reveal law that does not see f; arbitrary f). Hypotheses: finite label set; finite input sets A_n given by a computable map with complexity K(A). For every f: E[L_SFI] ≤ E[L_P] + K(P) + K(Δ) + K(n) + K(A) + c (+ C_dir if the reveal law sees f). This holds (a) for P and Δ with rational values computable from their arguments, and (b) for P and Δ with computable real values, which includes every computable sampler that halts with probability 1. | (a) proved; (b) proved for reveal laws that do not see f, proof sketch for those that do; computed (c3, r2, c8) |
| 3.9 | **Hänni's Thm 1 under Reading C** (his intended reading: for each f the reveal law Δ_f is a standalone sampler). Under the hypotheses of 3.8: E_{x∣f}[L_SFI] ≤ E_{x∣f}[L_P] + K(P) + K(Δ_f) + K(n) + K(A) + c. For deterministic Δ_f it holds pathwise, with no K(n) or K(A), for every sampler P. **Open:** samplers that diverge with positive probability, infinite alphabets, and whether K(n) can be dropped. | proved under the stated hypotheses; rest open |
| 3.10 | **Shannon form of Hänni's mutual-information question.** Let (f, K) be jointly random, f ~ π computable, and let the inputs, given K, come from a reveal law Δ_K that does not see f. Then I(f → x) ≤ I(f; K), so E[L_SFI] ≤ E[L_P] + I(f; K) + K(π) + c. | proved (new); computed (c7) |
| 3.11 | Algorithmic form under Reading C: K(Δ_f) can be replaced by I(Δ_f : f) + O(log). | conjecture (untested) |
| 3.12 | No pathwise version of Reading A with only K(P) + K(Δ). | proved |
| 4.1–4.3 | SFI^hist (hypotheses see the list of previous inputs) is SFI on list-valued inputs. Its law M_H is a universal lower-semicomputable chronological semimeasure. Every such ρ is generated **exactly** by a history-oracle function machine, at every non-root node. We define ξ := M_H. Then L_ξ ≤ L_P + K(P) + c on every sequence, for every lower-semicomputable history-aware predictor P. Hänni's conjecture H4 holds in this sense. That ξ equals Hutter's universal chronological semimeasure up to constants is known but unverified. Whether Thm 4.2 is already in the literature is unverified. | proved; identification known (unverified); computed (c4, r5) |
| 4.4–4.5 | Variants. Oracle access to previous (x,y) pairs gives the same class as SFI^hist. Access to the count i is the foundations track's stamped SFI. Access to the set of previous inputs lies strictly between. So SFI ≺ SFI^count ≺ SFI^set ≺ SFI^hist, with each gap unbounded, and unbounded along a single infinite sequence (4.5′). | proved; lemma computed (c6, r4) |
| 4.6 | Relation to Solomonoff's M on x_1y_1x_2y_2…: L_ξ ≤ L_M^joint + c and L_M^joint ≤ L_ξ + L_ξ′^x + c. For inputs from a computable deterministic policy δ: L_M^y ≤ L_ξ + K(δ) + c. | proved |
| 4.7 | Lattimore–Hutter–Gavane (ALT 2011): unnormalised M can fail on simple selected sub-patterns. If that failure carries over to the prefix-coded block format used here, then L_M^y ≤ L_ξ + O(1) fails on some input sequence. Whether L_ξ ≤ L_M^y + O(1) on every sequence is open. | known (unverified beyond the abstract); conditional; open |
| 4.8 | Cyclic permutation (H5): SFI^hist's loss is ≤ c on every instance. | proved |
| 4.9 | Operator induction (Solomonoff 2008), as secondary sources describe it, is a per-query mixture of x-only operators. It is a lower-semicomputable chronological semimeasure that ignores the history, so M_H dominates it. On data with distinct inputs it is M_prod ≤ 2^c M_F, so the separations of §2 apply to it. | proved, given the unverified description |
| 4.10 | Deterministic programs for SFI^hist: with binary labels the program mixture loses at most κ(n) + c bits against fair-coin labels, where κ(n) = min_{L≥n} K(L). | proved (corrects notes.md §7) |
| 5.1 | SFI's loss depends only on the set D_n. | proved |
| 5.2–5.3 | Sandwich: max_σ L_ξ(D_σ) − c ≤ L_SFI(D) ≤ min_τ [L_ξ(D_τ) + KH(x_τ)] + c. Equality up to K(e) + c for initial segments of a computable enumeration e. | proved |
| 5.4 | GF(2^m): L_ξ ≤ m + c in both orders. L_SFI ≥ 3m/2 − k − c for all but a 2^{1−k} fraction of triples, and E[L_SFI] ≥ 3m/2 − 2. The exact optimum over all random functions is 2.708 bits (m = 2) and 4.348 bits (m = 3), against ξ's m. So SFI's deficit is not only order information. | proved; computed (c5, r3) |
| 5.6 | −c ≤ E[L_SFI] − E[L_ξ] ≤ I(f → x) + K(π) + c. Attained up to the last input's entropy in the randomized chain; not attained in the GF process. | proved |

**What changed from `notes.md`.**
* **Hänni's Thm 1 is now read as his text intends (Reading C).** Under that reading it is **true** under the hypotheses of Cor. 3.9, and only the proof sketch is wrong. The "refutation" in `notes.md` was of Reading B, which his preceding sentence rules out. He had already said that version fails, and Thm 3.7 makes his remark rigorous (referee M1).
* Thm 3.8 now states all its hypotheses, including the K(A) term. It is extended from rational-valued to computable real-valued P and Δ, so it covers every almost surely halting sampler (referee M2).
* New: Prop. 2.3 (the §2 lower bounds hold for every order-free predictor) and Prop. 3.10 (Shannon form of the mutual-information question). The algorithmic form is stated as Conjecture 3.11.
* SFI^hist is now defined as SFI on list-valued inputs, and the universal chronological semimeasure is *defined* as M_H. Nothing depends on an unverified enumeration of chronological semimeasures any more. The literature status of Thm 4.2, operator induction and Wyeth–Hutter 2025 is recorded in §4.6 (referee M3).
* All minor issues m1–m17 are handled (§9). The remark on deterministic programs for SFI^hist is corrected (Prop. 4.10).

---

## 1. Setting

### 1.1 Notation

This follows the foundations track (`../foundations/notes.md` §1).
* X = Y = {0,1}* unless a finite label set is stated. The results hold for any countable decidable X and Y with |Y| ≥ 2, unless a statement says otherwise. ε is the empty string.
* A *data set* is a finite partial function D ⊆ X × Y, with domain dom D. A sequence (x_1,y_1),…,(x_n,y_n) is *consistent* if x_i = x_j implies y_i = y_j. (`notes.md` said "function-consistent".) D_n := {(x_i,y_i) : i ≤ n} and h_i := (x_1,y_1,…,x_i,y_i).
* λ is the uniform measure on {0,1}^ℕ, and [w] is the cylinder of the finite string w.
* log is log₂. K(·) and K(·∣·) are prefix complexities with respect to a fixed universal prefix machine V. c, c′, c″ are constants that depend only on the fixed machines and encodings. c_ω depends also on ω.
* s̄ is a fixed prefix-free code for strings (for example 1^{|s|}0s), and code(x_1y_1…x_ny_n) := x̄_1ȳ_1…x̄_nȳ_n.
* κ(N) := min_{L ≥ N} K(L). It is used only in Prop. 4.10.

### 1.2 Function machines and SFI

**Function machine** (foundations Def 2.5). A c.e. set T ⊆ X × {0,1}* × Y of triples that is *consistent*: if (x,w,y) and (x,w′,y′) are in T and w, w′ are comparable, then y = y′. For ω ∈ {0,1}^ℕ put f^T_ω(x) := y if some prefix w of ω has (x,w,y) ∈ T, and leave it undefined otherwise. The *machine law* is ν_T(D) := λ{ω : f^T_ω ⊇ D}.

The same object is a Turing machine with a one-way read-only random tape ω. All queries share the tape. On query x the machine reads finitely many tape bits and then halts with a label or diverges. (`notes.md` used this form; the two forms convert into each other uniformly.) ν_T is lower semicomputable (LSC), uniformly in D and in an index of T (foundations Prop 2.6). K(T) is the complexity of an index of T in the effective list of function machines (foundations §2).

**Universal SFI.** M_F := ν_{T_U} is the law of the universal function machine. It reads a V-program p from the tape and then runs T_{V(p)} on the rest of the tape. Facts used:
* (F1) M_F(D) ≥ 2^{−K(T)} ν_T(D) for every function machine T and every D ≠ ∅ (foundations Thm 3.2).
* (F2) M_F is the law of a random partial function. So D ⊆ D′ implies M_F(D′) ≤ M_F(D); Σ_y M_F(D ∪ {(x,y)}) ≤ M_F(D) for x ∉ dom D; and for a finite set S the events {f_ω ⊇ l}, dom l = S, are pairwise disjoint.
* (F3) A partial computable g with g ⊇ D gives M_F(D) ≥ 2^{−K(g)−c} (foundations Prop 3.3(b)).
* (F3′) For a LSC conditional semimeasure P(y∣x), the product law ν_P(D) := Π_{(x,y)∈D} P(y∣x) is a machine law with K(ν_P) ≤ K(P) + c (foundations Prop 3.3(a)). These are Hänni's x-only samplers.
* A *computable random function* is a function machine T_π whose f_ω is total for λ-almost every ω. Put π(D) := ν_{T_π}(D) and K(π) := K(T_π). For finite Y these are exactly the computable laws of random total functions (foundations Thm 6.5). A law on Y^A with A finite and rational probabilities is a machine law, realised by rejection sampling from the tape (foundations Prop 3.3(c)).

**Loss (semimeasure convention).** L_SFI(D) := −log M_F(D). For a consistent sequence,
  Σ_i −log [M_F(D_i)/M_F(D_{i−1})] = L_SFI(D_n)
by telescoping, with M_F(∅) = 1. It depends only on the set D_n (foundations Prop 5.2). In the *normalised convention* one predicts with M_F(D_i)/Σ_y M_F(D_{i−1} ∪ {(x_i,y)}). Its cumulative loss is at most L_SFI(D_n), and it can depend on the order (foundations Prop 5.3). So upper bounds on L_SFI transfer to the normalised predictor, and lower bounds do not.

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

**Lemma 1.1 (domain lower bound) [proved].** For every data set D: L_SFI(D) ≥ K(D ∣ dom D) − c, where dom D is given as a finite set. This is the left side of foundations Thm 6.3(a). For a LSC weak function semimeasure ν, the same holds for −log ν(D), with K(ν) added.

*Proof.* Fix a finite set S. The labellings l of S give pairwise disjoint events {ω : f_ω ⊇ l} (F2), so ν_S(l) := M_F(l) is a discrete semimeasure. It is LSC uniformly in S. Apply (F4). For a weak ν, foundations Def 2.1, consequence (b), gives Σ_{dom l = S} ν(l) ≤ ν(∅) ≤ 1. ∎

**Lemma 1.2 (SFI is a chronological semimeasure) [proved].** Put ρ_F(y_{1:n}‖x_{1:n}) := λ{ω : f_ω(x_i) = y_i ∀i ≤ n}. This equals M_F(D_n) for consistent data and is 0 otherwise. ρ_F is a LSC chronological semimeasure. Hence L_ξ(D in order σ) ≤ L_SFI(D) + c for **every** order σ (using Cor. 4.3). This is foundations Prop 7.2(a). By foundations Prop 7.2(b) the same holds with M_F replaced by any LSC weak function semimeasure.

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

So the draft's belief is correct, with rate L_{n−1} up to logarithmic terms. The same bound holds in expectation when the blocks are uniform and independent (Thm 3.7).

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

---

## 3. The draft's Thm 1 (computable reveal distribution Δ)

> Thm 1. Let C be the set of computable samplers which get to see the revealed input-output data set so far … Suppose the data-generating process samples a function f : X → Y and then reveals a sequence of input-output pairs, with the sequence of inputs sampled from a distribution Δ. Then each predictor P in C can only beat solomonoff function induction in expected log loss by at most the complexity C_Δ of sampling from the reveal sequence distribution Δ plus a constant C_P.

**Three readings.**
* **Reading A (fixed reveal law that does not see f).** x_i ~ Δ(· ∣ h_{i−1}). The input choice sees f only through revealed labels. Δ may use private randomness and memory independent of f. f is arbitrary.
* **Reading C (a standalone reveal law for each f).** For each f there is a reveal law Δ_f(x ∣ h) that sees only the revealed history (with private randomness independent of f). The inputs are drawn from Δ_f, and C_Δ := K(Δ_f) is its complexity as a standalone sampler, or a bound on this uniform in f. Reading A is the case Δ_f = Δ for all f.
* **Reading B (oracle).** x_i ~ Δ(· ∣ f, h_{i−1}), with Δ computable relative to an oracle for f, and C_Δ the complexity of that oracle machine.

Throughout, "Δ(x∣h)" denotes the conditional law of the next input given the history (and given f in Reading B). Private memory is absorbed into this conditional; in Readings A and C it still does not depend on f, by the factorisation in the proof of Thm 3.5.

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

where Δ(x‖y) := Π_i Δ(x_i ∣ h_{i−1}). If the inputs are distinct, the right-hand side may be replaced by 2^{−K(Δ,P)−c} Σ_σ Δ(x_σ‖y_σ)P(y_σ‖x_σ), summed over all orders σ of D_n. Hence

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

For a kernel Δ (the conditional law of the next input given the history, or given (f|_{A_n}, history) in the peeking case) and a predictor P, put

  C_dir(Δ, n) := sup_π I_π(f → x_{1:n}),

with the supremum over laws π on Y^{A_n} and the inputs drawn from Δ. C_dir = 0 when Δ does not see f.

**Theorem 3.8 (minimax) [proved; (b) for kernels that see f: proof sketch].** Fix n, and assume (H1) and (H2). Assume either
(a) P and Δ take rational values computable from their arguments (Hänni's "computable distribution in the first sense"); or
(b) P and Δ take computable real values, uniformly in their arguments. By Lemma 1.0 this includes every computable sampler that halts with probability 1.
Then for **every** f : A_n → Y,

  E_{x∣f}[L_SFI(D_n)] ≤ E_{x∣f}[L_P] + C_dir(Δ,n) + K(P) + K(Δ) + K(n) + K(A) + c.

The bound also holds averaged over f ~ F, for any law F independent of the selector's private randomness. Here K(P) and K(Δ) are the complexities of programs that compute the values (exactly in (a), to any requested precision in (b)). For an almost surely halting sampler these are at most the sampler's complexity plus c.

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
(a) Assume (H1) and (H2). Let P and every Δ_f have computable real probabilities; this includes every almost surely halting sampler. Then for every f,
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
The proof sketch is invalid (Prop. 3.1); the theorem needs a different proof (minimax).

**Remarks.**
* *Why the K(n).* The minimax G depends on the horizon. The referee's r6 shows that horizon-specific minimax random functions are genuinely incompatible. In one small instance (the "random P" of r6, instance 0), the single-G value over horizons 1–4 is certified ≥ 0.026 bits, while every single-horizon value is ≤ 0.005 numerically and ≤ 0 by the theorem. So a horizon-free version needs a positive constant. r7 finds no growth of that constant up to horizon 6 in three instances: the upper brackets stay at 0.007, 0.013 and 0.022 bits. This is weak evidence that the K(n) is an artefact of the proof. It does not settle Q1.
* *Why compactness.* Finite A_n and Y make 𝒢 compact and the Lipschitz constant finite. The infinite case is **[open]**.
* *Defective samplers.* For a LSC P that diverges with positive probability, E[L_P] is only upper semicomputable. Condition (★) is then co-c.e. and cannot be certified, and no argument is known that K(P) + K(Δ) still suffices. The lower approximations P_t of P give rational predictors, but E[L_{P_t}] approaches E[L_P] at a rate that is not computable. Naming a good stage t costs K(t). **[open]**

### 3.6 Hänni's mutual-information question in Reading C

Hänni asks whether "thm 1 [can] be improved to a version that talks about the algorithmic mutual information of Δ and f instead of the complexity of Δ". Thm 3.7 answers this negatively for Reading B. In Reading C the question is whether K(Δ_f) can be replaced by I(Δ_f : f). Thm 3.7 does not decide this: there K(Δ_f) and I(Δ_f : f) are both ≈ Σ ℓ_i. The Bayesian (Shannon) analogue holds.

**Proposition 3.10 (Shannon form) [proved; computed: c7].** Let (f, K) be jointly distributed, with K an arbitrary random element (the "reveal law index"). Given (f, K), draw a private memory R with R independent of f given K. Then draw the inputs by x_i ~ Δ_{K,R}(· ∣ h_{i−1}), a kernel that does not see f, and put y_i = f(x_i). Assume finite input and label sets up to time n.
(a) If I(f; K) < ∞, then
  I(f → x_{1:n}) = I(f; K) − I(f; K ∣ h_n) − Σ_{i≤n} I(y_i ; K ∣ h_{i−1}, x_i) ≤ I(f; K).
(If I(f; K) = ∞, the inequality is trivial.)
(b) If f has law π, a computable random function, then for every predictor P:
  E[L_SFI(D_n)] ≤ E[L_P] + I(f; K) + K(π) + c.
(c) If K = Δ_f is a function of f, as in Reading C, then I(f; K) = H(Δ_f), the entropy of the random reveal law. The bound is attained in the randomized chain (Thm 3.7): there I(f → x) = I(f; Δ_f) = H(Δ_f) = n(n+1)/2.

*Proof.* (a) *Step 1: x_i ⊥ f ∣ (K, h_{i−1}).* Conditionally on K = k, the joint law of (f, R, h_{i−1}) is
  p(df ∣ k) p(dR ∣ k) Π_{j<i} Δ_{k,R}(x_j ∣ h_{j−1}) 1[f(x_j) = y_j].
For fixed (k, h_{i−1}) this is a function of f times a function of R. So f ⊥ R ∣ (K, h_{i−1}). The law of x_i given (f, K, R, h_{i−1}) is Δ_{K,R}(· ∣ h_{i−1}), which does not involve f. Hence the law of x_i given (f, K, h_{i−1}) does not involve f.
*Step 2.* By the chain rule, I(f; K, h_n) = I(f; K) + Σ_i [I(f; x_i ∣ K, h_{i−1}) + I(f; y_i ∣ K, h_{i−1}, x_i)]. The first summand is 0 by Step 1. The second is H(y_i ∣ K, h_{i−1}, x_i), because y_i is a function of (f, x_i).
*Step 3.* Also I(f; K, h_n) = I(f; h_n) + I(f; K ∣ h_n), and, as in the proof of Thm 3.6, I(f; h_n) = I(f → x) + Σ_i H(y_i ∣ h_{i−1}, x_i).
*Step 4.* Equate the two expressions. Use H(y_i ∣ h_{i−1}, x_i) − H(y_i ∣ K, h_{i−1}, x_i) = I(y_i ; K ∣ h_{i−1}, x_i) ≥ 0. All terms are finite: I(f; h_n) ≤ H(h_n) < ∞, and I(f; K) < ∞ by assumption.
(b) The process is a special case of Thm 3.6: given f, the inputs have some joint law with f. Apply Thm 3.6(b) and (a).
(c) I(f; K) = H(K) − H(K ∣ f) = H(K) when K is a function of f. In Thm 3.7, Δ_f determines the chain, which is uniform on n(n+1)/2 bits. ∎

[computed: c7, 40 random instances with three reveal laws, private memory and f correlated with K: the identity in (a) holds to 2·10^{−14}; I(f;K) − I(f→x) ≥ 0.089; and (E[−log π(D_n)] − E[L_B]) − I(f;K) ≤ −0.18. On the randomized chain with n = 2, 3: I(f→x) = I(f;K) = H(K) = n(n+1)/2 and E[L_B] = 0.]

**Conjecture 3.11 (algorithmic form, Reading C) [conjecture; untested].** Under the hypotheses of Cor. 3.9(a), for every f:
  E_{x∣f}[L_SFI] ≤ E_{x∣f}[L_P] + I(Δ_f : f|_{A_n}) + K(P) + O(log K(Δ_f)) + K(n) + K(A) + c.
*What supports it.* Prop. 3.10 is its Bayesian analogue. It is consistent with the randomized chain (both sides ≈ n(n+1)/2) and with the GF example of §5.3. The intuition: when Δ_f is complex but carries no information about f, a history-aware P can exploit the inputs' order only through structure of f that P itself must encode. *What is missing.* A function machine can access neither f nor Δ_f. A proof would have to show that the part of Δ_f that is independent of f can be "averaged out" at logarithmic cost. We have neither a proof nor a counterexample.

### 3.7 No pathwise version of Reading A

**Proposition 3.12 [proved].** There is no bound of the form L_SFI(D_n) ≤ L_P + K(P) + K(Δ) + c that holds on every path for every fixed f and every reveal law Δ that does not see f.

*Proof.* Let ω be Martin-Löf random and let f be **the chain function of ω**: with b_i the i-th block of ω of length i, put f(b_{i+1}) := b_i, f(b_1) := ε, and f(x) := ε elsewhere. Let Δ draw independent uniform strings of lengths 1, 2, …; K(Δ) = O(1). Let P be the chain predictor of Thm 2.1(c); K(P) = O(1). The path x_i = b_i has positive probability Π_{i≤n} 2^{−i}. On it, P has loss 0, while L_SFI(D_n) ≥ n(n−1)/2 − 2 log n − c_ω by Thm 2.1(b). ∎

(`notes.md` said "take f fixed"; for a generic fixed f the chain paths need not exist, or x_{1:n−1} may be cheap given x_n. The proof needs f to be the chain function of a random ω, as above; referee m1.) Thm 3.2 is the pathwise statement. On this path it pays L_Δ = n(n+1)/2.

<!-- PART2 -->
