import NeuralGeneralization.NeuralTailCoherence
import NeuralGeneralization.ArcsineTraceReal
import NeuralGeneralization.SmallSampleCutoff
import NeuralGeneralization.CubeFarPairs
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics

/-! Uniform absorption of the far-coherence and near-pair errors. -/
noncomputable section
namespace NeuralGeneralization.TailCoherenceAsymptotics
open Filter
open scoped Topology
open SmallSampleCutoff CubeFarPairs

def radius (d r : ℕ) : ℝ := (d+1:ℝ)*Real.exp (-(r:ℝ)/4)+2/(2:ℝ)^r

lemma radius_nonneg (d r : ℕ) : 0≤radius d r := by unfold radius; positivity

lemma radius_le_exp (d r : ℕ) :
    radius d r≤3*(d+1:ℝ)*Real.exp (-(r:ℝ)/4) := by
  have hlog : (1:ℝ)/4≤Real.log 2 := by
    have hh := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at hh
    linarith
  have he : (2:ℝ)^r=Real.exp ((r:ℝ)*Real.log 2) := by
    rw [Real.exp_nat_mul,Real.exp_log (by norm_num : (0:ℝ)<2)]
  have htail : 2/(2:ℝ)^r≤2*Real.exp (-(r:ℝ)/4) := by
    rw [he,div_eq_mul_inv,← Real.exp_neg]
    apply mul_le_mul_of_nonneg_left _ (by norm_num)
    apply Real.exp_le_exp.mpr
    have hh := mul_le_mul_of_nonneg_left hlog (Nat.cast_nonneg r (α:=ℝ))
    linarith
  have hD : (1:ℝ)≤d+1 := by have := Nat.cast_nonneg d (α:=ℝ); linarith
  have hE := Real.exp_pos (-(r:ℝ)/4)
  unfold radius
  nlinarith only [htail,hD,hE]

/-- Above the logarithmic-square cutoff, coherence beats every fixed
polynomial, uniformly in the choice of the cutoff. -/
theorem eventually_radius_le_inverse_power (m : ℕ) :
    ∀ᶠ d : ℕ in atTop,∀ r : ℕ,logDimension d^2/2≤(r:ℝ) →
      radius d r≤1/(d+1:ℝ)^m := by
  filter_upwards [logDimension_tendsto.eventually_ge_atTop (8*((m:ℝ)+2)),
    eventually_ge_atTop (2:ℕ)] with d hlog hd r hr
  have hD : (3:ℝ)≤d+1 := by exact_mod_cast (by omega : 3≤d+1)
  have hD0 : (0:ℝ)<d+1 := by positivity
  have hL := logDimension_nonneg d
  have hquadratic : ((m:ℝ)+2)*logDimension d≤(r:ℝ)/4 := by
    nlinarith [mul_le_mul_of_nonneg_right hlog hL]
  have he : Real.exp (-(r:ℝ)/4)≤1/(d+1:ℝ)^(m+2) := by
    have hh : Real.exp (-(r:ℝ)/4)≤Real.exp (-(((m:ℝ)+2)*logDimension d)) :=
      Real.exp_le_exp.mpr (by linarith)
    rw [Real.exp_neg] at hh
    have hidentity : Real.exp (((m:ℝ)+2)*logDimension d)=(d+1:ℝ)^(m+2) := by
      rw [show (m:ℝ)+2=((m+2:ℕ):ℝ) by norm_num,Real.exp_nat_mul]
      unfold logDimension
      rw [Real.exp_log hD0]
    rw [hidentity] at hh
    simpa only [one_div] using hh
  calc
    radius d r≤3*(d+1:ℝ)*Real.exp (-(r:ℝ)/4) := radius_le_exp d r
    _ ≤3*(d+1:ℝ)*(1/(d+1:ℝ)^(m+2)) := mul_le_mul_of_nonneg_left he (by positivity)
    _ ≤1/(d+1:ℝ)^m := by
      rw [mul_one_div]
      apply (div_le_div_iff₀ (by positivity : (0:ℝ)<(d+1:ℝ)^(m+2))
        (by positivity : (0:ℝ)<(d+1:ℝ)^m)).mpr
      rw [pow_add,pow_two]
      have hh := mul_le_mul_of_nonneg_right hD (by positivity : (0:ℝ)≤(d+1:ℝ)^m*(d+1))
      nlinarith only [hh]

lemma spectral_tail_inverse_dimension_lower (depth d r : ℕ)
    (hdepth : 1≤depth) (hr : 0<r) (hdim : 131072*r≤d) :
    1/(16384*(d+1:ℝ))≤walshSpectralTail (arcsineProfile d depth) r := by
  have hβ0 : 0≤1/(2:ℝ)^depth := by positivity
  have hβ1 : 1/(2:ℝ)^depth≤1 := by
    have hh : (1:ℝ)≤2^depth := one_le_pow₀ (by norm_num)
    exact (div_le_one (by positivity)).mpr hh
  have hr1 : (1:ℝ)≤r := by exact_mod_cast hr
  have hrD : (r:ℝ)≤d+1 := by exact_mod_cast (by omega : r≤d+1)
  have hp : (r:ℝ)^(1/(2:ℝ)^depth)≤d+1 := by
    have hh := Real.rpow_le_rpow_of_exponent_le hr1 hβ1
    rw [Real.rpow_one] at hh
    exact hh.trans hrD
  have hinv := one_div_le_one_div_of_le
    (Real.rpow_pos_of_pos (by positivity : (0:ℝ)<r) (1/(2:ℝ)^depth)) hp
  simp only [one_div] at hinv
  rw [← Real.rpow_neg (by positivity : (0:ℝ)≤r)] at hinv
  have hh := div_le_div_of_nonneg_right hinv (by norm_num : (0:ℝ)≤16384)
  have hlo := iterated_arcsine_spectral_tail_lower d depth r hdepth hr hdim
  calc
    _ = (d+1:ℝ)⁻¹/16384 := by field_simp
    _ ≤ (r:ℝ)^(-(2^depth:ℝ)⁻¹)/16384 := hh
    _ ≤ _ := by simpa only [one_div] using hlo

theorem eventually_dimension_radius_le_trace (depth : ℕ) (hdepth : 1≤depth) :
    ∀ᶠ d : ℕ in atTop,∀ r : ℕ,0<r →131072*r≤d →logDimension d^2/2≤(r:ℝ) →
      (d:ℝ)*radius d r≤walshSpectralTail (arcsineProfile d depth) r := by
  filter_upwards [eventually_radius_le_inverse_power 3,eventually_ge_atTop (16384:ℕ)]
    with d hrad hd r hr hdim hlog
  have hD : (16384:ℝ)≤d+1 := by exact_mod_cast (by omega : 16384≤d+1)
  have hD0 : (0:ℝ)<d+1 := by positivity
  calc
    (d:ℝ)*radius d r≤(d:ℝ)*(1/(d+1:ℝ)^3) :=
      mul_le_mul_of_nonneg_left (hrad r hlog) (Nat.cast_nonneg d)
    _ ≤1/(16384*(d+1:ℝ)) := by
      rw [mul_one_div]
      apply (div_le_div_iff₀ (by positivity : (0:ℝ)<(d+1:ℝ)^3) (by positivity)).mpr
      have hh := mul_le_mul_of_nonneg_right hD (by positivity : (0:ℝ)≤(d+1:ℝ)^2)
      nlinarith only [hh,sq_nonneg (d:ℝ)]
    _ ≤_ := spectral_tail_inverse_dimension_lower depth d r hdepth hr hdim

end NeuralGeneralization.TailCoherenceAsymptotics
