import NeuralGeneralization.NeuralSpectrumMonotone
import NeuralGeneralization.BinomialGeometricBounds
import NeuralGeneralization.ArcsineTraceReal
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics
import Mathlib.Algebra.Order.Floor.Ring

/-! A concrete polylogarithmic cutoff for all small sample sizes.
The cutoff is odd, tends to infinity, and is negligible compared with every
positive power of the dimension. Binomial doubling alone makes every
remaining eigenvalue negligible uniformly for n ≤ exp(log(d+1)^3). -/
noncomputable section
open Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.SmallSampleCutoff

def logDimension (d : ℕ) : ℝ := Real.log ((d : ℝ)+1)

def cutoff (d : ℕ) : ℕ := 2*⌈logDimension d^4 / Real.log 2⌉₊+1

theorem logDimension_nonneg (d : ℕ) : 0 ≤ logDimension d :=
  Real.log_nonneg (by have := Nat.cast_nonneg (α := ℝ) d; linarith)

theorem logDimension_tendsto : Tendsto logDimension atTop atTop :=
  Real.tendsto_log_atTop.comp (tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop)

theorem cutoff_pos (d : ℕ) : 0 < cutoff d := by unfold cutoff; omega

theorem cutoff_odd (d : ℕ) : Odd (cutoff d) := ⟨_, rfl⟩

