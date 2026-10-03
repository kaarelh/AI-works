import InfLearn.Prelude

/-!
# T5 §3: rate thresholds and the convex hull; T4 Cor 7.2 and Prop 7.3

This file formalises, in finite form, the rate-threshold results of
`research/theory/T5-steeper-simplicity-and-normativity-from-imitation.md` (§3.1–3.2 and
Thm 4.1(ii)) and the steeper-penalty results of
`research/theory/T4-informal-math-latent-formalization.md` (§7: Prop 7.1, Cor 7.2, Prop 7.3),
including the corrections recorded in both files' *Verification log*s
(T5 B6, B21, B22; T4 C12–C14).

Everything is about the Lagrangian `J_c(h) = c·ℓ(h) + R(h)` (`c = λ/N`), with real numbers and
finite sums.

## 1. Theorem 3.2, product classes (first bullet)
`prodObj c ℓ R h = c · ∑_j ℓ_j(h_j) + ∑_j R_j(h_j)` for `h : ∀ j, H j` over finitely many
regions `j`.  `prod_isMin_iff`: `h` minimises iff every `h_j` minimises its own region
objective `c ℓ_j + R_j` (minimisers are exactly the products of per-region minimisers);
`prod_isUniqueMin_iff`: the same for unique minimisers.

