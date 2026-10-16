import NeuralGeneralization.SmallSampleParity
import NeuralGeneralization.GaussianParityConfidence
import NeuralGeneralization.GaussianSignPosteriorBridge
import NeuralGeneralization.ParityModelBridge

/-! The small-sample Gaussian sign posterior: actual buffered confidence,
not a classifier formed from the sign of the posterior mean. -/
noncomputable section
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.GaussianSmallSample
open GaussianSignCone GaussianSignRegression GaussianPosteriorFeatures GaussianWalshMeanTail
open GaussianWalshResidual GaussianResidualIndependence GaussianSignConfidence GaussianParityConfidence
variable {d : ℕ} {J : Type*} [Fintype J]

/-- Finite quantitative ABFR bound for the actual conditioned Gaussian sign
posterior. No control of the low-degree mean norm is required. -/
theorem failure_lower_of_ABFR_spectrum {u t : ℕ}
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (A : J → Finset (Fin d) → ℝ)
    (hprob : (Measure.pi (fun _ : Finset (Fin d) => gaussianReal 0 1)) (signCone A) ≠ 0)
    (H : Finset (Finset (Fin d))) (hdegree : ∀ S ∈ H, S.card ≤ u) (hut : u+2*t < d)
    (ell b : ℝ) (hell : 0 ≤ ell) (hb : 0 < b)
    (hmax : ∀ S ∈ Finset.univ \ H, w S ≤ ell)
    (htau : 0 < ∑ S ∈ Finset.univ \ H, w S)
    (hmargin : b ≤ Real.sqrt (Real.pi * (∑ S ∈ Finset.univ \ H, w S)) *
      (Real.exp (-1) - 7 / 20)) :
    (Fintype.card (DegreeIndices d t) : ℝ)/Fintype.card (ClippingCube d) -
      2*Fintype.card J*ell/(∑ S ∈ Finset.univ \ H, w S) -
      Fintype.card J*ell/b^2 ≤ ConfidenceClipping.failure (confidence w A) (13/20) := by
  classical
  let T := Finset.univ \ H
  let tau : ℝ := ∑ S ∈ T, w S
  let V : Set (ClippingCube d) :=
    {x | residualVariance (observationSpan A) (featureVector w x) < tau/2}
  have hdeg : ∀ S, maskCoefficients H (posteriorCoefficients A w) S ≠ 0 → S.card ≤ u := by
    intro S hS
    by_cases h : S ∈ H
    · exact hdegree S h
    · exact False.elim (hS (by simp [maskCoefficients, h]))
  have hm := confidence_failure_lower_of_ABFR_approximation
    (maskCoefficients H (posteriorCoefficients A w)) hdeg hut
    (confidence w A) (meanField w A) (13/20) b hb V (fun x hq hx => by
      have hvar : tau/2 ≤ residualVariance (observationSpan A) (featureVector w x) :=
        le_of_not_gt hx
      have hv : 0 < GaussianSignConfidence.variance A (signedFeature w x) := by
        rw [signedFeature_variance]
        exact (half_pos htau).trans_le hvar
      have hh := buffered_confidence_mean_margin A (signedFeature w x) hprob hv hq
      rw [signedFeature_variance, signedFeature_mean w A hprob x] at hh
      have hs : Real.pi*tau ≤ 2*Real.pi*residualVariance (observationSpan A) (featureVector w x) := by
        nlinarith [Real.pi_pos]
      exact hmargin.trans ((mul_le_mul_of_nonneg_right (Real.sqrt_le_sqrt hs)
        buffered_confidence_constant_pos.le).trans hh.le))
  have hV : ConfidenceClipping.fraction V ≤ 2*Fintype.card J*ell/tau := by
    rw [fraction_eq_filter_card]
    exact small_variance_fraction_le w (fun S => (hw S).le) T ell hell hmax htau A
  have hfun (x : ClippingCube d) : meanField w A x-
      walshExpansion (maskCoefficients H (posteriorCoefficients A w)) x =
      walshExpansion (maskCoefficients T (posteriorCoefficients A w)) x := by
    have he := featureField_decomposition walshCharacter (posteriorCoefficients A w) H x
    change meanField w A x = walshExpansion (maskCoefficients H (posteriorCoefficients A w)) x +
      walshExpansion (maskCoefficients T (posteriorCoefficients A w)) x at he
    linarith
  have htail := posterior_tail_mean_square_le w hw A hprob T ell hell hmax
  simp_rw [hfun] at hm
  have hdiv := div_le_div_of_nonneg_right htail (sq_nonneg b)
  change _ ≤ 2*Fintype.card J*ell/(∑ S ∈ Finset.univ \ H, w S) at hV
  linarith

