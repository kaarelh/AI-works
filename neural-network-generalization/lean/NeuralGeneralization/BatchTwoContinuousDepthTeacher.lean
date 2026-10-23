import NeuralGeneralization.BatchTwoContinuousModel
import NeuralGeneralization.Activation
import Mathlib.Analysis.SpecialFunctions.Artanh
import Mathlib.Data.Fin.VecNotation

/-! The explicit width-three tanh teacher from the continuous depth lower
bound. Every layer and the constant rail use literal network coefficients. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

def expandingMap (t : ℝ) : ℝ :=
  2*(Real.tanh (10*(t+1/2))-Real.tanh (10*(t-1/2)))-1

def railConstant : ℝ := Real.artanh (1/2)

theorem railConstant_bounds : 0 ≤ railConstant ∧ railConstant ≤ 1 := by
  constructor
  · exact Real.artanh_nonneg (by norm_num)
  · have hl := Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 3)
    have ha : railConstant = (1/2 : ℝ)*Real.log 3 := by
      rw [railConstant, Real.artanh_eq_half_log (by constructor <;> norm_num)]
      norm_num
    rw [ha]
    linarith

theorem tanh_railConstant : Real.tanh railConstant = 1/2 :=
  Real.tanh_artanh (by constructor <;> norm_num)

def firstMatrix : Fin 3 → Fin 3 → ℝ :=
  ![![5,10,0], ![-5,10,0], ![railConstant,0,0]]

def iterationMatrix : Fin 3 → Fin 3 → ℝ :=
  ![![20,-20,-10], ![20,-20,-30], ![0,0,2*railConstant]]

def readoutVector : Fin 3 → ℝ := ![2,-2,-2]

def teacherWeights (k : ℕ) : Weights 2 3 k
  | Sum.inl (i,j) => firstMatrix i j
  | Sum.inr (Sum.inl (_,i,j)) => iterationMatrix i j
  | Sum.inr (Sum.inr i) => readoutVector i

def hiddenRepresentation (t : ℝ) : Fin 3 → ℝ :=
  ![Real.tanh (10*(t+1/2)), Real.tanh (10*(t-1/2)), (1/2 : ℝ)]

theorem teacher_firstHidden (k : ℕ) (x : RealInput 2) :
    BatchTwoContinuous.firstHidden Real.tanh (teacherWeights k) x = hiddenRepresentation (x 0) := by
  funext i
  fin_cases i <;>
    simp [BatchTwoContinuous.firstHidden,teacherWeights,firstMatrix,augmentedInput,
      Fin.sum_univ_succ,hiddenRepresentation,tanh_railConstant]
    <;> congr 1 <;> ring

theorem teacher_hiddenStep {k : ℕ} (s : Fin k) (t : ℝ) :
    hiddenStep Real.tanh (teacherWeights k) (hiddenRepresentation t) s =
      hiddenRepresentation (expandingMap t) := by
  funext i
  fin_cases i <;>
    simp [hiddenStep,teacherWeights,iterationMatrix,hiddenRepresentation,
      Fin.sum_univ_succ,expandingMap,tanh_railConstant]
    <;> congr 1 <;> ring
  exact tanh_railConstant

theorem teacher_hiddenFold {k : ℕ} (ss : List (Fin k)) (t : ℝ) :
    ss.foldl (hiddenStep Real.tanh (teacherWeights k)) (hiddenRepresentation t) =
      hiddenRepresentation (expandingMap^[ss.length] t) := by
  induction ss generalizing t with
  | nil => simp
  | cons s ss ih =>
    rw [List.foldl_cons,teacher_hiddenStep,ih]
    simp only [List.length_cons,Function.iterate_succ_apply]

theorem teacher_readout (t : ℝ) :
    (∑ i, readoutVector i*hiddenRepresentation t i) = expandingMap t := by
  simp [readoutVector,hiddenRepresentation,expandingMap,Fin.sum_univ_succ]
  ring

/-- Depth k+2, hence r+1 at k=r-1. The equality holds on all real inputs,
not only on the unit circle or the eventual Cantor support. -/
theorem teacher_output (k : ℕ) (x : RealInput 2) :
    output Real.tanh (teacherWeights k) x = expandingMap^[k+1] (x 0) := by
  unfold output BatchTwoContinuous.finalHidden
  rw [teacher_firstHidden,teacher_hiddenFold]
  simp only [List.length_finRange]
  change (∑ i, readoutVector i*hiddenRepresentation (expandingMap^[k] (x 0)) i) = _
  rw [teacher_readout,Function.iterate_succ_apply']

theorem teacher_weights_bounded (k : ℕ) : boundedWeights 30 (teacherWeights k) := by
  have hr := railConstant_bounds
  intro z
  rcases z with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · fin_cases i <;> fin_cases j <;>
      norm_num [teacherWeights,firstMatrix] <;> rw [abs_of_nonneg hr.1] <;> linarith
  · fin_cases i <;> fin_cases j <;>
      norm_num [teacherWeights,iterationMatrix] <;>
      rw [abs_of_nonneg hr.1] <;> linarith
  · fin_cases i <;> norm_num [teacherWeights,readoutVector]

theorem continuous_expandingMap : Continuous expandingMap := by
  have ht : Continuous Real.tanh := tanh_lipschitzWith.continuous
  unfold expandingMap
  fun_prop

theorem continuous_target (r : ℕ) :
    Continuous (fun x : RealInput 2 => expandingMap^[r] (x 0)) :=
  (continuous_expandingMap.iterate r).comp (continuous_apply 0)

end NeuralGeneralization.BatchTwoContinuousDepthLower
