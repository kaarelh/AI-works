import NeuralGeneralization.GaussianCovarianceFactor
import NeuralGeneralization.GaussianMarginLaw
import NeuralGeneralization.SubcriticalMixtureRate
import NeuralGeneralization.NetworkHiddenFreezing
import NeuralGeneralization.WalshGaussianLaw

/-! Actual positive-subcritical function-mass rates. The covariance is frozen
under the actual hidden prior and the actual conditional Gaussian readout is
integrated, retaining the all-input strict margin convention. -/
noncomputable section
open Filter MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators Topology NNReal MatrixOrder
namespace NeuralGeneralization.NetworkSubcriticalRate
open ConcreteModel NetworkReadout NetworkHiddenFreezing GaussianReadout
open GaussianCovarianceFactor GaussianMarginGeometry GaussianMarginLaw GaussianRate

/-- The limiting quadratic margin energy, in canonical Gaussian coordinates. -/
def canonicalMarginEnergy (d r : ℕ) (a : ℝ) (f : BooleanFunction d) : ℝ :=
  squareInf (linearMargin (signedCoefficients (canonicalFeatures (arcsineCovariance d (r + 1)))
    (fun x => labelReal (f x))) a) / 2

theorem arcsineCovariance_posSemidef (d r : ℕ) :
    Matrix.PosSemidef (arcsineCovariance d (r + 1)) := by
  let H := WalshGaussianLaw.features (walshCoefficients (arcsineProfile d (r + 1)))
  have h := normalizedGram_posSemidef H (N := 1) zero_le_one
  have he : normalizedGram H 1 = arcsineCovariance d (r + 1) := by
    ext x y
    simp only [normalizedGram, div_one, H,
      WalshGaussianLaw.gram_features _ (fun S => (iterated_arcsine_coefficient_pos d r S).le),
      arcsineCovariance_walsh]
  rwa [he] at h

theorem canonical_law_eq_arcsineLaw (d r : ℕ) :
    (Measure.pi fun _ : Cube d => gaussianReal 0 1).map
      (readout (canonicalFeatures (arcsineCovariance d (r + 1)))) =
      WalshGaussianLaw.arcsineLaw d r := by
  apply law_eq_of_gram_eq
  intro x y
  simp only [NNReal.coe_one, one_mul,
    gram_canonicalFeatures _ (arcsineCovariance_posSemidef d r),
    WalshGaussianLaw.gram_features _ (fun S => (iterated_arcsine_coefficient_pos d r S).le),
    arcsineCovariance_walsh]

theorem canonical_margin_nonempty (d r : ℕ) (a : ℝ) (f : BooleanFunction d) :
    (linearMargin (signedCoefficients (canonicalFeatures (arcsineCovariance d (r + 1)))
      (fun x => labelReal (f x))) a).Nonempty := by
  have hpos := WalshGaussianLaw.orthant_pos _ (iterated_arcsine_coefficient_pos d r) f a
  change 0 < WalshGaussianLaw.arcsineLaw d r (fieldMargin (fun x => labelReal (f x)) a) at hpos
  rw [← canonical_law_eq_arcsineLaw, Measure.map_apply (continuous_readout _).measurable
    (isOpen_fieldMargin _ _).measurableSet, readout_preimage_fieldMargin] at hpos
  by_contra hne
  rw [Set.not_nonempty_iff_eq_empty.mp hne, measure_empty] at hpos
  exact (lt_irrefl _) hpos

/-- Exact global-margin event after splitting hidden and readout coordinates. -/
def productMargin (d N r : ℕ) (a : ℝ) (f : BooleanFunction d) :
    Set ((HiddenIndex d N r → ℝ) × (Fin N → ℝ)) :=
  (weightSplit d N r).symm ⁻¹' marginEvent Real.tanh a f

theorem measurableSet_productMargin (d N r : ℕ) (a : ℝ) (f : BooleanFunction d) :
    MeasurableSet (productMargin d N r a f) :=
  (isOpen_marginEvent tanh_lipschitzWith.continuous a f).measurableSet.preimage
    (weightSplit d N r).symm.measurable

