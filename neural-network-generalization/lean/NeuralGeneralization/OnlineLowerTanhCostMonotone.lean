import NeuralGeneralization.OnlineLowerTanhCostSigns
import Mathlib.Analysis.Calculus.Deriv.MeanValue

/-! Eventual monotonicity of the actual optimized scalar tanh cost. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped Topology
open Complex Set Metric
namespace NeuralGeneralization.OnlineLowerTanh

lemma optimizedRealCost_first_error (b:ActualGainBranch) (T K:ℝ)
    (hT:2≤T) (ha:DifferentiableOn ℂ (holomorphicOptimizedCost b)
      {z:ℂ|0<z.re ∧ T<‖z‖})
    (u:ℝ) (hu:2*T<u)
    (hE:‖deriv (optimizedCostRemainder b) (u:ℂ)‖≤6*K/u^3) :
    HasDerivAt (optimizedRealCost b) (deriv (optimizedRealCost b) u) u ∧
    |deriv (optimizedRealCost b) u-(optimizedCostSlope-optimizedCostCurvature/u^2)|≤6*K/u^3 := by
  let U:Set ℂ:={z:ℂ|0<z.re ∧ T<‖z‖}
  have hU:IsOpen U := (isOpen_lt continuous_const Complex.continuous_re).inter
    (isOpen_lt continuous_const continuous_norm)
  have hu0:0<u:=by linarith
  have huT:T<u:=by linarith
  have huU:(u:ℂ)∈U:=⟨hu0,by simpa [Complex.norm_real,Real.norm_eq_abs,abs_of_pos hu0] using huT⟩
  have huc:(u:ℂ)≠0:=by exact_mod_cast hu0.ne'
  have hcost:HasDerivAt (holomorphicOptimizedCost b)
      (deriv (holomorphicOptimizedCost b) (u:ℂ)) (u:ℂ):=
    (ha.differentiableAt (hU.mem_nhds huU)).hasDerivAt
  have hreal:=hcost.real_of_complex
  change HasDerivAt (optimizedRealCost b) _ u at hreal
  have hrat:HasDerivAt (fun z:ℂ=>(optimizedCostSlope:ℂ)*z+
      (optimizedCostIntercept:ℂ)+(optimizedCostCurvature:ℂ)/z)
      ((optimizedCostSlope:ℂ)-(optimizedCostCurvature:ℂ)/(u:ℂ)^2) (u:ℂ):=by
    convert! (((hasDerivAt_id (u:ℂ)).const_mul (optimizedCostSlope:ℂ)).add_const
      (optimizedCostIntercept:ℂ)).add (hasDerivAt_const (u:ℂ) (optimizedCostCurvature:ℂ) |>.div (hasDerivAt_id (u:ℂ)) huc) using 1
    all_goals first | rfl | simp [id_eq,sub_eq_add_neg,neg_div]
  have hd:deriv (optimizedCostRemainder b) (u:ℂ)=
      deriv (holomorphicOptimizedCost b) (u:ℂ)-
        ((optimizedCostSlope:ℂ)-(optimizedCostCurvature:ℂ)/(u:ℂ)^2):=(hcost.sub hrat).deriv
  rw [hd] at hE
  have hh:=(Complex.abs_re_le_norm _).trans hE
  have he:((optimizedCostSlope:ℂ)-(optimizedCostCurvature:ℂ)/(u:ℂ)^2).re=
      optimizedCostSlope-optimizedCostCurvature/u^2:=by
    norm_cast
  rw [Complex.sub_re,he,←hreal.deriv] at hh
  exact ⟨hreal.differentiableAt.hasDerivAt,hh⟩

/-- A positive lower bound for the derivative holds on a concrete eventual
half-line; it follows from the proved cost expansion and its Cauchy bound. -/
theorem optimizedRealCost_eventually_derivative_pos (b:ActualGainBranch) :
    ∃U:ℝ,0<U ∧ b.threshold<U ∧ ∀u:ℝ,U≤u→
      HasDerivAt (optimizedRealCost b) (deriv (optimizedRealCost b) u) u ∧
      optimizedCostSlope/2≤deriv (optimizedRealCost b) u := by
  obtain ⟨T,K,hT,hK,hb,ha,hE⟩:=optimizedCostRemainder_all_derivative_bounds b
  let A:=optimizedCostSlope
  let C:=optimizedCostCurvature
  have hA:0<A:=optimizedCostSlope_pos
  have hC:0<C:=optimizedCostCurvature_pos
  let U:=max (2*T+1) (max (4*C/A) (24*K/A))
  have hU0:0<U:=lt_of_lt_of_le (by linarith : 0<2*T+1) (le_max_left _ _)
  have hbU:b.threshold<U:=lt_of_le_of_lt hb (lt_of_lt_of_le (by linarith : T<2*T+1) (le_max_left _ _))
  refine ⟨U,hU0,hbU,?_⟩
  intro u hu
  have huT:2*T<u:=by have hh:2*T+1≤U:=le_max_left _ _; linarith
  have hu0:0<u:=lt_of_lt_of_le hU0 hu
  have hu1:1≤u:=by have hh:2*T+1≤U:=le_max_left _ _; linarith
  have hCu:4*C/A≤u:=le_trans (le_trans (le_max_left _ _) (le_max_right _ _)) hu
  have hKu:24*K/A≤u:=le_trans (le_trans (le_max_right _ _) (le_max_right _ _)) hu
  have hE1:‖deriv (optimizedCostRemainder b) (u:ℂ)‖≤6*K/u^3:=by
    simpa only [iteratedDeriv_one,Nat.cast_one,Nat.factorial_one,mul_one,Nat.cast_ofNat] using
      hE 1 (by decide) u (by simpa using huT)
  obtain ⟨hd,herr⟩:=optimizedRealCost_first_error b T K hT ha u huT hE1
  refine ⟨hd,?_⟩
  have hCbound:C/u^2≤A/4:=by
    have hpow:u≤u^2:=by nlinarith
    calc
      _≤C/u:=div_le_div_of_nonneg_left hC.le hu0 hpow
      _≤A/4:=by
        apply (div_le_iff₀ hu0).mpr
        have hh:=(div_le_iff₀ hA).mp hCu
        nlinarith
  have hKbound:6*K/u^3≤A/4:=by
    have hpow:u≤u^3:=by nlinarith [sq_nonneg (u-1)]
    calc
      _≤6*K/u:=div_le_div_of_nonneg_left (by positivity) hu0 hpow
      _≤A/4:=by
        apply (div_le_iff₀ hu0).mpr
        have hh:=(div_le_iff₀ hA).mp hKu
        nlinarith
  have hh:=(abs_le.mp herr).1
  dsimp [A,C] at *
  linarith

theorem optimizedRealCost_eventually_strictMono (b:ActualGainBranch) :
    ∃U:ℝ,0<U ∧ b.threshold<U ∧ StrictMonoOn (optimizedRealCost b) (Ici U) := by
  obtain ⟨U,hU,hb,hd⟩:=optimizedRealCost_eventually_derivative_pos b
  refine ⟨U,hU,hb,?_⟩
  apply strictMonoOn_of_deriv_pos (convex_Ici U)
    (fun u hu=>(hd u hu).1.continuousAt.continuousWithinAt)
  intro u hu
  have hx:u∈Ici U:=interior_subset hu
  have hh:=(hd u hx).2
  linarith [optimizedCostSlope_pos]

end NeuralGeneralization.OnlineLowerTanh
