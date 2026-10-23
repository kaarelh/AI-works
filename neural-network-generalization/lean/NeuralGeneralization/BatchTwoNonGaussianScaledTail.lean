import NeuralGeneralization.BatchTwoNonGaussianLinearTail
import NeuralGeneralization.GaussianApproximationTail

/-! Scaled actual coordinate laws, their linear-form tails, and squared-norm
tails. The quadratic tail is proved from the density comparison, not assumed. -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoNonGaussian

def scaledCoordinates (ν : CoordinateLaw) (I : Type*) [Fintype I] (σ : ℝ) : Measure (I → ℝ) :=
  Measure.pi (fun _ : I => ν.law.map (fun x => σ * x))

instance scaledCoordinates_probability (ν : CoordinateLaw) (I : Type*) [Fintype I] (σ : ℝ) :
    IsProbabilityMeasure (scaledCoordinates ν I σ) := by
  have : IsProbabilityMeasure (ν.law.map (fun x => σ * x)) :=
    Measure.isProbabilityMeasure_map (by fun_prop)
  unfold scaledCoordinates
  infer_instance

theorem scaledCoordinates_eq_map (ν : CoordinateLaw) (I : Type*) [Fintype I] (σ : ℝ) :
    scaledCoordinates ν I σ = (Measure.pi fun _ : I => ν.law).map (fun x i => σ * x i) := by
  rw [Measure.pi_map_pi (f := fun _ : I => fun x : ℝ => σ * x) (fun _ => by fun_prop)]
  rfl

theorem scaledCoordinates_gaussian_upper (ν : CoordinateLaw) (I : Type*) [Fintype I] (σ : ℝ) :
    scaledCoordinates ν I σ ≤ ENNReal.ofReal (ν.comparisonFactor ν.lowerCurvature ^ Fintype.card I) •
      (Measure.pi fun _ : I => gaussianReal 0 (σ ^ 2 / ν.lowerCurvature).toNNReal) := by
  have hmap : (Measure.pi fun _ : I => gaussianReal 0 (1 / ν.lowerCurvature).toNNReal).map
      (fun x i => σ * x i) =
      Measure.pi (fun _ : I => gaussianReal 0 (σ ^ 2 / ν.lowerCurvature).toNNReal) := by
    rw [Measure.pi_map_pi (f := fun _ : I => fun x : ℝ => σ * x) (fun _ => by fun_prop)]
    congr 1
    funext i
    rw [gaussianReal_map_const_mul, mul_zero]
    congr 1
    apply NNReal.eq
    simp only [NNReal.coe_mul, NNReal.coe_mk,
      Real.coe_toNNReal _ (div_nonneg zero_le_one ν.lowerCurvature_pos.le),
      Real.coe_toNNReal _ (div_nonneg (sq_nonneg _) ν.lowerCurvature_pos.le)]
    ring
  have h := Measure.map_mono (ν.product_measure_gaussian_upper (I := I))
    (show Measurable (fun x : I → ℝ => fun i => σ * x i) by fun_prop)
  rw [Measure.map_smul, hmap, ← scaledCoordinates_eq_map] at h
  exact h

variable {I : Type*} [Fintype I]

theorem scaled_linear_upper_tail (ν : CoordinateLaw) (σ : ℝ) (c : I → ℝ)
    (V u : ℝ) (hV : 0 < V) (hu : 0 ≤ u)
    (hvar : (σ ^ 2 * subGaussianVariance ν) * (∑ i, c i ^ 2) ≤ V) :
    (scaledCoordinates ν I σ).real {x | u ≤ ∑ i, c i * x i} ≤
      Real.exp (-u ^ 2 / (2 * V)) := by
  rw [scaledCoordinates_eq_map, Measure.real, Measure.map_apply
    (show Measurable (fun x : I → ℝ => fun i => σ * x i) by fun_prop)
    (measurableSet_le measurable_const (by fun_prop))]
  have hvar' : subGaussianVariance ν * (∑ i, (σ * c i) ^ 2) ≤ V := by
    simpa only [mul_pow, ← Finset.mul_sum, mul_comm, mul_left_comm, mul_assoc] using hvar
  have h := actual_linear_upper_tail ν (fun i => σ * c i) V u hV hu hvar'
  simpa only [Measure.real, Set.preimage_setOf_eq, mul_comm, mul_left_comm, mul_assoc] using h

