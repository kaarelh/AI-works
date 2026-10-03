import InfLearn.Prelude

/-!
# T5 Theorem 2.1(i): no adaptation with private randomness

This file formalises Theorem 2.1(i) of
`research/theory/T5-steeper-simplicity-and-normativity-from-imitation.md` (§2.1), in the form
revised after verification (Verification log, item A4).

## Setting
* `X` is the input type (arbitrary), `Y` a finite label type.
* `F : Finset (X → Y)` is a finite class of deterministic labelers, and
  `Q : (X → Y) → ℝ` a probability distribution on `F` (`IsDistOn F Q`: `Q ≥ 0` on `F` and
  `∑_{f ∈ F} Q f = 1`; values of `Q` off `F` are irrelevant).
* The inputs are `x : I → X` for a finite index type `I` (take `I = Fin N` for
  `x_1, …, x_N`); repeats are allowed.
* A *product hypothesis* (function hypothesis with private randomness, Def 1.1) is
  `h : X → Y → ℝ` with `h x ·` a probability distribution on `Y` for every `x`
  (`IsProductHyp h`).  Its log-loss on `f` is `loss h x f = ∑_i -log h(f(x_i) | x_i)`.
* `Fimg F x = F(x) = {f(x) : f ∈ F}`; `marg F Q x = Q_x` is the law of `f(x)` under `f ∼ Q`;
  `entropy p = -∑_y p_y log p_y` (natural logarithm; `0 log 0 = 0`).

