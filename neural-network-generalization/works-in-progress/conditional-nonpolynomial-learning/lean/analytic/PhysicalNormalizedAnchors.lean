import PhysicalCanonicalScaledStep
import PhysicalCanonicalAnchorProgram
import PhysicalCanonicalQueryMoments
import CanonicalCompression

/-! Uniform normalized anchor compression. Entropy cutoffs grow with the
actual sharp physical Gaussian gain, so the number of anchors stays
polynomial even when intermediate feature scales are extremely small. -/
noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.ConcreteModel
open NeuralGeneralization.GaussianFieldTilt

lemma gaussianAnchorModulus_mul_le {η G : ℝ} (hη : 0≤η) (hG : 1≤G) :
    gaussianAnchorModulus (η*G)≤G*gaussianAnchorModulus η := by
  have hGp : 0≤G := le_trans zero_le_one hG
  have hroot : Real.sqrt (Real.sqrt G)≤G := by
    have hsq : G≤G^2 := by nlinarith
    have hs : Real.sqrt G≤G := (Real.sqrt_le_iff).mpr ⟨hGp,hsq⟩
    exact (Real.sqrt_le_iff).mpr ⟨hGp,hs.trans hsq⟩
  have hm := mul_le_mul_of_nonneg_left hroot (Real.sqrt_nonneg (Real.sqrt η))
  unfold gaussianAnchorModulus
  rw [Real.sqrt_mul hη,Real.sqrt_mul (Real.sqrt_nonneg η)]
  nlinarith

def normalizedAnchorError (η : ℝ) : ℝ :=
  Real.sqrt 2*Real.sqrt (gaussianAnchorModulus η)

lemma normalizedAnchorError_nonneg (η : ℝ) : 0≤normalizedAnchorError η := by
  unfold normalizedAnchorError
  positivity

lemma gaussianEntropyGain_cost_ratio {D η : ℝ} (hD : 0≤D) (hη : 0<η) :
    D/(η*gaussianEntropyGain D)≤1/(2*η) := by
  have hg := gaussianEntropyGain_one_le D
  have hl := Real.log_nonneg hg
  have hc := gaussianEntropyGain_cost hD
  unfold gaussianVarianceCost at hc
  have hbound : 2*D≤gaussianEntropyGain D := by linarith
  apply (div_le_div_iff₀ (mul_pos hη (lt_of_lt_of_le zero_lt_one hg)) (by positivity)).mpr
  nlinarith

lemma physicalLayerGain_eq (P : ControlledMarginPath d H t f) (j : ℕ) :
    physicalLayerGain P j=t*Real.sqrt (gaussianEntropyGain (physicalLayerCost P j)) := by
  unfold physicalLayerGain
  rw [physicalVariance_coe,Real.sqrt_sq_eq_abs,abs_of_pos P.scale_positive]

lemma physical_feature_gain_norm (P : ControlledMarginPath d H t f)
    (hd : 1≤d) (j : ℕ) (hj : j≤H) (x : Cube d) :
    ‖P.feature j x‖≤Real.sqrt 2*physicalGainProduct P j := by
  have hh := physical_gain_product_variance P 0 j (Nat.zero_le _) hj x
  have hi : ‖P.feature 0 x‖^2≤2 := by
    rw [← real_inner_self_eq_norm_sq,P.initial,real_inner_self_eq_norm_sq]
    exact normalizedInputFeature_norm_sq_le_two hd x
  simp only [physicalGainProduct_zero,one_pow,mul_one] at hh
  have hb := mul_le_mul_of_nonneg_right hi (sq_nonneg (physicalGainProduct P j))
  have hsq : (Real.sqrt 2)^2=2 := Real.sq_sqrt (by norm_num)
  have hn : 0≤Real.sqrt 2*physicalGainProduct P j :=
    mul_nonneg (Real.sqrt_nonneg _) (physicalGainProduct_pos P j).le
  nlinarith [norm_nonneg (P.feature j x)]

