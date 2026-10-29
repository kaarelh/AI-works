import CanonicalResidualExistence
import ArithmeticProgramEvaluator
import ResidualProgramResources

noncomputable section
set_option maxHeartbeats 500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

abbrev CanonicalAmbientIndex {d : ℕ} (states : ℕ → CanonicalProgramState d) (H : ℕ) :=
  Σj:Fin (H+1),(states j).Index

def canonicalAmbientCurry {d : ℕ} (states : ℕ → CanonicalProgramState d) (H : ℕ) :
    EuclideanSpace ℝ (CanonicalAmbientIndex states H) ≃ₗᵢ[ℝ] CanonicalAmbient states H :=
  LinearIsometryEquiv.piLpCurry ℝ 2 (fun (j:Fin (H+1)) (_:(states j).Index)=>ℝ)

lemma coordinateIso_encode {I : Type*} [Fintype I] (x : EuclideanSpace ℝ I) :
    coordinateIso I (WithLp.toLp 2 (realCoordinates (fun i=>x i)))=x := by
  ext i
  change x ((Fintype.equivFin I).symm ((Fintype.equivFin I) i))=x i
  rw [Equiv.symm_apply_apply]

lemma coordinateIso_program {I J : Type*} [Fintype I] [Fintype J]
    (A : ArithmeticProgram (Fintype.card I) (Fintype.card J)) (x : EuclideanSpace ℝ I) :
    coordinateIso J (WithLp.toLp 2 (A.eval (realCoordinates (fun i=>x i))))=A.realMap x := rfl

lemma canonicalAmbientIso_encode {d : ℕ} (states : ℕ → CanonicalProgramState d) (H : ℕ)
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states H)) :
    canonicalAmbientIso states H (WithLp.toLp 2 (realCoordinates (fun i=>x i)))=canonicalAmbientCurry states H x := by
  change canonicalAmbientCurry states H (coordinateIso _ _)=_
  rw [coordinateIso_encode]

lemma canonicalAmbientIso_decode {d : ℕ} (states : ℕ → CanonicalProgramState d) (H : ℕ)
    (x : CanonicalAmbient states H) :
    coordinateIso (CanonicalAmbientIndex states H) ((canonicalAmbientIso states H).symm x)=
      (canonicalAmbientCurry states H).symm x := by
  change coordinateIso _ ((coordinateIso _).symm ((canonicalAmbientCurry states H).symm x))=_
  exact LinearIsometryEquiv.apply_symm_apply _ _

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {f : BooleanFunction d} {P : ControlledMarginPath d H 1 f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

def residualCoordinates (M : FiniteCanonicalDynamics P S states) (j : Fin H)
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states H)) :
    EuclideanSpace ℝ (CanonicalAmbientIndex states H) :=
  (canonicalAmbientCurry states H).symm
    (M.normResidual (canonicalSignPrecision P) j (canonicalAmbientCurry states H x))

lemma residualCoordinates_range (M : FiniteCanonicalDynamics P S states) (j : Fin H)
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states H)) :
    ‖M.residualCoordinates j x‖≤M.residualRange (canonicalSignPrecision P) j := by
  rw [residualCoordinates,LinearIsometryEquiv.norm_map]
  exact M.normResidual_range (canonicalSignPrecision_pos P) j _

lemma residualCoordinates_lipschitz (M : FiniteCanonicalDynamics P S states) (j : Fin H)
    (x y : EuclideanSpace ℝ (CanonicalAmbientIndex states H)) :
    ‖M.residualCoordinates j x-M.residualCoordinates j y‖≤
      M.nonlinearGain (canonicalSignPrecision P) j*‖x-y‖ := by
  rw [residualCoordinates,residualCoordinates,←map_sub,LinearIsometryEquiv.norm_map]
  apply (M.normResidual_lipschitz (canonicalSignPrecision_pos P) j _ _).trans_eq
  rw [←map_sub,LinearIsometryEquiv.norm_map]

lemma residualProgram_realMap_error (M : FiniteCanonicalDynamics P S states)
    (j : Fin H) {n : ℕ} (w : Fin n→Fin (M.layerInputDimension j)→ℝ) (a : Fin n→ℝ)
    (A : Fin (M.layerRank j)→Fin n→ℝ) (b : Fin n→ℝ) (τ : ℝ)
    (hraw : ∀x:EuclideanSpace ℝ (Fin (canonicalAmbientDimension states H)),
      ‖WithLp.toLp 2 ((M.residualProgram j w a A b).eval (fun i=>x i))-
        (canonicalAmbientIso states H).symm
          (M.normResidual (canonicalSignPrecision P) j (canonicalAmbientIso states H x))‖≤τ)
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states H)) :
    ‖(M.residualProgram j w a A b).realMap x-M.residualCoordinates j x‖≤τ := by
  have hh := hraw (WithLp.toLp 2 (realCoordinates (fun i=>x i)))
  rw [← (coordinateIso (CanonicalAmbientIndex states H)).norm_map] at hh
  rw [map_sub,coordinateIso_program,canonicalAmbientIso_encode,canonicalAmbientIso_decode] at hh
  exact hh

/-- Existential interface directly consumable by the finite-grid compiler,
now with the exact arbitrary-finite-coordinate semantics accounted for. -/
theorem exists_residual_realMap_program (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (j : Fin H) {τ : ℝ} (hτ : 0<τ) (hτ1 : τ≤1) :
    ∃A : ArithmeticProgram (canonicalAmbientDimension states H) (canonicalAmbientDimension states H),
      A.length=14 ∧ A.bounded (M.residualCoefficientBudget j) ∧
      A.maxDimension≤2*canonicalAmbientDimension states H+4*M.layerInputDimension j+
        2*M.quadratureCount j τ+2*M.layerRank j+4 ∧
      ∀x:EuclideanSpace ℝ (CanonicalAmbientIndex states H),‖A.realMap x-M.residualCoordinates j x‖≤τ := by
  obtain ⟨w,a,A,b,hbound,happrox⟩ := M.exists_residual_program hd j hτ hτ1
  refine ⟨M.residualProgram j w a A b,M.residualProgram_length j w a A b,hbound,?_,
    M.residualProgram_realMap_error j w a A b τ happrox⟩
  have hh := residualArithmeticProgram_dimension (linearCoefficients (M.residualPreEncoded j))
    (canonicalRadius P (canonicalSignPrecision P) j) w a A b (linearCoefficients (M.residualPost j))
  simpa only [residualProgram,two_mul] using hh

#print axioms exists_residual_realMap_program
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic
