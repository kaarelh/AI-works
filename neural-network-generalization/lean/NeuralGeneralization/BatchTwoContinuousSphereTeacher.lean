import NeuralGeneralization.BatchTwoContinuousSphereLaw
import NeuralGeneralization.BatchTwoContinuousStatements

/-! The literal width-one teacher and compact unit-ball input domain. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousSphere
open ConcreteModel BatchTwoContinuous GaussianConeRadial

/-- One hidden tanh unit, zero bias, first coordinate weight one, readout one. -/
def scoreTeacher (n : ℕ) : Weights (n+1) 1 0
  | .inl (_, j) => if j = (0 : Fin (n+1)).succ then 1 else 0
  | .inr (.inl (s, _)) => Fin.elim0 s
  | .inr (.inr _) => 1

theorem scoreTeacher_bounded (n : ℕ) : boundedWeights 1 (scoreTeacher n) := by
  intro i
  rcases i with ij | (sij | j)
  · simp only [scoreTeacher]
    split_ifs <;> norm_num
  · exact Fin.elim0 sij.1
  · norm_num [scoreTeacher]

theorem scoreTeacher_output (n : ℕ) (x : RealInput (n+1)) :
    BatchTwoContinuous.output Real.tanh (scoreTeacher n) x = Real.tanh (x 0) := by
  simp only [BatchTwoContinuous.output, BatchTwoContinuous.finalHidden,
    BatchTwoContinuous.firstHidden, scoreTeacher, List.finRange_zero, List.foldl_nil,
    Fin.sum_univ_one, one_mul, ite_mul, zero_mul, Finset.sum_ite_eq', Finset.mem_univ, if_true]
  rfl

def inputBall (d : ℕ) : Set (RealInput d) := {x | squaredRadius x ≤ 1}

theorem inputBall_admissible (d : ℕ) : admissibleDomain (inputBall d) := by
  refine ⟨⟨0, by simp [inputBall, squaredRadius]⟩, ?_, fun x hx => hx⟩
  have hc : IsClosed (inputBall d) := isClosed_le (by unfold squaredRadius; fun_prop) continuous_const
  apply isCompact_Icc.of_isClosed_subset hc
  intro x hx
  constructor <;> intro i
  · have hi : (x i)^2 ≤ 1 := (Finset.single_le_sum
      (fun j _ => sq_nonneg (x j)) (Finset.mem_univ i)).trans hx
    change (-1 : ℝ) ≤ x i
    nlinarith
  · have hi : (x i)^2 ≤ 1 := (Finset.single_le_sum
      (fun j _ => sq_nonneg (x j)) (Finset.mem_univ i)).trans hx
    change x i ≤ (1 : ℝ)
    nlinarith

theorem uniformSphere_inputBall (n : ℕ) : uniformSphere (n+1) (inputBall (n+1))ᶜ = 0 := by
  have h := (uniformSphere_on_sphere n).mono (fun x hx => le_of_eq hx)
  exact (ae_iff).mp h

end NeuralGeneralization.BatchTwoContinuousSphere
