import NeuralGeneralization.IIDHoeffding
import NeuralGeneralization.BoundedTiltDomination
import NeuralGeneralization.GaussianLinear
import NeuralGeneralization.TanhHessian

/-!
Actual IID sampling under a bounded exponential tilt. The covariance event
and Gaussian coordinate event are measured under the very same product law;
the final existence theorem therefore selects actual bounded real rows.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.TiltedRowSampling
open CompressionSampling
variable {Ω : Type*} [MeasurableSpace Ω]

/-- The empirical mean form of the actual IID Hoeffding inequality. -/
theorem iid_bounded_mean_tail (ν : Measure Ω) [IsProbabilityMeasure ν]
    {N : ℕ} (hN : 0 < N) (f : Ω → ℝ) (hf : Measurable f)
    (hbound : ∀ x, |f x| ≤ 1) {η : ℝ} (hη : 0 ≤ η) :
    (iidSamples ν N).real
      {ω | η ≤ |(∑ i, f (ω i)) / (N : ℝ) - ∫ x, f x ∂ν|} ≤
      2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) := by
  have hNR : 0 < (N : ℝ) := Nat.cast_pos.mpr hN
  have h := iid_bounded_sum_tail ν N f hf (by norm_num : (0 : ℝ) ≤ 1)
    hbound (mul_nonneg hNR.le hη)
  have heq : {ω : Fin N → Ω | η ≤ |(∑ i, f (ω i)) / (N : ℝ) - ∫ x, f x ∂ν|} =
      {ω | (N : ℝ) * η ≤ |(∑ i, f (ω i)) - (N : ℝ) * ∫ x, f x ∂ν|} := by
    ext ω
    simp only [Set.mem_setOf_eq]
    rw [div_sub' hNR.ne', abs_div, abs_of_pos hNR, le_div_iff₀ hNR]
    rw [mul_comm η]
  rw [heq]
  convert h using 2
  congr 1
  field_simp
  <;> ring

variable {X : Type*} [Fintype X]

/-- Simultaneous control of all actual empirical covariance entries. -/
theorem covariance_sampling_tail (ν : Measure Ω) [IsProbabilityMeasure ν]
    (h : Ω → X → ℝ) (hh : ∀ x, Measurable (fun a => h a x))
    (hbound : ∀ a x, |h a x| ≤ 1) {N : ℕ} (hN : 0 < N) {η : ℝ} (hη : 0 ≤ η) :
    (iidSamples ν N).real
      {ω | ∃ x y, η ≤ |(∑ i, h (ω i) x * h (ω i) y) / (N : ℝ) -
        ∫ a, h a x * h a y ∂ν|} ≤
      2 * (Fintype.card X : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) := by
  let E (e : X × X) : Set (Fin N → Ω) :=
    {ω | η ≤ |(∑ i, h (ω i) e.1 * h (ω i) e.2) / (N : ℝ) -
      ∫ a, h a e.1 * h a e.2 ∂ν|}
  have htail (e : X × X) : (iidSamples ν N).real (E e) ≤
      2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) := by
    apply iid_bounded_mean_tail ν hN (fun a => h a e.1 * h a e.2)
      ((hh e.1).mul (hh e.2)) _ hη
    intro a
    rw [abs_mul]
    simpa using mul_le_mul (hbound a e.1) (hbound a e.2) (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)
  have heq : {ω : Fin N → Ω | ∃ x y, η ≤ |(∑ i, h (ω i) x * h (ω i) y) / (N : ℝ) -
        ∫ a, h a x * h a y ∂ν|} = ⋃ e, E e := by
    ext ω
    simp only [E, Set.mem_setOf_eq, Set.mem_iUnion, Prod.exists]
  rw [heq]
  calc
    _ ≤ ∑ e, (iidSamples ν N).real (E e) := measureReal_iUnion_fintype_le E
    _ ≤ ∑ _e : X × X, 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) :=
      Finset.sum_le_sum (fun e he => htail e)
    _ = _ := by simp [Fintype.card_prod]; ring

variable {J : Type*} [Fintype J] [DecidableEq J]

theorem gaussian_coordinate_tail (v : J → ℝ≥0) (hv : ∀ j, (v j : ℝ) ≤ 1)
    (j : J) {B : ℝ} (hB : 0 ≤ B) :
    (Measure.pi fun j => gaussianReal 0 (v j)).real {w : J → ℝ | B ≤ |w j|} ≤
      2 * Real.exp (-B ^ 2 / 2) := by
  have h := GaussianTail.gaussian_linear_form_abs_tail v
    (fun i => if i = j then 1 else 0) 1 B (by norm_num) hB (by simpa using hv j)
  simpa using h

/-- All scalar row coordinates under the actual bounded tilt. -/
theorem tilted_coordinate_tail (v : J → ℝ≥0) (hv : ∀ j, (v j : ℝ) ≤ 1)
    (V : (J → ℝ) → ℝ) (hV : Measurable V) {G : ℝ} (hbound : ∀ w, |V w| ≤ G)
    (j : J) {B : ℝ} (hB : 0 ≤ B) :
    ((Measure.pi fun j => gaussianReal 0 (v j)).tilted V).real
      {w : J → ℝ | B ≤ |w j|} ≤ 2 * Real.exp (2 * G - B ^ 2 / 2) := by
  apply (BoundedTilt.tilted_measureReal_le _ V hV hbound _).trans
  calc
    _ ≤ Real.exp (2 * G) * (2 * Real.exp (-B ^ 2 / 2)) :=
      mul_le_mul_of_nonneg_left (gaussian_coordinate_tail v hv j hB) (Real.exp_pos _).le
    _ = _ := by rw [← mul_assoc, mul_comm _ 2, mul_assoc, ← Real.exp_add]; congr 2; ring


