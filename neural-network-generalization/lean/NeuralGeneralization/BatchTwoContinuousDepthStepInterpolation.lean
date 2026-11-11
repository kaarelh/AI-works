import NeuralGeneralization.BatchTwoContinuousDepthStepPartition
import Mathlib.LinearAlgebra.Matrix.ToLin
import Mathlib.LinearAlgebra.FiniteDimensional.Basic

/-! Exact inversion of the ordered tanh step interpolator, with the literal
8/7 infinity-norm bound used for labels of magnitude at most 7/8. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuousDepthLower BatchTwoNeuralConverse

def idealProfile {m : ℕ} (i : Fin (m+1)) (j : Fin m) : ℝ :=
  if j.val < i.val then 1 else -1

theorem extended_idealProfile {m : ℕ} (i : Fin (m+1)) (j : Fin (m+2)) :
    extendedProfile (idealProfile i) j = if j.val ≤ i.val then 1 else -1 := by
  induction j using Fin.cases with
  | zero => simp
  | succ j =>
    induction j using Fin.lastCases with
    | last =>
      simp only [Fin.succ_last,extendedProfile_last,Fin.val_last]
      have hnot : ¬ m+1 ≤ i.val := by omega
      simp [hnot]
    | cast j =>
      simp only [extendedProfile_internal,idealProfile,Fin.val_succ,Fin.val_castSucc]
      congr 1

theorem stepBasis_idealProfile {m : ℕ} (i j : Fin (m+1)) :
    stepBasis (idealProfile i) j = if j=i then 1 else 0 := by
  simp only [stepBasis,extended_idealProfile,Fin.val_castSucc,Fin.val_succ]
  by_cases h : j=i
  · subst j; simp
  · have hne : j.val ≠ i.val := fun hh => h (Fin.ext hh)
    split_ifs <;> norm_num <;> omega