## 2. Theorem 3.2, binary components (second bullet) = T4 Prop 7.1
Components `j : ι` (`Fintype`), cost `k j` bits, risk reduction `r j`,
`J c base R0 k r S = c * (base + ∑_{j∈S} k j) + (R0 - ∑_{j∈S} r j)`,
`Sstar c k r = {j | c * k j < r j}` (= `{j | r_j/k_j > c}` when `k_j > 0`).
* `rate_threshold` (the task's item (1), bundled): `S*` minimises `J_c` for every real `c`;
  without ties it is the only minimiser and strictly beats every other subset.
* `Sstar_isMinimizer`: `S*` minimises `J_c` (for every real `c`).
* `isMinimizer_iff`: **all** minimisers: `{j | r_j > c k_j} ⊆ S ⊆ {j | r_j ≥ c k_j}`
  ("ties are arbitrary", also `ties_arbitrary`).
* `isMinimizer_iff_eq_Sstar`, `isUniqueMinimizer_iff`: without ties `S*` is the unique
  minimiser; and `S` is the unique minimiser iff `S = S*` and there is no tie.
* `thm_3_2`, `thm_3_2_unique`: the rate form (`k_j > 0`): `j` selected iff `r_j/k_j > c`.
* `rate_blindness` (T5 Thm 4.1(ii), Thm 3.2 setting): if a valid `v` is selected and
  `rate v ≤ rate e`, then `e` is selected, except at a common tie `c = rate v = rate e`.

## 3. Selectability (T4 Cor 7.2; the task's corollary)
* `selectable_iff`: some `c > 0` makes `V` the **unique** minimiser iff every `j ∈ V` has
  positive rate and out-rates every `i ∉ V`.
* `selectable_iff_fold`: the same as `min_{j∈V} rate_j > max_{i∉V} rate_i` with the paper's
  conventions `max ∅ = 0` (T4 Cor 7.2) and `min ∅ = +∞`.
* `selectable_iff_sup'_lt_inf'`: for `V`, `Vᶜ` nonempty and `r ≥ 0`, literally
  `max_{i∉V} r_i/k_i < min_{j∈V} r_j/k_j`.
* `exists_Sstar_eq_iff`: the same criterion for `S*(c) = V`; `weakly_selectable_iff`: `V` is a
  (possibly non-unique) minimiser for some `c > 0` iff the weak inequality holds (and rates in
  `V` are positive).

## 4. Lemma 3.1 (the convex-hull selection lemma), finite form
Finitely many hypotheses `h : H` with points `P_h = (ℓ h, R h)`.  `InHull ℓ R x y` is
membership of `(x,y)` in `conv(A) + ℝ²≥0 = conv(A + ℝ²≥0)` (finite convex weights).
* (i) `isMinAt_le_of_inHull`: a minimiser of `J_c` (`c ≥ 0`) lies on a supporting line of slope
  `-c` of `conv(A + ℝ²≥0)`; `onLowerHull_iff`: `P_h ∈ hull⁻(A)` iff `h` minimises `J_c` for some
  `c > 0`.
* (ii) `lemma_3_1_ii`: monotonicity of minimisers in `c`.
* (iii) `lemma_3_1_iii`: `P_h` is the unique minimising point for all `c` in a nonempty open
  interval of positive reals iff `P_h` is a vertex of `hull⁻(A)` (an extreme point of
  `conv(A + ℝ²≥0)` lying on `hull⁻(A)`); `lemma_3_1_iii_hyp`: the hypothesis `h` is the unique
  minimiser there iff moreover no other hypothesis has the same point;
  `uniquePoint_iff_rates`: the set of such `c` is the open interval cut out by the chord rates
  (`(s₊, s₋)`).  Equivalent finite characterisations: `chord_iff_extreme` (strictly below every
  chord, not weakly dominated) and `chord_iff_notInOthersHull` (`P_h ∉ conv((A∖{P_h}) + ℝ²≥0)`).

## 5. The counterexample (T4 Prop 7.3; T5 rate inversion, Thm 4.1 / Prop 4.2)
Rules `A` (common valid, ℓ=10, π=0.5, g=8), `B` (rare long valid, ℓ=40, π=0.01, g=8) and the
freshman's dream `F` (short frequent fallacy, ℓ=8, π=0.05, g=8); rates 0.4, 0.002, 0.05.
* `valid_not_minimizer`: for **every** real `c`, `{A,B}` is not even a (weak) minimiser of `J_c`.
* `not_selectable`: no `c > 0` selects exactly the valid set.
* `Sstar_low/mid/high/top`: the selection path `{A,B,F} → {A,F} → {A} → ∅`.
* `pareto_dominated`, `no_monotone_criterion`: `{A,F} = (18, 0.08)` Pareto-dominates
  `{A,B} = (50, 0.4)`, so no criterion strictly increasing in both coordinates selects `{A,B}`.
* `valid_not_hullVertex`, `valid_never_vertex`: the point of `{A,B}` is not a `hull⁻` vertex, in
  any finite hypothesis class containing a hypothesis at the point of `{A,F}`.

## Scope and deviations from the paper
* Lemma 3.1 is proved for a **finite** hypothesis class (the paper allows countably many
  hypotheses with finite sublevel sets of `ℓ`; only finitely many matter for any bounded `c`
  range, but that reduction is not formalised).  Convex hulls are encoded by finite convex
  weights on hypotheses (`InHull`); no Mathlib convexity library is used.
* Lemma 3.1(ii) assumes `0 ≤ c` (the paper's `c > 0`).
* The T4 Prop 7.3 remarks "the full-hull vertices are ∅, {A}, {A,F}, {A,B,F}, {B,F}, {B}" and
  "{A,B} lies strictly inside the hull of the other points" are not formalised; we prove the
  stronger-for-our-purposes Pareto-dominance statement and that `{A,B}` is never a `hull⁻`
  vertex, whatever other hypotheses are added.
-/

set_option linter.unusedSectionVars false

namespace InfLearn
namespace RateThreshold

open Finset

/-! ## 0. A gap lemma -/

/-- Between a finite family of reals `f i` and a finite family of positive reals `g j` with
`f i < g j` for all `i, j` there is a nonempty open interval `(a, b)` with `0 ≤ a`. -/
theorem exists_gap {α β : Type*} (s : Finset α) (t : Finset β) (f : α → ℝ) (g : β → ℝ)
    (hfg : ∀ i ∈ s, ∀ j ∈ t, f i < g j) (hg : ∀ j ∈ t, 0 < g j) :
    ∃ a b : ℝ, 0 ≤ a ∧ a < b ∧ (∀ i ∈ s, f i ≤ a) ∧ (∀ j ∈ t, b ≤ g j) := by
  refine ⟨s.fold max 0 f, t.fold min (s.fold max 0 f + 1) g, ?_, ?_, ?_, ?_⟩
  · exact (Finset.le_fold_max _).2 (Or.inl le_rfl)
  · refine (Finset.lt_fold_min _).2 ⟨by linarith, fun j hj => ?_⟩
    exact (Finset.fold_max_lt _).2 ⟨hg j hj, fun i hi => hfg i hi j hj⟩
  · intro i hi; exact (Finset.le_fold_max _).2 (Or.inr ⟨i, hi, le_rfl⟩)
  · intro j hj; exact (Finset.fold_min_le _).2 (Or.inr ⟨j, hj, le_rfl⟩)

/-! ## 1. Theorem 3.2, first bullet: product classes -/

section Product

variable {ι : Type*} [Fintype ι] [DecidableEq ι] {H : ι → Type*}

/-- The per-region objective `c ℓ_j(x) + R_j(x)`. -/
def regObj (c : ℝ) (ℓ R : ∀ j, H j → ℝ) (j : ι) (x : H j) : ℝ := c * ℓ j x + R j x

/-- `J_c(h) = c ℓ(h) + R(h)` on the product class, with `ℓ(h) = ∑_j ℓ_j(h_j)` (concatenated
codes) and `R(h) = ∑_j R_j(h_j)` (risk on disjoint regions). -/
def prodObj (c : ℝ) (ℓ R : ∀ j, H j → ℝ) (h : ∀ j, H j) : ℝ :=
  c * ∑ j, ℓ j (h j) + ∑ j, R j (h j)

/-- T5 Thm 3.2: `J_c(h) = ∑_j [c ℓ_j(h_j) + R_j(h_j)]`. -/
theorem prodObj_eq_sum (c : ℝ) (ℓ R : ∀ j, H j → ℝ) (h : ∀ j, H j) :
    prodObj c ℓ R h = ∑ j, regObj c ℓ R j (h j) := by
  simp only [prodObj, regObj, Finset.sum_add_distrib, Finset.mul_sum]

theorem prodObj_update (c : ℝ) (ℓ R : ∀ j, H j → ℝ) (h : ∀ j, H j) (j : ι) (x : H j) :
    prodObj c ℓ R (Function.update h j x) =
      prodObj c ℓ R h - regObj c ℓ R j (h j) + regObj c ℓ R j x := by
  rw [prodObj_eq_sum, prodObj_eq_sum,
    ← Finset.add_sum_erase univ (fun i => regObj c ℓ R i (Function.update h j x i)) (mem_univ j),
    ← Finset.add_sum_erase univ (fun i => regObj c ℓ R i (h i)) (mem_univ j)]
  have : ∑ i ∈ univ.erase j, regObj c ℓ R i (Function.update h j x i) =
      ∑ i ∈ univ.erase j, regObj c ℓ R i (h i) := by
    refine Finset.sum_congr rfl fun i hi => ?_
    rw [Function.update_of_ne (Finset.ne_of_mem_erase hi)]
  simp only [this, Function.update_self]
  ring

/-- **T5 Theorem 3.2 (product classes), first bullet.** A product hypothesis minimises `J_c`
iff each of its components minimises its own region objective: the minimisers are exactly the
products of per-region minimisers. -/
theorem prod_isMin_iff (c : ℝ) (ℓ R : ∀ j, H j → ℝ) (h : ∀ j, H j) :
    (∀ h', prodObj c ℓ R h ≤ prodObj c ℓ R h') ↔
      ∀ j (x : H j), regObj c ℓ R j (h j) ≤ regObj c ℓ R j x := by
  constructor
  · intro hmin j x
    have := hmin (Function.update h j x)
    rw [prodObj_update] at this
    linarith
  · intro hloc h'
    rw [prodObj_eq_sum, prodObj_eq_sum]
    exact Finset.sum_le_sum fun j _ => hloc j (h' j)

/-- Unique-minimiser version of `prod_isMin_iff`. -/
theorem prod_isUniqueMin_iff (c : ℝ) (ℓ R : ∀ j, H j → ℝ) (h : ∀ j, H j) :
    (∀ h', h' ≠ h → prodObj c ℓ R h < prodObj c ℓ R h') ↔
      ∀ j (x : H j), x ≠ h j → regObj c ℓ R j (h j) < regObj c ℓ R j x := by
  constructor
  · intro hmin j x hx
    have hne : Function.update h j x ≠ h := by
      intro heq
      apply hx
      have := congrFun heq j
      rwa [Function.update_self] at this
    have := hmin _ hne
    rw [prodObj_update] at this
    linarith
  · intro hloc h' hne
    obtain ⟨j, hj⟩ := Function.ne_iff.1 hne
    rw [prodObj_eq_sum, prodObj_eq_sum]
    refine Finset.sum_lt_sum (fun i _ => ?_) ⟨j, mem_univ j, hloc j (h' j) hj⟩
    by_cases hi : h' i = h i
    · rw [hi]
    · exact (hloc i (h' i) hi).le

end Product

/-! ## 2. Theorem 3.2, second bullet: independent binary components -/

section Binary

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The objective over component sets `S`:
`J(S) = c · (base + ∑_{j∈S} k_j) + (R0 - ∑_{j∈S} r_j)`. -/
def J (c base R0 : ℝ) (k r : ι → ℝ) (S : Finset ι) : ℝ :=
  c * (base + ∑ j ∈ S, k j) + (R0 - ∑ j ∈ S, r j)

/-- The threshold set `S* = {j | r_j > c k_j}`. -/
noncomputable def Sstar (c : ℝ) (k r : ι → ℝ) : Finset ι :=
  univ.filter (fun j => c * k j < r j)

/-- The rate `r_j / k_j` of component `j`. -/
noncomputable def rate (k r : ι → ℝ) (j : ι) : ℝ := r j / k j

/-- `S` minimises `J_c` over all component sets. -/
def IsMinimizer (c base R0 : ℝ) (k r : ι → ℝ) (S : Finset ι) : Prop :=
  ∀ S' : Finset ι, J c base R0 k r S ≤ J c base R0 k r S'

/-- `S` is the unique minimiser of `J_c`. -/
def IsUniqueMinimizer (c base R0 : ℝ) (k r : ι → ℝ) (S : Finset ι) : Prop :=
  ∀ S' : Finset ι, S' ≠ S → J c base R0 k r S < J c base R0 k r S'

variable {c base R0 : ℝ} {k r : ι → ℝ}

theorem mem_Sstar {j : ι} : j ∈ Sstar c k r ↔ c * k j < r j := by
  simp [Sstar]

theorem J_eq (S : Finset ι) :
    J c base R0 k r S = c * base + R0 + ∑ j ∈ S, (c * k j - r j) := by
  simp only [J, Finset.sum_sub_distrib, ← Finset.mul_sum]
  ring

theorem J_insert {S : Finset ι} {j : ι} (hj : j ∉ S) :
    J c base R0 k r (insert j S) = J c base R0 k r S + (c * k j - r j) := by
  rw [J_eq, J_eq, Finset.sum_insert hj]
  ring

theorem J_erase {S : Finset ι} {j : ι} (hj : j ∈ S) :
    J c base R0 k r (S.erase j) = J c base R0 k r S - (c * k j - r j) := by
  rw [J_eq, J_eq, Finset.sum_erase_eq_sub hj]
  ring

/-- **All minimisers of `J_c`** (any real `c`): `S` minimises iff it contains every strictly
profitable component and only weakly profitable ones (ties are arbitrary). -/
theorem isMinimizer_iff {S : Finset ι} :
    IsMinimizer c base R0 k r S ↔
      (∀ j, c * k j < r j → j ∈ S) ∧ (∀ j ∈ S, c * k j ≤ r j) := by
  constructor
  · intro hmin
    refine ⟨fun j hj => ?_, fun j hj => ?_⟩
    · by_contra hjS
      have := hmin (insert j S)
      rw [J_insert hjS] at this
      linarith
    · by_contra hlt
      push Not at hlt
      have := hmin (S.erase j)
      rw [J_erase hj] at this
      linarith
  · rintro ⟨hin, hout⟩ S'
    rw [J_eq, J_eq]
    have e1 := Finset.sum_inter_add_sum_sdiff S S' (fun j => c * k j - r j)
    have e2 := Finset.sum_inter_add_sum_sdiff S' S (fun j => c * k j - r j)
    rw [Finset.inter_comm] at e2
    have h1 : ∑ j ∈ S \ S', (c * k j - r j) ≤ 0 :=
      Finset.sum_nonpos fun j hj => by
        have := hout j (Finset.mem_sdiff.1 hj).1
        linarith
    have h2 : 0 ≤ ∑ j ∈ S' \ S, (c * k j - r j) :=
      Finset.sum_nonneg fun j hj => by
        have hjS := (Finset.mem_sdiff.1 hj).2
        have : ¬ c * k j < r j := fun h => hjS (hin j h)
        push Not at this
        linarith
    linarith

/-- **T5 Thm 3.2 / T4 Prop 7.1:** the threshold set `S*` minimises `J_c`. -/
theorem Sstar_isMinimizer : IsMinimizer c base R0 k r (Sstar c k r) :=
  isMinimizer_iff.2 ⟨fun _ hj => mem_Sstar.2 hj, fun _ hj => (mem_Sstar.1 hj).le⟩

theorem J_Sstar_le (S : Finset ι) : J c base R0 k r (Sstar c k r) ≤ J c base R0 k r S :=
  Sstar_isMinimizer S

/-- Without ties (`r_j ≠ c k_j` for all `j`), `S*` is the only minimiser. -/
theorem isMinimizer_iff_eq_Sstar (hnt : ∀ j, r j ≠ c * k j) {S : Finset ι} :
    IsMinimizer c base R0 k r S ↔ S = Sstar c k r := by
  constructor
  · intro h
    obtain ⟨hin, hout⟩ := isMinimizer_iff.1 h
    ext j
    rw [mem_Sstar]
    exact ⟨fun hj => lt_of_le_of_ne (hout j hj) (fun h => hnt j h.symm), hin j⟩
  · rintro rfl
    exact Sstar_isMinimizer

/-- `S` is the **unique** minimiser of `J_c` iff `S = S*` and there are no ties. -/
theorem isUniqueMinimizer_iff {S : Finset ι} :
    IsUniqueMinimizer c base R0 k r S ↔ S = Sstar c k r ∧ ∀ j, r j ≠ c * k j := by
  constructor
  · intro hu
    have hmin : IsMinimizer c base R0 k r S := fun S' => by
      by_cases h : S' = S
      · rw [h]
      · exact (hu S' h).le
    have hnt : ∀ j, r j ≠ c * k j := by
      intro j hj
      by_cases hjS : j ∈ S
      · have := hu (S.erase j) (fun h => (Finset.erase_eq_self.1 h) hjS)
        rw [J_erase hjS, hj] at this
        linarith
      · have := hu (insert j S) (fun h => hjS (Finset.insert_eq_self.1 h))
        rw [J_insert hjS, hj] at this
        linarith
    exact ⟨(isMinimizer_iff_eq_Sstar hnt).1 hmin, hnt⟩
  · rintro ⟨rfl, hnt⟩ S' hS'
    have hnm : ¬ IsMinimizer c base R0 k r S' :=
      fun h => hS' ((isMinimizer_iff_eq_Sstar hnt).1 h)
    unfold IsMinimizer at hnm
    push Not at hnm
    obtain ⟨S'', hS''⟩ := hnm
    exact lt_of_le_of_lt (Sstar_isMinimizer S'') hS''

/-- Without ties, `S*` is the unique minimiser: `J(S*) < J(S)` for every `S ≠ S*`. -/
theorem Sstar_isUniqueMinimizer (hnt : ∀ j, r j ≠ c * k j) :
    IsUniqueMinimizer c base R0 k r (Sstar c k r) :=
  isUniqueMinimizer_iff.2 ⟨rfl, hnt⟩

/-- **T5 Theorem 3.2 (binary components), bundled (the task's item (1)).** For every real `c`,
`S* = {j | r_j > c k_j}` minimises `J_c` over all subsets; when there are no ties
(`r_j ≠ c k_j`), `S*` is the only minimiser and beats every other subset strictly. -/
theorem rate_threshold :
    (∀ S : Finset ι, J c base R0 k r (Sstar c k r) ≤ J c base R0 k r S) ∧
      ((∀ j, r j ≠ c * k j) →
        (∀ S : Finset ι, IsMinimizer c base R0 k r S ↔ S = Sstar c k r) ∧
        ∀ S : Finset ι, S ≠ Sstar c k r → J c base R0 k r (Sstar c k r) < J c base R0 k r S) :=
  ⟨J_Sstar_le, fun hnt => ⟨fun _ => isMinimizer_iff_eq_Sstar hnt, Sstar_isUniqueMinimizer hnt⟩⟩

/-- "Ties are arbitrary": at a tie `r_j = c k_j`, adding or removing `j` from a minimiser
gives a minimiser. -/
theorem ties_arbitrary {S : Finset ι} (hS : IsMinimizer c base R0 k r S) {j : ι}
    (hj : r j = c * k j) :
    IsMinimizer c base R0 k r (insert j S) ∧ IsMinimizer c base R0 k r (S.erase j) := by
  obtain ⟨hin, hout⟩ := isMinimizer_iff.1 hS
  refine ⟨isMinimizer_iff.2 ⟨fun i hi => Finset.mem_insert_of_mem (hin i hi), fun i hi => ?_⟩,
    isMinimizer_iff.2 ⟨fun i hi => ?_, fun i hi => hout i (Finset.mem_of_mem_erase hi)⟩⟩
  · rcases Finset.mem_insert.1 hi with rfl | hi
    · rw [hj]
    · exact hout i hi
  · refine Finset.mem_erase.2 ⟨?_, hin i hi⟩
    rintro rfl
    rw [hj] at hi
    exact lt_irrefl _ hi

theorem mem_Sstar_iff_rate {j : ι} (hk : 0 < k j) : j ∈ Sstar c k r ↔ c < rate k r j := by
  rw [mem_Sstar, rate, lt_div_iff₀ hk]

theorem tie_iff_rate {j : ι} (hk : 0 < k j) : r j = c * k j ↔ rate k r j = c := by
  rw [rate, div_eq_iff hk.ne']

/-- **T5 Theorem 3.2 (rate threshold), second bullet.** With `k_j > 0`, `S` minimises `J_c`
iff every component of rate `> c` is in `S` and every component in `S` has rate `≥ c`;
i.e. component `j` is selected iff `r_j / k_j > c`, ties arbitrary. -/
theorem thm_3_2 (hk : ∀ j, 0 < k j) {S : Finset ι} :
    IsMinimizer c base R0 k r S ↔
      (∀ j, c < rate k r j → j ∈ S) ∧ (∀ j ∈ S, c ≤ rate k r j) := by
  have e1 : ∀ j, c < rate k r j ↔ c * k j < r j := fun j => lt_div_iff₀ (hk j)
  have e2 : ∀ j, c ≤ rate k r j ↔ c * k j ≤ r j := fun j => le_div_iff₀ (hk j)
  simp only [e1, e2]
  exact isMinimizer_iff

/-- **T5 Theorem 3.2, no-tie form.** If no rate equals `c`, the minimiser is unique and equals
`{j | r_j / k_j > c}`. -/
theorem thm_3_2_unique (hk : ∀ j, 0 < k j) (hnt : ∀ j, rate k r j ≠ c) {S : Finset ι} :
    IsMinimizer c base R0 k r S ↔ S = univ.filter (fun j => c < rate k r j) := by
  have hnt' : ∀ j, r j ≠ c * k j := fun j h => hnt j ((tie_iff_rate (hk j)).1 h)
  have hS : Sstar c k r = univ.filter (fun j => c < rate k r j) := by
    ext j
    rw [mem_Sstar_iff_rate (hk j)]
    simp
  rw [isMinimizer_iff_eq_Sstar hnt', hS]

theorem thm_3_2_unique' (hk : ∀ j, 0 < k j) (hnt : ∀ j, rate k r j ≠ c) :
    IsUniqueMinimizer c base R0 k r (univ.filter (fun j => c < rate k r j)) := by
  have hnt' : ∀ j, r j ≠ c * k j := fun j h => hnt j ((tie_iff_rate (hk j)).1 h)
  have hS : Sstar c k r = univ.filter (fun j => c < rate k r j) := by
    ext j
    rw [mem_Sstar_iff_rate (hk j)]
    simp
  rw [← hS]
  exact Sstar_isUniqueMinimizer hnt'

/-- **T5 Theorem 4.1(ii), in the setting of Thm 3.2 (rate blindness).** If `v` is selected by
some minimiser and `rate v ≤ rate e`, then `e` is selected too, except at a common tie value
`c = rate v = rate e`. Validity plays no role: only rates matter. -/
theorem rate_blindness (hk : ∀ j, 0 < k j) {S : Finset ι}
    (hS : IsMinimizer c base R0 k r S) {v e : ι} (hv : v ∈ S)
    (hve : rate k r v ≤ rate k r e) (htie : ¬ (rate k r v = c ∧ rate k r e = c)) :
    e ∈ S := by
  rw [thm_3_2 hk] at hS
  obtain ⟨hin, hout⟩ := hS
  have h1 := hout v hv
  apply hin
  by_contra hce
  push Not at hce
  exact htie ⟨by linarith, by linarith⟩

/-! ## 3. Selectability (T4 Corollary 7.2) -/

/-- **T4 Cor 7.2 / the task's corollary (pairwise form).** Some `c > 0` makes `V` the unique
minimiser of `J_c` iff every `j ∈ V` has positive rate and strictly out-rates every `i ∉ V`. -/
theorem selectable_iff (hk : ∀ j, 0 < k j) {V : Finset ι} :
    (∃ c > 0, IsUniqueMinimizer c base R0 k r V) ↔
      ∀ j ∈ V, 0 < rate k r j ∧ ∀ i ∉ V, rate k r i < rate k r j := by
  constructor
  · rintro ⟨c, hc, hu⟩
    obtain ⟨hV, -⟩ := isUniqueMinimizer_iff.1 hu
    intro j hj
    have hjc : c < rate k r j := (mem_Sstar_iff_rate (hk j)).1 (hV ▸ hj)
    refine ⟨lt_trans hc hjc, fun i hi => ?_⟩
    have : ¬ c < rate k r i := fun h => hi (hV ▸ (mem_Sstar_iff_rate (hk i)).2 h)
    push Not at this
    linarith
  · intro hsep
    obtain ⟨a, b, ha, hab, hsa, htb⟩ :=
      exists_gap (univ.filter (· ∉ V)) V (rate k r) (rate k r)
        (fun i hi j hj => (hsep j hj).2 i (Finset.mem_filter.1 hi).2)
        (fun j hj => (hsep j hj).1)
    refine ⟨(a + b) / 2, by linarith, isUniqueMinimizer_iff.2 ⟨?_, ?_⟩⟩
    · ext j
      rw [mem_Sstar_iff_rate (hk j)]
      constructor
      · intro hj
        have := htb j hj
        linarith
      · intro hj
        by_contra hjV
        have := hsa j (Finset.mem_filter.2 ⟨mem_univ j, hjV⟩)
        linarith
    · intro j
      rw [Ne, tie_iff_rate (hk j)]
      intro heq
      by_cases hjV : j ∈ V
      · have := htb j hjV
        linarith
      · have := hsa j (Finset.mem_filter.2 ⟨mem_univ j, hjV⟩)
        linarith

/-- The same criterion characterises `∃ c > 0, S*(c) = V`. -/
theorem exists_Sstar_eq_iff (hk : ∀ j, 0 < k j) {V : Finset ι} :
    (∃ c > 0, Sstar c k r = V) ↔
      ∀ j ∈ V, 0 < rate k r j ∧ ∀ i ∉ V, rate k r i < rate k r j := by
  rw [← selectable_iff (base := 0) (R0 := 0) hk]
  constructor
  · rintro ⟨c, hc, hV⟩
    -- move `c` into the open gap: `S*` is constant on `[c, min rate in V)`
    have key : ∀ j ∈ V, 0 < rate k r j ∧ ∀ i ∉ V, rate k r i < rate k r j := by
      intro j hj
      have hjc : c < rate k r j := (mem_Sstar_iff_rate (hk j)).1 (hV ▸ hj)
      refine ⟨lt_trans hc hjc, fun i hi => ?_⟩
      have : ¬ c < rate k r i := fun h => hi (hV ▸ (mem_Sstar_iff_rate (hk i)).2 h)
      push Not at this
      linarith
    exact (selectable_iff hk).2 key
  · rintro ⟨c, hc, hu⟩
    exact ⟨c, hc, ((isUniqueMinimizer_iff).1 hu).1.symm⟩

/-- **T4 Cor 7.2, with the paper's conventions.** Some `c > 0` makes `V` the unique minimiser
iff `min_{j∈V} rate_j > max_{i∉V} rate_i`, where the max over the empty set is `0` (as in T4
Cor 7.2) and the min over the empty set is `+∞` (the `∀ j ∈ V`). -/
theorem selectable_iff_fold (hk : ∀ j, 0 < k j) {V : Finset ι} :
    (∃ c > 0, IsUniqueMinimizer c base R0 k r V) ↔
      ∀ j ∈ V, (univ.filter (· ∉ V)).fold max 0 (rate k r) < rate k r j := by
  rw [selectable_iff hk]
  refine forall₂_congr fun j _ => ?_
  rw [Finset.fold_max_lt]
  simp [Finset.mem_filter]

/-- **The task's corollary (2), literal form.** For nonnegative risk reductions, positive costs
and `V`, `Vᶜ` nonempty: `V` is selectable (unique minimiser for some `c > 0`) iff
`max_{i∉V} r_i/k_i < min_{j∈V} r_j/k_j`. -/
theorem selectable_iff_sup'_lt_inf' (hk : ∀ j, 0 < k j) (hr : ∀ j, 0 ≤ r j) {V : Finset ι}
    (hV : V.Nonempty) (hVc : Vᶜ.Nonempty) :
    (∃ c > 0, IsUniqueMinimizer c base R0 k r V) ↔
      Vᶜ.sup' hVc (rate k r) < V.inf' hV (rate k r) := by
  rw [selectable_iff hk, Finset.lt_inf'_iff]
  simp only [Finset.sup'_lt_iff, Finset.mem_compl]
  constructor
  · intro h j hj i hi
    exact (h j hj).2 i hi
  · intro h j hj
    refine ⟨?_, fun i hi => h j hj i hi⟩
    obtain ⟨i, hi⟩ := hVc
    rw [Finset.mem_compl] at hi
    have h0 : 0 ≤ rate k r i := div_nonneg (hr i) (hk i).le
    linarith [h j hj i hi]

/-- Weak selectability: `V` is *a* minimiser (possibly tied) for some `c > 0` iff every rate in
`V` is positive and at least every rate outside `V`. -/
theorem weakly_selectable_iff (hk : ∀ j, 0 < k j) {V : Finset ι} :
    (∃ c > 0, IsMinimizer c base R0 k r V) ↔
      ∀ j ∈ V, 0 < rate k r j ∧ ∀ i ∉ V, rate k r i ≤ rate k r j := by
  constructor
  · rintro ⟨c, hc, hmin⟩
    rw [thm_3_2 hk] at hmin
    obtain ⟨hin, hout⟩ := hmin
    intro j hj
    refine ⟨lt_of_lt_of_le hc (hout j hj), fun i hi => ?_⟩
    have : ¬ c < rate k r i := fun h => hi (hin i h)
    push Not at this
    linarith [hout j hj]
  · intro hsep
    set a := (univ.filter (· ∉ V)).fold max 0 (rate k r) with ha
    have hia : ∀ i ∉ V, rate k r i ≤ a := fun i hi =>
      (Finset.le_fold_max _).2 (Or.inr ⟨i, Finset.mem_filter.2 ⟨mem_univ i, hi⟩, le_rfl⟩)
    by_cases hpos : 0 < a
    · refine ⟨a, hpos, (thm_3_2 hk).2 ⟨fun j hj => ?_, fun j hj => ?_⟩⟩
      · by_contra hjV
        have := hia j hjV
        linarith
      · refine (Finset.fold_max_le _).2 ⟨(hsep j hj).1.le, fun i hi => ?_⟩
        exact (hsep j hj).2 i (Finset.mem_filter.1 hi).2
    · push Not at hpos
      set b := V.fold min 1 (rate k r) with hb
      have hb0 : 0 < b := (Finset.lt_fold_min _).2 ⟨one_pos, fun j hj => (hsep j hj).1⟩
      refine ⟨b, hb0, (thm_3_2 hk).2 ⟨fun j hj => ?_, fun j hj => ?_⟩⟩
      · by_contra hjV
        have := hia j hjV
        linarith
      · exact (Finset.fold_min_le _).2 (Or.inr ⟨j, hj, le_rfl⟩)

end Binary

/-! ## 4. Lemma 3.1: the convex-hull selection lemma (finite form) -/

section Hull

variable {H : Type*} [Fintype H] [DecidableEq H] (ℓ R : H → ℝ)

/-- `J_c(h) = c ℓ(h) + R(h)`. -/
def Jc (c : ℝ) (h : H) : ℝ := c * ℓ h + R h

/-- `h` minimises `J_c`. -/
def IsMinAt (c : ℝ) (h : H) : Prop := ∀ h', Jc ℓ R c h ≤ Jc ℓ R c h'

/-- `(x, y) ∈ conv(A) + ℝ²≥0 = conv(A + ℝ²≥0)`, where `A = {(ℓ h, R h) : h ∈ H}`; convex
combinations are given by weights on hypotheses. -/
def InHull (x y : ℝ) : Prop :=
  ∃ w : H → ℝ, (∀ h, 0 ≤ w h) ∧ ∑ h, w h = 1 ∧ ∑ h, w h * ℓ h ≤ x ∧ ∑ h, w h * R h ≤ y

/-- `P_h ∈ hull⁻(A)`: some line of slope `-c`, `c ∈ (0, ∞)`, through `P_h` supports
`conv(A + ℝ²≥0)` (the paper's definition, made precise after verification, restricted to the
points of `A`). -/
def OnLowerHull (h : H) : Prop :=
  ∃ c > 0, ∀ x y, InHull ℓ R x y → c * ℓ h + R h ≤ c * x + y

/-- `(x, y)` is an extreme point of `conv(A + ℝ²≥0)`. -/
def IsExtremePt (x y : ℝ) : Prop :=
  InHull ℓ R x y ∧ ∀ x₁ y₁ x₂ y₂ t : ℝ, InHull ℓ R x₁ y₁ → InHull ℓ R x₂ y₂ → 0 < t → t < 1 →
    x = t * x₁ + (1 - t) * x₂ → y = t * y₁ + (1 - t) * y₂ →
      (x₁ = x ∧ y₁ = y) ∧ (x₂ = x ∧ y₂ = y)

/-- `P_h` is a vertex of `hull⁻(A)`: an extreme point of `conv(A + ℝ²≥0)` lying in
`hull⁻(A)` (T5 §3.1). -/
def IsHullVertex (h : H) : Prop := IsExtremePt ℓ R (ℓ h) (R h) ∧ OnLowerHull ℓ R h

/-- Elementary 2D characterisation: no other point weakly dominates `P_h` from the left (or the
same column), and `P_h` lies strictly below every chord between a point to its left and a point
to its right. -/
def ChordCond (h : H) : Prop :=
  (∀ h', (ℓ h', R h') ≠ (ℓ h, R h) → ℓ h' ≤ ℓ h → R h < R h') ∧
  (∀ h₁ h₂, ℓ h₁ < ℓ h → ℓ h < ℓ h₂ →
     (ℓ h₂ - ℓ h₁) * R h < (ℓ h₂ - ℓ h) * R h₁ + (ℓ h - ℓ h₁) * R h₂)

/-- `P_h ∉ conv((A ∖ {P_h}) + ℝ²≥0)`. -/
def NotInOthersHull (h : H) : Prop :=
  ¬ ∃ w : H → ℝ, (∀ h', 0 ≤ w h') ∧ (∀ h', (ℓ h', R h') = (ℓ h, R h) → w h' = 0) ∧
    ∑ h', w h' = 1 ∧ ∑ h', w h' * ℓ h' ≤ ℓ h ∧ ∑ h', w h' * R h' ≤ R h

/-- `P_h` is the unique minimising point of `J_c` for every `c ∈ (a, b)`. -/
def UniquePointOn (h : H) (a b : ℝ) : Prop :=
  ∀ c, a < c → c < b → ∀ h', (ℓ h', R h') ≠ (ℓ h, R h) → Jc ℓ R c h < Jc ℓ R c h'

/-- The chord rate between `P_h` and `P_h'`: risk saved per extra bit (`(R h - R h') /
(ℓ h' - ℓ h)`; symmetric in `h, h'`). -/
noncomputable def chordRate (h h' : H) : ℝ := (R h - R h') / (ℓ h' - ℓ h)

variable {ℓ R}

theorem inHull_of_le (h : H) {x y : ℝ} (hx : ℓ h ≤ x) (hy : R h ≤ y) : InHull ℓ R x y := by
  refine ⟨fun h' => if h' = h then 1 else 0, fun h' => ?_, ?_, ?_, ?_⟩
  · show 0 ≤ (if h' = h then (1 : ℝ) else 0)
    split_ifs <;> norm_num
  · simp
  · simpa [ite_mul] using hx
  · simpa [ite_mul] using hy

/-- Hypotheses sharing a point are co-minimisers (they have the same `J_c` value). -/
theorem Jc_eq_of_same_point {c : ℝ} {h h' : H} (hp : (ℓ h', R h') = (ℓ h, R h)) :
    Jc ℓ R c h' = Jc ℓ R c h := by
  simp only [Prod.mk.injEq] at hp
  simp [Jc, hp.1, hp.2]

theorem sum_mul_Jc (c : ℝ) (w : H → ℝ) :
    ∑ h', w h' * Jc ℓ R c h' = c * ∑ h', w h' * ℓ h' + ∑ h', w h' * R h' := by
  rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun h' _ => ?_
  simp only [Jc]
  ring

theorem Jc_inHull_bound {c : ℝ} (hc : 0 ≤ c) {h : H} (hm : IsMinAt ℓ R c h) {x y : ℝ}
    (w : H → ℝ) (hw0 : ∀ h, 0 ≤ w h) (hw1 : ∑ h, w h = 1) (hx : ∑ h, w h * ℓ h ≤ x)
    (hy : ∑ h, w h * R h ≤ y) :
    Jc ℓ R c h ≤ c * x + y := by
  have e0 : Jc ℓ R c h = ∑ h', w h' * Jc ℓ R c h := by rw [← Finset.sum_mul, hw1, one_mul]
  have e1 : ∑ h', w h' * Jc ℓ R c h ≤ ∑ h', w h' * Jc ℓ R c h' :=
    Finset.sum_le_sum fun h' _ => mul_le_mul_of_nonneg_left (hm h') (hw0 h')
  have e2 := sum_mul_Jc (ℓ := ℓ) (R := R) c w
  have e3 : c * ∑ h', w h' * ℓ h' ≤ c * x := mul_le_mul_of_nonneg_left hx hc
  linarith

/-- **T5 Lemma 3.1(i), first half.** For `c ≥ 0`, a minimiser `h` of `J_c` lies on a supporting
line of slope `-c` of `conv(A + ℝ²≥0)`: minimising over `A` is minimising over
`conv(A + ℝ²≥0)`. -/
theorem isMinAt_le_of_inHull {c : ℝ} (hc : 0 ≤ c) {h : H} (hm : IsMinAt ℓ R c h) {x y : ℝ}
    (hxy : InHull ℓ R x y) : Jc ℓ R c h ≤ c * x + y := by
  obtain ⟨w, hw0, hw1, hx, hy⟩ := hxy
  exact Jc_inHull_bound hc hm w hw0 hw1 hx hy

/-- **T5 Lemma 3.1(i).** `P_h ∈ hull⁻(A)` iff `h` minimises `J_c` for some `c > 0`. -/
theorem onLowerHull_iff {h : H} : OnLowerHull ℓ R h ↔ ∃ c > 0, IsMinAt ℓ R c h := by
  constructor
  · rintro ⟨c, hc, hsupp⟩
    exact ⟨c, hc, fun h' => hsupp _ _ (inHull_of_le h' le_rfl le_rfl)⟩
  · rintro ⟨c, hc, hm⟩
    exact ⟨c, hc, fun x y hxy => isMinAt_le_of_inHull hc.le hm hxy⟩

/-- **T5 Lemma 3.1(ii) (monotonicity).** If `0 ≤ c < c'`, `h` minimises `J_c` and `h'`
minimises `J_{c'}`, then `ℓ h' ≤ ℓ h` and `R h ≤ R h'`. -/
theorem lemma_3_1_ii {c c' : ℝ} (hc : 0 ≤ c) (hcc : c < c') {h h' : H}
    (hm : IsMinAt ℓ R c h) (hm' : IsMinAt ℓ R c' h') : ℓ h' ≤ ℓ h ∧ R h ≤ R h' := by
  have e1 := hm h'
  have e2 := hm' h
  simp only [Jc] at e1 e2
  have hl : ℓ h' ≤ ℓ h := by
    by_contra hlt
    push Not at hlt
    have : (c' - c) * (ℓ h' - ℓ h) > 0 := mul_pos (by linarith) (by linarith)
    nlinarith
  refine ⟨hl, ?_⟩
  have : c * (ℓ h' - ℓ h) ≤ 0 := mul_nonpos_of_nonneg_of_nonpos hc (by linarith)
  nlinarith

/-- The set of `c` at which `P_h` is the unique minimising point, described by chord rates:
every point to the right has chord rate `< c` (`c > s₊`), every point to the left has chord rate
`> c` (`c < s₋`), and points in the same column lie strictly above. This is the paper's
"the interval is `(s₊, s₋)`". -/
theorem uniquePoint_iff_rates {c : ℝ} {h : H} :
    (∀ h', (ℓ h', R h') ≠ (ℓ h, R h) → Jc ℓ R c h < Jc ℓ R c h') ↔
      (∀ h', ℓ h < ℓ h' → chordRate ℓ R h h' < c) ∧
      (∀ h', ℓ h' < ℓ h → c < chordRate ℓ R h h') ∧
      (∀ h', ℓ h' = ℓ h → (ℓ h', R h') ≠ (ℓ h, R h) → R h < R h') := by
  have key : ∀ h', Jc ℓ R c h < Jc ℓ R c h' ↔ R h - R h' < c * (ℓ h' - ℓ h) := by
    intro h'
    simp only [Jc]
    constructor <;> intro H' <;> linarith
  constructor
  · intro hs
    refine ⟨fun h' hlt => ?_, fun h' hlt => ?_, fun h' heq hne => ?_⟩
    · have hne : (ℓ h', R h') ≠ (ℓ h, R h) := by
        intro he
        simp only [Prod.mk.injEq] at he
        linarith [he.1]
      have := (key h').1 (hs h' hne)
      rw [chordRate, div_lt_iff₀ (by linarith)]
      linarith
    · have hne : (ℓ h', R h') ≠ (ℓ h, R h) := by
        intro he
        simp only [Prod.mk.injEq] at he
        linarith [he.1]
      have := (key h').1 (hs h' hne)
      rw [chordRate, lt_div_iff_of_neg (by linarith)]
      linarith
    · have := (key h').1 (hs h' hne)
      rw [heq] at this
      linarith
  · rintro ⟨hright, hleft, hsame⟩ h' hne
    rw [key]
    rcases lt_trichotomy (ℓ h') (ℓ h) with hlt | heq | hgt
    · have := hleft h' hlt
      rw [chordRate, lt_div_iff_of_neg (by linarith)] at this
      linarith
    · have := hsame h' heq hne
      rw [heq]
      linarith
    · have := hright h' hgt
      rw [chordRate, div_lt_iff₀ (by linarith)] at this
      linarith

/-- Strict separation on other points implies minimisation. -/
theorem isMinAt_of_uniquePoint {c : ℝ} {h : H}
    (hs : ∀ h', (ℓ h', R h') ≠ (ℓ h, R h) → Jc ℓ R c h < Jc ℓ R c h') : IsMinAt ℓ R c h := by
  intro h'
  by_cases hp : (ℓ h', R h') = (ℓ h, R h)
  · exact (Jc_eq_of_same_point hp).ge
  · exact (hs h' hp).le

/-- `P_h` is the unique minimising point on a nonempty open interval of positive `c` iff the
elementary chord condition holds. -/
theorem isolated_iff_chord {h : H} :
    (∃ a b, 0 ≤ a ∧ a < b ∧ UniquePointOn ℓ R h a b) ↔ ChordCond ℓ R h := by
  constructor
  · rintro ⟨a, b, ha, hab, hu⟩
    set c := (a + b) / 2
    have hc0 : 0 < c := by simp only [c]; linarith
    have hs := hu c (by simp only [c]; linarith) (by simp only [c]; linarith)
    refine ⟨fun h' hne hle => ?_, fun h₁ h₂ h1 h2 => ?_⟩
    · have := hs h' hne
      simp only [Jc] at this
      have : c * (ℓ h' - ℓ h) ≤ 0 := mul_nonpos_of_nonneg_of_nonpos hc0.le (by linarith)
      nlinarith
    · have hne1 : (ℓ h₁, R h₁) ≠ (ℓ h, R h) := by
        intro he; simp only [Prod.mk.injEq] at he; linarith [he.1]
      have hne2 : (ℓ h₂, R h₂) ≠ (ℓ h, R h) := by
        intro he; simp only [Prod.mk.injEq] at he; linarith [he.1]
      have e1 := hs h₁ hne1
      have e2 := hs h₂ hne2
      simp only [Jc] at e1 e2
      have f1 := mul_lt_mul_of_pos_left e1 (sub_pos.2 h2)
      have f2 := mul_lt_mul_of_pos_left e2 (sub_pos.2 h1)
      nlinarith
  · rintro ⟨ha, hb⟩
    obtain ⟨a, b, ha0, hab, hsa, htb⟩ :=
      exists_gap (univ.filter (fun h' => ℓ h < ℓ h')) (univ.filter (fun h' => ℓ h' < ℓ h))
        (chordRate ℓ R h) (chordRate ℓ R h)
        (fun h₂ h₂m h₁ h₁m => by
          have h2 := (Finset.mem_filter.1 h₂m).2
          have h1 := (Finset.mem_filter.1 h₁m).2
          have := hb h₁ h₂ h1 h2
          have eq1 : chordRate ℓ R h h₁ = (R h₁ - R h) / (ℓ h - ℓ h₁) := by
            rw [chordRate, ← neg_div_neg_eq, neg_sub, neg_sub]
          rw [eq1, chordRate, div_lt_div_iff₀ (by linarith) (by linarith)]
          linarith)
        (fun h₁ h₁m => by
          have h1 := (Finset.mem_filter.1 h₁m).2
          have hne : (ℓ h₁, R h₁) ≠ (ℓ h, R h) := by
            intro he; simp only [Prod.mk.injEq] at he; linarith [he.1]
          have := ha h₁ hne h1.le
          rw [chordRate]
          exact div_pos_of_neg_of_neg (by linarith) (by linarith))
    refine ⟨a, b, ha0, hab, fun c hac hcb => ?_⟩
    refine uniquePoint_iff_rates.2 ⟨fun h' hlt => ?_, fun h' hlt => ?_, fun h' heq hne => ?_⟩
    · have := hsa h' (Finset.mem_filter.2 ⟨mem_univ _, hlt⟩)
      linarith
    · have := htb h' (Finset.mem_filter.2 ⟨mem_univ _, hlt⟩)
      linarith
    · exact ha h' hne heq.le

/-- From the chord condition: some `c > 0` at which `P_h` is the unique minimising point. -/
theorem exists_c_of_chord {h : H} (hch : ChordCond ℓ R h) :
    ∃ c > 0, ∀ h', (ℓ h', R h') ≠ (ℓ h, R h) → Jc ℓ R c h < Jc ℓ R c h' := by
  obtain ⟨a, b, ha, hab, hu⟩ := isolated_iff_chord.2 hch
  exact ⟨(a + b) / 2, by linarith, hu _ (by linarith) (by linarith)⟩

/-- If `P_h` is the unique minimising point of `J_c` (`c > 0`), then `P_h` is the only point of
`conv(A + ℝ²≥0)` on the supporting line `c x + y = J_c(h)`. -/
theorem eq_of_inHull_of_le {c : ℝ} (hc : 0 < c) {h : H}
    (hs : ∀ h', (ℓ h', R h') ≠ (ℓ h, R h) → Jc ℓ R c h < Jc ℓ R c h') {x y : ℝ}
    (hxy : InHull ℓ R x y) (hle : c * x + y ≤ Jc ℓ R c h) : x = ℓ h ∧ y = R h := by
  obtain ⟨w, hw0, hw1, hx, hy⟩ := hxy
  have hd0 : ∀ h', 0 ≤ w h' * (Jc ℓ R c h' - Jc ℓ R c h) := fun h' => by
    by_cases hp : (ℓ h', R h') = (ℓ h, R h)
    · rw [Jc_eq_of_same_point hp, sub_self, mul_zero]
    · exact mul_nonneg (hw0 h') (by linarith [hs h' hp])
  have hsum : ∑ h', w h' * (Jc ℓ R c h' - Jc ℓ R c h) =
      c * ∑ h', w h' * ℓ h' + ∑ h', w h' * R h' - Jc ℓ R c h := by
    simp only [mul_sub, Finset.sum_sub_distrib]
    rw [← Finset.sum_mul, hw1, one_mul, sum_mul_Jc]
  have e3 : c * ∑ h', w h' * ℓ h' ≤ c * x := mul_le_mul_of_nonneg_left hx hc.le
  have hd_eq : ∑ h', w h' * (Jc ℓ R c h' - Jc ℓ R c h) = 0 :=
    le_antisymm (by linarith) (Finset.sum_nonneg fun h' _ => hd0 h')
  have hall := (Finset.sum_eq_zero_iff_of_nonneg (fun h' _ => hd0 h')).1 hd_eq
  have hpt : ∀ h', w h' ≠ 0 → (ℓ h', R h') = (ℓ h, R h) := by
    intro h' hw
    by_contra hp
    rcases mul_eq_zero.1 (hall h' (mem_univ _)) with h0 | h0
    · exact hw h0
    · linarith [hs h' hp]
  have hl : ∑ h', w h' * ℓ h' = ℓ h := by
    have : ∀ h', w h' * ℓ h' = w h' * ℓ h := fun h' => by
      by_cases hw : w h' = 0
      · simp [hw]
      · have := hpt h' hw
        simp only [Prod.mk.injEq] at this
        rw [this.1]
    rw [Finset.sum_congr rfl fun h' _ => this h', ← Finset.sum_mul, hw1, one_mul]
  have hr : ∑ h', w h' * R h' = R h := by
    have : ∀ h', w h' * R h' = w h' * R h := fun h' => by
      by_cases hw : w h' = 0
      · simp [hw]
      · have := hpt h' hw
        simp only [Prod.mk.injEq] at this
        rw [this.2]
    rw [Finset.sum_congr rfl fun h' _ => this h', ← Finset.sum_mul, hw1, one_mul]
  rw [hl] at hx
  rw [hr] at hy
  simp only [Jc] at hle
  have h1 : c * x ≤ c * ℓ h := by linarith
  have h2 : x ≤ ℓ h := le_of_mul_le_mul_left h1 hc
  have h3 : c * ℓ h ≤ c * x := mul_le_mul_of_nonneg_left hx hc.le
  constructor <;> linarith

/-- Chord condition ⟹ `P_h` is an extreme point of `conv(A + ℝ²≥0)`. -/
theorem extreme_of_chord {h : H} (hch : ChordCond ℓ R h) : IsExtremePt ℓ R (ℓ h) (R h) := by
  obtain ⟨c, hc, hs⟩ := exists_c_of_chord hch
  have hm := isMinAt_of_uniquePoint hs
  refine ⟨inHull_of_le h le_rfl le_rfl, fun x₁ y₁ x₂ y₂ t h₁ h₂ ht0 ht1 hx hy => ?_⟩
  have e1 := isMinAt_le_of_inHull hc.le hm h₁
  have e2 := isMinAt_le_of_inHull hc.le hm h₂
  have key : t * (c * x₁ + y₁ - Jc ℓ R c h) + (1 - t) * (c * x₂ + y₂ - Jc ℓ R c h) = 0 := by
    simp only [Jc]
    linear_combination (-c) * hx - hy
  have f1 : c * x₁ + y₁ ≤ Jc ℓ R c h := by
    by_contra hcon
    push Not at hcon
    have := mul_pos ht0 (sub_pos.2 hcon)
    have := mul_nonneg (sub_pos.2 ht1).le (sub_nonneg.2 e2)
    linarith
  have f2 : c * x₂ + y₂ ≤ Jc ℓ R c h := by
    by_contra hcon
    push Not at hcon
    have := mul_pos (sub_pos.2 ht1) (sub_pos.2 hcon)
    have := mul_nonneg ht0.le (sub_nonneg.2 e1)
    linarith
  exact ⟨eq_of_inHull_of_le hc hs h₁ f1, eq_of_inHull_of_le hc hs h₂ f2⟩

/-- Extreme point of `conv(A + ℝ²≥0)` ⟹ chord condition. -/
theorem chord_of_extreme {h : H} (hE : IsExtremePt ℓ R (ℓ h) (R h)) : ChordCond ℓ R h := by
  obtain ⟨-, hE⟩ := hE
  refine ⟨fun h' hne hle => ?_, fun h₁ h₂ h1 h2 => ?_⟩
  · by_contra hR
    push Not at hR
    have := hE (ℓ h') (R h') (2 * ℓ h - ℓ h') (2 * R h - R h') (1 / 2)
      (inHull_of_le h' le_rfl le_rfl) (inHull_of_le h (by linarith) (by linarith))
      (by norm_num) (by norm_num) (by ring) (by ring)
    exact hne (Prod.ext this.1.1 this.1.2)
  · by_contra hR
    push Not at hR
    have hD : 0 < ℓ h₂ - ℓ h₁ := by linarith
    have hq : 0 < ℓ h - ℓ h₁ := by linarith
    have ht0 : 0 < (ℓ h₂ - ℓ h) / (ℓ h₂ - ℓ h₁) := div_pos (by linarith) hD
    have ht1 : (ℓ h₂ - ℓ h) / (ℓ h₂ - ℓ h₁) < 1 := (div_lt_one hD).2 (by linarith)
    have hy₂le : R h₂ ≤ ((ℓ h₂ - ℓ h₁) * R h - (ℓ h₂ - ℓ h) * R h₁) / (ℓ h - ℓ h₁) := by
      rw [le_div_iff₀ hq]
      linarith
    have hx : ℓ h = (ℓ h₂ - ℓ h) / (ℓ h₂ - ℓ h₁) * ℓ h₁ +
        (1 - (ℓ h₂ - ℓ h) / (ℓ h₂ - ℓ h₁)) * ℓ h₂ := by
      field_simp
      ring
    have hy : R h = (ℓ h₂ - ℓ h) / (ℓ h₂ - ℓ h₁) * R h₁ +
        (1 - (ℓ h₂ - ℓ h) / (ℓ h₂ - ℓ h₁)) *
          (((ℓ h₂ - ℓ h₁) * R h - (ℓ h₂ - ℓ h) * R h₁) / (ℓ h - ℓ h₁)) := by
      field_simp
      ring
    have := hE (ℓ h₁) (R h₁) (ℓ h₂) _ _ (inHull_of_le h₁ le_rfl le_rfl)
      (inHull_of_le h₂ le_rfl hy₂le) ht0 ht1 hx hy
    linarith [this.1.1]

/-- Chord condition ⟹ `P_h ∉ conv((A ∖ {P_h}) + ℝ²≥0)`. -/
theorem notInOthersHull_of_chord {h : H} (hch : ChordCond ℓ R h) : NotInOthersHull ℓ R h := by
  obtain ⟨c, hc, hs⟩ := exists_c_of_chord hch
  rintro ⟨w, hw0, hwP, hw1, hx, hy⟩
  have hm := isMinAt_of_uniquePoint hs
  obtain ⟨h₀, -, hw₀⟩ := Finset.exists_ne_zero_of_sum_ne_zero (s := univ) (f := w)
    (by rw [hw1]; exact one_ne_zero)
  have hp₀ : (ℓ h₀, R h₀) ≠ (ℓ h, R h) := fun hp => hw₀ (hwP h₀ hp)
  have hlt : ∑ h', w h' * Jc ℓ R c h < ∑ h', w h' * Jc ℓ R c h' := by
    refine Finset.sum_lt_sum (fun h' _ => ?_) ⟨h₀, mem_univ _, ?_⟩
    · exact mul_le_mul_of_nonneg_left (hm h') (hw0 h')
    · exact mul_lt_mul_of_pos_left (hs h₀ hp₀) (lt_of_le_of_ne (hw0 h₀) (Ne.symm hw₀))
  have e0 : ∑ h', w h' * Jc ℓ R c h = Jc ℓ R c h := by rw [← Finset.sum_mul, hw1, one_mul]
  have e2 := sum_mul_Jc (ℓ := ℓ) (R := R) c w
  have e3 : c * ∑ h', w h' * ℓ h' ≤ c * ℓ h := mul_le_mul_of_nonneg_left hx hc.le
  have e4 : Jc ℓ R c h = c * ℓ h + R h := rfl
  linarith

/-- `P_h ∉ conv((A ∖ {P_h}) + ℝ²≥0)` ⟹ chord condition. -/
theorem chord_of_notInOthersHull {h : H} (hN : NotInOthersHull ℓ R h) : ChordCond ℓ R h := by
  refine ⟨fun h' hne hle => ?_, fun h₁ h₂ h1 h2 => ?_⟩
  · by_contra hR
    push Not at hR
    apply hN
    refine ⟨fun h'' => if h'' = h' then 1 else 0, fun h'' => ?_, fun h'' hp => ?_, ?_, ?_, ?_⟩
    · show 0 ≤ (if h'' = h' then (1 : ℝ) else 0)
      split_ifs <;> norm_num
    · show (if h'' = h' then (1 : ℝ) else 0) = 0
      rw [if_neg]
      rintro rfl
      exact hne hp
    · simp
    · simpa [ite_mul] using hle
    · simpa [ite_mul] using hR
  · by_contra hR
    push Not at hR
    apply hN
    have hD : 0 < ℓ h₂ - ℓ h₁ := by linarith
    have h12 : h₁ ≠ h₂ := by
      rintro rfl
      linarith
    have a1 : 0 ≤ (ℓ h₂ - ℓ h) / (ℓ h₂ - ℓ h₁) := div_nonneg (by linarith) hD.le
    have a2 : 0 ≤ (ℓ h - ℓ h₁) / (ℓ h₂ - ℓ h₁) := div_nonneg (by linarith) hD.le
    refine ⟨fun h'' => (if h'' = h₁ then (ℓ h₂ - ℓ h) / (ℓ h₂ - ℓ h₁) else 0) +
        (if h'' = h₂ then (ℓ h - ℓ h₁) / (ℓ h₂ - ℓ h₁) else 0),
      fun h'' => ?_, fun h'' hp => ?_, ?_, ?_, ?_⟩
    · show 0 ≤ (if h'' = h₁ then (ℓ h₂ - ℓ h) / (ℓ h₂ - ℓ h₁) else 0) +
        (if h'' = h₂ then (ℓ h - ℓ h₁) / (ℓ h₂ - ℓ h₁) else 0)
      split_ifs <;> linarith
    · simp only [Prod.mk.injEq] at hp
      have n1 : h'' ≠ h₁ := by
        rintro rfl
        linarith [hp.1]
      have n2 : h'' ≠ h₂ := by
        rintro rfl
        linarith [hp.1]
      simp [n1, n2]
    · simp only [Finset.sum_add_distrib, Finset.sum_ite_eq', mem_univ, if_true]
      rw [← add_div, div_eq_one_iff_eq hD.ne']
      ring
    · simp only [add_mul, ite_mul, zero_mul, Finset.sum_add_distrib, Finset.sum_ite_eq',
        mem_univ, if_true]
      rw [div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_le_iff₀ hD]
      nlinarith
    · simp only [add_mul, ite_mul, zero_mul, Finset.sum_add_distrib, Finset.sum_ite_eq',
        mem_univ, if_true]
      rw [div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_le_iff₀ hD]
      linarith

theorem chord_iff_extreme {h : H} : ChordCond ℓ R h ↔ IsExtremePt ℓ R (ℓ h) (R h) :=
  ⟨extreme_of_chord, chord_of_extreme⟩

theorem chord_iff_notInOthersHull {h : H} : ChordCond ℓ R h ↔ NotInOthersHull ℓ R h :=
  ⟨notInOthersHull_of_chord, chord_of_notInOthersHull⟩

theorem onLowerHull_of_chord {h : H} (hch : ChordCond ℓ R h) : OnLowerHull ℓ R h := by
  obtain ⟨c, hc, hs⟩ := exists_c_of_chord hch
  exact onLowerHull_iff.2 ⟨c, hc, isMinAt_of_uniquePoint hs⟩

/-- Every extreme point of `conv(A + ℝ²≥0)` at a point of `A` lies on `hull⁻(A)`, so a
`hull⁻` vertex is the same as an extreme point; both are the chord condition. -/
theorem isHullVertex_iff_chord {h : H} : IsHullVertex ℓ R h ↔ ChordCond ℓ R h :=
  ⟨fun hv => chord_of_extreme hv.1, fun hch => ⟨extreme_of_chord hch, onLowerHull_of_chord hch⟩⟩

theorem isHullVertex_iff_extreme {h : H} : IsHullVertex ℓ R h ↔ IsExtremePt ℓ R (ℓ h) (R h) :=
  isHullVertex_iff_chord.trans chord_iff_extreme

/-- **T5 Lemma 3.1(iii) (points).** `P_h` is the unique minimising point of `J_c` for all `c` in
a nonempty open interval of positive reals iff `P_h` is a vertex of `hull⁻(A)`. -/
theorem lemma_3_1_iii {h : H} :
    (∃ a b, 0 ≤ a ∧ a < b ∧ UniquePointOn ℓ R h a b) ↔ IsHullVertex ℓ R h := by
  rw [isHullVertex_iff_chord]
  exact isolated_iff_chord

/-- **T5 Lemma 3.1(iii) (hypotheses).** The hypothesis `h` is the unique minimiser of `J_c` for
all `c` in a nonempty open interval of positive reals iff `P_h` is a `hull⁻` vertex and no other
hypothesis has the same point. -/
theorem lemma_3_1_iii_hyp {h : H} :
    (∃ a b, 0 ≤ a ∧ a < b ∧ ∀ c, a < c → c < b → ∀ h', h' ≠ h → Jc ℓ R c h < Jc ℓ R c h') ↔
      IsHullVertex ℓ R h ∧ ∀ h', h' ≠ h → (ℓ h', R h') ≠ (ℓ h, R h) := by
  constructor
  · rintro ⟨a, b, ha, hab, hu⟩
    refine ⟨lemma_3_1_iii.1 ⟨a, b, ha, hab, fun c hac hcb h' hne =>
      hu c hac hcb h' (fun he => hne (by rw [he]))⟩, fun h' hne hp => ?_⟩
    have := hu ((a + b) / 2) (by linarith) (by linarith) h' hne
    rw [Jc_eq_of_same_point hp] at this
    exact lt_irrefl _ this
  · rintro ⟨hv, hdist⟩
    obtain ⟨a, b, ha, hab, hu⟩ := lemma_3_1_iii.2 hv
    exact ⟨a, b, ha, hab, fun c hac hcb h' hne => hu c hac hcb h' (hdist h' hne)⟩

/-- A point weakly dominated by another point of `A` is never a `hull⁻` vertex (whatever the
other hypotheses are). -/
theorem not_isHullVertex_of_dominated {h h' : H} (hne : (ℓ h', R h') ≠ (ℓ h, R h))
    (hl : ℓ h' ≤ ℓ h) (hr : R h' ≤ R h) : ¬ IsHullVertex ℓ R h := fun hv => by
  have := (isHullVertex_iff_chord.1 hv).1 h' hne hl
  linarith

end Hull

/-- The binary objective of §2 is the Lagrangian `J_c` of the hypothesis class `Finset ι`, with
`ℓ(S) = base + ∑_{j∈S} k_j` and `R(S) = R0 - ∑_{j∈S} r_j`; so Lemma 3.1 applies to it. -/
theorem J_eq_Jc {ι : Type*} (c base R0 : ℝ) (k r : ι → ℝ) (S : Finset ι) :
    J c base R0 k r S =
      Jc (fun S : Finset ι => base + ∑ j ∈ S, k j) (fun S => R0 - ∑ j ∈ S, r j) c S := rfl

/-! ## 5. The counterexample (T4 Prop 7.3) -/

section Example

/-- Three rule tags: `A` a common valid rule, `B` a rare long valid rule, `F` the freshman's
dream `(a+b)² = a² + b²` (a short, frequent fallacy). -/
inductive Rule
  | A
  | B
  | F
  deriving DecidableEq, Fintype

namespace Rule

/-- Description length `ℓ` (bits). -/
noncomputable def len : Rule → ℝ
  | A => 10
  | B => 40
  | F => 8

/-- Frequency `π` (fraction of data steps that are instances). -/
noncomputable def freq : Rule → ℝ
  | A => 1 / 2
  | B => 1 / 100
  | F => 1 / 20

/-- Per-instance gain `g` (bits). -/
noncomputable def gain : Rule → ℝ := fun _ => 8

/-- Risk reduction `r = π g` (bits per datum). -/
noncomputable def red (j : Rule) : ℝ := freq j * gain j

/-- The valid rules. -/
def valid : Finset Rule := {A, B}

end Rule

open Rule

theorem len_pos : ∀ j, 0 < len j := by
  intro j; cases j <;> norm_num [len]

theorem red_nonneg : ∀ j, 0 ≤ red j := by
  intro j; cases j <;> norm_num [red, freq, gain]

theorem rate_A : rate len red A = 2 / 5 := by norm_num [rate, len, red, freq, gain]
theorem rate_B : rate len red B = 1 / 500 := by norm_num [rate, len, red, freq, gain]
theorem rate_F : rate len red F = 1 / 20 := by norm_num [rate, len, red, freq, gain]

theorem A_mem_valid : A ∈ valid := by simp [valid]
theorem B_mem_valid : B ∈ valid := by simp [valid]
theorem F_not_mem_valid : F ∉ valid := by simp [valid]

/-- **Rate inversion.** The rare long valid rule `B` has a lower rate than the cheap frequent
fallacy `F` (0.002 < 0.05). -/
theorem rate_inversion : rate len red B < rate len red F := by
  rw [rate_B, rate_F]; norm_num

/-- **T4 Prop 7.3 (the vertex conjecture fails).** For every real `c` (in particular every
`c > 0`), the valid set `{A, B}` is not even a (weak) minimiser of `J_c`. -/
theorem valid_not_minimizer (c base R0 : ℝ) : ¬ IsMinimizer c base R0 len red valid := by
  rw [isMinimizer_iff]
  rintro ⟨hin, hout⟩
  by_cases hc : c * len F < red F
  · exact F_not_mem_valid (hin F hc)
  · push Not at hc
    have hB := hout B B_mem_valid
    simp only [len, red, freq, gain] at hc hB
    linarith

/-- For every `c`, the threshold set `S*(c)` differs from the valid set. -/
theorem Sstar_ne_valid (c : ℝ) : Sstar c len red ≠ valid := fun h =>
  valid_not_minimizer c 0 0 (h ▸ Sstar_isMinimizer)

/-- No `c > 0` selects exactly the valid set (as unique minimiser). -/
theorem not_selectable (base R0 : ℝ) :
    ¬ ∃ c > 0, IsUniqueMinimizer c base R0 len red valid := by
  rintro ⟨c, -, hu⟩
  exact valid_not_minimizer c base R0 fun S' => by
    by_cases h : S' = valid
    · rw [h]
    · exact (hu S' h).le

/-- The same, read off the selectability criterion: rates are not separated. -/
theorem rates_not_separated :
    ¬ ∀ j ∈ valid, 0 < rate len red j ∧ ∀ i ∉ valid, rate len red i < rate len red j := by
  intro h
  have := (h B B_mem_valid).2 F F_not_mem_valid
  linarith [rate_inversion]

/-- The selection path, part 1: for `c < 0.002`, `S* = {A, B, F}` (the fallacy is learned). -/
theorem Sstar_low {c : ℝ} (hc : c < 1 / 500) : Sstar c len red = {A, B, F} := by
  ext j
  rw [mem_Sstar_iff_rate (len_pos j)]
  cases j <;> simp [rate_A, rate_B, rate_F] <;> linarith

/-- The selection path, part 2: for `0.002 ≤ c < 0.05`, `S* = {A, F}` (`B` lost, `F` kept). -/
theorem Sstar_mid {c : ℝ} (h1 : 1 / 500 ≤ c) (h2 : c < 1 / 20) :
    Sstar c len red = {A, F} := by
  ext j
  rw [mem_Sstar_iff_rate (len_pos j)]
  cases j <;> simp [rate_A, rate_B, rate_F] <;> linarith

/-- The selection path, part 3: for `0.05 ≤ c < 0.4`, `S* = {A}`. -/
theorem Sstar_high {c : ℝ} (h1 : 1 / 20 ≤ c) (h2 : c < 2 / 5) : Sstar c len red = {A} := by
  ext j
  rw [mem_Sstar_iff_rate (len_pos j)]
  cases j <;> simp [rate_A, rate_B, rate_F] <;> linarith

/-- The selection path, part 4: for `c ≥ 0.4`, `S* = ∅`. -/
theorem Sstar_top {c : ℝ} (h1 : 2 / 5 ≤ c) : Sstar c len red = ∅ := by
  ext j
  rw [mem_Sstar_iff_rate (len_pos j)]
  cases j <;> simp [rate_A, rate_B, rate_F] <;> linarith

/-- Complexity (bits) of a rule set. -/
noncomputable def cost (S : Finset Rule) : ℝ := ∑ j ∈ S, len j

/-- Residual bits per datum of a rule set (risk reduction not achieved). -/
noncomputable def resid (S : Finset Rule) : ℝ := (∑ j, red j) - ∑ j ∈ S, red j

theorem univ_eq : (univ : Finset Rule) = {A, B, F} := by decide

theorem cost_valid : cost valid = 50 := by
  simp [cost, valid, len]
  norm_num

theorem cost_AF : cost {A, F} = 18 := by
  simp [cost, len]
  norm_num

theorem sum_red_valid : ∑ j ∈ valid, red j = 102 / 25 := by
  simp [valid, red, freq, gain]
  norm_num

theorem sum_red_AF : ∑ j ∈ ({A, F} : Finset Rule), red j = 22 / 5 := by
  simp [red, freq, gain]
  norm_num

theorem sum_red_univ : ∑ j, red j = 112 / 25 := by
  simp [univ_eq, Finset.sum_insert, red, freq, gain]
  norm_num

theorem resid_valid : resid valid = 2 / 5 := by
  rw [resid, sum_red_univ, sum_red_valid]
  norm_num

theorem resid_AF : resid {A, F} = 2 / 25 := by
  rw [resid, sum_red_univ, sum_red_AF]
  norm_num

theorem J_eq_cost_resid (c : ℝ) (S : Finset Rule) :
    J c 0 (∑ j, red j) len red S = c * cost S + resid S := by
  simp [J, cost, resid]

/-- **T4 Prop 7.3, Pareto remark (added after verification).** `{A, F} = (18, 0.08)`
Pareto-dominates `{A, B} = (50, 0.4)` in (complexity, residual bits per datum). -/
theorem pareto_dominated : cost {A, F} < cost valid ∧ resid {A, F} < resid valid := by
  rw [cost_AF, cost_valid, resid_AF, resid_valid]
  norm_num

/-- Hence no criterion strictly increasing in both coordinates prefers `{A, B}` to `{A, F}`. -/
theorem no_monotone_criterion (φ : ℝ → ℝ → ℝ) (h1 : ∀ x x' y, x < x' → φ x y < φ x' y)
    (h2 : ∀ x y y', y < y' → φ x y < φ x y') :
    φ (cost {A, F}) (resid {A, F}) < φ (cost valid) (resid valid) :=
  lt_trans (h1 _ _ _ pareto_dominated.1) (h2 _ _ _ pareto_dominated.2)

/-- In the hull picture (Lemma 3.1, applied to the class of all rule sets with
`ℓ(S) = base + ∑ len`, `R(S) = R0 - ∑ red`), the point of `{A, B}` is not a `hull⁻` vertex. -/
theorem valid_not_hullVertex (base R0 : ℝ) :
    ¬ IsHullVertex (fun S : Finset Rule => base + ∑ j ∈ S, len j)
      (fun S => R0 - ∑ j ∈ S, red j) valid := by
  have e1 : ∑ j ∈ valid, len j = 50 := cost_valid
  have e2 : ∑ j ∈ ({A, F} : Finset Rule), len j = 18 := cost_AF
  have e3 : ∑ j ∈ valid, red j = 102 / 25 := sum_red_valid
  have e4 : ∑ j ∈ ({A, F} : Finset Rule), red j = 22 / 5 := sum_red_AF
  refine not_isHullVertex_of_dominated (h' := ({A, F} : Finset Rule)) ?_ ?_ ?_
  · simp only [e1, e2, ne_eq, Prod.mk.injEq, not_and]
    intro h
    linarith
  · simp only [e1, e2]
    linarith
  · simp only [e3, e4]
    linarith

/-- Adding further hypotheses cannot make `{A, B}` a vertex: in **any** finite hypothesis class
containing hypotheses at the points of `{A, B}` and `{A, F}`, the former is not a `hull⁻`
vertex. -/
theorem valid_never_vertex {H : Type*} [Fintype H] [DecidableEq H] (ℓ R : H → ℝ)
    (hAB hAF : H) (base R0 : ℝ)
    (h1 : ℓ hAB = base + cost valid) (h2 : R hAB = R0 - ∑ j ∈ valid, red j)
    (h3 : ℓ hAF = base + cost {A, F}) (h4 : R hAF = R0 - ∑ j ∈ ({A, F} : Finset Rule), red j) :
    ¬ IsHullVertex ℓ R hAB := by
  have e3 : ∑ j ∈ valid, red j = 102 / 25 := sum_red_valid
  have e4 : ∑ j ∈ ({A, F} : Finset Rule), red j = 22 / 5 := sum_red_AF
  rw [cost_valid] at h1
  rw [cost_AF] at h3
  rw [e3] at h2
  rw [e4] at h4
  refine not_isHullVertex_of_dominated (h' := hAF) ?_ ?_ ?_
  · simp only [h1, h3, ne_eq, Prod.mk.injEq, not_and]
    intro h
    linarith
  · rw [h1, h3]; linarith
  · rw [h2, h4]; linarith

end Example

/-! ## Axiom check -/

#print axioms exists_gap
#print axioms prod_isMin_iff
#print axioms prod_isUniqueMin_iff
#print axioms isMinimizer_iff
#print axioms Sstar_isMinimizer
#print axioms isMinimizer_iff_eq_Sstar
#print axioms isUniqueMinimizer_iff
#print axioms Sstar_isUniqueMinimizer
#print axioms rate_threshold
#print axioms ties_arbitrary
#print axioms thm_3_2
#print axioms thm_3_2_unique
#print axioms thm_3_2_unique'
#print axioms rate_blindness
#print axioms selectable_iff
#print axioms exists_Sstar_eq_iff
#print axioms selectable_iff_fold
#print axioms selectable_iff_sup'_lt_inf'
#print axioms weakly_selectable_iff
#print axioms isMinAt_le_of_inHull
#print axioms onLowerHull_iff
#print axioms lemma_3_1_ii
#print axioms uniquePoint_iff_rates
#print axioms isolated_iff_chord
#print axioms chord_iff_extreme
#print axioms chord_iff_notInOthersHull
#print axioms isHullVertex_iff_chord
#print axioms lemma_3_1_iii
#print axioms lemma_3_1_iii_hyp
#print axioms not_isHullVertex_of_dominated
#print axioms J_eq_Jc
#print axioms rate_inversion
#print axioms valid_not_minimizer
#print axioms Sstar_ne_valid
#print axioms not_selectable
#print axioms rates_not_separated
#print axioms Sstar_low
#print axioms Sstar_mid
#print axioms Sstar_high
#print axioms Sstar_top
#print axioms pareto_dominated
#print axioms no_monotone_criterion
#print axioms valid_not_hullVertex
#print axioms valid_never_vertex

end RateThreshold
end InfLearn
