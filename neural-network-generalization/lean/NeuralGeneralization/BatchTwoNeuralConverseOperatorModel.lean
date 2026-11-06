import NeuralGeneralization.BatchTwoNeuralConverseSingleton
import NeuralGeneralization.BatchTwoMergingSharpBulk
import NeuralGeneralization.CylinderGeometry
import Mathlib.Analysis.InnerProductSpace.Adjoint

/-! The separate strict internal-operator-norm prior from the neural converse. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators RealInnerProductSpace
open ConcreteModel MeasureTheory ProbabilityTheory Set WithLp

lemma matrixOperator_norm_le_iff {m n : Type*} [Fintype m] [Fintype n]
    (W : m × n → ℝ) {B : ℝ} (hB : 0 ≤ B) :
    ‖coordinateMatrixOperator W‖ ≤ B ↔
      ∀ x : n → ℝ, (∑ i, (∑ j, W (i,j)*x j)^2) ≤ B^2*∑ j, x j^2 := by
  constructor
  · exact fun h x => coordinateMatrix_action_squared_le W B hB h x
  · intro h
    apply ContinuousLinearMap.opNorm_le_bound _ hB
    intro x
    apply (sq_le_sq₀ (norm_nonneg _) (mul_nonneg hB (norm_nonneg _))).mp
    simpa only [mul_pow,EuclideanSpace.real_norm_sq_eq,coordinateMatrixOperator,
      LinearMap.coe_toContinuousLinearMap',Matrix.toLpLin_apply,Matrix.mulVec,dotProduct]
      using h (ofLp x)

lemma matrixOperator_transpose_norm {m n : Type*} [Fintype m] [Fintype n]
    (W : m × n → ℝ) :
    ‖coordinateMatrixOperator (fun ji : n × m => W (ji.2,ji.1))‖ =
      ‖coordinateMatrixOperator W‖ := by
  have he : coordinateMatrixOperator (fun ji : n × m => W (ji.2,ji.1)) =
      ContinuousLinearMap.adjoint (coordinateMatrixOperator W) := by
    apply (ContinuousLinearMap.eq_adjoint_iff _ _).mpr
    intro x y
    conv_rhs => rw [real_inner_comm]
    rw [coordinateMatrixOperator_inner,coordinateMatrixOperator_inner]
    simp only [Fintype.sum_prod_type]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [he,LinearIsometryEquiv.norm_map]

lemma matrixOperator_norm_sq_le_frobenius {m n : Type*} [Fintype m] [Fintype n]
    (W : m × n → ℝ) :
    ‖coordinateMatrixOperator W‖^2 ≤ ∑ i, ∑ j, W (i,j)^2 := by
  have hF : 0 ≤ ∑ i, ∑ j, W (i,j)^2 := by positivity
  have hb : ‖coordinateMatrixOperator W‖ ≤ Real.sqrt (∑ i, ∑ j, W (i,j)^2) := by
    apply (matrixOperator_norm_le_iff W (Real.sqrt_nonneg _)).mpr
    intro x
    rw [Real.sq_sqrt hF,Finset.sum_mul]
    exact Finset.sum_le_sum fun i _ =>
      Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (fun j => W (i,j)) x
  exact (pow_le_pow_left₀ (norm_nonneg _) hb 2).trans_eq (Real.sq_sqrt hF)

def internalOperator {d N r : ℕ} (w : Weights d N r) (s : Fin r) :
    EuclideanSpace ℝ (Fin N) →L[ℝ] EuclideanSpace ℝ (Fin N) :=
  coordinateMatrixOperator (fun ij => w (Sum.inr (Sum.inl (s,ij.1,ij.2))))

/-- Strict Euclidean operator norm, as in the paper; no Frobenius restriction. -/
def operatorContractive {d N r : ℕ} (w : Weights d N r) : Prop :=
  ∀ s : Fin r, ‖internalOperator w s‖ < 1

lemma continuous_internalOperator {d N r : ℕ} (s : Fin r) :
    Continuous (fun w : Weights d N r => internalOperator w s) :=
  BatchTwoMerging.continuous_coordinateMatrixOperator.comp
    (continuous_pi fun ij => continuous_apply _)

def operatorSupport {d N r : ℕ} (U : ℝ) : Set (Weights d N r) :=
  {w | (∀ x : Cube d, (1:ℝ)/2 < |networkOutput Real.tanh w x| ∧
    |networkOutput Real.tanh w x| < U) ∧ operatorContractive w}

def operatorFunctionSupport {d N r : ℕ} (U : ℝ) (f : BooleanFunction d) :
    Set (Weights d N r) := operatorSupport U ∩ marginEvent Real.tanh (1/2) f

lemma isOpen_operatorContractive {d N r : ℕ} :
    IsOpen {w : Weights d N r | operatorContractive w} := by
  simp only [operatorContractive,setOf_forall]
  exact isOpen_iInter_of_finite fun s => isOpen_lt (continuous_internalOperator s).norm continuous_const

lemma isOpen_operatorSupport {d N r : ℕ} (U : ℝ) :
    IsOpen (operatorSupport (d := d) (N := N) (r := r) U) := by
  unfold operatorSupport
  simp only [setOf_and]
  apply IsOpen.inter _ isOpen_operatorContractive
  simp only [setOf_forall]
  exact isOpen_iInter_of_finite fun x =>
    (isOpen_lt continuous_const (continuous_networkOutput tanh_continuous x).abs).inter
      (isOpen_lt (continuous_networkOutput tanh_continuous x).abs continuous_const)

lemma isOpen_operatorFunctionSupport {d N r : ℕ} (U : ℝ) (f : BooleanFunction d) :
    IsOpen (operatorFunctionSupport (N := N) (r := r) U f) :=
  (isOpen_operatorSupport U).inter (isOpen_marginEvent tanh_continuous (1/2) f)

def operatorPrior {d N r : ℕ} (σ U : ℝ) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (operatorSupport U)

def operatorPosterior {d N r : ℕ} (σ U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d)) :
    Measure (Weights d N r) := cond (operatorPrior σ U) (signTraining f A)