/-- The boundedness event for every sampled row and every scalar coordinate. -/
theorem sampled_tilted_coordinate_tail (v : J → ℝ≥0) (hv : ∀ j, (v j : ℝ) ≤ 1)
    (V : (J → ℝ) → ℝ) (hV : Measurable V) {G : ℝ} (hbound : ∀ w, |V w| ≤ G)
    (N : ℕ) {B : ℝ} (hB : 0 ≤ B) :
    (iidSamples ((Measure.pi fun j => gaussianReal 0 (v j)).tilted V) N).real
      {w : Fin N → J → ℝ | ∃ i j, B ≤ |w i j|} ≤
      2 * (N : ℝ) * (Fintype.card J : ℝ) * Real.exp (2 * G - B ^ 2 / 2) := by
  let ν := (Measure.pi fun j => gaussianReal 0 (v j)).tilted V
  letI : IsProbabilityMeasure ν := BoundedTilt.tilted_probability _ V hV hbound
  let E (e : Fin N × J) : Set (Fin N → J → ℝ) := {w | B ≤ |w e.1 e.2|}
  have hi (e : Fin N × J) : (iidSamples ν N).real (E e) =
      ν.real {w : J → ℝ | B ≤ |w e.2|} := by
    have hs : MeasurableSet {w : J → ℝ | B ≤ |w e.2|} :=
      measurableSet_le measurable_const ((measurable_pi_apply e.2).abs)
    have hmap := (measurePreserving_eval (fun _ : Fin N => ν) e.1).map_eq
    have h := Measure.map_apply (μ := iidSamples ν N) (measurable_pi_apply e.1) hs
    rw [show (iidSamples ν N).map (fun w => w e.1) = ν from hmap] at h
    exact congrArg ENNReal.toReal h.symm
  have heq : {w : Fin N → J → ℝ | ∃ i j, B ≤ |w i j|} = ⋃ e, E e := by
    ext w
    simp only [E, Set.mem_setOf_eq, Set.mem_iUnion, Prod.exists]
  change (iidSamples ν N).real _ ≤ _
  rw [heq]
  calc
    _ ≤ ∑ e, (iidSamples ν N).real (E e) := measureReal_iUnion_fintype_le E
    _ ≤ ∑ _e : Fin N × J, 2 * Real.exp (2 * G - B ^ 2 / 2) := by
      apply Finset.sum_le_sum
      intro e he
      rw [hi]
      exact tilted_coordinate_tail v hv V hV hbound e.2 hB
    _ = _ := by simp [Fintype.card_prod]; ring

/-- Strict probability budgets select actual rows satisfying both covariance
accuracy and all coordinate bounds; no adaptive-kernel premise is needed. -/
theorem exists_bounded_covariance_rows (v : J → ℝ≥0) (hv : ∀ j, (v j : ℝ) ≤ 1)
    (V : (J → ℝ) → ℝ) (hV : Measurable V) {G : ℝ} (hVbound : ∀ w, |V w| ≤ G)
    (h : (J → ℝ) → X → ℝ) (hh : ∀ x, Measurable (fun w => h w x))
    (hbound : ∀ w x, |h w x| ≤ 1) {N : ℕ} (hN : 0 < N)
    {η B : ℝ} (hη : 0 ≤ η) (hB : 0 ≤ B)
    (hbudget : 2 * (Fintype.card X : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) +
      2 * (N : ℝ) * (Fintype.card J : ℝ) * Real.exp (2 * G - B ^ 2 / 2) < 1) :
    ∃ w : Fin N → J → ℝ, (∀ i j, |w i j| < B) ∧ ∀ x y,
      |(∑ i, h (w i) x * h (w i) y) / (N : ℝ) -
        ∫ a, h a x * h a y ∂((Measure.pi fun j => gaussianReal 0 (v j)).tilted V)| < η := by
  let ν := (Measure.pi fun j => gaussianReal 0 (v j)).tilted V
  letI : IsProbabilityMeasure ν := BoundedTilt.tilted_probability _ V hV hVbound
  let A : Set (Fin N → J → ℝ) := {w | ∃ x y,
    η ≤ |(∑ i, h (w i) x * h (w i) y) / (N : ℝ) - ∫ a, h a x * h a y ∂ν|}
  let Bset : Set (Fin N → J → ℝ) := {w | ∃ i j, B ≤ |w i j|}
  have hA := covariance_sampling_tail ν h hh hbound hN hη
  have hBset := sampled_tilted_coordinate_tail v hv V hV hVbound N hB
  by_contra hnone
  have hcover : A ∪ Bset = Set.univ := by
    ext w
    simp only [Set.mem_union, Set.mem_univ, iff_true]
    by_contra hnot
    obtain ⟨ha, hb⟩ := not_or.mp hnot
    apply hnone
    refine ⟨w, ?_, ?_⟩
    · intro i j
      exact lt_of_not_ge (fun hij => hb ⟨i, j, hij⟩)
    · intro x y
      exact lt_of_not_ge (fun hxy => ha ⟨x, y, hxy⟩)
  have hu := measureReal_union_le (μ := iidSamples ν N) A Bset
  rw [hcover] at hu
  simp only [probReal_univ] at hu
  change (iidSamples ν N).real A ≤ _ at hA
  change (iidSamples ν N).real Bset ≤ _ at hBset
  linarith

end NeuralGeneralization.TiltedRowSampling
