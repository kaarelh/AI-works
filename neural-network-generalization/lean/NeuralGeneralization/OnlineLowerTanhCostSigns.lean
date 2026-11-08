import NeuralGeneralization.OnlineLowerTanhCostDerivative
import NeuralGeneralization.OnlineLowerComplexRealJet

/-! Alternating high derivatives of the actual optimized tanh cost, with
uniform quantitative constants and a threshold linear in derivative order. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped Topology
open Complex Set Metric
namespace NeuralGeneralization.OnlineLowerTanh

def optimizedRealCost (b:ActualGainBranch) (x:ℝ) : ℝ :=
  (holomorphicOptimizedCost b (x:ℂ)).re

lemma optimizedRealCost_odd (b:ActualGainBranch) (r:ℕ)
    (hr:b.threshold<(2*r+1:ℕ)) :
    optimizedRealCost b (2*r+1:ℕ)=balancedCost r := by
  unfold optimizedRealCost
  simpa only [Complex.ofReal_natCast,Complex.ofReal_re] using
    congrArg Complex.re (holomorphicOptimizedCost_odd b r hr)

lemma optimizedRealCost_derivative_error (b:ActualGainBranch) (T K:ℝ)
    (hT:2≤T) (ha:DifferentiableOn ℂ (holomorphicOptimizedCost b)
      {z:ℂ|0<z.re ∧ T<‖z‖})
    (j:ℕ) (hj:2≤j) (u:ℝ) (hu:(j+1:ℕ)*T<u)
    (hE:‖iteratedDeriv j (optimizedCostRemainder b) (u:ℂ)‖≤
      6*K*(j:ℝ)*(j.factorial:ℝ)/u^(j+2)) :
    |(-1:ℝ)^j*iteratedDeriv j (optimizedRealCost b) u-
        optimizedCostCurvature*(j.factorial:ℝ)/u^(j+1)|≤
      6*K*(j:ℝ)*(j.factorial:ℝ)/u^(j+2) := by
  let U:Set ℂ:={z:ℂ|0<z.re ∧ T<‖z‖}
  have hU:IsOpen U := (isOpen_lt continuous_const Complex.continuous_re).inter
    (isOpen_lt continuous_const continuous_norm)
  have hT0:0≤T := le_trans (by norm_num) hT
  have hu0:0<u := lt_of_le_of_lt (by positivity) hu
  have huT:T<u := by
    have hj1:(1:ℝ)≤(j+1:ℕ) := by exact_mod_cast (show 1≤j+1 by omega)
    nlinarith
  have huU:(u:ℂ)∈U := by
    exact ⟨hu0,by simpa [Complex.norm_real,Real.norm_eq_abs,abs_of_pos hu0] using huT⟩
  have huc:(u:ℂ)≠0 := by exact_mod_cast hu0.ne'
  have hcost:ContDiffAt ℂ j (holomorphicOptimizedCost b) (u:ℂ) :=
    (ha.analyticAt (hU.mem_nhds huU)).contDiffAt
  have hrat:ContDiffAt ℂ j (fun z:ℂ=>(optimizedCostSlope:ℂ)*z+
      (optimizedCostIntercept:ℂ)+(optimizedCostCurvature:ℂ)/z) (u:ℂ) := by
    apply ContDiffAt.add
    · fun_prop
    · exact contDiffAt_const.div contDiffAt_id huc
  have hd : iteratedDeriv j (optimizedCostRemainder b) (u:ℂ)=
      iteratedDeriv j (holomorphicOptimizedCost b) (u:ℂ)-
        (optimizedCostCurvature:ℂ)*((-1:ℂ)^j*(j.factorial:ℂ)/(u:ℂ)^(j+1)) := by
    unfold optimizedCostRemainder
    rw [iteratedDeriv_fun_sub hcost hrat,
      iteratedDeriv_affine_reciprocal _ _ _ _ huc j hj]
  rw [hd] at hE
  have hr := iteratedDeriv_realPart hU ha j u huU
  change iteratedDeriv j (optimizedRealCost b) u=_ at hr
  have heRe : (iteratedDeriv j (holomorphicOptimizedCost b) (u:ℂ)-
        (optimizedCostCurvature:ℂ)*((-1:ℂ)^j*(j.factorial:ℂ)/(u:ℂ)^(j+1))).re=
      iteratedDeriv j (optimizedRealCost b) u-
        (-1:ℝ)^j*(optimizedCostCurvature*(j.factorial:ℝ)/u^(j+1)) := by
    rw [Complex.sub_re,←hr]
    have he : (optimizedCostCurvature:ℂ)*((-1:ℂ)^j*(j.factorial:ℂ)/(u:ℂ)^(j+1))=
        (((-1:ℝ)^j*(optimizedCostCurvature*(j.factorial:ℝ)/u^(j+1)):ℝ):ℂ) := by
      push_cast
      ring
    rw [he,Complex.ofReal_re]
  have hreal := (Complex.abs_re_le_norm _).trans hE
  rw [heRe] at hreal
  have hsign: (-1:ℝ)^j*(-1:ℝ)^j=1 := by rw [←mul_pow]; norm_num
  have he : (-1:ℝ)^j*iteratedDeriv j (optimizedRealCost b) u-
        optimizedCostCurvature*(j.factorial:ℝ)/u^(j+1)=
      (-1:ℝ)^j*(iteratedDeriv j (optimizedRealCost b) u-
        (-1:ℝ)^j*(optimizedCostCurvature*(j.factorial:ℝ)/u^(j+1))) := by
    nlinarith [congrArg (fun x:ℝ=>x*(optimizedCostCurvature*(j.factorial:ℝ)/u^(j+1))) hsign]
  rw [he,abs_mul,abs_neg_one_pow,one_mul]
  exact hreal

