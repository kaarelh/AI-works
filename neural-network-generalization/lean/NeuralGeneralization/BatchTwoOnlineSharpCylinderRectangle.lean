import NeuralGeneralization.NetworkGaussianCylinder
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds

/-! Gaussian rectangle cost at most one reciprocal radius per constrained
coordinate, enough to retain the online appendix's exact target exponent. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel MeasureTheory ProbabilityTheory

theorem gaussian_radius_prefactor_sharp (ρ : ℝ) (hρ : 0<ρ) (hρhalf : ρ≤1/2) :
    Real.exp (ρ^2-1/ρ)≤2*ρ/Real.sqrt (2*Real.pi) := by
  have hs:0<Real.sqrt (2*Real.pi):=by positivity
  have hs3:Real.sqrt (2*Real.pi)≤3:=by
    apply (Real.sqrt_le_iff).mpr
    exact ⟨by norm_num,by linarith [Real.pi_le_four]⟩
  have hlog1:=Real.log_le_sub_one_of_pos (show 0<Real.sqrt (2*Real.pi)/2 by positivity)
  have hlog2:=Real.log_le_sub_one_of_pos (one_div_pos.mpr hρ)
  have he:Real.log (Real.sqrt (2*Real.pi)/(2*ρ))=
      Real.log (Real.sqrt (2*Real.pi)/2)+Real.log (1/ρ) := by
    rw [←Real.log_mul (by positivity) (by positivity)]
    congr 1
    field_simp
  have hlog:Real.log (Real.sqrt (2*Real.pi)/(2*ρ))≤1/ρ-ρ^2:=by
    rw [he]
    nlinarith [sq_nonneg ρ]
  have hpos:0<2*ρ/Real.sqrt (2*Real.pi):=by positivity
  rw [←Real.exp_log hpos]
  apply Real.exp_le_exp.mpr
  have hi:Real.log (2*ρ/Real.sqrt (2*Real.pi))= -Real.log (Real.sqrt (2*Real.pi)/(2*ρ)) := by
    rw [←Real.log_inv]
    congr 1
    field_simp
  rw [hi]
  linarith

theorem gaussian_rectangle_exp_sharp {ι : Type*} [Fintype ι]
    (a : ι→ℝ) (ρ σ : ℝ) (hρ : 0<ρ) (hρhalf : ρ≤1/2) (hσ : 0<σ) :
    Real.exp (-(∑i,a i^2)/σ^2-(Fintype.card ι:ℝ)/ρ)≤
    (Measure.pi fun _ : ι=>gaussianReal 0 (σ^2).toNNReal).real
      (Set.pi Set.univ fun i=>Set.Icc (a i-ρ*σ) (a i+ρ*σ)) := by
  have hp:=pow_le_pow_left₀ (Real.exp_nonneg _) (gaussian_radius_prefactor_sharp ρ hρ hρhalf)
    (Fintype.card ι)
  apply le_trans _ (GaussianTail.gaussian_scaled_rectangle_mass_lower a ρ σ hρ.le hσ)
  calc
    _ = Real.exp (ρ^2-1/ρ)^Fintype.card ι*
        Real.exp (-(∑i,a i^2)/σ^2-(Fintype.card ι:ℝ)*ρ^2) := by
      rw [←Real.exp_nat_mul,←Real.exp_add]
      congr 1
      ring
    _ ≤ _:=mul_le_mul_of_nonneg_right hp (Real.exp_nonneg _)

theorem smallPrior_selected_cylinder_sharp {d N r : ℕ}
    (hd : 0<d) (hN : 0<N) {σ ρ : ℝ} (hσ : 0<σ) (hρ : 0<ρ) (hρhalf : ρ≤1/2)
    (f : EuclideanSpace ℝ (WeightIndex d N r)≃ₗᵢ[ℝ]EuclideanSpace ℝ (WeightIndex d N r))
    (p : WeightIndex d N r→Prop) [DecidablePred p]
    (a : {i//p i}→ℝ) (B : Set ({i//¬p i}→ℝ))
    (hB : (1:ℝ)/2≤(Measure.pi fun _ : {i//¬p i}=>gaussianReal 0 (σ^2).toNNReal).real B) :
    (1/2)*Real.exp (-(∑i,a i^2)/σ^2-(Fintype.card {i//p i}:ℝ)/ρ)≤
      (smallPrior d N r σ).real
        (orthogonalWhiten f ⁻¹'
          ((MeasurableEquiv.piEquivPiSubtypeProd (fun _ : WeightIndex d N r=>ℝ) p) ⁻¹'
            ((Set.pi Set.univ fun i=>Set.Icc (a i-ρ*σ) (a i+ρ*σ))×ˢB))) := by
  unfold Measure.real
  rw [smallPrior_orthogonal_event_measure hd hN hσ,
    GaussianTail.gaussian_split_cylinder_measure,ENNReal.toReal_mul]
  have hh:=gaussian_rectangle_exp_sharp a ρ σ hρ hρhalf hσ
  exact (mul_le_mul hB hh (Real.exp_nonneg _) measureReal_nonneg).trans_eq (mul_comm _ _)

end NeuralGeneralization.BatchTwoOnlineSharp
