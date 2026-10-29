import CanonicalCoordinateOperators
import ResidualArithmeticProgram
import GaussianCanonicalCircuit

noncomputable section
set_option maxHeartbeats 500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {f : BooleanFunction d} {P : ControlledMarginPath d H 1 f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

abbrev layerSpan (M : FiniteCanonicalDynamics P S states) (j : Fin H) :=
  actualCanonicalSpan (M.layer j).law (M.layer j).finiteKL (fun s:S=>(states j).feature s)

abbrev layerRank (M : FiniteCanonicalDynamics P S states) (j : Fin H) :=
  Module.finrank ℝ (M.layerSpan j)

def residualProgram (M : FiniteCanonicalDynamics P S states) (j : Fin H) {n : ℕ}
    (w : Fin n→Fin (M.layerInputDimension j)→ℝ) (a : Fin n→ℝ)
    (A : Fin (M.layerRank j)→Fin n→ℝ) (b : Fin n→ℝ) :
    ArithmeticProgram (canonicalAmbientDimension states H) (canonicalAmbientDimension states H) :=
  residualArithmeticProgram (linearCoefficients (M.residualPreEncoded j))
    (canonicalRadius P (canonicalSignPrecision P) j) w a A b (linearCoefficients (M.residualPost j))

lemma residualProgram_length (M : FiniteCanonicalDynamics P S states) (j : Fin H) {n : ℕ}
    (w : Fin n→Fin (M.layerInputDimension j)→ℝ) (a : Fin n→ℝ)
    (A : Fin (M.layerRank j)→Fin n→ℝ) (b : Fin n→ℝ) :
    (M.residualProgram j w a A b).length=14 := residualArithmeticProgram_length _ _ _ _ _ _ _

lemma radial_program_vector {n : ℕ} (s : ℝ) (hs : 0<s) (u : EuclideanSpace ℝ (Fin n)) :
    WithLp.toLp 2 (radialArithmeticProgram s (fun i=>u i))=radialClip s u := by
  ext i
  exact radialArithmeticProgram_is_projection s hs u i

/-- The concrete fourteen-stage arithmetic program approximates the actual
normalized residual on all inputs; clipping supplies the finite quadrature
range independently of the incoming approximation. -/
theorem residualProgram_error (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (j : Fin H) {n : ℕ} (w : Fin n→Fin (M.layerInputDimension j)→ℝ) (a : Fin n→ℝ)
    (A : Fin (M.layerRank j)→Fin n→ℝ) (b : Fin n→ℝ) (θ : ℝ)
    (hquad : ∀v:ParameterCube (Fin (M.layerInputDimension j)) 4,
      ‖WithLp.toLp 2 (canonicalArithmeticProgram w a A b v.val)-
        canonicalGaussianMap (M.layer j).law (M.layer j).finiteKL
          (fun s:S=>(states j).feature s) (coordinateIso (states j).Index (WithLp.toLp 2 v.val))‖≤θ)
    (x : EuclideanSpace ℝ (Fin (canonicalAmbientDimension states H))) :
    ‖WithLp.toLp 2 ((M.residualProgram j w a A b).eval (fun i=>x i))-
      (canonicalAmbientIso states H).symm (M.normResidual (canonicalSignPrecision P) j (canonicalAmbientIso states H x))‖≤
        (1+M.linearGain j)*θ := by
  let u0 := M.residualPre j x
  let s := canonicalRadius P (canonicalSignPrecision P) j
  let ur := radialArithmeticProgram s (fun i=>u0 i)
  let u : EuclideanSpace ℝ (Fin (M.layerInputDimension j)) := WithLp.toLp 2 ur
  let z : EuclideanSpace ℝ (M.layerCanonicalIndex j) := WithLp.toLp 2 (canonicalArithmeticProgram w a A b ur)
  have hs : 0<s := canonicalRadius_pos P (canonicalSignPrecision_pos P) j
  have hur : u=radialClip s u0 := radial_program_vector s hs u0
  have hu : ∀i,|ur i|≤(4:ℝ) := by
    intro i
    have hn0 : ‖u‖≤s := by rw [hur]; exact radialClip_norm_le hs _
    have hn := (PiLp.norm_apply_le u i).trans hn0
    have hr := canonicalRadius_le_three P hd j j.isLt.le
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
  have htarget := M.residualPost_exact (canonicalSignPrecision P) j x
  dsimp only at htarget
  change M.residualPost j (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>radialClip s u0 i))
    (realCoordinates (fun i=>canonicalGaussianMap (M.layer j).law (M.layer j).finiteKL
      (fun t:S=>(states j).feature t) (coordinateIso (states j).Index (radialClip s u0)) i))))=_ at htarget
  rw [← hur] at htarget
  rw [hreal,← htarget]
  apply (M.residualPost_perturb j u z _).trans
  exact mul_le_mul_of_nonneg_left (hquad v) (by linarith [M.linearGain_one_le j])

#print axioms residualProgram_error
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic
