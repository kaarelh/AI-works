import NeuralGeneralization.OnlineLowerTanhNearOptimalBulk
import NeuralGeneralization.OnlineLowerTanhSharpParity
import NeuralGeneralization.OnlineLowerTanhCostIdentification

/-! # The exact limiting supremum of scaled intrinsic tanh parity gain -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set Asymptotics
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh

lemma normalized_optimized_cost_tendsto (b:ActualGainBranch) :
    Tendsto (fun z:ℂ=>holomorphicOptimizedCost b z/z) rightDegreeInfinity
      (𝓝 (optimizedCostSlope:ℂ)) := by
  have hi:=rightDegree_inv_tendsto
  have herr:=(actualGainBranch_normalized_cost_jet b).trans_tendsto (by simpa using hi.pow 3)
  have hpoly:=((tendsto_const_nhds (x:=(optimizedQuotient0:ℂ))).add
    (hi.const_mul ((optimizedQuotient1-optimizedQuotient0/4:ℝ):ℂ))).add
    ((hi.pow 2).const_mul (normalizedOptimizedCurvature limitingGain:ℂ))
  have hq:=herr.add hpoly
  simp only [zero_pow (by decide : (2:ℕ)≠0),mul_zero,add_zero,zero_add] at hq
  have hh:=hq.const_mul (Real.sqrt (Real.pi/2):ℂ)
  simp only [←Complex.ofReal_mul] at hh
  change Tendsto _ rightDegreeInfinity (𝓝 (optimizedCostSlope:ℂ)) at hh
  apply hh.congr'
  filter_upwards [rightDegree_re_eventually] with z hz
  have hzn:z≠0 := by intro h; simpa [h] using hz
  unfold holomorphicOptimizedCost
  simp only [sub_add_cancel]
  field_simp

lemma balanced_cost_per_degree_tendsto :
    Tendsto (fun r:ℕ=>balancedCost r/(2*r+1:ℕ)) atTop (𝓝 optimizedCostSlope) := by
  apply tendsto_ofReal_iff.mp
  have h:=(normalized_optimized_cost_tendsto actualGainBranch).comp oddDegree_complex_tendsto
  apply h.congr'
  filter_upwards [oddDegree_real_tendsto.eventually (eventually_gt_atTop actualGainBranch.threshold)] with r hr
  dsimp only [Function.comp_apply]
  rw [holomorphicOptimizedCost_odd actualGainBranch r hr]
  norm_cast

lemma optimizedCostSlope_inv : optimizedCostSlope⁻¹=limitingParityEfficiency := by
  have hs:Real.sqrt (Real.pi/2)*Real.sqrt (2/Real.pi)=1 := by
    rw [←Real.sqrt_mul (by positivity)]
    field_simp
    norm_num
  have ha:=limitingGain_pos.ne'
  have hf:=scalarF0_limitingGain_pos.ne'
  have hp:(Real.sqrt (Real.pi/2))≠0 := by positivity
  unfold optimizedCostSlope optimizedQuotient0 limitingParityEfficiency
  apply (inv_eq_iff_eq_inv).mpr
  field_simp
  nlinarith [congrArg (fun x:ℝ=>x*limitingGain) hs]

lemma degree_div_balanced_cost_tendsto :
    Tendsto (fun r:ℕ=>(2*r+1:ℕ)/balancedCost r) atTop (𝓝 limitingParityEfficiency) := by
  have h:=balanced_cost_per_degree_tendsto.inv₀ optimizedCostSlope_pos.ne'
  simpa only [inv_div,optimizedCostSlope_inv] using h

/-- The supremum is over literal nonzero incoming weight vectors. -/
def scaledIntrinsicSup (r:ℕ):ℝ:=sSup {s:ℝ|∃u:Fin (2*r+1)→ℝ,u≠0 ∧ s=intrinsicEfficiency u}

lemma scaledIntrinsicSup_eventually :
    ∀ᶠr:ℕ in atTop,scaledIntrinsicSup r=(2*r+1:ℕ)/balancedCost r := by
  filter_upwards [eventual_intrinsicParityBound] with r hr
  have hbound (u:Fin (2*r+1)→ℝ) (hu:u≠0):
      intrinsicEfficiency u ≤ (2*r+1:ℕ)/balancedCost r := by
    have he:=Real.sqrt_pos.mpr (incomingEnergy_pos_of_ne_zero u hu)
    have hb:intrinsicGain u ≤ 1/balancedCost r := by
      apply (div_le_div_iff₀ he (balancedCost_pos r)).mpr
      simpa only [one_mul,mul_comm] using hr u
    have h:=mul_le_mul_of_nonneg_left hb (show (0:ℝ) ≤ (2*r+1:ℕ) by positivity)
    simpa only [intrinsicEfficiency,mul_one_div] using h
  have hbnonzero:(fun _:Fin (2*r+1)=>balancedGain r)≠0 := by
    intro h
    have hh:=congrFun h ⟨0,by omega⟩
    have hg:0<balancedGain r := lt_of_lt_of_le zero_lt_one (balancedGain_mem r).1
    simpa using hg.ne' hh
  have heq:intrinsicEfficiency (fun _:Fin (2*r+1)=>balancedGain r)=
      (2*r+1:ℕ)/balancedCost r := by rw [intrinsicEfficiency,intrinsicGain_balanced]; ring
  have hgreat:IsGreatest {s:ℝ|∃u:Fin (2*r+1)→ℝ,u≠0 ∧ s=intrinsicEfficiency u}
      ((2*r+1:ℕ)/balancedCost r) := by
    refine ⟨⟨(fun _=>balancedGain r),hbnonzero,heq.symm⟩,?_⟩
    rintro s ⟨u,hu,rfl⟩
    exact hbound u hu
  exact hgreat.csSup_eq

/-- First assertion of the paper's asymptotic-localization lemma: the actual
nonzero-vector supremum has precisely the limiting balanced efficiency. -/
theorem scaled_intrinsic_sup_tendsto :
    Tendsto scaledIntrinsicSup atTop (𝓝 limitingParityEfficiency) :=
  degree_div_balanced_cost_tendsto.congr' (scaledIntrinsicSup_eventually.mono (fun r hr=>hr.symm))

end NeuralGeneralization.OnlineLowerTanh
