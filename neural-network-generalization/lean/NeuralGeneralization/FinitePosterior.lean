import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Field
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.Order.BigOperators.GroupWithZero.Finset
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.SplitIfs
import Mathlib.Tactic.Push

/-!
# Finite consistency posteriors

This file proves the finite probability part of the papers. It does not assume
that a neural prior has any particular concentration or compression property.
The weights may be unnormalized (e.g. the Gaussian masses of the global-margin
sign events), so global-margin normalization cancels exactly.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators

open Classical

attribute [local instance] Classical.propDecidable

section Conditioning

variable {H : Type*} [Fintype H]

/-- Normalizing mass of the hypotheses compatible with the observations. -/
def normalizer (w : H → ℝ) (keep : H → Prop) [DecidablePred keep] : ℝ :=
  ∑ h, if keep h then w h else 0

/-- The actual normalized posterior, not an arbitrary distribution on survivors. -/
def posterior (w : H → ℝ) (keep : H → Prop) [DecidablePred keep] (h : H) : ℝ :=
  (if keep h then w h else 0) / normalizer w keep

variable (w : H → ℝ) (keep : H → Prop) [DecidablePred keep]
/-- Dividing every prior weight by the same constant scales the normalizer. -/
lemma normalizer_div_const (c : ℝ) :
    normalizer (fun h => w h / c) keep = normalizer w keep / c := by
  unfold normalizer
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro h _
  by_cases hh : keep h <;> simp [hh]

/-- Global-margin normalization cancels exactly in the consistency posterior. -/
theorem posterior_div_const (c : ℝ) (hc : c ≠ 0) :
    posterior (fun h => w h / c) keep = posterior w keep := by
  funext h
  unfold posterior
  rw [normalizer_div_const]
  by_cases hh : keep h
  · simpa only [if_pos hh] using div_div_div_cancel_right₀ hc (w h) (normalizer w keep)
  · simp [hh]

variable (hw : ∀ h, 0 ≤ w h) (target : H) (ht : keep target) (hwt : 0 < w target)

include hw ht in
lemma weight_le_normalizer : w target ≤ normalizer w keep := by
  classical
  calc
    w target = (if keep target then w target else 0) := by simp [ht]
    _ ≤ normalizer w keep := by
      unfold normalizer
      exact Finset.single_le_sum (f := fun h => if keep h then w h else 0)
        (fun h _ => by split_ifs; exact hw h; exact le_refl 0)
        (Finset.mem_univ target)

include hw ht hwt in
lemma normalizer_pos : 0 < normalizer w keep :=
  lt_of_lt_of_le hwt (weight_le_normalizer w keep hw target ht)

include hw ht hwt in
lemma posterior_nonneg (h : H) : 0 ≤ posterior w keep h := by
  apply div_nonneg
  · split_ifs
    · exact hw h
    · exact le_refl 0
  · exact (normalizer_pos w keep hw target ht hwt).le

include hw ht hwt in
lemma posterior_sum : ∑ h, posterior w keep h = 1 := by
  unfold posterior
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt (normalizer_pos w keep hw target ht hwt))

lemma posterior_of_not_kept (h : H) (hh : ¬ keep h) : posterior w keep h = 0 := by
  simp [posterior, hh]

include hw ht hwt in
lemma posterior_le_weight_ratio (h : H) : posterior w keep h ≤ w h / w target := by
  have hn := normalizer_pos w keep hw target ht hwt
  calc
    posterior w keep h ≤ w h / normalizer w keep := by
      apply div_le_div_of_nonneg_right _ hn.le
      split_ifs
      · exact le_refl _
      · exact hw h
    _ ≤ w h / w target :=
      div_le_div_of_nonneg_left (hw h) hwt (weight_le_normalizer w keep hw target ht)

include hw ht hwt in
/-- A point mass at a consistent target bounds every posterior exceptional mass. -/
lemma posterior_mass_le_weight_ratio (A : Finset H) :
    ∑ h ∈ A, posterior w keep h ≤ (∑ h ∈ A, w h) / w target := by
  calc
    ∑ h ∈ A, posterior w keep h ≤ ∑ h ∈ A, w h / w target := by
      exact Finset.sum_le_sum fun h _ =>
        posterior_le_weight_ratio w keep hw target ht hwt h
    _ = (∑ h ∈ A, w h) / w target := by rw [Finset.sum_div]

end Conditioning

section FiniteRisk

variable {H X Y : Type*} [Fintype H] [Fintype X] [DecidableEq Y]

