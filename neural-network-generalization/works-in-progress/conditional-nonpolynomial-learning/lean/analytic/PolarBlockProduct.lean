import PolarHilbertSchmidt
import SequentialMaurey
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch
variable {E : ℕ→Type*} [∀n,NormedAddCommGroup (E n)]
  [∀n,InnerProductSpace ℝ (E n)] [∀n,FiniteDimensional ℝ (E n)]

def hsLinearChain (A : ∀n,E n→ₗ[ℝ] E (n+1)) : (n : ℕ)→E 0→ₗ[ℝ] E n
  | 0=>LinearMap.id
  | n+1=>(A n).comp (hsLinearChain A n)

def hsIsometryChain (U : ∀n,E n→ₗᵢ[ℝ] E (n+1)) : (n : ℕ)→E 0→ₗᵢ[ℝ] E n
  | 0=>LinearIsometry.id
  | n+1=>(U n).comp (hsIsometryChain U n)

lemma polar_chain_error_step (A : ∀n,E n→ₗ[ℝ] E (n+1))
    (U : ∀n,E n→ₗᵢ[ℝ] E (n+1)) (t : ℝ) (n : ℕ) :
    hsLinearChain A (n+1)-t^(n+1) • (hsIsometryChain U (n+1)).toLinearMap=
      (A n).comp (hsLinearChain A n-t^n • (hsIsometryChain U n).toLinearMap)+
      (A n-t • (U n).toLinearMap).comp (t^n • (hsIsometryChain U n).toLinearMap) := by
  ext x
  change A n (hsLinearChain A n x)-t^(n+1) • U n (hsIsometryChain U n x)=
    A n (hsLinearChain A n x-t^n • hsIsometryChain U n x)+
      (A n (t^n • hsIsometryChain U n x)-t • U n (t^n • hsIsometryChain U n x))
  simp only [map_sub,map_smul,smul_sub,smul_smul,pow_succ]
  rw [mul_comm (t^n) t]
  abel

lemma polar_layer_gain {F G : Type*} [NormedAddCommGroup F] [InnerProductSpace ℝ F]
    [FiniteDimensional ℝ F] [NormedAddCommGroup G] [InnerProductSpace ℝ G]
    [FiniteDimensional ℝ G] (A : F→ₗ[ℝ] G) (U : F→ₗᵢ[ℝ] G)
    {t w : ℝ} (ht : 0≤t) (ht1 : t≤1) (hw : 0≤w)
    (herr : frobeniusNorm (A-t • U.toLinearMap)≤w) (x : F) :
    ‖A x‖≤Real.exp w*‖x‖ := by
  have hdiff := norm_linear_le_frobenius (A-t • U.toLinearMap) x
  have hh := norm_add_le ((A-t • U.toLinearMap) x) (t • U x)
  have hid : (A-t • U.toLinearMap) x+t • U x=A x := by simp
  rw [hid,norm_smul,Real.norm_eq_abs,abs_of_nonneg ht,U.norm_map] at hh
  have hm := mul_le_mul_of_nonneg_right herr (norm_nonneg x)
  have he := mul_le_mul_of_nonneg_right (Real.add_one_le_exp w) (norm_nonneg x)
  nlinarith [norm_nonneg x]

