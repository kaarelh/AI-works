import NeuralGeneralization.BatchTwoOnlineBalancedLayout

/-! Exact group cardinalities and normalized averages for unequal clone multiplicities. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging
variable {C N : ℕ} {k : Fin C→ℕ}

theorem layout_sum_group {M : Type*} [AddCommMonoid M]
    (e : (Σa : Fin C,Fin (k a))≃Fin N) (f : Fin N→M) (a : Fin C) :
    (∑i,if layoutGroup e i=a then f i else 0)=∑j : Fin (k a),f (e ⟨a,j⟩) := by
  classical
  rw [←e.sum_comp]
  simp only [Fintype.sum_sigma,layoutGroup,Equiv.symm_apply_apply]
  rw [Finset.sum_eq_single a]
  · simp
  · intro b _ hba
    simp [hba]
  · simp

theorem layoutPartition_label (e : (Σa : Fin C,Fin (k a))≃Fin N)
    (hk : ∀a,0<k a) (i : Fin N) : populationLabel (layoutPartition e hk) i=layoutGroup e i := rfl

theorem layoutPartition_group_card (e : (Σa : Fin C,Fin (k a))≃Fin N)
    (hk : ∀a,0<k a) (a : Fin C) :
    (populationMembers (layoutPartition e hk) a).card=k a := by
  have hh := layout_sum_group e (fun _=>1:Fin N→ℕ) a
  simpa [populationMembers,layoutPartition_label] using hh

def IsBalancedPartition (p : PopulationPartition N) : Prop :=
  ∀a,(populationMembers p a).card=N/populationCount p ∨
    (populationMembers p a).card=⌈(N:ℝ)/(populationCount p:ℝ)⌉₊

theorem isBalanced_layoutPartition {C N : ℕ} (hC : 0<C) (hCN : C≤N) :
    IsBalancedPartition (layoutPartition (balancedLayout (N:=N) hC) (balancedGroupSize_pos hC hCN)) := by
  intro a
  rw [layoutPartition_group_card]
  exact balancedGroupSize_floor_or_ceil hC a

def layoutMean (e : (Σa : Fin C,Fin (k a))≃Fin N) (h : Fin N→ℝ) (a : Fin C) : ℝ :=
  (∑j : Fin (k a),h (e ⟨a,j⟩))/(k a:ℝ)

def layoutBits (e : (Σa : Fin C,Fin (k a))≃Fin N) (b : Fin C→Bool) : Fin N→ℝ :=
  fun i=>labelReal (b (layoutGroup e i))

@[simp] theorem abs_layoutBits (e : (Σa : Fin C,Fin (k a))≃Fin N) (b : Fin C→Bool) (i : Fin N) :
    |layoutBits e b i|=1 := by simp [layoutBits]

@[simp] theorem layoutMean_bits (e : (Σa : Fin C,Fin (k a))≃Fin N)
    (hk : ∀a,0<k a) (b : Fin C→Bool) (a : Fin C) : layoutMean e (layoutBits e b) a=labelReal (b a) := by
  have hka : (k a:ℝ)≠0 := by exact_mod_cast (hk a).ne'
  simp [layoutMean,layoutBits,layoutGroup,hka]

theorem layout_group_energy_le (e : (Σa : Fin C,Fin (k a))≃Fin N) (z : Fin N→ℝ) (a : Fin C) :
    (∑j : Fin (k a),z (e ⟨a,j⟩)^2)≤∑i,z i^2 := by
  classical
  have hi : Function.Injective (fun j : Fin (k a)=>e ⟨a,j⟩) := by
    intro j l h
    have hh := e.injective h
    exact eq_of_heq (Sigma.mk.inj_iff.mp hh).2
  calc
    _ = ∑i∈Finset.univ.image (fun j : Fin (k a)=>e ⟨a,j⟩),z i^2 := by
      rw [Finset.sum_image]
      exact fun j _ l _ h=>hi h
    _ ≤ _ := Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun i _ _=>sq_nonneg _)

theorem layoutMean_error_sq (e : (Σa : Fin C,Fin (k a))≃Fin N)
    (hk : ∀a,0<k a) (h : Fin N→ℝ) (b : Fin C→Bool) (a : Fin C) :
    (layoutMean e h a-labelReal (b a))^2≤(∑i,(h i-layoutBits e b i)^2)/(k a:ℝ) := by
  have hka : (0:ℝ)<k a := by exact_mod_cast hk a
  have he : layoutMean e h a-labelReal (b a)=
      (∑j : Fin (k a),(h (e ⟨a,j⟩)-labelReal (b a)))/(k a:ℝ) := by
    simp only [layoutMean,Finset.sum_sub_distrib,Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
    field_simp
  rw [he,div_pow]
  have hh := Finset.sum_mul_sq_le_sq_mul_sq (s:=Finset.univ)
    (fun _ : Fin (k a)=>(1:ℝ)) (fun j : Fin (k a)=>h (e ⟨a,j⟩)-labelReal (b a))
  simp only [one_mul,one_pow,Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,mul_one] at hh
  have hg := layout_group_energy_le e (fun i=>h i-layoutBits e b i) a
  simp only [layoutBits,layoutGroup,Equiv.symm_apply_apply] at hg
  apply (div_le_div_iff₀ (sq_pos_of_pos hka) hka).mpr
  have hm := mul_le_mul_of_nonneg_right (hh.trans (mul_le_mul_of_nonneg_left hg hka.le)) hka.le
  simpa only [layoutBits,layoutGroup,pow_two,mul_assoc,mul_left_comm,mul_comm] using hm

theorem layoutMean_error_le (e : (Σa : Fin C,Fin (k a))≃Fin N)
    (hk : ∀a,0<k a) (hwidth : ∀a,N≤2*C*k a)
    (h : Fin N→ℝ) (b : Fin C→Bool) {ε δ : ℝ} (hδ : 0≤δ)
    (hgroup : 2*(C:ℝ)*ε^2≤δ^2)
    (hstate : (∑i,(h i-layoutBits e b i)^2)≤(N:ℝ)*ε^2) (a : Fin C) :
    |layoutMean e h a-labelReal (b a)|≤δ := by
  have hka : (0:ℝ)<k a := by exact_mod_cast hk a
  have hwidthR : (N:ℝ)≤2*(C:ℝ)*(k a:ℝ) := by exact_mod_cast hwidth a
  have hh := layoutMean_error_sq e hk h b a
  have hdiv : ((N:ℝ)*ε^2)/(k a:ℝ)≤2*(C:ℝ)*ε^2 := by
    apply (div_le_iff₀ hka).mpr
    nlinarith [mul_le_mul_of_nonneg_right hwidthR (sq_nonneg ε)]
  have hs := hh.trans ((div_le_div_of_nonneg_right hstate hka.le).trans (hdiv.trans hgroup))
  exact (sq_le_sq₀ (abs_nonneg _) hδ).mp (by simpa only [sq_abs] using hs)

end NeuralGeneralization.BatchTwoOnlineBalanced