/-- Posterior probability of an incorrect label at the given test point. -/
def errorAt (p : H → ℝ) (predict : H → X → Y) (truth : X → Y) (x : X) : ℝ :=
  ∑ h, if predict h x ≠ truth x then p h else 0

/-- Posterior probability of the correct label at the given test point. -/
def correctAt (p : H → ℝ) (predict : H → X → Y) (truth : X → Y) (x : X) : ℝ :=
  ∑ h, if predict h x = truth x then p h else 0

/-- Average error of a posterior under a finite input distribution. -/
def averageRisk (p : H → ℝ) (D : X → ℝ) (predict : H → X → Y)
    (truth : X → Y) : ℝ :=
  ∑ x, D x * errorAt p predict truth x

/-- True classification error of an individual hypothesis. -/
def hypothesisError (D : X → ℝ) (predict : H → X → Y) (truth : X → Y)
    (h : H) : ℝ :=
  ∑ x, if predict h x ≠ truth x then D x else 0

/-- Averaging prediction errors over inputs or over hypotheses is exactly equivalent. -/
theorem averageRisk_eq_sum_hypothesis (p : H → ℝ) (D : X → ℝ)
    (predict : H → X → Y) (truth : X → Y) :
    averageRisk p D predict truth = ∑ h, p h * hypothesisError D predict truth h := by
  unfold averageRisk errorAt hypothesisError
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro h _
  apply Finset.sum_congr rfl
  intro x _
  by_cases hh : predict h x ≠ truth x <;> simp [hh, mul_comm]

/-- Failure of the strict `> 2/3` criterion includes equality at `2/3`. -/
noncomputable def confidenceFailure (p : H → ℝ) (D : X → ℝ)
    (predict : H → X → Y) (truth : X → Y) : ℝ := by
  classical
  exact ∑ x, if correctAt p predict truth x ≤ (2 / 3 : ℝ) then D x else 0

variable (p : H → ℝ) (D : X → ℝ) (predict : H → X → Y) (truth : X → Y)
variable (hp : ∀ h, 0 ≤ p h) (hpsum : ∑ h, p h = 1)
variable (hD : ∀ x, 0 ≤ D x) (hDsum : ∑ x, D x = 1)

omit [Fintype X] in
include hpsum in
lemma correctAt_add_errorAt (x : X) :
    correctAt p predict truth x + errorAt p predict truth x = 1 := by
  rw [correctAt, errorAt, ← Finset.sum_add_distrib, ← hpsum]
  apply Finset.sum_congr rfl
  intro h _
  by_cases hh : predict h x = truth x <;> simp [hh]

omit [Fintype X] in
include hp in
lemma errorAt_nonneg (x : X) : 0 ≤ errorAt p predict truth x := by
  apply Finset.sum_nonneg
  intro h _
  split_ifs
  · exact hp h
  · exact le_refl 0

omit [Fintype X] in
include hp in
lemma correctAt_nonneg (x : X) : 0 ≤ correctAt p predict truth x := by
  apply Finset.sum_nonneg
  intro h _
  split_ifs
  · exact hp h
  · exact le_refl 0

omit [Fintype X] in
include hp hpsum in
lemma errorAt_le_one (x : X) : errorAt p predict truth x ≤ 1 := by
  have hc := correctAt_nonneg p predict truth hp x
  have he := correctAt_add_errorAt p predict truth hpsum x
  linarith

include hp hpsum hD in
/-- Markov conversion with precisely the strict confidence convention. -/
theorem confidenceFailure_le_three_risk :
    confidenceFailure p D predict truth ≤ 3 * averageRisk p D predict truth := by
  classical
  unfold confidenceFailure averageRisk
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro x _
  have hs := correctAt_add_errorAt p predict truth hpsum x
  have he := errorAt_nonneg p predict truth hp x
  by_cases hx : correctAt p predict truth x ≤ (2 / 3 : ℝ)
  · simp only [if_pos hx]
    nlinarith [hD x, mul_nonneg (hD x) (show 0 ≤ 3 * errorAt p predict truth x - 1 by linarith)]
  · simp only [if_neg hx]
    exact mul_nonneg (by norm_num) (mul_nonneg (hD x) he)

include hp hpsum hD in
/-- An average-risk upper bound gives the desired strict confidence guarantee. -/
theorem confidenceFailure_le_of_risk_le {ε : ℝ}
    (hrisk : averageRisk p D predict truth ≤ ε / 3) :
    confidenceFailure p D predict truth ≤ ε := by
  have hb := confidenceFailure_le_three_risk p D predict truth hp hpsum hD
  linarith

