import CanonicalProgramBudgets
import FixedAmbientPadding
import NormalizedResidualRecurrence

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

abbrev CanonicalAmbient {d : ℕ} (states : ℕ → CanonicalProgramState d) (H : ℕ) :=
  PiLp 2 (fun j:Fin (H+1) => EuclideanSpace ℝ (states j).Index)

structure FiniteCanonicalDynamics {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (S : Finset (Cube d))
    (states : ℕ → CanonicalProgramState d) where
  layer : (j : Fin H) → CanonicalLayerModel (J:=(states (j+1)).Index)
    (fun s:S => (states j).feature s) (criticalLayerCost P j)
  evaluate : ∀j:Fin H,∀x,(states (j+1)).feature x=(layer j).value ((states j).feature x)

theorem finiteCanonicalDynamics_exists {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (S : Finset (Cube d))
    (states : ℕ → CanonicalProgramState d)
    (hstep : ∀j<H,CanonicalProgramStep P S j (states j) (states (j+1))) :
    Nonempty (FiniteCanonicalDynamics P S states) := by
  classical
  choose layer hlayer using fun j:Fin H => (hstep j j.isLt).layerModel
  exact ⟨⟨layer,hlayer⟩⟩

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {f : BooleanFunction d} {P : ControlledMarginPath d H 1 f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

def linear (M : FiniteCanonicalDynamics P S states) (j : ℕ) :
    CanonicalAmbient states H →L[ℝ] CanonicalAmbient states H :=
  if hj:j<H then blockLiftLinear
    (fun k:Fin (H+1) => EuclideanSpace ℝ (states k).Index)
    (i := (⟨j,hj⟩ : Fin H).castSucc) (j := (⟨j,hj⟩ : Fin H).succ)
    (M.layer ⟨j,hj⟩).linear
  else 0

def residual (M : FiniteCanonicalDynamics P S states) (η : ℝ) (j : ℕ) :
    CanonicalAmbient states H → CanonicalAmbient states H :=
  if hj:j<H then blockLiftMap
    (fun k:Fin (H+1) => EuclideanSpace ℝ (states k).Index)
    (i := (⟨j,hj⟩ : Fin H).castSucc) (j := (⟨j,hj⟩ : Fin H).succ)
    ((M.layer ⟨j,hj⟩).clippedResidual (canonicalRadius P η j))
  else fun _ => 0

def state (_M : FiniteCanonicalDynamics P S states) (x : Cube d) (j : ℕ) :
    CanonicalAmbient states H :=
  if hj:j≤H then blockEmbedding
    (fun k:Fin (H+1) => EuclideanSpace ℝ (states k).Index)
    ⟨j,Nat.lt_succ_of_le hj⟩ ((states j).feature x)
  else 0

def linearGain (_M : FiniteCanonicalDynamics P S states) (j : ℕ) : ℝ :=
  if j<H then 1+Real.sqrt (2*criticalLayerCost P j) else 1

def nonlinearGain (_M : FiniteCanonicalDynamics P S states) (η : ℝ) (j : ℕ) : ℝ :=
  if j<H then 224*((canonicalRadius P η j)^2+Real.sqrt (criticalLayerCost P j)) else 0

def residualRange (_M : FiniteCanonicalDynamics P S states) (η : ℝ) (j : ℕ) : ℝ :=
  if j<H then 112*((canonicalRadius P η j)^2+Real.sqrt (criticalLayerCost P j))*canonicalRadius P η j
  else 0

theorem linearGain_one_le (M : FiniteCanonicalDynamics P S states) (j : ℕ) :
    1≤M.linearGain j := by
  unfold linearGain
  split_ifs <;> linarith [Real.sqrt_nonneg (2*criticalLayerCost P j)]

theorem nonlinearGain_nonneg (M : FiniteCanonicalDynamics P S states) (η : ℝ) (j : ℕ) :
    0≤M.nonlinearGain η j := by
  unfold nonlinearGain
  split_ifs <;> positivity

theorem linear_norm_le (M : FiniteCanonicalDynamics P S states) (j : ℕ) :
    ‖M.linear j‖≤M.linearGain j := by
  unfold linear linearGain
  split_ifs with hj
  · exact (blockLiftLinear_opNorm _ _).trans (M.layer ⟨j,hj⟩).linear_norm_le
  · simp

theorem residual_lipschitz (M : FiniteCanonicalDynamics P S states)
    {η : ℝ} (hη : 0<η) (j : ℕ) (x y : CanonicalAmbient states H) :
    ‖M.residual η j x-M.residual η j y‖≤M.nonlinearGain η j*‖x-y‖ := by
  unfold residual nonlinearGain
  split_ifs with hj
  · simp only [blockLiftMap,← map_sub,LinearIsometry.norm_map]
    apply ((M.layer ⟨j,hj⟩).clippedResidual_lipschitz
      (canonicalRadius_pos P hη j) _ _).trans
    have hp := blockProjection_norm
      (fun k:Fin (H+1) => EuclideanSpace ℝ (states k).Index)
      (⟨j,hj⟩ : Fin H).castSucc (x-y)
    rw [map_sub] at hp
    exact mul_le_mul_of_nonneg_left hp (by positivity)
  · simp

theorem residual_range (M : FiniteCanonicalDynamics P S states)
    {η : ℝ} (hη : 0<η) (j : ℕ) (x : CanonicalAmbient states H) :
    ‖M.residual η j x‖≤M.residualRange η j := by
  unfold residual residualRange
  split_ifs with hj
  · exact blockLiftMap_range _ _ _
      ((M.layer ⟨j,hj⟩).clippedResidual_range (canonicalRadius_pos P hη j)) x
  · simp

theorem recursion (M : FiniteCanonicalDynamics P S states) {η : ℝ} (hη : 0<η)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η)
    (x : Cube d) (j : ℕ) :
    M.state x (j+1)=M.linear j (M.state x j)+M.residual η j (M.state x j) := by
  by_cases hj:j<H
  · have hj0 : j≤H := Nat.le_of_lt hj
    have hj1 : j+1≤H := by omega
    have he := (M.layer ⟨j,hj⟩).decomposition_on_ball (canonicalRadius_pos P hη j)
      ((states j).feature x) (query_norm_le_canonicalRadius P η j (states j) S x (hquery j hj0 x))
    rw [← M.evaluate ⟨j,hj⟩ x] at he
    have hh := blockLift_recursion
      (fun k:Fin (H+1) => EuclideanSpace ℝ (states k).Index)
      (i := (⟨j,hj⟩ : Fin H).castSucc) (j := (⟨j,hj⟩ : Fin H).succ)
      (M.layer ⟨j,hj⟩).linear ((M.layer ⟨j,hj⟩).clippedResidual (canonicalRadius P η j))
      ((states j).feature x) ((states (j+1)).feature x) he
    simpa only [state,linear,residual,dif_pos hj0,dif_pos hj1,dif_pos hj,
      Fin.succ_mk,Fin.castSucc_mk] using hh
  · have hnext : ¬j+1≤H := by omega
    simp only [state,linear,residual,dif_neg hj,dif_neg hnext,ContinuousLinearMap.zero_apply,
      add_zero]

theorem nonlinear_sum (M : FiniteCanonicalDynamics P S states) (η : ℝ) :
    (∑j∈Finset.range H,M.nonlinearGain η j)=canonicalNonlinearBudget P η := by
  unfold canonicalNonlinearBudget
  rw [Fin.sum_univ_eq_sum_range (fun j => 224*((canonicalRadius P η j)^2+
    Real.sqrt (criticalLayerCost P j))) H]
  apply Finset.sum_congr rfl
  intro j hj
  simp only [nonlinearGain,if_pos (Finset.mem_range.mp hj)]

theorem ambient_dimension_le (M : FiniteCanonicalDynamics P S states)
    (hdim : ∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) :
    Module.finrank ℝ (CanonicalAmbient states H)≤(H+1)*(d+1+H*(S.card+1)) := by
  apply (blockAmbient_finrank_le
    (fun k:Fin (H+1) => EuclideanSpace ℝ (states k).Index)
    (D := d+1+H*(S.card+1)) ?_).trans_eq ?_
  · intro j
    have hj : (j:ℕ)≤H := by omega
    have hh := hdim j hj
    have hm := Nat.mul_le_mul_right (S.card+1) hj
    simpa only [CanonicalProgramState.dimension,finrank_euclideanSpace] using
      hh.trans (by omega)
  · simp only [Fintype.card_fin]

end FiniteCanonicalDynamics
#print axioms FiniteCanonicalDynamics.recursion
#print axioms FiniteCanonicalDynamics.ambient_dimension_le
end ConditionalNonpolynomial.Analytic