/-- Actual products of rectangular maps remain close in Hilbert--Schmidt
norm to the free isometric product. The bound is dimension independent. -/
theorem polar_block_product (A : ∀n,E n→ₗ[ℝ] E (n+1))
    (U : ∀n,E n→ₗᵢ[ℝ] E (n+1)) (w : ℕ→ℝ) {t : ℝ}
    (ht : 0≤t) (ht1 : t≤1) (H : ℕ)
    (hw : ∀j<H,0≤w j)
    (herr : ∀j<H,frobeniusNorm (A j-t • (U j).toLinearMap)≤w j) :
    frobeniusNorm (hsLinearChain A H-t^H • (hsIsometryChain U H).toLinearMap)≤
      Real.exp (∑j∈Finset.range H,w j)*(∑j∈Finset.range H,w j) := by
  induction H with
  | zero=>simp [hsLinearChain,hsIsometryChain,frobeniusNorm_zero]
  | succ H ih=>
    have hprev := ih (fun j hj=>hw j (by omega)) (fun j hj=>herr j (by omega))
    let S := ∑j∈Finset.range H,w j
    have hS : 0≤S := Finset.sum_nonneg (fun j hj=>hw j (by have:=Finset.mem_range.mp hj;omega))
    have hwH := hw H (by omega)
    have hleft := frobeniusNorm_comp_left
      (hsLinearChain A H-t^H • (hsIsometryChain U H).toLinearMap) (A H)
      (Real.exp_nonneg (w H)) (polar_layer_gain (A H) (U H) ht ht1 hwH (herr H (by omega)))
    have hright := frobeniusNorm_comp_right
      (t^H • (hsIsometryChain U H).toLinearMap) (A H-t • (U H).toLinearMap)
      (by norm_num : (0:ℝ)≤1) (by
        intro x
        simp only [LinearMap.smul_apply,norm_smul,Real.norm_eq_abs,abs_of_nonneg (pow_nonneg ht H),
          LinearIsometry.coe_toLinearMap,LinearIsometry.norm_map,one_mul]
        exact mul_le_of_le_one_left (norm_nonneg x) (pow_le_one₀ ht ht1))
    rw [polar_chain_error_step]
    have htri := frobeniusNorm_add
      ((A H).comp (hsLinearChain A H-t^H • (hsIsometryChain U H).toLinearMap))
      ((A H-t • (U H).toLinearMap).comp (t^H • (hsIsometryChain U H).toLinearMap))
    have hmul := mul_le_mul_of_nonneg_left hprev (Real.exp_nonneg (w H))
    have hexp : 1≤Real.exp (S+w H) := Real.one_le_exp (by positivity)
    have hlast := mul_le_mul_of_nonneg_right hexp hwH
    rw [Finset.sum_range_succ]
    change _≤Real.exp (S+w H)*(S+w H)
    rw [Real.exp_add] at hlast ⊢
    change _≤Real.exp S*S at hprev
    change _≤Real.exp (w H)*(Real.exp S*S) at hmul
    have heH := herr H (by omega)
    simp only [mul_one] at hright
    nlinarith

/-- Cauchy--Schwarz converts the sum of layer perturbations to the
square root of block length times total Gaussian cost. -/
theorem polar_block_gaussian_cost (A : ∀n,E n→ₗ[ℝ] E (n+1))
    (U : ∀n,E n→ₗᵢ[ℝ] E (n+1)) (C : ℕ→ℝ) {t : ℝ}
    (ht : 0≤t) (ht1 : t≤1) (H : ℕ) (hC : ∀j,0≤C j)
    (herr : ∀j<H,frobeniusSq (A j-t • (U j).toLinearMap)≤2*t^2*C j) :
    frobeniusNorm (hsLinearChain A H-t^H • (hsIsometryChain U H).toLinearMap)≤
      Real.exp (Real.sqrt (2*H*(∑j∈Finset.range H,C j)))*
        Real.sqrt (2*H*(∑j∈Finset.range H,C j)) := by
  have ht2 : t^2≤1 := by nlinarith
  have hpoint (j : ℕ) (hj : j<H) :
      frobeniusNorm (A j-t • (U j).toLinearMap)≤Real.sqrt (2*C j) := by
    have hcj := hC j
    apply (sq_le_sq₀ (ConditionalNonpolynomial.Analytic.frobeniusNorm_nonneg _) (Real.sqrt_nonneg _)).mp
    rw [frobeniusNorm_sq,Real.sq_sqrt (by positivity)]
    have hm := mul_le_mul_of_nonneg_right ht2 (show 0≤2*C j by positivity)
    nlinarith [herr j hj]
  have hprod := polar_block_product A U (fun j=>Real.sqrt (2*C j)) ht ht1 H
    (fun j _=>Real.sqrt_nonneg _) hpoint
  have hcs := Real.sum_mul_le_sqrt_mul_sqrt (Finset.range H)
    (fun j=>Real.sqrt (2*C j)) (fun _=>1)
  simp only [mul_one,one_pow,Finset.sum_const,Finset.card_range,nsmul_eq_mul,mul_one] at hcs
  have hsq : (∑j∈Finset.range H,(Real.sqrt (2*C j))^2)=2*(∑j∈Finset.range H,C j) := by
    simp_rw [Real.sq_sqrt (mul_nonneg (by norm_num : (0:ℝ)≤2) (hC _))]
    rw [Finset.mul_sum]
  rw [hsq] at hcs
  have hCsum : 0≤∑j∈Finset.range H,C j := Finset.sum_nonneg (fun j _=>hC j)
  have hsum : (∑j∈Finset.range H,Real.sqrt (2*C j))≤
      Real.sqrt (2*H*(∑j∈Finset.range H,C j)) := by
    rw [←Real.sqrt_mul (by positivity)] at hcs
    convert hcs using 1 <;> congr 1 <;> ring
  exact hprod.trans (mul_le_mul (Real.exp_le_exp.mpr hsum) hsum
    (Finset.sum_nonneg (fun j _=>Real.sqrt_nonneg _)) (Real.exp_nonneg _))

#print axioms polar_block_product
#print axioms polar_block_gaussian_cost
end ConditionalNonpolynomial.Analytic