include hp hpsum hD hDsum in
/-- The reverse conversion used for sample-complexity lower bounds. -/
theorem risk_le_one_third_add_failure :
    averageRisk p D predict truth ≤
      1 / 3 + (2 / 3) * confidenceFailure p D predict truth := by
  classical
  have hpoint : ∀ x, D x * errorAt p predict truth x ≤
      D x / 3 + (2 / 3) * (if correctAt p predict truth x ≤ (2 / 3 : ℝ)
        then D x else 0) := by
    intro x
    have hs := correctAt_add_errorAt p predict truth hpsum x
    have he := errorAt_le_one p predict truth hp hpsum x
    by_cases hx : correctAt p predict truth x ≤ (2 / 3 : ℝ)
    · simp only [if_pos hx]
      nlinarith [mul_nonneg (hD x) (sub_nonneg.mpr he)]
    · simp only [if_neg hx, mul_zero, add_zero]
      have herr : errorAt p predict truth x ≤ (1 / 3 : ℝ) := by
        have hx' := lt_of_not_ge hx
        linarith
      nlinarith [mul_nonneg (hD x) (sub_nonneg.mpr herr)]
  calc
    averageRisk p D predict truth ≤ ∑ x, (D x / 3 + (2 / 3) *
        (if correctAt p predict truth x ≤ (2 / 3 : ℝ) then D x else 0)) :=
      Finset.sum_le_sum fun x _ => hpoint x
    _ = 1 / 3 + (2 / 3) * confidenceFailure p D predict truth := by
      rw [Finset.sum_add_distrib, ← Finset.sum_div, ← Finset.mul_sum, hDsum]
      rfl

include hp hpsum in
/-- A pointwise lower bound on the errors of posterior-supported hypotheses
passes to posterior average risk. -/
theorem lower_bound_averageRisk {r : ℝ}
    (herror : ∀ h, 0 < p h → r ≤ hypothesisError D predict truth h) :
    r ≤ averageRisk p D predict truth := by
  rw [averageRisk_eq_sum_hypothesis]
  calc
    r = ∑ h, p h * r := by rw [← Finset.sum_mul, hpsum, one_mul]
    _ ≤ ∑ h, p h * hypothesisError D predict truth h := by
      apply Finset.sum_le_sum
      intro h _
      by_cases hz : p h = 0
      · simp [hz]
      · exact mul_le_mul_of_nonneg_left (herror h (lt_of_le_of_ne (hp h) (Ne.symm hz))) (hp h)

include hp hpsum hD hDsum in
/-- In particular, risk at least `3/8` forces confidence failure at least `1/16`. -/
theorem one_sixteenth_le_confidenceFailure
    (hrisk : (3 / 8 : ℝ) ≤ averageRisk p D predict truth) :
    (1 / 16 : ℝ) ≤ confidenceFailure p D predict truth := by
  have hb := risk_le_one_third_add_failure p D predict truth hp hpsum hD hDsum
  linarith

end FiniteRisk

section RelevantClass

variable {H : Type*} [Fintype H] [DecidableEq H]

/-- Deterministic part of the finite relevant-class posterior bound.
All retained members of `A` have error at most `a`. -/
theorem posterior_risk_le
    (w : H → ℝ) (keep : H → Prop) [DecidablePred keep]
    (hw : ∀ h, 0 ≤ w h) (target : H) (ht : keep target) (hwt : 0 < w target)
    (err : H → ℝ) (herr : ∀ h, 0 ≤ err h ∧ err h ≤ 1)
    (A : Finset H) (a τ : ℝ) (ha : 0 ≤ a)
    (hgood : ∀ h ∈ A, keep h → err h ≤ a)
    (htail : (∑ h ∈ Finset.univ \ A, w h) / w target ≤ τ) :
    (∑ h, posterior w keep h * err h) ≤ a + τ := by
  have hpn := posterior_nonneg w keep hw target ht hwt
  have hps := posterior_sum w keep hw target ht hwt
  have hout := posterior_mass_le_weight_ratio w keep hw target ht hwt (Finset.univ \ A)
  have hpoint : ∀ h, posterior w keep h * err h ≤
      a * posterior w keep h + if h ∈ A then 0 else posterior w keep h := by
    intro h
    by_cases hA : h ∈ A
    · simp only [if_pos hA, add_zero]
      by_cases hk : keep h
      · nlinarith [mul_nonneg (hpn h) (sub_nonneg.mpr (hgood h hA hk))]
      · simp [posterior_of_not_kept w keep h hk]
    · simp only [if_neg hA]
      nlinarith [mul_nonneg (hpn h) (sub_nonneg.mpr (herr h).2), mul_nonneg ha (hpn h)]
  calc
    (∑ h, posterior w keep h * err h) ≤
        ∑ h, (a * posterior w keep h + if h ∈ A then 0 else posterior w keep h) :=
      Finset.sum_le_sum fun h _ => hpoint h
    _ = a + ∑ h ∈ Finset.univ \ A, posterior w keep h := by
      rw [Finset.sum_add_distrib, ← Finset.mul_sum, hps, mul_one]
      congr 1
      have hset : Finset.univ \ A = Finset.univ.filter (fun h => h ∉ A) := by
        ext h
        simp
      rw [hset, Finset.sum_filter]
      apply Finset.sum_congr rfl
      intro h _
      by_cases hh : h ∈ A <;> simp [hh]
    _ ≤ a + τ := by linarith [le_trans hout htail]

