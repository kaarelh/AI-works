import NeuralGeneralization.BatchTwoContinuousDepthCriticalTeacherBounds

/-! Quantitative geometry for the paper's depth-dependent smooth jitter.
A sharper bound on the original Cantor coding preserves the existing
memorizer's label range after adding the stated jitter. -/
noncomputable section
open Set
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

/-- The upper inverse-branch endpoint can be improved from .65 to .64. -/
theorem expandingMap_sharp_endpoint : expandingMap (16/25) < (-3/4 : ℝ) := by
  have h1 : (27/10 : ℝ) ≤ Real.exp 1 := by linarith [Real.exp_one_gt_d9]
  have h2 : (6/5 : ℝ) ≤ Real.exp (1/5) := by linarith [Real.add_one_le_exp (1/5)]
  have hp1 := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 27/10) h1 2
  have hp2 := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 6/5) h2 4
  have hp := mul_le_mul hp1 hp2 (by positivity) (by positivity)
  have he : (Real.exp 1)^2 * (Real.exp (1/5))^4 = Real.exp (14/5) := by
    rw [← Real.exp_nat_mul, ← Real.exp_nat_mul, ← Real.exp_add]
    norm_num
  rw [he] at hp
  have hex : (15 : ℝ) < Real.exp (14/5) := by norm_num at hp; linarith
  have ht : (7/8 : ℝ) < Real.tanh (7/5) := by
    rw [tanh_double_exp, lt_div_iff₀ (by positivity)]
    norm_num only at *
    linarith
  unfold expandingMap
  norm_num only
  linarith [Real.tanh_lt_one (57/5)]

theorem positiveBranch_sharp_bound (y : BranchDomain) : positiveBranch y ≤ (16/25 : ℝ) := by
  have hex : ∃ t ∈ Icc (1/2 : ℝ) (16/25), expandingMap t = y := by
    apply intermediate_value_Icc' (by norm_num : (1/2 : ℝ) ≤ 16/25)
      continuous_expandingMap.continuousOn
    exact ⟨expandingMap_sharp_endpoint.le.trans y.property.1,
      y.property.2.trans expandingMap_left_endpoint.le⟩
  obtain ⟨t, ht, hty⟩ := hex
  have hdist := (expandingMap_branch_distance (positiveBranch_mem y)
    (show t ∈ Icc (1/2 : ℝ) (13/20) from ⟨ht.1, by linarith [ht.2]⟩)).1
  rw [expandingMap_positiveBranch, hty, sub_self, abs_zero] at hdist
  have he : positiveBranch y = t := sub_eq_zero.mp (abs_eq_zero.mp (by
    linarith [abs_nonneg (positiveBranch y - t)]))
  exact he ▸ ht.2

theorem coding_sharp_bound (ω : SignStream) : |scalarCoding ω| ≤ (16/25 : ℝ) := by
  change |(coding ω).val| ≤ _
  rw [coding_unfold]
  have hlo := (positiveBranch_mem (coding (streamShift 1 ω))).1
  have hhi := positiveBranch_sharp_bound (coding (streamShift 1 ω))
  cases h : ω 0 <;> simp only [h, branch, Bool.false_eq_true, ↓reduceIte, abs_neg] <;>
    rw [abs_of_nonneg (by linarith)] <;> exact hhi

/-- The paper's global derivative bound, including points outside the Cantor set. -/
theorem expandingDerivative_global_bound (t : ℝ) : |expandingDerivative t| ≤ 20 := by
  have hb (x : ℝ) : 0 ≤ 1/(Real.cosh x)^2 ∧ 1/(Real.cosh x)^2 ≤ 1 := by
    refine ⟨by positivity, (div_le_one (sq_pos_of_pos (Real.cosh_pos x))).mpr ?_⟩
    nlinarith [Real.one_le_cosh x]
  unfold expandingDerivative
  rw [abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 20)]
  have h := abs_le.mpr (show -(1 : ℝ) ≤ 1/(Real.cosh (10*(t+1/2)))^2 -
      1/(Real.cosh (10*(t-1/2)))^2 ∧
      1/(Real.cosh (10*(t+1/2)))^2 - 1/(Real.cosh (10*(t-1/2)))^2 ≤ 1 from
      ⟨by linarith [(hb (10*(t+1/2))).1, (hb (10*(t-1/2))).2],
       by linarith [(hb (10*(t+1/2))).2, (hb (10*(t-1/2))).1]⟩)
  linarith

theorem expandingMap_global_lipschitz : LipschitzWith 20 expandingMap := by
  apply lipschitzWith_of_nnnorm_deriv_le (fun t => (hasDerivAt_expandingMap t).differentiableAt)
  intro t
  apply NNReal.coe_le_coe.mp
  change |deriv expandingMap t| ≤ 20
  rw [(hasDerivAt_expandingMap t).deriv]
  exact expandingDerivative_global_bound t

def jitterRadius (r : ℕ) : ℝ := 1 / (100 * 20 ^ r)

theorem jitterRadius_pos (r : ℕ) : 0 < jitterRadius r := by unfold jitterRadius; positivity

theorem jitterRadius_le (r : ℕ) : jitterRadius r ≤ (1/100 : ℝ) := by
  unfold jitterRadius
  apply one_div_le_one_div_of_le (by norm_num)
  have hp : (1 : ℝ) ≤ 20 ^ r := one_le_pow₀ (by norm_num)
  linarith

