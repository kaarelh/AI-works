import NeuralGeneralization.LargeDampedConditioningCost
import NeuralGeneralization.NeuralComparatorProbability
import NeuralGeneralization.WalshMarginMinimizers

/-! A sharp actual global comparator for the positive subcritical regime.
The exponent is the actual depth-dependent cusp exponent. -/
noncomputable section
open Filter
open scoped Topology
namespace NeuralGeneralization.LocalizedCubeBump
open ConcreteModel WalshMarginMinimizers SmallSampleCutoff

def largePositiveConstant (k : ℕ) (a : ℝ) : ℝ :=
  8*a^2*(1/(2/Real.pi)^(k+1)+8*sharpDampedConstant k+4)

lemma largePositiveConstant_pos (k : ℕ) {a : ℝ} (ha : 0<a) :
    0<largePositiveConstant k a := by
  unfold largePositiveConstant
  have := sharpDampedConstant_pos k
  positivity

lemma sharp_global_comparator {d n : ℕ} (hd : 101≤d) (k : ℕ)
    {a : ℝ} (ha : 0<a) (hn : (d:ℝ)+1≤n)
    (hsharp : sharpEnergyBudget d k≤(2*sharpDampedConstant k)*(d:ℝ)^dampingExponent k)
    (hR : 0<d/10) (hsmall : (n:ℝ)*(1/5:ℝ)^(d/10)<1/20)
    (s : Fin n → Cube d) (f : BooleanFunction d) (hs : neuralComparatorGood d k n s) :
    ∃ c₀ ∈ globalTrainingMarginSet a f s,
      featureEnergy (walshCoefficients (arcsineProfile d (k+1))) c₀ ≤
        largePositiveConstant k a*(n:ℝ)*(d:ℝ)^dampingExponent k := by
  let w := walshCoefficients (arcsineProfile d (k+1))
  obtain ⟨P,hmargin,htrain,henergy⟩ := exists_global_interpolant_of_good_sample
    w (iterated_arcsine_coefficient_pos d k) a (sharpEnergyBudget d k) 1 ha
    (sharp_diagonalEnergy_bound hd k) s (d/10) hR hs.1 hsmall hs.2 f
  refine ⟨walshCoefficients P,?_,henergy.trans ?_⟩
  · constructor
    · intro x
      simpa only [walshExpansion_coefficients] using (hmargin x).le
    · intro i
      simpa only [walshExpansion_coefficients] using (htrain i).le
  · have hd1 : (1:ℝ)≤d := by exact_mod_cast (show 1≤d by omega)
    have hp : 1≤(d:ℝ)^dampingExponent k :=
      Real.one_le_rpow hd1 (dampingExponent_pos k).le
    have hn1 : (1:ℝ)≤n := by linarith
    have hnp : 1≤(n:ℝ)*(d:ℝ)^dampingExponent k := one_le_mul_of_one_le_of_one_le hn1 hp
    have hscale : (d:ℝ)+1≤(n:ℝ)*(d:ℝ)^dampingExponent k := by nlinarith only [hn,hn1,hp]
    have hc : 0≤1/(2/Real.pi)^(k+1) := by positivity
    have hconst : 1/w ∅≤(1/(2/Real.pi)^(k+1))*((d:ℝ)+1) := by
      have hh := one_div_le_one_div_of_le
        (by positivity : 0<(2/Real.pi)^(k+1)/((d:ℝ)+1))
        (arcsineProfile_coefficient_empty_lower d (k+1))
      calc
        _ ≤ 1/((2/Real.pi)^(k+1)/((d:ℝ)+1)) := hh
        _ = _ := by field_simp
    have hconst' := hconst.trans (mul_le_mul_of_nonneg_left hscale hc)
    have henergy' := mul_le_mul_of_nonneg_left hsharp (Nat.cast_nonneg n : (0:ℝ)≤n)
    have hbound : 1/w ∅+4*((n:ℝ)*sharpEnergyBudget d k+1)≤
        (1/(2/Real.pi)^(k+1)+8*sharpDampedConstant k+4)*(n:ℝ)*(d:ℝ)^dampingExponent k := by
      nlinarith only [hconst',henergy',hnp]
    have hh := mul_le_mul_of_nonneg_left hbound (show 0≤8*a^2 by positivity)
    convert hh using 1 <;> unfold largePositiveConstant <;> ring

/-- The sharp comparator is available for every actual good sample, uniformly
from the superpolynomial threshold to an exponential number of examples. -/
theorem eventually_large_positive_comparator (k : ℕ) {a : ℝ} (ha : 0<a) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ,
      Real.exp (logDimension d^3)≤(n:ℝ) → (n:ℝ)≤Real.exp ((d:ℝ)/1000) →
      ∀ s : Fin n → Cube d, neuralComparatorGood d k n s →
      ∀ f : BooleanFunction d,
      ∃ c₀ ∈ globalTrainingMarginSet a f s,
        featureEnergy (walshCoefficients (arcsineProfile d (k+1))) c₀≤
          largePositiveConstant k a*(n:ℝ)*(d:ℝ)^dampingExponent k := by
  filter_upwards [eventually_sharpEnergyBudget_le k,
    eventually_neuralComparatorGood_probability k (1/16) (by norm_num),
    logDimension_tendsto.eventually_ge_atTop 1,eventually_ge_atTop 101]
    with d hsharp hgood hlog hd n hmin hmax s hs f
  obtain ⟨hR,hsmall,_⟩ := hgood n hmax
  have hpow : logDimension d≤logDimension d^3 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤1) hlog 2
    have hh' := mul_le_mul_of_nonneg_left hh (by linarith only [hlog] : 0≤logDimension d)
    nlinarith only [hh']
  have hn : (d:ℝ)+1≤n := by
    have hh := (Real.exp_le_exp.mpr hpow).trans hmin
    simpa only [logDimension,Real.exp_log (by positivity : (0:ℝ)<(d:ℝ)+1)] using hh
  exact sharp_global_comparator hd k ha hn hsharp hR hsmall s f hs

end NeuralGeneralization.LocalizedCubeBump
