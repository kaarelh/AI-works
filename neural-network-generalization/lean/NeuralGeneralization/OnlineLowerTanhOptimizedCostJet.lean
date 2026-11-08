import NeuralGeneralization.OnlineLowerTanhOptimizedGain
import NeuralGeneralization.OnlineLowerQuadraticJet
import NeuralGeneralization.OnlineLowerCentralBinomialWallis

noncomputable section
open scoped Topology BigOperators
open Complex Set Metric Filter Asymptotics
namespace NeuralGeneralization.OnlineLowerTanh

def optimizedQuotient0 : ℝ := limitingGain/scalarF0 limitingGain
def optimizedQuotient1 : ℝ := -limitingGain*scalarF1 limitingGain/(scalarF0 limitingGain)^2
def optimizedQuotient2 : ℝ := limitingGain*(scalarF1 limitingGain)^2/(scalarF0 limitingGain)^3-
  limitingGain*scalarF2 limitingGain/(scalarF0 limitingGain)^2+
  (scalarF1 limitingGain-limitingGain*scalarF1First limitingGain)^2/
    (2*limitingGain*scalarF0Second limitingGain*(scalarF0 limitingGain)^2)

lemma actualGainBranch_complexF_jet (b:ActualGainBranch) :
    (fun z=>complexF z (b.gain z)-((scalarF0 limitingGain:ℂ)+
      (scalarF0First limitingGain:ℂ)*(b.gain z-(limitingGain:ℂ))+
      ((scalarF0Second limitingGain:ℂ)/2)*(b.gain z-(limitingGain:ℂ))^2+
      ((scalarF1 limitingGain:ℂ)+(scalarF1First limitingGain:ℂ)*(b.gain z-(limitingGain:ℂ)))*z⁻¹+
      (scalarF2 limitingGain:ℂ)*z⁻¹^2))=O[rightDegreeInfinity] (fun z:ℂ=>z⁻¹^3) := by
  let a:ℂ:=limitingGain
  let δ:ℂ→ℂ:=fun z=>b.gain z-a
  let h:ℂ→ℂ:=fun z=>z⁻¹
  have hδO:δ=O[rightDegreeInfinity] h:=actualGainBranch_displacement_bigO b
  have hδ:Tendsto δ rightDegreeInfinity (𝓝 0):=hδO.trans_tendsto rightDegree_inv_tendsto
  have ha:1<a.re:=by change 1<limitingGain; linarith [limitingGain_mem.1]
  have hopen:IsOpen {a:ℂ|1<a.re}:=isOpen_lt continuous_const Complex.continuous_re
  have hf0:=complexF0_differentiableOn.analyticAt (hopen.mem_nhds ha)
  have hf1:=complexF1_differentiableOn.analyticAt (hopen.mem_nhds ha)
  have hf2:=complexF2_differentiableOn.analyticAt (hopen.mem_nhds ha)
  have ht0 := ((analytic_taylor_bigO complexF0 a hf0 3).comp_tendsto hδ).trans (hδO.pow 3)
  have ht1 := ((analytic_taylor_bigO complexF1 a hf1 2).comp_tendsto hδ).trans (hδO.pow 2)
  have ht2 := ((analytic_taylor_bigO complexF2 a hf2 1).comp_tendsto hδ).trans (hδO.pow 1)
  simp only [Function.comp_def] at ht0 ht1 ht2
  simp [Finset.sum_range_succ,iteratedDeriv_zero,iteratedDeriv_one,a,
    complexF0_ofReal,complexF1_ofReal,complexF2_ofReal,complexF0_limitingGain_deriv,
    complexF0_limitingGain_iteratedDeriv_two,complexF1_limitingGain_deriv] at ht0 ht1 ht2
  have hE : (fun z=>complexF z (b.gain z)-(complexF0 (b.gain z)+
      complexF1 (b.gain z)*h z+complexF2 (b.gain z)*h z^2))
      =O[rightDegreeInfinity] (fun z=>h z^3) := by
    apply rightDegree_uniform_bigO _ 3 (4*∑'j:ℕ,complexRemainderMajorant j)
    filter_upwards [rightDegree_re_eventually,rightDegree_large b.threshold] with z hz hzT
    have hb:dist (b.gain z) (limitingGain:ℂ)<(1/8:ℝ) := by
      have hh:dist (b.gain z) (limitingGain:ℂ)≤b.radius := (b.root z hz hzT).1
      linarith [b.radius_small,b.radius_pos]
    have hzn:z≠0:=by intro he; simpa [he] using hz
    simpa [h,div_eq_mul_inv,inv_pow] using
      complexF_expansion_bound hz.le hzn (limitingGain_disk_bounds hb).1.le
  have hT1 := ht1.mul (isBigO_refl h rightDegreeInfinity)
  have hT2 := ht2.mul ((isBigO_refl h rightDegreeInfinity).pow 2)
  have hs := ((hE.add ht0).add (hT1.congr_right (fun z=>by ring))).add
    (hT2.congr_right (fun z=>by ring))
  exact hs.congr_left (fun z=>by dsimp [δ,h,a]; ring)

lemma optimizedGainFirstCoefficient_eq :
    optimizedGainFirstCoefficient=
      ((scalarF1 limitingGain-limitingGain*scalarF1First limitingGain)/
        (limitingGain*scalarF0Second limitingGain):ℝ) := by
  unfold optimizedGainFirstCoefficient complexStationary1
  rw [complexF1Derivative_ofReal,complexF1_ofReal,complexStationary0_limitingGain_deriv]
  push_cast
  ring

lemma actualGainBranch_quotient_jet (b:ActualGainBranch) :
    (fun z=>b.gain z/complexF z (b.gain z)-((optimizedQuotient0:ℂ)+
      (optimizedQuotient1:ℂ)*z⁻¹+(optimizedQuotient2:ℂ)*z⁻¹^2))
      =O[rightDegreeInfinity] (fun z:ℂ=>z⁻¹^3) := by
  have h0:(scalarF0 limitingGain:ℂ)≠0:=by exact_mod_cast scalarF0_limitingGain_pos.ne'
  have ha:(limitingGain:ℂ)≠0:=by exact_mod_cast limitingGain_pos.ne'
  have hpp:(scalarF0Second limitingGain:ℂ)≠0:=by exact_mod_cast scalarF0Second_limitingGain_neg.ne
  have hstat:(limitingGain:ℂ)*(scalarF0First limitingGain:ℂ)=(scalarF0 limitingGain:ℂ) := by
    have hh:=limitingGain_stationary
    unfold scalarStationary at hh
    exact_mod_cast sub_eq_zero.mp hh
  have hδ1:=actualGainBranch_first_order b
  rw [optimizedGainFirstCoefficient_eq] at hδ1
  push_cast at hδ1
  have hq:=stationary_quotient_jet_explicit rightDegreeInfinity (fun z:ℂ=>z⁻¹)
    (fun z=>b.gain z-(limitingGain:ℂ)) (fun z=>complexF z (b.gain z))
    (limitingGain:ℂ) (scalarF0 limitingGain:ℂ) (scalarF0First limitingGain:ℂ)
    (scalarF0Second limitingGain:ℂ) (scalarF1 limitingGain:ℂ)
    (scalarF1First limitingGain:ℂ) (scalarF2 limitingGain:ℂ)
    rightDegree_inv_tendsto (actualGainBranch_displacement_bigO b) hδ1
    (actualGainBranch_complexF_jet b) h0 ha hpp hstat
  simpa [optimizedQuotient0,optimizedQuotient1,optimizedQuotient2] using hq

lemma centralBinomial_reciprocal_jet :
    (fun z=> (centralBinomialHolomorphic z)⁻¹-(1-(1/4:ℂ)*z⁻¹+(1/32:ℂ)*z⁻¹^2))
      =O[rightDegreeInfinity] (fun z:ℂ=>z⁻¹^3) := by
  have hH : (fun z=>centralBinomialHolomorphic z-(1+(1/4:ℂ)*z⁻¹+(1/32:ℂ)*z⁻¹^2))
      =O[rightDegreeInfinity] (fun z:ℂ=>z⁻¹^3) := by
    apply rightDegree_uniform_bigO _ 3 257
    filter_upwards [rightDegree_re_eventually,rightDegree_large 32] with z hz hzN
    exact centralBinomialHolomorphic_expansion hz hzN.le
  have hq:=stationary_quotient_jet rightDegreeInfinity (fun z:ℂ=>z⁻¹) (fun _=>0)
    centralBinomialHolomorphic 1 0 1 1 0 (1/4) 0 (1/32) 1 (-1/4) (1/32)
    rightDegree_inv_tendsto (isBigO_zero _ _) (by simpa only [zero_mul,sub_zero] using isBigO_zero (E':=ℂ) (fun z:ℂ=>z⁻¹^2) rightDegreeInfinity)
    (by simpa using hH) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact hq.congr_left (fun z=>by simp only [zero_mul,add_zero,one_div]; ring)

lemma optimizedQuotient_curvature :
    optimizedQuotient2-optimizedQuotient1/4+optimizedQuotient0/32=
      normalizedOptimizedCurvature limitingGain := by
  unfold optimizedQuotient0 optimizedQuotient1 optimizedQuotient2 normalizedOptimizedCurvature
  field_simp
  <;> ring

lemma actualGainBranch_normalized_cost_jet (b:ActualGainBranch) :
    (fun z=>b.gain z/(centralBinomialHolomorphic z*complexF z (b.gain z))-
      ((optimizedQuotient0:ℂ)+((optimizedQuotient1-optimizedQuotient0/4:ℝ):ℂ)*z⁻¹+
        (normalizedOptimizedCurvature limitingGain:ℂ)*z⁻¹^2))
      =O[rightDegreeInfinity] (fun z:ℂ=>z⁻¹^3) := by
  have hh := quadratic_jet_mul rightDegreeInfinity (fun z:ℂ=>z⁻¹)
    (fun z=>b.gain z/complexF z (b.gain z)) (fun z=>(centralBinomialHolomorphic z)⁻¹)
    (optimizedQuotient0:ℂ) (optimizedQuotient1:ℂ) (optimizedQuotient2:ℂ) 1 (-1/4) (1/32)
    rightDegree_inv_tendsto (actualGainBranch_quotient_jet b)
    (centralBinomial_reciprocal_jet.congr_left (fun z=>by ring))
  apply hh.congr_left
  intro z
  rw [←optimizedQuotient_curvature]
  push_cast
  simp only [div_eq_mul_inv,mul_inv_rev]
  ring

def optimizedCostSlope : ℝ := Real.sqrt (Real.pi/2)*optimizedQuotient0
def optimizedCostIntercept : ℝ := Real.sqrt (Real.pi/2)*(optimizedQuotient1-optimizedQuotient0/4)
def optimizedCostCurvature : ℝ := Real.sqrt (Real.pi/2)*normalizedOptimizedCurvature limitingGain

def holomorphicOptimizedCost (b:ActualGainBranch) (z:ℂ) : ℂ :=
  (Real.sqrt (Real.pi/2):ℂ)*z*(b.gain z/(centralBinomialHolomorphic z*complexF z (b.gain z)))

lemma optimizedCostSlope_pos : 0<optimizedCostSlope := by
  exact mul_pos (Real.sqrt_pos.mpr (div_pos Real.pi_pos (by norm_num)))
    (div_pos limitingGain_pos scalarF0_limitingGain_pos)
lemma optimizedCostCurvature_pos : 0<optimizedCostCurvature := by
  exact mul_pos (Real.sqrt_pos.mpr (div_pos Real.pi_pos (by norm_num))) limitingGain_curvature_positive

/-- The actual positive curvature expansion, uniform through complex degrees
in the right half-plane. -/
theorem holomorphicOptimizedCost_jet (b:ActualGainBranch) :
    (fun z=>holomorphicOptimizedCost b z-
      ((optimizedCostSlope:ℂ)*z+(optimizedCostIntercept:ℂ)+(optimizedCostCurvature:ℂ)/z))
      =O[rightDegreeInfinity] (fun z:ℂ=>z⁻¹^2) := by
  obtain ⟨K,hK⟩:=isBigO_iff.mp (actualGainBranch_normalized_cost_jet b)
  apply isBigO_iff.mpr
  refine ⟨‖(Real.sqrt (Real.pi/2):ℂ)‖*K,?_⟩
  filter_upwards [hK,rightDegree_large 1] with z hz hzN
  have hzn:z≠0:=norm_ne_zero_iff.mp (ne_of_gt (lt_trans (by norm_num) hzN))
  have he : holomorphicOptimizedCost b z-
      ((optimizedCostSlope:ℂ)*z+(optimizedCostIntercept:ℂ)+(optimizedCostCurvature:ℂ)/z)=
      (Real.sqrt (Real.pi/2):ℂ)*z*(b.gain z/(centralBinomialHolomorphic z*complexF z (b.gain z))-
        ((optimizedQuotient0:ℂ)+((optimizedQuotient1-optimizedQuotient0/4:ℝ):ℂ)*z⁻¹+
          (normalizedOptimizedCurvature limitingGain:ℂ)*z⁻¹^2)) := by
    unfold holomorphicOptimizedCost optimizedCostSlope optimizedCostIntercept optimizedCostCurvature
    push_cast
    field_simp
    <;> ring
  rw [he,norm_mul,norm_mul]
  calc
    _ ≤ ‖(Real.sqrt (Real.pi/2):ℂ)‖*‖z‖*(K*‖z⁻¹^3‖) := by gcongr
    _ = _ := by
      rw [norm_pow,norm_pow,norm_inv]
      field_simp
      <;> ring

end NeuralGeneralization.OnlineLowerTanh
