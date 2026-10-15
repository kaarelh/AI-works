# Track "split": independent check of the post-referee iid results (2026-10-13)

*The synthesis `notes-final.md` (§5.0) asks that the post-referee results of the iid sub-track that go into the paper's main text get one independent check before publication. This is that check. For each item it asks: is the statement exactly what the proof proves (hypotheses, quantifiers, constants)? Is the proof complete and correct? Key steps were re-derived by hand, and new seeded code in `iid/verify_code/` recomputes the numerical claims and small exact cases without importing or reading the record's scripts. No record was edited.*

* **Sources read.**
  * `iid/notes-final.md`, in full: the statements and proofs of the items below, and the definitions, lemmas and theorems they use (Defs 1.1–1.3, Remark 1.4, Lemmas 2.1–2.2, Thms 3.1, 4.1(i), Prop 4.4(b), Prop 5.1(a),(b), Prop 7.3(i)–(iii), §9, §11, the verification log).
  * `iid/referee-B.md`, issues B1 and b3 (the proposals that became Prop 3.3 and Thm 4.1(iv′)).
  * The synthesis `notes-final.md`: §2 (Theorem A, Corollary A′), §5.0, §8; and `final-check.md`, for the way these items are quoted.
  * Paper 2: `sections/split.tex` and `sections/app-split.tex` (`thm:split:private` and its proof), to check the claim that Prop 3.3 extends `thm:split:private`(iv) to λ = 1.
  * The record's scripts were not read, except the class definitions of i4 (its docstring and setup lines), i8's re-typed copy of the i1 class, and the header of referee B's rB6, which were needed to recompute the quoted numbers in the same classes.
* **Code.** `iid/verify_code/v1`–`v6`, Python 3.11.15, numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0. Each is deterministic or seeded, and its output is saved next to it as a `.out` file. §3 lists what each one checks.
* **Notation** is that of `iid/notes-final.md` ("the record"). "Item" means one of the eleven results the brief lists.

---

## 0. Verdicts

| item | verdict | in one line |
|---|---|---|
| Prop 3.3 (every λ ≥ 1, every input rule, PQ or FR: eventually ν-equivalent on the run) | **verified** | Proof complete. Two wording points for the paper (§1.1). |
| Thm 4.1(iv′) (free-exponent bound) | **verified** | Holds for every λ > 0 and every n. Its two displayed corollary forms need λ ≥ 1 (s = 1/λ ≤ 1); the theorem's standing assumption λ > 1 covers this. |
| Thm 4.1(v) (uniform in time) | **verified** | Constants and the sufficient n₀ re-derived. |
| Prop 3.4(b) (λ = cn, c < c*: cn-MAPs = E₀ eventually) | **verified** | |
| Prop 3.4(c) (λ = cn, every countable Kraft class: cn-MAPs eventually in argmin(cℓ + R)) | **verified** | Elsewhere the record and the synthesis say "recovers iff c < c*"; the proved statement is "for c < c*; fails for c > c*; c = c* not covered" (§1.3). |
| Prop 5.1(b′) (λ = 1 recovery-time bracket) | **verified** | Bound P(n) ≤ 2^{k+1}/n² holds uniformly in D; no violation on any scanned n; every certified n_rec lies in the bracket. |
| Remark 4.5 (length bound attained) | **verified** | "Integers k and λ" should read "an integer k and a real λ > 1" (§1.5). |
| Remark 4.7 (λ = 1 needs Σ2^{-sℓ} < ∞) | **verified with correction** | Its necessity claim is not proved, and it is false for (iv′) as stated, with the exponent chosen per program. "Z(s) = ∞ in C_k" is false in Prop 5.1's finite-D setting. "No bound in (ℓ₀, γ, ε) exists in C_k" contradicts Prop 5.1(b′); the class that shows it is C_{k,M}. Corrected statement in §1.6. |
| Lemma 8.1(iv) (excess k − 7) | **verified** | |
| Prop 7.3(iii′) (PQ, same class: the coin is eventually the unique MAP for every λ) | **verified** | |
| Prop 7.3(v) (finite class, λ_n/√(n log log n) → ∞, λ_n = o(n): MAPs in P₀; sharp) | **verified** | Uses the Hartman–Wintner LIL (known). |
| Cor 6.1(vi) (frozen, finite domain) | **verified with correction** (wording) | The proved bound (7/8)^64 and the computed table hold. The exact values are 0.2554, 0.2554, 0.2040, 0.5664. The "penalised empirical rate" sentence describes the best program with the true f, not every λ-MAP (§1.10). |

**What the paper may state as proved.** Every item above, in the forms given in §1. For Remark 4.7, only the corrected form of §1.6. Three sentences of Remark 4.7, as written, must not be stated: that the λ = 1 bound "needs" Σ_π 2^{-sℓ(π)} < ∞; that Z(s) = ∞ in C_k; and that no bound in terms of (ℓ₀, γ, ε) exists in C_k. The same applies wherever the synthesis quotes them: §2 "What Theorem A says about λ", the §8 row A-λ1, and iid §0 item 4 and the §5 table row "finite-sample failure bound".

---

## 1. Item by item

### 1.1 Prop 3.3: identification on the run, every λ ≥ 1, any input rule, PQ or FR — **verified**

*Statement as checked.* C is countable with Kraft sum ≤ 1 and contains π_ν of length k whose kernel equals ν at the queried inputs. Inputs come from any rule that fixes x_{n+1} before y_{n+1} is drawn. Labels are fresh per query, or frozen on distinct inputs, in which case the process is indexed by distinct inputs. K is the random set of π with Σ_i g_i(π) < ∞, where g_i = Hel(ν(·|x_i), ν_π(·|x_i)). Fix λ ≥ 1. Then almost surely: (a) MAP lengths are bounded uniformly in n; (b) eventually every λ-MAP is in K; (c) Π_λ(C∖K | data) → 0.

