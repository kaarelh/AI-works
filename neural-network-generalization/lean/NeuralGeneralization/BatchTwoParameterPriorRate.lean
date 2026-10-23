import NeuralGeneralization.BatchTwoNonGaussianStrongRate

/-! Small-prior rates and strict rate-gap concentration for arbitrary open
parameter events. The underlying measures are the actual anisotropic product
priors, including the strongly log-concave non-Gaussian coordinate laws. -/
noncomputable section
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.BatchTwoParameterPriorRate
open ConcreteModel

def eventEnergy {d N r : ℕ} (V : Set (Weights d N r)) : ℝ := sInf (weightedSquaredNorm '' V)/2

theorem eventEnergy_le {d N r : ℕ} {V : Set (Weights d N r)} {w : Weights d N r} (hw : w ∈ V) :
    eventEnergy V ≤ weightedSquaredNorm w/2 :=
  div_le_div_of_nonneg_right (csInf_le (weightedSquaredNorm_image_bddBelow _) ⟨w,hw,rfl⟩) (by norm_num)

theorem eventEnergy_ge {d N r : ℕ} {V : Set (Weights d N r)} (hne : V.Nonempty)
    {K : ℝ} (hK : ∀ w ∈ V, K ≤ weightedSquaredNorm w) : K/2 ≤ eventEnergy V := by
  apply div_le_div_of_nonneg_right _ (by norm_num)
  apply le_csInf (hne.image weightedSquaredNorm)
  rintro _ ⟨w,hw,rfl⟩
  exact hK w hw

