import NeuralGeneralization.RobustCouplingGaussianScale
import NeuralGeneralization.RobustCompressionGridPadding
import NeuralGeneralization.RobustStatisticsCoupling
import NeuralGeneralization.ModelFacts

/-!
# Small-width compression by a genuine finite-grid pushforward

The actual Gaussian KL budget gives a uniform physical second moment after
cancelling the common noise scale. The globally defined clamp-and-round map
then produces one candidate distribution for all inputs at once.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped ENNReal NNReal
namespace NeuralGeneralization.ConcreteModel
open RobustCoupling

def normalizedPhysicalVariance (d N r : ℕ) : WeightIndex d N r → ℝ≥0
  | Sum.inl _ => (1 / (d : ℝ)).toNNReal
  | Sum.inr (Sum.inl _) => (1 / (N : ℝ)).toNNReal
  | Sum.inr (Sum.inr _) => (1 / (N : ℝ) ^ 2).toNNReal

theorem normalizedPhysicalVariance_le_one {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (i : WeightIndex d N r) : normalizedPhysicalVariance d N r i ≤ 1 := by
  have hd' : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hN' : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hd0 : (0 : ℝ) < d := by positivity
  have hN0 : (0 : ℝ) < N := by positivity
  rcases i with ij | (sij | j)
  all_goals
    apply NNReal.coe_le_coe.mp
    simp only [normalizedPhysicalVariance, NNReal.coe_one]
    rw [Real.coe_toNNReal _ (by positivity)]
  · exact (div_le_one hd0).mpr hd'
  · exact (div_le_one hN0).mpr hN'
  · exact (div_le_one (sq_pos_of_pos hN0)).mpr (by nlinarith)

theorem smallPrior_eq_scaledDiagonalGaussian {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ t : ℝ} (hscale : t ^ 2 = N * σ ^ 2) :
    smallPrior d N r σ = scaledDiagonalGaussian (normalizedPhysicalVariance d N r) t := by
  have hd0 : (0 : ℝ) < d := by positivity
  have hN0 : (0 : ℝ) < N := by positivity
  unfold smallPrior productGaussian scaledDiagonalGaussian
  congr 1
  funext i
  apply congrArg (gaussianReal 0)
  apply NNReal.eq
  rcases i with ij | (sij | j)
  all_goals
    simp only [smallVariance, normalizedPhysicalVariance, NNReal.coe_mul]
    repeat rw [Real.coe_toNNReal _ (by positivity)]
    rw [hscale]
  · ring
  · field_simp
  · field_simp

theorem smallPrior_entropy_physical_moment {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ t K : ℝ} (hK : 0 ≤ K) (ht : 0 < t) (ht1 : t ^ 2 ≤ 1) (hscale : t ^ 2 = N * σ ^ 2)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (N * K / t ^ 2)) :
    Integrable (fun w : Weights d N r => ∑ i, w i ^ 2) Q ∧
      (∫ w : Weights d N r, ∑ i, w i ^ 2 ∂Q) ≤
        4 * N * K + 2 * robustParameterCount d N r := by
  have hfinite : klDiv Q (smallPrior d N r σ) ≠ ⊤ :=
    ne_top_of_le_ne_top ENNReal.ofReal_ne_top hKL
  have heq := smallPrior_eq_scaledDiagonalGaussian hd hN hscale (r := r)
  obtain ⟨hi, hm⟩ := scaled_gaussian_entropy_second_moment
    (normalizedPhysicalVariance d N r) (normalizedPhysicalVariance_le_one hd hN) ht Q
    (by rwa [← heq])
  refine ⟨hi, ?_⟩
  rw [← heq, robustWeightIndex_card] at hm
  have hK0 : 0 ≤ N * K / t ^ 2 := by positivity
  have hkr := ENNReal.toReal_mono ENNReal.ofReal_ne_top hKL
  rw [ENNReal.toReal_ofReal hK0] at hkr
  have hmul := mul_le_mul_of_nonneg_left hkr (by positivity : 0 ≤ 4 * t ^ 2)
  have hcancel : 4 * t ^ 2 * (N * K / t ^ 2) = 4 * N * K := by field_simp
  rw [hcancel] at hmul
  have hdimbound := mul_le_mul_of_nonneg_right ht1
    (by positivity : 0 ≤ 2 * (robustParameterCount d N r : ℝ))
  nlinarith

