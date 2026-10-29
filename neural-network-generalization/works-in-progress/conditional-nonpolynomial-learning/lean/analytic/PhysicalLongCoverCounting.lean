import PhysicalLongBlockCover

noncomputable section
set_option maxHeartbeats 2200000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
attribute [local instance] Classical.propDecidable
open NeuralGeneralization.ConcreteModel
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
variable {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

lemma pathNonlinearCost_nonneg
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1))) (ε : ℝ) (j : ℕ) :
    0≤pathNonlinearCost hstep ε j := by
  unfold pathNonlinearCost
  positivity

 theorem physical_long_good_count
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    (ε : ℝ) {J : ℕ} (hJ : J≤H)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1) (ha1 : (physicalVariance P:ℝ)⁻¹-1≤1/4)
    {K T C A : ℝ} (hT : 1≤T) (hK : 1≤K) (hC : 0≤C) (hA : 0≤A)
    (hKspan : 2*longBlockSpan≤K) (hKC : C+1≤K)
    (hKsqrt : 16*longBlockSpan*A≤longCoverNonlinearThreshold*Real.sqrt K)
    (hcount : K*T/((physicalVariance P:ℝ)⁻¹-1)≤(J:ℝ))
    (hraw : (∑j∈Finset.range J,physicalLayerCost P j)≤
      (K/2+C+1)*((physicalVariance P:ℝ)⁻¹-1)*T)
    (hnl : (∑j∈Finset.range J,pathNonlinearCost hstep ε j)≤A*(1+Real.sqrt K)*T) :
    K*T/(4*longBlockSpan)≤
      (((Finset.range (J/longPhysicalBlockLength P)).filter (longPhysicalGoodBlock hstep ε)).card:ℝ) := by
  classical
  let b := longPhysicalBlockLength P
  let n := J/b
  have hfit : n*b≤J := Nat.div_mul_le_self J b
  have hc : K*T/(2*longBlockSpan)≤((Finset.range n).card:ℝ) := by
    simpa only [Finset.card_range,n,b,longPhysicalBlockLength] using
      longBlock_count_lower ha ha1 hKspan hT hcount
  simp only [longPhysicalGoodBlock]
  apply longBlock_half_good (Finset.range n)
    (disjointBlockCost (physicalLayerCost P) 0 b)
    (disjointBlockCost (pathNonlinearCost hstep ε) 0 b)
    ha hT hK hC hA longCoverNonlinearThreshold_pos hKC hKsqrt hc
  · intro i hi
    exact Finset.sum_nonneg (fun j hj=>ENNReal.toReal_nonneg)
  · intro i hi
    exact Finset.sum_nonneg (fun j hj=>pathNonlinearCost_nonneg hstep ε _)
  · exact (disjoint_block_sum_le_prefix (physicalLayerCost P)
      (fun j hj=>ENNReal.toReal_nonneg) hfit).trans hraw
  · exact (disjoint_block_sum_le_prefix (pathNonlinearCost hstep ε)
      (fun j hj=>pathNonlinearCost_nonneg hstep ε _) hfit).trans hnl

 theorem physical_long_prefix_counted_cover
    (hd : 1≤d)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y))
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    {ε : ℝ} (hε : 0<ε) {J : ℕ} (hJ : J≤H)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1) (ha1 : (physicalVariance P:ℝ)⁻¹-1≤1/4)
    {K T C A : ℝ} (hT : 1≤T) (hK : 1≤K) (hC : 0≤C) (hA : 0≤A)
    (hKspan : 2*longBlockSpan≤K) (hKC : C+1≤K)
    (hKsqrt : 16*longBlockSpan*A≤longCoverNonlinearThreshold*Real.sqrt K)
    (hcount : K*T/((physicalVariance P:ℝ)⁻¹-1)≤(J:ℝ))
    (hraw : (∑j∈Finset.range J,physicalLayerCost P j)≤
      (K/2+C+1)*((physicalVariance P:ℝ)⁻¹-1)*T)
    (hnl : (∑j∈Finset.range J,pathNonlinearCost hstep ε j)≤A*(1+Real.sqrt K)*T)
    (hadj : (∑j∈Finset.range J,physicalAdjustedCost P j)≤C*((physicalVariance P:ℝ)⁻¹-1)*T) :
    IndexedActualBallCover
      (fun x=>(physicalGainProduct P ((J/longPhysicalBlockLength P)*longPhysicalBlockLength P))⁻¹ •
        (states ((J/longPhysicalBlockLength P)*longPhysicalBlockLength P)).feature x)
      (longCoverCardFactor^(J/longPhysicalBlockLength P))
      (2*Real.sqrt 2*Real.exp ((C-K/(4*longBlockSpan))*T)) := by
  classical
  let b := longPhysicalBlockLength P
  let n := J/b
  have hfit : n*b≤J := Nat.div_mul_le_self J b
  have hcost : (∑j∈Finset.range (n*b),physicalAdjustedCost P j)≤
      C*((physicalVariance P:ℝ)⁻¹-1)*T := by
    apply le_trans (Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_mono hfit) ?_) hadj
    intro j hj hj'
    have hh := physicalGaussianRemainder_bounds P j (by have:=Finset.mem_range.mp hj;omega)
    exact hh.1.trans hh.2
  have hc := physical_long_block_normalized_cover hd hzero hstep hε n (hfit.trans hJ) ha ha1 hcost
  apply hc.radius_mono
  have hgood := physical_long_good_count hstep ε hJ ha ha1 hT hK hC hA hKspan hKC hKsqrt hcount hraw hnl
  apply mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr ?_) (by positivity)
  have hid : C*((physicalVariance P:ℝ)⁻¹-1)*T/((physicalVariance P:ℝ)⁻¹-1)=C*T := by
    calc
      _ = C*T*(((physicalVariance P:ℝ)⁻¹-1)/((physicalVariance P:ℝ)⁻¹-1)) := by ring
      _ = C*T := by rw [div_self ha.ne',mul_one]
  rw [hid]
  dsimp only [n,b] at *
  calc
    _ ≤ C*T-K*T/(4*longBlockSpan) := sub_le_sub_left hgood _
    _ = _ := by ring

#print axioms physical_long_prefix_counted_cover
end ConditionalNonpolynomial.Analytic
