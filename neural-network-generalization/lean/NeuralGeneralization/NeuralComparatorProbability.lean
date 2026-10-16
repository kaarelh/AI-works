import NeuralGeneralization.NeuralPolynomialConditioningCost
import NeuralGeneralization.SmallSampleCutoff

/-! Uniformly probable neural localized comparators, on an explicit
exponential range of sample sizes. All estimates apply to the actual IID law. -/
noncomputable section
open MeasureTheory Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.LocalizedCubeBump
open ConcreteModel CompressionSampling

lemma positive_pow_eq_exp (a : ℝ) (ha : 0<a) (n : ℕ) :
    a^n=Real.exp ((n:ℝ)*Real.log a) := by
  rw [Real.exp_nat_mul,Real.exp_log ha]

lemma comparator_separation_envelope (d n : ℕ)
    (hn : (n:ℝ) ≤ Real.exp ((d:ℝ)/1000)) :
    (n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*(d/10)) ≤ Real.exp (-(d:ℝ)/25) := by
  have hn0 : (0:ℝ)≤n := Nat.cast_nonneg _
  have hn2 := pow_le_pow_left₀ hn0 hn 2
  rw [←Real.exp_nat_mul] at hn2
  norm_num only [Nat.cast_ofNat] at hn2
  have hr : (10:ℝ)*(d/10:ℕ)≤d := by exact_mod_cast (show 10*(d/10)≤d from Nat.mul_div_le d 10)
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg _
  have hl3 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<3/4)
  have hl2 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
  have hlog : Real.log (1/2:ℝ)= -Real.log 2 := by rw [one_div,Real.log_inv]
  calc
    _ ≤ Real.exp (2*((d:ℝ)/1000))*(3/4:ℝ)^d/(1/2:ℝ)^(2*(d/10)) := by
      exact div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_right hn2 (by positivity)) (by positivity)
    _ = Real.exp (2*((d:ℝ)/1000)+(d:ℝ)*Real.log (3/4)+(2:ℝ)*(d/10:ℕ)*Real.log 2) := by
      rw [positive_pow_eq_exp _ (by norm_num),positive_pow_eq_exp _ (by norm_num),
        ←Real.exp_add,←Real.exp_sub,hlog]
      push_cast
      congr 1
      ring
    _ ≤ _ := by
      apply Real.exp_le_exp.mpr
      have h3 := mul_le_mul_of_nonneg_left hl3 hd0
      have h2 := mul_le_mul_of_nonneg_left hl2 (by positivity : (0:ℝ)≤2*(d/10:ℕ))
      nlinarith

lemma comparator_smallness_envelope {d n : ℕ} (hd : 20≤d)
    (hn : (n:ℝ) ≤ Real.exp ((d:ℝ)/1000)) :
    (n:ℝ)*(1/5:ℝ)^(d/10) ≤ Real.exp (-(d:ℝ)/50) := by
  have hr : (d:ℝ)≤20*(d/10:ℕ) := by exact_mod_cast (show d≤20*(d/10) by omega)
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg _
  have hl := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<1/5)
  calc
    _ ≤ Real.exp ((d:ℝ)/1000)*(1/5:ℝ)^(d/10) := by gcongr
    _ = Real.exp ((d:ℝ)/1000+(d/10:ℕ)*Real.log (1/5)) := by
      rw [positive_pow_eq_exp _ (by norm_num),Real.exp_add]
    _ ≤ _ := by
      apply Real.exp_le_exp.mpr
      have hh := mul_le_mul_of_nonneg_left hl (by positivity : (0:ℝ)≤(d/10:ℕ))
      nlinarith

lemma neuralCoordinateBudget_exp_bound (d k : ℕ) :
    neuralCoordinateBudget d k ≤ (24/(2/Real.pi)^k)*((d:ℝ)+1)^3*Real.exp (-7*(d:ℝ)/25) := by
  have hl := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<18/25)
  have hp : (18/25:ℝ)^d ≤ Real.exp (-7*(d:ℝ)/25) := by
    rw [positive_pow_eq_exp _ (by norm_num)]
    apply Real.exp_le_exp.mpr
    have hh := mul_le_mul_of_nonneg_left hl (Nat.cast_nonneg d : (0:ℝ)≤d)
    nlinarith
  unfold neuralCoordinateBudget neuralFloor
  calc
    _ = (24/(2/Real.pi)^k)*((d:ℝ)+1)^3*(18/25:ℝ)^d := by field_simp
    _ ≤ _ := by gcongr

/-- A polynomial times a fixed decaying exponential tends to zero on naturals,
including a harmless unit shift in the polynomial. -/
lemma shifted_polynomial_exp_neg_tendsto (p : ℕ) (b : ℝ) (hb : 0<b) :
    Tendsto (fun d : ℕ => ((d:ℝ)+1)^p*Real.exp (-b*(d:ℝ))) atTop (𝓝 0) := by
  have h := (tendsto_rpow_mul_exp_neg_mul_atTop_nhds_zero (p:ℝ) b hb).comp
    (tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop)
  have he : (fun d : ℕ => ((d:ℝ)+1)^p*Real.exp (-b*(d:ℝ))) =
      fun d : ℕ => Real.exp b*(((d:ℝ)+1)^(p:ℝ)*Real.exp (-b*((d:ℝ)+1))) := by
    funext d
    rw [Real.rpow_natCast]
    calc
      _ = ((d:ℝ)+1)^p*(Real.exp b*Real.exp (-b*((d:ℝ)+1))) := by
        rw [←Real.exp_add]
        congr 2
        ring
      _ = _ := by ring
  rw [he]
  simpa using h.const_mul (Real.exp b)

lemma comparator_cross_envelope (d k n : ℕ) (E : ℝ) (hE : 0≤E)
    (henergy : sharpEnergyBudget d k ≤ E*((d:ℝ)+1)^3)
    (hn : (n:ℝ) ≤ Real.exp ((d:ℝ)/1000)) :
    (n:ℝ)^2*Real.sqrt (neuralCoordinateBudget d k*sharpEnergyBudget d k) ≤
      Real.sqrt ((24/(2/Real.pi)^k*E)*((d:ℝ)+1)^6*Real.exp (-(d:ℝ)/4)) := by
  have hcoef := neuralCoordinateBudget_exp_bound d k
  have hcoordpos := neuralCoordinateBudget_pos d k
  have henergypos := sharpEnergyBudget_pos d k
  have hn4 := pow_le_pow_left₀ (Nat.cast_nonneg n : (0:ℝ)≤n) hn 4
  rw [←Real.exp_nat_mul] at hn4
  norm_num only [Nat.cast_ofNat] at hn4
  have he : (n:ℝ)^4*(neuralCoordinateBudget d k*sharpEnergyBudget d k) ≤
      (24/(2/Real.pi)^k*E)*((d:ℝ)+1)^6*Real.exp (-(d:ℝ)/4) := by
    calc
      _ ≤ Real.exp (4*((d:ℝ)/1000))*
        ((24/(2/Real.pi)^k)*((d:ℝ)+1)^3*Real.exp (-7*(d:ℝ)/25)*
          (E*((d:ℝ)+1)^3)) := by
        apply mul_le_mul hn4 _ (by positivity) (Real.exp_pos _).le
        exact mul_le_mul hcoef henergy (sharpEnergyBudget_pos d k).le (by positivity)
      _ = (24/(2/Real.pi)^k*E)*((d:ℝ)+1)^6*
          Real.exp (4*((d:ℝ)/1000)-7*(d:ℝ)/25) := by
        rw [show 4*((d:ℝ)/1000)-7*(d:ℝ)/25=
          4*((d:ℝ)/1000)+(-7*(d:ℝ)/25) by ring,Real.exp_add]
        ring
      _ ≤ _ := by
        apply mul_le_mul_of_nonneg_left _ (by positivity)
        apply Real.exp_le_exp.mpr
        nlinarith [Nat.cast_nonneg (α:=ℝ) d]
  have hs := Real.sqrt_le_sqrt he
  rw [show (n:ℝ)^4=((n:ℝ)^2)^2 by ring,Real.sqrt_mul (sq_nonneg _),
    Real.sqrt_sq (sq_nonneg _)] at hs
  exact hs

