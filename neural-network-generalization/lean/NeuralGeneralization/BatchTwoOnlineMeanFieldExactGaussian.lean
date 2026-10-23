import NeuralGeneralization.BatchTwoOnlineMeanFieldExactBudgets
import NeuralGeneralization.MeanFieldHiddenTail

/-! Literal covariance-coordinate entropy in the actual Gaussian row law. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoOnlineMeanFieldExact
open ConcreteModel GaussianDualLayer GaussianDualMatrix GaussianAngularPrice GaussianFieldTilt
open CompressionSampling CovarianceDualLift DualCertificate

variable {d N : ℕ} {J R : Type*} [Fintype J] [Fintype R]

theorem covariance_bad_event_tail (μ : Measure (Cube d→ℝ)) [IsProbabilityMeasure μ]
    {N s : ℕ} (hN : 0<N) (hs : 0<s) {G : ℝ} (hG : 0<G) (K : ℝ) :
    (iidSamples μ N).real (DualCertificate.badEvent μ (features Real.tanh) N G K)≤
      Real.exp ((s:ℝ)*testEntropy d-(N:ℝ)*(K-G^2/(2*(s:ℝ)))) := by
  have hh:=bounded_dual_tail_exp μ (features Real.tanh)
    (measurable_features Real.tanh TanhDifferential.continuous_tanh.measurable)
    (features_bound Real.tanh (fun z=>(Real.abs_tanh_lt_one z).le)) hN hs hG K
  simpa only [testEntropy,CovarianceIndexCounting.covariance_index_card,Nat.cast_pow,Nat.cast_ofNat] using hh

theorem rawBadRows_tail (A : Cube d→J→ℝ) (H : Cube d→R→ℝ)
    (v : ℝ≥0) (hcov : ∀x y,(v:ℝ)*gram H x y=gram A x y)
    {N s : ℕ} (hN : 0<N) (hs : 0<s) {G : ℝ} (hG : 0<G) (K : ℝ) :
    (iidSamples (Measure.pi (fun _:R=>gaussianReal 0 v)) N).real (rawBadRows A H N G K)≤
      Real.exp ((s:ℝ)*testEntropy d-(N:ℝ)*(K-G^2/(2*(s:ℝ)))) := by
  have hb:=covariance_bad_event_tail (fieldLaw A) hN hs hG K
  rw [←map_raw_rows A H v hcov,Measure.real,Measure.map_apply (measurable_rows H)
    (DualCertificate.measurableSet_badEvent (fieldLaw A) (features Real.tanh)
      (fun p=>(TanhDifferential.continuous_tanhPairValue p.1 p.2).measurable) N G K)] at hb
  exact hb

theorem badMatrix_tail (A : Cube d→J→ℝ) (H : Cube d→R→ℝ)
    (v : ℝ≥0) (hcov : ∀x y,(v:ℝ)*gram H x y=gram A x y)
    {N s : ℕ} (hN : 0<N) (hs : 0<s) {G : ℝ} (hG : 0<G) (K : ℝ) :
    (Measure.pi (fun _:Fin N×R=>gaussianReal 0 v)).real (badMatrix A H N G K)≤
      Real.exp ((s:ℝ)*testEntropy d-(N:ℝ)*(K-G^2/(2*(s:ℝ)))) := by
  have hp:=LayerGramConcentration.measurePreserving_uncurry (fun (_:Fin N) (_:R)=>gaussianReal 0 v)
  rw [←hp.map_eq,Measure.real,Measure.map_apply hp.measurable (measurableSet_badMatrix A H N G K)]
  exact rawBadRows_tail A H v hcov hN hs hG K

end NeuralGeneralization.BatchTwoOnlineMeanFieldExact
