# Track "history": history-aware predictors, SFI^hist and the chronological semimeasure

Brief items H3 and H4, and the characterisation asked for in item 3 of the track task.
Scripts are in `checks/` (seeded; outputs saved next to them as `*.out`).

Status labels: **[proved]** (full proof here), **[computed]** (script and saved output),
**[known]** (exact reference; *unverified* when not checked against the source), **[proof sketch]**,
**[conjecture]**, **[open]**, **[refuted]** (kept with its counterexample).

---

## 0. Summary of results

| # | Claim | Status |
|---|---|---|
| 2.1 | Chain example (Hänni): for an ML-random ω cut into blocks x_i of computable increasing lengths ℓ_i, SFI's loss on (x_1,ε),(x_2,x_1),…,(x_n,x_{n−1}) is ≥ Σ_{i<n} ℓ_i − K(ℓ_n) − O(1) and ≤ Σ_{i<n} ℓ_i + K(n) + O(1); a constant-size set-based predictor has loss 0. Hänni's belief "unbounded" is true; with ℓ_i = i the loss is n²/2 ± O(n). | proved |
| 2.2 | Skipped strings (Hänni): after all strings of length ≤ ℓ, SFI's loss is between K(s_1…s_ℓ ∣ ℓ) − O(1) and ℓ(ℓ+1)/2 + O(1); for ML-random choices ≥ ℓ(ℓ+1)/2 − K(ℓ) − O(1). A constant-size set-based predictor has loss 0. | proved |
| 3.1 | The private-randomness simulator in the draft's proof sketch can lose more than P (brief's example: 2 bits vs 1). The sketch has two errors: it drops cross-input correlations and it averages over simulated histories whose labels come from P, not from f. | computed (c1, c2) |
| 3.2 | Shared-randomness simulator: on every sequence, L_SFI ≤ L_P + L_Δ + K(Δ) + K(P) + O(1), with L_Δ the inputs' log loss under Δ. Hence Thm 1 holds pathwise for deterministic computable reveal policies. Also L_SFI ≤ −log M(x_1y_1…x_ny_n) + O(1) (Solomonoff on the joint sequence). | proved |
| 3.5 | Bayes form: if f ~ π for a computable random function π and the inputs depend on f only through revealed labels (any policy, even non-computable), then L_SFI ≤ −log π(D_n) + K(π) + O(1) on every path, and −log π(D_n) is the Bayes predictor's loss; so E[L_SFI] ≤ E[L_P] + K(π) + O(1) for every predictor P. | proved |
| 3.6 | Directed-information form: if the input choice may also depend on f, E[L_SFI] ≤ E[L_P] + I(f → x_{1:n}) + K(π) + O(1), with I(f → x_{1:n}) = Σ_i I(f; x_i ∣ h_{i−1}); the excess of the "set" loss over the Bayes loss is exactly I(f → x) minus an expected KL term. | proved; identity computed (c2) |
| 3.7 | Hänni's Thm 1 read with a reveal law that may depend on f (his wording) is false: randomized chain, K(Δ) = O(1), E[L_P] = 0, E[L_SFI] ≥ n(n−1)/2 − O(1). Any bound through K(Δ) or the algorithmic mutual information I(Δ : f) of the law fails for the same reason. | refuted (Thm 1, reading B) |
| 3.8 | Hänni's Thm 1 read with a reveal policy that does not see f (reading A), arbitrary fixed f, finite inputs and labels at each horizon: E[L_SFI] ≤ E[L_P] + K(P) + K(Δ) + K(n) + O(1). With an f-dependent policy add C_dir = sup_π I_π(f → x). Proof by a minimax argument. Whether the K(n) can be dropped is open. | proved (with K(n)); minimax computed (c3) |
| 4.2 | Every lower-semicomputable chronological semimeasure is generated exactly by a history-oracle function machine (shared randomness). | proved; construction computed (c4) |
| 4.3 | SFI^hist (hypotheses see the list of previous inputs) is, up to multiplicative constants, Hutter's universal chronological semimeasure ξ with inputs as actions and labels as percepts. It dominates every lower-semicomputable history-aware predictor on every sequence: L_hist ≤ L_P + K(P) + O(1). Hänni's conjecture H4 holds in this sense. | proved (ξ's definition: known, unverified) |
| 4.4–4.5 | Variants. Oracle access to previous (x,y) pairs gives the same class as SFI^hist. Access to the count i is SFI on time-stamped inputs. Access to the set of previous inputs lies strictly between. Strict hierarchy SFI ≺ SFI^count ≺ SFI^set ≺ SFI^hist, each gap unbounded. | proved; lemma for SFI^set computed (c6) |
| 4.6 | Relation to Solomonoff's M on x_1y_1x_2y_2…: L_ξ ≤ L_M^joint + O(1) and L_M^joint ≤ L_ξ + L_ξ'^x + O(1), with ξ' the universal input predictor. Hence L_ξ − L_M^y ≤ L_M^x + O(1) and L_M^y − L_ξ ≤ L_ξ'^x − L_M^x + O(1); for inputs chosen by a computable deterministic policy δ, L_M^y ≤ L_ξ + K(δ) + O(1). | proved |
| 4.7 | Lattimore–Hutter–Gavane (ALT 2011): unnormalised M can fail to predict simple recursive sub-patterns, while normalised M learns them. If the failure on the "copy the input" pattern means unbounded loss, then L_M^y ≤ L_ξ + O(1) fails on some input sequence. Whether L_ξ ≤ L_M^y + O(1) on every sequence is open. | known (unverified beyond the abstract); open |
| 5.1 | SFI's loss is order-independent (semimeasure convention). | proved |
| 5.2 | Sandwich: max_σ L_ξ(D in order σ) − O(1) ≤ L_SFI(D) ≤ min_τ [L_ξ(D in order τ) + KH(τ)] + O(1), where KH(τ) is the complexity of recovering each input's list of predecessors from the input. When dom D is an initial segment of a computable enumeration e, L_SFI(D) = L_ξ(D in e-order) ± (K(e) + O(1)), and the e-order is the worst order for ξ. | proved |
| 5.4 | The KH term cannot be dropped: in GF(2^m), D = {(a, r), (b, r + ab)} has L_ξ ≤ m + O(1) in both orders but L_SFI ≥ 3m/2 − k − O(1) for all but a 2^{−k} fraction of triples. In expectation E[L_SFI] ≥ 3m/2 − 2. So SFI's deficit is not only "order information". | proved; counting bound computed (c5) |
| 5.6 | Expected-value characterisation: −O(1) ≤ E[L_SFI] − E[L_ξ] ≤ I(f → x_{1:n}) + K(π) + O(1), tight up to the last input's entropy (randomized chain). The gap is the information that the choice of inputs carries about f beyond the revealed labels. | proved |

All lower bounds on SFI (2.1, 2.2, 4.5, 5.4) are for the semimeasure convention −log M_F(D). For the per-step normalised convention they are **[open]** (§1.2, Q4).

---

## 1. Setting

### 1.1 Notation

* X = Y = {0,1}* unless a finite label set is stated. ε is the empty string.
* A data sequence is (x_1,y_1),…,(x_n,y_n). It is *function-consistent* if x_i = x_j implies y_i = y_j. D_n = {(x_i,y_i) : i ≤ n} is the finite partial function it defines. h_i = (x_1,y_1,…,x_i,y_i) is the history.
* log is log₂. K(·) and K(·∣·) are prefix complexities. c, c′ denote constants that depend only on the fixed universal machines and on the encodings, unless other dependencies are stated.
* s̄ is a fixed prefix-free code for strings (e.g. 1^{|s|}0s); code(x_1y_1…x_ny_n) = x̄_1ȳ_1…x̄_nȳ_n.

### 1.2 Solomonoff function induction (SFI)

This follows the brief's H1(a); the foundations track fixes the definitions for the paper.

**Function machine.** A Turing machine T with a one-way read-only random tape ω ∈ {0,1}^ℕ. On query x it reads finitely many tape bits and either halts with an output T^ω(x) ∈ Y or diverges. All queries use the same ω (shared randomness). For a finite partial function D,

  M_T(D) := λ{ω : T^ω(x) = y for all (x,y) ∈ D}

(λ the uniform measure). This event is a union of cylinders, enumerable uniformly in D, so M_T is lower semicomputable (LSC).

**Universal SFI.** U reads a prefix-free program p from the tape and then runs T_p on the rest: U^{pω}(x) = T_p^ω(x). Put M_F := M_U. Then M_F(D) = Σ_p 2^{−|p|} M_{T_p}(D), so

* (F1) M_F(D) ≥ 2^{−K(T)} M_T(D) for every function machine T, where K(T) is the length of T's shortest program (equal to the prefix complexity of an index of T, up to a constant);
* (F2) M_F(D′) ≤ M_F(D) if D ⊆ D′, and Σ_y M_F(D ∪ {(x,y)}) ≤ M_F(D) for x ∉ dom D;
* (F3) a deterministic program g with g ⊇ D gives M_F(D) ≥ 2^{−K(g)−c}.

**Loss (semimeasure convention).** L_F(D_n) := −log M_F(D_n) = Σ_i −log [M_F(D_i)/M_F(D_{i−1})], with M_F(∅) = 1. It depends only on the set D_n, not on the order. *Normalised convention:* predicting with M_F(D_i)/Σ_y M_F(D_{i−1} ∪ {(x_i,y)}) gives a cumulative loss ≤ L_F(D_n) that depends on the order. So upper bounds on L_F transfer to the normalised predictor, but lower bounds do not.

### 1.3 History-aware predictors, chronological semimeasures, ξ

* A *history-aware predictor* P gives P(y ∣ h, x) ≥ 0 with Σ_y P(y∣h,x) ≤ 1. Its loss on a sequence is L_P := −log P(y_{1:n} ‖ x_{1:n}) with P(y_{1:n} ‖ x_{1:n}) := Π_i P(y_i ∣ h_{i−1}, x_i).
* A *computable sampler* is a probabilistic machine that, given (h, x), reads random bits and halts with a label, or diverges. Its P(y∣h,x) := Pr[output y] is LSC. This is the class C of the draft.
* A *chronological semimeasure* is ρ(y_{1:n} ‖ x_{1:n}) ≥ 0 with ρ(ε‖ε) ≤ 1 and Σ_y ρ(y_{1:n}y ‖ x_{1:n}x) ≤ ρ(y_{1:n} ‖ x_{1:n}) for every x. Every predictor P gives one. Conversely every ρ gives the predictor ρ(y_{1:i}‖x_{1:i})/ρ(y_{<i}‖x_{<i}), with loss −log ρ(y‖x).
* **ξ.** Hutter's universal chronological semimeasure is ξ := Σ_ρ 2^{−K(ρ)} ρ, summed over an enumeration of all LSC chronological semimeasures. It is LSC, chronological, and satisfies ξ ≥ 2^{−K(ρ)}ρ (known: Hutter 2005, *Universal Artificial Intelligence*, Springer, ch. 5; Hutter 2000, arXiv cs/0004001, eq. (27) and the universality statement after it, as quoted in a search snippet; **unverified**, section and equation numbers not checked). In Hutter's notation the agent's actions are y and its percepts are x. Here the roles are swapped: our inputs x play the actions, and our labels y play the percepts.

### 1.4 Facts used

* **(F4) Coding theorem** [known; Levin 1974, Gács 1974, Chaitin 1975; Li & Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed. 2008, §4.3; theorem numbers unverified]. Let ν(·∣w) be discrete semimeasures (Σ_z ν(z∣w) ≤ 1), lower semicomputable uniformly in w. Then ν(z∣w) ≤ 2^{−K(z∣w)+K(ν)+c}.
* **(F5) Levin–Schnorr** [known; Li & Vitányi 2008 §3.6, unverified numbering]. ω is Martin-Löf random iff there is c_ω with K(ω_{1:ℓ}) ≥ ℓ − c_ω for all ℓ.
* **(F6)** For a random variable Z, E[K(Z∣w)] ≥ H(Z) (Kraft) [proved: standard].
* **(F7)** K(a,b) ≤ K(b) + K(a∣b) + c and K(s) ≤ |s| + K(|s|) + c [known; Li & Vitányi 2008 ch. 3].
* **(F8) Universal M** [known; Zvonkin & Levin 1970; Li & Vitányi 2008 §4.5, unverified numbering]. M(z) := λ{ω : U_mono(ω) ⊒ z}, for a universal monotone machine, is an LSC semimeasure on {0,1}*. It satisfies M ≥ 2^{−K(ν)−c}ν for every LSC semimeasure ν.
* **(F9) Sion's minimax theorem** [known; M. Sion, "On general minimax theorems", Pacific J. Math. 8 (1958) 171–176; unverified]. We use only the compact convex finite-dimensional case with a continuous payoff that is convex in one variable and affine in the other.

### 1.5 Two basic lemmas

**Lemma 1.1 (domain lower bound) [proved].** For every finite partial function D: L_F(D) ≥ K(D ∣ dom D) − c. Here dom D is given as a finite set.

*Proof.* Fix a finite set S. Labellings l : S → Y give events {ω : U^ω ⊇ l} that are pairwise disjoint, so ν_S(l) := M_F(l) is a discrete semimeasure. It is LSC uniformly in S. Apply (F4). ∎

**Lemma 1.2 (SFI is a chronological semimeasure) [proved].** ρ_F(y_{1:n}‖x_{1:n}) := λ{ω : U^ω(x_i) = y_i ∀i} (= M_F(D_n) for function-consistent data, 0 otherwise) is an LSC chronological semimeasure. Hence L_ξ(D in order σ) ≤ L_F(D) + c for **every** order σ.

*Proof.* The events for different y_{n+1} are disjoint subsets of the event for y_{1:n}. If x_{n+1} repeats an earlier input, only one label survives. LSC as in §1.2. Universality of ξ gives the second statement. ∎

---

## 2. Hänni's two counterexamples

The draft: "let x_1, x_2, … be a deterministic sequence of increasingly long random strings … (x_1,0),(x_2,x_1),(x_3,x_2),… I'm pretty sure Solomonoff induction gets unbounded loss … I don't actually have a proof". Notes: "you give 0 to everything except one string you've skipped among all strings of a certain length … solomonoff has nothing inside doing that — if it had, we could compress these incompressible strings!"

We use ε as the first label of the chain so that labels and inputs never collide (the draft's "0" could equal x_1).

### 2.1 The chain

**Lemma 2.0 (chain semimeasure) [proved].** For a string x and a finite sequence z = (z_1,…,z_k) of nonempty strings (k ≥ 0), put
ν(z ∣ x) := λ{ω : U^ω(x) = z_1, U^ω(z_1) = z_2, …, U^ω(z_{k−1}) = z_k, U^ω(z_k) = ε}
(for k = 0: U^ω(x) = ε). Then Σ_z ν(z∣x) ≤ 1, and ν is LSC uniformly in x.

*Proof.* Fix ω and x, and suppose z ≠ z′ both satisfy the condition. Put z_0 = z′_0 = x. If they first differ at position j ≥ 1, then z_j = U^ω(z_{j−1}) = z′_j, a contradiction. If z is a proper prefix of z′ (length k < k′), then U^ω(z_k) = ε but also U^ω(z_k) = U^ω(z′_k) = z′_{k+1} ≠ ε, a contradiction. So the events are disjoint. ∎

**Theorem 2.1 (chain) [proved].** Let x_1,…,x_n (n ≥ 2) be distinct nonempty strings, and D_n := {(x_1, ε)} ∪ {(x_{i+1}, x_i) : i < n}, revealed in the order (x_1,ε),(x_2,x_1),….

(a) L_F(D_n) ≥ K(x_1,…,x_{n−1} ∣ x_n) − c and L_F(D_n) ≤ K(x_1,…,x_{n−1}) + c.

(b) Let 1 ≤ ℓ_1 < ℓ_2 < ⋯ be computable, ω Martin-Löf random, x_i the i-th block of ω of length ℓ_i, and L_k := Σ_{i≤k} ℓ_i. Then
  L_{n−1} − K(ℓ_n) − c_ω ≤ L_F(D_n) ≤ L_{n−1} + K(n) + c.
For ℓ_i = i: n(n−1)/2 − 2 log n − O(1) ≤ L_F(D_n) ≤ n(n−1)/2 + 2 log n + O(1).

(c) The predictor P = "predict ε on the empty history, otherwise the unique input of the history that is not a label of the history" (the draft's predictor) has loss 0 on this sequence. It is deterministic, has K(P) = O(1), and uses only the *set* of revealed pairs.

*Proof.* (a) Lower bound. Every ω with U^ω ⊇ D_n satisfies the condition of Lemma 2.0 for x = x_n and z = (x_{n−1},…,x_1). So M_F(D_n) ≤ ν(z∣x_n) ≤ 2^{−K(z∣x_n)+c} by (F4), and K(z∣x_n) = K(x_1,…,x_{n−1}∣x_n) ± c. Upper bound. The program with the list x_1,…,x_{n−1} built in does the following on input x: output ε if x = x_1; output x_{i−1} if x = x_i with 2 ≤ i ≤ n−1; otherwise output x_{n−1}. It is consistent with D_n. Apply (F3).
(b) ω_{1:L_n} is computable from the tuple x_{1:n}, so by (F5) K(x_{1:n}) ≥ L_n − c_ω − c. By (F7), K(x_{1:n}) ≤ K(x_n) + K(x_{1:n−1}∣x_n) + c ≤ ℓ_n + K(ℓ_n) + K(x_{1:n−1}∣x_n) + c′. Hence K(x_{1:n−1}∣x_n) ≥ L_{n−1} − K(ℓ_n) − c″. For the upper bound, the tuple x_{1:n−1} is determined by n and ω_{1:L_{n−1}}, and L_{n−1} is computable from n.
(c) At step i ≥ 2 the history's inputs are x_1,…,x_{i−1} and its labels are ε, x_1,…,x_{i−2}. ∎

So the draft's belief is correct, with the rate L_{n−1} up to logarithmic terms. The same bound holds in expectation when the blocks are uniform and independent (§3.4).

### 2.2 Skipped strings

**Setup.** For each ℓ ≥ 1 fix s_ℓ ∈ {0,1}^ℓ. Put f_s(x) = 1 if x = s_{|x|} and 0 otherwise (x nonempty). Reveal the strings in blocks ℓ = 1, 2, …. Block ℓ consists of all strings of length ℓ other than s_ℓ in lexicographic order, then s_ℓ. Let D^{(ℓ)} be the data after blocks 1,…,ℓ, so dom D^{(ℓ)} = {0,1}^{1..ℓ}.

**Theorem 2.2 (skipped strings) [proved].**
(a) P = "predict 1 at x iff every other string of length |x| is already an input of the history, else 0" has loss 0. It is deterministic, has K(P) = O(1), and is set-based.
(b) L_F(D^{(ℓ)}) ≥ K(s_1,…,s_ℓ ∣ ℓ) − c.
(c) L_F(D^{(ℓ)}) ≤ ℓ(ℓ+1)/2 + c.
(d) If s_1 s_2 s_3 … are the consecutive blocks of a Martin-Löf random ω, then L_F(D^{(ℓ)}) ≥ ℓ(ℓ+1)/2 − K(ℓ) − c_ω. For each ℓ, all but a 2^{−k} fraction of the tuples (s_1,…,s_ℓ) give L_F(D^{(ℓ)}) ≥ ℓ(ℓ+1)/2 − k − c. Since L_F is nondecreasing in the data (F2), SFI's loss along the whole reveal sequence is unbounded.

*Proof.* (b) Lemma 1.1. dom D^{(ℓ)} and ℓ are computable from each other, and given the domain the labelling determines (s_1,…,s_ℓ).
(c) Let the function machine read, for each length j, its own block of j tape bits as a guess s′_j, and answer 1 at x iff x = s′_{|x|}. It is consistent with D^{(ℓ)} with probability Π_{j≤ℓ} 2^{−j}.
(d) (F5) gives K(s_{1:ℓ}) ≥ ℓ(ℓ+1)/2 − c_ω. Then K(s_{1:ℓ} ∣ ℓ) ≥ K(s_{1:ℓ}) − K(ℓ) − c. The counting statement is the usual one: fewer than 2^{N−k} tuples have K(·∣ℓ) < N − k, where N = ℓ(ℓ+1)/2. ∎

**Remark.** dom D^{(ℓ)} is an initial segment of the length-lexicographic order. By Cor. 5.3, L_F(D^{(ℓ)}) = L_ξ(D^{(ℓ)} in length-lex order) ± c. In that order s_ℓ sits at its lexicographic place, not last. ξ's loss is O(1) in Hänni's order and ≈ ℓ(ℓ+1)/2 in length-lex order. The reveal order carries the information.

---

## 3. The draft's Thm 1 (computable reveal distribution Δ)

> Thm 1. Let C be the set of computable samplers which get to see the revealed input-output data set so far … Suppose the data-generating process samples a function f : X → Y and then reveals a sequence of input-output pairs, with the sequence of inputs sampled from a distribution Δ. Then each predictor P in C can only beat solomonoff function induction in expected log loss by at most the complexity C_Δ of sampling from the reveal sequence distribution Δ plus a constant C_P.

It is introduced for the case where "the reveal sequence distribution is simple to sample from conditional on any particular choice of function f". The proof sketch simulates Δ, which "can take into account (x_1,y_1)". There are two readings.

* **Reading A (non-peeking).** x_i ~ Δ(· ∣ h_{i−1}): the input choice sees f only through the revealed labels. Δ may use private randomness and memory independent of f. f is arbitrary.
* **Reading B (peeking).** x_i ~ Δ(· ∣ f, h_{i−1}): Δ is computable with oracle f, and C_Δ is the complexity of this conditional sampler. This is the literal reading of "simple to sample from conditional on f".

### 3.1 The proof sketch fails

**Proposition 3.1 [computed: c1, c2].** In the brief's example (X = {a,b}, f(a) = f(b) = β uniform, Δ shows a then b, P predicts y_1 uniform and y_2 = y_1), P's loss is 1 bit. The private-randomness simulator g gives each input its own simulated history, so g(a) and g(b) are independent uniform bits and g's loss is 2 bits. The shared-randomness simulator and the mixture of the two constant functions both have loss 1 bit (`c1_brief_counterexample.out`).

The sketch makes two errors.
1. With private randomness the simulator is a product over inputs, so it loses the cross-input correlations that P exploits.
2. The Jensen step averages P's prediction at x over *simulated* histories, whose labels are sampled from P. The theorem would need the average over *true* histories, whose labels are f's. In the example, the per-input loss at b is 0 bits under the true history (a, β) and 1 bit under the simulated one.

On random finite instances (X = {0,1,2}, Y = {0,1}, n = 3, non-peeking Δ, f ~ π), the private simulator's expected loss exceeded E[L_P] in 60/60 instances when P is the Bayes predictor for π, and in 55/60 when P is Bayes for a perturbed prior. It never did for random (poor) P (`c2_simulators_bayes.out`). The example does not refute the theorem: SFI itself does well there.

### 3.2 The shared-randomness simulator

**Theorem 3.2 [proved].** Let Δ (input sampler, given h) and P (label sampler, given (h,x)) be computable samplers. For every function-consistent sequence,
  M_F(D_n) ≥ 2^{−K(Δ,P)−c} · Δ(x_{1:n} ‖ y_{1:n−1}) · P(y_{1:n} ‖ x_{1:n}),
where Δ(x‖y) := Π_i Δ(x_i ∣ h_{i−1}). If the inputs are distinct, the right-hand side may be replaced by 2^{−K(Δ,P)−c} Σ_σ Δ(x_σ‖y_σ)P(y_σ‖x_σ), summed over all orders σ of D_n. Hence

  L_F(D_n) ≤ L_P + L_Δ + K(Δ) + K(P) + c,  with L_Δ := −log Δ(x‖y).

*Proof.* The function machine T uses ω as one stream of random bits for one run of the alternating process: sample x′_1 from Δ(·∣∅), y′_1 from P(·∣∅,x′_1), x′_2 from Δ(·∣h′_1), and so on. Each sampler call reads fresh consecutive bits. On query x, T runs the process until the first j with x′_j = x and outputs y′_j. It diverges if no such j appears. T's answer depends on a finite prefix of ω, so T is a function machine, and K(T) ≤ K(Δ,P) + c. If the simulated trajectory begins with x_1y_1…x_ny_n, then every x ∈ dom D_n is first visited with D_n's label (a repeated input is first visited at its first occurrence). Since the bits are fresh at each step, the probability of that beginning is Π_i Δ(x_i∣h_{i−1})P(y_i∣h_{i−1},x_i). For distinct inputs, different orders give different trajectory prefixes, hence disjoint events. Apply (F1). ∎

**Corollary 3.3 (deterministic policies) [proved].** If x_i = δ(h_{i−1}) for a computable δ (adaptive allowed), then for every f, every sampler P and every n, L_F(D_n) ≤ L_P + K(δ) + K(P) + c on every path. So in reading A with deterministic computable Δ, Thm 1 holds pathwise with C_Δ = K(δ).

**Corollary 3.4 (SFI vs Solomonoff on the joint sequence) [proved].**
  L_F(D_n) ≤ −log Σ_σ M(code(D_n in order σ)) + c ≤ −log M(code(x_1y_1…x_ny_n)) + c.
*Proof.* Same construction, with the universal monotone machine run on ω as the sampler: its output is parsed into alternating blocks x̄′, ȳ′, and T answers query x with the label after the first block x̄′ = x̄. The probability that the output extends code(D_n in order σ) is M(code(·)) by (F8)'s definition. Distinct orders give incomparable codes. ∎

So SFI's label loss is at most Solomonoff's loss on predicting *both* inputs and labels. The input part is what SFI pays for not seeing the inputs. With Thm 4.6(b) this gives L_F ≤ L_P + K(P) + L_ξ′^x + c for every sampler P, where L_ξ′^x is the universal chronological complexity of the input sequence given the labels.

### 3.3 Reading A with a computable prior: the Bayes form

**Theorem 3.5 [proved].** Let π be a computable random function: a function machine T_π that for λ-almost every ω halts on every query, with π(D) := M_{T_π}(D) = Pr[f ⊇ D]. Let f ~ π. Choose inputs by any mechanism (not necessarily computable, possibly random, possibly adaptive) that sees f only through revealed labels. Let y_i = f(x_i).
(a) On every path of positive probability, the chronological Bayes predictor B(y ∣ h, x) := π(D_h ∪ {(x,y)})/π(D_h) is the conditional law of y_i given (h_{i−1}, x_i). Its loss is L_B = −log π(D_n), and L_F(D_n) ≤ L_B + K(π) + c.
(b) For every history-aware predictor P (computable or not), E[L_P] ≥ E[L_B]. Hence E[L_F(D_n)] ≤ E[L_P] + K(π) + c, with no dependence on Δ or on P. In particular E[L_F] ≤ E[L_ξ] + K(π) + c.

*Proof.* Let R be the selector's private randomness, independent of f. The probability of f together with a history h_n is π(f)·Q(x_{1:n} ‖ y_{1:n−1})·1[f ⊇ D_n], where Q (an average over R) depends only on the revealed labels. So the posterior given h_{i−1} and x_i is π restricted to {f ⊇ D_{i−1}} and renormalised. Its predictive probability for y_i is π(D_i)/π(D_{i−1}), and the product telescopes to π(D_n). (F1) gives M_F ≥ 2^{−K(π)}π. For (b), apply Gibbs' inequality at each step, since B is the true conditional law: E[−log P(y_i∣h_{i−1},x_i)] ≥ E[−log B(y_i∣h_{i−1},x_i)]. If the right side is infinite, so is the left. ∎

[computed: c2(C): the Bayes loss equals −log π(D_n) on every path, to 2·10^{−15}, and E[L_P] ≥ E[−log π(D_n)] in all instances.]

### 3.4 Reading B: the input choice may depend on f

**Theorem 3.6 (directed information) [proved].** Let π be as in Thm 3.5, f ~ π, x_i ~ Δ(· ∣ f, h_{i−1}) for an arbitrary kernel, y_i = f(x_i). Assume the inputs and labels up to time n lie in finite sets A and B, so all entropies are finite. Let μ be the joint law, L_B := −log μ(y‖x) the chronological Bayes loss, and

  I(f → x_{1:n}) := Σ_{i=1}^n I(f ; x_i ∣ h_{i−1})

(the directed information from the function to the input choices). Then
(a) E[−log π(D_n)] − E[L_B] = I(f → x_{1:n}) − E[KL(μ(f∣h_n) ‖ π(f ∣ f ⊇ D_n))] ≤ I(f → x_{1:n});
(b) for every predictor P: E[L_F(D_n)] ≤ E[L_P] + I(f → x_{1:n}) + K(π) + c.

*Proof.* (b) follows from (a), (F1) and Gibbs (E[L_P] ≥ E[L_B]). For (a), replace f by f|_A. Write Δ(x∣f) := Π_i Δ(x_i∣f,h_{i−1}), Δ̄(x‖y) := Π_i μ(x_i∣h_{i−1}), and Δ_D(x) := E_{f′∼π(·∣f′⊇D_n)}[Δ(x∣f′)]. Then μ(h_n) = π(D_n)Δ_D(x) and μ(f∣h_n) = π(f)1[f⊇D_n]Δ(x∣f)/μ(h_n), so

  I(f; h_n) = E[log Δ(x∣f) − log Δ_D(x) − log π(D_n)].

By the chain rule, I(f;h_n) = Σ_i [I(f;x_i∣h_{i−1}) + I(f;y_i∣h_{i−1},x_i)] = E[log Δ(x∣f)/Δ̄(x‖y)] + E[L_B], because y_i is a function of (f, x_i). Subtracting gives E[−log π(D_n)] − E[L_B] = E[log Δ(x∣f)/Δ̄(x‖y)] − E[log Δ(x∣f)/Δ_D(x)]. The first term is I(f → x). In the second, given h_n the posterior is p(f) ∝ q(f)Δ(x∣f) with q = π(·∣f⊇D_n), so E_{f∼p}[log Δ(x∣f)/Δ_D(x)] = KL(p‖q) ≥ 0. ∎

[computed: c2(D): the identity holds to 3·10^{−15} on 40 random peeking instances, the inequality holds, and E[L_P] ≥ E[L_B].]

In reading A, I(f → x) = 0 and Thm 3.6 reduces to Thm 3.5.

**Theorem 3.7 (reading B of Thm 1 is false) [proved; refutes Thm 1 in reading B].** Let x_i be uniform on {0,1}^i, independent. Define f(x_{i+1}) := x_i (i ≥ 1) and f(x) := ε otherwise, and reveal x_1, x_2, …. Then:
* f is a computable random function with K(π) = O(1): the machine answers a query of length i by comparing it with tape block i and returning tape block i−1 or ε;
* given f, the reveal sequence is deterministic and computable with oracle f by an O(1) program: x_i (i ≥ 2) is the unique string of length i with f(x) ≠ ε, and x_1 = f(x_2);
* P of Thm 2.1(c) has loss 0;
* E[L_F(D_n)] ≥ E[K(x_{1:n−1} ∣ x_n)] − c ≥ H(x_{1:n−1}) − c = n(n−1)/2 − c, by Thm 2.1(a) and (F6).

So the expected gap is unbounded although C_Δ = O(1). For the same reason, no bound in terms of the algorithmic mutual information I(Δ : f) between the reveal *law* and f can hold, since I(Δ : f) ≤ K(Δ) + c = O(1) here. This answers the draft's open question ("can thm 1 be improved to a version that talks about the algorithmic mutual information of Δ and f") negatively for that reading. The quantity that works is the information between f and the *realized* inputs, I(f → x_{1:n}) = n(n+1)/2 here (Thm 3.6). That bound is tight up to the last block's n bits.

A second, one-step reading-B example with exact constants is in §5.3: E[L_F] ≥ 3m/2 − 2 while E[L_P] = m.

### 3.5 Reading A with arbitrary f: the minimax theorem

**Theorem 3.8 [proved].** Fix n. Suppose the inputs at steps ≤ n lie in a finite set A_n computable from n, and Y is finite. Let Δ be a kernel Δ(x ∣ h) (non-peeking) or Δ(x ∣ f|_{A_n}, h) (peeking), and P a history-aware predictor, both with rational values computable from their arguments. Then for **every** f : A_n → Y,

  E_{x∣f}[L_F(D_n)] ≤ E_{x∣f}[L_P] + C_dir(Δ,n) + K(P) + K(Δ) + K(n) + c,

where C_dir(Δ,n) := sup_π I_π(f → x_{1:n}) over priors π on Y^{A_n}, and C_dir = 0 for non-peeking Δ. The bound averages over f ~ F for any law F independent of the selector's private randomness. So in reading A, Hänni's Thm 1 holds up to an additive K(n) ≤ 2 log n + O(1), for finite inputs and labels at each horizon.

*Proof.* Let 𝒢 := {½G_0 + ½U}, where G_0 ranges over probability distributions on Y^{A_n} (random functions on A_n) and U is the uniform one. 𝒢 is compact and convex, and G(D) ≥ ½|Y|^{−n} for every G ∈ 𝒢. Let F_fin := {f : E_{x∣f}[L_P] < ∞}; for f ∉ F_fin the claim is trivial. Put

  Φ(G, π) := Σ_{f∈F_fin} π(f) ( E_{x∣f}[−log G(D_n)] − E_{x∣f}[L_P] ).

Φ is continuous on 𝒢 × Δ(F_fin), convex in G (−log of a linear function) and affine in π. By (F9), min_G max_π Φ = max_π min_G Φ.

For fixed π take G = ½π + ½U. Then −log G(D) ≤ 1 − log π(D), so by Thm 3.6(a) (which does not need π computable) and Gibbs,
  Φ ≤ 1 + E_π[−log π(D_n)] − E_π[L_P] ≤ 1 + E_π[−log π(D_n)] − E_π[L_B] ≤ 1 + I_π(f → x).
Hence V := min_G max_{f∈F_fin} Φ(G, δ_f) ≤ 1 + C_dir.

Computability: with rational P and Δ, F_fin is decidable and each Φ_f(G) is computable to any precision. On 𝒢 each Φ_f is Lipschitz in G_0 (in ℓ¹) with a constant computable from |Y| and n. So a search over a fine enough rational grid finds G with max_f Φ_f(G) ≤ V + 1, uniformly in (P, Δ, n). This G is a random function with rational probabilities, hence a function machine with K(G) ≤ K(P) + K(Δ) + K(n) + c. Then (F1) gives E_{x∣f}[L_F] ≤ E_{x∣f}[−log G(D_n)] + K(G) + c ≤ E_{x∣f}[L_P] + C_dir + 2 + K(G) + c. ∎

[computed: c3. For 24 non-peeking instances (random, Bayes and "copy the last label" predictors) the minimax value V was ≤ 0 (max +0.000000, attained by Bayes predictors). For peeking instances V ≤ the computed lower estimate of C_dir. A designed leak (first input = f(2)) gives V = 0.585 > 0 with C_dir ≥ 1.]

**Remarks.**
* The K(n) term arises because the minimax G depends on the horizon. Whether a single random function works for all n with a constant independent of n is **[open]** (Q1).
* Compactness needs finite A_n and Y. The infinite case is **[open]**.
* A pathwise version of reading A with only K(P) + K(Δ) is false. Take f fixed, Δ drawing independent uniform strings of lengths 1, 2, …, and P the chain predictor of Thm 2.1(c). On the (improbable) paths where f(x_{i+1}) = x_i for all i, P has loss 0 while L_F ≥ K(x_{1:n−1} ∣ x_n) − c by Thm 2.1(a). Thm 3.2 is the pathwise statement, and it pays L_Δ.

---

## 4. SFI^hist: oracle access to the previous inputs (H4)

### 4.1 Definitions

A *history-oracle function machine* T receives the list (x_1,…,x_i) and reads the shared tape ω. Its output T^ω(x_{1:i}) is the label at time i. It never sees labels, but it can recompute its own earlier labels from ω and the earlier inputs.

  M_T^hist(y_{1:n} ‖ x_{1:n}) := λ{ω : T^ω(x_{1:i}) = y_i for all i ≤ n}.

The universal one, M_H, is built as in §1.2: SFI^hist. Its loss is L_H := −log M_H(y‖x).

**Lemma 4.1 [proved].** M_T^hist is an LSC chronological semimeasure.
*Proof.* The events for distinct y_{n+1} are disjoint subsets of the event for y_{1:n}. The value at time i depends only on x_{1:i}. The events are effectively open. ∎

### 4.2 Representation theorem

**Theorem 4.2 [proved; construction computed in c4].** For every LSC chronological semimeasure ρ there is a history-oracle function machine T_ρ with M^hist_{T_ρ} = ρ exactly. T_ρ is obtained uniformly from an enumeration of ρ, so K(T_ρ) ≤ K(ρ) + c.

*Proof (interval allocation, after Zvonkin–Levin).* Nodes are z = (x_{1:k}, y_{1:k}). The parent of z is p(z) = (x_{1:k−1}, y_{1:k−1}). The family F(z) consists of the nodes with the same parent and the same x_k. Take a computable increasing sequence ρ_t ↑ ρ of finitely supported functions with dyadic values, and an enumeration z_1, z_2, … of the non-root nodes in which every node comes after its parent. Each node z gets a set S(z) ⊆ [0,1), a finite union of dyadic intervals, initially empty, with S(root) = [0,1).

At stage t, process z_1,…,z_t in order. Let free(z) := S(p(z)) ∖ ⋃_{z′∈F(z)} S(z′) (z itself included). Add to S(z) a part of free(z) of measure min(ρ_t(z) − λ(S(z)), λ(free(z))) when this is positive.

Invariants: (I1) S(z) ⊆ S(p(z)); (I2) the members of a family are pairwise disjoint; (I3) λ(S_t(z)) ≤ ρ_t(z); (I4) S_t(z) ⊆ S_{t+1}(z). (I1), (I2) and (I4) hold by construction. (I3) holds because the amount added never exceeds ρ_t(z) − λ(S(z)) and ρ_t is increasing.

Limit: let S(z) := ⋃_t S_t(z). We show λ(S(z)) = ρ(z) by induction along the enumeration. For the root, λ(S) = 1 ≥ ρ(ε‖ε) ≥ Σ_{z∈F} ρ(z) for every family F of its children. For z with parent p, after z is processed at stage t,
  λ(S_t(z)) = min(ρ_t(z), λ(S_t(p)) − Σ_{z′∈F(z)∖z} λ(S_t(z′))) ≥ min(ρ_t(z), λ(S_t(p)) − Σ_{z′∈F(z)∖z} ρ(z′)),
using (I1), (I2) and (I3). As t → ∞, ρ_t(z) → ρ(z) and λ(S_t(p)) → λ(S(p)) ≥ Σ_{z′∈F(z)} ρ(z′) (by the induction hypothesis and the semimeasure inequality). So the lim inf is ≥ ρ(z), and (I3) gives equality.

Machine: T_ρ^ω(x_{1:k}) first recomputes y_i := T_ρ^ω(x_{1:i}) for i < k. It then searches for t and y with ω ∈ S_t((x_{1:k}, y_{1:k−1}y)), which depends on a finite prefix of ω, and outputs y. By (I2) at most one y is ever found. By (I1), {ω : T_ρ^ω(x_{1:i}) = y_i ∀i ≤ n} = S((x_{1:n},y_{1:n})), whose measure is ρ. ∎

[computed: c4 runs the construction with exact rational arithmetic on a random dyadic chronological semimeasure (X = {0,1}, Y = {0,1,2}, depth 3, 6 stages, 237 stage–node pairs where children's approximations ran ahead of the parent's). Every node ends with λ(S(z)) = ρ(z) exactly. There were no nesting, disjointness or growth violations. Monte Carlo runs of the machine match ρ to within 0.0056.]

**Corollary 4.3 (H4) [proved; ξ's definition known, unverified].**
(a) M_H ≥ 2^{−K(ρ)−c}ρ for every LSC chronological semimeasure ρ. Since M_H is itself one (Lemma 4.1), 2^{−c}ξ ≤ M_H ≤ 2^{c}ξ: SFI^hist and Hutter's ξ agree up to multiplicative constants, with inputs as actions and labels as percepts.
(b) For every computable sampler (or LSC predictor) P that sees the history, and **every** sequence (adversarial, non-computable): L_H ≤ L_P + K(P) + c.
(c) L_H ≤ L_F(D_n) + c on every sequence and in every order (Lemma 1.2).

### 4.3 Variants of the oracle

In this subsection inputs are distinct (the case of interest for function learning, and needed for "set determines count").

* **SFI^pairs:** the hypothesis sees the previous inputs *and labels*, T^ω(h_{i−1}, x_i).
* **SFI^count:** it sees only i, T^ω(i, x_i).
* **SFI^set:** it sees the set {x_1,…,x_{i−1}}, T^ω({x_{<i}}, x_i).

**Proposition 4.4 [proved].**
(a) SFI^pairs and SFI^hist define the same semimeasures. Given a pairs-machine T, put T′^ω(x_{1:i}) := T^ω(x_1, T′^ω(x_1), …, x_{i−1}, T′^ω(x_{<i}), x_i). On the event that T′ outputs y_{1:n}, the recursion reproduces the true history, so T outputs y_{1:n}; the converse holds by induction. Conversely, a hist-machine is a pairs-machine that ignores labels. So SFI^pairs ≍ ξ, which is "trivially SI-like" as the task says.
(b) SFI^count is SFI on time-stamped inputs (i, x_i). It dominates Solomonoff's M on the label sequence alone: L_count ≤ −log M(ȳ_1…ȳ_n) + c (the hypothesis outputs the i-th block of the universal monotone machine's output).
(c) SFI ≼ SFI^count ≼ SFI^set ≼ SFI^hist, where ≼ means that the left universal semimeasure is at most 2^c times the right one on every sequence (each oracle is computable from the next; the count is the size of the set).

**Proposition 4.5 (the hierarchy is strict) [proved; lemma in (iii) computed in c6].**
(i) *SFI vs SFI^count.* For every set S of n ≥ 2 strings there is an order such that, with labels y_i = [i even], L_F ≥ n − log(n+1) − c while L_count ≤ c.
(ii) *SFI^count vs SFI^set.* On the chain of Thm 2.1(b), L_count ≥ L_{n−1} − K(ℓ_n) − K(n) − c_ω while L_set ≤ c.
(iii) *SFI^set vs SFI^hist.* For every set S of n ≥ 2 strings there is an order such that, with labels y_1 = ε and y_i = x_{i−1}, L_set ≥ log n! − log n − c while L_H ≤ c.

*Proof.* (i) L_F depends only on the set D. By Lemma 1.1, L_F ≥ K(A ∣ S) − c, where A = {x_i : i even} has ⌊n/2⌋ elements. Choose A ⊆ S with K(A∣S) ≥ log C(n, ⌊n/2⌋) − 1 ≥ n − log(n+1) − 1, and an order placing A at the even positions. The deterministic hypothesis g(i,x) = [i even] gives L_count ≤ c.
(ii) Lemma 2.0 with time stamps: ν(z ∣ x, n) := λ{ω : U^ω(n, x) = z_1, U^ω(n−1, z_1) = z_2, …, U^ω(1, z_{n−1}) = ε}. For fixed ω the chain is determined by iteration, so Σ_z ν ≤ 1. Hence L_count ≥ K(x_{1:n−1} ∣ x_n, n) − c ≥ K(x_{1:n−1}∣x_n) − K(n) − c′, and the proof of Thm 2.1(b) finishes. SFI^set: "output the longest element of the set, or ε if it is empty" is correct because lengths increase.
(iii) Fix S and ω. An order σ is consistent with U^ω iff U^ω(∅, x_1) = ε and U^ω({x_{<i}}, x_i) = x_{i−1} for i ≥ 2. Backward reconstruction: x_n determines x_{n−1} = U^ω(S∖{x_n}, x_n), which determines x_{n−2}, and so on. So at most n orders are consistent with one ω, and ν_S(σ) := M_set(labels of σ ‖ σ) satisfies Σ_σ ν_S(σ) ≤ n. Since ν_S/n is LSC uniformly in S, (F4) gives L_set ≥ K(σ∣S) − log n − c. Choose σ with K(σ∣S) ≥ log n! − 1. The predictor "y_i = x_{i−1}" gives L_H ≤ c. ∎

[computed: c6 finds, by exhaustive maximum-clique search over the compatibility graph of orders, that at most n orders can be consistent with one set-hypothesis for n = 2,…,5, and that n is attained.]

### 4.4 "As good as SI": comparison with Solomonoff's M on x_1y_1x_2y_2…

Let M be as in (F8), applied to code(x_1y_1…). Write

* L_M^joint := −log M(code(x_1y_1…x_ny_n));
* L_M^x := −Σ_i log [M(code(h_{i−1})x̄_i)/M(code(h_{i−1}))] (input loss);
* L_M^y := −Σ_i log [M(code(h_{i−1})x̄_iȳ_i)/M(code(h_{i−1})x̄_i)] (SI's conditional label loss, unnormalised).

So L_M^joint = L_M^x + L_M^y. Let ξ′ be a universal LSC chronological semimeasure for inputs given previous labels (inputs as percepts), with L_ξ′^x := −log ξ′(x_{1:n} ‖ y_{1:n−1}).

**Lemma B (block codes) [proved].** Let ν be an LSC semimeasure on alternating block sequences (x_1, y_1, x_2, …; a sequence may end after an x-block). Then ν_bin(z) := Σ_{b∈B(z)} ν(b) is an LSC semimeasure on {0,1}*, where B(z) is the set of block sequences b with code(b) ⊒ z and code(b⁻) ⋣ z (b⁻ is b without its last block). Moreover ν_bin(code(b)) = ν(b). Hence M(code(b)) ≥ 2^{−K(ν)−c}ν(b).

*Proof.* Since codes are prefix-free, code(b′) ⊒ code(b) forces b′ to extend b blockwise, so B(code(b)) = {b}. Each b ∈ B(z0) ∪ B(z1) either lies in B(z) with code(b) ≠ z, or is a one-block extension of some b′ ∈ B(z) with code(b′) = z. The elements of B(z) with code ≠ z go to exactly one of B(z0), B(z1). For b′ with code(b′) = z, Σ_β ν(b′β) ≤ ν(b′). So ν_bin(z0) + ν_bin(z1) ≤ ν_bin(z). ∎

**Theorem 4.6 [proved].** On every sequence:
(a) L_ξ ≤ L_M^joint + c and L_ξ′^x ≤ L_M^joint + c;
(b) L_M^joint ≤ L_ξ + L_ξ′^x + c;
(c) L_ξ − L_M^y ≤ L_M^x + c and L_M^y − L_ξ ≤ L_ξ′^x − L_M^x + c;
(d) if x_i = δ(h_{i−1}) for a computable δ, then L_M^y ≤ L_ξ + K(δ) + c and L_M^x ≤ L_ξ + K(δ) + c.

*Proof.* (a) ρ(y‖x) := M(code(x_1y_1…x_ny_n)) is an LSC chronological semimeasure: Σ_y M(z x̄ ȳ) ≤ M(z x̄) ≤ M(z) because M is a semimeasure and {ȳ} is prefix-free. The same holds with the roles of x and y exchanged. (b) ν(x_1y_1…) := ξ′(x‖y)·ξ(y‖x), defined also on sequences ending with an x-block, is an LSC semimeasure on block sequences: summing over y_n uses ξ's inequality, and summing over x_n uses ξ′'s. Apply Lemma B. (c) Combine (a), (b) and L_M^joint = L_M^x + L_M^y. (d) The deterministic input predictor gives L_ξ′^x ≤ K(δ) + c and L_M^x ≥ 0, then use (c). The second bound uses L_M^x ≤ L_M^joint and (b). ∎

**Known results and the open direction.**
* [known, **unverified** beyond the abstract and search snippets] T. Lattimore, M. Hutter, V. Gavane, "Universal Prediction of Selected Bits", ALT 2011, LNCS 6925, pp. 262–276, doi:10.1007/978-3-642-24412-4_22, arXiv:1107.5531. The abstract says that online classification can be cast as sequence prediction of input/target pairs. It says the normalised Solomonoff measure "can detect any recursive sub-pattern (regularity) within an otherwise completely unstructured sequence", while "the unnormalised version can fail to predict very simple recursive sub-patterns". The paper's motivating example: even bits repeat the preceding odd bit. A later paper attributes to their Thm 10 the convergence M_norm → 1 on selected bits. That is convergence, not a bounded loss.
* In our terms, take X = Y = {0,1} and labels y_i = x_i. Then ξ's loss is O(1) on every input sequence (the copy predictor). If the "failure" of unnormalised M means an unbounded label loss L_M^y on some input sequence, then L_M^y ≤ L_ξ + O(1) is false in general. This is consistent with Thm 4.6(c), whose right-hand side contains L_ξ′^x, large for non-computable inputs. Not checked against the paper.
* Whether L_ξ ≤ L_M^y + O(1) on every sequence is **[open]** (Q3). Thm 4.6(c) bounds the excess by M's input loss.

**Verdict on H4.** In the precise sense of Cor. 4.3, SFI^hist is (up to constants) the universal chronological semimeasure. It is as good as every computable history-aware predictor on every sequence, and its label loss is at most Solomonoff's joint loss on x_1y_1x_2y_2… plus a constant (Thm 4.6(a)). Equality with SI's *conditional* label predictions up to an additive constant holds only up to the input-loss terms of Thm 4.6(c). It fails in one direction for unnormalised SI if LHG's failure means unbounded loss, and it is open in the other.

---

## 5. What SFI can and cannot exploit

### 5.1 Order and locality

**Proposition 5.1 [proved].** L_F depends only on the set D_n (§1.2), so SFI cannot use the order in which data arrive. It also cannot use the identity of the other inputs: each hypothesis answers each query alone, and the only coupling between queries is the shared tape.

### 5.2 Sandwich bounds for individual data sets

**Theorem 5.2 (sandwich) [proved].** For a function-consistent D with distinct inputs, write D_σ for D in order σ. Let KH(x_{1:n}) := min{|p| : U(p, x_i) = ⟨x_1,…,x_{i−1}⟩ for all i ≤ n} (U universal prefix machine with input) be the complexity of recovering each input's list of predecessors from the input. Then

  max_σ L_ξ(D_σ) − c ≤ L_F(D) ≤ min_τ [L_ξ(D_τ) + KH(x_τ)] + c.

*Proof.* The left inequality is Lemma 1.2. For the right one, given p, the function machine on query x computes the list ⟨x′_1,…,x′_k⟩ = U(p, x) and outputs U_H^ω(x′_1,…,x′_k, x), where U_H is the universal history-oracle machine of §4.1. On D_τ it outputs U_H^ω(x_{τ,1:i}) at x_{τ,i}, so it is consistent with D with probability M_H(y_τ‖x_τ) ≥ 2^{−c}ξ(y_τ‖x_τ) (Cor. 4.3). It costs |p| + c bits (F1). ∎

**Corollary 5.3 (initial segments) [proved].** If dom D = {e_1,…,e_N} for a computable injective sequence e, then |L_F(D) − L_ξ(D in e-order)| ≤ K(e) + c, and L_ξ(D_σ) ≤ L_ξ(D in e-order) + K(e) + c for every σ. So the e-order is the worst order for ξ, up to K(e) + c.
*Proof.* KH(e-order) ≤ K(e) + c (find x's index by enumerating e, then list its predecessors). Combine with Thm 5.2. ∎

This covers the skipped-string example (all strings of length ≤ ℓ in length-lex order) and the brief's cyclic permutation (all strings of length n in lex order, with K(e) = K(n) + c). In both, SFI's loss equals ξ's loss in the canonical order up to K(n) + c.

**Gap bounds.** For an order σ put gap(σ) := L_F(D) − L_ξ(D_σ). Then:
* max_τ L_ξ(D_τ) − L_ξ(D_σ) − c ≤ gap(σ) — at least the advantage of σ over the worst order [proved];
* gap(σ) ≤ KH(x_σ) + c ≤ K(x_{1:n−1}) + c′ [proved];
* gap(σ) ≤ L_ξ′^x(x_σ‖y_σ) + c — at most the chronological complexity of the input sequence given the labels (Cor. 3.4 and Thm 4.6(b)) [proved].

### 5.3 The upper term is needed

Identify {0,1}^m with F = GF(2^m), using the polynomial basis modulo the lexicographically least irreducible polynomial of degree m, which is computable from m. For a ≠ b ∈ F and r ∈ F let D_{abr} := {(a, r), (b, r + ab)}.

**Lemma 5.5 (character-sum bound) [proved; computed in c5].** For every partial G : F → F,
  N(G) := #{(a,b) : a ≠ b, G(a), G(b) defined, G(a) + G(b) = ab} < 2^m + 2^{3m/2}.

*Proof.* Extend G to a total function and include a = b; neither decreases the count. Let χ_u(z) = (−1)^{Tr(uz)}. Then Σ_u χ_u(z) = 2^m·1[z = 0], so
  N ≤ 2^{−m} Σ_u Σ_{a,b} χ_u(G(a))χ_u(G(b))χ_u(ab).
The u = 0 term is 2^{2m}. For u ≠ 0, H_{ab} := χ_u(ab) satisfies HHᵀ = 2^m I, because Σ_b χ_u((a+a′)b) = 2^m·1[a = a′]. So |vᵀHv| ≤ |v|²·2^{m/2} = 2^{3m/2} for v_a := χ_u(G(a)) ∈ {±1}. Hence N ≤ 2^{−m}(2^{2m} + (2^m − 1)2^{3m/2}) < 2^m + 2^{3m/2}. ∎

[computed: c5 verifies HHᵀ = 2^m I for m = 2,…,6 and all u ≠ 0. Exhaustive search gives max_G N(G) = 8 for m = 2 and 22 for m = 3, against bounds 12 and 30.6. Local search for m = 4,…,7 found at most 56, 142, 322, 740, against bounds 80, 213, 576, 1576.]

**Theorem 5.4 [proved].**
(a) In both orders, L_ξ(D_{abr}) ≤ m + c (c independent of m).
(b) L_F(D_{abr}) ≥ K(a,b,r ∣ m) − 3m/2 − 1 − c. So for all but a 2^{1−k} fraction of triples, L_F ≥ 3m/2 − k − c′ ≥ max_σ L_ξ + m/2 − k − c″.
(c) For uniform (a, b, r) with a ≠ b: E[L_F(D_{abr})] ≥ 3m/2 − 2 for every m ≥ 1.

*Proof.* (a) Let P predict y_1 uniformly on {0,1}^{|x_1|} and then y_2 = y_1 + x_1x_2. In order (a,b) its loss is m. In order (b,a) it predicts r = (r + ab) + ba, again with loss m, since ab = ba and the characteristic is 2. Apply Cor. 4.3(b).
(b) Σ_{a≠b, r} M_F(D_{abr}) = E_ω #{(a,b) : a ≠ b, U^ω(a) + U^ω(b) = ab} ≤ max_G N(G) < 2^{3m/2+1}. Here r = U^ω(a) is determined, and outputs outside {0,1}^m do not count. So M_F(D_{abr})·2^{−3m/2−1} is a discrete semimeasure on triples, LSC uniformly in m. Apply (F4).
(c) Jensen: E[L_F] ≥ −log E[M_F(D)] ≥ log(2^{2m}(2^m − 1)) − log 2^{3m/2+1} ≥ 3m/2 − 2. ∎

**Interpretation.** In every order, ξ sees the first input when predicting the second label, and the second label depends on it. SFI's hypotheses never see it. So L_F can exceed ξ's loss in the *worst* order by ≥ m/2. SFI's deficit is not only the information carried by the order.

Viewed as a reading-B process (f defined from random (a, b, r), inputs (a, b)), E[L_F] ≥ 3m/2 − 2, while P has loss m and K(Δ) = O(1). This is a second refutation of reading B with exact constants. It is consistent with Thm 3.6: f determines {a, b}, so I(f → x) = H(x_1) − H(x_1 ∣ f) + H(x_2 ∣ h_1) = m − 1 + log(2^m − 1) ≈ 2m (given f, which of the two points comes first is a fair coin).

### 5.4 Expected-value characterisation

**Theorem 5.6 [proved].** For sources f ~ π (a computable random function) and inputs x_i ~ Δ(· ∣ f, h_{i−1}), under the finiteness assumption of Thm 3.6:

  −c ≤ E[L_F(D_n)] − E[L_ξ] ≤ I(f → x_{1:n}) + K(π) + c.

For non-peeking sources the gap is at most K(π) + c. The upper bound is tight up to the last input's entropy: in Thm 3.7, E[L_F] − E[L_ξ] ≥ n(n−1)/2 − c while I(f → x) = n(n+1)/2.

*Proof.* The lower bound is Lemma 1.2. The upper bound is Thm 3.6(b) with P = ξ (ξ is a semimeasure, so Gibbs applies). For tightness, ξ's loss is ≤ K(P) + c = O(1) for the chain predictor. ∎

For arbitrary (non-computable) f, Thm 3.8 gives the analogous statement against every computable P, with C_dir and an extra K(n).

**Answer to item 3, in one paragraph.** SFI can exploit any structure of the labels that a single random function (with shared randomness) can express: dependence of each label on its own input, and correlations between labels through shared randomness. It cannot exploit the order of the data (Prop. 5.1), and it cannot let a label depend on which other inputs are present (Thm 5.4). In expectation, the loss this costs relative to the history-aware optimum (SFI^hist ≍ ξ, or the Bayes predictor) is at most the directed information I(f → x_{1:n}) that the input choices carry about f beyond the revealed labels, plus K(π) (Thm 5.6). That bound is attained up to lower-order terms. On individual sequences, the cost lies between "advantage of the actual order over the worst order" and "complexity of recovering the history from each input" (Thm 5.2). The two coincide up to K(e) for initial segments of a computable enumeration (Cor. 5.3), and they can differ by ≥ m/2 (Thm 5.4).

---

## 6. Open questions

* **Q1.** In Thm 3.8 (reading A, arbitrary f), can K(n) be replaced by a constant, as Hänni's Thm 1 asserts? Does the theorem extend to infinite input or label sets at a horizon?
* **Q2.** Is there an individual-sequence analogue of Thm 3.6, e.g. L_F(D) ≤ L_ξ(D_σ) + I(x_σ : y_σ) + O(log), with algorithmic mutual information? The chain and the GF(2^m) example are consistent with such a bound. [conjecture, not tested]
* **Q3.** Is L_ξ ≤ L_M^y + O(1) on every sequence, for unnormalised or normalised M?
* **Q4.** Do the lower bounds of §2, §4.5 and §5.3 hold for SFI with per-step normalisation?
* **Q5.** Is L_M^joint = L_ξ + L_ξ′^x ± O(1)? Only ≤ is proved (Thm 4.6(b)). By analogy with symmetry of information, we expect a logarithmic correction in general; unproved.
* **Q6.** In Thm 5.4 the true growth of max_G N(G) seems to be about 2^{1.35m} (local search, c5). That would give a gap of about 0.65m rather than m/2. The exponent is not determined here.

---

## 7. Relation to the brief and to Hänni's text

* **H3, chain:** proved (Thm 2.1), with rate L_{n−1} ± O(log). Hänni's predictor uses only the set of revealed pairs.
* **H3, skipped strings:** proved (Thm 2.2), via incompressibility as Hänni indicated.
* **H3, Thm 1:**
  * the proof sketch is invalid (Prop. 3.1);
  * reading B is false (Thm 3.7, Thm 5.4);
  * reading A is true up to K(n) for finite settings (Thm 3.8), and true pathwise for deterministic policies (Cor. 3.3);
  * with a computable prior, a Δ-free and P-free form holds (Thm 3.5);
  * the correct extra term for f-dependent input choice is the directed information (Thm 3.6, tight);
  * the algorithmic mutual information of the law Δ with f is not the right quantity (Thm 3.7).
* **H4:** proved in the form of Cor. 4.3, with the comparison to SI in Thm 4.6 and the variants in Props. 4.4 and 4.5.
* **"Kolmogorov vs semimeasure versions"** (Hänni's §2.2): not addressed here, except that the program-mixture form of SFI^hist with *monotone* programs is M_H by definition (the tape prefix is the program). With prefix-free deterministic programs, labels that are random bits cost an extra ≈ K(n) [proof sketch: a prefix-free program that outputs n random labels must encode n]. That question belongs to the foundations track.

---

## Verification log

All scripts are in `checks/`, run with `python3` (3.11, numpy 2.4.6, scipy 1.17.1). Outputs are saved as `checks/<name>.out`.

| Script | Seed | What it checks | Result |
|---|---|---|---|
| `c1_brief_counterexample.py` | 0 (exact) | Prop. 3.1: losses of P, the private simulator, the shared simulator and the constant-function mixture in the brief's {a,b} example, in exact rationals. | P: 1 bit; private: 2 bits; shared: 1; mixture: 1. Per-input loss at b: 0 (true history) vs 1 (simulated). |
| `c2_simulators_bayes.py` | 20261011 | (A) Thm 3.2 on 40 random instances: G(D) ≥ Δ·P on all consistent paths; G(D) ≥ Σ_σ for distinct inputs; G is a function semimeasure. (B) private-simulator violations of "E[sim loss] ≤ E[L_P]". (C) Thm 3.5: Bayes loss = −log π(D_n) pathwise; E[L_P] ≥ E[−log π(D)]. (D) Thm 3.6 identity and inequality on 40 peeking instances. | (A) min margins 1.1e−5 and −2.8e−17 (rounding); semimeasure max −1.1e−5. (B) violations 60/60 (Bayes P), 55/60 (perturbed Bayes), 0/60 (random P). (C) deviation 1.8e−15; min E[L_P] − E[−log π] = −0.0000 (equality for Bayes P). (D) identity error 2.1e−15; max (lhs − I_dir) = −0.015; min E[L_P] − E[L_B] = 1.69. |
| `c3_minimax.py` | 7 | Thm 3.8: minimax value V by SLSQP (6 restarts) on 24 non-peeking instances (3 predictor kinds), 4 random peeking instances and 1 designed leak; lower estimates of C_dir by Nelder–Mead. | Non-peeking max V = +0.000000 (V = 0 for Bayes P, negative otherwise). Peeking: V ≤ C_dir estimate; designed leak V = 0.585, C_dir ≥ 1. |
| `c4_chrono_representation.py` | 11 | Thm 4.2 construction with exact rationals; invariants (I1), (I2), (I4); exactness of the limit; Monte Carlo of the machine. | 259 nodes, all exact; 0 violations; MC deviation 0.0056 (25 000 samples per input sequence). |
| `c5_gf_agreement.py` | 5 | Lemma 5.5: HHᵀ = 2^m I (m ≤ 6); exact max N for m = 2, 3; local search for m = 4,…,7; implied E[L_F] bounds. | All below the bound; exact maxima 8 and 22; implied E[L_F] ≥ 2.585 (m=2), 4.348 (m=3). |
| `c6_set_order_lemma.py` | 0 (exact) | Lemma in Prop. 4.5(iii): max number of orders consistent with one set-hypothesis, by exhaustive maximum-clique search, n = 2,…,5. | Equal to n in each case (bound attained). n = 6 was too slow for the simple clique search and was not run. |

**Not machine-checked.** All statements involving K, M, ξ, M_F (uncomputable) are proved by hand. The scripts check only the finite combinatorial or analytic steps, as listed. Proofs were written once by this track and have not been refereed.

**Literature checks** (WebSearch snippets only; arxiv.org, hutter1.net, anu.edu.au and mlanthology.org did not resolve):
* LHG 2011: bibliographic data and abstract wording confirmed in snippets; theorem statements not seen.
* Hutter's ξ: definition and universality confirmed in snippets of the 2000 report (arXiv cs/0004001); the 2005 book's section numbers not seen.
* Wood–Sunehag–Hutter, "(Non-)Equivalence of Universal Priors" (arXiv:1111.3854; Solomonoff 85th Memorial Conference, LNCS): exists. Relevant only as background on equivalence of universal priors; not used in proofs.
* Coding theorem, Levin–Schnorr, Zvonkin–Levin, Sion: standard and cited from memory, with theorem numbers unverified.

**Assumptions to flag to the writers.**
* (i) All SFI lower bounds use the semimeasure convention.
* (ii) Theorems 3.6, 3.8 and 5.6 need finite input and label sets at the horizon, or finite entropies.
* (iii) Thm 3.8 needs rational-valued (exactly computable) P and Δ for the search step. For merely lower-semicomputable samplers the minimax G still exists, but its computability, and so the K(P) + K(Δ) bound, is not established here.
