import NeuralGeneralization.FinitePosterior
import Mathlib.Analysis.Complex.Exponential

/-!
# The finite relevant-class sample bound

This file proves the learning step from a finite relevant class and a prior-tail
bound. It does not postulate or establish the neural-network compression theorem
that supplies that class. All samples here have the explicit IID product weights
from `FinitePosterior`, and all posterior risks use the normalized posterior.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

variable {X H : Type*} [Fintype X] [Fintype H]

/-- True error when `good x` means prediction agrees with the target at `x`. -/
def eventError (D : X → ℝ) (good : X → Prop) : ℝ :=
  ∑ x, if good x then 0 else D x

lemma eventError_nonneg (D : X → ℝ) (hD : ∀ x, 0 ≤ D x) (good : X → Prop) :
    0 ≤ eventError D good := by
  apply Finset.sum_nonneg
  intro x _
  split_ifs
  · exact le_refl 0
  · exact hD x

lemma eventError_le_one (D : X → ℝ) (hD : ∀ x, 0 ≤ D x)
    (hDsum : ∑ x, D x = 1) (good : X → Prop) : eventError D good ≤ 1 := by
  rw [← hDsum]
  apply Finset.sum_le_sum
  intro x _
  split_ifs
  · exact hD x
  · exact le_refl _

lemma event_survival_eq_one_sub_error (D : X → ℝ) (hDsum : ∑ x, D x = 1)
    (good : X → Prop) :
    (∑ x, if good x then D x else 0) = 1 - eventError D good := by
  have hs : (∑ x, if good x then D x else 0) + eventError D good = 1 := by
    unfold eventError
    rw [← Finset.sum_add_distrib, ← hDsum]
    apply Finset.sum_congr rfl
    intro x _
    split_ifs <;> simp
  linarith

lemma pow_one_sub_le_exp (a : ℝ) (ha : a ≤ 1) (n : ℕ) :
    (1 - a) ^ n ≤ Real.exp (-(n : ℝ) * a) := by
  have hstep : 1 - a ≤ Real.exp (-a) := by
    have h := Real.add_one_le_exp (-a)
    linarith
  calc
    (1 - a) ^ n ≤ Real.exp (-a) ^ n :=
      pow_le_pow_left₀ (sub_nonneg.mpr ha) hstep n
    _ = Real.exp (-(n : ℝ) * a) := by
      rw [← Real.exp_nat_mul]
      congr 1
      ring