theorem physical_moment_boundedWeights_tail {d N r : ℕ}
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hi : Integrable (fun w : Weights d N r => ∑ i, w i ^ 2) Q)
    {B α : ℝ} (hB : 0 < B)
    (hbudget : (∫ w : Weights d N r, ∑ i, w i ^ 2 ∂Q) ≤ α * B ^ 2) :
    Q.real {w | ¬ boundedWeights B w} ≤ α := by
  have hsub : {w : Weights d N r | ¬ boundedWeights B w} ⊆
      {w | B ^ 2 ≤ ∑ i, w i ^ 2} := by
    intro w hw
    obtain ⟨i, hi⟩ := not_forall.mp hw
    have habs : B < |w i| := lt_of_not_ge hi
    have hs := Finset.single_le_sum (fun j (_ : j ∈ Finset.univ) => sq_nonneg (w j))
      (Finset.mem_univ i)
    have hsq : B ^ 2 ≤ (w i) ^ 2 := by nlinarith [sq_abs (w i)]
    exact hsq.trans hs
  have hm := mul_meas_ge_le_integral_of_nonneg
    (μ := Q) (Filter.Eventually.of_forall (fun w => Finset.sum_nonneg (fun i _ => sq_nonneg (w i)))) hi (B ^ 2)
  have hmono : Q.real {w | ¬ boundedWeights B w} ≤ Q.real {w | B ^ 2 ≤ ∑ i, w i ^ 2} :=
    ENNReal.toReal_mono (measure_ne_top _ _) (measure_mono hsub)
  have htail : Q.real {w | B ^ 2 ≤ ∑ i, w i ^ 2} ≤ α := by
    nlinarith [sq_pos_of_pos hB]
  exact hmono.trans htail

/-- Deterministic graph coupling for the globally defined padded rounder. -/
def smallWidthGridCoupling {d N M r : ℕ}
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hNM : N ≤ M) (B R : ℕ) :
    RobustStatistics.ProbabilityCoupling Q
      (Q.map (padAndRoundCode (d := d) (r := r) hNM B R)) where
  joint := Q.map (fun w => (id w, padAndRoundCode hNM B R w))
  probability := Measure.isProbabilityMeasure_map
    (measurable_id.prodMk (measurable_padAndRoundCode hNM B R)).aemeasurable
  left := by
    rw [Measure.map_map measurable_fst
      (measurable_id.prodMk (measurable_padAndRoundCode hNM B R))]
    exact Measure.map_id
  right := by
    rw [Measure.map_map measurable_snd
      (measurable_id.prodMk (measurable_padAndRoundCode hNM B R))]
    rfl

/-- Failure is simultaneous over the entire Boolean input cube. -/
def gridOutputFailure (d N M r B R : ℕ) (φ : ℝ → ℝ) :
    Set (Weights d N r × RobustOutputCode d M r B R) :=
  {p | ∃ x : Cube d, 1 / (R : ℝ) <
    |networkOutput φ p.1 x - robustGridOutput d M r B R φ p.2 x|}

theorem measurable_gridOutputFailure (d N M r B R : ℕ) (φ : ℝ → ℝ)
    (hφ : Continuous φ) : MeasurableSet (gridOutputFailure d N M r B R φ) := by
  have hg (x : Cube d) : Measurable (fun q : RobustOutputCode d M r B R =>
      robustGridOutput d M r B R φ q x) := measurable_of_countable _
  unfold gridOutputFailure
  have heq : {p : Weights d N r × RobustOutputCode d M r B R |
      ∃ x : Cube d, 1 / (R : ℝ) < |networkOutput φ p.1 x - robustGridOutput d M r B R φ p.2 x|} =
      ⋃ x : Cube d, {p : Weights d N r × RobustOutputCode d M r B R |
      1 / (R : ℝ) < |networkOutput φ p.1 x - robustGridOutput d M r B R φ p.2 x|} := by ext p; simp
  rw [heq]
  apply MeasurableSet.iUnion
  intro x
  exact measurableSet_lt measurable_const
    (((continuous_networkOutput hφ x).measurable.comp measurable_fst).sub
      ((hg x).comp measurable_snd)).abs

