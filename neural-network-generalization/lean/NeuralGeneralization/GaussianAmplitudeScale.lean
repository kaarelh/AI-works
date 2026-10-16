import NeuralGeneralization.SmallSampleCutoff
import NeuralGeneralization.GaussianAmplitudeScalar
import NeuralGeneralization.WalshGaussianEnergy

/-! Explicit auxiliary scales for the fixed-margin Gaussian amplitude bound.
The cutoff and sample size are independent of the conditioned training sample. -/
noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped Topology
namespace NeuralGeneralization.GaussianAmplitude

def auxiliaryCutoff (d : ℕ) : ℕ := d/262144

def auxiliaryRate : ℝ := Real.log 2/(16*262144)

def auxiliaryExponent (d : ℕ) : ℝ := auxiliaryRate*(d:ℝ)

def auxiliaryCount (d : ℕ) : ℕ := ⌈Real.exp (auxiliaryExponent d)⌉₊

def spectralExponent (k : ℕ) : ℝ := 1/(2:ℝ)^(k+1)

def auxiliarySigma (d k : ℕ) : ℝ :=
  Real.sqrt (walshSpectralTail (arcsineProfile d (k+1)) (auxiliaryCutoff d)/2)

def auxiliaryLevel (d k : ℕ) (a : ℝ) : ℝ :=
  (a+auxiliarySigma d k*Real.sqrt (auxiliaryExponent d))/2

lemma auxiliaryRate_pos : 0 < auxiliaryRate := by
  unfold auxiliaryRate
  exact div_pos (Real.log_pos (by norm_num)) (by norm_num)

lemma spectralExponent_pos (k : ℕ) : 0 < spectralExponent k := by
  unfold spectralExponent
  positivity

lemma auxiliaryCutoff_bounds (d : ℕ) :
    auxiliaryCutoff d ≤ d ∧ 131072*auxiliaryCutoff d ≤ d ∧ 3*auxiliaryCutoff d ≤ d := by
  unfold auxiliaryCutoff
  have := Nat.mul_div_le d 262144
  omega

lemma auxiliaryCutoff_pos {d : ℕ} (hd : 262144 ≤ d) : 0 < auxiliaryCutoff d := by
  unfold auxiliaryCutoff
  omega

lemma auxiliaryExponent_nonneg (d : ℕ) : 0 ≤ auxiliaryExponent d := by
  exact mul_nonneg auxiliaryRate_pos.le (Nat.cast_nonneg d)

lemma auxiliaryExponent_pos {d : ℕ} (hd : 0 < d) : 0 < auxiliaryExponent d := by
  exact mul_pos auxiliaryRate_pos (by exact_mod_cast hd)

lemma auxiliaryCount_bounds (d : ℕ) :
    Real.exp (auxiliaryExponent d) ≤ (auxiliaryCount d:ℝ) ∧
      (auxiliaryCount d:ℝ) ≤ 2*Real.exp (auxiliaryExponent d) := by
  have he : 1 ≤ Real.exp (auxiliaryExponent d) := Real.one_le_exp (auxiliaryExponent_nonneg d)
  refine ⟨Nat.le_ceil _, ?_⟩
  have h := Nat.ceil_lt_add_one (Real.exp_pos (auxiliaryExponent d)).le
  change (auxiliaryCount d:ℝ) < Real.exp (auxiliaryExponent d)+1 at h
  linarith

lemma auxiliaryCount_pos (d : ℕ) : 0 < auxiliaryCount d := by
  have hh := (Real.exp_pos (auxiliaryExponent d)).trans_le (auxiliaryCount_bounds d).1
  exact_mod_cast hh

lemma auxiliary_choose_lower (d : ℕ) :
    Real.exp (16*auxiliaryExponent d-Real.log 2) ≤ (d.choose (auxiliaryCutoff d):ℝ) := by
  have hchoose : (2:ℝ)^(auxiliaryCutoff d) ≤ (d.choose (auxiliaryCutoff d):ℝ) := by
    have hh := BinomialGeometry.choose_growth (D:=d) (k:=0)
      (j:=auxiliaryCutoff d) (B:=auxiliaryCutoff d) (Nat.zero_le _) le_rfl (auxiliaryCutoff_bounds d).2.2
    norm_num at hh
    exact_mod_cast hh
  refine (show Real.exp (16*auxiliaryExponent d-Real.log 2) ≤ (2:ℝ)^(auxiliaryCutoff d) from ?_).trans hchoose
  rw [←Real.exp_log (by positivity : (0:ℝ)<(2:ℝ)^(auxiliaryCutoff d)), Real.log_pow]
  apply Real.exp_le_exp.mpr
  have hfloor : (d:ℝ) ≤ 262144*((auxiliaryCutoff d:ℝ)+1) := by
    have hn : d ≤ 262144*(auxiliaryCutoff d+1) := by unfold auxiliaryCutoff; omega
    exact_mod_cast hn
  have hh := mul_le_mul_of_nonneg_left hfloor (Real.log_pos (by norm_num : (1:ℝ)<2)).le
  unfold auxiliaryExponent auxiliaryRate
  nlinarith only [hh]

