import NeuralGeneralization.NetworkSubcriticalRate
import NeuralGeneralization.GaussianMarginEnergy

/-! The actual positive-subcritical neural rate in weighted Walsh coordinates,
with the same population-eigenvalue normalization as the kernel energy lemmas. -/
noncomputable section
open Filter MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators Topology NNReal
namespace NeuralGeneralization.NetworkSubcriticalWalshRate
open ConcreteModel GaussianRate GaussianMarginGeometry GaussianMarginLaw GaussianMarginEnergy
open NetworkSubcriticalRate GaussianCovarianceFactor GaussianReadout

def walshMarginSet (d : ℕ) (a : ℝ) (f : BooleanFunction d) : Set (Finset (Fin d) → ℝ) :=
  {c | ∀ x, a < labelReal (f x) * walshExpansion c x}

def walshMarginEnergy (d r : ℕ) (a : ℝ) (f : BooleanFunction d) : ℝ :=
  sInf (featureEnergy (walshCoefficients (arcsineProfile d (r + 1))) '' walshMarginSet d a f) / 2

theorem linearMargin_walsh_eq (d : ℕ) (a : ℝ) (f : BooleanFunction d) :
    linearMargin (signedCoefficients walshCharacter (fun x => labelReal (f x))) a =
      walshMarginSet d a f := by
  ext c
  apply forall_congr'
  intro x
  have he : (∑ i, signedCoefficients walshCharacter (fun x => labelReal (f x)) x i * c i) =
      labelReal (f x) * walshExpansion c x := by
    simp only [signedCoefficients, walshExpansion, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    ring
  exact he ▸ Iff.rfl

theorem walsh_gaussian_margin_nonempty (d r : ℕ) (a : ℝ) (f : BooleanFunction d) :
    (linearMargin (signedCoefficients
      (WalshGaussianLaw.features (walshCoefficients (arcsineProfile d (r + 1))))
      (fun x => labelReal (f x))) a).Nonempty := by
  obtain ⟨z, hz⟩ := WalshGaussianLaw.orthant_nonempty f a
  obtain ⟨c, hc⟩ := WalshGaussianLaw.readout_surjective _ (iterated_arcsine_coefficient_pos d r) z
  refine ⟨c, ?_⟩
  rw [← readout_preimage_fieldMargin]
  change readout (WalshGaussianLaw.features (walshCoefficients (arcsineProfile d (r + 1)))) c ∈
    fieldMargin (fun x => labelReal (f x)) a
  rw [hc]
  exact hz

/-- Exact identity of the canonical Gaussian energy and the normalized
Walsh feature energy; no missing cube-size factor occurs. -/
theorem canonicalMarginEnergy_eq_walshMarginEnergy (d r : ℕ) (a : ℝ) (f : BooleanFunction d) :
    canonicalMarginEnergy d r a f = walshMarginEnergy d r a f := by
  have hgram (x y : Cube d) :
      gram (canonicalFeatures (arcsineCovariance d (r + 1))) x y =
      gram (WalshGaussianLaw.features (walshCoefficients (arcsineProfile d (r + 1)))) x y := by
    rw [gram_canonicalFeatures _ (arcsineCovariance_posSemidef d r),
      WalshGaussianLaw.gram_features _ (fun S => (iterated_arcsine_coefficient_pos d r S).le),
      arcsineCovariance_walsh]
  have he := squareInf_margin_eq_of_gram _ _ hgram (fun x => labelReal (f x)) a
    (canonical_margin_nonempty d r a f) (walsh_gaussian_margin_nonempty d r a f)
  have hweighted := squareInf_weighted_margin walshCharacter
    (walshCoefficients (arcsineProfile d (r + 1))) (iterated_arcsine_coefficient_pos d r)
    (fun x => labelReal (f x)) a
  change squareInf (linearMargin (signedCoefficients
      (WalshGaussianLaw.features (walshCoefficients (arcsineProfile d (r + 1))))
      (fun x => labelReal (f x))) a) = _ at hweighted
  rw [linearMargin_walsh_eq] at hweighted
  exact congrArg (fun E : ℝ => E / 2) (he.trans hweighted)

/-- The main analytic width-limit rate in the paper's weighted Walsh
convention, for the actual finite network and actual full-margin sign mass. -/
theorem actual_functionMass_hasExponentialRate {d : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ0 : 0 < γ) (hγ1 : γ < 1) {a : ℝ} (ha : 0 < a)
    (f : BooleanFunction d) :
    HasExponentialRate atTop (fun N : ℕ => (N : ℝ) ^ γ)
      (fun N => functionMass Real.tanh a (powerPrior d N r γ) f)
      (walshMarginEnergy d r a f) := by
  rw [← canonicalMarginEnergy_eq_walshMarginEnergy]
  exact NetworkSubcriticalRate.actual_functionMass_hasExponentialRate hd r hγ0 hγ1 ha f

theorem posteriorDenominator_eventually_pos {d n : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ0 : 0 < γ) (hγ1 : γ < 1) {a : ℝ} (ha : 0 < a)
    (f : BooleanFunction d) (sample : Fin n → Cube d) :
    ∀ᶠ N : ℕ in atTop, 0 < posteriorDenominator Real.tanh a (powerPrior d N r γ) f sample := by
  filter_upwards [(actual_functionMass_hasExponentialRate hd r hγ0 hγ1 ha f).eventually_pos] with N hN
  exact ConcreteModel.posteriorDenominator_pos Real.tanh a (powerPrior d N r γ) f sample hN

/-- Every retained full-sign function strictly above a retained comparator
in weighted Walsh margin energy has vanishing actual network posterior mass. -/
theorem networkPosterior_tendsto_zero_of_energy_gap {d n : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ0 : 0 < γ) (hγ1 : γ < 1) {a : ℝ} (ha : 0 < a)
    (f target g : BooleanFunction d) (sample : Fin n → Cube d)
    (ht : consistent f sample target)
    (hgap : walshMarginEnergy d r a target < walshMarginEnergy d r a g) :
    Tendsto (fun N => networkPosterior Real.tanh a (powerPrior d N r γ) f sample g)
      atTop (𝓝 (0 : ℝ)) := by
  exact posterior_tendsto_zero_of_rate_gap (fun N : ℕ => (N : ℝ) ^ γ)
    (fun N g => functionMass Real.tanh a (powerPrior d N r γ) g)
    (walshMarginEnergy d r a) (consistent f sample)
    (fun N => functionMass_nonneg Real.tanh a (powerPrior d N r γ))
    ((tendsto_rpow_atTop hγ0).comp tendsto_natCast_atTop_atTop)
    (actual_functionMass_hasExponentialRate hd r hγ0 hγ1 ha) target g ht hgap

/-- Finite posterior concentration on all tied minimizing energies together;
this conclusion requires no assertion that a minimum is unique. -/
theorem networkPosterior_high_energy_mass_tendsto_zero {d n : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ0 : 0 < γ) (hγ1 : γ < 1) {a : ℝ} (ha : 0 < a)
    (f target : BooleanFunction d) (sample : Fin n → Cube d)
    (ht : consistent f sample target) (A : Finset (BooleanFunction d))
    (hA : ∀ g ∈ A, walshMarginEnergy d r a target < walshMarginEnergy d r a g) :
    Tendsto (fun N => ∑ g ∈ A, networkPosterior Real.tanh a (powerPrior d N r γ) f sample g)
      atTop (𝓝 (0 : ℝ)) := by
  exact posterior_high_energy_mass_tendsto_zero (fun N : ℕ => (N : ℝ) ^ γ)
    (fun N g => functionMass Real.tanh a (powerPrior d N r γ) g)
    (walshMarginEnergy d r a) (consistent f sample)
    (fun N => functionMass_nonneg Real.tanh a (powerPrior d N r γ))
    ((tendsto_rpow_atTop hγ0).comp tendsto_natCast_atTop_atTop)
    (actual_functionMass_hasExponentialRate hd r hγ0 hγ1 ha) target ht A hA

end NeuralGeneralization.NetworkSubcriticalWalshRate
