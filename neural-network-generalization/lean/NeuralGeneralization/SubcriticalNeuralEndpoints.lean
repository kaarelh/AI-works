import NeuralGeneralization.ParityModelBridge
import NeuralGeneralization.GaussianSignPosteriorBridge
import NeuralGeneralization.GaussianParityConfidence
import NeuralGeneralization.GaussianZeroModelBridge
import NeuralGeneralization.NetworkSubcriticalWalshRate

/-! Exact neural endpoint identifications, with all label and normalization
conventions retained. These do not assume a Gaussian limit: that limit is proved. -/
noncomputable section
namespace NeuralGeneralization.SubcriticalNeuralEndpoints
open scoped BigOperators Topology
open ConcreteModel NetworkGaussianFunctionLimit GaussianSignPosteriorBridge
open Filter
variable {d n : ℕ}

lemma uniform_bufferedFailure_eq (q : Cube d → ℝ) (b : ℝ) :
    (∑ x, if q x ≤ b then (uniformLaw d).mass x else 0) = ConfidenceClipping.failure q b := by
  classical
  simp only [uniformLaw, ConfidenceClipping.failure, ConfidenceClipping.fraction,
    uniformCubeMean, Set.mem_setOf_eq, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro x _
  split_ifs <;> simp

lemma parity_gaussian_confidence_eq (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (s : Fin n → Cube d) (x : Cube d) :
    correctConfidence (parity d) (posterior (walshFunctionMass w 0) (consistent (parity d) s)) x =
      GaussianParityConfidence.confidence w
        (GaussianPosteriorFeatures.trainingMatrix (fun S x => walshCharacter S x) w s
          (fun j => fullParity (s j))) x := by
  rw [walsh_correctConfidence_eq_conditionedOutput w hw]
  have hp : predictionCoefficients w (parity d) x = GaussianParityConfidence.signedFeature w x := by
    funext S
    simp only [predictionCoefficients, GaussianParityConfidence.signedFeature, labelReal_parity, mul_assoc]
  simp only [GaussianParityConfidence.confidence, trainingCoefficients, labelReal_parity, hp]

/-- An actual buffered failure bound for the sign-conditioned Gaussian
posterior transfers to every negative gamma in the original neural model. -/
theorem negative_confidence_liminf_of_gaussian_failure (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ : γ < 0) (a : ℝ) (s : Fin n → Cube d) (b : ℝ) (hb : b < 2/3) :
    ConfidenceClipping.failure
      (GaussianParityConfidence.confidence (walshCoefficients (arcsineProfile d (r+1)))
        (GaussianPosteriorFeatures.trainingMatrix (fun S x => walshCharacter S x)
          (walshCoefficients (arcsineProfile d (r+1))) s (fun j => fullParity (s j)))) b ≤
      Filter.liminf (fun N => ConcreteModel.confidenceFailure (uniformLaw d) (parity d)
        (networkPosterior Real.tanh a (powerPrior d N r γ) (parity d) s)) atTop := by
  have h := gamma_negative_confidence_liminf hd r hγ a (parity d) s (uniformLaw d) b hb
  rw [uniform_bufferedFailure_eq] at h
  have he : gaussianFunctionMass d r 0 =
      walshFunctionMass (walshCoefficients (arcsineProfile d (r+1))) 0 := rfl
  rw [he] at h
  have heq := funext (parity_gaussian_confidence_eq _ (iterated_arcsine_coefficient_pos d r) s)
  rw [heq] at h
  exact h

/-- Posterior normalization eventually holds simultaneously for every sample,
for every fixed subcritical exponent, without any sample-size restriction. -/
theorem subcritical_denominators_eventually_pos (hd : 0 < d) (r : ℕ)
    {γ a : ℝ} (hγ : γ < 1) (ha : 0 < a) (f : BooleanFunction d) :
    ∀ᶠ N : ℕ in atTop, ∀ s : Fin n → Cube d,
      0 < posteriorDenominator Real.tanh a (powerPrior d N r γ) f s := by
  have hmass : ∀ᶠ N : ℕ in atTop,
      0 < functionMass Real.tanh a (powerPrior d N r γ) f := by
    rcases lt_trichotomy γ 0 with hn | he | hp
    · exact (gamma_negative_functionMass_tendsto hd r hn a f).eventually
        (eventually_gt_nhds (gaussianFunctionMass_pos d r 0 f))
    · subst γ
      exact (gamma_zero_functionMass_tendsto hd r a f).eventually
        (eventually_gt_nhds (gaussianFunctionMass_pos d r a f))
    · exact (NetworkSubcriticalWalshRate.actual_functionMass_hasExponentialRate hd r hp hγ ha f).eventually_pos
  filter_upwards [hmass] with N hN
  intro s
  exact ConcreteModel.posteriorDenominator_pos Real.tanh a (powerPrior d N r γ) f s hN

/-- Fixed-margin Gaussian confidence is transferred with the actual global
conditioning event intact; no posterior-mean prediction rule is used. -/
theorem zero_confidence_liminf_of_gaussian_failure (hd : 0 < d) (r : ℕ)
    {a : ℝ} (ha : 0 ≤ a) (s : Fin n → Cube d) (b : ℝ) (hb : b < 2/3) :
    ConfidenceClipping.failure (GaussianMarginConfidence.confidence
      (ProbabilityTheory.cond
        (GaussianFieldTilt.fieldLaw (WalshGaussianEnergy.matrix (walshCoefficients (arcsineProfile d (r+1)))))
        (FieldPosteriorBridge.conditioningEvent id a (parity d) s))) b ≤
      Filter.liminf (fun N => ConcreteModel.confidenceFailure (uniformLaw d) (parity d)
        (networkPosterior Real.tanh a (powerPrior d N r 0) (parity d) s)) atTop := by
  have h := gamma_zero_confidence_liminf hd r a (parity d) s (uniformLaw d) b hb
  rw [uniform_bufferedFailure_eq] at h
  have he : gaussianFunctionMass d r a =
      walshFunctionMass (walshCoefficients (arcsineProfile d (r+1))) a := rfl
  rw [he, GaussianZeroModelBridge.buffered_failure_eq _ ha] at h
  exact h

end NeuralGeneralization.SubcriticalNeuralEndpoints
