import NeuralGeneralization.BatchTwoNonGaussianScaleComparison
import NeuralGeneralization.NetworkGaussianRate

/-! Actual small-prior rate gaps for non-Gaussian network sign masses.  Only the
already proved Gaussian rate and the proved density comparisons are used. -/

noncomputable section
open MeasureTheory ProbabilityTheory Filter
open scoped Topology
open NeuralGeneralization.ConcreteModel
namespace NeuralGeneralization.BatchTwoNonGaussian

theorem smallMass_gaussian_lower (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (σ : ℝ) (φ : ℝ → ℝ) (a : ℝ) (f : BooleanFunction d) :
    ν.comparisonFactor ν.upperCurvature ^ Fintype.card (WeightIndex d N r) *
        functionMass φ a (ConcreteModel.smallPrior d N r (σ / Real.sqrt ν.upperCurvature)) f ≤
      functionMass φ a (smallPrior ν d N r σ) f := by
  have h := ENNReal.toReal_mono (measure_ne_top (smallPrior ν d N r σ) (marginEvent φ a f))
    ((smallPrior_gaussian_lower ν hd hN σ) (marginEvent φ a f))
  simpa only [functionMass, Measure.smul_apply, smul_eq_mul, ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (pow_nonneg (ν.comparisonFactor_pos _ ν.upperCurvature_pos).le _)] using h

theorem smallMass_gaussian_upper (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (σ : ℝ) (φ : ℝ → ℝ) (a : ℝ) (f : BooleanFunction d) :
    functionMass φ a (smallPrior ν d N r σ) f ≤
      ν.comparisonFactor ν.lowerCurvature ^ Fintype.card (WeightIndex d N r) *
        functionMass φ a (ConcreteModel.smallPrior d N r (σ / Real.sqrt ν.lowerCurvature)) f := by
  have h := ENNReal.toReal_mono (by
      rw [Measure.smul_apply, smul_eq_mul]
      exact ENNReal.mul_ne_top ENNReal.ofReal_ne_top (measure_ne_top _ _))
    ((smallPrior_gaussian_upper ν (r := r) hd hN σ) (marginEvent φ a f))
  simpa only [functionMass, Measure.smul_apply, smul_eq_mul, ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (pow_nonneg (ν.comparisonFactor_pos _ ν.lowerCurvature_pos).le _)] using h

private theorem tendsto_div_nhdsGT (c : ℝ) (hc : 0 < c) :
    Tendsto (fun σ : ℝ => σ / c) (𝓝[>] 0) (𝓝[>] 0) := by
  apply tendsto_nhdsWithin_iff.mpr
  constructor
  · simpa using ((continuous_id.div_const c).tendsto (0 : ℝ)).mono_left nhdsWithin_le_nhds
  · filter_upwards [self_mem_nhdsWithin] with σ hσ
    exact div_pos hσ hc

private theorem rescale_rate {w : ℝ → ℝ} {E c : ℝ} (hc : 0 < c)
    (h : HasExponentialRate (𝓝[>] (0 : ℝ)) (fun σ : ℝ => 1 / σ ^ 2) w E) :
    HasExponentialRate (𝓝[>] (0 : ℝ)) (fun σ : ℝ => 1 / σ ^ 2)
      (fun σ => w (σ / Real.sqrt c)) (c * E) := by
  have hcomp := h.comp (tendsto_div_nhdsGT (Real.sqrt c) (Real.sqrt_pos.mpr hc))
  intro ε hε
  filter_upwards [hcomp (ε / c) (div_pos hε hc)] with σ hσ
  have hs : 1 / (σ / Real.sqrt c) ^ 2 = c * (1 / σ ^ 2) := by
    rw [div_pow, Real.sq_sqrt hc.le, one_div_div]
    ring
  rw [hs] at hσ
  convert! hσ using 1 <;> congr 1 <;> field_simp

theorem rescaled_gaussian_mass_rate {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (a : ℝ) (f : BooleanFunction d)
    (hne : (marginEvent (N := N) (r := r) φ a f).Nonempty) (c : ℝ) (hc : 0 < c) :
    HasExponentialRate (𝓝[>] (0 : ℝ)) (fun σ : ℝ => 1 / σ ^ 2)
      (fun σ => functionMass φ a (ConcreteModel.smallPrior d N r (σ / Real.sqrt c)) f)
      (c * networkEnergy (N := N) (r := r) φ a f) :=
  rescale_rate hc (network_functionMass_hasExponentialRate hd hN hφ a f hne)

/-- Strict weighted quadratic rate separation gives the needed raw-mass ratio
for the actual non-Gaussian prior, uniformly over later data conditioning. -/
theorem smallMass_ratio_tendsto_zero (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f g : BooleanFunction d)
    (hf : (marginEvent (N := N) (r := r) φ (1 / 2) f).Nonempty)
    (hg : (marginEvent (N := N) (r := r) φ (1 / 2) g).Nonempty)
    (hgap : ν.upperCurvature * networkEnergy (N := N) (r := r) φ (1 / 2) f <
      ν.lowerCurvature * networkEnergy (N := N) (r := r) φ (1 / 2) g) :
    Tendsto (fun σ => functionMass φ (1 / 2) (smallPrior ν d N r σ) g /
      functionMass φ (1 / 2) (smallPrior ν d N r σ) f) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  let A := ν.comparisonFactor ν.upperCurvature ^ Fintype.card (WeightIndex d N r)
  let B := ν.comparisonFactor ν.lowerCurvature ^ Fintype.card (WeightIndex d N r)
  let u := fun σ => functionMass φ (1 / 2)
    (ConcreteModel.smallPrior d N r (σ / Real.sqrt ν.lowerCurvature)) g
  let v := fun σ => functionMass φ (1 / 2)
    (ConcreteModel.smallPrior d N r (σ / Real.sqrt ν.upperCurvature)) f
  have hA : 0 < A := pow_pos (ν.comparisonFactor_pos _ ν.upperCurvature_pos) _
  have hB : 0 < B := pow_pos (ν.comparisonFactor_pos _ ν.lowerCurvature_pos) _
  have hrU := rescaled_gaussian_mass_rate hd hN hφ (1 / 2) g hg _ ν.lowerCurvature_pos
  have hrV := rescaled_gaussian_mass_rate hd hN hφ (1 / 2) f hf _ ν.upperCurvature_pos
  have hratio := hrU.ratio_tendsto_zero hrV hgap tendsto_inverse_square_nhdsGT_zero_atTop
  have hlim : Tendsto (fun σ => (B / A) * (u σ / v σ)) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
    simpa only [mul_zero] using hratio.const_mul (B / A)
  apply squeeze_zero' (Eventually.of_forall fun σ => div_nonneg
    (functionMass_nonneg _ _ _ _) (functionMass_nonneg _ _ _ _)) _ hlim
  filter_upwards [hrV.eventually_pos] with σ hv
  have hlo := smallMass_gaussian_lower ν (r := r) hd hN σ φ (1 / 2) f
  have hhi := smallMass_gaussian_upper ν (r := r) hd hN σ φ (1 / 2) g
  have hapos : 0 < A * v σ := mul_pos hA hv
  have hdenom : 0 < functionMass φ (1 / 2) (smallPrior ν d N r σ) f := hapos.trans_le hlo
  calc
    _ ≤ B * u σ / functionMass φ (1 / 2) (smallPrior ν d N r σ) f :=
      div_le_div_of_nonneg_right hhi hdenom.le
    _ ≤ B * u σ / (A * v σ) :=
      div_le_div_of_nonneg_left (mul_nonneg hB.le (functionMass_nonneg _ _ _ _)) hapos hlo
    _ = _ := by field_simp

end NeuralGeneralization.BatchTwoNonGaussian