*Proof re-derived.*
* **(a).** J_λ(π̂) ≤ J_λ(π_ν), and ν_{π_ν}(data) = ν(data). These give log Λ_n(π̂) ≥ λ(ℓ(π̂) − k). If ℓ(π̂) > L ≥ k, then λ ≥ 1 and ℓ − k > 0 give log Λ_n(π̂) ≥ ℓ(π̂) − k. Hence 2^{-ℓ(π̂)}Λ_n(π̂) ≥ 2^{-k} and Z^L_n ≥ 2^{-k}.
  * Z^L is a nonnegative supermartingale under every such rule. The one-step factor is E[Λ_{n+1}/Λ_n | past, x_{n+1}] = Σ_{y:ν>0} ν_π(y|x_{n+1}) ≤ 1, in PQ and in FR. In FR the next distinct input is new, and its frozen label is independent of the past with law ν(·|x).
  * Ville gives P[∃n: Z^L_n ≥ 2^{-k}] ≤ 2^k t_L. Z^L_n is pathwise nonincreasing in L, so these events decrease in L and their intersection is null.
  * This is the only place where Paper 2's proof of `thm:split:private`(iv) used λ > 1: there, its part (i) confined the MAPs to a finite set. The replacement is correct.
* **(b).** Given the past and x_{n+1}, E√(Λ_{n+1}/Λ_n) = Σ_{y:ν>0} √(ν ν_π) = 1 − g_{n+1}, with g_{n+1} fixed before y_{n+1} is drawn.
  * If some g_i = 1, then Λ is 0 from then on, a.s.
  * Otherwise M_n = √Λ_n / ∏(1 − g_i) is a nonnegative martingale for the filtration (data_n, x_{n+1}), so it converges a.s. On {Σg_i = ∞}, ∏(1 − g_i) ≤ e^{-Σg_i} → 0, so Λ_n → 0.
  * For each fixed π, a.s. [π ∉ K ⇒ Λ_n(π) → 0]. A countable intersection gives this for all π at once, even though K is random.
  * On the event of (a) the MAPs lie in the finite set {ℓ ≤ L₀}. A MAP has log Λ_n ≥ −λk, and each π ∉ K in that set eventually has Λ_n < 2^{-λk}.
* **(c).** The normaliser, divided by ν(data), is at least 2^{-λk}Λ_n(π_ν) = 2^{-λk}. The tail is at most Z^L_n, since 2^{-λℓ} ≤ 2^{-ℓ}. Choose t_{L_j} ≤ 4^{-j}; Ville and Borel–Cantelli give sup_n Z^{L_j}_n < 2^{-j} for all large j. Correct.
* **Special cases.**
  * PQ, i.i.d. inputs: Hel(P, Q) > 0 iff Q ≠ P, also for a sub-probability Q (Cauchy–Schwarz with equality only for Q = P). So π ∉ E has i.i.d. g_i ∈ [0, 1] with mean Hel_μ(π) > 0, and Σg_i = ∞ a.s. by the strong law. Hence K = E a.s.
  * FR, infinite support on a countable X: every atom is eventually queried, and the nonnegative sum can be rearranged, so K = {π : Σ_{x∈supp μ} Hel_x < ∞}.
  * FR, finite support: K = C, and the statement is trivial.
* **The claim about Paper 2.** `thm:split:private`(iv) at λ = 1 follows. Its hypotheses (distinct inputs, π_ν equal to ν everywhere) are a case of Prop 3.3. Its proof uses (i) and (ii) only to confine the MAPs and to bound the tail, and (a) and Z^L do both jobs.

*Code* (v1). The Kakutani identity holds on 10⁵ random kernel pairs, sub-probabilities and zeros included: largest error 3.3·10⁻¹⁶. M_n has mean 0.9986 ± 0.0040 under an adaptive rule. The Ville step (a) holds under a repeating adaptive rule at λ = 1: 0.127, 0.017 and 0.000 against 2^k t_L = 0.25, 0.062 and 0.016. A full illustration uses adversarial rules in FR (sparse odd queries) and in PQ (repeats), at λ ∈ {1, 1.5}, with K decided analytically for the limit of each rule. The fraction of runs with all MAPs in K rises to 0.985–0.99 by n = 4000. The mean Π_λ(C∖K) falls to 0.010–0.028. The largest MAP length is at most 7.

*Wording points for the paper* (not errors in the proof).
* The hypothesis "equals ν at every input the rule can query" is used only through "ν_{π_ν}(data_n) = ν(data_n) for all n, almost surely". With i.i.d. inputs on an uncountable X, a program in E₀ may differ from ν on a μ-null set. It satisfies the a.s. form, so the proof gives the PQ special case with k = ℓ₀. The record says this explicitly only for FR on a countable X. State the hypothesis in the a.s. form.
* In FR, "n" may index queries or distinct inputs: the data set changes only at new inputs, so "eventually" means the same in both indexings when the support is infinite.

### 1.2 Thm 4.1(iv′) and (v) — **verified**

