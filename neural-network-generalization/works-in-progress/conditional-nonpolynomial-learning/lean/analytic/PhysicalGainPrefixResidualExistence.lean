import PhysicalGainPrefixResidualProgram
import PhysicalShortResidualExistence

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort

lemma gainQuadrature_final_error (d : ℕ) {τ : ℝ} (hτ : 0<τ) (hτ1 : τ≤1) :
    let δ := (τ/(64*((d:ℝ)+1)))^2
    2*(δ+Real.sqrt ((1+2*(((d:ℝ)+1)*4+δ))*δ))≤τ := by
  let D := (d:ℝ)+1
  let ζ := τ/(64*D)
  have hD : 1≤D := by dsimp [D];linarith [Nat.cast_nonneg (α:=ℝ) d]
  have hζ : 0<ζ := by dsimp [ζ];positivity
  have hζ1 : ζ≤1 := by
    apply (div_le_iff₀ (by positivity : 0<64*D)).mpr
    linarith
  have hζsq : ζ^2≤ζ := by nlinarith
  have hζsq1 : ζ^2≤1 := by nlinarith
  have hc : 1+2*(D*4+ζ^2)≤16*D^2 := by nlinarith [sq_nonneg (D-1)]
  have hs : Real.sqrt ((1+2*(D*4+ζ^2))*ζ^2)≤4*D*ζ := by
    apply Real.sqrt_le_iff.mpr ⟨by positivity,?_⟩
    have hh := mul_le_mul_of_nonneg_right hc (sq_nonneg ζ)
    nlinarith only [hh]
  have hid : 64*D*ζ=τ := by dsimp [ζ];field_simp
  change 2*(ζ^2+Real.sqrt ((1+2*(D*4+ζ^2))*ζ^2))≤τ
  have hDz : ζ≤D*ζ := by nlinarith
  nlinarith

namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

def quadratureZ (M : GainPrefixDynamics P S states J) (j : Fin J) :=
  canonicalNormalizer (M.layer j).law (canonicalBasisValues (M.layer j).law (M.layerSpan j))
    (fun z=>gaussianRowNorm z/Real.sqrt (gaussianEntropyGain (physicalLayerCost P j)))
def quadratureError (M : GainPrefixDynamics P S states J) (j : Fin J) (τ : ℝ) :=
  (τ/(64*((M.layerInputDimension j:ℝ)+1)))^2
def quadratureCount (M : GainPrefixDynamics P S states J) (j : Fin J) (τ : ℝ) :=
  canonicalQuadratureSamples (M.layerInputDimension j) (M.quadratureZ j) (M.quadratureError j τ)
def residualCoefficientBudget (M : GainPrefixDynamics P S states J) (j : Fin J) : ℕ :=
  ⌈6+(M.layerRank j:ℝ)+2*(M.layerInputDimension j:ℝ)+(M.radius j)⁻¹^2⌉₊+1

lemma quadratureZ_positive (M : GainPrefixDynamics P S states J) (j : Fin J) : 0<M.quadratureZ j :=
  canonicalNormalizer_pos _ _ _
lemma quadratureError_positive (M : GainPrefixDynamics P S states J) (j : Fin J)
    {τ : ℝ} (hτ : 0<τ) : 0<M.quadratureError j τ := by unfold quadratureError;positivity

lemma layer_gain_bound (M : GainPrefixDynamics P S states J) (j : Fin J) :
    Real.sqrt (gaussianEntropyGain ((klDiv (M.layer j).law
      (Measure.pi fun _ : (states j).Index=>gaussianReal 0 1)).toReal))≤
      Real.sqrt (gaussianEntropyGain (physicalLayerCost P j)) :=
  Real.sqrt_le_sqrt (gaussianEntropyGain_mono ENNReal.toReal_nonneg (M.layer j).cost_le)

lemma quadratureZ_bound (M : GainPrefixDynamics P S states J) (j : Fin J) :
    M.quadratureZ j≤3+(M.layerRank j:ℝ)+2*(M.layerInputDimension j:ℝ) :=
  gainDominatedNormalizer_bound (M.layer j).law (M.layerSpan j)
    (Fintype.equivFin (states j).Index).symm (M.layer j).finiteKL _ (M.layer_gain_bound j)