open SmallSampleCutoff

/-- Uniform small-sample buffered-confidence failure for actual neural
Gaussian sign conditioning. This holds for every observation matrix,
including singular matrices, whenever the conditioning event is positive. -/
theorem eventually_neural_confidence_failure (ε : ℝ) (hε : 0 < ε) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ, (n : ℝ) ≤ Real.exp (logDimension d^3) →
      ∀ k : ℕ, ∀ A : Fin n → Finset (Fin d) → ℝ,
      (Measure.pi (fun _ : Finset (Fin d) => gaussianReal 0 1)) (signCone A) ≠ 0 →
      (1/2 : ℝ)-ε ≤ ConfidenceClipping.failure
        (confidence (walshCoefficients (arcsineProfile d (k+1))) A) (13/20) := by
  classical
  let c : ℝ := Real.exp (-1)-7/20
  have hc : 0 < c := buffered_confidence_constant_pos
  let B : ℝ := 2+1/(Real.pi*c^2)
  have hB : 0 ≤ B := by dsimp [B]; positivity
  have hlim : Tendsto (fun d : ℕ => 2*B/((d : ℝ)+1)) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop (tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop)
  filter_upwards [eventually_ABFR_lower (ε/2) (by positivity), eventually_choose_lower,
    eventually_small_sample_ratio 1 (by norm_num) 0,
    hlim.eventually (eventually_le_nhds (show (0 : ℝ)<ε/2 by positivity))]
    with d hd hchoose hratio hnum n hn k A hprob
  let w := walshCoefficients (arcsineProfile d (k+1))
  let H := lowBand d
  let T := Finset.univ \ H
  let τ : ℝ := ∑ S ∈ T, w S
  let D : ℝ := d.choose (cutoff d)
  let ell : ℝ := τ/D
  let b : ℝ := Real.sqrt (Real.pi*τ)*c
  have hw : ∀ S, 0 < w S := iterated_arcsine_coefficient_pos d k
  have hD : 0 < D := (Real.exp_pos _).trans_le hchoose
  have hT : T = Finset.univ.filter (fun S : Finset (Fin d) => cutoff d ≤ S.card) := by
    ext S
    simp [T, H, lowBand]
  have hτ : 0 < τ := by
    apply Finset.sum_pos' (fun S hS => (hw S).le)
    refine ⟨Finset.univ, ?_, hw Finset.univ⟩
    rw [hT]
    simp only [Finset.mem_filter, Finset.mem_univ, Finset.card_univ, Fintype.card_fin, true_and]
    exact hd.1.le
  have hτeq : τ=walshSpectralTail (arcsineProfile d (k+1)) (cutoff d) := by
    dsimp [τ]
    rw [hT]
    rfl
  have hell : 0 ≤ ell := div_nonneg hτ.le hD.le
  have hb : 0 < b := mul_pos (Real.sqrt_pos.mpr (mul_pos Real.pi_pos hτ)) hc
  have hb2 : b^2=Real.pi*τ*c^2 := by
    dsimp [b]
    rw [mul_pow, Real.sq_sqrt (mul_pos Real.pi_pos hτ).le]
  have hdegree : ∀ S ∈ H, S.card ≤ cutoff d := by
    intro S hS
    exact (Finset.mem_filter.mp hS).2.le
  have hst : cutoff d+2*((d-cutoff d-1)/2) < d := by omega
  have hmax : ∀ S ∈ Finset.univ \ H, w S ≤ ell := by
    intro S hS
    have hcard : cutoff d ≤ S.card := by simpa [H, lowBand] using hS
    apply (le_div_iff₀ hD).mpr
    rw [hτeq]
    simpa only [mul_comm] using arcsineProfile_coefficient_binomial_le_tail (k+1) (cutoff d) S hcard
  have hfin := failure_lower_of_ABFR_spectrum w hw A hprob H hdegree hst ell b hell hb hmax hτ le_rfl
  have he1 : 2*(n : ℝ)*ell/τ=2*((n : ℝ)/D) := by dsimp [ell]; field_simp
  have he2 : (n : ℝ)*ell/b^2=((n : ℝ)/D)/(Real.pi*c^2) := by
    rw [hb2]
    dsimp [ell]
    field_simp
  simp only [Fintype.card_fin] at hfin
  change _ - 2*(n : ℝ)*ell/τ - (n : ℝ)*ell/b^2 ≤ _ at hfin
  rw [he1, he2] at hfin
  have hrat : (n : ℝ)/D ≤ 2/((d : ℝ)+1) := by
    have hh := hratio (n : ℝ) (Nat.cast_nonneg _) hn
    simp only [pow_zero, one_mul, mul_one] at hh
    exact (div_le_div_of_nonneg_right (by linarith : (n : ℝ) ≤ 1+n) hD.le).trans hh
  have herr : B*((n : ℝ)/D) ≤ ε/2 := by
    have hh := mul_le_mul_of_nonneg_left hrat hB
    have hid : B*(2/((d : ℝ)+1))=2*B/((d : ℝ)+1) := by ring
    rw [hid] at hh
    exact hh.trans hnum
  dsimp [B] at herr
  rw [show (2+1/(Real.pi*c^2))*((n : ℝ)/D) =
    2*((n : ℝ)/D)+((n : ℝ)/D)/(Real.pi*c^2) by ring] at herr
  change (1/2 : ℝ)-ε ≤ ConfidenceClipping.failure (confidence w A) (13/20)
  linarith [hd.2]