*(iv′) as checked.* For every n and every λ > 0, P[set of λ-MAPs ≠ E₀] ≤ Σ_{π∉E} inf_{0<s≤1} 2^{-sλ(ℓ(π)−ℓ₀)} ρ_s(π)^n.
* **Event inclusion.** A.s. every π₀ ∈ E₀ has J_λ(π₀) = λℓ₀ + S_n, and E∖E₀ is strictly worse by λ(ℓ − ℓ₀) > 0. MAPs exist, since J_λ ≥ λℓ and only finitely many programs have each length. So {MAPs ≠ E₀} ⊆ ∪_{π∉E}{J_λ(π) ≤ J_λ(π₀)} = ∪_{π∉E}{Λ_n(π) ≥ 2^{λ(ℓ(π)−ℓ₀)}}, a.s.
* **One Markov step per program and per s ∈ (0, 1].** E Λ_n^s = ρ_s^n, with ρ_s = E_μ Σ_{y:ν>0} ν^{1−s}ν_π^s. This holds for s = 1 too (ρ₁ ≤ 1), and also when ν_π has zeros.
* Taking the infimum over s per program and then a union bound is valid. Programs shorter than ℓ₀ get factors above 1; the bound remains valid.
* **The corollary forms.** "With s = 1/λ for every π …" and the second displayed form (s = 1/λ up to L, s = 1 above) need s = 1/λ ≤ 1, that is λ ≥ 1. The theorem's standing assumption λ > 1 covers both; the parenthetical "(and every λ > 0)" applies to the main display only. For the second form, ℓ > L and λ ≥ 1 give 2^{-λ(ℓ−ℓ₀)}ρ₁^n ≤ 2^{λℓ₀−(λ−1)L}2^{-ℓ}, and summing gives 2^{λℓ₀−(λ−1)L}t_L. Correct.

*(v) as checked.* P[∃n ≥ n₀ : MAPs ≠ E₀] ≤ 2^{λℓ₀−(λ−1)L} + 2^{ℓ₀}e^{-a_L n₀}(1 + 1/a_L).
* **Long programs.** By (i), a program π ∉ E with ℓ(π) > L and J ≤ J(π₀) at some n forces δ* > (λ−1)L − λℓ₀. Lemma 2.2(a) bounds this once, uniformly in n, because δ* is a supremum.
* **Programs of length ≤ L at each n.** The s = 1/λ Markov step and Lemma 2.1(d) give ρ_{1/λ}^n ≤ e^{-2min(1/λ, 1−1/λ)γ_L n} = e^{-a_L n}, with min(1/λ, 1−1/λ) = min(1, λ−1)/λ.
* **Summing over n ≥ n₀.** Σ_{n≥n₀} e^{-an} = e^{-an₀}/(1 − e^{-a}), and 1/(1 − e^{-a}) ≤ 1 + 1/a because e^a ≥ 1 + a.
* **The sufficient n₀.** With L = L_ε the first term is ≤ ε/2. The function a ↦ e^{-an₀}(1 + 1/a) decreases, so γ ≤ γ_{L_ε} is allowed. Then 2^{ℓ₀}e^{-an₀}(1 + 1/a) ≤ ε/2 ⟺ an₀ ≥ ℓ₀ ln 2 + ln(2/ε) + ln(1 + 1/a). Correct.

*Code.*
* v2(A): exact enumeration of all count vectors in two classes designed here. Both have sub-probability, deterministic and zero-containing kernels, and E-programs of three lengths. Class A has margin 5.4·10⁻⁴; class A2 has margin 0.011.
  * λ ∈ {0.5, 1, 1.5, 2, 3} and n ∈ {10, …, 320}, 60 rows.
  * The check is exact ≤ (iv′) with the infimum found by convex minimisation in s (log ρ_s is convex) ≤ min(s = 1/λ form, second form at L = 6).
  * **0 violations.** In class A2 at λ = 2, n = 320: exact 8.0·10⁻³, (iv′) 5.9·10⁻², s = 1/λ form 6.0·10⁻².
* v2(C): (v) by Monte Carlo in a third class (margin 0.0102), 3000 runs to n = 6000. The bound holds wherever it is below 1; for example, empirical 0 against 1.9·10⁻⁴ at λ = 2, n₀ = 1500.
* The inequality 1/(1 − e^{-a}) ≤ 1 + 1/a holds on a ∈ [10⁻⁶, 10²].

### 1.3 Prop 3.4(b),(c): λ = cn — **verified**

*(c) as checked.* Let C be a countable Kraft class, ν ∈ C or not, and let J_c(π) = cℓ(π) + R(π) with R(π) = E[−log ν_π(y|x)] under the true channel. If some π has J_c(π) < ∞, then A_c = argmin J_c is nonempty and finite. A.s. every cn-MAP is in A_c for all large n. If A_c has one kernel μ-a.e., the set of cn-MAPs equals A_c for all large n.

*Proof re-derived.*
* **A_c exists.** J_c ≥ cℓ, and Kraft allows at most 2^ℓ programs of length ℓ, so the sublevel set is finite.
* **Strong law.** For nonnegative i.i.d. variables, possibly +∞ or of infinite mean, R̂_n(π) → R(π) a.s., for all π at once by countability.
* **Bounded candidate set.** A MAP has cnℓ(π̂) ≤ J_{cn}(π_c), so ℓ(π̂) ≤ ℓ(π_c) + sup_n R̂_n(π_c)/c. This is finite a.s.: R(π_c) < ∞ forces ν_{π_c}(y_i|x_i) > 0 a.s., so each R̂_n(π_c) is finite, and the sequence converges to a finite limit.
* **Elimination.** Each of the finitely many candidates outside A_c has J_{cn}/n → J_c > min J_c.
* **Ties.** One kernel μ-a.e. gives one R, hence one length, hence a.s. equal J_{cn} at every n.
* "(c) holds in every countable Kraft class, also when ν ∉ C": correct; the proof never uses ν ∈ C.

*(b) as checked.* If c < c* := min_{ℓ(π)<ℓ₀} D(π)/(ℓ₀ − ℓ(π)), with c* = ∞ if no program is shorter than ℓ₀, then A_c = E₀.
* J_c(π) − J_c(π₀) = c(ℓ − ℓ₀) + D(π), because R(π) = H_μ(ν) + D(π) with H_μ(ν) ≤ log|Y| finite.
* The three cases are as the record states, including D = ∞. The minimum defining c* is over finitely many positive extended reals.
* Then (c) applies, because E₀ has the single kernel ν μ-a.e. Correct.

*Wording.* The record's revision summary ("recovers if and only if c < c* (strict inequalities on both sides)") and the synthesis (§4.4: "λ = cn recovers iff c < c*") use "iff". What is proved is (a) together with (b): recovery for c < c*, failure for c > c*, and nothing at c = c*. The synthesis's §2.5 row and §8 row F-cn already say "c = c* not covered"; use that form throughout.