## Logarithm of zero
Mathlib's `Real.log 0 = 0`, so the real-valued `loss` treats `-log 0` as `0` rather than `+∞`.
We therefore give two versions of the theorem:
* `thm_2_1_i` (real-valued) assumes that `h` gives positive probability to the label of every
  `f` in the support of `Q` at every input (otherwise the paper's loss is `+∞`);
* `thm_2_1_i_ennreal` uses the extended loss `lossE` with values in `[0, ∞]`
  (`-log 0 = ∞`) and needs **no** extra hypothesis. This is the paper's statement verbatim.

## Main results
* `gibbs`: Gibbs' inequality `H(p) ≤ ∑_y p_y (-log q_y)` for a distribution `p` and a
  sub-probability vector `q` with `q_y > 0` wherever `p_y > 0`, proved from
  `Real.log_le_sub_one_of_pos`.  `gibbs_eq`: equality at `q = p`.
* `expLoss_eq_sum_marg`: `E_{f∼Q} loss h x f = ∑_i ∑_y Q_{x_i}(y) (-log h(y | x_i))`.
* **`thm_2_1_i`** (T5 Thm 2.1(i)):
  `∑_i H(Q_{x_i}) ≤ E_{f∼Q}[∑_i -log h(f(x_i)|x_i)] ≤ max_{f ∈ supp Q} ∑_i -log h(f(x_i)|x_i)`.
  `thm_2_1_i_maxF` is the paper's displayed form with `max_{f ∈ F}`, and `thm_2_1_i_exists`
  gives a witness `f ∈ supp Q`.
* **`thm_2_1_i_ennreal`**: the same chain for the `[0,∞]`-valued loss, with no hypothesis
  on `h` beyond being a product hypothesis. `thm_2_1_i_ennreal_maxF`: the `max_{f∈F}` form.
* `margHyp_expLoss`: the second inequality is an equality for `h(·|x) = Q_x`.
* `unifHyp` (the hypothesis `h(·|x) = Unif(F(x))`): `unifHyp_isProductHyp`,
  `unifHyp_loss` (it pays exactly `∑_i log |F(x_i)|` against **every** `f ∈ F`), hence
  `sum_entropy_le_sum_log_card` (`∑_i H(Q_{x_i}) ≤ ∑_i log |F(x_i)|` for every `Q`).
* `entropy_marg_of_uniform`, `sum_entropy_of_uniform`: if `Q_{x_i}` is uniform on `F(x_i)`,
  then `∑_i H(Q_{x_i}) = ∑_i log |F(x_i)|`.
* **`minimax_of_uniform_marginals`**: if some `Q` on `F` has uniform marginals on every
  `F(x_i)`, then `min_h max_{f ∈ F} loss = ∑_i log |F(x_i)|`, attained by `unifHyp`
  (both in the real form and in the `[0,∞]` form, `minimax_of_uniform_marginals_ennreal`).
* `uniform_marginals_of_transitive` (the group condition of Thm 2.1(i), as revised in A4): if
  a family of label permutations `σ_{g,x}` acts on `F` by `(g·f)(x) = σ_{g,x}(f(x))` and the
  induced action on each `F(x)` is transitive, then `Q = Unif(F)` has uniform marginals.
  (No group axioms are needed; only closure of `F` under each `g·`.)
* `Example`: the paper's example `F = {(a,a),(a,b),(b,a),(c,a)}` on two inputs:
  no `Q` has uniform marginals (`Example.no_uniform_marginals`), and an explicit product
  hypothesis has worst-case loss `< log 3 + log 2 = ∑_i log |F(x_i)|`
  (`Example.value_lt_sum_log_card`), so the uniform hypothesis is not minimax-optimal there and
  the uniform-marginal hypothesis cannot be dropped.

## Not formalised
* The exact minimax value `min_h max_f = max_Q ∑_i H(Q_{x_i})` (via Sion's theorem) and the
  "only if" direction of "the value equals `∑ log |F(x_i)|` iff a uniform-marginal `Q`
  exists" (both need a minimax theorem).  For the paper's example we prove only the strict
  upper bound `log(35/6) < log 6`, not the exact value `2.5431` bits.
* Theorem 2.1(ii) (Shtarkov, shared randomness).
-/

namespace InfLearn.NoAdaptation

open Finset

/-! ## Definitions -/

section Defs

variable {X Y I : Type*} [Fintype Y] [DecidableEq Y] [Fintype I]

/-- Shannon entropy (natural logarithm) of a vector `p : Y → ℝ`: `H(p) = -∑ p_y log p_y`.
(With Mathlib's `Real.log 0 = 0`, the convention `0 log 0 = 0` is automatic.) -/
noncomputable def entropy (p : Y → ℝ) : ℝ := ∑ y, -(p y * Real.log (p y))

/-- `Q` is a probability distribution on the finite class `F`. -/
def IsDistOn (F : Finset (X → Y)) (Q : (X → Y) → ℝ) : Prop :=
  (∀ f ∈ F, 0 ≤ Q f) ∧ ∑ f ∈ F, Q f = 1

/-- A product hypothesis (function hypothesis with private randomness, T5 Def 1.1):
`h(·|x)` is a probability distribution on `Y` for every input `x`. -/
def IsProductHyp (h : X → Y → ℝ) : Prop :=
  (∀ x y, 0 ≤ h x y) ∧ ∀ x, ∑ y, h x y = 1

/-- `F(x) = {f(x) : f ∈ F}`. -/
def Fimg (F : Finset (X → Y)) (x : X) : Finset Y := F.image (fun f => f x)

/-- The pushforward `Q_x`: the law of `f(x)` under `f ∼ Q`. -/
def marg (F : Finset (X → Y)) (Q : (X → Y) → ℝ) (x : X) (y : Y) : ℝ :=
  ∑ f ∈ F with f x = y, Q f

/-- The support of `Q` in `F`. -/
noncomputable def supp (F : Finset (X → Y)) (Q : (X → Y) → ℝ) : Finset (X → Y) :=
  F.filter (fun f => 0 < Q f)

/-- The (real-valued) log-loss of the product hypothesis `h` on the labeling of the inputs
`x` by `f`: `∑_i -log h(f(x_i) | x_i)`. (Here `-log 0` is computed as `0`; see `lossE`.) -/
noncomputable def loss (h : X → Y → ℝ) (x : I → X) (f : X → Y) : ℝ :=
  ∑ i, -Real.log (h (x i) (f (x i)))

/-- Expected loss `E_{f∼Q}[loss h x f]`. -/
noncomputable def expLoss (F : Finset (X → Y)) (Q : (X → Y) → ℝ) (h : X → Y → ℝ)
    (x : I → X) : ℝ :=
  ∑ f ∈ F, Q f * loss h x f

/-- Extended negative log-probability: `-log p ∈ [0, ∞]`, with `-log 0 = ∞`. -/
noncomputable def nllE (p : ℝ) : ENNReal :=
  if 0 < p then ENNReal.ofReal (-Real.log p) else ⊤

/-- The extended log-loss `∑_i -log h(f(x_i) | x_i) ∈ [0, ∞]`. -/
noncomputable def lossE (h : X → Y → ℝ) (x : I → X) (f : X → Y) : ENNReal :=
  ∑ i, nllE (h (x i) (f (x i)))

/-- Extended expected loss `E_{f∼Q}[lossE h x f] ∈ [0, ∞]`. -/
noncomputable def expLossE (F : Finset (X → Y)) (Q : (X → Y) → ℝ) (h : X → Y → ℝ)
    (x : I → X) : ENNReal :=
  ∑ f ∈ F, ENNReal.ofReal (Q f) * lossE h x f

/-- The uniform hypothesis `h(·|x) = Unif(F(x))`. -/
noncomputable def unifHyp (F : Finset (X → Y)) (x : X) (y : Y) : ℝ :=
  if y ∈ Fimg F x then 1 / ((Fimg F x).card : ℝ) else 0

/-- The hypothesis `h(·|x) = Q_x`. -/
def margHyp (F : Finset (X → Y)) (Q : (X → Y) → ℝ) : X → Y → ℝ := marg F Q

/-- `Q` has uniform marginals on every `F(x_i)`: `Q_{x_i} = Unif(F(x_i))`. -/
def UniformMarginals (F : Finset (X → Y)) (Q : (X → Y) → ℝ) (x : I → X) : Prop :=
  ∀ i, ∀ y ∈ Fimg F (x i), marg F Q (x i) y = 1 / ((Fimg F (x i)).card : ℝ)

/-- The uniform distribution on `F`. -/
noncomputable def unifDist (F : Finset (X → Y)) : (X → Y) → ℝ := fun _ => 1 / (F.card : ℝ)

end Defs

/-! ## Gibbs' inequality -/

section Gibbs

variable {Y : Type*} [Fintype Y]

/-- Pointwise form: `a (log b - log a) ≤ b - a` for `a, b ≥ 0` with `b > 0` when `a > 0`. -/
lemma mul_log_sub_le (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (hab : 0 < a → 0 < b) :
    a * (Real.log b - Real.log a) ≤ b - a := by
  rcases ha.eq_or_lt with h | h
  · subst h; simpa using hb
  · have hb' := hab h
    have h1 := Real.log_le_sub_one_of_pos (div_pos hb' h)
    rw [Real.log_div hb'.ne' h.ne'] at h1
    have h2 := mul_le_mul_of_nonneg_left h1 h.le
    have h3 : a * (b / a - 1) = b - a := by field_simp
    linarith

/-- **Gibbs' inequality.** For a probability vector `p` and a nonnegative `q` with
`∑ q ≤ 1` and `q_y > 0` wherever `p_y > 0`: `H(p) ≤ ∑_y p_y (-log q_y)`. -/
theorem gibbs {p q : Y → ℝ} (hp0 : ∀ y, 0 ≤ p y) (hp1 : ∑ y, p y = 1)
    (hq0 : ∀ y, 0 ≤ q y) (hq1 : ∑ y, q y ≤ 1) (hpq : ∀ y, 0 < p y → 0 < q y) :
    entropy p ≤ ∑ y, p y * -Real.log (q y) := by
  have key : ∑ y, p y * (Real.log (q y) - Real.log (p y)) ≤ ∑ y, (q y - p y) :=
    Finset.sum_le_sum fun y _ => mul_log_sub_le _ _ (hp0 y) (hq0 y) (hpq y)
  rw [Finset.sum_sub_distrib, hp1] at key
  have e : ∑ y, p y * -Real.log (q y) - entropy p =
      -∑ y, p y * (Real.log (q y) - Real.log (p y)) := by
    unfold entropy
    rw [← Finset.sum_sub_distrib, ← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl fun y _ => ?_
    ring
  linarith

/-- Equality in Gibbs' inequality at `q = p`. -/
theorem gibbs_eq (p : Y → ℝ) : ∑ y, p y * -Real.log (p y) = entropy p := by
  unfold entropy
  refine Finset.sum_congr rfl fun y _ => ?_
  ring

end Gibbs

/-! ## Basic facts about the setting -/

section Basic

variable {X Y I : Type*} [Fintype Y] [DecidableEq Y] [Fintype I]
variable {F : Finset (X → Y)} {Q : (X → Y) → ℝ}

omit [Fintype Y] in
lemma marg_nonneg (hQ : IsDistOn F Q) (x : X) (y : Y) : 0 ≤ marg F Q x y :=
  Finset.sum_nonneg fun f hf => hQ.1 f (Finset.mem_filter.1 hf).1

lemma sum_marg (F : Finset (X → Y)) (Q : (X → Y) → ℝ) (x : X) :
    ∑ y, marg F Q x y = ∑ f ∈ F, Q f :=
  Finset.sum_fiberwise F (fun f => f x) Q

/-- Pushing an expectation over `f ∼ Q` forward to `y = f(x) ∼ Q_x`. -/
lemma sum_mul_comp_eq (F : Finset (X → Y)) (Q : (X → Y) → ℝ) (x : X) (g : Y → ℝ) :
    ∑ f ∈ F, Q f * g (f x) = ∑ y, marg F Q x y * g y := by
  unfold marg
  simp_rw [Finset.sum_mul]
  rw [← Finset.sum_fiberwise F (fun f => f x) (fun f => Q f * g (f x))]
  refine Finset.sum_congr rfl fun y _ => Finset.sum_congr rfl fun f hf => ?_
  rw [(Finset.mem_filter.1 hf).2]

lemma margHyp_isProductHyp (hQ : IsDistOn F Q) : IsProductHyp (margHyp F Q) :=
  ⟨fun x y => marg_nonneg hQ x y, fun x => by
    show ∑ y, marg F Q x y = 1
    rw [sum_marg, hQ.2]⟩

omit [Fintype Y] [DecidableEq Y] in
lemma supp_nonempty (hQ : IsDistOn F Q) : (supp F Q).Nonempty := by
  by_contra hne
  rw [Finset.not_nonempty_iff_eq_empty] at hne
  have : ∀ f ∈ F, Q f = 0 := by
    intro f hf
    by_contra hQf
    have : f ∈ supp F Q :=
      Finset.mem_filter.2 ⟨hf, lt_of_le_of_ne (hQ.1 f hf) (Ne.symm hQf)⟩
    rw [hne] at this
    simp at this
  have h0 : ∑ f ∈ F, Q f = 0 := Finset.sum_eq_zero this
  rw [hQ.2] at h0
  exact one_ne_zero h0

omit [Fintype Y] [DecidableEq Y] in
lemma mem_supp {f : X → Y} : f ∈ supp F Q ↔ f ∈ F ∧ 0 < Q f := Finset.mem_filter

omit [Fintype Y] [DecidableEq Y] in
lemma supp_subset : supp F Q ⊆ F := Finset.filter_subset _ _

omit [Fintype Y] in
/-- If `Q_x(y) > 0` then some `f` in the support of `Q` has `f(x) = y`. -/
lemma exists_supp_of_marg_pos {x : X} {y : Y}
    (hy : 0 < marg F Q x y) : ∃ f ∈ F, 0 < Q f ∧ f x = y := by
  by_contra hne
  push Not at hne
  have : marg F Q x y ≤ 0 := by
    apply Finset.sum_nonpos
    intro f hf
    have hf' := Finset.mem_filter.1 hf
    by_contra hlt
    exact hne f hf'.1 (lt_of_not_ge hlt) hf'.2
  linarith

omit [DecidableEq Y] in
lemma le_one_of_isProductHyp {h : X → Y → ℝ} (hh : IsProductHyp h) (x : X) (y : Y) :
    h x y ≤ 1 := by
  rw [← hh.2 x]
  exact Finset.single_le_sum (fun y _ => hh.1 x y) (Finset.mem_univ y)

omit [DecidableEq Y] in
lemma neg_log_nonneg_of_isProductHyp {h : X → Y → ℝ} (hh : IsProductHyp h) (x : X) (y : Y) :
    0 ≤ -Real.log (h x y) := by
  have := Real.log_nonpos (hh.1 x y) (le_one_of_isProductHyp hh x y)
  linarith

omit [DecidableEq Y] in
lemma loss_nonneg {h : X → Y → ℝ} (hh : IsProductHyp h) (x : I → X) (f : X → Y) :
    0 ≤ loss h x f :=
  Finset.sum_nonneg fun _ _ => neg_log_nonneg_of_isProductHyp hh _ _

/-- The expected loss decomposes over inputs into cross-entropies of the marginals:
`E_{f∼Q} loss h x f = ∑_i ∑_y Q_{x_i}(y) (-log h(y|x_i))`. -/
theorem expLoss_eq_sum_marg (F : Finset (X → Y)) (Q : (X → Y) → ℝ) (h : X → Y → ℝ)
    (x : I → X) :
    expLoss F Q h x = ∑ i, ∑ y, marg F Q (x i) y * -Real.log (h (x i) y) := by
  unfold expLoss loss
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => ?_
  exact sum_mul_comp_eq F Q (x i) (fun y => -Real.log (h (x i) y))

end Basic

/-! ## Theorem 2.1(i), real-valued form -/

section Main

variable {X Y I : Type*} [Fintype Y] [DecidableEq Y] [Fintype I]
variable {F : Finset (X → Y)} {Q : (X → Y) → ℝ} {h : X → Y → ℝ}

/-- **Second inequality of T5 Thm 2.1(i)** (Gibbs): `E_{f∼Q} loss ≥ ∑_i H(Q_{x_i})`, provided
`h` gives positive probability to the label of every `f` in the support of `Q`
(otherwise the paper's loss is `+∞`; see `thm_2_1_i_ennreal`). -/
theorem sum_entropy_le_expLoss (hQ : IsDistOn F Q) (hh : IsProductHyp h) (x : I → X)
    (hpos : ∀ f ∈ F, 0 < Q f → ∀ i, 0 < h (x i) (f (x i))) :
    ∑ i, entropy (marg F Q (x i)) ≤ expLoss F Q h x := by
  rw [expLoss_eq_sum_marg]
  refine Finset.sum_le_sum fun i _ => ?_
  refine gibbs (marg_nonneg hQ _) (by rw [sum_marg, hQ.2]) (hh.1 _) (le_of_eq (hh.2 _)) ?_
  intro y hy
  obtain ⟨f, hf, hQf, rfl⟩ := exists_supp_of_marg_pos hy
  exact hpos f hf hQf i

omit [Fintype Y] [DecidableEq Y] in
/-- **First inequality of T5 Thm 2.1(i)**: `max_{f ∈ supp Q} loss ≥ E_{f∼Q} loss`. -/
theorem expLoss_le_sup'_supp (hQ : IsDistOn F Q) (h : X → Y → ℝ) (x : I → X) :
    expLoss F Q h x ≤ (supp F Q).sup' (supp_nonempty hQ) (loss h x) := by
  set M := (supp F Q).sup' (supp_nonempty hQ) (loss h x)
  have hterm : ∀ f ∈ F, Q f * loss h x f ≤ Q f * M := by
    intro f hf
    rcases (hQ.1 f hf).eq_or_lt with h0 | hpos
    · rw [← h0]; simp
    · exact mul_le_mul_of_nonneg_left
        (Finset.le_sup' (loss h x) (mem_supp.2 ⟨hf, hpos⟩)) hpos.le
  calc expLoss F Q h x = ∑ f ∈ F, Q f * loss h x f := rfl
    _ ≤ ∑ f ∈ F, Q f * M := Finset.sum_le_sum hterm
    _ = M := by rw [← Finset.sum_mul, hQ.2, one_mul]

/-- **T5 Theorem 2.1(i)** (real-valued form). For every product hypothesis `h` and every
distribution `Q` on `F` such that `h` assigns positive probability to the labels produced by
the labelers in the support of `Q`:
`∑_i H(Q_{x_i}) ≤ E_{f∼Q}[∑_i -log h(f(x_i)|x_i)] ≤ max_{f ∈ supp Q} ∑_i -log h(f(x_i)|x_i)`. -/
theorem thm_2_1_i (hQ : IsDistOn F Q) (hh : IsProductHyp h) (x : I → X)
    (hpos : ∀ f ∈ F, 0 < Q f → ∀ i, 0 < h (x i) (f (x i))) :
    ∑ i, entropy (marg F Q (x i)) ≤ expLoss F Q h x ∧
      expLoss F Q h x ≤ (supp F Q).sup' (supp_nonempty hQ) (loss h x) :=
  ⟨sum_entropy_le_expLoss hQ hh x hpos, expLoss_le_sup'_supp hQ h x⟩

/-- Witness form of Thm 2.1(i): some `f` in the support of `Q` pays at least
`∑_i H(Q_{x_i})` (indeed at least the expected loss). -/
theorem thm_2_1_i_exists (hQ : IsDistOn F Q) (hh : IsProductHyp h) (x : I → X)
    (hpos : ∀ f ∈ F, 0 < Q f → ∀ i, 0 < h (x i) (f (x i))) :
    ∃ f ∈ F, 0 < Q f ∧ ∑ i, entropy (marg F Q (x i)) ≤ expLoss F Q h x ∧
      expLoss F Q h x ≤ loss h x f := by
  obtain ⟨f, hf, hfeq⟩ := Finset.exists_mem_eq_sup' (supp_nonempty hQ) (loss h x)
  have ⟨h1, h2⟩ := thm_2_1_i hQ hh x hpos
  rw [hfeq] at h2
  exact ⟨f, (mem_supp.1 hf).1, (mem_supp.1 hf).2, h1, h2⟩

/-- **T5 Theorem 2.1(i)**, the paper's displayed form: `max_{f∈F} loss ≥ ∑_i H(Q_{x_i})`. -/
theorem thm_2_1_i_maxF (hQ : IsDistOn F Q) (hh : IsProductHyp h) (x : I → X)
    (hpos : ∀ f ∈ F, 0 < Q f → ∀ i, 0 < h (x i) (f (x i))) :
    ∑ i, entropy (marg F Q (x i)) ≤
      F.sup' ((supp_nonempty hQ).mono supp_subset) (loss h x) := by
  obtain ⟨f, hf, -, h1, h2⟩ := thm_2_1_i_exists hQ hh x hpos
  exact le_trans (le_trans h1 h2) (Finset.le_sup' (loss h x) hf)

/-- Equality in the second inequality: the hypothesis `h(·|x) = Q_x` has expected loss exactly
`∑_i H(Q_{x_i})`. -/
theorem margHyp_expLoss (F : Finset (X → Y)) (Q : (X → Y) → ℝ) (x : I → X) :
    expLoss F Q (margHyp F Q) x = ∑ i, entropy (marg F Q (x i)) := by
  rw [expLoss_eq_sum_marg]
  refine Finset.sum_congr rfl fun i _ => ?_
  exact gibbs_eq _

end Main

/-! ## Theorem 2.1(i), extended-valued form (`-log 0 = ∞`), with no extra hypothesis -/

section Extended

variable {X Y I : Type*} [Fintype Y] [DecidableEq Y] [Fintype I]
variable {F : Finset (X → Y)} {Q : (X → Y) → ℝ} {h : X → Y → ℝ}

lemma nllE_of_pos {p : ℝ} (hp : 0 < p) : nllE p = ENNReal.ofReal (-Real.log p) := if_pos hp

lemma nllE_of_nonpos {p : ℝ} (hp : ¬ 0 < p) : nllE p = ⊤ := if_neg hp

omit [DecidableEq Y] in
/-- If every term is positive, the extended loss is the real loss. -/
lemma lossE_eq_ofReal (hh : IsProductHyp h) (x : I → X) {f : X → Y}
    (hf : ∀ i, 0 < h (x i) (f (x i))) : lossE h x f = ENNReal.ofReal (loss h x f) := by
  unfold lossE loss
  rw [ENNReal.ofReal_sum_of_nonneg fun i _ => neg_log_nonneg_of_isProductHyp hh _ _]
  exact Finset.sum_congr rfl fun i _ => nllE_of_pos (hf i)

omit [Fintype Y] [DecidableEq Y] in
lemma lossE_eq_top {x : I → X} {f : X → Y} {i : I} (hi : ¬ 0 < h (x i) (f (x i))) :
    lossE h x f = ⊤ :=
  ENNReal.sum_eq_top.2 ⟨i, Finset.mem_univ _, nllE_of_nonpos hi⟩

/-- **T5 Theorem 2.1(i)** (extended form, verbatim). For every product hypothesis `h` and every
distribution `Q` on `F`, with the log-loss valued in `[0, ∞]` (`-log 0 = ∞`):
`∑_i H(Q_{x_i}) ≤ E_{f∼Q}[∑_i -log h(f(x_i)|x_i)] ≤ max_{f ∈ supp Q} ∑_i -log h(f(x_i)|x_i)`. -/
theorem thm_2_1_i_ennreal (hQ : IsDistOn F Q) (hh : IsProductHyp h) (x : I → X) :
    ENNReal.ofReal (∑ i, entropy (marg F Q (x i))) ≤ expLossE F Q h x ∧
      expLossE F Q h x ≤ (supp F Q).sup (lossE h x) := by
  by_cases hbad : ∃ f ∈ F, 0 < Q f ∧ ∃ i, ¬ 0 < h (x i) (f (x i))
  · -- some labeler in the support gets probability `0`: both sides are `∞`
    obtain ⟨f, hf, hQf, i, hi⟩ := hbad
    have htop : lossE h x f = ⊤ := lossE_eq_top hi
    have hsup : (supp F Q).sup (lossE h x) = ⊤ := by
      apply top_unique
      rw [← htop]
      exact Finset.le_sup (f := lossE h x) (mem_supp.2 ⟨hf, hQf⟩)
    have hexp : expLossE F Q h x = ⊤ := by
      apply ENNReal.sum_eq_top.2
      refine ⟨f, hf, ?_⟩
      rw [htop]
      exact ENNReal.mul_top (by simpa using hQf)
    rw [hexp, hsup]
    exact ⟨le_top, le_rfl⟩
  · push Not at hbad
    -- reduce to the real-valued theorem
    have hreal := thm_2_1_i hQ hh x hbad
    have hterm : ∀ f ∈ F, ENNReal.ofReal (Q f) * lossE h x f =
        ENNReal.ofReal (Q f * loss h x f) := by
      intro f hf
      rcases (hQ.1 f hf).eq_or_lt with h0 | hpos
      · rw [← h0]; simp
      · rw [lossE_eq_ofReal hh x (hbad f hf hpos), ENNReal.ofReal_mul hpos.le]
    have hexp : expLossE F Q h x = ENNReal.ofReal (expLoss F Q h x) := by
      unfold expLossE expLoss
      rw [Finset.sum_congr rfl hterm, ENNReal.ofReal_sum_of_nonneg]
      intro f hf
      exact mul_nonneg (hQ.1 f hf) (loss_nonneg hh x f)
    refine ⟨?_, ?_⟩
    · rw [hexp]; exact ENNReal.ofReal_le_ofReal hreal.1
    · rw [hexp]
      obtain ⟨f, hf, hfeq⟩ := Finset.exists_mem_eq_sup' (supp_nonempty hQ) (loss h x)
      have hfF := mem_supp.1 hf
      calc ENNReal.ofReal (expLoss F Q h x) ≤ ENNReal.ofReal (loss h x f) := by
            apply ENNReal.ofReal_le_ofReal; rw [← hfeq]; exact hreal.2
        _ = lossE h x f := (lossE_eq_ofReal hh x (hbad f hfF.1 hfF.2)).symm
        _ ≤ (supp F Q).sup (lossE h x) := Finset.le_sup (f := lossE h x) hf

/-- **T5 Theorem 2.1(i)** (extended form), the paper's displayed `max_{f ∈ F}` version. -/
theorem thm_2_1_i_ennreal_maxF (hQ : IsDistOn F Q) (hh : IsProductHyp h) (x : I → X) :
    ENNReal.ofReal (∑ i, entropy (marg F Q (x i))) ≤ F.sup (lossE h x) := by
  obtain ⟨h1, h2⟩ := thm_2_1_i_ennreal hQ hh x
  exact h1.trans (h2.trans (Finset.sup_mono supp_subset))

end Extended

/-! ## The uniform hypothesis and uniform marginals -/

section Uniform

variable {X Y I : Type*} [Fintype Y] [DecidableEq Y] [Fintype I]
variable {F : Finset (X → Y)} {Q : (X → Y) → ℝ}

omit [Fintype Y] in
lemma mem_Fimg {f : X → Y} (hf : f ∈ F) (x : X) : f x ∈ Fimg F x :=
  Finset.mem_image_of_mem _ hf

omit [Fintype Y] in
lemma Fimg_nonempty (hF : F.Nonempty) (x : X) : (Fimg F x).Nonempty := hF.image _

omit [Fintype Y] in
lemma Fimg_card_pos (hF : F.Nonempty) (x : X) : (0 : ℝ) < ((Fimg F x).card : ℝ) := by
  exact_mod_cast (Fimg_nonempty hF x).card_pos

lemma unifHyp_isProductHyp (hF : F.Nonempty) : IsProductHyp (unifHyp F) := by
  refine ⟨fun x y => ?_, fun x => ?_⟩
  · unfold unifHyp
    split_ifs
    · exact div_nonneg zero_le_one (Nat.cast_nonneg _)
    · exact le_rfl
  · unfold unifHyp
    rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, nsmul_eq_mul]
    have := Fimg_card_pos hF x
    field_simp

omit [Fintype Y] in
lemma unifHyp_pos {f : X → Y} (hf : f ∈ F) (x : X) : 0 < unifHyp F x (f x) := by
  unfold unifHyp
  rw [if_pos (mem_Fimg hf x)]
  exact div_pos one_pos (Fimg_card_pos ⟨f, hf⟩ x)

omit [Fintype Y] in
/-- The uniform hypothesis pays exactly `∑_i log |F(x_i)|` against **every** `f ∈ F`. -/
theorem unifHyp_loss (x : I → X) {f : X → Y} (hf : f ∈ F) :
    loss (unifHyp F) x f = ∑ i, Real.log ((Fimg F (x i)).card : ℝ) := by
  unfold loss
  refine Finset.sum_congr rfl fun i _ => ?_
  unfold unifHyp
  rw [if_pos (mem_Fimg hf (x i)), one_div, Real.log_inv, neg_neg]

omit [Fintype Y] in
/-- The worst-case loss of the uniform hypothesis is `∑_i log |F(x_i)|`. -/
theorem unifHyp_sup' (x : I → X) (hF : F.Nonempty) :
    F.sup' hF (loss (unifHyp F) x) = ∑ i, Real.log ((Fimg F (x i)).card : ℝ) := by
  obtain ⟨f, hf, hfeq⟩ := Finset.exists_mem_eq_sup' hF (loss (unifHyp F) x)
  rw [hfeq, unifHyp_loss x hf]

/-- The extended worst-case loss of the uniform hypothesis is `∑_i log |F(x_i)|`. -/
theorem unifHyp_supE (x : I → X) (hF : F.Nonempty) :
    F.sup (lossE (unifHyp F) x) = ENNReal.ofReal (∑ i, Real.log ((Fimg F (x i)).card : ℝ)) := by
  have hall : ∀ f ∈ F, lossE (unifHyp F) x f =
      ENNReal.ofReal (∑ i, Real.log ((Fimg F (x i)).card : ℝ)) := by
    intro f hf
    rw [lossE_eq_ofReal (unifHyp_isProductHyp hF) x (fun i => unifHyp_pos hf (x i)),
      unifHyp_loss x hf]
  apply le_antisymm
  · exact Finset.sup_le fun f hf => (hall f hf).le
  · obtain ⟨f, hf⟩ := hF
    rw [← hall f hf]
    exact Finset.le_sup (f := lossE (unifHyp F) x) hf

/-- For every `Q`, `∑_i H(Q_{x_i}) ≤ ∑_i log |F(x_i)|` (Thm 2.1(i) applied to the uniform
hypothesis; "so the value is at most that"). -/
theorem sum_entropy_le_sum_log_card (hQ : IsDistOn F Q) (x : I → X) :
    ∑ i, entropy (marg F Q (x i)) ≤ ∑ i, Real.log ((Fimg F (x i)).card : ℝ) := by
  have hF : F.Nonempty := (supp_nonempty hQ).mono supp_subset
  have h := thm_2_1_i_maxF hQ (unifHyp_isProductHyp hF) x
    (fun f hf _ i => unifHyp_pos hf (x i))
  rwa [unifHyp_sup'] at h

omit [Fintype Y] in
lemma marg_eq_zero_of_not_mem {x : X} {y : Y} (hy : y ∉ Fimg F x) : marg F Q x y = 0 := by
  unfold marg
  apply Finset.sum_eq_zero
  intro f hf
  exfalso
  have hf' := Finset.mem_filter.1 hf
  exact hy (hf'.2 ▸ mem_Fimg hf'.1 x)

/-- If `Q_x` is uniform on `F(x)`, then `H(Q_x) = log |F(x)|`. -/
theorem entropy_marg_of_uniform {x : X}
    (hU : ∀ y ∈ Fimg F x, marg F Q x y = 1 / ((Fimg F x).card : ℝ)) :
    entropy (marg F Q x) = Real.log ((Fimg F x).card : ℝ) := by
  unfold entropy
  have hterm : ∀ y, -(marg F Q x y * Real.log (marg F Q x y)) =
      if y ∈ Fimg F x then (1 / ((Fimg F x).card : ℝ)) * Real.log ((Fimg F x).card : ℝ)
      else 0 := by
    intro y
    split_ifs with hy
    · rw [hU y hy, one_div, Real.log_inv]; ring
    · rw [marg_eq_zero_of_not_mem hy]; simp
  rw [Finset.sum_congr rfl fun y _ => hterm y, Finset.sum_ite_mem, Finset.univ_inter,
    Finset.sum_const, nsmul_eq_mul]
  rcases (Fimg F x).eq_empty_or_nonempty with he | hne
  · simp [he]
  · have : (0 : ℝ) < ((Fimg F x).card : ℝ) := by exact_mod_cast hne.card_pos
    field_simp

/-- If `Q` has uniform marginals on every `F(x_i)`, then `∑_i H(Q_{x_i}) = ∑_i log |F(x_i)|`:
the bound of Thm 2.1(i) equals the loss of the uniform hypothesis. -/
theorem sum_entropy_of_uniform {x : I → X} (hU : UniformMarginals F Q x) :
    ∑ i, entropy (marg F Q (x i)) = ∑ i, Real.log ((Fimg F (x i)).card : ℝ) :=
  Finset.sum_congr rfl fun i _ => entropy_marg_of_uniform (hU i)

/-- **Minimax value under uniform marginals** (T5 Thm 2.1(i), "it equals `∑_i log |F(x_i)|`
if some `Q` has uniform marginals on every `F(x_i)`"; real-valued form).
(1) Every product hypothesis `h` that gives positive probability to every label in `F(x_i)`
has worst-case loss `≥ ∑_i log |F(x_i)|`; (2) the uniform hypothesis is a product
hypothesis whose worst-case loss is exactly `∑_i log |F(x_i)|`.  (Product hypotheses that give
probability `0` to some `f(x_i)` have infinite worst-case loss; see the extended version.) -/
theorem minimax_of_uniform_marginals (hQ : IsDistOn F Q) (x : I → X)
    (hU : UniformMarginals F Q x) :
    (∀ h : X → Y → ℝ, IsProductHyp h → (∀ f ∈ F, ∀ i, 0 < h (x i) (f (x i))) →
      ∑ i, Real.log ((Fimg F (x i)).card : ℝ) ≤
        F.sup' ((supp_nonempty hQ).mono supp_subset) (loss h x)) ∧
    IsProductHyp (unifHyp F) ∧
    F.sup' ((supp_nonempty hQ).mono supp_subset) (loss (unifHyp F) x) =
      ∑ i, Real.log ((Fimg F (x i)).card : ℝ) := by
  refine ⟨fun h hh hpos => ?_, unifHyp_isProductHyp ((supp_nonempty hQ).mono supp_subset),
    unifHyp_sup' x _⟩
  rw [← sum_entropy_of_uniform hU]
  exact thm_2_1_i_maxF hQ hh x (fun f hf _ i => hpos f hf i)

/-- **Minimax value under uniform marginals**, extended form: for **every** product hypothesis
`h`, `max_{f∈F} lossE ≥ ∑_i log |F(x_i)|`, and the uniform hypothesis attains equality. So
`min_h max_{f∈F} ∑_i -log h(f(x_i)|x_i) = ∑_i log |F(x_i)|`. -/
theorem minimax_of_uniform_marginals_ennreal (hQ : IsDistOn F Q) (x : I → X)
    (hU : UniformMarginals F Q x) :
    (∀ h : X → Y → ℝ, IsProductHyp h →
      ENNReal.ofReal (∑ i, Real.log ((Fimg F (x i)).card : ℝ)) ≤ F.sup (lossE h x)) ∧
    IsProductHyp (unifHyp F) ∧
    F.sup (lossE (unifHyp F) x) = ENNReal.ofReal (∑ i, Real.log ((Fimg F (x i)).card : ℝ)) := by
  have hF : F.Nonempty := (supp_nonempty hQ).mono supp_subset
  refine ⟨fun h hh => ?_, unifHyp_isProductHyp hF, unifHyp_supE x hF⟩
  rw [← sum_entropy_of_uniform hU]
  exact thm_2_1_i_ennreal_maxF hQ hh x

omit [Fintype Y] [DecidableEq Y] in
/-- `Unif(F)` is a distribution on `F` (for nonempty `F`). -/
lemma unifDist_isDistOn (hF : F.Nonempty) : IsDistOn F (unifDist F) := by
  refine ⟨fun f _ => div_nonneg zero_le_one (Nat.cast_nonneg _), ?_⟩
  unfold unifDist
  rw [Finset.sum_const, nsmul_eq_mul]
  have : (0 : ℝ) < (F.card : ℝ) := by exact_mod_cast hF.card_pos
  field_simp

omit [Fintype Y] in
/-- **The group condition** (T5 Thm 2.1(i), as revised in Verification log A4). Suppose a
family of label permutations `σ g x` (indexed by `g : G`) acts on `F` by
`(g·f)(x) = σ_{g,x}(f(x))` (i.e. `F` is closed under each `g·`), and the induced action on
every `F(x)` is transitive. Then `Q = Unif(F)` has uniform marginals: `Q_x = Unif(F(x))` for
every `x`. (No group axioms are needed.) -/
theorem uniform_marginals_of_transitive {G : Type*} (σ : G → X → Equiv.Perm Y)
    (hF : F.Nonempty)
    (hclosed : ∀ g, ∀ f ∈ F, (fun x => σ g x (f x)) ∈ F)
    (htrans : ∀ x, ∀ y ∈ Fimg F x, ∀ y' ∈ Fimg F x, ∃ g, σ g x y = y') (x : X) :
    ∀ y ∈ Fimg F x, marg F (unifDist F) x y = 1 / ((Fimg F x).card : ℝ) := by
  classical
  -- fibre cardinalities are all equal
  have hle : ∀ y ∈ Fimg F x, ∀ y' ∈ Fimg F x,
      (F.filter (fun f => f x = y)).card ≤ (F.filter (fun f => f x = y')).card := by
    intro y hy y' hy'
    obtain ⟨g, hg⟩ := htrans x y hy y' hy'
    apply Finset.card_le_card_of_injOn (fun f => fun x => σ g x (f x))
    · intro f hf
      have hf' := Finset.mem_filter.1 hf
      refine Finset.mem_filter.2 ⟨hclosed g f hf'.1, ?_⟩
      show σ g x (f x) = y'
      rw [hf'.2, hg]
    · intro f₁ _ f₂ _ heq
      funext z
      have := congrFun heq z
      exact (σ g z).injective this
  have heq : ∀ y ∈ Fimg F x, ∀ y' ∈ Fimg F x,
      (F.filter (fun f => f x = y)).card = (F.filter (fun f => f x = y')).card :=
    fun y hy y' hy' => le_antisymm (hle y hy y' hy') (hle y' hy' y hy)
  intro y hy
  have hcard : F.card = ∑ b ∈ Fimg F x, (F.filter (fun f => f x = b)).card :=
    Finset.card_eq_sum_card_fiberwise (fun f hf => mem_Fimg hf x)
  rw [Finset.sum_congr rfl (fun b hb => heq b hb y hy), Finset.sum_const, smul_eq_mul] at hcard
  have hpos : 0 < (F.filter (fun f => f x = y)).card := by
    obtain ⟨f, hf, rfl⟩ := Finset.mem_image.1 hy
    exact Finset.card_pos.2 ⟨f, Finset.mem_filter.2 ⟨hf, rfl⟩⟩
  have hFx : (0 : ℝ) < ((Fimg F x).card : ℝ) := Fimg_card_pos hF x
  have hcR : (0 : ℝ) < ((F.filter (fun f => f x = y)).card : ℝ) := by exact_mod_cast hpos
  unfold marg unifDist
  rw [Finset.sum_const, nsmul_eq_mul, hcard]
  push_cast
  field_simp

/-- Corollary: under the group condition, the minimax value over product hypotheses is
`∑_i log |F(x_i)|`, attained by the uniform hypothesis. -/
theorem minimax_of_transitive {G : Type*} (σ : G → X → Equiv.Perm Y) (hF : F.Nonempty)
    (hclosed : ∀ g, ∀ f ∈ F, (fun x => σ g x (f x)) ∈ F)
    (htrans : ∀ x, ∀ y ∈ Fimg F x, ∀ y' ∈ Fimg F x, ∃ g, σ g x y = y') (x : I → X) :
    (∀ h : X → Y → ℝ, IsProductHyp h →
      ENNReal.ofReal (∑ i, Real.log ((Fimg F (x i)).card : ℝ)) ≤ F.sup (lossE h x)) ∧
    F.sup (lossE (unifHyp F) x) = ENNReal.ofReal (∑ i, Real.log ((Fimg F (x i)).card : ℝ)) :=
  let h := minimax_of_uniform_marginals_ennreal (unifDist_isDistOn hF) x
    (fun i => uniform_marginals_of_transitive σ hF hclosed htrans (x i))
  ⟨h.1, h.2.2⟩

end Uniform

/-! ## The paper's example: uniform marginals are needed

`F = {(a,a),(a,b),(b,a),(c,a)}` on two inputs, with `a,b,c = 0,1,2 : Fin 3`; a labeler is a
function `Fin 2 → Fin 3` (its values on input `0` and input `1`), and the input list is
`x = id : Fin 2 → Fin 2`. Then `|F(x_1)| = 3`, `|F(x_2)| = 2`. -/

namespace Example

/-- `F = {(a,a),(a,b),(b,a),(c,a)}`. -/
def F : Finset (Fin 2 → Fin 3) := {![0, 0], ![0, 1], ![1, 0], ![2, 0]}

/-- The two inputs `x_1 = 0`, `x_2 = 1`. -/
def xs : Fin 2 → Fin 2 := id

lemma Fimg_card_zero : (Fimg F 0).card = 3 := by decide
lemma Fimg_card_one : (Fimg F 1).card = 2 := by decide

/-- No distribution on `F` has uniform marginals on both `F(x_1) = {a,b,c}` and
`F(x_2) = {a,b}`. -/
theorem no_uniform_marginals (Q : (Fin 2 → Fin 3) → ℝ) (hQ : IsDistOn F Q) :
    ¬ UniformMarginals F Q xs := by
  intro hU
  have h00 := hU 0 0 (by decide)
  have h11 := hU 1 1 (by decide)
  simp only [xs, id, Fimg_card_zero, Fimg_card_one] at h00 h11
  have e00 : F.filter (fun f => f 0 = 0) = {![0, 0], ![0, 1]} := by decide
  have e11 : F.filter (fun f => f 1 = 1) = {![0, 1]} := by decide
  unfold marg at h00 h11
  rw [e11, Finset.sum_singleton] at h11
  rw [e00, Finset.sum_pair (by decide)] at h00
  have hnn : 0 ≤ Q ![0, 0] := hQ.1 _ (by decide)
  norm_num at h00 h11
  linarith

/-- An explicit product hypothesis: `h(·|x_1) = (3/7, 2/7, 2/7)`, `h(·|x_2) = (3/5, 2/5, 0)`. -/
noncomputable def hstar : Fin 2 → Fin 3 → ℝ := ![![3/7, 2/7, 2/7], ![3/5, 2/5, 0]]

lemma hstar_isProductHyp : IsProductHyp hstar := by
  refine ⟨fun x y => ?_, fun x => ?_⟩
  · fin_cases x <;> fin_cases y <;> simp [hstar] <;> norm_num
  · fin_cases x <;> simp [hstar, Fin.sum_univ_three] <;> norm_num

private lemma two_term_lt (a b : ℝ) (ha : 0 < a) (hb : 0 < b) (h : 1 < 6 * (a * b)) :
    -Real.log a + -Real.log b < Real.log 3 + Real.log 2 := by
  have h1 : 0 < Real.log (6 * (a * b)) := Real.log_pos h
  rw [Real.log_mul (by norm_num) (by positivity), Real.log_mul ha.ne' hb.ne'] at h1
  have h6 : Real.log 6 = Real.log 3 + Real.log 2 := by
    rw [← Real.log_mul (by norm_num) (by norm_num)]; norm_num
  linarith

/-- Every labeler in `F` has loss `< log 3 + log 2` under `hstar` (the worst case is
`log(35/6) ≈ 1.7636` nats, vs `log 6 ≈ 1.7918`). -/
theorem hstar_loss_lt (f : Fin 2 → Fin 3) (hf : f ∈ F) :
    loss hstar xs f < Real.log 3 + Real.log 2 := by
  unfold loss
  rw [Fin.sum_univ_two]
  simp only [F, Finset.mem_insert, Finset.mem_singleton] at hf
  rcases hf with rfl | rfl | rfl | rfl <;>
    · simp only [xs, id, hstar, Matrix.cons_val_zero, Matrix.cons_val_one,
        Matrix.cons_val_two]
      apply two_term_lt <;> norm_num

/-- **The uniform-marginal hypothesis cannot be dropped** (T5 Thm 2.1(i), the example of
Verification log A4). For `F = {(a,a),(a,b),(b,a),(c,a)}` on two inputs the product hypothesis
`hstar` has worst-case loss strictly below `∑_i log |F(x_i)| = log 3 + log 2`, the worst-case
loss of the uniform hypothesis. Hence `min_h max_f loss < ∑_i log |F(x_i)|` here, and (by
Thm 2.1(i)) `∑_i H(Q_{x_i}) < ∑_i log |F(x_i)|` for every distribution `Q` on `F`. -/
theorem value_lt_sum_log_card (hF : F.Nonempty) :
    F.sup' hF (loss hstar xs) < ∑ i, Real.log ((Fimg F (xs i)).card : ℝ) ∧
    F.sup' hF (loss (unifHyp F) xs) = ∑ i, Real.log ((Fimg F (xs i)).card : ℝ) := by
  have hsum : ∑ i, Real.log ((Fimg F (xs i)).card : ℝ) = Real.log 3 + Real.log 2 := by
    rw [Fin.sum_univ_two]
    simp only [xs, id, Fimg_card_zero, Fimg_card_one]
    norm_num
  refine ⟨?_, unifHyp_sup' xs hF⟩
  rw [hsum, Finset.sup'_lt_iff]
  exact hstar_loss_lt

/-- Consequently, for every distribution `Q` on this `F`,
`∑_i H(Q_{x_i}) < log 3 + log 2 = ∑_i log |F(x_i)|`. -/
theorem sum_entropy_lt (Q : (Fin 2 → Fin 3) → ℝ) (hQ : IsDistOn F Q) :
    ∑ i, entropy (marg F Q (xs i)) < ∑ i, Real.log ((Fimg F (xs i)).card : ℝ) := by
  have hF : F.Nonempty := (supp_nonempty hQ).mono supp_subset
  have hpos : ∀ f ∈ F, 0 < Q f → ∀ i, 0 < hstar (xs i) (f (xs i)) := by
    intro f hf _ i
    simp only [F, Finset.mem_insert, Finset.mem_singleton] at hf
    rcases hf with rfl | rfl | rfl | rfl <;> fin_cases i <;> simp [hstar, xs]
  have h1 := thm_2_1_i_maxF hQ hstar_isProductHyp xs hpos
  exact lt_of_le_of_lt h1 (value_lt_sum_log_card hF).1

end Example

end InfLearn.NoAdaptation

/-! ## Axiom audit -/

#print axioms InfLearn.NoAdaptation.gibbs
#print axioms InfLearn.NoAdaptation.expLoss_eq_sum_marg
#print axioms InfLearn.NoAdaptation.thm_2_1_i
#print axioms InfLearn.NoAdaptation.thm_2_1_i_exists
#print axioms InfLearn.NoAdaptation.thm_2_1_i_maxF
#print axioms InfLearn.NoAdaptation.margHyp_expLoss
#print axioms InfLearn.NoAdaptation.thm_2_1_i_ennreal
#print axioms InfLearn.NoAdaptation.thm_2_1_i_ennreal_maxF
#print axioms InfLearn.NoAdaptation.unifHyp_loss
#print axioms InfLearn.NoAdaptation.unifHyp_supE
#print axioms InfLearn.NoAdaptation.sum_entropy_le_sum_log_card
#print axioms InfLearn.NoAdaptation.sum_entropy_of_uniform
#print axioms InfLearn.NoAdaptation.minimax_of_uniform_marginals
#print axioms InfLearn.NoAdaptation.minimax_of_uniform_marginals_ennreal
#print axioms InfLearn.NoAdaptation.uniform_marginals_of_transitive
#print axioms InfLearn.NoAdaptation.minimax_of_transitive
#print axioms InfLearn.NoAdaptation.Example.no_uniform_marginals
#print axioms InfLearn.NoAdaptation.Example.value_lt_sum_log_card
#print axioms InfLearn.NoAdaptation.Example.sum_entropy_lt