theorem stepCombination_ideal {m : ℕ} (i : Fin (m+1)) (t : Fin (m+1) → ℝ) :
    stepCombination (idealProfile i) t=t i := by
  rw [stepCombination_partition]
  simp only [stepBasis_idealProfile,ite_mul,one_mul,zero_mul,Finset.sum_ite_eq',Finset.mem_univ,if_true]

theorem stepCombination_profile_error {m : ℕ} (θ η : Fin m → ℝ) (t : Fin (m+1) → ℝ)
    {B e : ℝ} (hB : 0 ≤ B) (he : 0 ≤ e) (ht : ∀ i, |t i| ≤ B)
    (hθη : ∀ j, |θ j-η j| ≤ e) :
    |stepCombination θ t-stepCombination η t| ≤ (m : ℝ)*B*e := by
  have hid : stepCombination θ t-stepCombination η t =
      ∑ j : Fin m, ((t j.succ-t j.castSucc)/2)*(θ j-η j) := by
    unfold stepCombination
    rw [add_sub_add_left_eq_sub,← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [hid]
  calc
    _ ≤ ∑ j : Fin m, |((t j.succ-t j.castSucc)/2)*(θ j-η j)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _j : Fin m, B*e := by
      apply Finset.sum_le_sum
      intro j _
      rw [abs_mul]
      apply mul_le_mul _ (hθη j) (abs_nonneg _) hB
      rw [abs_div,abs_of_pos (by norm_num : (0 : ℝ)<2)]
      apply (div_le_iff₀ (by norm_num : (0 : ℝ)<2)).mpr
      exact (abs_sub _ _).trans (by linarith [ht j.succ,ht j.castSucc])
    _ = _ := by simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]; ring

def sampleCenters {m : ℕ} (s : Fin (m+1) → ℝ) (j : Fin m) : ℝ :=
  (s j.castSucc+s j.succ)/2

theorem sampleCenters_monotone {m : ℕ} (s : Fin (m+1) → ℝ) (hs : Monotone s) :
    Monotone (sampleCenters s) := by
  intro i j hij
  unfold sampleCenters
  have h1 := hs (Fin.castSucc_le_castSucc_iff.mpr hij)
  have h2 := hs (Fin.succ_le_succ_iff.mpr hij)
  linarith

theorem sampleCenters_bound {m : ℕ} (s : Fin (m+1) → ℝ) (hs : ∀ i, |s i| ≤ 1)
    (j : Fin m) : |sampleCenters s j| ≤ 1 := by
  unfold sampleCenters
  rw [abs_div,abs_of_pos (by norm_num : (0 : ℝ)<2)]
  apply (div_le_iff₀ (by norm_num : (0 : ℝ)<2)).mpr
  exact (abs_add_le _ _).trans (by linarith [hs j.castSucc,hs j.succ])

theorem thresholdProfile_sample_error {m : ℕ} {δ : ℝ} (hδ : 0 < δ)
    (s : Fin (m+1) → ℝ) (hs : Monotone s)
    (hsep : ∀ j : Fin m, δ ≤ s j.succ-s j.castSucc) (i : Fin (m+1)) (j : Fin m) :
    |thresholdProfile (interpolationSlope (m+1) δ) (sampleCenters s) (s i) j-idealProfile i j| ≤
      1/(8*((m+1 : ℕ) : ℝ)) := by
  let a := interpolationSlope (m+1) δ
  have ha : 0 < a := interpolationSlope_pos (Nat.succ_pos m) hδ
  rw [← interpolationSlope_exp (Nat.succ_pos m) hδ]
  change |Real.tanh (a*(s i-sampleCenters s j))-idealProfile i j| ≤ 2*Real.exp (-a*δ)
  by_cases hji : j.val < i.val
  · have hj : s j.succ ≤ s i := hs (by change j.val+1 ≤ i.val; omega)
    have harg : a*δ/2 ≤ a*(s i-sampleCenters s j) := by
      unfold sampleCenters
      have hbase : δ/2 ≤ s i-(s j.castSucc+s j.succ)/2 := by linarith [hsep j]
      nlinarith [mul_le_mul_of_nonneg_left hbase ha.le]
    have h := logistic_positive_error harg
    have hsq : |Real.tanh (a*(s i-sampleCenters s j))-1| =
        2*|((1+Real.tanh (a*(s i-sampleCenters s j)))/2)-1| := by
      calc
        _ = |2*(((1+Real.tanh (a*(s i-sampleCenters s j)))/2)-1)| := by congr 1; ring
        _ = _ := by rw [abs_mul]; norm_num
    simp only [idealProfile,if_pos hji]
    rw [hsq]
    have hex : -2*(a*δ/2) = -a*δ := by ring
    rw [hex] at h
    linarith
  · have hj : s i ≤ s j.castSucc := hs (by change i.val ≤ j.val; omega)
    have harg : a*(s i-sampleCenters s j) ≤ -(a*δ/2) := by
      unfold sampleCenters
      have hbase : s i-(s j.castSucc+s j.succ)/2 ≤ -δ/2 := by linarith [hsep j]
      nlinarith [mul_le_mul_of_nonneg_left hbase ha.le]
    have h := logistic_negative_error harg
    have hsq : |Real.tanh (a*(s i-sampleCenters s j))-(-1)| =
        2*|(1+Real.tanh (a*(s i-sampleCenters s j)))/2| := by
      calc
        _ = |2*((1+Real.tanh (a*(s i-sampleCenters s j)))/2)| := by congr 1; ring
        _ = _ := by rw [abs_mul]; norm_num
    simp only [idealProfile,if_neg hji]
    rw [hsq]
    have hex : -2*(a*δ/2) = -a*δ := by ring
    rw [hex] at h
    linarith

def stepSampleMap {m : ℕ} (a : ℝ) (s : Fin (m+1) → ℝ) :
    (Fin (m+1) → ℝ) →ₗ[ℝ] (Fin (m+1) → ℝ) :=
  Matrix.mulVecLin (fun i j => stepBasis (thresholdProfile a (sampleCenters s) (s i)) j)

theorem stepSampleMap_apply {m : ℕ} (a : ℝ) (s t : Fin (m+1) → ℝ) (i : Fin (m+1)) :
    stepSampleMap a s t i = stepCombination (thresholdProfile a (sampleCenters s) (s i)) t := by
  rw [stepCombination_partition]
  rfl

theorem stepSampleMap_error {m : ℕ} {δ : ℝ} (hδ : 0 < δ)
    (s : Fin (m+1) → ℝ) (hs : Monotone s)
    (hsep : ∀ j : Fin m, δ ≤ s j.succ-s j.castSucc) (t : Fin (m+1) → ℝ) :
    ‖stepSampleMap (interpolationSlope (m+1) δ) s t-t‖ ≤ (1/8 : ℝ)*‖t‖ := by
  apply (pi_norm_le_iff_of_nonneg (by positivity)).mpr
  intro i
  simp only [Pi.sub_apply,Real.norm_eq_abs,stepSampleMap_apply]
  rw [← stepCombination_ideal i t]
  have h := stepCombination_profile_error _ _ t (norm_nonneg t)
    (by positivity : 0 ≤ 1/(8*((m+1 : ℕ) : ℝ)))
    (fun j => by simpa only [Real.norm_eq_abs] using norm_le_pi_norm t j)
    (thresholdProfile_sample_error hδ s hs hsep i)
  apply h.trans
  have hn : (0 : ℝ) < (m+1 : ℕ) := by positivity
  rw [mul_assoc,mul_comm ‖t‖,← mul_assoc]
  apply mul_le_mul_of_nonneg_right _ (norm_nonneg t)
  rw [mul_one_div]
  apply (div_le_iff₀ (by positivity : 0 < 8*((m+1 : ℕ) : ℝ))).mpr
  push_cast
  linarith


/-- The actual finite step matrix is bijective, and its inverse has infinity
norm at most 8/7. This includes m=0, when there are no thresholds. -/
theorem exists_step_coefficients {m : ℕ} {δ : ℝ} (hδ : 0 < δ)
    (s : Fin (m+1) → ℝ) (hs : Monotone s)
    (hsep : ∀ j : Fin m, δ ≤ s j.succ-s j.castSucc) (y : Fin (m+1) → ℝ) :
    ∃ t : Fin (m+1) → ℝ, ‖t‖ ≤ (8/7 : ℝ)*‖y‖ ∧
      ∀ i, stepCombination (thresholdProfile (interpolationSlope (m+1) δ)
        (sampleCenters s) (s i)) t = y i := by
  let A := stepSampleMap (interpolationSlope (m+1) δ) s
  have hinj : Function.Injective A := by
    apply LinearMap.ker_eq_bot.mp
    apply LinearMap.ker_eq_bot'.mpr
    intro t ht
    have h := stepSampleMap_error hδ s hs hsep t
    change ‖A t-t‖ ≤ (1/8 : ℝ)*‖t‖ at h
    rw [ht,zero_sub,norm_neg] at h
    apply norm_eq_zero.mp
    linarith [norm_nonneg t]
  obtain ⟨t,ht⟩ := LinearMap.surjective_of_injective hinj y
  have h := stepSampleMap_error hδ s hs hsep t
  change ‖A t-t‖ ≤ (1/8 : ℝ)*‖t‖ at h
  rw [ht] at h
  have htri := norm_sub_le y (y-t)
  have hid : y-(y-t)=t := by abel
  rw [hid] at htri
  refine ⟨t,by linarith,?_⟩
  intro i
  have hi := congrFun ht i
  simpa only [A,stepSampleMap_apply] using hi

theorem exists_bounded_step_interpolator {m : ℕ} {δ : ℝ} (hδ : 0 < δ)
    (s : Fin (m+1) → ℝ) (hs : Monotone s)
    (hsep : ∀ j : Fin m, δ ≤ s j.succ-s j.castSucc) (y : Fin (m+1) → ℝ)
    (hy : ∀ i, |y i| ≤ 7/8) :
    ∃ t : Fin (m+1) → ℝ, (∀ i, |t i| ≤ 1) ∧
      (∀ i, stepCombination (thresholdProfile (interpolationSlope (m+1) δ)
        (sampleCenters s) (s i)) t = y i) ∧
      (∀ x : ℝ, |stepCombination (thresholdProfile (interpolationSlope (m+1) δ)
        (sampleCenters s) x) t| ≤ 1) := by
  obtain ⟨t,ht,hinterp⟩ := exists_step_coefficients hδ s hs hsep y
  have hyn : ‖y‖ ≤ 7/8 := (pi_norm_le_iff_of_nonneg (by norm_num)).mpr (by
    intro i; simpa only [Real.norm_eq_abs] using hy i)
  have hbound (i : Fin (m+1)) : |t i| ≤ 1 := by
    have hi : |t i| ≤ ‖t‖ := by simpa only [Real.norm_eq_abs] using norm_le_pi_norm t i
    linarith
  refine ⟨t,hbound,hinterp,?_⟩
  intro x
  exact tanh_stepCombination_bound (interpolationSlope_pos (Nat.succ_pos m) hδ).le
    _ (sampleCenters_monotone s hs) t hbound x

end NeuralGeneralization.BatchTwoContinuousDepthPaper