*Code.*
* v3(A): exact enumeration in class A2 (c* = 0.0595, attained by a program of length 3). P[cn-MAP set = A_c] rises with n for c < c*, where A_c = E₀: 0.905 at n = 300 for c = c*/2. For c > c*, A_c = {coin}: 0.53, 0.99 and 1.00 at n = 300 for c = 1.25c*, 2c* and 4c*.
* v3(B): a countable misspecified class: Bern(j/2^m) for odd j, of length 2m + 1, with ν = Bern(0.3) ∉ C.
  * A_c is computed exactly at c ∈ {0.1, 0.02, 0.005, 0.001}.
  * The cn-MAP is computed exactly from the sufficient statistic, with a proved stopping rule for the length scan, checked against brute force on 196 fully covered cases.
  * Over 200 runs, every cn-MAP is in A_c in all runs at n ≥ 10⁴ for all four c. At n = 10³ the fractions are 1.0, 0.995, 0.955 and 0.77.

### 1.4 Prop 5.1(b′): the λ = 1 recovery-time bracket in C_k — **verified**

*Statement as checked.* In C_k, P(n) := P[set of 1-MAPs ≠ {coin} at n] ≤ 2^{k+1}/n² for every n ≥ 32. Hence 2^{(k−8)/2} − 6 < n_rec(ε) ≤ max(32, ⌈2^{(k+1)/2}/√ε⌉) for ε < 31/32 and even k.

*Proof re-derived.*
* **Reduction to a span.** ℓ(m) = m + 2⌈log(m+1)⌉ + 1 is strictly increasing. Ties count as "≠ {coin}". A parity on fewer bits is a parity on more bits. So the event is y ∈ colspan(A_{n×m*}), and P(n) = E[2^{rank − n}] ≤ 2^{m* − n}.
* **The chain.** ℓ(m*) ≤ k + n gives m* − n ≤ k − 1 − 2⌈log(m*+1)⌉, and 2^{2⌈log(m+1)⌉} ≥ (m+1)², so P(n) ≤ 2^{k−1}/(m*+1)².
* **The case split.** For m₁ := n + k − 1 − 2⌈log(n+1)⌉, either 1 ≤ m₁ ≤ n and ℓ(m₁) ≤ n + k, or m₁ > n and ℓ(n) < n + k. In both cases m* ≥ min(n, m₁).
* **The lower bound on m*.** For n ≥ 32, n/2 ≥ 2⌈log(n+1)⌉ (checked: equality is far off at n = 32, 16 against 12), so m₁ ≥ n/2 − 1 + k. Hence m* + 1 ≥ n/2 and P(n) ≤ 2^{k+1}/n².
* **The bracket.** Upper end: n ≥ 2^{(k+1)/2}/√ε gives 2^{k+1}/n² ≤ ε. Lower end: at n_b = 2^{(k−8)/2} − 6 the strict condition 2⌈log(n+6)⌉ + 6 < k holds with equality slack 2 (n_b + 6 is a power of 2). Prop 5.1(b) then gives P(n_b) ≥ 31/32 > ε, so n_rec > n_b. It fails at n_b + 1.
* **Uniform in D.** With a finite D, m* is capped at D, which only lowers P. The upper bound is therefore uniform in D. The lower end needs D ≥ n_b + 5 ("D large"). For k < 14, n_b ≤ 0 and the lower end is trivial.

*Code* (v4(A)).
* The GF(2) rank law was written here from the q-binomial count. It was checked against brute-force enumeration of all matrices with nm ≤ 16 (exact fractions; error 1.1·10⁻¹⁶), against an exact transpose-row chain (n, m ≤ 30; error 4.4·10⁻¹⁶), and against a Gaussian-elimination Monte Carlo of y ∈ colspan (|z| ≤ 1.31).
* P(n)n²/2^{k+1} was scanned on every integer n from 32 up to 10⁵–2·10⁷, for every k = 4, …, 40. The maximum is 0.351 (at k = 4) and **0 violations**. For k ≥ 24 the maximum is 0.250.
* Certified n_rec(ε) for even k = 14, …, 40 and ε ∈ {0.5, 0.1, 0.01, 0.001}. The scan stops where the nonincreasing bound 2^{m*(n)−n} falls below ε, which uses only rank ≤ m*. **All 55 values lie in the bracket.**
* n_rec(0.01) = 2^{(k+4)/2} + 6 at k = 16, 24, 32, 40: 1030, 16390, 262150, 4194310, equal to the record's table.
* The exact P(n_b) is 0.9845 at k = 16, 20, 24, 32 and 40.

### 1.5 Remark 4.5: the length bound of Thm 4.1(i) is attained — **verified**

*Statement as checked.* In C_{k,M}, take an integer k and a real λ > 1 with n := λ(k − 2)/(λ − 1) ∈ ℕ, and set M = n (D ≥ M). With probability ∏_{i=1}^n(1 − 2^{-i}) > 0.2887, the λ-MAP set is {coin, φ} with ℓ(φ) = (λk − 2)/(λ − 1) = (λk + δ_n)/(λ − 1) − log(1 + 2^{2−k})/(λ − 1).

*Proof re-derived.*
* **The tie.** λ(n + 2) = λk + n ⟺ n(λ − 1) = λ(k − 2).
* **The MAP set.** On the event that A is invertible, exactly one parity is consistent, and every other parity has J = ∞. So the MAP set is {coin, φ}. Off that event it is either {coin} or contains ≥ 3 programs, so the stated probability is exactly the probability of this MAP set.
* **The deficiency.** ξ(h_n)/ν(h_n) = 2^{-k} + 2^{-(n+2)}·2^n gives δ_n = log(2^{-k} + 1/4) = −2 + log(1 + 2^{2−k}).
* **The gap and the probability.** log₂(1 + x) ≤ x/ln 2 gives the stated gap bound. The finite product exceeds the infinite one, 0.2887881.

