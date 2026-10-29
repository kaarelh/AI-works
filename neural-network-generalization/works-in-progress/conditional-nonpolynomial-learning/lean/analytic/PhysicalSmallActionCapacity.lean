import PhysicalShortThresholdCircuit
import ThresholdResourceConversion
import UniformCapacityAssembly

/-! Uniform actual threshold-circuit construction for controlled paths whose
raw action is within a logarithmic-squared-over-depth excess of the scalar
baseline. The construction is uniform in every physical scale `0 < t ≤ 1`. -/
noncomputable section
set_option maxHeartbeats 2000000
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

theorem smallActionPathCapacity : SmallActionPathCapacity := by
  intro B hB
  let p := PhysicalShort.criticalCapacitySizeExponent B
  let C := PhysicalShort.criticalCapacityDepthCoefficient B
  let K := naturalCircuitResourceExponent p C
  have hC : 0≤C := by
    dsimp [C,PhysicalShort.criticalCapacityDepthCoefficient]
    linarith [PhysicalShort.criticalIterationCoefficient_nonneg B]
  refine ⟨1,K,by norm_num,naturalCircuitResourceExponent_one p C,?_⟩
  intro d H R hd hH hR hres hpad t ht ht1 f path hnear
  have hH0 : (0:ℝ)<H := by exact_mod_cast (show 0<H by omega)
  have hR2 : (2:ℝ)≤R := by exact_mod_cast hR
  have hdR : (d:ℝ)≤R := by exact_mod_cast (show d≤R by omega)
  have hHR : (H:ℝ)≤R := by exact_mod_cast (show H≤R by omega)
  have hlog : 0≤Real.log (R:ℝ) := Real.log_nonneg (by linarith)
  let ε := B*(Real.log (R:ℝ))^2/(H:ℝ)
  have hε : 0≤ε := div_nonneg (mul_nonneg hB (sq_nonneg _)) hH0.le
  have hgap : (H:ℝ)*ε≤B*(1+Real.log (R:ℝ))^2 := by
    have he : (H:ℝ)*ε=B*(Real.log (R:ℝ))^2 := by dsimp [ε];field_simp
    rw [he]
    exact mul_le_mul_of_nonneg_left (by nlinarith only [hlog]) hB
  obtain ⟨c,hf,hs,hD⟩ := PhysicalShort.critical_path_threshold_circuit path hd hH hε hB hR2 hdR hHR hgap hnear
  obtain ⟨hsize,hdepth⟩ := natural_circuit_resource_bounds_uniform p hC hR hs hD
  exact ⟨c,hsize,hdepth,hf⟩

#print axioms smallActionPathCapacity
end ConditionalNonpolynomial.Analytic