theorem productMargin_mass (d N r : ℕ) (γ a : ℝ) (f : BooleanFunction d) :
    ((hiddenPrior d N r γ).prod (readoutPrior N γ)).real (productMargin d N r a f) =
      functionMass Real.tanh a (powerPrior d N r γ) f := by
  exact congrArg ENNReal.toReal
    ((MeasurePreserving.symm (weightSplit d N r) (measurePreserving_weightSplit d N r γ)).measure_preimage
      (isOpen_marginEvent tanh_lipschitzWith.continuous a f).measurableSet.nullMeasurableSet)

/-- Exact finite-width conditional margin mass as a fixed-dimensional
isotropic Gaussian margin mass with covariance square-root coefficients. -/
theorem frozen_margin_mass {d N r : ℕ} (hN : 0 < N) (γ a : ℝ)
    (f : BooleanFunction d) (h : HiddenIndex d N r → ℝ) :
    (readoutPrior N γ).real {z | (h,z) ∈ productMargin d N r a f} =
      isotropicMass (linearMargin
        (signedCoefficients (canonicalFeatures (empiricalGram Real.tanh h))
          (fun x => labelReal (f x))) a) ((N : ℝ) ^ (-γ)) := by
  have hNp : (0 : ℝ) < N := by exact_mod_cast hN
  have hv : (N : ℝ≥0) * ((N : ℝ) ^ (-γ - 1)).toNNReal =
      ((N : ℝ) ^ (-γ)).toNNReal := by
    apply NNReal.coe_injective
    simp only [NNReal.coe_mul, NNReal.coe_natCast,
      Real.coe_toNNReal _ (Real.rpow_nonneg hNp.le _)]
    rw [Real.rpow_sub hNp, Real.rpow_one]
    field_simp
  have hlaw := law_eq_canonical (features Real.tanh h) N hN
    ((N : ℝ) ^ (-γ - 1)).toNNReal
  rw [hv] at hlaw
  have hm := congrArg (fun μ : Measure (EuclideanSpace ℝ (Cube d)) =>
    μ.real (fieldMargin (fun x => labelReal (f x)) a)) hlaw
  simp only [mapped_fieldMargin_mass] at hm
  have he : {z | (h,z) ∈ productMargin d N r a f} =
      readout (features Real.tanh h) ⁻¹' fieldMargin (fun x => labelReal (f x)) a := by
    ext z
    simp only [Set.mem_setOf_eq, productMargin, Set.mem_preimage, weightSplit_symm,
      marginEvent, fieldMargin]
    rfl
  rw [he, readout_preimage_fieldMargin]
  exact hm

theorem frozen_uniform_lower {d r : ℕ} {γ : ℝ} (hγ : 0 < γ)
    (a : ℝ) (f : BooleanFunction d) {ε : ℝ} (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∃ c : ℝ, 0 < c ∧ ∀ᶠ N : ℕ in atTop,
      ∀ h ∉ hiddenGramBad (arcsineCovariance d (r + 1)) δ,
        c * Real.exp (-(canonicalMarginEnergy d r a f + ε) * (N : ℝ) ^ γ) ≤
          (readoutPrior N γ).real {z | (h,z) ∈ productMargin d N r a f} := by
  obtain ⟨η, hη, c, hc, hlo⟩ := UniformGaussianMarginRate.uniform_lower
    (signedCoefficients (canonicalFeatures (arcsineCovariance d (r + 1))) (fun x => labelReal (f x)))
    a (canonical_margin_nonempty d r a f) hε
  obtain ⟨δ, hδ, hclose⟩ := canonicalFeatures_close_of_entries_close
    (arcsineCovariance d (r + 1)) (arcsineCovariance_posSemidef d r) hη
  refine ⟨δ, hδ, c, hc, ?_⟩
  have ht : Tendsto (fun N : ℕ => (N : ℝ) ^ (-γ)) atTop (𝓝 (0 : ℝ)) :=
    (tendsto_rpow_neg_atTop hγ).comp tendsto_natCast_atTop_atTop
  filter_upwards [eventually_gt_atTop (0 : ℕ), ht.eventually_lt_const zero_lt_one] with N hN ht1
  intro h hh
  have hNp : (0 : ℝ) < N := by exact_mod_cast hN
  have hnear : ∀ x y, |empiricalGram Real.tanh h x y - arcsineCovariance d (r + 1) x y| < δ := by
    simpa only [hiddenGramBad, Set.mem_setOf_eq, not_exists, not_le] using hh
  have hQ : Matrix.PosSemidef (empiricalGram Real.tanh h) :=
    normalizedGram_posSemidef (features Real.tanh h) (Nat.cast_nonneg N)
  have hcoeff := signedCoefficients_close (fun x => labelReal (f x))
    (fun x => abs_labelReal (f x)) hη (hclose _ hQ hnear)
  have hm := hlo _ hcoeff ((N : ℝ) ^ (-γ)) (Real.rpow_pos_of_pos hNp _) ht1.le
  rw [frozen_margin_mass hN]
  simpa only [canonicalMarginEnergy, Real.rpow_neg hNp.le, one_div, inv_inv] using hm

theorem frozen_uniform_upper {d r : ℕ} (γ : ℝ) {a : ℝ} (ha : 0 < a)
    (f : BooleanFunction d) {ε : ℝ} (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∃ C : ℝ, 0 < C ∧ ∀ᶠ N : ℕ in atTop,
      ∀ h ∉ hiddenGramBad (arcsineCovariance d (r + 1)) δ,
        (readoutPrior N γ).real {z | (h,z) ∈ productMargin d N r a f} ≤
          C * Real.exp (-(canonicalMarginEnergy d r a f - ε) * (N : ℝ) ^ γ) := by
  obtain ⟨η, hη, C, hC, hhi⟩ := UniformGaussianMarginRate.uniform_upper
    (signedCoefficients (canonicalFeatures (arcsineCovariance d (r + 1))) (fun x => labelReal (f x)))
    ha hε
  obtain ⟨δ, hδ, hclose⟩ := canonicalFeatures_close_of_entries_close
    (arcsineCovariance d (r + 1)) (arcsineCovariance_posSemidef d r) hη
  refine ⟨δ, hδ, C, hC, ?_⟩
  filter_upwards [eventually_gt_atTop (0 : ℕ)] with N hN
  intro h hh
  have hNp : (0 : ℝ) < N := by exact_mod_cast hN
  have hnear : ∀ x y, |empiricalGram Real.tanh h x y - arcsineCovariance d (r + 1) x y| < δ := by
    simpa only [hiddenGramBad, Set.mem_setOf_eq, not_exists, not_le] using hh
  have hQ : Matrix.PosSemidef (empiricalGram Real.tanh h) :=
    normalizedGram_posSemidef (features Real.tanh h) (Nat.cast_nonneg N)
  have hcoeff := signedCoefficients_close (fun x => labelReal (f x))
    (fun x => abs_labelReal (f x)) hη (hclose _ hQ hnear)
  have hm := hhi _ hcoeff ((N : ℝ) ^ (-γ)) (Real.rpow_pos_of_pos hNp _)
  rw [frozen_margin_mass hN]
  simpa only [canonicalMarginEnergy, Real.rpow_neg hNp.le, one_div, inv_inv] using hm

/-- The actual positive-subcritical network function mass has the Gaussian
quadratic margin rate at speed `N^gamma`, with the strict margin imposed on
every cube input. No limiting-law or large-deviation premise is assumed. -/
theorem actual_functionMass_hasExponentialRate {d : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ0 : 0 < γ) (hγ1 : γ < 1) {a : ℝ} (ha : 0 < a)
    (f : BooleanFunction d) :
    HasExponentialRate atTop (fun N : ℕ => (N : ℝ) ^ γ)
      (fun N => functionMass Real.tanh a (powerPrior d N r γ) f)
      (canonicalMarginEnergy d r a f) := by
  have h := SubcriticalMixtureRate.product_mixture_hasExponentialRate
    (fun N => hiddenPrior d N r γ) (fun N => readoutPrior N γ)
    (fun N => productMargin d N r a f) (fun N => measurableSet_productMargin d N r a f)
    (fun N δ => hiddenGramBad (N := N) (r := r) (arcsineCovariance d (r + 1)) δ)
    (fun N δ => measurableSet_hiddenGramBad _ δ) hγ0 hγ1
    (fun δ hδ => hidden_gram_exponential_freezing hd r hγ1 hδ)
    (fun ε hε => frozen_uniform_lower hγ0 a f hε)
    (fun ε hε => frozen_uniform_upper γ ha f hε)
  simpa only [productMargin_mass] using h

end NeuralGeneralization.NetworkSubcriticalRate