lemma residualCoefficientBudget_bounds (M : GainPrefixDynamics P S states J) (j : Fin J) :
    1≤M.residualCoefficientBudget j ∧ (2:ℝ)≤M.residualCoefficientBudget j ∧
      (M.radius j)⁻¹^2≤M.residualCoefficientBudget j ∧
      3+(M.layerRank j:ℝ)+2*(M.layerInputDimension j:ℝ)≤M.residualCoefficientBudget j := by
  have hh := Nat.le_ceil (6+(M.layerRank j:ℝ)+2*(M.layerInputDimension j:ℝ)+(M.radius j)⁻¹^2)
  have hb : (⌈6+(M.layerRank j:ℝ)+2*(M.layerInputDimension j:ℝ)+(M.radius j)⁻¹^2⌉₊:ℝ)≤
      M.residualCoefficientBudget j := by unfold residualCoefficientBudget;push_cast;linarith
  have hr := sq_nonneg (M.radius j)⁻¹
  have hi := Nat.cast_nonneg (α:=ℝ) (M.layerInputDimension j)
  have hk := Nat.cast_nonneg (α:=ℝ) (M.layerRank j)
  refine ⟨by unfold residualCoefficientBudget;omega,?_,?_,?_⟩ <;> linarith

/-- A bounded fourteen-stage evaluator of the actual gain-normalized
canonical residual. Its numerical resources contain no inverse physical
scale or inverse gain product. -/
theorem exists_residual_program (M : GainPrefixDynamics P S states J)
    (j : Fin J) {τ : ℝ} (hτ : 0<τ) (hτ1 : τ≤1) :
    ∃w:Fin (M.quadratureCount j τ)→Fin (M.layerInputDimension j)→ℝ,
    ∃a:Fin (M.quadratureCount j τ)→ℝ,
    ∃A:Fin (M.layerRank j)→Fin (M.quadratureCount j τ)→ℝ,
    ∃b:Fin (M.quadratureCount j τ)→ℝ,
      (M.residualProgram j w a A b).bounded (M.residualCoefficientBudget j) ∧
      ∀x:EuclideanSpace ℝ (Fin (canonicalAmbientDimension states J)),
        ‖WithLp.toLp 2 ((M.residualProgram j w a A b).eval (fun i=>x i))-
          (canonicalAmbientIso states J).symm (M.residual j (canonicalAmbientIso states J x))‖≤τ := by
  classical
  let δ := M.quadratureError j τ
  let T := canonicalQuadratureMesh (M.layerInputDimension j) (M.quadratureZ j) δ
  have hδ : 0<δ := M.quadratureError_positive j hτ
  obtain ⟨w,a,A,b,hw,hA,hb,happrox⟩ := actual_gain_dominated_canonical_program
    (M.layer j).law (M.layerSpan j) (Fintype.equivFin (states j).Index).symm
    (M.layer j).finiteKL (M.inputScale j) (Real.sqrt (gaussianEntropyGain (physicalLayerCost P j)))
    (M.inputScale_pos j).ne' (M.layer_gain_bound j) 4 (by norm_num) T
    (canonicalQuadratureMesh_positive _ _ _) δ hδ (M.quadratureCount j τ)
    (canonicalQuadratureSamples_positive _ _ _) (canonicalQuadratureMesh_suffices _ _ hδ)
    (canonicalQuadratureSamples_suffices _ _ hδ)
  obtain ⟨hB,hB2,hrad,hcoeff⟩ := M.residualCoefficientBudget_bounds j
  have hB1 : (1:ℝ)≤M.residualCoefficientBudget j := by exact_mod_cast hB
  refine ⟨w,a,A,b,?_,?_⟩
  · exact residualArithmeticProgram_bounded _ _ w a A b _ _ hB
      (fun k i=>(linearCoefficients_bound _ k i).trans ((M.residualPreEncoded_norm j).trans hB1))
      hrad (fun k i=>(hw k i).trans hB1)
      (fun k i=>(hA k i).trans (by
        have hn := Nat.cast_nonneg (α:=ℝ) (M.layerRank j)
        have hd := Nat.cast_nonneg (α:=ℝ) (M.layerInputDimension j)
        linarith))
      (fun i=>by rw [abs_of_nonneg (hb i).1];exact (hb i).2.trans hcoeff)
      (fun k i=>(linearCoefficients_bound _ k i).trans ((M.residualPost_norm j).trans hB2))
  · intro x
    apply (M.residualProgram_error j w a A b
      (δ+Real.sqrt ((1+2*(((M.layerInputDimension j:ℝ)+1)*4+δ))*δ)) ?_ x).trans
    · exact gainQuadrature_final_error (M.layerInputDimension j) hτ hτ1
    · intro v
      have hh := happrox v
      rw [canonicalProgramVector_coordinates] at hh
      exact hh

#print axioms exists_residual_program
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
