import PhysicalGainPrefixResidualExistence
import PhysicalShortResidualRealMap

noncomputable section
set_option maxHeartbeats 500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort

namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

def residualCoordinates (M : GainPrefixDynamics P S states J) (j : Fin J)
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states J)) :
    EuclideanSpace ℝ (CanonicalAmbientIndex states J) :=
  (canonicalAmbientCurry states J).symm
    (M.residual j (canonicalAmbientCurry states J x))

lemma residualCoordinates_range (M : GainPrefixDynamics P S states J) (j : Fin J)
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states J)) :
    ‖M.residualCoordinates j x‖≤3*M.nonlinearGain j := by
  rw [residualCoordinates,LinearIsometryEquiv.norm_map]
  exact M.residual_range j _

lemma residualCoordinates_lipschitz (M : GainPrefixDynamics P S states J) (j : Fin J)
    (x y : EuclideanSpace ℝ (CanonicalAmbientIndex states J)) :
    ‖M.residualCoordinates j x-M.residualCoordinates j y‖≤
      M.nonlinearGain j*‖x-y‖ := by
  rw [residualCoordinates,residualCoordinates,←map_sub,LinearIsometryEquiv.norm_map]
  apply (M.residual_lipschitz j _ _).trans_eq
  rw [←map_sub,LinearIsometryEquiv.norm_map]

lemma residualProgram_realMap_error (M : GainPrefixDynamics P S states J)
    (j : Fin J) {n : ℕ} (w : Fin n→Fin (M.layerInputDimension j)→ℝ) (a : Fin n→ℝ)
    (A : Fin (M.layerRank j)→Fin n→ℝ) (b : Fin n→ℝ) (τ : ℝ)
    (hraw : ∀x:EuclideanSpace ℝ (Fin (canonicalAmbientDimension states J)),
      ‖WithLp.toLp 2 ((M.residualProgram j w a A b).eval (fun i=>x i))-
        (canonicalAmbientIso states J).symm
          (M.residual j (canonicalAmbientIso states J x))‖≤τ)
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states J)) :
    ‖(M.residualProgram j w a A b).realMap x-M.residualCoordinates j x‖≤τ := by
  have hh := hraw (WithLp.toLp 2 (realCoordinates (fun i=>x i)))
  rw [← (coordinateIso (CanonicalAmbientIndex states J)).norm_map] at hh
  rw [map_sub,coordinateIso_program,canonicalAmbientIso_encode,canonicalAmbientIso_decode] at hh
  exact hh

/-- Existential interface directly consumable by the finite-grid compiler,
now with the exact arbitrary-finite-coordinate semantics accounted for. -/
theorem exists_residual_realMap_program (M : GainPrefixDynamics P S states J)
    (j : Fin J) {τ : ℝ} (hτ : 0<τ) (hτ1 : τ≤1) :
    ∃A : ArithmeticProgram (canonicalAmbientDimension states J) (canonicalAmbientDimension states J),
      A.length=14 ∧ A.bounded (M.residualCoefficientBudget j) ∧
      A.maxDimension≤2*canonicalAmbientDimension states J+4*M.layerInputDimension j+
        2*M.quadratureCount j τ+2*M.layerRank j+4 ∧
      ∀x:EuclideanSpace ℝ (CanonicalAmbientIndex states J),‖A.realMap x-M.residualCoordinates j x‖≤τ := by
  obtain ⟨w,a,A,b,hbound,happrox⟩ := M.exists_residual_program j hτ hτ1
  refine ⟨M.residualProgram j w a A b,M.residualProgram_length j w a A b,hbound,?_,
    M.residualProgram_realMap_error j w a A b τ happrox⟩
  have hh := residualArithmeticProgram_dimension (linearCoefficients (M.residualPreEncoded j))
    (M.radius j) w a A b (linearCoefficients (M.residualPost j))
  simpa only [residualProgram,two_mul] using hh

#print axioms exists_residual_realMap_program
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