lemma auxiliarySigma_sq (d k : ℕ) :
    (auxiliarySigma d k)^2=walshSpectralTail (arcsineProfile d (k+1)) (auxiliaryCutoff d)/2 := by
  apply Real.sq_sqrt
  exact div_nonneg (Finset.sum_nonneg fun S hS => arcsineProfile_coefficient_nonneg d (k+1) S) (by norm_num)

lemma auxiliaryLevel_pos (d k : ℕ) (a : ℝ) (ha : 0<a) : 0<auxiliaryLevel d k a := by
  unfold auxiliaryLevel auxiliarySigma
  positivity

lemma auxiliarySigma_pos {d : ℕ} (hd : 262144 ≤ d) (k : ℕ) : 0 < auxiliarySigma d k := by
  apply Real.sqrt_pos.mpr
  apply div_pos _ (by norm_num)
  have hh := iterated_arcsine_spectral_tail_lower d (k+1) (auxiliaryCutoff d)
    (by omega) (auxiliaryCutoff_pos hd) (auxiliaryCutoff_bounds d).2.1
  refine (show 0 < (auxiliaryCutoff d:ℝ)^(-(1/(2:ℝ)^(k+1)))/16384 from ?_).trans_le hh
  exact div_pos (Real.rpow_pos_of_pos (by exact_mod_cast auxiliaryCutoff_pos hd) _) (by norm_num)

/-- The actual large-output threshold has the correct all-depth power of d. -/
lemma auxiliaryLevel_sq_lower {d : ℕ} (hd : 262144 ≤ d) (k : ℕ)
    (a : ℝ) (ha : 0 ≤ a) :
    (auxiliaryRate/131072)*(d:ℝ)^(1-spectralExponent k) ≤ (auxiliaryLevel d k a)^2 := by
  have hd0 : 0 < (d:ℝ) := by exact_mod_cast (show 0<d by omega)
  have hv0 : 0 < (auxiliaryCutoff d:ℝ) := by exact_mod_cast auxiliaryCutoff_pos hd
  have hvd : (auxiliaryCutoff d:ℝ) ≤ d := by exact_mod_cast (auxiliaryCutoff_bounds d).1
  have hpow : (d:ℝ)^(-spectralExponent k) ≤ (auxiliaryCutoff d:ℝ)^(-spectralExponent k) :=
    Real.rpow_le_rpow_of_nonpos hv0 hvd (neg_nonpos.mpr (spectralExponent_pos k).le)
  have htail := iterated_arcsine_spectral_tail_lower d (k+1) (auxiliaryCutoff d)
    (by omega) (auxiliaryCutoff_pos hd) (auxiliaryCutoff_bounds d).2.1
  change (auxiliaryCutoff d:ℝ)^(-spectralExponent k)/16384 ≤ _ at htail
  have hsigma : (d:ℝ)^(-spectralExponent k)/32768 ≤ (auxiliarySigma d k)^2 := by
    rw [auxiliarySigma_sq]
    linarith
  have hx := auxiliaryExponent_nonneg d
  have hs := Real.sq_sqrt hx
  have ht0 : 0 ≤ auxiliarySigma d k*Real.sqrt (auxiliaryExponent d) := by
    exact mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  have hbase : (auxiliarySigma d k*Real.sqrt (auxiliaryExponent d))^2 ≤
      (a+auxiliarySigma d k*Real.sqrt (auxiliaryExponent d))^2 := by
    exact pow_le_pow_left₀ ht0 (by linarith) 2
  rw [mul_pow,hs] at hbase
  have hmul := mul_le_mul_of_nonneg_right hsigma hx
  have hid : (d:ℝ)^(1-spectralExponent k)=(d:ℝ)^(-spectralExponent k)*(d:ℝ) := by
    rw [show 1-spectralExponent k=-spectralExponent k+1 by ring,Real.rpow_add hd0,Real.rpow_one]
  rw [hid]
  unfold auxiliaryLevel
  unfold auxiliaryExponent at hbase hmul ⊢
  nlinarith only [hbase,hmul]

lemma auxiliaryCutoff_tendsto : Tendsto auxiliaryCutoff atTop atTop := by
  refine tendsto_atTop.2 fun B => ?_
  filter_upwards [eventually_ge_atTop (262144*B)] with d hd
  unfold auxiliaryCutoff
  omega

lemma auxiliaryExponent_tendsto : Tendsto auxiliaryExponent atTop atTop :=
  tendsto_natCast_atTop_atTop.const_mul_atTop auxiliaryRate_pos