/-- The preceding confidence theorem is about the actual finite Boolean
function posterior used in the negative-gamma width limit. It holds for
every training sample, with no random-sample exceptional event. -/
theorem eventually_neural_function_posterior_failure (ε : ℝ) (hε : 0 < ε) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ, (n : ℝ) ≤ Real.exp (logDimension d^3) →
      ∀ k : ℕ, ∀ sample : Fin n → ConcreteModel.Cube d,
      (1/2 : ℝ)-ε ≤ ConfidenceClipping.failure
        (ConcreteModel.correctConfidence (ConcreteModel.parity d)
          (posterior (NetworkGaussianFunctionLimit.gaussianFunctionMass d k 0)
            (ConcreteModel.consistent (ConcreteModel.parity d) sample))) (13/20) := by
  classical
  filter_upwards [eventually_neural_confidence_failure ε hε] with d hd n hn k sample
  let w := walshCoefficients (arcsineProfile d (k+1))
  let A := GaussianSignPosteriorBridge.trainingCoefficients w (ConcreteModel.parity d) sample
  have hprob : (Measure.pi (fun _ : Finset (Fin d) => gaussianReal 0 1)) (signCone A) ≠ 0 :=
    GaussianSignPosteriorBridge.training_probability_ne_zero w (iterated_arcsine_coefficient_pos d k)
      (ConcreteModel.parity d) sample
  have heq : ConcreteModel.correctConfidence (ConcreteModel.parity d)
      (posterior (NetworkGaussianFunctionLimit.gaussianFunctionMass d k 0)
        (ConcreteModel.consistent (ConcreteModel.parity d) sample)) = confidence w A := by
    funext x
    rw [GaussianSignPosteriorBridge.arcsine_correctConfidence_eq_conditionedOutput]
    unfold confidence
    congr 2
    funext S
    simp only [GaussianSignPosteriorBridge.predictionCoefficients, signedFeature, labelReal_parity]
    ring
  rw [heq]
  exact hd n hn k A hprob

end NeuralGeneralization.GaussianSmallSample
