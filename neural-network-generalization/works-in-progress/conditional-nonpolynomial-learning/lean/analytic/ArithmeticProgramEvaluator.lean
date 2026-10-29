import ArithmeticProgramPrecision
import GridCircuitComposition

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
namespace ArithmeticProgram

 def mesh {d o : ℕ} (P : ArithmeticProgram d o) (B U : ℕ) (ε : ℝ) : ℕ :=
  ⌈1/P.tolerance B U ε⌉₊+1

 theorem mesh_pos {d o : ℕ} (P : ArithmeticProgram d o) (B U : ℕ) (ε : ℝ) :
    0<P.mesh B U ε := by unfold mesh;omega

 theorem mesh_precision {d o : ℕ} (P : ArithmeticProgram d o) (B U : ℕ)
    {ε : ℝ} (hε : 0<ε) : 1/(2*(P.mesh B U ε:ℝ))≤P.tolerance B U ε := by
  have ht:=P.tolerance_pos B U hε
  have hceil : 1/P.tolerance B U ε≤(P.mesh B U ε:ℝ) := by
    exact (Nat.le_ceil _).trans (by unfold mesh;push_cast;linarith)
  have hm : 1≤(P.mesh B U ε:ℝ)*P.tolerance B U ε := (div_le_iff₀ ht).mp hceil
  have hQ : (0:ℝ)<P.mesh B U ε := Nat.cast_pos.mpr (P.mesh_pos B U ε)
  apply (div_le_iff₀ (by positivity : 0<2*(P.mesh B U ε:ℝ))).mpr
  nlinarith

 theorem mesh_upper {d o : ℕ} (P : ArithmeticProgram d o) (B U : ℕ)
    {ε : ℝ} (hε : 0<ε) : (P.mesh B U ε:ℝ)<1/P.tolerance B U ε+2 := by
  have ht:=P.tolerance_pos B U hε
  have hceil:=Nat.ceil_lt_add_one (show 0≤1/P.tolerance B U ε from div_nonneg (by norm_num) ht.le)
  unfold mesh
  push_cast
  linarith

/-- Preferred real semantics of the compiled program: coordinate permutations
from arbitrary finite enumeration are part of the definition, not silently
identified with the identity permutation. -/
 def realMap {ι κ : Type*} [Fintype ι] [Fintype κ]
    (P : ArithmeticProgram (Fintype.card ι) (Fintype.card κ)) (x : EuclideanSpace ℝ ι) :
    EuclideanSpace ℝ κ := WithLp.toLp 2
      (fun j=>P.eval (realCoordinates x) (Fintype.equivFin κ j))

 theorem finite_evaluator {ι κ : Type*} [Fintype ι] [Fintype κ]
    (P : ArithmeticProgram (Fintype.card ι) (Fintype.card κ)) (B U : ℕ)
    (hP : P.bounded B) {ε : ℝ} (hε : 0<ε) (hεone : ε≤1) :
    let Q:=P.mesh B U ε
    let V:=P.outputRange B U
    ∀x:EuclideanSpace ℝ ι,(∀i,|x i|≤(U:ℝ))→
      ∃b:κ→ScalarCode Q V,
        (P.compile Q B U).eval (encodeCoordinateState Q U (fun i=>scalarEncode Q U (x i)))=
          encodeCoordinateState Q V b ∧
        ‖P.realMap x-decodeCoordinates Q V b‖≤((Fintype.card κ:ℝ)+1)*ε := by
  intro Q V x hx
  let a:=P.gridEval Q B U (fun i=>scalarEncode Q U (realCoordinates x i))
  refine ⟨(fun j=>a (Fintype.equivFin κ j)),?_,?_⟩
  · change (P.compile Q B U).eval (oneHotState _)=oneHotState _
    rw [P.compile_eval]
    congr 1
    funext j
    simp only [coordinateCodes,Equiv.apply_symm_apply]
    rfl
  · have he:=P.error_le_of_precision Q B U hε hεone (by positivity : 0≤1/(2*(Q:ℝ))) le_rfl
      (P.mesh_precision B U hε)
    have ha:=P.accuracy Q B U (P.mesh_pos B U ε) hP (realCoordinates x) (fun i=>hx _)
      (fun i=>scalarEncode Q U (realCoordinates x i)) (by positivity : 0≤1/(2*(Q:ℝ))) le_rfl
      (fun i=>scalarEncode_error Q U (P.mesh_pos B U ε) _ (hx _))
    apply euclidean_norm_of_coordinate_bounds _ hε.le
    intro j
    exact (ha (Fintype.equivFin κ j)).trans he

end ArithmeticProgram
#print axioms ArithmeticProgram.finite_evaluator
end ConditionalNonpolynomial.AnalyticLookup
