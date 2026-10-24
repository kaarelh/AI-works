import NeuralGeneralization.BatchTwoShallowStability
import Mathlib.Data.NNReal.Basic

/-! Actual all-width target implementation with the manuscript's weighted
teacher cost. Equal groups with disconnected padding suffice; a balanced
partition is not required. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel CompressionSampling

def rowEnergy {d C : ℕ} (w : Weights d C 0) (i : Fin C) : ℝ :=
  ∑ j, w (Sum.inl (i,j))^2

def firstEnergySum {d C : ℕ} (w : Weights d C 0) : ℝ := ∑ i, rowEnergy w i

def readoutEnergySum {d C : ℕ} (w : Weights d C 0) : ℝ :=
  ∑ i, w (Sum.inr (Sum.inr i))^2

def maxRowEnergy {d C : ℕ} (w : Weights d C 0) : ℝ :=
  (Finset.univ.sup (fun i : Fin C => (⟨rowEnergy w i, by unfold rowEnergy; positivity⟩ : ℝ≥0)) : ℝ≥0)

theorem rowEnergy_le_max {d C : ℕ} (w : Weights d C 0) (i : Fin C) :
    rowEnergy w i ≤ maxRowEnergy w := by
  exact_mod_cast (Finset.le_sup (f := fun i : Fin C =>
    (⟨rowEnergy w i, by unfold rowEnergy; positivity⟩ : ℝ≥0)) (Finset.mem_univ i))

theorem firstEnergySum_le {d C : ℕ} (w : Weights d C 0) :
    firstEnergySum w ≤ (C : ℝ)*maxRowEnergy w := by
  calc
    _ ≤ ∑ _i : Fin C, maxRowEnergy w := Finset.sum_le_sum (fun i _ => rowEnergy_le_max w i)
    _ = _ := by simp

def teacherInputCost {d C : ℕ} (w : Weights d C 0) : ℝ :=
  (d : ℝ)*min (maxRowEnergy w) ((2/(C : ℝ))*firstEnergySum w)

def teacherCenterCost {d C : ℕ} (s : ℝ) (w : Weights d C 0) : ℝ :=
  teacherInputCost w+2*s^2*(C : ℝ)*readoutEnergySum w

theorem clone_scaled_cost {d C N k p : ℕ} (hC : 0 < C) (hk : 0 < k)
    (hbelow : C*k ≤ N) (habove : N ≤ 2*C*k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (s : ℝ) (w : Weights d C 0) :
    weightedSquaredNorm (clonedWeights e (rescaleReadout s w)) ≤ teacherCenterCost s w := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.mul_pos hC hk) hbelow
  have hNR : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  have hCR : (0 : ℝ) < C := Nat.cast_pos.mpr hC
  have hkR : (0 : ℝ) < k := Nat.cast_pos.mpr hk
  have hbelowR : (C : ℝ)*k ≤ N := by exact_mod_cast hbelow
  have haboveR : (N : ℝ) ≤ 2*C*k := by exact_mod_cast habove
  have hfirst : 0 ≤ firstEnergySum w := by unfold firstEnergySum rowEnergy; positivity
  have hmax : 0 ≤ maxRowEnergy w := NNReal.coe_nonneg _
  have hread : 0 ≤ readoutEnergySum w := by unfold readoutEnergySum; positivity
  have hsum := firstEnergySum_le w
  have hfrac : (k : ℝ)/(N : ℝ) ≤ 1/C := by
    apply (div_le_div_iff₀ hNR hCR).mpr
    nlinarith
  have hcost1 : (d : ℝ)*k/N*firstEnergySum w ≤ (d : ℝ)*maxRowEnergy w := by
    apply (le_trans (mul_le_mul_of_nonneg_left hsum (by positivity)))
    have hh := mul_le_mul_of_nonneg_right hbelowR
      (mul_nonneg (Nat.cast_nonneg d) hmax)
    rw [div_mul_eq_mul_div]
    apply (div_le_iff₀ hNR).mpr
    nlinarith [hh]
  have hcost2 : (d : ℝ)*k/N*firstEnergySum w ≤ (d : ℝ)*(2/C*firstEnergySum w) := by
    have hh := mul_le_mul_of_nonneg_right hfrac (mul_nonneg (Nat.cast_nonneg d) hfirst)
    have hhpos : 0 ≤ (d : ℝ)/C*firstEnergySum w := by positivity
    simp only [div_eq_mul_inv] at hh hhpos ⊢
    nlinarith
  have hcost : (d : ℝ)*k/N*firstEnergySum w ≤ teacherInputCost w := by
    unfold teacherInputCost
    rw [mul_min_of_nonneg _ _ (Nat.cast_nonneg d)]
    exact le_min hcost1 hcost2
  have hreadfrac : (N : ℝ)/k ≤ 2*C := (div_le_iff₀ hkR).mpr (by nlinarith)
  have hreadcost := mul_le_mul_of_nonneg_right hreadfrac (mul_nonneg (sq_nonneg s) hread)
  rw [weightedSquaredNorm_cloned hk]
  simp only [rescaleReadout, Finset.univ_eq_empty, Finset.sum_empty, zero_add,
    mul_pow, ← Finset.mul_sum]
  change (d : ℝ)*k/N*firstEnergySum w + 0 + (N : ℝ)/k*(s^2*readoutEnergySum w) ≤ _
  unfold teacherCenterCost
  nlinarith

theorem exists_teacher_clone {d C N : ℕ} (hC : 0 < C) (hCN : C ≤ N)
    {s : ℝ} (hs : 0 ≤ s) (w : Weights d C 0) :
    ∃ v : Weights d N 0,
      (∀ x, networkOutput Real.tanh v x=s*networkOutput Real.tanh w x) ∧
      readoutL1 v=s*readoutL1 w ∧ weightedSquaredNorm v ≤ teacherCenterCost s w := by
  classical
  let k := N/C
  have hk : 0 < k := Nat.div_pos hCN hC
  have hsplit : N%C+C*k=N := Nat.mod_add_div N C
  have hmod : N%C<C := Nat.mod_lt _ hC
  have hbelow : C*k≤N := by omega
  have hCk : C≤C*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove : N≤2*C*k := by nlinarith
  let e : ((Fin C × Fin k) ⊕ Fin (N-C*k)) ≃ Fin N :=
    Fintype.equivOfCardEq (by simp only [Fintype.card_sum, Fintype.card_prod, Fintype.card_fin]; omega)
  refine ⟨clonedWeights e (rescaleReadout s w), ?_, ?_, clone_scaled_cost hC hk hbelow habove e s w⟩
  · intro x
    rw [networkOutput_cloned hk, rescaleReadout_output]
  · rw [readoutL1_cloned hk, readoutL1_rescale hs]

end NeuralGeneralization.BatchTwoShallow