/-- The full finite relevant-class statistical estimate used in the upper bounds.
For a class `A` whose outside mass divided by target mass is at most `τ`, the
probability that posterior average error exceeds `a + τ` is at most
`|A| exp(-n a)`. -/
theorem finite_class_posterior_bound
    (D : X → ℝ) (hD : ∀ x, 0 ≤ D x) (hDsum : ∑ x, D x = 1)
    (w : H → ℝ) (hw : ∀ h, 0 ≤ w h) (good : H → X → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (a τ : ℝ) (ha : 0 ≤ a) (ha1 : a ≤ 1)
    (htail : (∑ h ∈ Finset.univ \ A, w h) / w target ≤ τ) (n : ℕ) :
    (∑ s : Samples X n,
      if a + τ < ∑ h, posterior w (fun h => allObservations (good h) n s) h *
        eventError D (good h)
      then iidWeight D n s else 0) ≤ (A.card : ℝ) * Real.exp (-(n : ℝ) * a) := by
  let B := A.filter (fun h => a < eventError D (good h))
  have herr : ∀ h, 0 ≤ eventError D (good h) ∧ eventError D (good h) ≤ 1 :=
    fun h => ⟨eventError_nonneg D hD (good h), eventError_le_one D hD hDsum (good h)⟩
  have hbase := iid_posterior_risk_bound D hD w hw good target htarget hwt
    (fun h => eventError D (good h)) herr A a τ ha htail n
  have hsurvive : ∀ h ∈ B,
      (∑ x, if good h x then D x else 0) ^ n ≤ Real.exp (-(n : ℝ) * a) := by
    intro h hh
    have he : a < eventError D (good h) := (Finset.mem_filter.mp hh).2
    have hn : 0 ≤ ∑ x, if good h x then D x else 0 := by
      apply Finset.sum_nonneg
      intro x _
      split_ifs
      · exact hD x
      · exact le_refl 0
    have hu : (∑ x, if good h x then D x else 0) ≤ 1 - a := by
      rw [event_survival_eq_one_sub_error D hDsum]
      linarith
    exact le_trans (pow_le_pow_left₀ hn hu n) (pow_one_sub_le_exp a ha1 n)
  calc
    _ ≤ ∑ h ∈ B, (∑ x, if good h x then D x else 0) ^ n := hbase
    _ ≤ ∑ _h ∈ B, Real.exp (-(n : ℝ) * a) := Finset.sum_le_sum hsurvive
    _ = (B.card : ℝ) * Real.exp (-(n : ℝ) * a) := by simp
    _ ≤ (A.card : ℝ) * Real.exp (-(n : ℝ) * a) := by
      apply mul_le_mul_of_nonneg_right _ (Real.exp_pos _).le
      exact_mod_cast Finset.card_filter_le A (fun h => a < eventError D (good h))

/-- Expected posterior mass of any exceptional set, bounded using only the
consistent target as a denominator. The IID survival factors remain exact. -/
theorem iid_expected_posterior_mass_le
    (D : X → ℝ) (hD : ∀ x, 0 ≤ D x)
    (w : H → ℝ) (hw : ∀ h, 0 ≤ w h) (good : H → X → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (B : Finset H) (n : ℕ) :
    (∑ s : Samples X n, iidWeight D n s *
      ∑ h ∈ B, posterior w (fun h => allObservations (good h) n s) h) ≤
      ∑ h ∈ B, (w h / w target) * (∑ x, if good h x then D x else 0) ^ n := by
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_le_sum
  intro h _
  calc
    (∑ s : Samples X n, iidWeight D n s *
        posterior w (fun h => allObservations (good h) n s) h) ≤
        ∑ s : Samples X n, (w h / w target) *
          (if allObservations (good h) n s then iidWeight D n s else 0) := by
      apply Finset.sum_le_sum
      intro s _
      by_cases hs : allObservations (good h) n s
      · simp only [if_pos hs]
        have hb := posterior_le_weight_ratio w
          (fun h => allObservations (good h) n s) hw target
          (allObservations_of_forall (good target) htarget n s) hwt h
        calc
          _ ≤ iidWeight D n s * (w h / w target) :=
            mul_le_mul_of_nonneg_left hb (iidWeight_nonneg D hD n s)
          _ = _ := mul_comm _ _
      · simp [posterior, hs]
    _ = (w h / w target) * (∑ x, if good h x then D x else 0) ^ n := by
      rw [← Finset.mul_sum, iid_survival]

/-- The elementary finite Markov inequality, with strict failure threshold. -/
theorem finite_markov {Ω : Type*} [Fintype Ω]
    (q v : Ω → ℝ) (hq : ∀ ω, 0 ≤ q ω) (hv : ∀ ω, 0 ≤ v ω)
    (b : ℝ) (hb : 0 < b) :
    (∑ ω, if b < v ω then q ω else 0) ≤ (∑ ω, q ω * v ω) / b := by
  apply (le_div_iff₀ hb).mpr
  rw [Finset.sum_mul]
  apply Finset.sum_le_sum
  intro ω _
  by_cases hω : b < v ω
  · simp only [if_pos hω]
    exact mul_le_mul_of_nonneg_left hω.le (hq ω)
  · simp only [if_neg hω, zero_mul]
    exact mul_nonneg (hq ω) (hv ω)

/-- Posterior mass on hypotheses whose true error exceeds `a`. -/
def badMass (p err : H → ℝ) (a : ℝ) : ℝ :=
  ∑ h ∈ Finset.univ.filter (fun h => a < err h), p h

lemma risk_le_threshold_add_badMass (p err : H → ℝ)
    (hp : ∀ h, 0 ≤ p h) (hpsum : ∑ h, p h = 1) (herr : ∀ h, err h ≤ 1)
    (a : ℝ) (ha : 0 ≤ a) :
    (∑ h, p h * err h) ≤ a + badMass p err a := by
  have hpoint : ∀ h, p h * err h ≤ a * p h + if a < err h then p h else 0 := by
    intro h
    by_cases hh : a < err h
    · simp only [if_pos hh]
      nlinarith [mul_nonneg (hp h) (sub_nonneg.mpr (herr h)), mul_nonneg ha (hp h)]
    · simp only [if_neg hh, add_zero]
      have he : err h ≤ a := le_of_not_gt hh
      nlinarith [mul_nonneg (hp h) (sub_nonneg.mpr he)]
  calc
    _ ≤ ∑ h, (a * p h + if a < err h then p h else 0) :=
      Finset.sum_le_sum fun h _ => hpoint h
    _ = a + badMass p err a := by
      rw [Finset.sum_add_distrib, ← Finset.mul_sum, hpsum, mul_one]
      simp [badMass, Finset.sum_filter]

/-- The target-mass route: the expected posterior mass on error greater than
`a` is at most `exp(-n a) / w(target)`. -/
theorem iid_expected_badMass_le
    (D : X → ℝ) (hD : ∀ x, 0 ≤ D x) (hDsum : ∑ x, D x = 1)
    (w : H → ℝ) (hw : ∀ h, 0 ≤ w h) (hwsum : ∑ h, w h ≤ 1)
    (good : H → X → Prop) (target : H) (htarget : ∀ x, good target x)
    (hwt : 0 < w target) (a : ℝ) (ha1 : a ≤ 1) (n : ℕ) :
    (∑ s : Samples X n, iidWeight D n s *
      badMass (posterior w (fun h => allObservations (good h) n s))
        (fun h => eventError D (good h)) a) ≤
      Real.exp (-(n : ℝ) * a) / w target := by
  let B := Finset.univ.filter (fun h => a < eventError D (good h))
  have hsurv : ∀ h ∈ B,
      (∑ x, if good h x then D x else 0) ^ n ≤ Real.exp (-(n : ℝ) * a) := by
    intro h hh
    have he : a < eventError D (good h) := (Finset.mem_filter.mp hh).2
    have hn : 0 ≤ ∑ x, if good h x then D x else 0 := by
      apply Finset.sum_nonneg
      intro x _
      split_ifs
      · exact hD x
      · exact le_refl 0
    have hu : (∑ x, if good h x then D x else 0) ≤ 1 - a := by
      rw [event_survival_eq_one_sub_error D hDsum]
      linarith
    exact le_trans (pow_le_pow_left₀ hn hu n) (pow_one_sub_le_exp a ha1 n)
  calc
    _ ≤ ∑ h ∈ B, (w h / w target) * (∑ x, if good h x then D x else 0) ^ n :=
      iid_expected_posterior_mass_le D hD w hw good target htarget hwt B n
    _ ≤ ∑ h ∈ B, (w h / w target) * Real.exp (-(n : ℝ) * a) := by
      apply Finset.sum_le_sum
      intro h hh
      exact mul_le_mul_of_nonneg_left (hsurv h hh) (div_nonneg (hw h) hwt.le)
    _ = ((∑ h ∈ B, w h) / w target) * Real.exp (-(n : ℝ) * a) := by
      rw [← Finset.sum_mul, ← Finset.sum_div]
    _ ≤ (1 / w target) * Real.exp (-(n : ℝ) * a) := by
      apply mul_le_mul_of_nonneg_right _ (Real.exp_pos _).le
      exact div_le_div_of_nonneg_right
        (le_trans (Finset.sum_le_univ_sum_of_nonneg hw) hwsum) hwt.le
    _ = Real.exp (-(n : ℝ) * a) / w target := by ring

/-- The full individual-target-mass learning bound used for the smaller widths.
The prior weights need only have total mass at most one, as do the unnormalized
Gaussian masses of the disjoint global-margin sign events. -/
theorem target_mass_posterior_bound
    (D : X → ℝ) (hD : ∀ x, 0 ≤ D x) (hDsum : ∑ x, D x = 1)
    (w : H → ℝ) (hw : ∀ h, 0 ≤ w h) (hwsum : ∑ h, w h ≤ 1)
    (good : H → X → Prop) (target : H) (htarget : ∀ x, good target x)
    (hwt : 0 < w target) (a b : ℝ) (ha : 0 ≤ a) (ha1 : a ≤ 1)
    (hb : 0 < b) (n : ℕ) :
    (∑ s : Samples X n,
      if a + b < ∑ h, posterior w (fun h => allObservations (good h) n s) h *
        eventError D (good h)
      then iidWeight D n s else 0) ≤ Real.exp (-(n : ℝ) * a) / (w target * b) := by
  let p := fun s : Samples X n => posterior w (fun h => allObservations (good h) n s)
  let v := fun s => badMass (p s) (fun h => eventError D (good h)) a
  have hpn : ∀ s h, 0 ≤ p s h := fun s h => posterior_nonneg w
    (fun h => allObservations (good h) n s) hw target
    (allObservations_of_forall (good target) htarget n s) hwt h
  have hv : ∀ s, 0 ≤ v s := by
    intro s
    exact Finset.sum_nonneg fun h _ => hpn s h
  have hr : ∀ s, (∑ h, p s h * eventError D (good h)) ≤ a + v s := by
    intro s
    exact risk_le_threshold_add_badMass (p s) (fun h => eventError D (good h))
      (hpn s) (posterior_sum w (fun h => allObservations (good h) n s) hw target
        (allObservations_of_forall (good target) htarget n s) hwt)
      (fun h => eventError_le_one D hD hDsum (good h)) a ha
  calc
    _ ≤ ∑ s : Samples X n, if b < v s then iidWeight D n s else 0 := by
      apply Finset.sum_le_sum
      intro s _
      change (if a + b < ∑ h, p s h * eventError D (good h) then iidWeight D n s else 0) ≤
        (if b < v s then iidWeight D n s else 0)
      by_cases hs : a + b < ∑ h, p s h * eventError D (good h)
      · have hbv : b < v s := by linarith [hr s]
        simp [hs, hbv]
      · simp only [hs, if_false]
        split_ifs
        · exact iidWeight_nonneg D hD n s
        · exact le_refl 0
    _ ≤ (∑ s, iidWeight D n s * v s) / b :=
      finite_markov (iidWeight D n) v (iidWeight_nonneg D hD n) hv b hb
    _ ≤ (Real.exp (-(n : ℝ) * a) / w target) / b := by
      apply div_le_div_of_nonneg_right _ hb.le
      exact iid_expected_badMass_le D hD hDsum w hw hwsum good target htarget hwt a ha1 n
    _ = Real.exp (-(n : ℝ) * a) / (w target * b) := by rw [div_div]

end NeuralGeneralization