theorem cutoff_lower (d : ℕ) : 2*logDimension d^4 ≤ (cutoff d : ℝ)*Real.log 2 := by
  have hp : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h := mul_le_mul_of_nonneg_right (Nat.le_ceil (logDimension d^4 / Real.log 2)) hp.le
  rw [div_mul_cancel₀ _ hp.ne'] at h
  dsimp [cutoff]
  push_cast
  nlinarith

theorem cutoff_upper (d : ℕ) : (cutoff d : ℝ) ≤
    (2/Real.log 2)*logDimension d^4+3 := by
  have hp : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h := Nat.ceil_lt_add_one (show 0 ≤ logDimension d^4 / Real.log 2 by positivity)
  dsimp [cutoff]
  push_cast
  convert (show 2*(⌈logDimension d^4 / Real.log 2⌉₊ : ℝ)+1 ≤
    2*(logDimension d^4 / Real.log 2+1)+1 by linarith) using 1 <;> ring

/-- The actual chosen cutoff is sub-polynomial, including o(sqrt d). -/
theorem cutoff_div_rpow_tendsto (a : ℝ) (ha : 0 < a) :
    Tendsto (fun d : ℕ => (cutoff d : ℝ)/((d : ℝ)+1)^a) atTop (𝓝 0) := by
  have hD : Tendsto (fun d : ℕ => (d : ℝ)+1) atTop atTop :=
    tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop
  have hlog : Tendsto (fun d : ℕ => logDimension d^4 / ((d : ℝ)+1)^a) atTop (𝓝 0) := by
    simpa only [Function.comp_def, Real.rpow_ofNat, logDimension] using
      (isLittleO_log_rpow_rpow_atTop (4 : ℝ) ha).tendsto_div_nhds_zero.comp hD
  have hinv : Tendsto (fun d : ℕ => (3 : ℝ)/((d : ℝ)+1)^a) atTop (𝓝 0) := by
    simpa using tendsto_const_nhds.div_atTop ((tendsto_rpow_atTop ha).comp hD)
  have hup : Tendsto (fun d : ℕ => ((2/Real.log 2)*logDimension d^4+3)/((d : ℝ)+1)^a)
      atTop (𝓝 0) := by
    simpa only [add_div, mul_div_assoc, mul_zero, zero_add] using
      (hlog.const_mul (2/Real.log 2)).add hinv
  apply squeeze_zero (fun d => by positivity) _ hup
  intro d
  exact div_le_div_of_nonneg_right (cutoff_upper d) (Real.rpow_nonneg (by positivity) _)

/-- Any fixed multiple of this cutoff is eventually below the dimension. -/
theorem eventually_multiple_cutoff_le (C : ℕ) :
    ∀ᶠ d : ℕ in atTop, C*cutoff d ≤ d := by
  have h := (cutoff_div_rpow_tendsto 1 (by norm_num)).eventually
    (eventually_le_nhds (show (0 : ℝ) < 1/(2*((C : ℝ)+1)) by positivity))
  filter_upwards [h, eventually_ge_atTop 1] with d hd hd1
  rw [Real.rpow_one] at hd
  have hD : 0 < (d : ℝ)+1 := by positivity
  have hc : 0 < 2*((C : ℝ)+1) := by positivity
  have hb := (div_le_iff₀ hD).mp hd
  have hb' := (le_div_iff₀ hc).mp (show (cutoff d : ℝ) ≤ ((d : ℝ)+1)/(2*((C : ℝ)+1)) by simpa only [one_div, div_eq_mul_inv, mul_comm, one_mul] using hb)
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd1
  have hn : 0 ≤ (cutoff d : ℝ) := Nat.cast_nonneg _
  have hfin : (C : ℝ)*(cutoff d : ℝ) ≤ d := by nlinarith
  exact_mod_cast hfin

/-- The dyadic binomial lower bound holds at the actual cutoff. -/
theorem eventually_choose_lower : ∀ᶠ d : ℕ in atTop,
    Real.exp (2*logDimension d^4) ≤ (d.choose (cutoff d) : ℝ) := by
  filter_upwards [eventually_multiple_cutoff_le 3] with d hd
  have hchoose : (2 : ℝ)^cutoff d ≤ (d.choose (cutoff d) : ℝ) := by
    have hn := BinomialGeometry.choose_growth (D:=d) (k:=0)
      (j:=cutoff d) (B:=cutoff d) (Nat.zero_le _) le_rfl hd
    norm_num at hn
    exact_mod_cast hn
  have he : Real.exp (2*logDimension d^4) ≤ (2 : ℝ)^cutoff d := by
    rw [← Real.exp_log (by positivity : (0 : ℝ) < (2 : ℝ)^cutoff d), Real.log_pow]
    exact Real.exp_le_exp.mpr (cutoff_lower d)
  exact he.trans hchoose

/-- The concrete dimension-dependent envelope tends to zero uniformly in
all admissible sample sizes. -/
theorem eventually_small_sample_ratio (C : ℝ) (hC : 0 ≤ C) (m : ℕ) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℝ, 0 ≤ n → n ≤ Real.exp (logDimension d^3) →
      C*((d : ℝ)+1)^m*(1+n)/(d.choose (cutoff d) : ℝ) ≤ 2*C/((d : ℝ)+1) := by
  filter_upwards [eventually_choose_lower,
    logDimension_tendsto.eventually_ge_atTop ((m : ℝ)+2)] with d hchoose ht n hn hnmax
  have hD : 0 < (d : ℝ)+1 := by positivity
  have ht0 := logDimension_nonneg d
  have ht1 : 1 ≤ logDimension d := by have := Nat.cast_nonneg (α := ℝ) m; linarith
  have hm : ((m : ℝ)+1)*logDimension d ≤ logDimension d^2 := by nlinarith
  have h23 : logDimension d^2 ≤ logDimension d^3 := by
    nlinarith [mul_le_mul_of_nonneg_right ht1 (sq_nonneg (logDimension d))]
  have h34 : logDimension d^3 ≤ logDimension d^4 := by
    nlinarith [mul_le_mul_of_nonneg_right ht1 (pow_nonneg ht0 3)]
  have hpoly : ((m : ℝ)+1)*logDimension d+logDimension d^3 ≤ 2*logDimension d^4 := by linarith
  have hE : ((d : ℝ)+1)^(m+1)*Real.exp (logDimension d^3) ≤ Real.exp (2*logDimension d^4) := by
    rw [show ((d : ℝ)+1)^(m+1) = Real.exp (((m : ℝ)+1)*logDimension d) by
      rw [show (m : ℝ)+1=((m+1 : ℕ) : ℝ) by simp, Real.exp_nat_mul]
      simp only [logDimension, Real.exp_log hD], ← Real.exp_add]
    exact Real.exp_le_exp.mpr hpoly
  have hone : 1 ≤ Real.exp (logDimension d^3) := Real.one_le_exp (pow_nonneg ht0 3)
  have hsize : ((d : ℝ)+1)^(m+1)*(1+n) ≤ 2*(d.choose (cutoff d) : ℝ) := by
    calc
      _ ≤ ((d : ℝ)+1)^(m+1)*(2*Real.exp (logDimension d^3)) := by gcongr; linarith
      _ = 2*(((d : ℝ)+1)^(m+1)*Real.exp (logDimension d^3)) := by ring
      _ ≤ _ := by linarith
  have hchoosepos : 0 < (d.choose (cutoff d) : ℝ) := (Real.exp_pos _).trans_le hchoose
  apply (div_le_div_iff₀ hchoosepos hD).mpr
  have hmul := mul_le_mul_of_nonneg_left hsize hC
  rw [pow_succ] at hmul
  nlinarith only [hmul]

/-- Uniform relative eigenvalue suppression for the actual neural kernel.
This also controls eigenvalue/tail ratios without any separate lower bound
on the trace tail. -/
theorem eventually_small_sample_spectral_ratio (C : ℝ) (hC : 0 ≤ C) (m : ℕ) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℝ, 0 ≤ n → n ≤ Real.exp (logDimension d^3) →
      ∀ k : ℕ, ∀ S : Finset (Fin d), cutoff d ≤ S.card →
      C*((d : ℝ)+1)^m*(1+n)*walshCoefficients (arcsineProfile d k) S ≤
        (2*C/((d : ℝ)+1))*walshSpectralTail (arcsineProfile d k) (cutoff d) := by
  filter_upwards [eventually_small_sample_ratio C hC m, eventually_choose_lower] with d hd hp n hn hnmax k S hS
  have hbin := arcsineProfile_coefficient_binomial_le_tail k (cutoff d) S hS
  have hden : 0 < (d.choose (cutoff d) : ℝ) := (Real.exp_pos _).trans_le hp
  have htail : 0 ≤ walshSpectralTail (arcsineProfile d k) (cutoff d) :=
    Finset.sum_nonneg (fun T hT => arcsineProfile_coefficient_nonneg d k T)
  have hcoef := (le_div_iff₀ hden).mpr (by simpa only [mul_comm] using hbin)
  calc
    _ ≤ C*((d : ℝ)+1)^m*(1+n)*(walshSpectralTail (arcsineProfile d k) (cutoff d)/
        (d.choose (cutoff d) : ℝ)) := mul_le_mul_of_nonneg_left hcoef (by positivity)
    _ = (C*((d : ℝ)+1)^m*(1+n)/(d.choose (cutoff d) : ℝ))*
        walshSpectralTail (arcsineProfile d k) (cutoff d) := by ring
    _ ≤ _ := mul_le_mul_of_nonneg_right (hd n hn hnmax) htail

/-- A convenient epsilon version with no remaining cutoff certificate. -/
theorem eventually_small_sample_spectral_epsilon (C : ℝ) (hC : 0 ≤ C) (m : ℕ)
    (ε : ℝ) (hε : 0 < ε) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℝ, 0 ≤ n → n ≤ Real.exp (logDimension d^3) →
      ∀ k : ℕ, ∀ S : Finset (Fin d), cutoff d ≤ S.card →
      C*((d : ℝ)+1)^m*(1+n)*walshCoefficients (arcsineProfile d k) S ≤
        ε*walshSpectralTail (arcsineProfile d k) (cutoff d) := by
  have hlim : Tendsto (fun d : ℕ => 2*C/((d : ℝ)+1)) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop (tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop)
  filter_upwards [eventually_small_sample_spectral_ratio C hC m,
    hlim.eventually (eventually_le_nhds hε)] with d hd he n hn hnmax k S hS
  exact (hd n hn hnmax k S hS).trans (mul_le_mul_of_nonneg_right he
    (Finset.sum_nonneg fun T hT => arcsineProfile_coefficient_nonneg d k T))

/-- The same concrete cutoff tends to infinity. -/
theorem cutoff_tendsto : Tendsto cutoff atTop atTop := by
  have hp : Tendsto (fun d => logDimension d^4) atTop atTop := by
    simpa only [Function.comp_def, Real.rpow_ofNat] using
      (tendsto_rpow_atTop (by norm_num : (0 : ℝ)<4)).comp logDimension_tendsto
  have hc := tendsto_nat_ceil_atTop.comp
    (hp.atTop_div_const (Real.log_pos (by norm_num : (1 : ℝ)<2)))
  exact tendsto_atTop_mono (fun d => by dsimp [cutoff]; omega) hc

/-- The actual trace tail at this cutoff vanishes at every fixed depth. -/
theorem spectral_tail_tendsto (k : ℕ) :
    Tendsto (fun d => walshSpectralTail (arcsineProfile d k) (cutoff d)) atTop (𝓝 0) := by
  have hb : 0 < 1/(2 : ℝ)^k := by positivity
  have hc : Tendsto (fun d => (cutoff d : ℝ)) atTop atTop :=
    tendsto_natCast_atTop_atTop.comp cutoff_tendsto
  have hl := ((tendsto_rpow_neg_atTop hb).comp hc).const_mul 4
  simp only [mul_zero] at hl
  apply squeeze_zero (fun d => Finset.sum_nonneg (fun S hS => arcsineProfile_coefficient_nonneg d k S)) _ hl
  intro d
  exact iterated_arcsine_spectral_tail_upper d k (cutoff d) (cutoff_pos d)

/-- The normalization is the exact diagonal covariance, hence trace one. -/
theorem spectral_tail_le_one (d k r : ℕ) : walshSpectralTail (arcsineProfile d k) r ≤ 1 := by
  classical
  have hs : (∑ S : Finset (Fin d), walshCoefficients (arcsineProfile d k) S) = 1 := by
    have h := walshExpansion_coefficients (arcsineProfile d k) (fun _ => true)
    simpa [walshExpansion, walshCharacter, cubeCoordinateSign, arcsineProfile_one] using h
  rw [← hs]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
    (fun S hS hnot => arcsineProfile_coefficient_nonneg d k S)

def lowBand (d : ℕ) : Finset (Finset (Fin d)) :=
  Finset.univ.filter fun S => S.card < cutoff d

/-- Uniform actual Fourier approximation under the precise Gaussian RKHS
energy convention. No abstract spectral estimate remains in this theorem. -/
theorem eventually_projection_error (C : ℝ) (hC : 0 ≤ C) (m : ℕ)
    (ε : ℝ) (hε : 0 < ε) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℝ, 0 ≤ n → n ≤ Real.exp (logDimension d^3) →
      ∀ k : ℕ, ∀ z : ClippingCube d → ℝ,
      finiteQuadratic (walshPrecisionKernel (walshCoefficients (arcsineProfile d (k+1)))) z ≤
        C*((d : ℝ)+1)^m*(1+n) →
      uniformCubeMean (fun x => (z x-walshProjection (lowBand d) z x)^2) ≤ ε := by
  classical
  have hlim : Tendsto (fun d : ℕ => 2*C/((d : ℝ)+1)) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop (tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop)
  filter_upwards [eventually_small_sample_ratio C hC m, eventually_choose_lower,
    hlim.eventually (eventually_le_nhds hε)] with d hd hp he n hn hnmax k z henergy
  let w := walshCoefficients (arcsineProfile d (k+1))
  let T := Finset.univ \ lowBand d
  let τ := walshSpectralTail (arcsineProfile d (k+1)) (cutoff d)
  let ell := τ/(d.choose (cutoff d) : ℝ)
  have hden : 0 < (d.choose (cutoff d) : ℝ) := (Real.exp_pos _).trans_le hp
  have htau : 0 ≤ τ := Finset.sum_nonneg (fun S hS => arcsineProfile_coefficient_nonneg d (k+1) S)
  have hell : 0 ≤ ell := div_nonneg htau hden.le
  have hmax : ∀ S ∈ T, w S ≤ ell := by
    intro S hS
    have hcard : cutoff d ≤ S.card := by simpa [T, lowBand] using hS
    apply (le_div_iff₀ hden).mpr
    simpa only [mul_comm] using arcsineProfile_coefficient_binomial_le_tail (k+1) (cutoff d) S hcard
  have herr := walshProjection_population_square_le w (iterated_arcsine_coefficient_pos d k)
    T z ell hell hmax
  have hfun (x : ClippingCube d) : z x-walshProjection (lowBand d) z x=walshProjection T z x := by
    have hh := walshProjection_decomposition (lowBand d) z x
    change z x = _ + walshProjection T z x at hh
    linarith
  simp_rw [hfun]
  apply herr.trans
  calc
    ell*finiteQuadratic (walshPrecisionKernel w) z ≤ ell*(C*((d : ℝ)+1)^m*(1+n)) :=
      mul_le_mul_of_nonneg_left henergy hell
    _ = (C*((d : ℝ)+1)^m*(1+n)/(d.choose (cutoff d) : ℝ))*τ := by dsimp [ell]; ring
    _ ≤ (2*C/((d : ℝ)+1))*τ := mul_le_mul_of_nonneg_right (hd n hn hnmax) htau
    _ ≤ (2*C/((d : ℝ)+1))*1 := mul_le_mul_of_nonneg_left
      (spectral_tail_le_one d (k+1) (cutoff d)) (by positivity)
    _ ≤ ε := by simpa using he

end NeuralGeneralization.SmallSampleCutoff