*Code* (v4(B)).
* Exact arithmetic (fractions and 50-digit mpmath) at the record's five (k, λ) and at (10, 5) and (7, 6). The tie holds exactly. The gap equals log(1 + 2^{2−k})/(λ − 1) to 40 digits and is below 2^{2−k}/((λ − 1) ln 2) in each case. The gaps range from 5.25·10⁻¹² (k = 40, λ = 2) to 3.52·10⁻⁴ (k = 16, λ = 1.25), as the record says.
* Monte Carlo by Gaussian elimination, 4000 runs each: P[MAP set = {coin, one parity}] = 0.278 at (k, λ) = (20, 2) and 0.286 at (16, 1.25), against 0.2888 (−1.5 and −0.4 standard errors). On that event the gap matched in every run.

*Wording.* "Take integers k and λ > 1" must read "an integer k and a real λ > 1", since three of the record's own examples have λ = 1.5, 1.25. The synthesis's verification log (item 2(C)) quotes the gaps as "5.5·10⁻⁶ to 3.5·10⁻⁴". Its own s1 output prints 5.25·10⁻¹² for (40, 2) and 2.69·10⁻⁹ for (30, 3); the correct range is 5.2·10⁻¹² to 3.5·10⁻⁴.

### 1.6 Remark 4.7: what λ > 1 buys in the finite-sample bound — **verified with correction**

*What is proved, and correct.*
* (1) For each fixed s ∈ (0, 1], (iv′) gives P[MAPs ≠ E₀] ≤ 2^{sλℓ₀}Σ_{π∉E}2^{-sλℓ(π)}ρ_s(π)^n.
* (2) For λ > 1, s = 1/λ gives (iv), with a class-free rate.
* (3) At λ = 1 and s < 1, the sum is at most 2^{sℓ₀}Z(s) sup_{π∉E} ρ_s(π)^n, with Z(s) = Σ_π 2^{-sℓ(π)}. In a finite class, Z(s) < ∞ and sup ρ_s < 1, so it decays exponentially at a class-dependent rate.
* (4) The numbers in i1's class: the λ = 1 free-exponent bound is 0.419 at n = 40 and 1.18·10⁻³ at n = 160, and the s = 1 (Rényi) form is 18.50. Recomputed independently in v2(B); exact values 5.9·10⁻² and 1.1·10⁻⁴.

*What is not proved, and is false as written.*
* **(F1) "At λ = 1 the same bound needs Σ_π 2^{-sℓ(π)} < ∞ for some s < 1."**
  * Remark 4.7 gives only the sufficiency in (3); no necessity argument is given.
  * The necessity is false for (iv′) as stated, with the infimum over s taken per program. Take C_k with parities on every m ≥ 1, inputs i.i.d. uniform bits (a non-atomic μ on {0,1}^ℕ, allowed by Def 1.1). Then Z(s) = ∞ for every s < 1.
  * A parity has ρ_s = 2^{s−1}, so its (iv′) term at λ = 1 is inf_s 2^{-s(ℓ−k)}2^{-(1−s)n} = 2^{-max(n, ℓ−k)}.
  * Summing over the blocks of equal ⌈log(m+1)⌉ and using m* + 1 ≥ n/2 (from 1.4) gives (iv′) ≤ 2^k/n + 2^{k+2}/n² for n ≥ 32. This tends to 0.
  * Computed (v4(D), k = 16): the bound is 16.9, 1.78, 0.184, 1.7·10⁻², 1.8·10⁻³ and 1.8·10⁻⁴ at n = 10³, …, 10⁸, that is (0.26–0.28)·2^k/n.
  * The statement is true only for the form with one s for all programs: 2^{sℓ₀}Z(s) sup ρ_s^n is finite only if Z(s) < ∞.
* **(F2) "In the parity class C_k, Z(s) = ∞ for every s < 1."** In Prop 5.1's setting (inputs uniform on {0,1}^D, D finite) C_k is a finite class, and Z(s) < ∞. Z(s) grows like 2^{(1−s)D} with D (v4(D)). The record's §0 item 4 says both "holds in finite classes" and "fails in the parity class of Prop 5.1", which contradict each other for finite D.
* **(F3) "Prop 5.1 shows that no bound in terms of (ℓ₀, γ, ε) exists there [in C_k]."** In C_k, Prop 5.1(b′) itself gives n_rec(ε) ≤ max(32, ⌈2^{(ℓ₀+1)/2}/√ε⌉), uniformly in D: a bound in terms of (ℓ₀, ε). What C_k shows is that the λ = 1 recovery time can be exponential in ℓ₀, Θ(2^{ℓ₀/2}), against Θ(λℓ₀/(λ − 1)) for λ > 1. The absence of any bound in (ℓ₀, γ, ε) is shown by the family C_{k,M}, M → ∞ (Prop 5.1(a)). There ℓ₀ = k and the margin is 0.293 for every M, yet the 1-MAP is a parity at n = M − 5 with probability ≥ 31/32, and Z(s) ≥ 2^{(1−s)M−2s}. In C_{k,M} the λ = 1 free-exponent bound is 2^{M−max(n, M+2−k)}, which is ≥ 1 until n ≥ M (v4(D)).

