import NeuralGeneralization.NetworkGaussianCylinder
import NeuralGeneralization.GaussianReadout
import NeuralGeneralization.GaussianApproximationTail

/-!
# Gaussian tools with logarithmic small-ball cost

The logarithm in this file is essential: the target cylinder radius may be
exponentially small in depth, but its negative log mass remains polynomial
in depth.  Replacing this cost by an inverse radius would lose that result.
-/

noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal

namespace NeuralGeneralization.BatchTwoMerging

open ConcreteModel

theorem gaussian_scaled_rectangle_log_lower {ι : Type*} [Fintype ι]
    (a : ι → ℝ) (ρ σ : ℝ) (hρ : 0 < ρ) (hσ : 0 < σ) :
    Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 -
      (Fintype.card ι : ℝ) * (ρ ^ 2 - Real.log (2 * ρ / Real.sqrt (2 * Real.pi)))) ≤
    (Measure.pi fun _ : ι => gaussianReal 0 (σ ^ 2).toNNReal).real
      (Set.pi Set.univ fun i => Set.Icc (a i - ρ * σ) (a i + ρ * σ)) := by
  have hp : 0 < 2 * ρ / Real.sqrt (2 * Real.pi) := by positivity
  have heq : Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 -
      (Fintype.card ι : ℝ) * (ρ ^ 2 - Real.log (2 * ρ / Real.sqrt (2 * Real.pi)))) =
      (2 * ρ / Real.sqrt (2 * Real.pi)) ^ Fintype.card ι *
        Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 - (Fintype.card ι : ℝ) * ρ ^ 2) := by
    rw [show -(∑ i, a i ^ 2) / σ ^ 2 -
        (Fintype.card ι : ℝ) * (ρ ^ 2 - Real.log (2 * ρ / Real.sqrt (2 * Real.pi))) =
      (Fintype.card ι : ℝ) * Real.log (2 * ρ / Real.sqrt (2 * Real.pi)) +
        (-(∑ i, a i ^ 2) / σ ^ 2 - (Fintype.card ι : ℝ) * ρ ^ 2) by ring]
    rw [Real.exp_add, Real.exp_nat_mul, Real.exp_log hp]
  rw [heq]
  exact GaussianTail.gaussian_scaled_rectangle_mass_lower a ρ σ hρ.le hσ