theorem gaussian_open_rate {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (V : Set (Weights d N r)) (hV : IsOpen V) (hne : V.Nonempty) :
    HasExponentialRate (𝓝[>] (0 : ℝ)) (fun σ : ℝ => 1/σ^2)
      (fun σ => (smallPrior d N r σ).real V) (eventEnergy V) := by
  let U := unwhiten ⁻¹' V
  have hU : IsOpen U := hV.preimage (continuous_unwhiten _ _ _)
  have hUne : U.Nonempty := by
    obtain ⟨w,hw⟩ := hne
    exact ⟨whiten w,by simpa [U,unwhiten_whiten hd hN] using hw⟩
  have himage : GaussianRate.squareSum '' U=weightedSquaredNorm '' V := by
    ext q
    constructor
    · rintro ⟨u,hu,rfl⟩
      exact ⟨unwhiten u,hu,weightedSquaredNorm_unwhiten hd hN u⟩
    · rintro ⟨w,hw,rfl⟩
      refine ⟨whiten w,by simpa [U,unwhiten_whiten hd hN] using hw,?_⟩
      change (∑ i, whiten w i^2)=weightedSquaredNorm w
      rw [← weightedSquaredNorm_unwhiten hd hN,unwhiten_whiten hd hN]
  have hr := (GaussianRate.gaussian_open_event_hasExponentialRate hU hUne).comp tendsto_square_nhdsGT_zero
  have heq : (fun σ : ℝ => GaussianRate.isotropicMass U (σ^2)) =ᶠ[𝓝[>] (0 : ℝ)]
      (fun σ => (smallPrior d N r σ).real V) := by
    filter_upwards [self_mem_nhdsWithin] with σ hσ
    unfold GaussianRate.isotropicMass Measure.real
    rw [← map_isotropic_eq_smallPrior hd hN (show 0 < σ from hσ),
      Measure.map_apply (continuous_unwhiten _ _ _).measurable hV.measurableSet]
  have h := hr.congr heq
  simpa only [GaussianRate.squareInf,himage,eventEnergy] using h

theorem rescale_rate {w : ℝ → ℝ} {E c : ℝ} (hc : 0 < c)
    (h : HasExponentialRate (𝓝[>] (0 : ℝ)) (fun σ : ℝ => 1/σ^2) w E) :
    HasExponentialRate (𝓝[>] (0 : ℝ)) (fun σ : ℝ => 1/σ^2)
      (fun σ => w (σ/Real.sqrt c)) (c*E) := by
  have hscale : Tendsto (fun σ : ℝ => σ/Real.sqrt c) (𝓝[>] 0) (𝓝[>] 0) := by
    apply tendsto_nhdsWithin_iff.mpr
    constructor
    · simpa using ((continuous_id.div_const (Real.sqrt c)).tendsto (0 : ℝ)).mono_left nhdsWithin_le_nhds
    · filter_upwards [self_mem_nhdsWithin] with σ hσ
      exact div_pos hσ (Real.sqrt_pos.mpr hc)
  have hcomp := h.comp hscale
  intro ε hε
  filter_upwards [hcomp (ε/c) (div_pos hε hc)] with σ hσ
  have hs : 1/(σ/Real.sqrt c)^2=c*(1/σ^2) := by rw [div_pow,Real.sq_sqrt hc.le,one_div_div]; ring
  rw [hs] at hσ
  convert! hσ using 1 <;> congr 1 <;> field_simp

theorem nonGaussian_lower (ν : BatchTwoNonGaussian.CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (σ : ℝ) (V : Set (Weights d N r)) :
    ν.comparisonFactor ν.upperCurvature ^ Fintype.card (WeightIndex d N r)*
      (smallPrior d N r (σ/Real.sqrt ν.upperCurvature)).real V ≤
      (BatchTwoNonGaussian.smallPrior ν d N r σ).real V := by
  have h := ENNReal.toReal_mono (measure_ne_top (BatchTwoNonGaussian.smallPrior ν d N r σ) V)
    ((BatchTwoNonGaussian.smallPrior_gaussian_lower ν hd hN σ) V)
  simpa only [Measure.real,Measure.smul_apply,smul_eq_mul,ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (pow_nonneg (ν.comparisonFactor_pos _ ν.upperCurvature_pos).le _)] using h

theorem nonGaussian_upper (ν : BatchTwoNonGaussian.CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (σ : ℝ) (V : Set (Weights d N r)) :
    (BatchTwoNonGaussian.smallPrior ν d N r σ).real V ≤
      ν.comparisonFactor ν.lowerCurvature ^ Fintype.card (WeightIndex d N r)*
      (smallPrior d N r (σ/Real.sqrt ν.lowerCurvature)).real V := by
  have h := ENNReal.toReal_mono (by
      rw [Measure.smul_apply,smul_eq_mul]
      exact ENNReal.mul_ne_top ENNReal.ofReal_ne_top (measure_ne_top _ _))
    ((BatchTwoNonGaussian.smallPrior_gaussian_upper ν hd hN σ) V)
  simpa only [Measure.real,Measure.smul_apply,smul_eq_mul,ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (pow_nonneg (ν.comparisonFactor_pos _ ν.lowerCurvature_pos).le _)] using h

theorem nonGaussian_open_ratio (ν : BatchTwoNonGaussian.CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (U V : Set (Weights d N r))
    (hU : IsOpen U) (hUne : U.Nonempty) (hV : IsOpen V) (hVne : V.Nonempty)
    (hgap : ν.upperCurvature*eventEnergy V < ν.lowerCurvature*eventEnergy U) :
    Tendsto (fun σ => (BatchTwoNonGaussian.smallPrior ν d N r σ).real U/
      (BatchTwoNonGaussian.smallPrior ν d N r σ).real V) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  let A := ν.comparisonFactor ν.upperCurvature ^ Fintype.card (WeightIndex d N r)
  let B := ν.comparisonFactor ν.lowerCurvature ^ Fintype.card (WeightIndex d N r)
  let u := fun σ => (smallPrior d N r (σ/Real.sqrt ν.lowerCurvature)).real U
  let v := fun σ => (smallPrior d N r (σ/Real.sqrt ν.upperCurvature)).real V
  have hA : 0 < A := pow_pos (ν.comparisonFactor_pos _ ν.upperCurvature_pos) _
  have hB : 0 < B := pow_pos (ν.comparisonFactor_pos _ ν.lowerCurvature_pos) _
  have hrU := rescale_rate ν.lowerCurvature_pos (gaussian_open_rate hd hN U hU hUne)
  have hrV := rescale_rate ν.upperCurvature_pos (gaussian_open_rate hd hN V hV hVne)
  have hratio := hrU.ratio_tendsto_zero hrV hgap tendsto_inverse_square_nhdsGT_zero_atTop
  have hlim : Tendsto (fun σ => (B/A)*(u σ/v σ)) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
    simpa only [mul_zero] using hratio.const_mul (B/A)
  apply squeeze_zero' (Eventually.of_forall fun σ => div_nonneg measureReal_nonneg measureReal_nonneg) _ hlim
  filter_upwards [hrV.eventually_pos] with σ hv
  have hlo := nonGaussian_lower ν hd hN σ V
  have hhi := nonGaussian_upper ν hd hN σ U
  have hapos : 0 < A*v σ := mul_pos hA hv
  have hdenom : 0 < (BatchTwoNonGaussian.smallPrior ν d N r σ).real V := hapos.trans_le hlo
  calc
    _ ≤ B*u σ/(BatchTwoNonGaussian.smallPrior ν d N r σ).real V := div_le_div_of_nonneg_right hhi hdenom.le
    _ ≤ B*u σ/(A*v σ) := div_le_div_of_nonneg_left (mul_nonneg hB.le measureReal_nonneg) hapos hlo
    _ = _ := by field_simp

end NeuralGeneralization.BatchTwoParameterPriorRate