end RelevantClass

section IID

variable {X H : Type*} [Fintype X] [Fintype H]

/-- The actual finite space of `n` ordered observations. -/
abbrev Samples (X : Type*) (n : ℕ) := Fin n → X

/-- Product weights of genuinely independent identically distributed draws. -/
def iidWeight (D : X → ℝ) (n : ℕ) (s : Samples X n) : ℝ := ∏ i, D (s i)

/-- All observations satisfy the specified one-observation event. -/
def allObservations (good : X → Prop) (n : ℕ) (s : Samples X n) : Prop :=
  ∀ i, good (s i)

noncomputable instance allObservationsDecidable (good : X → Prop) (n : ℕ) :
    DecidablePred (allObservations good n) := Classical.decPred _

omit [Fintype X] in
lemma allObservations_of_forall (good : X → Prop) (hg : ∀ x, good x) (n : ℕ)
    (s : Samples X n) : allObservations good n s := fun i => hg (s i)

omit [Fintype X] in
lemma iidWeight_nonneg (D : X → ℝ) (hD : ∀ x, 0 ≤ D x) (n : ℕ)
    (s : Samples X n) : 0 ≤ iidWeight D n s := by
  unfold iidWeight
  exact Finset.prod_nonneg fun i _ => hD (s i)

/-- Exact finite IID survival probability, prior to any exponential estimate. -/
theorem iid_survival (D : X → ℝ) (good : X → Prop) [DecidablePred good] (n : ℕ) :
    (∑ s : Samples X n, if allObservations good n s then iidWeight D n s else 0) =
      (∑ x, if good x then D x else 0) ^ n := by
  classical
  rw [Fintype.sum_pow]
  apply Finset.sum_congr rfl
  intro s _
  by_cases hs : allObservations good n s
  · simp only [if_pos hs]
    unfold iidWeight
    apply Finset.prod_congr rfl
    intro i _
    simp [hs i]
  · simp only [if_neg hs]
    obtain ⟨i, hi⟩ := not_forall.mp hs
    symm
    apply Finset.prod_eq_zero (Finset.mem_univ i)
    simp [hi]

/-- Classification survival is `(1 - true error)^n`, exactly. -/
theorem iid_classification_survival {Y : Type*} [DecidableEq Y]
    (D : X → ℝ) (hDsum : ∑ x, D x = 1)
    (predict truth : X → Y) (n : ℕ) :
    (∑ s : Samples X n,
      if allObservations (fun x => predict x = truth x) n s then iidWeight D n s else 0) =
      (1 - ∑ x, if predict x ≠ truth x then D x else 0) ^ n := by
  rw [iid_survival]
  congr 1
  have hs : (∑ x, if predict x = truth x then D x else 0) +
      (∑ x, if predict x ≠ truth x then D x else 0) = 1 := by
    rw [← Finset.sum_add_distrib, ← hDsum]
    apply Finset.sum_congr rfl
    intro x _
    by_cases hx : predict x = truth x <;> simp [hx]
  linarith

lemma iidWeight_sum (D : X → ℝ) (hDsum : ∑ x, D x = 1) (n : ℕ) :
    ∑ s : Samples X n, iidWeight D n s = 1 := by
  unfold iidWeight
  rw [← Fintype.sum_pow, hDsum, one_pow]

