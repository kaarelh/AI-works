import NeuralGeneralization.BatchTwoOnlineTanhClone

/-! Balanced Boolean clone layouts exist at every learner width N >= C. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging

def balancedGroupSize (C N : ℕ) (a : Fin C) : ℕ := N/C+if a.val<N%C then 1 else 0

theorem balancedGroupSize_pos {C N : ℕ} (hC : 0<C) (hCN : C≤N) (a : Fin C) :
    0<balancedGroupSize C N a := by
  have hh := Nat.div_pos hCN hC
  unfold balancedGroupSize
  omega

theorem balancedGroupSize_sum {C N : ℕ} (hC : 0<C) :
    (∑a : Fin C,balancedGroupSize C N a)=N := by
  classical
  have hm := Nat.mod_lt N hC
  let e : {a : Fin C // a.val<N%C}≃Fin (N%C) :=
    { toFun := fun a=>⟨a.val.val,a.property⟩
      invFun := fun a=>⟨⟨a.val,lt_trans a.isLt hm⟩,a.isLt⟩
      left_inv := fun a=>by cases a; rfl
      right_inv := fun a=>by cases a; rfl }
  have hc := Fintype.card_congr e
  simp only [Fintype.card_fin,Fintype.card_subtype] at hc
  simp only [balancedGroupSize,Finset.sum_add_distrib,Finset.sum_const,Finset.card_univ,
    Fintype.card_fin,smul_eq_mul]
  simpa [hc] using Nat.div_add_mod N C

def balancedLayout {C N : ℕ} (hC : 0<C) : (Σa : Fin C,Fin (balancedGroupSize C N a))≃Fin N :=
  Fintype.equivOfCardEq (by simpa only [Fintype.card_sigma,Fintype.card_fin] using balancedGroupSize_sum (N:=N) hC)

theorem balancedGroupSize_bounds {C N : ℕ} (hC : 0<C) (hCN : C≤N) (a : Fin C) :
    N≤2*C*balancedGroupSize C N a ∧ C*balancedGroupSize C N a≤2*N := by
  have hq := Nat.div_pos hCN hC
  have hm := Nat.mod_lt N hC
  have he := Nat.div_add_mod N C
  unfold balancedGroupSize
  split_ifs <;> constructor <;> (try simp only [Nat.add_zero]) <;> first | omega | nlinarith

theorem balancedGroupSize_floor_or_ceil {C N : ℕ} (hC : 0<C) (a : Fin C) :
    balancedGroupSize C N a=N/C ∨ balancedGroupSize C N a=⌈(N:ℝ)/(C:ℝ)⌉₊ := by
  unfold balancedGroupSize
  split_ifs with ha
  · right
    symm
    apply (Nat.ceil_eq_iff (Nat.succ_ne_zero (N/C))).mpr
    have hCp : (0:ℝ)<C := by exact_mod_cast hC
    have hrem : 0<N%C := by omega
    have hm := Nat.mod_lt N hC
    have he : (N:ℝ)=(C:ℝ)*(N/C:ℕ)+(N%C:ℕ) := by exact_mod_cast (Nat.div_add_mod N C).symm
    constructor
    · simp only [Nat.add_sub_cancel,Nat.succ_sub_one]
      apply (lt_div_iff₀ hCp).mpr
      have hr : (0:ℝ)<(N%C:ℕ) := by exact_mod_cast hrem
      nlinarith
    · apply (div_le_iff₀ hCp).mpr
      have hr : ((N%C:ℕ):ℝ)<C := by exact_mod_cast hm
      push_cast
      nlinarith
  · left
    omega

def layoutGroup {C N : ℕ} {k : Fin C→ℕ} (e : (Σa : Fin C,Fin (k a))≃Fin N) (i : Fin N) : Fin C :=
  (e.symm i).1

def layoutPartition {C N : ℕ} {k : Fin C→ℕ} (e : (Σa : Fin C,Fin (k a))≃Fin N)
    (hk : ∀a,0<k a) : PopulationPartition N := by
  have hs : Function.Surjective (layoutGroup e) := fun a=>⟨e ⟨a,⟨0,hk a⟩⟩,by simp [layoutGroup]⟩
  have hc : C≤N := by simpa only [Fintype.card_fin] using Fintype.card_le_of_surjective _ hs
  exact ⟨⟨⟨C,Nat.lt_succ_of_le hc⟩,layoutGroup e⟩,hs⟩

theorem layoutPartition_count {C N : ℕ} {k : Fin C→ℕ} (e : (Σa : Fin C,Fin (k a))≃Fin N)
    (hk : ∀a,0<k a) : populationCount (layoutPartition e hk)=C := rfl

end NeuralGeneralization.BatchTwoOnlineBalanced
