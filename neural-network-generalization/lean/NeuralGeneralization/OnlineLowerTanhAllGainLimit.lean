import NeuralGeneralization.OnlineLowerTanhInterpolation

/-! Actual balanced parity limit at every positive real gain. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open Complex Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma oddDegree_inv_tendsto :
    Tendsto (fun r:ℕ=>(((2*r+1:ℕ):ℂ))⁻¹) atTop (𝓝 0) := by
  exact (tendsto_inv_atTop_nhds_zero_nat (𝕜:=ℂ)).comp
    (StrictMono.tendsto_atTop (fun a b hab=>by omega))

lemma hammingFactor_odd_tendsto (j:ℕ) :
    Tendsto (fun r:ℕ=>((((2*r+1:ℕ):ℂ)-(2*(j:ℂ)+1))/
      (((2*r+1:ℕ):ℂ)+(2*(j:ℂ)+3)))) atTop (𝓝 1) := by
  have h:=((tendsto_const_nhds (x:=(1:ℂ))).sub
    ((tendsto_const_nhds (x:=2*(j:ℂ)+1)).mul oddDegree_inv_tendsto)).div
      ((tendsto_const_nhds (x:=(1:ℂ))).add
        ((tendsto_const_nhds (x:=2*(j:ℂ)+3)).mul oddDegree_inv_tendsto)) (by simp)
  have he (r:ℕ) :
      ((((2*r+1:ℕ):ℂ)-(2*(j:ℂ)+1))/(((2*r+1:ℕ):ℂ)+(2*(j:ℂ)+3)))=
      (1-(2*(j:ℂ)+1)*(((2*r+1:ℕ):ℂ))⁻¹)/
       (1+(2*(j:ℂ)+3)*(((2*r+1:ℕ):ℂ))⁻¹) := by
    have hn:((2*r+1:ℕ):ℂ)≠0 := by exact_mod_cast (show 2*r+1≠0 by omega)
    field_simp
  simp only [mul_zero,sub_zero,add_zero,div_one] at h
  convert! h using 1
  funext r
  exact he r

lemma hammingRatio_odd_tendsto (j:ℕ) :
    Tendsto (fun r:ℕ=>hammingRatio j ((2*r+1:ℕ):ℂ)) atTop (𝓝 1) := by
  induction j with
  | zero => simpa only [hammingRatio,Finset.range_zero,Finset.prod_empty] using
      (tendsto_const_nhds (x:=(1:ℂ)))
  | succ j ih =>
      simpa only [hammingRatio_succ,one_mul] using ih.mul (hammingFactor_odd_tendsto j)

lemma prefactoredRatio_odd_tendsto (j:ℕ) :
    Tendsto (fun r:ℕ=>prefactoredRatio j ((2*r+1:ℕ):ℂ)) atTop (𝓝 1) := by
  have he (r:ℕ) : (((2*r+1:ℕ):ℂ)/(((2*r+1:ℕ):ℂ)+1))=
      (1:ℂ)/(1+(((2*r+1:ℕ):ℂ))⁻¹) := by
    have hn:((2*r+1:ℕ):ℂ)≠0 := by exact_mod_cast (show 2*r+1≠0 by omega)
    field_simp
  have h: Tendsto (fun r:ℕ=>(((2*r+1:ℕ):ℂ)/(((2*r+1:ℕ):ℂ)+1))) atTop (𝓝 1) := by
    simp_rw [he]
    convert! (tendsto_const_nhds (x:=(1:ℂ))).div
      ((tendsto_const_nhds (x:=(1:ℂ))).add oddDegree_inv_tendsto) (by simp) using 1 <;> norm_num
  simpa only [prefactoredRatio,one_mul] using h.mul (hammingRatio_odd_tendsto j)

lemma complexLogistic_positive_real_bound (j:ℕ) (a:ℝ) (ha:0<a) :
    ‖complexLogistic j (a:ℂ)‖≤Real.exp (-2*a)*Real.exp (-4*a)^j := by
  rw [complexLogistic_ofReal,Complex.norm_real,Real.norm_eq_abs,logisticTail_exp]
  have he:0<Real.exp (-2*a*(2*(j:ℝ)+1)) := Real.exp_pos _
  rw [abs_of_pos (div_pos he (by positivity))]
  calc
    _ ≤ Real.exp (-2*a*(2*(j:ℝ)+1)) := div_le_self he.le (by linarith)
    _ = _ := by rw [←Real.exp_nat_mul,←Real.exp_add]; congr 1; ring

theorem complexF_odd_tendsto_all_gain (a:ℝ) (ha:0<a) :
    Tendsto (fun r:ℕ=>complexF ((2*r+1:ℕ):ℂ) (a:ℂ)) atTop (𝓝 (complexF0 (a:ℂ))) := by
  have hsum:Summable (fun j:ℕ=>Real.exp (-2*a)*Real.exp (-4*a)^j) :=
    (summable_geometric_of_abs_lt_one (by
      rw [abs_of_pos (Real.exp_pos _)]
      exact Real.exp_lt_one_iff.mpr (by linarith))).mul_left _
  have hlim (j:ℕ) : Tendsto
      (fun r:ℕ=>(-1:ℂ)^j*prefactoredRatio j ((2*r+1:ℕ):ℂ)*complexLogistic j (a:ℂ))
      atTop (𝓝 ((-1:ℂ)^j*complexLogistic j (a:ℂ))) := by
    simpa only [mul_one] using
      ((tendsto_const_nhds (x:=(-1:ℂ)^j)).mul (prefactoredRatio_odd_tendsto j)).mul_const _
  have hbound : ∀ᶠr:ℕ in atTop, ∀j:ℕ,
      ‖(-1:ℂ)^j*prefactoredRatio j ((2*r+1:ℕ):ℂ)*complexLogistic j (a:ℂ)‖≤
        Real.exp (-2*a)*Real.exp (-4*a)^j := by
    exact Eventually.of_forall (fun r j=>by
      rw [norm_mul,norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul]
      exact (mul_le_mul (prefactoredRatio_norm_le_one j (by simp only [Complex.natCast_re]; positivity))
        (complexLogistic_positive_real_bound j a ha) (norm_nonneg _) (by norm_num)).trans_eq (one_mul _))
  have hh:=tendsto_tsum_of_dominated_convergence hsum hlim hbound
  exact (tendsto_const_nhds (x:=(1:ℂ))).sub ((tendsto_const_nhds (x:=(4:ℂ))).mul hh)

/-- No restriction to gains at least one: this is the actual finite-cube limit
for every fixed positive gain. -/
theorem balancedParity_normalized_tendsto (a:ℝ) (ha:0<a) :
    Tendsto (fun r:ℕ=>balancedParity r a/oddParityKappa r) atTop (𝓝 (scalarF0 a)) := by
  apply tendsto_ofReal_iff.mp
  simpa only [complexF_odd_eq_balanced,complexF0_ofReal] using complexF_odd_tendsto_all_gain a ha

end NeuralGeneralization.OnlineLowerTanh
