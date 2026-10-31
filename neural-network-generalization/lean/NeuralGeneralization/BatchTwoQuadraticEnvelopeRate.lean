import NeuralGeneralization.BatchTwoQuadraticEnvelopeModel
import NeuralGeneralization.BatchTwoNonGaussianStrongClass

/-! Small-variance rate separation for the actual independent coordinate
model with two-sided quadratic density envelopes. -/
noncomputable section
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.QuadraticEnvelope
open ConcreteModel
variable {a b : ℝ}

theorem smallMass_gaussian_lower {d N r : ℕ} (ν : WeightIndex d N r→Coordinate a b)
    (hd : 0<d) (hN : 0<N) (hb : 0<b) (σ : ℝ) (φ : ℝ→ℝ) (f : BooleanFunction d) :
    lowerProduct ν*functionMass φ (1/2) (ConcreteModel.smallPrior d N r (σ/Real.sqrt b)) f≤
      functionMass φ (1/2) (smallPrior ν σ) f := by
  have h := ENNReal.toReal_mono (measure_ne_top (smallPrior ν σ) (marginEvent φ (1/2) f))
    ((smallPrior_gaussian_lower ν hd hN hb σ) (marginEvent φ (1/2) f))
  simpa only [functionMass,Measure.smul_apply,smul_eq_mul,ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (lowerProduct_pos ν hb).le] using h

theorem smallMass_gaussian_upper {d N r : ℕ} (ν : WeightIndex d N r→Coordinate a b)
    (hd : 0<d) (hN : 0<N) (ha : 0<a) (σ : ℝ) (φ : ℝ→ℝ) (f : BooleanFunction d) :
    functionMass φ (1/2) (smallPrior ν σ) f≤
      upperProduct ν*functionMass φ (1/2) (ConcreteModel.smallPrior d N r (σ/Real.sqrt a)) f := by
  have h := ENNReal.toReal_mono (by
      rw [Measure.smul_apply,smul_eq_mul]
      exact ENNReal.mul_ne_top ENNReal.ofReal_ne_top (measure_ne_top _ _))
    ((smallPrior_gaussian_upper ν hd hN ha σ) (marginEvent φ (1/2) f))
  simpa only [functionMass,Measure.smul_apply,smul_eq_mul,ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (upperProduct_pos ν ha).le] using h

theorem smallMass_pos {d C N r : ℕ} (ν : WeightIndex d N r→Coordinate a b)
    (hd : 0<d) (hb : 0<b) {φ : ℝ→ℝ} (hφ : Continuous φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C)
    (hCN : C≤N) {σ : ℝ} (hσ : 0<σ) :
    0<functionMass φ (1/2) (smallPrior ν σ) f := by
  have hN : 0<N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hp := small_functionMass_pos hd hφ f hf hCN (div_pos hσ (Real.sqrt_pos.mpr hb))
  exact (mul_pos (lowerProduct_pos ν hb) hp).trans_le (smallMass_gaussian_lower ν hd hN hb σ φ f)

theorem smallMass_ratio_tendsto_zero {d N r : ℕ} (ν : WeightIndex d N r→Coordinate a b)
    (hd : 0<d) (hN : 0<N) (ha : 0<a) (hb : 0<b)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f g : BooleanFunction d)
    (hf : (marginEvent (N:=N) (r:=r) φ (1/2) f).Nonempty)
    (hg : (marginEvent (N:=N) (r:=r) φ (1/2) g).Nonempty)
    (hgap : b*networkEnergy (N:=N) (r:=r) φ (1/2) f<
      a*networkEnergy (N:=N) (r:=r) φ (1/2) g) :
    Tendsto (fun σ=>functionMass φ (1/2) (smallPrior ν σ) g/
      functionMass φ (1/2) (smallPrior ν σ) f) (𝓝[>] (0:ℝ)) (𝓝 0) := by
  let A := lowerProduct ν
  let B := upperProduct ν
  let u := fun σ=>functionMass φ (1/2) (ConcreteModel.smallPrior d N r (σ/Real.sqrt a)) g
  let v := fun σ=>functionMass φ (1/2) (ConcreteModel.smallPrior d N r (σ/Real.sqrt b)) f
  have hA : 0<A := lowerProduct_pos ν hb
  have hB : 0<B := upperProduct_pos ν ha
  have hrU := BatchTwoNonGaussian.rescaled_gaussian_mass_rate hd hN hφ (1/2) g hg a ha
  have hrV := BatchTwoNonGaussian.rescaled_gaussian_mass_rate hd hN hφ (1/2) f hf b hb
  have hratio := hrU.ratio_tendsto_zero hrV hgap tendsto_inverse_square_nhdsGT_zero_atTop
  have hlim : Tendsto (fun σ=>(B/A)*(u σ/v σ)) (𝓝[>] (0:ℝ)) (𝓝 0) := by
    simpa only [mul_zero] using hratio.const_mul (B/A)
  apply squeeze_zero' (Eventually.of_forall fun σ=>div_nonneg
    (functionMass_nonneg _ _ _ _) (functionMass_nonneg _ _ _ _)) _ hlim
  filter_upwards [hrV.eventually_pos] with σ hv
  have hlo := smallMass_gaussian_lower ν hd hN hb σ φ f
  have hhi := smallMass_gaussian_upper ν hd hN ha σ φ g
  have hapos : 0<A*v σ := mul_pos hA hv
  have hdenom : 0<functionMass φ (1/2) (smallPrior ν σ) f := hapos.trans_le hlo
  calc
    _ ≤ B*u σ/functionMass φ (1/2) (smallPrior ν σ) f :=
      div_le_div_of_nonneg_right hhi hdenom.le
    _ ≤ B*u σ/(A*v σ) :=
      div_le_div_of_nonneg_left (mul_nonneg hB.le (functionMass_nonneg _ _ _ _)) hapos hlo
    _ = _ := by field_simp

