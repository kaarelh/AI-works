import PolarBlockProduct

/-! Finite-horizon polar products require no fictitious isometries after the
last layer, so they apply directly to finite canonical paths. -/
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch
variable {E : ℕ→Type*} [∀n,NormedAddCommGroup (E n)]
  [∀n,InnerProductSpace ℝ (E n)] [∀n,FiniteDimensional ℝ (E n)]

theorem finite_polar_block_product (A : ∀n,E n→ₗ[ℝ] E (n+1)) (w : ℕ→ℝ)
    {t : ℝ} (ht : 0≤t) (ht1 : t≤1) (H : ℕ)
    (hw : ∀j<H,0≤w j)
    (herr : ∀j<H,∃U:E j→ₗᵢ[ℝ] E (j+1),frobeniusNorm (A j-t • U.toLinearMap)≤w j) :
    ∃U:E 0→ₗᵢ[ℝ] E H,
      frobeniusNorm (hsLinearChain A H-t^H • U.toLinearMap)≤
        Real.exp (∑j∈Finset.range H,w j)*(∑j∈Finset.range H,w j) := by
  induction H with
  | zero=>
    refine ⟨LinearIsometry.id,?_⟩
    simp [hsLinearChain,frobeniusNorm_zero]
  | succ H ih=>
    obtain ⟨Uprev,hprev⟩ := ih (fun j hj=>hw j (by omega)) (fun j hj=>herr j (by omega))
    obtain ⟨Ulast,hlast⟩ := herr H (by omega)
    refine ⟨Ulast.comp Uprev,?_⟩
    let S := ∑j∈Finset.range H,w j
    have hS : 0≤S := Finset.sum_nonneg (fun j hj=>hw j (by have:=Finset.mem_range.mp hj;omega))
    have hwH := hw H (by omega)
    have hleft := frobeniusNorm_comp_left (hsLinearChain A H-t^H • Uprev.toLinearMap) (A H)
      (Real.exp_nonneg (w H)) (polar_layer_gain (A H) Ulast ht ht1 hwH hlast)
    have hright := frobeniusNorm_comp_right (t^H • Uprev.toLinearMap) (A H-t • Ulast.toLinearMap)
      (by norm_num : (0:ℝ)≤1) (by
        intro x
        simp only [LinearMap.smul_apply,norm_smul,Real.norm_eq_abs,abs_of_nonneg (pow_nonneg ht H),
          LinearIsometry.coe_toLinearMap,LinearIsometry.norm_map,one_mul]
        exact mul_le_of_le_one_left (norm_nonneg x) (pow_le_one₀ ht ht1))
    have hid : hsLinearChain A (H+1)-t^(H+1) • (Ulast.comp Uprev).toLinearMap=
        (A H).comp (hsLinearChain A H-t^H • Uprev.toLinearMap)+
          (A H-t • Ulast.toLinearMap).comp (t^H • Uprev.toLinearMap) := by
      ext x
      change A H (hsLinearChain A H x)-t^(H+1) • Ulast (Uprev x)=
        A H (hsLinearChain A H x-t^H • Uprev x)+
          (A H (t^H • Uprev x)-t • Ulast (t^H • Uprev x))
      simp only [map_sub,map_smul,smul_sub,smul_smul,pow_succ]
      rw [mul_comm (t^H) t]
      abel
    rw [hid]
    have htri := frobeniusNorm_add
      ((A H).comp (hsLinearChain A H-t^H • Uprev.toLinearMap))
      ((A H-t • Ulast.toLinearMap).comp (t^H • Uprev.toLinearMap))
    have hmul := mul_le_mul_of_nonneg_left hprev (Real.exp_nonneg (w H))
    have hexp : 1≤Real.exp (S+w H) := Real.one_le_exp (by positivity)
    have hterm := mul_le_mul_of_nonneg_right hexp hwH
    rw [Finset.sum_range_succ]
    change _≤Real.exp (S+w H)*(S+w H)
    rw [Real.exp_add] at hterm ⊢
    change _≤Real.exp S*S at hprev
    change _≤Real.exp (w H)*(Real.exp S*S) at hmul
    simp only [mul_one] at hright
    nlinarith

theorem finite_polar_block_gaussian_cost (A : ∀n,E n→ₗ[ℝ] E (n+1)) (C : ℕ→ℝ)
    {t : ℝ} (ht : 0≤t) (ht1 : t≤1) (H : ℕ)
    (hC : ∀j<H,0≤C j)
    (herr : ∀j<H,∃U:E j→ₗᵢ[ℝ] E (j+1),frobeniusSq (A j-t • U.toLinearMap)≤2*t^2*C j) :
    ∃U:E 0→ₗᵢ[ℝ] E H,
      frobeniusNorm (hsLinearChain A H-t^H • U.toLinearMap)≤
        Real.exp (Real.sqrt (2*H*(∑j∈Finset.range H,C j)))*
          Real.sqrt (2*H*(∑j∈Finset.range H,C j)) := by
  have ht2 : t^2≤1 := by nlinarith
  have hpoint (j : ℕ) (hj : j<H) :
      ∃U:E j→ₗᵢ[ℝ] E (j+1),frobeniusNorm (A j-t • U.toLinearMap)≤Real.sqrt (2*C j) := by
    obtain ⟨U,hU⟩ := herr j hj
    refine ⟨U,?_⟩
    have hcj := hC j hj
    apply (sq_le_sq₀ (frobeniusNorm_nonneg _) (Real.sqrt_nonneg _)).mp
    rw [frobeniusNorm_sq,Real.sq_sqrt (by positivity)]
    have hm := mul_le_mul_of_nonneg_right ht2 (show 0≤2*C j by positivity)
    nlinarith
  obtain ⟨U,hprod⟩ := finite_polar_block_product A (fun j=>Real.sqrt (2*C j)) ht ht1 H
    (fun j _=>Real.sqrt_nonneg _) hpoint
  refine ⟨U,?_⟩
  have hcs := Real.sum_mul_le_sqrt_mul_sqrt (Finset.range H)
    (fun j=>Real.sqrt (2*C j)) (fun _=>1)
  simp only [mul_one,one_pow,Finset.sum_const,Finset.card_range,nsmul_eq_mul,mul_one] at hcs
  have hsq : (∑j∈Finset.range H,(Real.sqrt (2*C j))^2)=2*(∑j∈Finset.range H,C j) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    exact Real.sq_sqrt (mul_nonneg (by norm_num) (hC j (Finset.mem_range.mp hj)))
  rw [hsq] at hcs
  have hCsum : 0≤∑j∈Finset.range H,C j := Finset.sum_nonneg (fun j hj=>hC j (Finset.mem_range.mp hj))
  have hsum : (∑j∈Finset.range H,Real.sqrt (2*C j))≤
      Real.sqrt (2*H*(∑j∈Finset.range H,C j)) := by
    rw [←Real.sqrt_mul (by positivity)] at hcs
    convert hcs using 1 <;> congr 1 <;> ring
  exact hprod.trans (mul_le_mul (Real.exp_le_exp.mpr hsum) hsum
    (Finset.sum_nonneg (fun j _=>Real.sqrt_nonneg _)) (Real.exp_nonneg _))

#print axioms finite_polar_block_gaussian_cost
end ConditionalNonpolynomial.Analytic