/-- A concrete actual-cost family with positive alternating derivatives.
The baseline need only dominate the largest derivative order linearly. -/
theorem optimizedRealCost_alternating_derivatives (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀j:ℕ,2≤j→∀u:ℝ,S*(j:ℝ)≤u→
      (optimizedCostCurvature/2)*(j.factorial:ℝ)/u^(j+1)≤
        (-1:ℝ)^j*iteratedDeriv j (optimizedRealCost b) u ∧
      (-1:ℝ)^j*iteratedDeriv j (optimizedRealCost b) u≤
        (3*optimizedCostCurvature/2)*(j.factorial:ℝ)/u^(j+1) := by
  obtain ⟨T,K,hT,hK,hb,ha,hE⟩:=optimizedCostRemainder_all_derivative_bounds b
  let C:=optimizedCostCurvature
  have hC:0<C := optimizedCostCurvature_pos
  let S:=max (2*T) (12*K/C)
  have hS:0<S := lt_of_lt_of_le (by linarith : 0<2*T) (le_max_left _ _)
  refine ⟨S,hS,?_⟩
  intro j hj u hu
  have hj2:(2:ℝ)≤j := by exact_mod_cast hj
  have hj0:0<(j:ℝ) := by linarith
  have hu0:0<u := lt_of_lt_of_le (mul_pos hS hj0) hu
  have hdom:(j+1:ℕ)*T<u := by
    have hh := mul_le_mul_of_nonneg_right (le_max_left (2*T) (12*K/C)) hj0.le
    change 2*T*(j:ℝ)≤S*(j:ℝ) at hh
    push_cast
    nlinarith
  have hsmall:12*K*(j:ℝ)≤C*u := by
    have hh:=mul_le_mul_of_nonneg_right (le_max_right (2*T) (12*K/C)) hj0.le
    change (12*K/C)*(j:ℝ)≤S*(j:ℝ) at hh
    have hmul:=mul_le_mul_of_nonneg_left (hh.trans hu) hC.le
    field_simp at hmul
    nlinarith
  have he:=optimizedRealCost_derivative_error b T K hT ha j hj u hdom (hE j (by omega) u hdom)
  have hhalf:6*K*(j:ℝ)*(j.factorial:ℝ)/u^(j+2)≤
      (C/2)*(j.factorial:ℝ)/u^(j+1) := by
    have hfact:0<(j.factorial:ℝ) := by positivity
    rw [show j+2=(j+1)+1 by omega,pow_succ]
    apply (div_le_div_iff₀ (mul_pos (pow_pos hu0 _) hu0) (pow_pos hu0 _)).mpr
    have hh:=mul_le_mul_of_nonneg_right hsmall (by positivity : 0≤(j.factorial:ℝ)*u^(j+1))
    nlinarith
  obtain ⟨hl,hu'⟩:=abs_le.mp he
  constructor <;> dsimp only [C] at * <;> ring_nf at hl hu' hhalf ⊢ <;> linarith

end NeuralGeneralization.OnlineLowerTanh