lemma row_contraction_of_operator {N : ℕ} (W : Fin N → Fin N → ℝ)
    (a D : Fin N → ℝ) (hD : ∀ i, 0 ≤ D i ∧ D i ≤ 1)
    (hW : ‖coordinateMatrixOperator (fun ij => W ij.1 ij.2)‖ ≤ 1) :
    (∑ j, (∑ i, a i*D i*W i j)^2) ≤ ∑ i, (a i)^2 := by
  have hT : ‖coordinateMatrixOperator (fun ji => W ji.2 ji.1)‖ ≤ 1 := by
    rwa [matrixOperator_transpose_norm (fun ij : Fin N × Fin N => W ij.1 ij.2)]
  have hh := coordinateMatrix_action_squared_le (fun ji => W ji.2 ji.1) 1 (by norm_num) hT
    (fun i => a i*D i)
  simp only [one_pow,one_mul,mul_comm (W _ _)] at hh
  apply hh.trans
  apply Finset.sum_le_sum
  intro i _
  have hsq : (D i)^2 ≤ 1 := by nlinarith [(hD i).1,(hD i).2]
  simpa only [mul_pow,mul_one] using mul_le_mul_of_nonneg_left hsq (sq_nonneg (a i))

lemma pathRow_operator_bound {d N r : ℕ} (w : Weights d N r) (D : Slopes N r)
    (hD : D ∈ slopeCube N r)
    (hW : ∀ s, ‖internalOperator w s‖ ≤ 1) (ss : List (Fin r)) :
    (∑ i, (pathRow w D ss i)^2) ≤ ∑ i, w (Sum.inr (Sum.inr i))^2 := by
  induction ss with
  | nil => rfl
  | cons s ss ih =>
    exact (row_contraction_of_operator (fun i j => w (Sum.inr (Sum.inl (s,i,j))))
      (pathRow w D ss) (D s) (fun i => ⟨hD.1 s i,hD.2 s i⟩) (hW s)).trans ih

/-- Internal nonexpansiveness gives the paper's sharp gain bound H E_v. -/
theorem gainSq_operator_bound {d N r : ℕ} (w : Weights d N r)
    (hW : ∀ s, ‖internalOperator w s‖ ≤ 1) :
    gainSq w ≤ ((r:ℝ)+1)*readoutEnergy w := by
  unfold gainSq
  apply csSup_le ((slopeCube_nonempty N r).image _)
  rintro _ ⟨D,hD,rfl⟩
  unfold gainEnergy
  have hb := Finset.sum_le_sum (s := Finset.univ) (fun (j : Fin (r+1)) _ =>
    pathRow_operator_bound w D hD hW ((List.finRange r).drop j.val))
  have hm := mul_le_mul_of_nonneg_left hb (Nat.cast_nonneg N : (0:ℝ) ≤ N)
  simpa [readoutEnergy,mul_comm,mul_left_comm,mul_assoc] using hm

theorem operatorSupport_subset_gainSupport {d N r : ℕ} {Λ U : ℝ} (hΛ : 1 < Λ) :
    operatorSupport (d := d) (N := N) (r := r) U ⊆ gainSupport Λ U := by
  intro w hw
  refine ⟨hw.1,?_⟩
  have ho : networkOutput Real.tanh w (fun _ => false) ≠ 0 := by
    intro hz
    have hh := (hw.1 (fun _ => false)).1
    rw [hz,abs_zero] at hh
    linarith
  have hv := readoutEnergy_pos_of_output_ne_zero w _ ho
  have hg := gainSq_operator_bound w (fun s => (hw.2 s).le)
  have hH : 0 < ((r:ℝ)+1)*readoutEnergy w := by positivity
  have hsq : (1:ℝ) < Λ^2 := by nlinarith
  have hm := mul_lt_mul_of_pos_right hsq hH
  nlinarith

theorem operatorFunctionSupport_subset {d N r : ℕ} {Λ U : ℝ} (hΛ : 1 < Λ)
    (f : BooleanFunction d) :
    operatorFunctionSupport (N := N) (r := r) U f ⊆ functionSupport Λ U f :=
  fun _ hw => ⟨operatorSupport_subset_gainSupport hΛ hw.1,hw.2⟩

end
end NeuralGeneralization.BatchTwoNeuralConverse
