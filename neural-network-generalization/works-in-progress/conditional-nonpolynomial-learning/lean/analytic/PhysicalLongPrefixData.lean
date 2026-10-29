import PhysicalLongPicardBudget
import PhysicalGainPrefixConstruction
import PhysicalPrefixClassifier

/-! Concrete witnesses for the long nearcritical argument. This packages an
actual entropy-split compression, its literal normalized prefix dynamics and
its actual-input representative cover. The existence theorem discharges all
geometric fields; no normal-form certificate is postulated. -/
noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel

variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

def longCoverEndpoint (P : ControlledMarginPath d H t f) (J : ℕ) : ℕ :=
  (J/longPhysicalBlockLength P)*longPhysicalBlockLength P

structure LongPrefixData (P : ControlledMarginPath d H t f) (J : ℕ) (K T C : ℝ) where
  anchors : Finset (Cube d)
  states : ℕ→CanonicalProgramState d
  readout : EuclideanSpace ℝ (states H).Index
  initial : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
    inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)
  anchorBound : (anchors.card:ℝ)≤(H:ℝ)/(2*physicalAbsolutePrecision P (longCompressionPrecision P))+
    ‖P.readout‖^2/((1:ℝ)/32)^2
  dimensionBound : ∀j≤H,(states j).dimension≤d+1+j*(anchors.card+1)
  step : ∀j<H,PhysicalEntropySplitStep P anchors j (states j) (states (j+1))
  query : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature anchors x (longCompressionPrecision P)
  readoutBound : ‖readout‖≤‖P.readout‖
  readoutError : ∀x,|inner ℝ P.readout (P.feature H x)-inner ℝ readout ((states H).feature x)|≤(1:ℝ)/8
  dynamics : GainPrefixDynamics P anchors states (longCoverEndpoint P J)
  floorBound : ∀j,((dynamics.radius j))⁻¹≤((H:ℝ)+1)*(physicalPartialGainBound P+1)
  budget : dynamics.nonlinearBudget≤224*longPrefixPicardCoefficient C K*T
  inputMap : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states (longCoverEndpoint P J)
  inputNorm : ‖inputMap‖≤1
  inputEval : ∀x,inputMap (normalizedInputFeature d x)=dynamics.state x 0
  representatives : Finset (Cube d)
  representativeCard : (representatives.card:ℝ)≤
    Real.exp (((K+1)*Real.log ((longCoverCardFactor:ℝ)+1)/64)*T)
  cover : ∀x,∃y∈representatives,
    dist (dynamics.normalizedEndpoint x) (dynamics.normalizedEndpoint y)≤
      1/(64*(1+‖P.readout‖*physicalGainProduct P H))

 theorem actual_longPrefixData (P : ControlledMarginPath d H t f)
    (hd : 1≤d) (hH : 0<H) {J : ℕ} (hJ1 : 1≤J) (hJ : J≤H)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1) (ha1 : (physicalVariance P:ℝ)⁻¹-1≤1/4)
    {K T C G : ℝ} (hT : 1≤T) (hK : 1≤K) (hC : 0≤C) (hG : 0≤G)
    (hKspan : 2*longBlockSpan≤K) (hKC : C+1≤K)
    (hKsqrt : 16*longBlockSpan*longPrefixNonlinearCoefficient C≤longCoverNonlinearThreshold*Real.sqrt K)
    (hKrad : 4*longBlockSpan*(C+G+16)≤K)
    (hcount : K*T/((physicalVariance P:ℝ)⁻¹-1)≤(J:ℝ))
    (hupper : (J:ℝ)≤(K+1)*T/((physicalVariance P:ℝ)⁻¹-1))
    (hadj : (∑j∈Finset.range J,physicalAdjustedCost P j)≤C*((physicalVariance P:ℝ)⁻¹-1)*T)
    (hlog : Real.log ((J:ℝ)+2)≤T)
    (hgain : ‖P.readout‖*physicalGainProduct P H≤Real.exp (G*T)) :
    Nonempty (LongPrefixData P J K T C) := by
  classical
  obtain ⟨S,states,c,hzero,hcard,hdim,hstep,hquery,hc,herr⟩ :=
    physical_entropy_split_absolute_compression P hd hH (longCompressionPrecision_pos P)
      (longCompressionPrecision_bounds P).1 (ρ:=(1:ℝ)/32) (by norm_num)
  have hphysical : ∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1)) :=
    fun j hj=>(hstep j hj).physicalStep
  obtain ⟨M⟩ := PhysicalShort.finiteCanonicalDynamics_exists P S states hphysical
  have hend : longCoverEndpoint P J≤J := Nat.div_mul_le_self J (longPhysicalBlockLength P)
  let N := flooredGainPrefix M hd (hend.trans hJ) hzero hphysical
  obtain ⟨A,hA,hAx⟩ := N.initial_linear_map hzero
  have hbudget := physical_long_picard_subprefix_budget P hd S states hJ1 hJ hend
    (fun j hj=>hquery j (by omega)) hK hT hC ha hupper hadj hlog
  have hNbudget : N.nonlinearBudget≤224*longPrefixPicardCoefficient C K*T := by
    have he : N.nonlinearBudget=224*(∑j∈Finset.range (longCoverEndpoint P J),
        ((t*physicalGainProduct P j*physicalFlooredRadius P states j)^2+Real.sqrt (physicalLayerCost P j))) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j hj
      simp only [GainPrefixDynamics.nonlinearGain,if_pos (Finset.mem_range.mp hj),
        GainPrefixDynamics.inputScale,N,flooredGainPrefix]
    rw [he]
    nlinarith only [hbudget]
  obtain ⟨Y,hY,hcover⟩ := physical_long_prefix_representatives hd hzero hstep hJ1 hJ
    (fun j hj=>hquery j (by omega)) ha ha1 hT hK hC hG hKspan hKC hKsqrt hKrad
    hcount hupper hadj hlog hgain
  refine ⟨⟨S,states,c,hzero,hcard,hdim,hstep,hquery,hc,?_,N,?_,hNbudget,A,hA,hAx,Y,hY,hcover⟩⟩
  · intro x
    have hh := (longCompressionPrecision_bounds P).2.2
    exact (herr x).trans (by linarith)
  · intro j
    exact flooredGainPrefix_inverse M hd (hend.trans hJ) hzero hphysical j

namespace LongPrefixData
variable {P : ControlledMarginPath d H t f} {J : ℕ} {K T C : ℝ}

def classifier (D : LongPrefixData P J K T C) : ThresholdCircuit d :=
  D.dynamics.representativeClassifier D.inputMap D.inputNorm D.representatives

 theorem classifier_correct (D : LongPrefixData P J K T C) (hd : 1≤d) : D.classifier.eval=f :=
  D.dynamics.representativeClassifier_correct hd
    (GainPrefixDynamics.initial_norm_from_gram hd D.initial) D.inputMap D.inputNorm D.inputEval
    D.readout D.readoutBound D.readoutError D.representatives D.cover

 theorem classifier_depth (D : LongPrefixData P J K T C) :
    D.classifier.depth≤90*longEvaluationIterations D.dynamics.nonlinearBudget (longEvaluationPrecision P)+27 :=
  D.dynamics.representativeClassifier_depth D.inputMap D.inputNorm D.representatives

end LongPrefixData
#print axioms actual_longPrefixData
#print axioms LongPrefixData.classifier_correct
end ConditionalNonpolynomial.Analytic.PhysicalLong