lemma physical_anchor_error_normalized (P : ControlledMarginPath d H t f)
    (hd : 1≤d) (j : ℕ) (hj : j≤H) (x : Cube d) {η : ℝ} (hη : 0<η) :
    (t*‖P.feature j x‖)*Real.sqrt
      (gaussianAnchorModulus (η*gaussianEntropyGain (physicalLayerCost P j)))≤
      physicalGainProduct P (j+1)*normalizedAnchorError η := by
  have hg := gaussianEntropyGain_one_le (physicalLayerCost P j)
  have hm := Real.sqrt_le_sqrt (gaussianAnchorModulus_mul_le hη.le hg)
  rw [Real.sqrt_mul (le_trans zero_le_one hg)] at hm
  have hn := physical_feature_gain_norm P hd j hj x
  calc
    _ ≤ (t*(Real.sqrt 2*physicalGainProduct P j))*
        (Real.sqrt (gaussianEntropyGain (physicalLayerCost P j))*
          Real.sqrt (gaussianAnchorModulus η)) := by
      exact mul_le_mul (mul_le_mul_of_nonneg_left hn P.scale_positive.le) hm
        (Real.sqrt_nonneg _) (mul_nonneg P.scale_positive.le
          (mul_nonneg (Real.sqrt_nonneg _) (physicalGainProduct_pos P j).le))
    _ = _ := by rw [physicalGainProduct_succ,physicalLayerGain_eq]; unfold normalizedAnchorError; ring

/-- Actual canonical Gaussian program at arbitrary physical scale. Its query
error is proportional to the physical gain product, with a scale-independent
normalized precision and per-layer anchor budget. -/
theorem physical_normalized_query_program {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (S : Finset (Cube d))
    {η : ℝ} (hη : 0<η)
    (hgap : ∀j<H,∀x,coordinateEntropy (P.law j)
      (fieldLaw (scaledFeatureCoefficients t (P.feature j))) (insert x S)-
      coordinateEntropy (P.law j) (fieldLaw (scaledFeatureCoefficients t (P.feature j))) S≤
      η*gaussianEntropyGain (physicalLayerCost P j)) :
    ∃states : ℕ → CanonicalProgramState d,
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (∀j≤H,(states j).physicalAnchorInvariant P S j) ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      (∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1))) ∧
      ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x
        ((j:ℝ)*normalizedAnchorError η*physicalGainProduct P j) := by
  obtain ⟨states,hidx,hzero,hanchor,hdim,hstep⟩ := physical_canonical_anchor_program P S
  refine ⟨states,hzero,hanchor,hdim,hstep,?_⟩
  intro j
  induction j with
  | zero =>
    intro hj x
    simp only [Nat.cast_zero,zero_mul]
    apply queryFeatureClose_of_gram_eq
    intro u v
    exact (P.initial u v).trans (hzero u v).symm
  | succ j ih =>
    intro hj x
    have hjlt : j<H := by omega
    letI := P.probability j hjlt
    have hηj : 0<η*gaussianEntropyGain (physicalLayerCost P j) :=
      mul_pos hη (lt_of_lt_of_le zero_lt_one (gaussianEntropyGain_one_le _))
    have he : 0≤(j:ℝ)*normalizedAnchorError η*physicalGainProduct P j :=
      mul_nonneg (mul_nonneg (Nat.cast_nonneg _) (normalizedAnchorError_nonneg _))
        (physicalGainProduct_pos P j).le
    have hs := physical_canonical_query_step_scaled (P.feature j) (states j).feature
      (P.feature (j+1)) (states (j+1)).feature (P.law j) P.scale_positive.le
      (P.finiteKL j hjlt) S x he hηj (ih (by omega) x) (hgap j hjlt x)
      (P.recursion j hjlt) ((hstep j hjlt).queryMoments x)
    apply hs.mono
    have hb := physical_anchor_error_normalized P hd j (by omega) x hη
    change _+(t*Real.sqrt (gaussianEntropyGain (physicalLayerCost P j)))*_≤_
    rw [← physicalLayerGain_eq,physicalGainProduct_succ,Nat.cast_add,Nat.cast_one]
    rw [physicalGainProduct_succ] at hb
    nlinarith only [hb]

#print axioms physical_normalized_query_program
end ConditionalNonpolynomial.Analytic