omit [Fintype H] in
/-- Union bound for any finite collection of hypotheses on the actual IID sample space. -/
theorem iid_union_bound (D : X → ℝ) (hD : ∀ x, 0 ≤ D x)
    (good : H → X → Prop) (A : Finset H) (n : ℕ) :
    (∑ s : Samples X n,
      if ∃ h ∈ A, allObservations (good h) n s then iidWeight D n s else 0) ≤
      ∑ h ∈ A, (∑ x, if good h x then D x else 0) ^ n := by
  classical
  have hpoint : ∀ s : Samples X n,
      (if ∃ h ∈ A, allObservations (good h) n s then iidWeight D n s else 0) ≤
      ∑ h ∈ A, if allObservations (good h) n s then iidWeight D n s else 0 := by
    intro s
    by_cases he : ∃ h ∈ A, allObservations (good h) n s
    · obtain ⟨h, hA, hh⟩ := he
      simp only [if_pos (show ∃ h ∈ A, allObservations (good h) n s from ⟨h, hA, hh⟩)]
      calc
        iidWeight D n s = (if allObservations (good h) n s then iidWeight D n s else 0) := by simp [hh]
        _ ≤ ∑ h ∈ A, if allObservations (good h) n s then iidWeight D n s else 0 := by
          apply Finset.single_le_sum _ hA
          intro h' _
          split_ifs
          · exact iidWeight_nonneg D hD n s
          · exact le_refl 0
    · simp only [if_neg he]
      apply Finset.sum_nonneg
      intro h _
      split_ifs
      · exact iidWeight_nonneg D hD n s
      · exact le_refl 0
  calc
    _ ≤ ∑ s : Samples X n,
        ∑ h ∈ A, if allObservations (good h) n s then iidWeight D n s else 0 :=
      Finset.sum_le_sum fun s _ => hpoint s
    _ = ∑ h ∈ A, (∑ x, if good h x then D x else 0) ^ n := by
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro h _
      exact iid_survival D (good h) n

/-- The finite relevant-class learning estimate with its exact IID probability bound.
The result concerns the actual normalized consistency posterior, not a selected
hypothesis or a posterior-mean predictor. -/
theorem iid_posterior_risk_bound (D : X → ℝ) (hD : ∀ x, 0 ≤ D x)
    (w : H → ℝ) (hw : ∀ h, 0 ≤ w h) (good : H → X → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (err : H → ℝ) (herr : ∀ h, 0 ≤ err h ∧ err h ≤ 1)
    (A : Finset H) (a τ : ℝ) (ha : 0 ≤ a)
    (htail : (∑ h ∈ Finset.univ \ A, w h) / w target ≤ τ) (n : ℕ) :
    (∑ s : Samples X n,
      if a + τ < ∑ h, posterior w (fun h => allObservations (good h) n s) h * err h
      then iidWeight D n s else 0) ≤
      ∑ h ∈ A.filter (fun h => a < err h),
        (∑ x, if good h x then D x else 0) ^ n := by
  classical
  let B := A.filter (fun h => a < err h)
  have implies_bad_survivor : ∀ s : Samples X n,
      a + τ < ∑ h, posterior w (fun h => allObservations (good h) n s) h * err h →
      ∃ h ∈ B, allObservations (good h) n s := by
    intro s hbad
    by_contra hnone
    have hgood : ∀ h ∈ A, allObservations (good h) n s → err h ≤ a := by
      intro h hA hs
      by_contra herror
      have hb : h ∈ B := by simp [B, hA, lt_of_not_ge herror]
      exact hnone ⟨h, hb, hs⟩
    have hr := posterior_risk_le w (fun h => allObservations (good h) n s)
      hw target (allObservations_of_forall (good target) htarget n s) hwt
      err herr A a τ ha hgood htail
    exact (not_lt_of_ge hr) hbad
  calc
    _ ≤ ∑ s : Samples X n,
        if ∃ h ∈ B, allObservations (good h) n s then iidWeight D n s else 0 := by
      apply Finset.sum_le_sum
      intro s _
      by_cases hr : a + τ < ∑ h,
          posterior w (fun h => allObservations (good h) n s) h * err h
      · simp [hr, implies_bad_survivor s hr]
      · simp only [if_neg hr]
        split_ifs
        · exact iidWeight_nonneg D hD n s
        · exact le_refl 0
    _ ≤ ∑ h ∈ B, (∑ x, if good h x then D x else 0) ^ n :=
      iid_union_bound D hD good B n

end IID

end NeuralGeneralization