theorem smallPrior_selected_cylinder_log_lower {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) {σ ρ : ℝ} (hσ : 0 < σ) (hρ : 0 < ρ)
    (f : EuclideanSpace ℝ (WeightIndex d N r) ≃ₗᵢ[ℝ]
      EuclideanSpace ℝ (WeightIndex d N r))
    (p : WeightIndex d N r → Prop) [DecidablePred p]
    (a : {i // p i} → ℝ) (B : Set ({i // ¬p i} → ℝ))
    (hB : (1 : ℝ) / 2 ≤
      (Measure.pi fun _ : {i // ¬p i} => gaussianReal 0 (σ ^ 2).toNNReal).real B) :
    (1 / 2) * Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 -
        (Fintype.card {i // p i} : ℝ) *
          (ρ ^ 2 - Real.log (2 * ρ / Real.sqrt (2 * Real.pi)))) ≤
      (smallPrior d N r σ).real
        (orthogonalWhiten f ⁻¹'
          ((MeasurableEquiv.piEquivPiSubtypeProd (fun _ : WeightIndex d N r => ℝ) p) ⁻¹'
            ((Set.pi Set.univ fun i => Set.Icc (a i - ρ * σ) (a i + ρ * σ)) ×ˢ B))) := by
  unfold Measure.real
  rw [smallPrior_orthogonal_event_measure hd hN hσ,
    GaussianTail.gaussian_split_cylinder_measure, ENNReal.toReal_mul]
  have hbox := gaussian_scaled_rectangle_log_lower a ρ σ hρ hσ
  exact (mul_le_mul hB hbox (Real.exp_nonneg _) measureReal_nonneg).trans_eq (mul_comm _ _)

/-- Linear measurements with orthonormal coefficient rows have exactly the
independent product Gaussian law; this is not merely a covariance estimate. -/
theorem productGaussian_map_orthonormal_rows {I J : Type*} [Fintype I] [Fintype J] [DecidableEq I]
    (A : I → J → ℝ) (hA : ∀ i k, (∑ j, A i j * A k j) = if i = k then 1 else 0)
    (v : ℝ≥0) :
    (Measure.pi fun _ : J => gaussianReal 0 v).map (fun z i => ∑ j, A i j * z j) =
      Measure.pi (fun _ : I => gaussianReal 0 v) := by
  classical
  let B : I → I → ℝ := fun i k => if i = k then 1 else 0
  have hB (i k : I) : GaussianReadout.gram B i k = if i = k then 1 else 0 := by
    simp [GaussianReadout.gram, B, eq_comm]
  have hlaw := GaussianReadout.law_eq_of_gram_eq (fun j i => A i j) B v v
    (fun i k => by rw [hB]; simp only [GaussianReadout.gram, hA])
  apply (MeasurableEquiv.toLp 2 (I → ℝ)).map_measurableEquiv_injective
  change ((Measure.pi fun _ : J => gaussianReal 0 v).map
    (fun z i => ∑ j, A i j * z j)).map (toLp 2) =
      (Measure.pi fun _ : I => gaussianReal 0 v).map (toLp 2)
  rw [Measure.map_map (WithLp.measurable_toLp 2 (I → ℝ)) (by fun_prop)]
  have hleft : (toLp 2) ∘ (fun z i => ∑ j, A i j * z j) =
      GaussianReadout.readout (fun j i => A i j) := by
    funext z
    apply congrArg (toLp 2)
    funext i
    simp only [GaussianReadout.readout, mul_comm]
  rw [hleft, hlaw]
  have hright : GaussianReadout.readout B = (toLp 2 : (I → ℝ) → EuclideanSpace ℝ I) := by
    funext z
    apply congrArg (toLp 2)
    funext i
    simp [GaussianReadout.readout, B]
  rw [hright]

theorem orthonormal_rows_squaredNorm_tail {I J : Type*} [Fintype I] [Fintype J] [DecidableEq I]
    (A : I → J → ℝ) (hA : ∀ i k, (∑ j, A i j * A k j) = if i = k then 1 else 0)
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) (B : ℝ)
    (hB : 8 * (Fintype.card I : ℝ) * (v : ℝ) ≤ B) :
    (Measure.pi fun _ : J => gaussianReal 0 v).real
      {z | B ≤ ∑ i, (∑ j, A i j * z j) ^ 2} ≤ Real.exp (-B / (4 * (v : ℝ))) := by
  have h := gaussian_squaredNorm_upper_tail (ι := I) v hv B hB
  rw [← productGaussian_map_orthonormal_rows A hA v] at h
  rw [Measure.real, Measure.map_apply (by fun_prop)
    (measurableSet_le measurable_const (by fun_prop))] at h
  exact h

/-- The exact dimension prefactor needed before unioning over partitions. -/
theorem gaussian_squaredNorm_log_chernoff {I : Type*} [Fintype I]
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) (J : ℝ) :
    (Measure.pi fun _ : I => gaussianReal 0 v).real
      {z | J ≤ ∑ i, z i ^ 2} ≤
        Real.exp ((Fintype.card I : ℝ) / 2 * Real.log 2 - J / (4 * (v : ℝ))) := by
  have h := GaussianTail.gaussian_squaredNorm_rate_upper (ι := I) v hv J (1 / 2)
    (by norm_num) (by norm_num)
  have hs : (Real.sqrt (1 / 2 : ℝ))⁻¹ = Real.exp (Real.log 2 / 2) := by
    rw [← Real.exp_log (by positivity : 0 < (Real.sqrt (1 / 2 : ℝ))⁻¹),
      Real.log_inv, Real.log_sqrt (by norm_num), Real.log_div (by norm_num) (by norm_num),
      Real.log_one]
    congr 1
    ring
  rw [hs, ← Real.exp_nat_mul, ← Real.exp_add] at h
  convert h using 1 <;> congr 1 <;> ring

end NeuralGeneralization.BatchTwoMerging
