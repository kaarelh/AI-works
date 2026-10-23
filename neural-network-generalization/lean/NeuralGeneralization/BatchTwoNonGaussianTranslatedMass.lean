import NeuralGeneralization.BatchTwoNonGaussianNoiseGeometry
import NeuralGeneralization.GaussianModelRate

/-! Symmetric-cylinder translation for the actual anisotropic non-Gaussian
network law, including the exact weighted energy and a target-margin bound. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel

theorem smallScale_pos {d N r : ℕ} (hd : 0 < d) (hN : 0 < N) {σ : ℝ} (hσ : 0 < σ)
    (i : WeightIndex d N r) : 0 < smallScale d N r σ i := by
  rcases i with ij | (sij | j)
  · exact mul_pos hσ (Real.sqrt_pos.mpr (div_pos (Nat.cast_pos.mpr hN) (Nat.cast_pos.mpr hd)))
  · exact hσ
  · exact div_pos hσ (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN))

theorem standardized_energy {d N r : ℕ} (hd : 0 < d) (hN : 0 < N) {σ : ℝ} (hσ : 0 < σ)
    (v : Weights d N r) :
    (∑ q, (v q/smallScale d N r σ q)^2)=weightedSquaredNorm v/σ^2 := by
  rw [weightedSquaredNorm_eq_coordinateSum, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro q _
  have hc := precision_mul_scale_sq (r := r) hd hN q
  rw [coordinateScale_sq hd hN] at hc
  have hs := smallScale_sq (r := r) hd hN σ q
  rw [smallVariance_eq_base_mul] at hs
  have hbase : smallVariance d N r 1 q ≠ 0 := (smallVariance_pos hd hN (by norm_num) q).ne'
  have hp : coordinatePrecision d N r q = 1/smallVariance d N r 1 q :=
    (eq_div_iff hbase).mpr hc
  rw [div_pow, hs, hp]
  ring

theorem smallPrior_translated_event_mass (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) {σ : ℝ} (hσ : 0 < σ)
    (E T : Set (Weights d N r)) (hE : MeasurableSet E)
    (hsym : ∀ z, -z ∈ E ↔ z ∈ E) (hT : MeasurableSet T)
    (v : Weights d N r) (hsub : ∀ z ∈ E, translatedNoise v σ z ∈ T) :
    (rawPrior ν d N r).real E *
      Real.exp (-(ν.upperCurvature/2*weightedSquaredNorm v/σ^2)) ≤
        (smallPrior ν d N r σ).real T := by
  let a : Weights d N r := fun q => v q/smallScale d N r σ q
  have ht := ν.symmetric_event_translation E hE hsym a
  have he := standardized_energy hd hN hσ v
  change (∑ q, a q^2)=weightedSquaredNorm v/σ^2 at he
  rw [he] at ht
  have hpre : {u : Weights d N r | u-a ∈ E} ⊆
      (fun u q => smallScale d N r σ q*u q) ⁻¹' T := by
    intro u hu
    have hv := hsub (u-a) hu
    have heq : translatedNoise v σ (u-a) = fun q => smallScale d N r σ q*u q := by
      funext q
      dsimp [translatedNoise,a]
      field_simp [(smallScale_pos hd hN hσ q).ne']
      <;> ring
    rw [heq] at hv
    exact hv
  have hm := measureReal_mono (μ := rawPrior ν d N r) hpre
  have hmap : (smallPrior ν d N r σ).real T =
      (rawPrior ν d N r).real ((fun u q => smallScale d N r σ q*u q) ⁻¹' T) := by
    rw [smallPrior, productPrior_eq_map, Measure.real, Measure.map_apply (by fun_prop) hT]
    rfl
  rw [hmap]
  have hmass := ht.trans hm
  simpa only [rawPrior, mul_div_assoc] using hmass

/-- An explicit lower bound using the actual group-cylinder probability.
All small-ball and operator estimates can now be applied without changing the
network prior or importing a conditional-concentration hypothesis. -/
theorem smallPrior_cloned_cylinder_mass (ν : CoordinateLaw) {d C k p N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (teacher : Weights d C r)
    (f : BooleanFunction d) {K b σ : ℝ} (hK : 0 ≤ K) (hb : 0 ≤ b) (hσ : 0 < σ)
    (hscale : (N : ℝ)*σ^2 ≤ 1) (hv : weightedSquaredNorm (clonedWeights e teacher) ≤ K)
    (hmargin : clonedWeights e teacher ∈ marginEvent Real.tanh (3/2) f) :
    let ρ := cylinderRadius d r K C (2*(b+C+1))
    (ν.law.real (Icc (-ρ) ρ))^(N*(d+2))*
      ((Measure.pi fun _ : Fin N × Fin N => ν.law).real (matrixNoiseCylinder e ρ b))^r *
        Real.exp (-(ν.upperCurvature/2*K/σ^2)) ≤
          functionMass Real.tanh (1/2) (smallPrior ν d N r σ) f := by
  let ρ := cylinderRadius d r K C (2*(b+C+1))
  have ht := smallPrior_translated_event_mass ν hd hN hσ
    (noiseCylinder d e ρ b r) (marginEvent Real.tanh (1/2) f)
    (measurable_noiseCylinder d e ρ b r) (noiseCylinder_neg d e ρ b r)
    (isOpen_marginEvent (by fun_prop : Continuous Real.tanh) (1/2) f).measurableSet
    (clonedWeights e teacher) (fun z hz =>
      cylinder_margin_transfer Real.tanh f _ _ hmargin
        (noiseCylinder_output_error hd hN hk e teacher hK hb hσ.le hscale hv z hz))
  rw [noiseCylinder_probability] at ht
  apply le_trans _ ht
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  apply Real.exp_le_exp.mpr
  exact neg_le_neg (div_le_div_of_nonneg_right
    (mul_le_mul_of_nonneg_left hv (div_nonneg ν.upperCurvature_pos.le (by norm_num))) (sq_nonneg σ))

end NeuralGeneralization.BatchTwoNonGaussian