abbrev Jitter (r : ℕ) := {u : ℝ // |u| ≤ jitterRadius r}

/-- The target perturbation is at most one hundredth at every depth. -/
theorem jitter_target_error (r : ℕ) (t : ℝ) (u : Jitter r) :
    |expandingMap^[r] (t + u.val) - expandingMap^[r] t| ≤ (1/100 : ℝ) := by
  have h := (expandingMap_global_lipschitz.iterate r).dist_le_mul (t + u.val) t
  simp only [Real.dist_eq, NNReal.coe_pow, NNReal.coe_ofNat, add_sub_cancel_left] at h
  calc
    _ ≤ 20 ^ r * |u.val| := h
    _ ≤ 20 ^ r * jitterRadius r := mul_le_mul_of_nonneg_left u.property (by positivity)
    _ = 1/100 := by unfold jitterRadius; field_simp

def jitteredCoding (r : ℕ) (z : SignStream × Jitter r) : RealInput 2 :=
  sphereArc (scalarCoding z.1 + z.2.val)

theorem jittered_scalar_bound (r : ℕ) (z : SignStream × Jitter r) :
    |scalarCoding z.1 + z.2.val| ≤ (13/20 : ℝ) :=
  (abs_add_le _ _).trans (by linarith [coding_sharp_bound z.1, z.2.property, jitterRadius_le r])

theorem jitteredCoding_on_sphere (r : ℕ) (z : SignStream × Jitter r) :
    ∑ i, jitteredCoding r z i ^ 2 = 1 :=
  sphereArc_on_sphere ((jittered_scalar_bound r z).trans (by norm_num))

theorem jittered_label_bound (r : ℕ) (z : SignStream × Jitter r) :
    |depthTarget r (jitteredCoding r z)| ≤ (13/20 : ℝ) := by
  have he := jitter_target_error r (scalarCoding z.1) z.2
  have hb : |expandingMap^[r] (scalarCoding z.1)| ≤ (16/25 : ℝ) := by
    change |expandingMap^[r] (coding z.1)| ≤ _
    rw [expandingMap_iterate_coding]
    exact coding_sharp_bound _
  change |expandingMap^[r] (scalarCoding z.1 + z.2.val)| ≤ _
  have ht := abs_sub_le (expandingMap^[r] (scalarCoding z.1 + z.2.val))
    (expandingMap^[r] (scalarCoding z.1)) 0
  simp only [sub_zero] at ht
  linarith

theorem jittered_pair_distance (r : ℕ) (z : SignStream × Jitter r) :
    inputDistance (jitteredCoding r z) (jitteredCoding r (flipCoordinate r z.1, z.2)) ≤
      (13/5 : ℝ) * (1/3)^r := by
  have h := sphereArc_distance ((jittered_scalar_bound r z).trans (by norm_num))
    ((jittered_scalar_bound r (flipCoordinate r z.1, z.2)).trans (by norm_num))
  have hp := scalarCoding_pair_distance r z.1
  simp only [add_sub_add_right_eq_sub] at h
  exact h.trans (by linarith)

theorem jittered_pair_target_gap (r : ℕ) (z : SignStream × Jitter r) :
    (49/50 : ℝ) ≤ |depthTarget r (jitteredCoding r z) -
      depthTarget r (jitteredCoding r (flipCoordinate r z.1, z.2))| := by
  have hg := scalarCoding_pair_target_gap r z.1
  have he₁ := jitter_target_error r (scalarCoding z.1) z.2
  have he₂ := jitter_target_error r (scalarCoding (flipCoordinate r z.1)) z.2
  change (49/50 : ℝ) ≤ |expandingMap^[r] (scalarCoding z.1 + z.2.val) -
      expandingMap^[r] (scalarCoding (flipCoordinate r z.1) + z.2.val)|
  have ht₁ := abs_sub_le (expandingMap^[r] (scalarCoding z.1))
    (expandingMap^[r] (scalarCoding z.1 + z.2.val)) (expandingMap^[r] (scalarCoding (flipCoordinate r z.1)))
  have ht₂ := abs_sub_le (expandingMap^[r] (scalarCoding z.1 + z.2.val))
    (expandingMap^[r] (scalarCoding (flipCoordinate r z.1) + z.2.val))
    (expandingMap^[r] (scalarCoding (flipCoordinate r z.1)))
  rw [abs_sub_comm (expandingMap^[r] (scalarCoding z.1))
    (expandingMap^[r] (scalarCoding z.1 + z.2.val))] at ht₁
  linarith

/-- The paper's original approximation and confidence tolerances still conflict. -/
theorem jittered_approximate_pair_incompatible {a b u v U V h : ℝ}
    (hgap : (49/50 : ℝ) ≤ |a-b|) (hchange : |U-V| ≤ 13/50)
    (hu : |u-U| ≤ h) (hv : |v-V| ≤ h) (hh : h ≤ 1/32) :
    ¬(|u-a| ≤ (1/4 : ℝ) ∧ |v-b| ≤ (1/4 : ℝ)) := by
  rintro ⟨ha, hb⟩
  have h₁ := abs_sub_le a u b
  have h₂ := abs_sub_le u v b
  have h₃ := abs_sub_le u U v
  have h₄ := abs_sub_le U V v
  rw [abs_sub_comm a u] at h₁
  rw [abs_sub_comm V v] at h₄
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthLower
