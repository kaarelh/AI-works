import NeuralGeneralization.NetworkEnergy

/-! Exact teacher-energy budget from the online manuscript: cloning only
loses a factor two on the readout, not on every layer. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel

def teacherBudget (d C r : ℕ) : ℝ :=
  (d:ℝ)*(d+1)*C^2+((r:ℝ)+2)*C^4

theorem teacherBudget_nonneg (d C r : ℕ) : 0≤teacherBudget d C r := by
  unfold teacherBudget
  positivity

theorem bounded_teacher_sums {d C r : ℕ} (w : Weights d C r) (hw : boundedWeights C w) :
    (∑i : Fin C,∑j : Fin (d+1),w (Sum.inl (i,j))^2)≤(C:ℝ)*(d+1)*C^2 ∧
    (∑s : Fin r,∑i : Fin C,∑j : Fin C,w (Sum.inr (Sum.inl (s,i,j)))^2)≤(r:ℝ)*C^4 ∧
    (∑i : Fin C,w (Sum.inr (Sum.inr i))^2)≤(C:ℝ)^3 := by
  classical
  have hs (i : WeightIndex d C r) : w i^2≤(C:ℝ)^2 := by
    have hh:=(sq_le_sq₀ (abs_nonneg (w i)) (Nat.cast_nonneg C)).2 (hw i)
    simpa only [sq_abs] using hh
  constructor
  · calc
      _ ≤ ∑_i : Fin C,∑_j : Fin (d+1),(C:ℝ)^2 :=
        Finset.sum_le_sum fun i _=>Finset.sum_le_sum fun j _=>hs _
      _ = _ := by simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,Nat.cast_add,Nat.cast_one];ring
  constructor
  · calc
      _ ≤ ∑_s : Fin r,∑_i : Fin C,∑_j : Fin C,(C:ℝ)^2 :=
        Finset.sum_le_sum fun s _=>Finset.sum_le_sum fun i _=>Finset.sum_le_sum fun j _=>hs _
      _ = _ := by simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul];ring
  · calc
      _ ≤ ∑_i : Fin C,(C:ℝ)^2 :=Finset.sum_le_sum fun i _=>hs _
      _ = _ := by simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul];ring

theorem cloned_teacher_cost {d C N r k p : ℕ} (hC : 0<C) (hk : 0<k)
    (hbelow : C*k≤N) (habove : N≤2*C*k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (w : Weights d C r) (hw : boundedWeights C w) :
    weightedSquaredNorm (clonedWeights e w)≤teacherBudget d C r := by
  have hN:0<N:=lt_of_lt_of_le (Nat.mul_pos hC hk) hbelow
  have hCR:0<(C:ℝ):=by exact_mod_cast hC
  have hkR:0<(k:ℝ):=by exact_mod_cast hk
  have hNR:0<(N:ℝ):=by exact_mod_cast hN
  have hbelowR:(C:ℝ)*k≤N:=by exact_mod_cast hbelow
  have haboveR:(N:ℝ)≤2*C*k:=by exact_mod_cast habove
  have hf:(d:ℝ)*k/N≤(d:ℝ)/C:=by
    apply (div_le_div_iff₀ hNR hCR).2
    nlinarith [mul_le_mul_of_nonneg_left hbelowR (Nat.cast_nonneg d : (0:ℝ)≤d)]
  have ho:(N:ℝ)/k≤2*C:=by apply (div_le_iff₀ hkR).2;nlinarith
  obtain ⟨hfSum,hiSum,hoSum⟩:=bounded_teacher_sums w hw
  have hfirst:0≤(∑i : Fin C,∑j : Fin (d+1),w (Sum.inl (i,j))^2):=
    Finset.sum_nonneg fun i _=>Finset.sum_nonneg fun j _=>sq_nonneg _
  have hout:0≤(∑i : Fin C,w (Sum.inr (Sum.inr i))^2):=
    Finset.sum_nonneg fun i _=>sq_nonneg _
  have hf1:=mul_le_mul_of_nonneg_right hf hfirst
  have hf2:=mul_le_mul_of_nonneg_left hfSum (div_nonneg (Nat.cast_nonneg d) hCR.le)
  have hfc:(d:ℝ)/C*((C:ℝ)*(d+1)*C^2)=(d:ℝ)*(d+1)*C^2:=by field_simp <;> ring
  rw [hfc] at hf2
  have ho1:=mul_le_mul_of_nonneg_right ho hout
  have ho2:=mul_le_mul_of_nonneg_left hoSum (show (0:ℝ)≤2*C by positivity)
  rw [weightedSquaredNorm_cloned hk]
  unfold teacherBudget
  nlinarith

theorem exists_paper_teacher_clone {d C N r : ℕ} (hC : 0<C) (hCN : C≤N)
    (φ : ℝ→ℝ) (w : Weights d C r) (hw : boundedWeights C w) :
    ∃v : Weights d N r,(∀x,networkOutput φ v x=networkOutput φ w x) ∧
      weightedSquaredNorm v≤teacherBudget d C r := by
  classical
  let k:=N/C
  have hk:0<k:=Nat.div_pos hCN hC
  have hmod:N%C<C:=Nat.mod_lt _ hC
  have hsplit:N%C+C*k=N:=Nat.mod_add_div N C
  have hbelow:C*k≤N:=by omega
  have hCk:C≤C*k:=by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove:N≤2*C*k:=by nlinarith
  let e : ((Fin C×Fin k)⊕Fin (N-C*k))≃Fin N:=Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  exact ⟨clonedWeights e w,fun x=>networkOutput_cloned hk φ e w x,
    cloned_teacher_cost hC hk hbelow habove e w hw⟩

theorem realizesAtComplexity_paper_energy {d C N r : ℕ} (φ : ℝ→ℝ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N) :
    networkEnergy (N:=N) (r:=r) φ (1/2) f≤teacherBudget d C r/2 := by
  obtain ⟨hC,w,hwm,hwb⟩:=hf
  obtain ⟨v,hv,hcost⟩:=exists_paper_teacher_clone (by omega) hCN φ w hwb
  have hm:v∈marginEvent φ (1/2) f:=by
    intro x
    simpa only [hv x] using hwm x
  exact (networkEnergy_le_of_mem φ (1/2) f v hm).trans (by linarith)

end NeuralGeneralization.BatchTwoOnlineSharp