*Corrected statement (proved).* **Remark 4.7′.**
* (a) For each fixed s ∈ (0, 1], (iv′) gives P[MAPs ≠ E₀] ≤ 2^{sλℓ₀}Σ_{π∉E}2^{-sλℓ(π)}ρ_s(π)^n.
* (b) For λ > 1, s = 1/λ turns the prior factor into 2^{-ℓ(π)}, which is Kraft-summable in every class. This gives (iv), whose rate depends only on (λ, ℓ₀, γ, ε).
* (c) At λ = 1 and s < 1, the bound is at most 2^{sℓ₀}Z(s) sup_{π∉E}ρ_s(π)^n with Z(s) := Σ_π 2^{-sℓ(π)}. When Z(s) < ∞ for some s < 1 and the margin is uniform (in particular in every finite class), it decays exponentially in n, with a constant 2^{sℓ₀}Z(s) that depends on the class.
* (d) At λ = 1 no bound depending only on (ℓ₀, γ, ε) exists: in C_{k,M} the margin is 0.293 and ℓ₀ = k for every M, but the recovery time exceeds M − 5 (Prop 5.1(a)); there Z(s) ≥ 2^{(1−s)M−2s}.
* (e) In C_k the λ = 1 recovery time is Θ(2^{ℓ₀/2}) (Prop 5.1(b),(b′)), exponential in ℓ₀, against Θ(λℓ₀/(λ − 1)) at λ > 1 (Prop 4.4(b)).

Optional, also proved: finiteness of Z(s) is sufficient, not necessary, for a decaying λ = 1 bound from (iv′) with s chosen per program. In C_k with parities on every m ≥ 1 that bound is ≤ 2^{ℓ₀}/n + 2^{ℓ₀+2}/n² for n ≥ 32.

*Where the uncorrected wording appears.*
* iid record: §0 item 4 ("Why λ > 1 (Remark 4.7)"), Remark 4.7 itself, the §5 contrast table row "finite-sample failure bound (PQ)", §9.3 ("λ = 1"), and §11 row 4.7.
* Synthesis: §2 "What Theorem A says about λ" ("At λ = 1, the same Markov argument needs …") and §8 row A-λ1.
* Replace "needs Σ2^{-sℓ} < ∞" by "has, with one exponent s < 1 for all programs, the class-dependent constant 2^{sℓ₀}Z(s); no bound in (ℓ₀, γ, ε) alone exists at λ = 1 (Prop 5.1(a))". The synthesis's phrase "What λ > 1 adds is a rate that depends only on (λ, ℓ₀, γ, ε)" is correct and can stay.

### 1.7 Lemma 8.1(iv): the ℓ₀ in the right-side slack cannot be dropped — **verified**

*Statement as checked.* In C_{k,M} with M + 2 > k, n = M − 5 ≥ 1 and α = M + 2, on the event that some parity is consistent (probability ≥ P[rank A = n] ≥ 31/32), ρ(ℓ₀) = n and ρ(α) = 0. So the excess ρ(ℓ₀) − ρ(α) − (α − ℓ₀) is exactly k − 7. The refuted reading "ρ(ℓ₀) − ρ(α) ≤ (α − ℓ₀) + δ*" therefore needs δ* ≥ k − 7, and it fails with probability ≥ 31/32 − 2^{7−k}.

*Proof re-derived.*
* M + 2 > k leaves the coin as the only program of length ≤ k, with fit n. A consistent parity has fit 0 and length M + 2.
* The excess is n − (M + 2 − k) = k − 7.
* P[rank A = n] ≥ 1 − Σ_{i<n}2^{i−M} > 1 − 2^{n−M} = 31/32. Lemma 2.2(a) gives P[δ* ≥ k − 7] ≤ 2^{7−k}.
* The second claim is informative only for k ≥ 8, where the excess is positive.

*Code* (v4(C)). Brute force over all 2^M parities at (k, M) = (10, 12), (12, 11), (9, 14), 3000 runs each. The excess equals k − 7 in every run of the event (2951/2951 and similar). The event frequencies 0.983–0.984 agree with the rank law, 0.9845–0.9847. The rank law gives 0.98450 at k ∈ {16, 24, 32} and M ∈ {k, k + 10, k + 100}.

### 1.8 Prop 7.3(iii′): the class of 7.3(iii) in PQ — **verified**

*Statement as checked.* The class is {0w : w deterministic} ∪ {1^{ℓ_c}}, with ν = f ⊕ Bern(p), p ∈ (0, ½), i.i.d. inputs from an atomic μ, and fresh labels. Almost surely some input eventually receives both labels. From then on every deterministic program has likelihood 0, and the coin is the unique λ-MAP for every λ > 0.

*Proof re-derived.*
* An atom of positive mass is queried infinitely often (second Borel–Cantelli lemma).
* At that atom the labels are i.i.d., and each value has probability ≥ p > 0, so both values appear a.s.
* A deterministic or partial program gives likelihood 0 to one of the two labels.
* The coin has finite J, so it is the unique MAP. It is also the unique KL-projection, since deterministic programs have D = ∞ when p > 0. Correct.

*Code* (v5(A)). With μ(x) = 2^{-(x+1)}, all 10⁴ runs reached the event, for each p ∈ {0.01, 0.1, 0.25}. The median times were 71, 9 and 5.

### 1.9 Prop 7.3(v): growing schedules in finite misspecified classes — **verified**

*Statement as checked.*
* (a) Let C be finite with D* < ∞, and let the log-ratios between projections have finite second moments. If λ_n/√(n log log n) → ∞ and λ_n = o(n), then a.s. every λ_n-MAP is eventually in P₀.
* (b) Let π, π′ ∈ P with ℓ(π′) > ℓ(π) and σ² > 0. If λ_n(ℓ(π′) − ℓ(π)) ≤ (1 − η)σ√(2n ln ln n) eventually, then in {π, π′} the longer π′ is the unique MAP infinitely often, a.s.