/-- Squared-norm tail with the same law-dependent sub-Gaussian variance scale.
This is sufficient for the network's input/readout and crude matrix norm events. -/
theorem scaled_squaredNorm_upper_tail (ν : CoordinateLaw) {σ : ℝ} (hσ : 0 < σ) (u : ℝ)
    (hu : 8 * (Fintype.card I : ℝ) * (σ ^ 2 * subGaussianVariance ν) ≤ u) :
    (scaledCoordinates ν I σ).real {x : I → ℝ | u ≤ ∑ i, x i ^ 2} ≤
      Real.exp (-u / (8 * (σ ^ 2 * subGaussianVariance ν))) := by
  let B := ν.comparisonFactor ν.lowerCurvature
  let v : ℝ := σ ^ 2 / ν.lowerCurvature
  have hB : 1 ≤ B := ν.one_le_comparisonFactor
  have hv : 0 < v := div_pos (sq_pos_of_pos hσ) ν.lowerCurvature_pos
  have hveq : σ ^ 2 * subGaussianVariance ν = v * B := by dsimp [v, B, subGaussianVariance]; ring
  have hu' : 8 * (Fintype.card I : ℝ) * v ≤ u := by
    rw [hveq] at hu
    have h := mul_le_mul_of_nonneg_left hB (show 0 ≤ 8 * (Fintype.card I : ℝ) * v by positivity)
    nlinarith
  have hgauss := gaussian_squaredNorm_upper_tail v.toNNReal
    (by simpa only [Real.coe_toNNReal _ hv.le] using hv) u
    (by simpa only [Real.coe_toNNReal _ hv.le] using hu')
  have hm := scaledCoordinates_gaussian_upper ν I σ {x : I → ℝ | u ≤ ∑ i, x i ^ 2}
  have htop : (ENNReal.ofReal (B ^ Fintype.card I) •
      (Measure.pi fun _ : I => gaussianReal 0 v.toNNReal)) {x | u ≤ ∑ i, x i ^ 2} ≠ ⊤ := by
    rw [Measure.smul_apply, smul_eq_mul]
    exact ENNReal.mul_ne_top ENNReal.ofReal_ne_top (measure_ne_top _ _)
  have hr := ENNReal.toReal_mono htop hm
  simp only [Measure.smul_apply, smul_eq_mul, ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (pow_nonneg (show 0 ≤ B by linarith) _)] at hr
  have hp : B ^ Fintype.card I ≤ Real.exp ((Fintype.card I : ℝ) * B) := by
    have hb : B ≤ Real.exp B := by linarith [Real.add_one_le_exp B]
    have h := pow_le_pow_left₀ (show 0 ≤ B by linarith) hb (Fintype.card I)
    simpa only [← Real.exp_nat_mul] using h
  have hs : (scaledCoordinates ν I σ).real {x : I → ℝ | u ≤ ∑ i, x i ^ 2} ≤
      Real.exp ((Fintype.card I : ℝ) * B - u / (4 * v)) := by
    apply hr.trans
    have h := mul_le_mul hp hgauss (measureReal_nonneg) (Real.exp_pos _).le
    simpa only [Real.coe_toNNReal _ hv.le, ← Real.exp_add, sub_eq_add_neg, neg_div, Measure.real] using! h
  apply hs.trans
  apply Real.exp_le_exp.mpr
  rw [hveq]
  have huB : 8 * (Fintype.card I : ℝ) * (v * B) ≤ u := by simpa only [hveq] using hu
  have hpos : 0 < 8 * (v * B) := by positivity
  apply (le_div_iff₀ hpos).mpr
  have heq : ((Fintype.card I : ℝ) * B - u / (4 * v)) * (8 * (v * B)) =
      8 * (Fintype.card I : ℝ) * v * B ^ 2 - 2 * u * B := by field_simp; ring
  rw [heq]
  have hh := mul_le_mul_of_nonneg_right huB (show 0 ≤ B by linarith)
  have hu0 : 0 ≤ u := (by positivity : 0 ≤ 8 * (Fintype.card I : ℝ) * (v * B)).trans huB
  have hh' := mul_le_mul_of_nonneg_left hB hu0
  nlinarith

end NeuralGeneralization.BatchTwoNonGaussian
