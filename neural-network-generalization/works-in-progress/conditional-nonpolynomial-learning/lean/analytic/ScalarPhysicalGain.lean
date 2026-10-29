import SubcriticalMarginAccounting

/-! The sharp second-moment gain with the physical scalar Gaussian
reference. This supplies the variance-growth and Gaussian-remainder part of
the subcritical adjusted entropy argument. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.GaussianFieldTilt

theorem gaussianEntropyGain_mono {D E : ℝ} (hD : 0≤D) (hDE : D≤E) :
    gaussianEntropyGain D≤gaussianEntropyGain E := by
  apply (gaussianVarianceCost_le_iff (hD.trans hDE) (gaussianEntropyGain_one_le D)).mp
  rw [gaussianEntropyGain_cost hD]
  exact hDE

theorem scalar_physical_second_moment_gain
    (Q : Measure ℝ) [IsProbabilityMeasure Q] (v : ℝ≥0)
    (hv : v≠0) (hKL : klDiv Q (gaussianReal 0 v)≠∞) {D : ℝ}
    (hD : (klDiv Q (gaussianReal 0 v)).toReal≤D) :
    (∫z : ℝ,z^2 ∂Q)≤(v:ℝ)*gaussianEntropyGain D := by
  have hvp : 0<(v:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  let T : ℝ → ℝ := fun z => (Real.sqrt (v:ℝ))⁻¹*z
  have hT : Measurable T := by dsimp [T]; fun_prop
  have hmap : (gaussianReal 0 v).map T=gaussianReal 0 1 := by
    dsimp [T]
    rw [gaussianReal_map_const_mul,mul_zero]
    congr 1
    apply NNReal.coe_injective
    simp only [NNReal.coe_mul,NNReal.coe_mk,NNReal.coe_one]
    rw [inv_pow,Real.sq_sqrt hvp.le]
    exact inv_mul_cancel₀ hvp.ne'
  have hdata := NeuralGeneralization.RobustEntropy.klDiv_map_le Q (gaussianReal 0 v) hT
  rw [hmap] at hdata
  have hf : klDiv (Q.map T) (gaussianReal 0 1)≠∞ :=
    ne_of_lt (lt_of_le_of_lt hdata (lt_top_iff_ne_top.mpr hKL))
  haveI : IsProbabilityMeasure (Q.map T) := Measure.isProbabilityMeasure_map hT.aemeasurable
  have hc : (klDiv (Q.map T) (gaussianReal 0 1)).toReal≤D :=
    (ENNReal.toReal_mono hKL hdata).trans hD
  have hgain := (actual_scalar_moment_le_gain (Q.map T) hf).trans
    (gaussianEntropyGain_mono ENNReal.toReal_nonneg hc)
  have he : (∫z : ℝ,z^2 ∂Q)=(v:ℝ)*(∫z : ℝ,z^2 ∂Q.map T) := by
    rw [integral_map hT.aemeasurable (by fun_prop),← integral_const_mul]
    apply integral_congr_ae
    filter_upwards [] with z
    dsimp [T]
    rw [mul_pow,inv_pow,Real.sq_sqrt hvp.le]
    field_simp
  rw [he]
  exact mul_le_mul_of_nonneg_left hgain hvp.le

theorem scalar_physical_transition_gain
    (Q : Measure ℝ) [IsProbabilityMeasure Q] (v : ℝ≥0)
    (hv : v≠0) (hvone : v≤1) (hKL : klDiv Q (gaussianReal 0 v)≠∞)
    {p D : ℝ} (hp : 0≤p) (hD : (klDiv Q (gaussianReal 0 v)).toReal≤D) :
    scalarTransition p Q≤p*(v:ℝ)*gaussianEntropyGain D := by
  have hf := (scalar_subcritical_reference_change Q v hv hvone hKL).1
  have hi := scalar_gaussian_second_moment_integrable Q hf
  have hm := scalar_physical_second_moment_gain Q v hv hKL hD
  calc
    _ ≤ ∫z : ℝ,p*z^2 ∂Q := integral_mono (varianceTest_integrable Q p) (hi.const_mul p)
      (fun z => by
        have h := pow_le_pow_left₀ (abs_nonneg _) (NeuralGeneralization.BatchTwoNonGaussian.abs_tanh_le_abs
          (Real.sqrt p*z)) 2
        simpa only [varianceTest,sq_abs,mul_pow,Real.sq_sqrt hp] using h)
    _ = p*(∫z : ℝ,z^2 ∂Q) := integral_const_mul _ _
    _ ≤ p*((v:ℝ)*gaussianEntropyGain D) := mul_le_mul_of_nonneg_left hm hp
    _ = _ := by ring

theorem controlledMarginPath_sharp_variance_gain
    {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (j : ℕ) (hj : j<H) :
    physicalMaxVariance P (j+1)≤physicalMaxVariance P j*(physicalVariance P:ℝ)*
      gaussianEntropyGain (physicalLayerCost P j) := by
  obtain ⟨p,R,hp,hpq,hR,hf,hc,ht⟩ := controlledMarginPath_scalar_step P j hj
  letI := hR
  rw [ht]
  have hgain := scalar_physical_transition_gain R (physicalVariance P) (physicalVariance_ne_zero P)
    (physicalVariance_le_one P) hf hp.le hc
  have hnon : 0≤(physicalVariance P:ℝ)*gaussianEntropyGain (physicalLayerCost P j) :=
    mul_nonneg (NNReal.coe_nonneg _) (le_trans (by norm_num) (gaussianEntropyGain_one_le _))
  have hm := mul_le_mul_of_nonneg_right hpq hnon
  nlinarith only [hgain,hm]


theorem physicalLogGain_double {D : ℝ} (v : ℝ≥0) (hv : v≠0) :
    2*physicalLogGain D v=Real.log ((v:ℝ)*gaussianEntropyGain D) := by
  have hvp : 0<(v:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  have hgp : 0<gaussianEntropyGain D := lt_of_lt_of_le (by norm_num) (gaussianEntropyGain_one_le D)
  unfold physicalLogGain
  rw [Real.log_mul (Real.sqrt_pos.mpr hvp).ne' (Real.sqrt_pos.mpr hgp).ne',
    Real.log_sqrt hvp.le,Real.log_sqrt hgp.le,Real.log_mul hvp.ne' hgp.ne']
  ring

def physicalGaussianRemainder {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (j : ℕ) : ℝ :=
  physicalLayerCost P j-subcriticalCostBaseline (physicalVariance P)-
    ((physicalVariance P:ℝ)⁻¹-1)*physicalPathLogGain P j

theorem physicalGaussianRemainder_bounds
    {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (j : ℕ) (hj : j<H) :
    0≤physicalGaussianRemainder P j ∧ physicalGaussianRemainder P j≤physicalAdjustedCost P j := by
  have hvp : 0<(physicalVariance P:ℝ) := by
    exact_mod_cast (pos_iff_ne_zero.mpr (physicalVariance_ne_zero P))
  have hv1 : (physicalVariance P:ℝ)≤1 := by exact_mod_cast physicalVariance_le_one P
  have ha : 0≤(physicalVariance P:ℝ)⁻¹-1 := by linarith [(one_le_inv₀ hvp).mpr hv1]
  have hgp : 0<gaussianEntropyGain (physicalLayerCost P j) :=
    lt_of_lt_of_le (by norm_num) (gaussianEntropyGain_one_le _)
  have hid := gaussianEntropyGain_adjusted_identity
    (show 0≤physicalLayerCost P j from ENNReal.toReal_nonneg) (physicalVariance P)
    (physicalVariance_ne_zero P)
  change physicalLayerCost P j-subcriticalCostBaseline (physicalVariance P)=
    ((physicalVariance P:ℝ)⁻¹-1)*physicalPathLogGain P j+
    (1+((physicalVariance P:ℝ)⁻¹-1))/2*
      (Real.exp (2*physicalPathLogGain P j)-1-2*physicalPathLogGain P j) at hid
  constructor
  · have hr := exp_two_remainder_nonneg (physicalPathLogGain P j)
    have hm := mul_nonneg (show 0≤(1+((physicalVariance P:ℝ)⁻¹-1))/2 by positivity) hr
    unfold physicalGaussianRemainder
    linarith
  · have hq := controlledMarginPath_variance_positive P
    have hvar := controlledMarginPath_sharp_variance_gain P j hj
    have hratio : physicalMaxVariance P (j+1)/physicalMaxVariance P j≤
        (physicalVariance P:ℝ)*gaussianEntropyGain (physicalLayerCost P j) := by
      apply (div_le_iff₀ (hq j (by omega))).mpr
      nlinarith only [hvar]
    have hlog := Real.log_le_log
      (div_pos (hq (j+1) (by omega)) (hq j (by omega))) hratio
    rw [← physicalLogGain_double (physicalVariance P) (physicalVariance_ne_zero P)] at hlog
    change Real.log (physicalMaxVariance P (j+1)/physicalMaxVariance P j)≤
      2*physicalPathLogGain P j at hlog
    have hm := mul_le_mul_of_nonneg_left hlog ha
    unfold physicalGaussianRemainder physicalAdjustedCost adjustedLayerCost
    linarith

#print axioms controlledMarginPath_sharp_variance_gain
#print axioms physicalGaussianRemainder_bounds
end ConditionalNonpolynomial.Analytic
