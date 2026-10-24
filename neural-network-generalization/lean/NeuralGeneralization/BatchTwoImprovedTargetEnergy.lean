import NeuralGeneralization.BatchTwoImprovedTargetInvariant

/-! Sparse gate energy and the full width-dependent readout lower bound. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {d C N r k p:ℕ}

theorem DigitalGate.coeff_squaredSum_le {I:Type*} [Fintype I] [DecidableEq I]
    (g:DigitalGate I) (one:I):(∑j,g.coeff one j^2)≤9 := by
  classical
  cases g with
  | copy i => simp [DigitalGate.coeff]
  | negate i => simp [DigitalGate.coeff]
  | nand i j =>
    by_cases hi:one=i <;> by_cases hj:one=j <;> by_cases hij:i=j <;>
      simp_all [DigitalGate.coeff,sub_sq,mul_ite,ite_mul,Finset.sum_sub_distrib,
        Finset.sum_add_distrib,Finset.mul_sum,Finset.sum_mul,eq_comm] <;> norm_num

namespace LayeredBooleanCircuit

theorem saturatedClone_first_energy (B:LayeredBooleanCircuit d C r)
    (e:((Fin C×Fin k)⊕Fin p)≃Fin N) (A a:ℝ):
    (∑i,∑j,B.saturatedClone e A a (.inl (i,j))^2)≤(N:ℝ)*9*A^2 := by
  calc
    _ = ∑i,A^2*(∑j,(B.cloneInputGate e i).coeff 0 j^2) := by
      simp only [saturatedClone,mul_pow,Finset.mul_sum]
    _ ≤ ∑_i:Fin N,A^2*9 := Finset.sum_le_sum fun i _=>
      mul_le_mul_of_nonneg_left ((B.cloneInputGate e i).coeff_squaredSum_le 0) (sq_nonneg A)
    _ = _ := by simp;ring

theorem saturatedClone_internal_row_energy (B:LayeredBooleanCircuit d C r)
    (e:((Fin C×Fin k)⊕Fin p)≃Fin N) (hk:0<k) (A a:ℝ) (s:Fin r) (i:Fin N):
    (∑j,B.saturatedClone e A a (.inr (.inl (s,i,j)))^2)≤9*A^2/k := by
  have hkr:(0:ℝ)<k := by exact_mod_cast hk
  rw [←e.sum_comp]
  simp only [Fintype.sum_sum_type,Fintype.sum_prod_type,saturatedClone,Equiv.symm_apply_apply,
    zero_pow (by omega : 2≠0),Finset.sum_const_zero,add_zero,Finset.sum_const,
    Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  have he:(∑b:Fin C,(k:ℝ)*(A*(B.cloneInternalGate e s i).coeff B.constant b/k)^2)=
      (A^2/k)*(∑b:Fin C,(B.cloneInternalGate e s i).coeff B.constant b^2) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro b _
    field_simp <;> ring
  rw [he]
  have hh:=mul_le_mul_of_nonneg_left ((B.cloneInternalGate e s i).coeff_squaredSum_le B.constant)
    (by positivity : 0≤A^2/(k:ℝ))
  exact hh.trans_eq (by ring)

theorem saturatedClone_readout_energy_eq (B:LayeredBooleanCircuit d C r)
    (e:((Fin C×Fin k)⊕Fin p)≃Fin N) (hk:0<k) (A a:ℝ):
    readoutEnergy (B.saturatedClone e A a)=(N:ℝ)*a^2/k := by
  have hkr:(k:ℝ)≠0 := by exact_mod_cast hk.ne'
  unfold readoutEnergy
  rw [←e.sum_comp]
  simp only [Fintype.sum_sum_type,Fintype.sum_prod_type,saturatedClone,Equiv.symm_apply_apply]
  simp only [ite_pow,zero_pow (by omega : 2≠0),Finset.sum_const_zero,add_zero,
    Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,←Finset.mul_sum]
  simp only [Finset.sum_ite_eq',Finset.mem_univ,ite_true]
  field_simp <;> ring

theorem saturatedClone_sharp_energy (B:LayeredBooleanCircuit d C r)
    (e:((Fin C×Fin k)⊕Fin p)≃Fin N) (hN:0<N) (hk:0<k)
    (hwidth:N≤2*C*k) (A a:ℝ):
    weightedSquaredNorm (B.saturatedClone e A a)≤
      9*d*A^2+18*r*C*A^2+2*C*a^2 := by
  have hNr:(0:ℝ)<N := by exact_mod_cast hN
  have hkr:(0:ℝ)<k := by exact_mod_cast hk
  have hratio:(N:ℝ)/k≤2*C := (div_le_iff₀ hkr).mpr (by exact_mod_cast hwidth)
  have hf:((d:ℝ)/N)*(∑i,∑j,B.saturatedClone e A a (.inl (i,j))^2)≤9*d*A^2 := by
    have hh:=mul_le_mul_of_nonneg_left (B.saturatedClone_first_energy e A a) (by positivity : 0≤(d:ℝ)/N)
    have he:((d:ℝ)/N)*((N:ℝ)*9*A^2)=9*d*A^2 := by field_simp
    exact hh.trans_eq he
  have hi:(∑s,∑i,∑j,B.saturatedClone e A a (.inr (.inl (s,i,j)))^2)≤18*r*C*A^2 := by
    calc
      _ ≤ ∑_s:Fin r,∑_i:Fin N,9*A^2/k := Finset.sum_le_sum fun s _=>
        Finset.sum_le_sum fun i _=>B.saturatedClone_internal_row_energy e hk A a s i
      _ = (r:ℝ)*((N:ℝ)/k)*(9*A^2) := by simp;ring
      _ ≤ _ := by have hh:=mul_le_mul_of_nonneg_right hratio (show 0≤(r:ℝ)*9*A^2 by positivity);nlinarith
  have ho:readoutEnergy (B.saturatedClone e A a)≤2*C*a^2 := by
    rw [B.saturatedClone_readout_energy_eq e hk A a]
    have hh:=mul_le_mul_of_nonneg_right hratio (sq_nonneg a)
    calc
      _ = (N:ℝ)/k*a^2 := by ring
      _ ≤ _ := hh
  unfold weightedSquaredNorm
  change _+_+readoutEnergy _≤_
  linarith

end LayeredBooleanCircuit

end NeuralGeneralization.ConcreteModel