*Proof re-derived.*
* **Non-projections.** They lose linearly by the strong law, as in (i). The positive part of log(ν_π/ν) is integrable, and log(ν_{π_P}/ν) is integrable because D* < ∞.
* **(a) for P∖P₀.** The increments of W_n have mean D(π) − D(π′) = 0 (both finite) and finite variance. The Hartman–Wintner LIL gives |W_n| ≤ 2σ√(n ln ln n) eventually, since √2 < 2. Then J(π′) − J(π) ≥ λ_n − 2σ√(n ln ln n) > 0 eventually. Changing the logarithm's base changes log log n only by a constant factor, so the hypothesis is base-free. If σ = 0, then W_n = 0 a.s. and the length difference decides. The class is finite.
* **(b).** lim sup W_n/(σ√(2n ln ln n)) = 1 a.s., so W_n > λ_nΔℓ infinitely often.
* "The second moment is automatic on a finite X": D(π) = D* < ∞ forces ν_π > 0 wherever ν > 0 on the support, so the log-ratio takes finitely many finite values. Correct.
* (b) is shown in the two-element subclass, a finite class in its own right, so it is a valid sharpness example. "Sharp up to the constant" is right: the LIL also gives eventual exclusion when λ_nΔℓ ≥ (1 + η)σ√(2n ln ln n).

*Code* (v5(B)). The record's example (σ = log₂3, Δℓ = 3, critical constant C* = σ√2/3 = 0.747 for λ_n = C√(n ln ln n)), 60 random walks of 10⁷ steps each. The fraction of runs in which π₂ is the unique MAP at some n ∈ (10⁶, 10⁷] is 54/60 at fixed λ = 2, 15/60 at √n, 30/60 at C = 0.4, 17/60 at C = 0.6, 1/60 at C = 0.9, and 0/60 at C = 1.5 and at n^0.6. This is consistent with the theorem. It is an illustration only: the LIL regime converges slowly.

### 1.10 Cor 6.1(vi): frozen data on a finite domain — **verified with correction (wording)**

*Statement as checked.* μ has finite support X₀, with frozen noise. The data set is eventually F|X₀, so every λ-MAP is eventually a minimiser of J_λ(·; F|X₀). In the i4 class (d = 6, p = 1/8, ℓ₀ = 10) the λ-MAP is then wrong with probability ≥ (7/8)^64 for every λ, together with the computed table.

*Proof re-derived.* On the no-flip event, (a*, 0) has length 1 + 6 + 2 = 9 and fit 0, so J = 9λ < 10λ + 64 log(8/7). This holds for every λ > 0. The probability is (7/8)^64 = 1.9432·10⁻⁴. "Eventually" (once every input has been seen) is implicit and should be said.

*The table, exactly.* The failure event splits into A (some (a*, q ≠ 1/8) or the coin has J ≤ J(truth)), which depends only on the flip count K ~ Bin(64, 1/8), and the events B_a of the 63 wrong parities. For a wrong parity a, the mismatch count is 32 + K − 2K_in, with K_in = #flips in the 32-set where a ⊕ a* = 1 and (K_in, K − K_in) ~ Bin(32, 1/8)². So P[A] ≤ P[fail] ≤ P[A] + 63·P[B_a ∖ A], all exact (v6(B)):

| λ | exact P[frozen λ-MAP ≠ (a*, 1/8)] | record (Monte Carlo, i8(D)) | exact breakdown of the unique MAP |
|---|---|---|---|
| 1 | 0.25542 | 0.2555 | rate 1/4: 0.1704; rate 1/16: 0.0848; (a*, 0): 0.0002; coin: 0.0001 |
| 1.5 | 0.25542 | 0.2555 | rate 1/4: 0.1686; rate 1/16: 0.0848; coin: 0.0018; (a*, 0): 0.0002 |
| 2 | 0.20399 | 0.2037 | rate 1/4: 0.1592; rate 1/16: 0.0334; coin: 0.0112; (a*, 0): 0.0002 |
| 4 | 0.56641 | 0.5661 | coin: 0.5564; rate 1/16: 0.0098; (a*, 0): 0.0002 |

* P[B_a ∖ A] = 0 exactly at every λ: wrong parities never compete, so the bracket closes.
* The record's Monte Carlo values agree within 0.3 standard errors. Its "selected instead" figures, printed to three digits, agree within about 2 standard errors (record: 0.169 and 0.086 at λ = 1, against exact 0.1704 and 0.0848).
* My own Monte Carlo of 200,000 tables (v6(C)) gives 0.2555, 0.2555, 0.2043 and 0.5671.
* The paper should quote the exact values: 0.255, 0.255, 0.204, 0.566 (to three digits).

*The second class.* The record quotes "0.132, 0.132, 0.080 and 0.562, each up to a further 0.005 from tables with K ≥ 16" for referee B's class; the synthesis quotes "0.13, 0.13, 0.08 and 0.56". With that class re-typed from rB6's description (including its single-input function competitors), the same exact bracket (v6(D)) gives **0.13623, 0.13623, 0.08481 and 0.56641**. The K ≥ 16 tables contribute essentially their whole mass, 0.0046. The record's statement is correct as a bracket. The synthesis's two-digit values are the lower ends; the exact values round to 0.14, 0.14, 0.08 and 0.57.

*Wording correction.* "Its rate is a penalised empirical rate: among the programs (f, q), the one minimising λℓ(f, q) + K log(1/q) + (|X₀| − K) log(1/(1−q))" describes the best program with the true function f. It does not describe every λ-MAP: at λ = 4 the coin is the MAP with probability 0.556. Corrected sentence: "Among the programs (f, q) with the true f, the one of least J_λ has the rate minimising λℓ(f, q) + K log(1/q) + (|X₀| − K) log(1/(1−q)), K the number of flipped inputs (a penalised empirical rate); the λ-MAP is this program unless another function or the coin has smaller J_λ."

---

## 2. Consolidated corrections for the paper and the synthesis

