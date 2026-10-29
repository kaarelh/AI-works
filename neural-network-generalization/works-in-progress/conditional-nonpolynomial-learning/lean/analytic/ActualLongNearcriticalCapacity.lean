import LongActualActionConstants
import PhysicalLongDataResources
import UniformCapacityAssembly

/-! The actual long nearcritical path has a polynomial-size logarithmic-depth
threshold implementation. All constants are chosen before dimension, depth,
width and prior scale. -/
noncomputable section
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel PhysicalLong

 theorem actualLongNearcriticalPathCapacity : LongNearcriticalPathCapacity := by
  intro B hB
  let C := longActualAdjustedConstant B
  let G := longActualProductCoefficient B
  let u := longActualResourceExponent B
  have hC : 0≤C := by
    dsimp [C,longActualAdjustedConstant,longActualExcessConstant]
    linarith
  have hG : 0≤G := longActualProductCoefficient_nonneg hB
  have hu : 1≤u := by dsimp [u,longActualResourceExponent];omega
  obtain ⟨K,Q,hK,hQ,hQ2,hQdepth,hspan,hKC,hKs,hKr⟩ :=
    exists_long_actual_prefix_constants hB hG
  refine ⟨Q,hQ,1,longDataCircuitExponent C K u,by omega,longDataCircuitExponent_one _ _ _,?_⟩
  intro d H R hd hH hR hres hpad t ht ht1 ha ha1 hlong f P hact
  have haction : P.action≤denominatorBudget B t R H := hact
  have hap : 0<(physicalVariance P:ℝ)⁻¹-1 := by simpa only [physicalVariance_coe] using ha
  have hap1 : (physicalVariance P:ℝ)⁻¹-1≤1/4 := by simpa only [physicalVariance_coe] using ha1.le
  have hlongp : Q*Real.log (R:ℝ)≤((physicalVariance P:ℝ)⁻¹-1)*(H:ℝ) := by
    simpa only [physicalVariance_coe] using hlong
  have hlog : 0≤Real.log (R:ℝ) := Real.log_nonneg (by exact_mod_cast (show 1≤R by omega))
  have hlong2 := (mul_le_mul_of_nonneg_right hQ2 hlog).trans hlongp
  have hp := long_actual_prefix P hd hH hR hres hB hK hQ2 hQdepth hap hap1 hlongp haction
  have hr := long_actual_polynomial_resources P hd hH hR hres hB hlong2 haction
  let J := longPrefixLength K (2*Real.log (R:ℝ)) ((physicalVariance P:ℝ)⁻¹-1)
  change 1≤J ∧ J≤H ∧ K*(2*Real.log (R:ℝ))/((physicalVariance P:ℝ)⁻¹-1)≤(J:ℝ) ∧
    (J:ℝ)≤(K+1)*(2*Real.log (R:ℝ))/((physicalVariance P:ℝ)⁻¹-1) ∧
    (∑j∈Finset.range J,physicalAdjustedCost P j)≤C*((physicalVariance P:ℝ)⁻¹-1)*(2*Real.log (R:ℝ)) ∧
    Real.log ((J:ℝ)+2)≤2*Real.log (R:ℝ) at hp
  obtain ⟨D⟩ := actual_longPrefixData P hd (by omega) hp.1 hp.2.1 hap hap1
    (long_time_bounds hd hR hres).1 hK hC hG hspan hKC hKs hKr
    hp.2.2.1 hp.2.2.2.1 hp.2.2.2.2.1 hp.2.2.2.2.2 hr.2.2.2.2
  have hc := D.circuit_resources hd hR hC (by linarith : 0≤K) u hu
    hr.1 hr.2.1 hr.2.2.1 hr.2.2.2.1
  exact ⟨D.classifier,hc.1,hc.2,D.classifier_correct hd⟩

#print axioms actualLongNearcriticalPathCapacity
end ConditionalNonpolynomial.Analytic
