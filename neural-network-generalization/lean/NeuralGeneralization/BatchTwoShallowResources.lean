import NeuralGeneralization.BatchTwoShallowTarget

/-! Literal teacher-resource consequences of the shallow theorem. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel

theorem teacherCenterCost_le_energy {d C : ℕ} {s : ℝ} (hs : 1 ≤ s)
    (w : Weights d C 0) :
    teacherCenterCost s w ≤ 2*s^2*weightedSquaredNorm w := by
  have hf : 0 ≤ firstEnergySum w := by unfold firstEnergySum rowEnergy; positivity
  have hinput : teacherInputCost w ≤ 2*((d : ℝ)/C*firstEnergySum w) := by
    unfold teacherInputCost
    have h := mul_le_mul_of_nonneg_left (min_le_right (maxRowEnergy w) ((2/(C : ℝ))*firstEnergySum w))
      (Nat.cast_nonneg d : (0 : ℝ) ≤ d)
    simpa only [div_eq_mul_inv, mul_assoc, mul_left_comm, mul_comm] using h
  have hi0 : 0 ≤ (d : ℝ)/C*firstEnergySum w := by positivity
  have hs2 : 1 ≤ s^2 := by nlinarith
  have hmul := mul_le_mul_of_nonneg_right hs2 hi0
  unfold teacherCenterCost weightedSquaredNorm
  simp only [Finset.univ_eq_empty, Finset.sum_empty, add_zero]
  change teacherInputCost w+2*s^2*(C : ℝ)*readoutEnergySum w ≤
    2*s^2*((d : ℝ)/C*firstEnergySum w+(C : ℝ)*readoutEnergySum w)
  nlinarith

theorem targetCost_le_energy {d C : ℕ} {s : ℝ} (hs : 1 ≤ s)
    (w : Weights d C 0) :
    targetCost s w ≤ 2*s^2*weightedSquaredNorm w+((d : ℝ)+2)*
      Real.log (Real.exp 1*Real.sqrt (2*Real.pi)/(2*targetRadius s w)) :=
  add_le_add (teacherCenterCost_le_energy hs w) le_rfl

theorem rowEnergy_le_bound {d C : ℕ} (w : Weights d C 0) {W : ℝ}
    (hw : ∀ i j, |w (Sum.inl (i,j))| ≤ W) (i : Fin C) :
    rowEnergy w i ≤ (d+1 : ℝ)*W^2 := by
  calc
    _ ≤ ∑ _j : Fin (d+1), W^2 := by
      apply Finset.sum_le_sum
      intro j _
      have h := (sq_le_sq₀ (abs_nonneg _) ((abs_nonneg _).trans (hw i j))).mpr (hw i j)
      simpa only [sq_abs] using h
    _ = _ := by simp

theorem maxRowEnergy_le_bound {d C : ℕ} (w : Weights d C 0) {W : ℝ}
    (hw : ∀ i j, |w (Sum.inl (i,j))| ≤ W) :
    maxRowEnergy w ≤ (d+1 : ℝ)*W^2 := by
  have h : (Finset.univ.sup (fun i : Fin C =>
      (⟨rowEnergy w i, by unfold rowEnergy; positivity⟩ : ℝ≥0))) ≤
      ⟨(d+1 : ℝ)*W^2, by positivity⟩ := by
    apply Finset.sup_le
    intro i _
    exact rowEnergy_le_bound w hw i
  exact_mod_cast h

theorem readoutEnergySum_le_bound {d C : ℕ} (w : Weights d C 0) {V : ℝ}
    (hv : ∀ i, |w (Sum.inr (Sum.inr i))| ≤ V) :
    readoutEnergySum w ≤ (C : ℝ)*V^2 := by
  calc
    _ ≤ ∑ _i : Fin C, V^2 := by
      apply Finset.sum_le_sum
      intro i _
      have h := sq_le_sq₀ (abs_nonneg (w (Sum.inr (Sum.inr i))))
        ((abs_nonneg _).trans (hv i)) |>.mpr (hv i)
      simpa only [sq_abs] using h
    _ = _ := by simp

theorem readoutL1_le_bound {d C : ℕ} (w : Weights d C 0) {V : ℝ}
    (hv : ∀ i, |w (Sum.inr (Sum.inr i))| ≤ V) : readoutL1 w ≤ (C : ℝ)*V := by
  calc
    _ ≤ ∑ _i : Fin C, V := Finset.sum_le_sum (fun i _ => hv i)
    _ = _ := by simp

theorem targetCost_le_width_resources {d C : ℕ} {s W V : ℝ}
    (hs : 0 ≤ s) (hV : 0 ≤ V) (w : Weights d C 0)
    (hw : ∀ i j, |w (Sum.inl (i,j))| ≤ W)
    (hv : ∀ i, |w (Sum.inr (Sum.inr i))| ≤ V) :
    targetCost s w ≤ (d : ℝ)*(d+1)*W^2+2*s^2*C^2*V^2+((d : ℝ)+2)*
      Real.log (2*Real.exp 1*Real.sqrt (2*Real.pi)*
        (1+s*C*V*(d+1)/Real.sqrt d)) := by
  have hrow := maxRowEnergy_le_bound w hw
  have hout := readoutEnergySum_le_bound w hv
  have hL := readoutL1_le_bound w hv
  have hinput : teacherInputCost w ≤ (d : ℝ)*(d+1)*W^2 := by
    apply (mul_le_mul_of_nonneg_left (min_le_left _ _) (Nat.cast_nonneg d)).trans
    nlinarith [mul_le_mul_of_nonneg_left hrow (Nat.cast_nonneg d)]
  have hcenter : teacherCenterCost s w ≤ (d : ℝ)*(d+1)*W^2+2*s^2*C^2*V^2 := by
    have h := mul_le_mul_of_nonneg_left hout (show 0 ≤ 2*s^2*(C : ℝ) by positivity)
    unfold teacherCenterCost
    nlinarith
  have hL0 : 0 ≤ readoutL1 w := Finset.sum_nonneg fun _ _ => abs_nonneg _
  have harg0 : 0 < 1+s*readoutL1 w*(d+1)/Real.sqrt d := by positivity
  have harg : 1+s*readoutL1 w*(d+1)/Real.sqrt d ≤ 1+s*C*V*(d+1)/Real.sqrt d := by
    have h := mul_le_mul_of_nonneg_left hL (show 0 ≤ s*((d : ℝ)+1)/Real.sqrt d by positivity)
    simp only [div_eq_mul_inv] at h ⊢
    nlinarith
  have he : Real.exp 1*Real.sqrt (2*Real.pi)/(2*targetRadius s w) =
      2*Real.exp 1*Real.sqrt (2*Real.pi)*(1+s*readoutL1 w*(d+1)/Real.sqrt d) := by
    unfold targetRadius
    field_simp
    <;> ring
  unfold targetCost
  rw [he]
  apply add_le_add hcenter
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  apply Real.log_le_log (by positivity)
  exact mul_le_mul_of_nonneg_left harg (by positivity)

end NeuralGeneralization.BatchTwoShallow