/-- The elementary scalar exceptional-set bound is uniformly small on an
explicit exponential range. -/
theorem eventually_comparator_scalar_bounds (k : ℕ) (E : ℝ) (hE : 0≤E)
    (henergy : ∀ d, sharpEnergyBudget d k ≤ E*((d:ℝ)+1)^3)
    (δ : ℝ) (hδ : 0<δ) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ, (n:ℝ)≤Real.exp ((d:ℝ)/1000) →
      0<d/10 ∧ (n:ℝ)*(1/5:ℝ)^(d/10)<1/20 ∧
      (n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*(d/10))+
        (n:ℝ)^2*Real.sqrt (neuralCoordinateBudget d k*sharpEnergyBudget d k) ≤ δ := by
  have hsmall : Tendsto (fun d : ℕ=>Real.exp (-(d:ℝ)/50)) atTop (𝓝 0) := by
    simpa only [pow_zero,one_mul,neg_mul,mul_neg,div_eq_mul_inv,mul_comm] using
      shifted_polynomial_exp_neg_tendsto 0 (1/50) (by norm_num)
  have hsep : Tendsto (fun d : ℕ=>Real.exp (-(d:ℝ)/25)) atTop (𝓝 0) := by
    simpa only [pow_zero,one_mul,neg_mul,mul_neg,div_eq_mul_inv,mul_comm] using
      shifted_polynomial_exp_neg_tendsto 0 (1/25) (by norm_num)
  have hraw : Tendsto (fun d : ℕ=>(24/(2/Real.pi)^k*E)*((d:ℝ)+1)^6*
      Real.exp (-(d:ℝ)/4)) atTop (𝓝 0) := by
    simpa only [mul_zero,zero_mul,one_mul,mul_assoc,neg_mul,mul_neg,div_eq_mul_inv,mul_comm,mul_left_comm] using
      (shifted_polynomial_exp_neg_tendsto 6 (1/4) (by norm_num)).const_mul (24/(2/Real.pi)^k*E)
  have hcross := Real.continuous_sqrt.continuousAt.tendsto.comp hraw
  simp only [Real.sqrt_zero] at hcross
  have hsum := hsep.add hcross
  simp only [zero_add] at hsum
  filter_upwards [eventually_ge_atTop 20,
    hsmall.eventually (eventually_lt_nhds (by norm_num : (0:ℝ)<1/20)),
    hsum.eventually (eventually_le_nhds hδ)] with d hd hsm hsum n hn
  refine ⟨by omega,(comparator_smallness_envelope hd hn).trans_lt hsm,?_⟩
  exact (add_le_add (comparator_separation_envelope d n hn)
    (comparator_cross_envelope d k n E hE (henergy d) hn)).trans hsum

/-- The concrete event needed both by the global interpolant and by the
Gaussian conditioning denominator. -/
def neuralComparatorGood (d k n : ℕ) (s : Fin n → ClippingCube d) : Prop :=
  (∀ i j, i≠j → 2*(d/10)≤hammingDist (s i) (s j)) ∧
  offDiagonalSum (fun x y=>|pairEnergy (walshCoefficients (arcsineProfile d (k+1))) x y|) s ≤ 1