1. **Remark 4.7** (§1.6). Use Remark 4.7′. Do not state that λ = 1 "needs" Σ_π2^{-sℓ(π)} < ∞, that Z(s) = ∞ in C_k (with inputs in {0,1}^D), or that no (ℓ₀, γ, ε)-bound exists in C_k. Attribute the absence of a class-free bound to C_{k,M} (Prop 5.1(a)), and the exponential λ = 1 recovery time to C_k (Prop 5.1(b),(b′)). Affects the synthesis §2 (Theorem A, "What Theorem A says about λ") and §8 row A-λ1, and the iid record's §0 item 4, the §5 table row and §11 row 4.7.
2. **Cor 6.1(vi)** (§1.10). Quote the exact values 0.255, 0.255, 0.204, 0.566. In the second class they are 0.136, 0.136, 0.085, 0.566. Use the corrected "penalised empirical rate" sentence and say "eventually (once the table is complete)".
3. **Prop 3.4** (§1.3). Say "recovery for c < c*, failure for c > c*, c = c* not covered", never "iff". In (c), "provided min J_c < ∞" means "provided J_c(π) < ∞ for some π".
4. **Prop 3.3** (§1.1). State the hypothesis on π_ν in the almost-sure form "ν_{π_ν}(data_n) = ν(data_n) for all n". Then the PQ i.i.d. special case covers E₀-programs that differ from ν on a μ-null set. If the paper extends `thm:split:private`(iv) to λ ≥ 1, its proof must replace the confinement by (i) with the Z^L supermartingale step (Prop 3.3(a)), and the tail bound by (ii) with Z^L and Borel–Cantelli (Prop 3.3(c)). Parts (i)–(iii) keep λ > 1.
5. **Thm 4.1(iv′)** (§1.2). The main display holds for every λ > 0. The two corollary forms (s = 1/λ) need λ ≥ 1.
6. **Remark 4.5** (§1.5). "An integer k and a real λ > 1 with λ(k − 2)/(λ − 1) ∈ ℕ", and D ≥ M. The synthesis's verification log quotes the gap range as 5.5·10⁻⁶ to 3.5·10⁻⁴; the correct range is 5.2·10⁻¹² to 3.5·10⁻⁴.
7. **κ = 0 numbers.** None of the numbers checked here involves a machine constant. All are exact or Monte Carlo values in explicit classes, so DECISIONS' κ = 0 marking does not apply to them.

---

## 3. Code and verification log

*Run 2026-10-13, Python 3.11.15, numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0. The scripts were run from a scratch copy with `python3 -I` and `PYTHONDONTWRITEBYTECODE=1`, all six in parallel. The `.out` files in `iid/verify_code/` are the outputs of that run; All six exited with code 0 and empty stderr. Run times, all six in parallel on 4 cores: v6 26 s, v5 31 s, v3 49 s, v1 221 s, v2 364 s, v4 630 s. v4's output is byte-identical to its earlier development run.*

| script | seed | checks | result |
|---|---|---|---|
| `v1_run_identification.py` | 4101–4104 | Prop 3.3: Kakutani identity (10⁵ random pairs); martingale mean under an adaptive rule; Ville for Z^L under a repeating adaptive rule; the full statement at λ ∈ {1, 1.5} in FR (sparse odd queries) and PQ (repeats), with K decided analytically for the limit of each rule | identity error 3.3·10⁻¹⁶; E M_n = 0.9986 ± 0.0040; Ville 0.127/0.017/0.000 ≤ 0.250/0.062/0.016; MAPs in K in 0.985–0.99 of runs at n = 4000, Π(C∖K) → 0.010–0.028 |
| `v2_free_exponent.py` | 4201, 4202 | Thm 4.1(iv′) by exact enumeration in two classes, 60 (λ, n) rows, λ ∈ {0.5, …, 3}; Remark 4.7's i1 numbers; Thm 4.1(v) by Monte Carlo | 0 violations of exact ≤ (iv′) ≤ min(s = 1/λ form, second form); 0.419, 1.18·10⁻³, 18.50 reproduced; (v) holds |
| `v3_lambda_cn.py` | 4201, 4300, 4301 | Prop 3.4: c*, A_c and exact P[cn-MAP set = A_c] in a finite class; a countable misspecified class, exact cn-MAPs to n = 10⁷, 200 runs | as in §1.3; all runs in A_c from n = 10⁴ |
| `v4_parity.py` | 4401, 4402 (Monte Carlo parts) | GF(2) rank law (three cross-checks); Prop 5.1(b′) on every n for k = 4..40; 55 certified n_rec against the bracket; Remark 4.5 in exact arithmetic, plus Monte Carlo; Lemma 8.1(iv) by brute force; Remark 4.7 in C_k (D finite and infinite) and C_{k,M} | 0 violations; all n_rec in the bracket; n_rec(0.01) = 2^{(k+4)/2} + 6; excess k − 7 in every event run; (F1)–(F3) of §1.6 |
| `v5_misspecification.py` | 4501, 4502 | Prop 7.3(iii′): time to a doubly labelled input; Prop 7.3(v): late switches under seven schedules, 60 walks of 10⁷ steps | as in §1.8–1.9 |
| `v6_frozen_noisy_parity.py` | 4601 | Cor 6.1(vi): the lower-bound mechanism; exact bracket and exact breakdown in the i4 class; Monte Carlo of 200,000 tables; exact bracket in rB6's class | 0.25542, 0.25542, 0.20399, 0.56641 (bracket closed); rB6 class 0.13623, 0.13623, 0.08481, 0.56641 |

*Two bugs found and fixed during development, both before the recorded run.*
* v3's first version compared against an infinite running minimum through `best − 1e-9·|best|`, which is NaN. This made its brute-force sanity check vacuous. It now treats the infinite case explicitly and reports the number of fully covered cases (196).
* v2's first version also asserted "s = 1/λ form ≤ second form". That is not a valid inequality: the second form uses s = 1 above L. Only "(iv′) ≤ both" is asserted now.

*Repository.* The only git command run was `git status`, which is read-only. Files written: `research/tracks/split/verify-iid.md` (this file) and `research/tracks/split/iid/verify_code/v1`–`v6` (`.py` and `.out`). No record, referee report, script or paper file was changed.
