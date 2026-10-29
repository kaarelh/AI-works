import CanonicalOutputProgram
import GainDominatedCanonical
import FarStrongNormalizedDynamics

noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
open ConditionalNonpolynomial.AnalyticLookup

lemma radialClip_isometry {E F:Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [NormedAddCommGroup F] [InnerProductSpace ℝ F]
    (T:E≃ₗᵢ[ℝ]F) (s:ℝ) (x:E) : T (radialClip s x)=radialClip s (T x) := by
  simp only [radialClip,map_smul,T.norm_map]

namespace CanonicalLayerModel
variable {I J A:Type*} [Fintype I] [Fintype J] [Fintype A]
variable {anchors:A→EuclideanSpace ℝ I} {D:ℝ}

def gainClippedValue (M:CanonicalLayerModel (J:=J) anchors D) (S α:ℝ)
    (x:EuclideanSpace ℝ I) : EuclideanSpace ℝ J :=
  (S*α)⁻¹ • M.value (S • radialClip 2 x)

def gainOutput (M:CanonicalLayerModel (J:=J) anchors D) :
    EuclideanSpace ℝ (CanonicalIndex M.law M.finiteKL anchors)→L[ℝ]
      EuclideanSpace ℝ (Fin (Fintype.card J)) :=
  (coordinateIso J).symm.toContinuousLinearMap.comp M.output.toContinuousLinearMap

lemma gainOutput_norm (M:CanonicalLayerModel (J:=J) anchors D) : ‖M.gainOutput‖≤1 := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
  intro x
  change ‖(coordinateIso J).symm (M.output x)‖≤_
  simp only [LinearIsometryEquiv.norm_map,LinearIsometry.norm_map,one_mul,le_refl]

lemma normalized_canonical_output (M:CanonicalLayerModel (J:=J) anchors D)
    {S α:ℝ} (hS:0<S) (hα:0<α) (x:EuclideanSpace ℝ I) :
    M.output (canonicalVector (actualCanonicalSpan M.law M.finiteKL anchors)
      (normalizedTanhL2 M.law S α x))=(S*α)⁻¹ • M.value (S • x) := by
  unfold normalizedTanhL2
  rw [canonicalVector_smul_nonneg _ _ (by positivity),map_smul]
  rfl

lemma gainClippedValue_norm (M:CanonicalLayerModel (J:=J) anchors D)
    {S α:ℝ} (hS:0<S)
    (hαgain:Real.sqrt (gaussianEntropyGain ((klDiv M.law
      (NeuralGeneralization.GaussianAngularFields.standardLaw I)).toReal))≤α)
    (x:EuclideanSpace ℝ I) : ‖M.gainClippedValue S α x‖≤2 := by
  have hα:0<α := (Real.sqrt_pos.mpr ((by norm_num : (0:ℝ)<1).trans_le
    (gaussianEntropyGain_one_le _))).trans_le hαgain
  rw [gainClippedValue,←M.normalized_canonical_output hS hα, M.output.norm_map]
  rw [canonicalVector_norm]
  exact (normalizedTanhL2_norm_of_gain_le M.law M.finiteKL S α hS.ne' hαgain _).trans
    (radialClip_norm_le (by norm_num) _)

lemma gainClippedProgram_error
    (M:CanonicalLayerModel (J:=J) anchors D) {S α:ℝ} (hS:0<S) (hα:0<α)
    {n:ℕ} (w:Fin n→Fin (Fintype.card I)→ℝ) (a:Fin n→ℝ)
    (A':Fin (Module.finrank ℝ (actualCanonicalSpan M.law M.finiteKL anchors))→Fin n→ℝ)
    (b:Fin n→ℝ) {τ:ℝ} (hτ:0≤τ)
    (hquad:∀v:ParameterCube (Fin (Fintype.card I)) 4,
      ‖WithLp.toLp 2 (canonicalArithmeticProgram w a A' b v.val)-
        canonicalVector (actualCanonicalSpan M.law M.finiteKL anchors)
          (normalizedTanhL2 M.law S α (coordinateIso I (WithLp.toLp 2 v.val)))‖≤τ)
    (x:EuclideanSpace ℝ I) :
    ‖(canonicalOutputProgram M.gainOutput w a A' b).realMap x-M.gainClippedValue S α x‖≤τ := by
  let F:=fun u:EuclideanSpace ℝ (Fin (Fintype.card I))=>
    canonicalVector (actualCanonicalSpan M.law M.finiteKL anchors)
      (normalizedTanhL2 M.law S α (coordinateIso I u))
  have hq (u:EuclideanSpace ℝ (Fin (Fintype.card I))) (hu:‖u‖≤2) :
      ‖WithLp.toLp 2 (canonicalArithmeticProgram w a A' b u)-F u‖≤τ := by
    exact hquad ⟨u,fun i=>(PiLp.norm_apply_le u i).trans (hu.trans (by norm_num))⟩
  let x':EuclideanSpace ℝ (Fin (Fintype.card I)):=WithLp.toLp 2 (realCoordinates x)
  have hh:=canonicalOutputProgram_error M.gainOutput w a A' b F hq x'
  have hb:‖M.gainOutput‖*τ≤τ := by nlinarith [M.gainOutput_norm]
  have hh:=hh.trans hb
  rw [←(coordinateIso J).norm_map] at hh
  rw [map_sub,coordinateIso_program] at hh
  have he : coordinateIso J (M.gainOutput (F (radialClip 2 x')))=M.gainClippedValue S α x := by
    change coordinateIso J ((coordinateIso J).symm (M.output (F (radialClip 2 x'))))=_
    rw [LinearIsometryEquiv.apply_symm_apply]
    dsimp only [F]
    rw [radialClip_isometry,coordinateIso_encode,M.normalized_canonical_output hS hα]
    rfl
  rw [he] at hh
  exact hh

#print axioms gainClippedProgram_error
end CanonicalLayerModel
end ConditionalNonpolynomial.Analytic
