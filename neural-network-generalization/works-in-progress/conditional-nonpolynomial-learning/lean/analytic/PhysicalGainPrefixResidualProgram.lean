import PhysicalGainPrefixCoordinates
import PhysicalShortResidualProgram
import ResidualArithmeticProgram
import GaussianCanonicalCircuit

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

def residualProgram (M : GainPrefixDynamics P S states J) (j : Fin J) {n : ℕ}
    (w : Fin n→Fin (M.layerInputDimension j)→ℝ) (a : Fin n→ℝ)
    (A : Fin (M.layerRank j)→Fin n→ℝ) (b : Fin n→ℝ) :
    ArithmeticProgram (canonicalAmbientDimension states J) (canonicalAmbientDimension states J) :=
  residualArithmeticProgram (linearCoefficients (M.residualPreEncoded j))
    (M.radius j) w a A b (linearCoefficients (M.residualPost j))

lemma residualProgram_length (M : GainPrefixDynamics P S states J) (j : Fin J) {n : ℕ}
    (w : Fin n→Fin (M.layerInputDimension j)→ℝ) (a : Fin n→ℝ)
    (A : Fin (M.layerRank j)→Fin n→ℝ) (b : Fin n→ℝ) :
    (M.residualProgram j w a A b).length=14 := residualArithmeticProgram_length _ _ _ _ _ _ _

/-- The concrete fourteen-stage arithmetic program approximates the actual
normalized residual on all inputs; clipping supplies the finite quadrature
range independently of the incoming approximation. -/
theorem residualProgram_error (M : GainPrefixDynamics P S states J)
    (j : Fin J) {n : ℕ} (w : Fin n→Fin (M.layerInputDimension j)→ℝ) (a : Fin n→ℝ)
    (A : Fin (M.layerRank j)→Fin n→ℝ) (b : Fin n→ℝ) (θ : ℝ)
    (hquad : ∀v:ParameterCube (Fin (M.layerInputDimension j)) 4,
      ‖WithLp.toLp 2 (canonicalArithmeticProgram w a A b v.val)-
        (M.layer j).gainCanonical (M.inputScale j) (coordinateIso (states j).Index (WithLp.toLp 2 v.val))‖≤θ)
    (x : EuclideanSpace ℝ (Fin (canonicalAmbientDimension states J))) :
    ‖WithLp.toLp 2 ((M.residualProgram j w a A b).eval (fun i=>x i))-
      (canonicalAmbientIso states J).symm (M.residual j (canonicalAmbientIso states J x))‖≤
        2*θ := by
  classical
  let u0 := M.residualPre j x
  let s := M.radius j
  let ur := radialArithmeticProgram s (fun i=>u0 i)
  let u : EuclideanSpace ℝ (Fin (M.layerInputDimension j)) := WithLp.toLp 2 ur
  let z : EuclideanSpace ℝ (M.layerCanonicalIndex j) := WithLp.toLp 2 (canonicalArithmeticProgram w a A b ur)
  have hs : 0<s := M.radius_pos j j.isLt
  have hur : u=radialClip s u0 := PhysicalShort.FiniteCanonicalDynamics.radial_program_vector s hs u0
  have hu : ∀i,|ur i|≤(4:ℝ) := by
    intro i
    have hn0 : ‖u‖≤s := by rw [hur]; exact radialClip_norm_le hs _
    have hn := (PiLp.norm_apply_le u i).trans hn0
    have hr := M.radius_le j j.isLt
    exact hn.trans (by dsimp [s];linarith)
  let v : ParameterCube (Fin (M.layerInputDimension j)) 4 := ⟨ur,hu⟩
  have heval := residualArithmeticProgram_eval (linearCoefficients (M.residualPreEncoded j)) s w a A b
    (linearCoefficients (M.residualPost j)) (fun i=>x i) (fun i=>u0 i)
    (M.residualPreEncoded_eval j x)
  have hreal : WithLp.toLp 2 ((M.residualProgram j w a A b).eval (fun i=>x i))=
      M.residualPost j (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>u i)) (realCoordinates (fun i=>z i)))) := by
    change WithLp.toLp 2 ((residualArithmeticProgram _ s w a A b _).eval (fun i=>x i))=_
    rw [heval]
    ext i
    exact linearCoefficients_eval (M.residualPost j)
      (WithLp.toLp 2 (Fin.addCases (realCoordinates ur)
        (realCoordinates (canonicalArithmeticProgram w a A b ur)))) i
  have htarget := M.residualPost_exact j x
  dsimp only at htarget
  change M.residualPost j (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>radialClip s u0 i))
    (realCoordinates (fun i=>(M.layer j).gainCanonical (M.inputScale j) (coordinateIso (states j).Index (radialClip s u0)) i))))=_ at htarget
  rw [← hur] at htarget
  rw [hreal,← htarget]
  apply (M.residualPost_perturb j u z _).trans
  exact mul_le_mul_of_nonneg_left (hquad v) (by norm_num)

#print axioms residualProgram_error
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
