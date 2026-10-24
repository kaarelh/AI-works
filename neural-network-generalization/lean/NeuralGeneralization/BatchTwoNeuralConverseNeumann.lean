import NeuralGeneralization.BatchTwoNeuralConverseModel
import Mathlib.Analysis.SpecificLimits.Normed
import Mathlib.Analysis.Normed.Group.InfiniteSum

/-! A quantitative finite-dimensional Neumann inverse in the actual l1 norm. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
open scoped BigOperators
open Classical
variable {I : Type*} [Fintype I]

def vectorL1 (v : I → ℝ) : ℝ := ∑ i, |v i|
def applyMatrix (A : I → I → ℝ) (v : I → ℝ) (i : I) : ℝ := ∑ j, A i j*v j

theorem vectorL1_nonneg (v : I → ℝ) : 0 ≤ vectorL1 v := Finset.sum_nonneg (fun _ _ => abs_nonneg _)

theorem abs_le_vectorL1 (v : I → ℝ) (i : I) : |v i| ≤ vectorL1 v := by
  unfold vectorL1
  exact Finset.single_le_sum (f := fun j => |v j|) (fun _ _ => abs_nonneg _) (Finset.mem_univ i)

theorem vectorL1_matrix_le (A : I → I → ℝ) (v : I → ℝ) {a : ℝ}
    (hA : ∀ j, (∑ i, |A i j|) ≤ a) : vectorL1 (applyMatrix A v) ≤ a*vectorL1 v := by
  unfold vectorL1 applyMatrix
  calc
    _ ≤ ∑ i, ∑ j, |A i j*v j| := Finset.sum_le_sum (fun i _ => Finset.abs_sum_le_sum_abs _ _)
    _ = ∑ j, (∑ i, |A i j|)*|v j| := by
      simp only [abs_mul]
      rw [Finset.sum_comm]
      simp only [Finset.sum_mul]
    _ ≤ ∑ j, a*|v j| := Finset.sum_le_sum (fun j _ => mul_le_mul_of_nonneg_right (hA j) (abs_nonneg _))
    _ = _ := (Finset.mul_sum _ _ _).symm

def neumannTerm (A : I → I → ℝ) (b : I → ℝ) : ℕ → I → ℝ
  | 0 => b
  | n+1 => applyMatrix A (neumannTerm A b n)

theorem neumannTerm_l1 (A : I → I → ℝ) (b : I → ℝ)
    (hA : ∀ j, (∑ i, |A i j|) ≤ 1/2) (n : ℕ) :
    vectorL1 (neumannTerm A b n) ≤ (1/2 : ℝ)^n*vectorL1 b := by
  induction n with
  | zero => simp [neumannTerm]
  | succ n ih =>
      have hm := vectorL1_matrix_le A (neumannTerm A b n) hA
      change vectorL1 (applyMatrix A (neumannTerm A b n)) ≤ _
      calc
        _ ≤ (1/2 : ℝ)*vectorL1 (neumannTerm A b n) := hm
        _ ≤ (1/2 : ℝ)*((1/2 : ℝ)^n*vectorL1 b) := mul_le_mul_of_nonneg_left ih (by norm_num)
        _ = _ := by rw [pow_succ]; ring

theorem neumannTerm_summable (A : I → I → ℝ) (b : I → ℝ)
    (hA : ∀ j, (∑ i, |A i j|) ≤ 1/2) (i : I) :
    Summable (fun n => neumannTerm A b n i) := by
  have hg : Summable (fun n : ℕ => (1/2 : ℝ)^n*vectorL1 b) :=
    (summable_geometric_of_norm_lt_one (by norm_num : ‖(1/2 : ℝ)‖ < 1)).mul_right _
  apply hg.of_norm_bounded
  intro n
  rw [Real.norm_eq_abs]
  exact (abs_le_vectorL1 _ i).trans (neumannTerm_l1 A b hA n)

theorem exists_neumann_solution (A : I → I → ℝ) (b : I → ℝ)
    (hA : ∀ j, (∑ i, |A i j|) ≤ 1/2) :
    ∃ v : I → ℝ, (∀ i, v i = b i+applyMatrix A v i) ∧ vectorL1 v ≤ 2*vectorL1 b := by
  let v : I → ℝ := fun i => ∑' n, neumannTerm A b n i
  have hs (i : I) := neumannTerm_summable A b hA i
  refine ⟨v, ?_, ?_⟩
  · intro i
    have hshift := (hs i).sum_add_tsum_nat_add 1
    simp only [Finset.sum_range_one, neumannTerm] at hshift
    change (∑' n, neumannTerm A b n i) = b i+applyMatrix A v i
    rw [← hshift]
    congr 1
    unfold applyMatrix v
    simp_rw [← tsum_mul_left]
    exact Summable.tsum_finsetSum (fun j _ => (hs j).mul_left (A i j))
  · have hl1sum : Summable (fun n => vectorL1 (neumannTerm A b n)) := by
      unfold vectorL1
      exact (hasSum_sum (fun i (_ : i ∈ Finset.univ) => (hs i).abs.hasSum)).summable
    calc
      vectorL1 v ≤ ∑ i, ∑' n, |neumannTerm A b n i| := by
        apply Finset.sum_le_sum
        intro i _
        have hn : Summable (fun n => ‖neumannTerm A b n i‖) := by
          simpa only [Real.norm_eq_abs] using (hs i).abs
        simpa only [Real.norm_eq_abs] using norm_tsum_le_tsum_norm hn
      _ = ∑' n, vectorL1 (neumannTerm A b n) :=
        (Summable.tsum_finsetSum (fun i _ => (hs i).abs)).symm
      _ ≤ ∑' n, (1/2 : ℝ)^n*vectorL1 b :=
        hl1sum.tsum_le_tsum (neumannTerm_l1 A b hA)
          ((summable_geometric_of_norm_lt_one (by norm_num : ‖(1/2 : ℝ)‖ < 1)).mul_right _)
      _ = 2*vectorL1 b := by
        rw [tsum_mul_right, tsum_geometric_of_norm_lt_one (by norm_num : ‖(1/2 : ℝ)‖ < 1)]
        norm_num

end
end NeuralGeneralization.BatchTwoNeuralConverse