/-- The single grid law and graph coupling work for every input simultaneously. -/
theorem smallWidthGridCoupling_failure_le {d N M r B R : ℕ}
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q] (hNM : N ≤ M)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (hB : 0 < B) (hR : 0 < R)
    {α : ℝ} (htail : Q.real {w | ¬ boundedWeights B w} ≤ α) :
    (smallWidthGridCoupling Q hNM B R).joint.real (gridOutputFailure d N M r B R φ) ≤ α := by
  have hm := measurable_id.prodMk (measurable_padAndRoundCode (d := d) (r := r) hNM B R)
  have hs := measurable_gridOutputFailure d N M r B R φ (admissibleActivation_continuous hφ)
  change (Q.map (fun w => (id w, padAndRoundCode hNM B R w))).real _ ≤ α
  rw [measureReal_def, Measure.map_apply hm hs]
  refine (ENNReal.toReal_mono (measure_ne_top _ _) (measure_mono ?_)).trans htail
  intro w hw
  intro hgood
  obtain ⟨x, hx⟩ := hw
  exact (not_lt_of_ge (padAndRoundCode_output_close hNM φ hφ hB hR w hgood x)) hx


theorem robustParameterCount_mono_width {d N M r : ℕ} (hNM : N ≤ M) :
    robustParameterCount d N r ≤ robustParameterCount d M r := by
  unfold robustParameterCount
  exact Nat.add_le_add
    (Nat.add_le_add (Nat.mul_le_mul_right _ hNM)
      (Nat.mul_le_mul (Nat.mul_le_mul_left _ hNM) hNM)) hNM

/-- Actual Gaussian KL alone produces a single finite-grid law and an exact
coupling whose raw output error is small on every input simultaneously. -/
theorem smallWidthGridCoupling_of_kl {d N M r B R : ℕ}
    (hd : 0 < d) (hN : 0 < N) (hNM : N ≤ M)
    {σ t K α : ℝ} (hK : 0 ≤ K) (ht : 0 < t) (ht1 : t ^ 2 ≤ 1)
    (hscale : t ^ 2 = N * σ ^ 2)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (N * K / t ^ 2))
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (hB : 0 < B) (hR : 0 < R)
    (hbudget : 4 * M * K + 2 * robustParameterCount d M r ≤ α * (B : ℝ) ^ 2) :
    (smallWidthGridCoupling Q hNM B R).joint.real (gridOutputFailure d N M r B R φ) ≤ α := by
  obtain ⟨hi, hm⟩ := smallPrior_entropy_physical_moment hd hN hK ht ht1 hscale Q hKL
  have hNM' : (N : ℝ) ≤ M := by exact_mod_cast hNM
  have hcard : (robustParameterCount d N r : ℝ) ≤ robustParameterCount d M r := by
    exact_mod_cast robustParameterCount_mono_width (d := d) (r := r) hNM
  have henergy : 4 * N * K + 2 * robustParameterCount d N r ≤
      4 * M * K + 2 * robustParameterCount d M r := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hNM') hK]
  exact smallWidthGridCoupling_failure_le Q hNM φ hφ hB hR
    (physical_moment_boundedWeights_tail Q hi (by exact_mod_cast hB)
      (hm.trans (henergy.trans hbudget)))


/-- The global raw failure bound implies the pointwise clipped-score interface
used by the finite-class statistics theorem. -/
theorem smallWidthGridCoupling_score_failure_le {d N M r B R : ℕ}
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q] (hNM : N ≤ M)
    (φ : ℝ → ℝ) (x : Cube d) {α : ℝ}
    (hR : 1 / (R : ℝ) ≤ 1 / 12)
    (hfail : (smallWidthGridCoupling Q hNM B R).joint.real
      (gridOutputFailure d N M r B R φ) ≤ α) :
    (smallWidthGridCoupling Q hNM B R).joint.real
      (RobustStatistics.scoreFailure (fun w => networkOutput φ w x)
        (fun q => robustGridOutput d M r B R φ q x)) ≤ α := by
  refine (ENNReal.toReal_mono (measure_ne_top _ _) (measure_mono ?_)).trans hfail
  intro p hp
  refine ⟨x, ?_⟩
  have hc := RobustStatistics.clippedScore_lipschitz
    (robustGridOutput d M r B R φ p.2 x) (networkOutput φ p.1 x)
  rw [abs_sub_comm (robustGridOutput d M r B R φ p.2 x) (networkOutput φ p.1 x)] at hc
  exact lt_of_le_of_lt hR (lt_of_lt_of_le hp hc)

end NeuralGeneralization.ConcreteModel
