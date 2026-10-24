import NeuralGeneralization.BatchTwoMergingSharpGeometry
import NeuralGeneralization.BatchTwoMergingGaussian
import NeuralGeneralization.RobustTargetProbability

/-! Exact logarithmic cylinder cost used in the ReLU/GELU paper. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d N r : ℕ}

def sharpCylinderCost (d r : ℕ) (K G ρ : ℝ) : ℝ :=
  K + ((d : ℝ) + 2 + (r : ℝ) * G) *
    Real.log (Real.exp 1 * Real.sqrt (2 * Real.pi) / (2 * ρ)) + Real.log 2

theorem sharpCoordinateCylinder_mass
    (hd : 0 < d) (hN : 0 < N) (v : Weights d N r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) {K G ρ σ : ℝ}
    (hρ : 0 < ρ) (hρ16 : ρ ≤ 1 / 16) (hσ : 0 < σ)
    (hscale : (N : ℝ) * σ ^ 2 ≤ 1)
    (hJ : (J.card : ℝ) ≤ G) (hcost : weightedSquaredNorm v ≤ K) :
    Real.exp (-sharpCylinderCost d r K G ρ / σ ^ 2) ≤
      (smallPrior d N r σ).real (sharpCoordinateCylinder v b J ρ σ) := by
  classical
  let a : {q : WeightIndex d N r // constrainedIndex J q} → ℝ :=
    fun q => rotateInternalRows b.repr (whiten v) q.val
  have hfree := sharpFreeCoordinateEvent_real_ge_half (d := d) (r := r) hN J hσ hscale
  have hm := smallPrior_selected_cylinder_log_lower hd hN hσ hρ
    (internalRowIsometry b.repr) (constrainedIndex J) a
    (sharpFreeCoordinateEvent J (sharpBulkBound r)) hfree
  have he : (∑ q, a q ^ 2) ≤ K :=
    (selected_rotated_center_energy_le hd hN b.repr (constrainedIndex J) v).trans hcost
  have hdim : (Fintype.card {q : WeightIndex d N r // constrainedIndex J q} : ℝ) ≤
      (N : ℝ) * ((d : ℝ) + 2 + (r : ℝ) * G) := by
    rw [card_constrainedIndex]
    push_cast
    apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg N)
    linarith [mul_le_mul_of_nonneg_left hJ (Nat.cast_nonneg r)]
  let q : ℝ := (d : ℝ) + 2 + (r : ℝ) * G
  let k : ℝ := Real.log (Real.exp 1 * Real.sqrt (2 * Real.pi) / (2 * ρ))
  have hroot : 0 < Real.sqrt (2 * Real.pi) := by positivity
  have hkeq : k = 1 - Real.log (2 * ρ / Real.sqrt (2 * Real.pi)) := by
    dsimp [k]
    rw [Real.log_div (mul_ne_zero (Real.exp_ne_zero _) hroot.ne') (by positivity),
      Real.log_mul (Real.exp_ne_zero _) hroot.ne', Real.log_exp,
      Real.log_div (by positivity) hroot.ne']
    ring
  have hroot1 : 1 ≤ Real.sqrt (2 * Real.pi) := by
    have hs := Real.sq_sqrt (by positivity : 0 ≤ 2 * Real.pi)
    nlinarith only [hs, Real.pi_gt_three, hroot]
  have hc : 2 * ρ / Real.sqrt (2 * Real.pi) ≤ 1 := by
    apply (div_le_iff₀ hroot).mpr
    nlinarith only [hρ16, hroot1]
  have hlog : Real.log (2 * ρ / Real.sqrt (2 * Real.pi)) ≤ 0 :=
    Real.log_nonpos (by positivity) hc
  have hk : 0 ≤ k := by rw [hkeq]; linarith only [hlog]
  have hkbox : ρ ^ 2 - Real.log (2 * ρ / Real.sqrt (2 * Real.pi)) ≤ k := by
    rw [hkeq]
    nlinarith only [hρ, hρ16]
  have hG : 0 ≤ G := (Nat.cast_nonneg _).trans hJ
  have hq : 0 ≤ q := by dsimp [q]; positivity
  have hσ2 : 0 < σ ^ 2 := sq_pos_of_pos hσ
  have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hs1 : σ ^ 2 ≤ 1 := by nlinarith only [hN1, hscale, hσ2]
  have hdimσ : (Fintype.card {i : WeightIndex d N r // constrainedIndex J i} : ℝ) * σ ^ 2 ≤ q := by
    calc
      _ ≤ ((N : ℝ) * q) * σ ^ 2 := mul_le_mul_of_nonneg_right hdim hσ2.le
      _ = q * ((N : ℝ) * σ ^ 2) := by ring
      _ ≤ q * 1 := mul_le_mul_of_nonneg_left hscale hq
      _ = q := mul_one _
  have hlog2 : 0 ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  have htotal : (∑ i, a i ^ 2) +
      (Fintype.card {i : WeightIndex d N r // constrainedIndex J i} : ℝ) * k * σ ^ 2 +
        σ ^ 2 * Real.log 2 ≤ sharpCylinderCost d r K G ρ := by
    change _ ≤ K + q * k + Real.log 2
    have hh := mul_le_mul_of_nonneg_right hdimσ hk
    have hh2 := mul_le_mul_of_nonneg_right hs1 hlog2
    nlinarith only [he, hh, hh2]
  have hexp : -sharpCylinderCost d r K G ρ / σ ^ 2 ≤
      -(∑ i, a i ^ 2) / σ ^ 2 -
      (Fintype.card {i : WeightIndex d N r // constrainedIndex J i} : ℝ) * k - Real.log 2 := by
    apply (div_le_iff₀ hσ2).mpr
    simp only [neg_div]
    have hh : (∑ i, a i ^ 2) / σ ^ 2 * σ ^ 2 = ∑ i, a i ^ 2 :=
      div_mul_cancel₀ _ hσ2.ne'
    nlinarith only [htotal, hh]
  calc
    _ ≤ Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 -
        (Fintype.card {i : WeightIndex d N r // constrainedIndex J i} : ℝ) * k - Real.log 2) :=
      Real.exp_le_exp.mpr hexp
    _ = (1 / 2) * Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 -
        (Fintype.card {i : WeightIndex d N r // constrainedIndex J i} : ℝ) * k) := by
      rw [show -(∑ i, a i ^ 2) / σ ^ 2 -
        (Fintype.card {i : WeightIndex d N r // constrainedIndex J i} : ℝ) * k - Real.log 2 =
          -Real.log 2 + (-(∑ i, a i ^ 2) / σ ^ 2 -
            (Fintype.card {i : WeightIndex d N r // constrainedIndex J i} : ℝ) * k) by ring,
        Real.exp_add, Real.exp_neg, Real.exp_log (by norm_num)]
      norm_num
    _ ≤ (1 / 2) * Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 -
        (Fintype.card {i : WeightIndex d N r // constrainedIndex J i} : ℝ) *
          (ρ ^ 2 - Real.log (2 * ρ / Real.sqrt (2 * Real.pi)))) := by
      apply mul_le_mul_of_nonneg_left _ (by norm_num)
      apply Real.exp_le_exp.mpr
      have hh := mul_le_mul_of_nonneg_left hkbox
        (Nat.cast_nonneg (Fintype.card {i : WeightIndex d N r // constrainedIndex J i}) :
          (0 : ℝ) ≤ Fintype.card {i : WeightIndex d N r // constrainedIndex J i})
      linarith only [hh]
    _ ≤ _ := hm

end NeuralGeneralization.BatchTwoMerging
