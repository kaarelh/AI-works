import NeuralGeneralization.BatchTwoOnlineReluTeacherCapacity

/-! Literal bounded-weight product estimate used by the online ReLU corollary. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem physical_relu_bounded_teacher_product {d C r : ℕ} (hC : 0<C)
    (w : Weights d C r) (hw : boundedWeights C w) :
    (physicalProduct hC relu_zeroLipschitz w)^2≤((d:ℝ)+1)*(C:ℝ)^(4*(r+2)-2) := by
  have hentry (i : WeightIndex d C r) : (w i)^2≤(C:ℝ)^2 := by
    simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg _) (hw i) 2
  have hfirst : (∑i,∑j,w (.inl (i,j))^2)≤((d:ℝ)+1)*(C:ℝ)^3 := by
    calc
      _ ≤ ∑_i:Fin C,∑_j:Fin (d+1),(C:ℝ)^2 :=
        Finset.sum_le_sum (fun i _=>Finset.sum_le_sum (fun j _=>hentry _))
      _ = _ := by simp; ring
  have hread : (∑i,w (.inr (.inr i))^2)≤(C:ℝ)^3 := by
    calc
      _ ≤ ∑_i:Fin C,(C:ℝ)^2 := Finset.sum_le_sum (fun i _=>hentry _)
      _ = _ := by simp; ring
  have hinter (s : Fin r) : (∑i,∑j,w (.inr (.inl (s,i,j)))^2)≤(C:ℝ)^4 := by
    calc
      _ ≤ ∑_i:Fin C,∑_j:Fin C,(C:ℝ)^2 :=
        Finset.sum_le_sum (fun i _=>Finset.sum_le_sum (fun j _=>hentry _))
      _ = _ := by simp; ring
  rw [physicalProduct_sq]
  calc
    _ ≤ (C:ℝ)^3*(((d:ℝ)+1)*(C:ℝ)^3)*∏_s:Fin r,(C:ℝ)^4 := by
      apply mul_le_mul
      · exact mul_le_mul hread hfirst (by positivity) (by positivity)
      · exact Finset.prod_le_prod (fun _ _=>by positivity) (fun s _=>hinter s)
      · positivity
      · positivity
    _ = _ := by
      simp only [Finset.prod_const,Finset.card_univ,Fintype.card_fin,←pow_mul]
      rw [show 4*(r+2)-2=6+4*r by omega,pow_add]
      ring

end NeuralGeneralization.BatchTwoActivation