theorem energyClass_tail_ratio {d C N r k : ℕ} (ν : WeightIndex d N r→Coordinate a b)
    (hd : 0<d) (ha : 0<a) (hb : 0<b) (hk : 1≤k) (hcompare : b≤a*k)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N) :
    Tendsto (fun σ=>
      (∑g∈Finset.univ \ BatchTwoNonGaussian.energyClass d N r (k*C) φ,
        functionMass φ (1/2) (smallPrior ν σ) g)/functionMass φ (1/2) (smallPrior ν σ) f)
      (𝓝[>] (0:ℝ)) (𝓝 0) := by
  classical
  have hN : 0<N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have htarget : networkEnergy (N:=N) (r:=r) φ (1/2) f≤
      (BatchTwoNonGaussian.teacherEnergy d r C:ℝ) := by
    simpa only [BatchTwoNonGaussian.teacherEnergy,Nat.cast_add,Nat.cast_mul,Nat.cast_pow,Nat.cast_one]
      using networkEnergy_le_complexity_polynomial φ f hf hCN
  have hscaled : (k:ℝ)*BatchTwoNonGaussian.teacherEnergy d r C≤
      (BatchTwoNonGaussian.teacherEnergy d r (k*C):ℝ) := by
    exact_mod_cast BatchTwoNonGaussian.teacherEnergy_scaled d r C k hk
  have hbound : b*networkEnergy (N:=N) (r:=r) φ (1/2) f≤
      a*(BatchTwoNonGaussian.teacherEnergy d r (k*C):ℝ) := by
    calc
      _ ≤ b*(BatchTwoNonGaussian.teacherEnergy d r C:ℝ) := mul_le_mul_of_nonneg_left htarget hb.le
      _ ≤ (a*k)*(BatchTwoNonGaussian.teacherEnergy d r C:ℝ) :=
        mul_le_mul_of_nonneg_right hcompare (Nat.cast_nonneg _)
      _ ≤ _ := by nlinarith [mul_le_mul_of_nonneg_left hscaled ha.le]
  have hratio : ∀g∈Finset.univ \ BatchTwoNonGaussian.energyClass d N r (k*C) φ,
      Tendsto (fun σ=>functionMass φ (1/2) (smallPrior ν σ) g/
        functionMass φ (1/2) (smallPrior ν σ) f) (𝓝[>] (0:ℝ)) (𝓝 0) := by
    intro g hg
    by_cases hne : (marginEvent (N:=N) (r:=r) φ (1/2) g).Nonempty
    · have hgt : (BatchTwoNonGaussian.teacherEnergy d r (k*C):ℝ)<
          networkEnergy (N:=N) (r:=r) φ (1/2) g := by
        apply lt_of_not_ge
        intro hle
        exact (Finset.mem_sdiff.mp hg).2 ((BatchTwoNonGaussian.mem_energyClass φ g).mpr ⟨hne,hle⟩)
      exact smallMass_ratio_tendsto_zero ν hd hN ha hb hφ f g
        (margin_witness_at_larger_width φ f hf hCN) hne
        (hbound.trans_lt (mul_lt_mul_of_pos_left hgt ha))
    · have hempty : marginEvent (N:=N) (r:=r) φ (1/2) g=∅ := Set.not_nonempty_iff_eq_empty.mp hne
      simpa only [functionMass,hempty,measure_empty,ENNReal.toReal_zero,zero_div] using
        (tendsto_const_nhds : Tendsto (fun _ : ℝ=>(0:ℝ)) (𝓝[>] (0:ℝ)) (𝓝 0))
  simpa only [Finset.sum_div,Finset.sum_const_zero] using
    tendsto_finsetSum (Finset.univ \ BatchTwoNonGaussian.energyClass d N r (k*C) φ) hratio

end NeuralGeneralization.QuadraticEnvelope
