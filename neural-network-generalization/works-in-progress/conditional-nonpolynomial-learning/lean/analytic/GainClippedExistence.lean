import GainClippedProgram

noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
open ConditionalNonpolynomial.AnalyticLookup

def gainQuadratureError (d:ℕ) (τ:ℝ) : ℝ := (τ/(8*(4*((d:ℝ)+1)+1)))^2

lemma gainQuadrature_final_error (d:ℕ) {τ:ℝ} (hτ:0<τ) (hτ1:τ≤1) :
    gainQuadratureError d τ+Real.sqrt ((1+2*(((d:ℝ)+1)*4+gainQuadratureError d τ))*
      gainQuadratureError d τ)≤τ := by
  let g:=4*((d:ℝ)+1)+1
  let z:=τ/(8*g)
  have hg:1≤g := by dsimp [g]; have hh:=Nat.cast_nonneg (α:=ℝ) d;linarith
  have hgp:0<g := by linarith
  have hz:0<z := by dsimp [z];positivity
  have hz1:z≤1 := (div_le_one (by positivity : 0<8*g)).mpr (by linarith)
  have hzs:z^2≤z := by nlinarith
  have hzsq:z^2≤1 := by nlinarith
  have hc:1+2*(((d:ℝ)+1)*4+z^2)≤9*g^2 := by dsimp [g] at *;nlinarith
  have hcm:=mul_le_mul_of_nonneg_right hc (sq_nonneg z)
  have hs:Real.sqrt ((1+2*(((d:ℝ)+1)*4+z^2))*z^2)≤3*g*z := by
    apply Real.sqrt_le_iff.mpr
    constructor
    · positivity
    · nlinarith only [hcm]
  have hgz:z≤g*z := by nlinarith
  have hid:8*g*z=τ := by dsimp [z];field_simp
  change z^2+Real.sqrt ((1+2*(((d:ℝ)+1)*4+z^2))*z^2)≤τ
  nlinarith

namespace CanonicalLayerModel
variable {I J A:Type*} [Fintype I] [Fintype J] [Fintype A]
variable {anchors:A→EuclideanSpace ℝ I} {D:ℝ}

abbrev gainRank (M:CanonicalLayerModel (J:=J) anchors D) :=
  Module.finrank ℝ (actualCanonicalSpan M.law M.finiteKL anchors)
def gainCoefficientBudget (M:CanonicalLayerModel (J:=J) anchors D) : ℕ :=
  ⌈3+(M.gainRank:ℝ)+2*(Fintype.card I:ℝ)⌉₊+1

def gainNormalizer (M:CanonicalLayerModel (J:=J) anchors D) (α:ℝ) : ℝ :=
  canonicalNormalizer M.law (canonicalBasisValues M.law (actualCanonicalSpan M.law M.finiteKL anchors))
    (fun z=>gaussianRowNorm z/α)

def gainQuadratureCount (M:CanonicalLayerModel (J:=J) anchors D) (α τ:ℝ) : ℕ :=
  canonicalQuadratureSamples (Fintype.card I) (M.gainNormalizer α) (gainQuadratureError (Fintype.card I) τ)

lemma gainCoefficientBudget_bounds (M:CanonicalLayerModel (J:=J) anchors D) :
    1≤M.gainCoefficientBudget ∧
      3+(M.gainRank:ℝ)+2*(Fintype.card I:ℝ)≤(M.gainCoefficientBudget:ℝ) := by
  refine ⟨by unfold gainCoefficientBudget;omega,?_⟩
  exact (Nat.le_ceil _).trans (by unfold gainCoefficientBudget;push_cast;linarith)

theorem exists_gainClipped_realMap_program
    (M:CanonicalLayerModel (J:=J) anchors D) {S α τ:ℝ} (hS:0<S)
    (hαgain:Real.sqrt (gaussianEntropyGain ((klDiv M.law
      (NeuralGeneralization.GaussianAngularFields.standardLaw I)).toReal))≤α)
    (hτ:0<τ) (hτ1:τ≤1) :
    ∃P:ArithmeticProgram (Fintype.card I) (Fintype.card J),
      P.length=14 ∧ P.bounded M.gainCoefficientBudget ∧
      P.maxDimension≤5*Fintype.card I+Fintype.card J+2*M.gainQuadratureCount α τ+2*M.gainRank+4 ∧
      ∀x:EuclideanSpace ℝ I,‖P.realMap x-M.gainClippedValue S α x‖≤τ := by
  let δ:=gainQuadratureError (Fintype.card I) τ
  let Z:=M.gainNormalizer α
  let T:=canonicalQuadratureMesh (Fintype.card I) Z δ
  have hδ:0<δ := by dsimp [δ,gainQuadratureError];positivity
  have hα:0<α := (Real.sqrt_pos.mpr ((by norm_num : (0:ℝ)<1).trans_le
    (gaussianEntropyGain_one_le _))).trans_le hαgain
  obtain ⟨w,a,A',b,hw,hA,hb,happrox⟩:=actual_gain_dominated_canonical_program M.law
    (actualCanonicalSpan M.law M.finiteKL anchors) (Fintype.equivFin I).symm M.finiteKL S α hS.ne'
    hαgain 4 (by norm_num) T (canonicalQuadratureMesh_positive _ _ _) δ hδ
    (M.gainQuadratureCount α τ) (canonicalQuadratureSamples_positive _ _ _)
    (canonicalQuadratureMesh_suffices _ _ hδ) (canonicalQuadratureSamples_suffices _ _ hδ)
  let P:=canonicalOutputProgram M.gainOutput w a A' b
  obtain ⟨hB,hbudget⟩:=M.gainCoefficientBudget_bounds
  have hBreal:(1:ℝ)≤M.gainCoefficientBudget := by exact_mod_cast hB
  refine ⟨P,canonicalOutputProgram_length _ _ _ _ _,?_,?_,?_⟩
  · exact canonicalOutputProgram_bounded _ _ _ _ _ _ hB
      (M.gainOutput_norm.trans hBreal) (fun j i=>(hw j i).trans hBreal)
      (fun j i=>(hA j i).trans (by change _≤(M.gainCoefficientBudget:ℝ);dsimp only [gainRank] at hbudget;linarith))
      (fun i=>by rw [abs_of_nonneg (hb i).1];exact (hb i).2.trans hbudget)
  · have hh:=residualArithmeticProgram_dimension (linearCoefficients (outputPre (Fintype.card I)))
      2 w a A' b (linearCoefficients (outputPost M.gainOutput))
    apply hh.trans
    dsimp only [gainRank]
    omega
  · intro x
    apply (M.gainClippedProgram_error hS hα w a A' b (by positivity : 0≤δ+Real.sqrt
      ((1+2*(((Fintype.card I:ℝ)+1)*4+δ))*δ)) ?_ x).trans
    · exact gainQuadrature_final_error (Fintype.card I) hτ hτ1
    · intro v
      have hh:=happrox v
      rw [canonicalProgramVector_coordinates] at hh
      exact hh

#print axioms exists_gainClipped_realMap_program
end CanonicalLayerModel
end ConditionalNonpolynomial.Analytic
