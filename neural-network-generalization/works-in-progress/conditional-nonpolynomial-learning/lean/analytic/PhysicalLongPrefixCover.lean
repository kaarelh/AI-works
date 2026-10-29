import PhysicalLongCoverCounting
import LongPrefixCoverResources
import PhysicalLongPrefix
import PhysicalLongPrecisionResources

/-! A literal representative cover of a genuine entropy-split path. All
block Gaussian and nonlinear charges are discharged from the actual prefix
adjusted entropy budget and query approximation. -/
noncomputable section
set_option maxHeartbeats 2500000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel PhysicalLong
attribute [local instance] Classical.propDecidable

def longPrefixNonlinearCoefficient (C:ℝ) : ℝ :=
  14+4*(physicalPrefixOccupationConstant+1)*(1+Real.sqrt (2*C))
lemma longPrefixNonlinearCoefficient_pos (C:ℝ) : 0<longPrefixNonlinearCoefficient C := by
  unfold longPrefixNonlinearCoefficient
  positivity [physicalPrefixOccupationConstant_pos]

variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
variable {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 theorem physical_long_nonlinear_budget
    (hd : 1≤d) (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    {J : ℕ} (hJ : J≤H)
    (hquery : ∀j<J,∀x,QueryFeatureClose (P.feature j) (states j).feature S x (longCompressionPrecision P))
    {K T C : ℝ} (hK : 1≤K) (hT : 1≤T) (hC : 0≤C)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1)
    (hupper : (J:ℝ)≤(K+1)*T/((physicalVariance P:ℝ)⁻¹-1))
    (hadj : (∑j∈Finset.range J,physicalAdjustedCost P j)≤C*((physicalVariance P:ℝ)⁻¹-1)*T)
    (hlog : Real.log ((J:ℝ)+2)≤T) :
    (∑j∈Finset.range J,pathNonlinearCost hstep (longCompressionPrecision P) j)≤
      longPrefixNonlinearCoefficient C*(1+Real.sqrt K)*T := by
  have hh := pathNonlinearCost_prefix hstep hd hJ (longCompressionPrecision_pos P).le hquery
  have hs := longCompressionPrecision_prefix_square P hJ
  have hcost : 0≤∑j∈Finset.range J,physicalAdjustedCost P j :=
    Finset.sum_nonneg (fun j hj=>(controlledMarginPath_adjusted_step P j (by have:=Finset.mem_range.mp hj;omega)).1)
  have hb := prefix_nonlinear_budget_bound (Nat.cast_nonneg J) hK hT ha hC hcost
    (M₀:=14) (M₁:=4*(physicalPrefixOccupationConstant+1)) (by norm_num)
    (by positivity [physicalPrefixOccupationConstant_pos]) hupper hadj hlog
  change _≤longPrefixNonlinearCoefficient C*(1+Real.sqrt K)*T at hb
  linarith

 theorem physical_long_prefix_representatives
    (hd : 1≤d)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y))
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    {J : ℕ} (hJ1 : 1≤J) (hJ : J≤H)
    (hquery : ∀j<J,∀x,QueryFeatureClose (P.feature j) (states j).feature S x (longCompressionPrecision P))
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1) (ha1 : (physicalVariance P:ℝ)⁻¹-1≤1/4)
    {K T C G : ℝ} (hT : 1≤T) (hK : 1≤K) (hC : 0≤C) (hG : 0≤G)
    (hKspan : 2*longBlockSpan≤K) (hKC : C+1≤K)
    (hKsqrt : 16*longBlockSpan*longPrefixNonlinearCoefficient C≤longCoverNonlinearThreshold*Real.sqrt K)
    (hKrad : 4*longBlockSpan*(C+G+16)≤K)
    (hcount : K*T/((physicalVariance P:ℝ)⁻¹-1)≤(J:ℝ))
    (hupper : (J:ℝ)≤(K+1)*T/((physicalVariance P:ℝ)⁻¹-1))
    (hadj : (∑j∈Finset.range J,physicalAdjustedCost P j)≤C*((physicalVariance P:ℝ)⁻¹-1)*T)
    (hlog : Real.log ((J:ℝ)+2)≤T)
    (hgain : ‖P.readout‖*physicalGainProduct P H≤Real.exp (G*T)) :
    ∃Y:Finset (Cube d),
      (Y.card:ℝ)≤Real.exp (((K+1)*Real.log ((longCoverCardFactor:ℝ)+1)/64)*T) ∧
      ∀x,∃y∈Y,
        dist ((physicalGainProduct P ((J/longPhysicalBlockLength P)*longPhysicalBlockLength P))⁻¹ •
          (states ((J/longPhysicalBlockLength P)*longPhysicalBlockLength P)).feature x)
        ((physicalGainProduct P ((J/longPhysicalBlockLength P)*longPhysicalBlockLength P))⁻¹ •
          (states ((J/longPhysicalBlockLength P)*longPhysicalBlockLength P)).feature y)
        ≤1/(64*(1+‖P.readout‖*physicalGainProduct P H)) := by
  classical
  have hraw := prefix_raw_cost_bound (Nat.cast_nonneg J) hK (by linarith : 0≤T) ha hC hupper hadj
    (subcriticalCostBaseline_quarter (physicalVariance_ne_zero P) (physicalVariance_le_one P))
    (physical_prefix_cost_le_adjusted P hd hJ1 hJ)
  have hnl := physical_long_nonlinear_budget hd hstep hJ hquery hK hT hC ha hupper hadj hlog
  have hc := physical_long_prefix_counted_cover hd hzero hstep (longCompressionPrecision_pos P) hJ ha ha1
    hT hK hC (longPrefixNonlinearCoefficient_pos C).le hKspan hKC hKsqrt hcount hraw hnl hadj
  have hsqrt : 2*Real.sqrt 2≤4 := by nlinarith [Real.sq_sqrt (show (0:ℝ)≤2 by norm_num),Real.sqrt_nonneg 2]
  have hid : C*((physicalVariance P:ℝ)⁻¹-1)*T/((physicalVariance P:ℝ)⁻¹-1)-K*T/(4*longBlockSpan)=
      (C-K/(4*longBlockSpan))*T := by
    have hh : C*((physicalVariance P:ℝ)⁻¹-1)*T/((physicalVariance P:ℝ)⁻¹-1)=C*T := by
      calc
        _ = C*T*(((physicalVariance P:ℝ)⁻¹-1)/((physicalVariance P:ℝ)⁻¹-1)) := by ring
        _ = C*T := by rw [div_self ha.ne',mul_one]
    rw [hh]
    ring
  have hsmall := longPrefix_radius_small ha hT hG
    (mul_nonneg (norm_nonneg _) (physicalGainProduct_pos P H).le) hKrad
    (E:=C*((physicalVariance P:ℝ)⁻¹-1)*T) (n:=K*T/(4*longBlockSpan)) le_rfl le_rfl hgain
    (r:=2*Real.sqrt 2*Real.exp ((C-K/(4*longBlockSpan))*T))
    (by rw [hid]; exact mul_le_mul_of_nonneg_right hsqrt (Real.exp_pos _).le)
  obtain ⟨Y,hY,hcover⟩ := hc.radius_mono hsmall
  refine ⟨Y,?_,hcover⟩
  have hYr : (Y.card:ℝ)≤(longCoverCardFactor:ℝ)^(J/longPhysicalBlockLength P) := by exact_mod_cast hY
  exact hYr.trans (longPrefix_cover_cardinality ha hupper longCoverCardFactor)

#print axioms physical_long_prefix_representatives
end ConditionalNonpolynomial.Analytic