/-- The auxiliary Gaussian standard deviation vanishes at each fixed depth. -/
lemma auxiliarySigma_tendsto (k : ℕ) : Tendsto (fun d => auxiliarySigma d k) atTop (𝓝 0) := by
  have hv : Tendsto (fun d => (auxiliaryCutoff d:ℝ)) atTop atTop :=
    tendsto_natCast_atTop_atTop.comp auxiliaryCutoff_tendsto
  have hupper := ((tendsto_rpow_neg_atTop (spectralExponent_pos k)).comp hv).const_mul 4
  simp only [mul_zero] at hupper
  have htail : Tendsto (fun d => walshSpectralTail (arcsineProfile d (k+1)) (auxiliaryCutoff d)) atTop (𝓝 0) := by
    apply squeeze_zero' (Eventually.of_forall fun d => Finset.sum_nonneg fun S hS => arcsineProfile_coefficient_nonneg d (k+1) S) ?_ hupper
    filter_upwards [eventually_ge_atTop 262144] with d hd
    exact iterated_arcsine_spectral_tail_upper d (k+1) (auxiliaryCutoff d) (auxiliaryCutoff_pos hd)
  have hh := Real.continuous_sqrt.continuousAt.tendsto.comp (htail.div_const 2)
  simpa only [zero_div,Real.sqrt_zero,auxiliarySigma,Function.comp_def] using hh

lemma eventually_auxiliarySigma_half_le (k : ℕ) (a : ℝ) (ha : 0<a) :
    ∀ᶠ d : ℕ in atTop, auxiliarySigma d k/2 ≤ a := by
  have hh := (auxiliarySigma_tendsto k).div_const 2
  simp only [zero_div] at hh
  exact hh.eventually (eventually_le_nhds ha)

/-- The actual conditioned neural Gaussian field has negligible mass below
the explicit growing amplitude threshold whenever its log conditioning cost
is at most the stated exponential allowance. No auxiliary sampling event
or covariance estimate is assumed here. -/
theorem eventually_neural_amplitude_scale (k : ℕ) (a : ℝ) (ha : 0<a) :
    ∀ᶠ d : ℕ in atTop,
      auxiliarySigma d k/2 ≤ a ∧
      (auxiliaryRate/131072)*(d:ℝ)^(1-spectralExponent k) ≤ (auxiliaryLevel d k a)^2 ∧
      ∀ E : Set (ClippingCube d → ℝ), MeasurableSet E →
        GaussianFieldTilt.fieldLaw (WalshGaussianEnergy.matrix
          (walshCoefficients (arcsineProfile d (k+1)))) E ≠ 0 →
        (∀ z ∈ E, ∀ x, a < |z x|) →
        Real.log (1/(GaussianFieldTilt.fieldLaw (WalshGaussianEnergy.matrix
          (walshCoefficients (arcsineProfile d (k+1))))).real E) ≤
            Real.exp (auxiliaryExponent d/4) →
        (∫ z, uniformCubeMean (fun x => if |z x| ≤ auxiliaryLevel d k a then (1:ℝ) else 0)
          ∂cond (GaussianFieldTilt.fieldLaw (WalshGaussianEnergy.matrix
            (walshCoefficients (arcsineProfile d (k+1))))) E) ≤ 1/32 := by
  classical
  filter_upwards [eventually_auxiliarySigma_half_le k a ha,
    auxiliaryExponent_tendsto.eventually eventually_amplitude_scalar_bound,
    eventually_ge_atTop 262144] with d hsigma hscalar hd
  refine ⟨hsigma, auxiliaryLevel_sq_lower hd k a ha.le, ?_⟩
  intro E hE hEpos hmargin hcost
  let A := WalshGaussianEnergy.matrix (walshCoefficients (arcsineProfile d (k+1)))
  let D := Real.log (1/(GaussianFieldTilt.fieldLaw A).real E)
  have hD : 0 ≤ D := by
    apply Real.log_nonneg
    have hp : 0 < (GaussianFieldTilt.fieldLaw A).real E :=
      ENNReal.toReal_pos hEpos (measure_ne_top _ _)
    exact (le_div_iff₀ hp).mpr (by simp)
  have hpop := neural_population_amplitude d k (auxiliaryCutoff d) (auxiliaryCount d)
    (auxiliaryCutoff_bounds d).1 (auxiliaryCount_pos d) a (Real.sqrt (auxiliaryExponent d))
    (Real.sqrt_nonneg _) hsigma E hE hEpos hmargin
  have hbound := hscalar a (auxiliarySigma d k) D (auxiliaryCount d:ℝ)
    (d.choose (auxiliaryCutoff d):ℝ) (auxiliarySigma_pos hd k) ha.le hD hcost
    (auxiliaryCount_bounds d).1 (auxiliaryCount_bounds d).2 (auxiliary_choose_lower d)
  exact hpop.trans hbound

end NeuralGeneralization.GaussianAmplitude
