import PhysicalLongPrefixCover
import PhysicalFlooredRadiusBudget

noncomputable section
set_option maxHeartbeats 2200000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel PhysicalLong

def longPrefixPicardCoefficient (C K : ℝ) : ℝ :=
  9+K+C+2*physicalPrefixOccupationConstant*(1+Real.sqrt (2*C)*Real.sqrt K)

variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

 theorem physical_long_picard_budget
    (P : ControlledMarginPath d H t f) (hd : 1≤d)
    (S : Finset (Cube d)) (states : ℕ→CanonicalProgramState d)
    {J : ℕ} (hJ1 : 1≤J) (hJ : J≤H)
    (hquery : ∀j<J,∀x,QueryFeatureClose (P.feature j) (states j).feature S x (longCompressionPrecision P))
    {K T C : ℝ} (hK : 1≤K) (hT : 1≤T) (hC : 0≤C)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1)
    (hupper : (J:ℝ)≤(K+1)*T/((physicalVariance P:ℝ)⁻¹-1))
    (hadj : (∑j∈Finset.range J,physicalAdjustedCost P j)≤C*((physicalVariance P:ℝ)⁻¹-1)*T)
    (hlog : Real.log ((J:ℝ)+2)≤T) :
    (∑j∈Finset.range J,((t*physicalGainProduct P j*physicalFlooredRadius P states j)^2+
      Real.sqrt (physicalLayerCost P j)))≤longPrefixPicardCoefficient C K*T := by
  have hT0 : 0≤T := by linarith
  have hcost : 0≤∑j∈Finset.range J,physicalAdjustedCost P j :=
    Finset.sum_nonneg (fun j hj=>(controlledMarginPath_adjusted_step P j (by have:=Finset.mem_range.mp hj;omega)).1)
  have hraw := prefix_raw_cost_bound (Nat.cast_nonneg J) hK hT0 ha hC hupper hadj
    (subcriticalCostBaseline_quarter (physicalVariance_ne_zero P) (physicalVariance_le_one P))
    (physical_prefix_cost_le_adjusted P hd hJ1 hJ)
  have hsD := prefix_entropy_sqrt_bound (Nat.cast_nonneg J) hK hT0 ha hC
    (Finset.sum_nonneg (fun j hj=>ENNReal.toReal_nonneg)) hupper hraw
  change Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,physicalLayerCost P j))≤(K+C+2)*T at hsD
  have hsE := prefix_forcing_sqrt_bound (Nat.cast_nonneg J) hK hT0 ha hC hcost hupper hadj
  have hocc := physical_prefix_variance_occupation P hd hJ
  have hCocc := physicalPrefixOccupationConstant_pos
  have hq : (∑j∈Finset.range J,physicalMaxVariance P j)≤
      2+physicalPrefixOccupationConstant*(1+Real.sqrt (2*C)*Real.sqrt K)*T := by
    have hm := mul_le_mul_of_nonneg_left (add_le_add hlog hsE) hCocc.le
    nlinarith only [hocc,hm]
  have hh := physical_floored_prefix_budget P S states hJ (longCompressionPrecision_pos P).le hquery
  have hsq := longCompressionPrecision_prefix_square P hJ
  unfold longPrefixPicardCoefficient
  nlinarith only [hh,hsq,hq,hsD,hT]

 theorem physical_long_picard_subprefix_budget
    (P : ControlledMarginPath d H t f) (hd : 1≤d)
    (S : Finset (Cube d)) (states : ℕ→CanonicalProgramState d)
    {J J₀ : ℕ} (hJ1 : 1≤J) (hJ : J≤H) (hJ₀ : J₀≤J)
    (hquery : ∀j<J,∀x,QueryFeatureClose (P.feature j) (states j).feature S x (longCompressionPrecision P))
    {K T C : ℝ} (hK : 1≤K) (hT : 1≤T) (hC : 0≤C)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1)
    (hupper : (J:ℝ)≤(K+1)*T/((physicalVariance P:ℝ)⁻¹-1))
    (hadj : (∑j∈Finset.range J,physicalAdjustedCost P j)≤C*((physicalVariance P:ℝ)⁻¹-1)*T)
    (hlog : Real.log ((J:ℝ)+2)≤T) :
    (∑j∈Finset.range J₀,((t*physicalGainProduct P j*physicalFlooredRadius P states j)^2+
      Real.sqrt (physicalLayerCost P j)))≤longPrefixPicardCoefficient C K*T := by
  apply le_trans (Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_mono hJ₀) ?_)
    (physical_long_picard_budget P hd S states hJ1 hJ hquery hK hT hC ha hupper hadj hlog)
  intro j hj hj'
  positivity

#print axioms physical_long_picard_subprefix_budget
end ConditionalNonpolynomial.Analytic
