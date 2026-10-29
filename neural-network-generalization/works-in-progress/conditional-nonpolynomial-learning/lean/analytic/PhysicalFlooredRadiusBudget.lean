import PhysicalFlooredRadii

noncomputable section
set_option maxHeartbeats 2200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}

lemma physicalFlooredRadius_inverse (P : ControlledMarginPath d H t f)
    (states : ℕ→CanonicalProgramState d) (j : ℕ) :
    (physicalFlooredRadius P states j)⁻¹≤((H:ℝ)+1)*(physicalPartialGainBound P+1) := by
  have hh := one_div_le_one_div_of_le (physicalRadiusFloor_pos P) (physicalFlooredRadius_floor P states j)
  simpa only [one_div,physicalRadiusFloor,inv_inv] using hh

/-- The complete normalized residual-radius budget, with an explicit at-most
one charge for flooring. Every term is bounded by original path quantities. -/
theorem physical_floored_prefix_budget (P : ControlledMarginPath d H t f)
    (S : Finset (Cube d)) (states : ℕ→CanonicalProgramState d)
    (hJ : J≤H) {ε : ℝ} (hε : 0≤ε)
    (hquery : ∀j<J,∀x,QueryFeatureClose (P.feature j) (states j).feature S x ε) :
    (∑j∈Finset.range J,((t*physicalGainProduct P j*physicalFlooredRadius P states j)^2+
      Real.sqrt (physicalLayerCost P j)))≤
      2*(∑j∈Finset.range J,physicalMaxVariance P j)+2*(J:ℝ)*ε^2+1+
        Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,physicalLayerCost P j)) := by
  have hpoint (j : ℕ) (hj : j∈Finset.range J) :
      (t*physicalGainProduct P j*physicalFlooredRadius P states j)^2≤
        2*physicalMaxVariance P j+2*ε^2+
          (physicalRadiusFloor P)^2*(physicalPartialGainBound P)^2 := by
    have hphys := physicalFlooredRadius_physical_square P states j (by have:=Finset.mem_range.mp hj;omega)
    have hv := queryFeatureClose_variance (P.feature j) (states j).feature S hε
      (hquery j (Finset.mem_range.mp hj))
    change _≤2*maxFeatureVariance (P.feature j)+2*ε^2+_
    linarith
  have hs := Finset.sum_le_sum hpoint
  simp only [Finset.sum_add_distrib,←Finset.mul_sum,Finset.sum_const,Finset.card_range,nsmul_eq_mul] at hs
  have hfloor := physicalRadiusFloor_total P
  have hJh : (J:ℝ)≤H := by exact_mod_cast hJ
  have hJfloor := mul_le_mul_of_nonneg_right hJh
    (mul_nonneg (sq_nonneg (physicalRadiusFloor P)) (sq_nonneg (physicalPartialGainBound P)))
  have hsqrt := Real.le_sqrt_of_sq_le (sum_sqrt_sq_le J (physicalLayerCost P)
    (fun j hj=>ENNReal.toReal_nonneg))
  rw [Finset.sum_add_distrib]
  nlinarith only [hs,hfloor,hJfloor,hsqrt]

#print axioms physical_floored_prefix_budget
#print axioms physicalFlooredRadius_inverse
end ConditionalNonpolynomial.Analytic
