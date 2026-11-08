import NeuralGeneralization.OnlineLowerTanhParameters

/-! # Verified resources of the logarithmic-rail tanh family -/

noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open ConcreteModel OnlineLower

theorem log_nat_eventually_ge (b : ℝ) : ∀ᶠ k : ℕ in atTop, b ≤ Real.log (k:ℝ) := by
  filter_upwards [eventually_ge_atTop (⌈Real.exp b⌉₊+1)] with k hk
  have hkpos : (0:ℝ) < k := Nat.cast_pos.mpr (by omega)
  apply (Real.le_log_iff_exp_le hkpos).mpr
  exact (Nat.le_ceil _).trans (by exact_mod_cast (show ⌈Real.exp b⌉₊≤k by omega))

/-- The explicit teacher saturation inequality is eventually true for
these actual integer dimensions. -/
theorem teacher_saturation_eventually (K : ℕ) (hK : 1 ≤ K) :
    ∀ᶠ k : ℕ in atTop,
      4*((logicalDim k:ℝ)+1)^2*(constructionDimension K k:ℝ) ≤
        Real.exp (logicalDim k:ℝ) := by
  let A : ℝ := 9680000*(K:ℝ)
  have ht : Tendsto (fun k : ℕ => A*((k:ℝ)^5*Real.exp (-(k:ℝ)))) atTop (𝓝 0) := by
    simpa using (tendsto_const_nhds.mul
      ((Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 5).comp tendsto_natCast_atTop_atTop) :
      Tendsto (fun k : ℕ => A*((k:ℝ)^5*Real.exp (-(k:ℝ)))) atTop (𝓝 (A*0)))
  have hevent : ∀ᶠ k : ℕ in atTop, A*((k:ℝ)^5*Real.exp (-(k:ℝ))) < 1 :=
    (tendsto_order.mp ht).2 1 (by norm_num)
  filter_upwards [hevent,log_nat_eventually_ge 1,eventually_ge_atTop 2] with k he hlog hk
  have hkR : (2:ℝ) ≤ k := by exact_mod_cast hk
  have hm : k ≤ logicalDim k ∧ logicalDim k+1 ≤ 11*k := by rw [logicalDim_eq]; omega
  have hmr : (logicalDim k:ℝ)+1 ≤ 11*(k:ℝ) := by exact_mod_cast hm.2
  have hln : Real.log (k:ℝ) ≤ k := (Real.log_le_sub_one_of_pos (by linarith)).trans (by linarith)
  have hsq : Real.log (k:ℝ)^2 ≤ (k:ℝ)^2 := by nlinarith
  have hdu := (construction_resource_bounds K k hK hk hlog).2.1
  have hdcube : (constructionDimension K k:ℝ) ≤ 20000*(K:ℝ)*(k:ℝ)^3 := by
    have hh := mul_le_mul_of_nonneg_left hsq (by positivity : (0:ℝ)≤20000*K*k)
    nlinarith only [hdu,hh]
  have hm2 : ((logicalDim k:ℝ)+1)^2 ≤ 121*(k:ℝ)^2 := by
    nlinarith [Nat.cast_nonneg (α:=ℝ) (logicalDim k)]
  have hpoly : 4*((logicalDim k:ℝ)+1)^2*(constructionDimension K k:ℝ) ≤ A*(k:ℝ)^5 := by
    have hh := mul_le_mul hm2 hdcube (Nat.cast_nonneg _) (by positivity : (0:ℝ)≤121*k^2)
    dsimp [A]
    nlinarith only [hh]
  have he' : A*(k:ℝ)^5 < Real.exp (k:ℝ) := by
    apply (div_lt_one (Real.exp_pos _)).mp
    simpa only [Real.exp_neg,div_eq_mul_inv,mul_assoc] using he
  have hex : Real.exp (k:ℝ) ≤ Real.exp (logicalDim k:ℝ) :=
    Real.exp_le_exp.mpr (by exact_mod_cast hm.1)
  exact hpoly.trans (he'.le.trans hex)

/-- Full actual neural and Boolean-circuit witnesses, with explicit
width/dimension polynomial inequalities, at every sufficiently large index. -/
theorem construction_resources_eventually (K : ℕ) (hK : 1 ≤ K) :
    ∀ᶠ k : ℕ in atTop,
      3 ≤ constructionDimension K k ∧ 6 ≤ constructionBaseline K k ∧
      BoundedTeacher Real.tanh (constructionTarget K k) (constructionTeacherWidth K k) ∧
      HasCircuitAtMost (constructionTarget K k) (17*constructionDimension K k+5) ∧
      (k:ℝ)*Real.log (k:ℝ)^2 ≤ constructionDimension K k ∧
      (constructionDimension K k:ℝ) ≤ 20000*(K:ℝ)*(k:ℝ)*Real.log (k:ℝ)^2 ∧
      (constructionTeacherWidth K k:ℝ) ≤ 300000*(K:ℝ)*(k:ℝ)^2*Real.log (k:ℝ)^2 := by
  filter_upwards [teacher_saturation_eventually K hK,log_nat_eventually_ge 2,
    eventually_ge_atTop 2] with k hs hlog hk
  have hK0 : 0 < K := by omega
  have hR := constructionBaseline_pos K k hK0
  have hH := constructionIncrement_pos k
  have hres := construction_resource_bounds K k hK hk (by linarith)
  have hkR : (2:ℝ) ≤ k := by exact_mod_cast hk
  have hd : 3 ≤ constructionDimension K k := by
    have hdn : (3:ℝ) ≤ constructionDimension K k := by nlinarith [hres.1]
    exact_mod_cast hdn
  have hbase : 6 ≤ constructionBaseline K k := by
    have hl := (constructionLog_comparison k hk).1
    have hRl := (constructionBaseline_bounds K k).1
    have hKR : (1:ℝ) ≤ K := by exact_mod_cast hK
    have hRR : (6:ℝ) ≤ constructionBaseline K k := by
      nlinarith [sq_nonneg (constructionLog k),mul_nonneg (by linarith : 0≤(K:ℝ)-1)
        (sq_nonneg (constructionLog k))]
    exact_mod_cast hRR
  refine ⟨hd,hbase,?_,target_circuit _ _ k hR hH,hres⟩
  exact OnlineLowerTanh.parityAnd_boundedTeacher hd hs _ _

end NeuralGeneralization.OnlineLowerTanh.Family