lemma neuralComparatorGood_probability {d : ℕ} (hd : 101≤d) (k n : ℕ) :
    1-(n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*(d/10))-
      (n:ℝ)^2*Real.sqrt (neuralCoordinateBudget d k*sharpEnergyBudget d k) ≤
      sampleProbability (uniformLaw d) n (neuralComparatorGood d k n) := by
  classical
  let w := walshCoefficients (arcsineProfile d (k+1))
  let μ := iidSamples (uniformCubeMeasure d) n
  let SepBad := {s : Fin n → ClippingCube d | ¬ ∀ i j, i≠j → 2*(d/10)≤hammingDist (s i) (s j)}
  let CrossBad := {s : Fin n → ClippingCube d | 1≤offDiagonalSum (fun x y=>|pairEnergy w x y|) s}
  have hs := separation_bad_probability d n (d/10)
  have hc := pairEnergy_bad_probability (n:=n) w
    (fun S=>(iterated_arcsine_coefficient_pos d k S).le)
    (neuralCoordinateBudget d k) (neuralCoordinateBudget_pos d k).le
    (neural_coefficient_energy_max (by omega) k) 1 (by norm_num)
  have he := sharp_diagonalEnergy_bound hd k
  have hp : (n:ℝ)^2*Real.sqrt (neuralCoordinateBudget d k*diagonalEnergy w) ≤
      (n:ℝ)^2*Real.sqrt (neuralCoordinateBudget d k*sharpEnergyBudget d k) := by
    apply mul_le_mul_of_nonneg_left _ (sq_nonneg _)
    apply Real.sqrt_le_sqrt
    exact mul_le_mul_of_nonneg_left he (neuralCoordinateBudget_pos d k).le
  simp only [div_one] at hc
  have hc' := hc.trans hp
  rw [←uniformCubeSample_measure_eq_probability] at hs hc'
  change μ.real SepBad≤_ at hs
  change μ.real CrossBad≤_ at hc'
  have hb := (measureReal_union_le (μ:=μ) SepBad CrossBad).trans (add_le_add hs hc')
  have hg : 1-(n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*(d/10))-
      (n:ℝ)^2*Real.sqrt (neuralCoordinateBudget d k*sharpEnergyBudget d k) ≤
      μ.real (SepBad∪CrossBad)ᶜ := by
    rw [probReal_compl_eq_one_sub (Set.toFinite _).measurableSet]
    linarith
  rw [←uniformCubeSample_measure_eq_probability]
  refine hg.trans (measureReal_mono ?_)
  intro s hs
  have hsc : s∉SepBad ∧ s∉CrossBad := by
    simpa only [Set.mem_compl_iff,Set.mem_union,not_or] using hs
  exact ⟨not_not.mp hsc.1,(lt_of_not_ge hsc.2).le⟩

/-- The actual comparator event is uniformly probable for every sample size
up to `exp(d/1000)`, including zero samples. -/
theorem eventually_neuralComparatorGood_probability (k : ℕ) (δ : ℝ) (hδ : 0<δ) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ, (n:ℝ)≤Real.exp ((d:ℝ)/1000) →
      0<d/10 ∧ (n:ℝ)*(1/5:ℝ)^(d/10)<1/20 ∧
      1-δ≤sampleProbability (uniformLaw d) n (neuralComparatorGood d k n) := by
  filter_upwards [eventually_ge_atTop 101,
    eventually_comparator_scalar_bounds k (energyPolyConstant k)
      (energyPolyConstant_pos k).le (fun d=>sharpEnergyBudget_polynomial_le d k) δ hδ]
    with d hd hb n hn
  obtain ⟨hR, hsmall, herror⟩ := hb n hn
  refine ⟨hR,hsmall,?_⟩
  have hp := neuralComparatorGood_probability hd k n
  linarith

lemma eventually_small_sample_le_comparator_exponential :
    ∀ᶠ d : ℕ in atTop,
      Real.exp (SmallSampleCutoff.logDimension d^3)≤Real.exp ((d:ℝ)/1000) := by
  have hD : Tendsto (fun d : ℕ=>(d:ℝ)+1) atTop atTop :=
    tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop
  have hlog : Tendsto (fun d : ℕ=>SmallSampleCutoff.logDimension d^3/((d:ℝ)+1)) atTop (𝓝 0) := by
    simpa only [SmallSampleCutoff.logDimension,Function.comp_def,Real.rpow_ofNat,Real.rpow_one] using
      (isLittleO_log_rpow_rpow_atTop (3:ℝ) (by norm_num : (0:ℝ)<1)).tendsto_div_nhds_zero.comp hD
  filter_upwards [eventually_ge_atTop 1,
    hlog.eventually (eventually_le_nhds (by norm_num : (0:ℝ)<1/2000))] with d hd hl
  apply Real.exp_le_exp.mpr
  have hh := (div_le_iff₀ (by positivity : (0:ℝ)<(d:ℝ)+1)).mp hl
  have hdR : (1:ℝ)≤d := by exact_mod_cast hd
  nlinarith

/-- A convenient uniform specialization to the subexponential range used
by the polynomial-threshold obstruction. -/
theorem eventually_small_sample_neuralComparatorGood_probability (k : ℕ) (δ : ℝ) (hδ : 0<δ) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ,
      (n:ℝ)≤Real.exp (SmallSampleCutoff.logDimension d^3) →
      0<d/10 ∧ (n:ℝ)*(1/5:ℝ)^(d/10)<1/20 ∧
      1-δ≤sampleProbability (uniformLaw d) n (neuralComparatorGood d k n) := by
  filter_upwards [eventually_neuralComparatorGood_probability k δ hδ,
    eventually_small_sample_le_comparator_exponential] with d hd hexp n hn
  exact hd n (hn.trans hexp)

end NeuralGeneralization.LocalizedCubeBump
