import NeuralGeneralization.BatchTwoOnlineTanhClone
import NeuralGeneralization.BatchTwoMergingSharpSupport

/-! Quantitative readout bounds placing the actual saturated cylinder in the merging support. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging
variable {d C N r k p : ℕ}

theorem sharpCoordinateCylinder_mono (v : Weights d N r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) {ρ ρ' σ : ℝ} (hρ : ρ≤ρ') (hσ : 0≤σ) :
    sharpCoordinateCylinder v b J ρ σ⊆sharpCoordinateCylinder v b J ρ' σ := by
  intro w hw
  refine ⟨?_,hw.2⟩
  intro q hq
  have hh := hw.1 q hq
  have hm := mul_le_mul_of_nonneg_right hρ hσ
  exact ⟨by linarith [hh.1],by linarith [hh.2]⟩

theorem saturated_readout_abs_sum (e : ((Fin C×Fin k)⊕Fin p)≃Fin N)
    (B : LayeredBooleanCircuit d C r) (hk : 0<k) (A : ℝ) {a : ℝ} (ha : 0≤a) :
    (∑i,|B.saturatedClone e A a (.inr (.inr i))|)=a := by
  have hkR : (k:ℝ)≠0 := by exact_mod_cast hk.ne'
  rw [←e.sum_comp]
  simp only [Fintype.sum_sum_type,Fintype.sum_prod_type,LayeredBooleanCircuit.saturatedClone,
    Equiv.symm_apply_apply]
  simp only [abs_ite,abs_zero,Finset.sum_const_zero,add_zero,Finset.sum_const,
    Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,←Finset.mul_sum]
  simp only [Finset.sum_ite_eq',Finset.mem_univ,ite_true,abs_div,
    abs_of_nonneg ha,abs_of_nonneg (Nat.cast_nonneg k : (0:ℝ)≤k)]
  field_simp

theorem tanh_output_abs_le_readout (w : Weights d N r) (x : Cube d) :
    |networkOutput Real.tanh w x|≤∑i,|w (.inr (.inr i))| := by
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  apply Finset.sum_le_sum
  intro i _
  rw [abs_mul]
  have hh : |finalHidden Real.tanh w x i|≤1 :=
    hiddenFold_bounded Real.tanh tanh_admissible w _ _ i
  simpa only [mul_one] using mul_le_mul_of_nonneg_left hh (abs_nonneg _)

theorem saturated_perturbed_output_abs (hN : 0<N) (hk : 0<k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredBooleanCircuit d C r)
    (w : Weights d N r) (A : ℝ) {a ρ : ℝ} (ha : 0≤a)
    (he : ∀i,|w (.inr (.inr i))-B.saturatedClone e A a (.inr (.inr i))|≤ρ/N)
    (x : Cube d) : |networkOutput Real.tanh w x|≤a+ρ := by
  have hN0 : (N:ℝ)≠0 := by exact_mod_cast hN.ne'
  apply (tanh_output_abs_le_readout w x).trans
  calc
    _ ≤ ∑i,(|B.saturatedClone e A a (.inr (.inr i))|+ρ/N) :=
      Finset.sum_le_sum fun i _=>by
        have ht := abs_add_le (w (.inr (.inr i))-B.saturatedClone e A a (.inr (.inr i)))
          (B.saturatedClone e A a (.inr (.inr i)))
        rw [sub_add_cancel] at ht
        linarith [he i]
    _ = _ := by rw [Finset.sum_add_distrib,saturated_readout_abs_sum e B hk A ha]; simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]; field_simp

theorem saturated_perturbed_population_budget (hN : 0<N) (hC : 0<C) (hk : 0<k)
    (hbelow : C*k≤N) (e : ((Fin C×Fin k)⊕Fin p)≃Fin N)
    (B : LayeredBooleanCircuit d C r) (w : Weights d N r) (A : ℝ)
    {a ρ : ℝ} (ha : 0≤a) (hρ : 0≤ρ) (hρa : ρ≤a/4)
    (he : ∀i,|w (.inr (.inr i))-B.saturatedClone e A a (.inr (.inr i))|≤ρ/N) :
    ∀x,((populationCount (clonePartition e):ℝ)-1)*(networkOutput Real.tanh w x)^2≤
      4*readoutEnergy w := by
  have hCR : (1:ℝ)≤C := by exact_mod_cast hC
  have hkR : (0:ℝ)<k := by exact_mod_cast hk
  have hbelowR : (C:ℝ)*k≤N := by exact_mod_cast hbelow
  have hcenter : (C:ℝ)*a^2≤readoutEnergy (B.saturatedClone e A a) := by
    rw [B.saturatedClone_readout_energy_eq e hk A a]
    apply (le_div_iff₀ hkR).mpr
    nlinarith [mul_le_mul_of_nonneg_right hbelowR (sq_nonneg a)]
  have hcompare := readoutEnergy_compare_of_coordinate_error hN w (B.saturatedClone e A a) hρ he
  have hrho : ρ^2≤a^2/16 := by nlinarith [sq_nonneg (a/4-ρ)]
  have haC : a^2≤(C:ℝ)*a^2 := le_mul_of_one_le_left (sq_nonneg a) hCR
  have henergy : 7/16*(C:ℝ)*a^2≤readoutEnergy w := by nlinarith
  intro x
  have hout := saturated_perturbed_output_abs hN hk e B w A ha he x
  have hout' : (networkOutput Real.tanh w x)^2≤25/16*a^2 := by
    have hs := (sq_le_sq₀ (abs_nonneg _) (show 0≤5*a/4 by positivity)).mpr
      (show |networkOutput Real.tanh w x|≤5*a/4 by linarith)
    rw [sq_abs] at hs
    nlinarith
  have hq : (populationCount (clonePartition e):ℝ)-1≤C := by
    have hh : (populationCount (clonePartition e):ℝ)≤(C:ℝ)+1 := by
      exact_mod_cast clonePartition_count_le e
    linarith
  calc
    _ ≤ (C:ℝ)*(networkOutput Real.tanh w x)^2 := mul_le_mul_of_nonneg_right hq (sq_nonneg _)
    _ ≤ (C:ℝ)*(25/16*a^2) := mul_le_mul_of_nonneg_left hout' (by positivity)
    _ ≤ _ := by nlinarith [mul_nonneg (Nat.cast_nonneg C : (0:ℝ)≤C) (sq_nonneg a)]

end NeuralGeneralization.BatchTwoOnlineTanhMerging
