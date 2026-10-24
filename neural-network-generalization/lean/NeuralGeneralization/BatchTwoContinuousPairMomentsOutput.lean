import NeuralGeneralization.BatchTwoContinuousPairMomentsHidden

/-! Sharp paired-output moments of the literal Gaussian tanh network. -/
noncomputable section
set_option maxHeartbeats 1200000
set_option maxRecDepth 10000
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuous.PairMoments
open ConcreteModel GaussianAngularFields CompressionSampling FiniteDifferential
open NetworkLayerSplit TowerNetwork GaussianNormMoments BatchTwoActivation NetworkReadout

variable {d N r : ℕ} {σ : ℝ}

theorem output_assemble_moment (h : HiddenIndex d N r→ℝ) (x y : RealInput d) (σ : ℝ)
    (p : ℕ) (hp : 0<p) :
    (∫⁻a : Fin N→ℝ,ENNReal.ofReal ((output Real.tanh (assemble h a) x-
      output Real.tanh (assemble h a) y)^2)^p ∂smallReadoutPrior N σ)≤
      ENNReal.ofReal (σ^2/(N:ℝ)*(1+2*p))^p*
        ENNReal.ofReal (hiddenDistanceSq (assemble h 0) x y)^p := by
  have ht:=scalar_linear_power_lintegral
    (fun j=>BatchTwoContinuous.finalHidden Real.tanh (assemble h 0) x j-
      BatchTwoContinuous.finalHidden Real.tanh (assemble h 0) y j)
    (σ^2/N).toNNReal p hp
  simp only [Real.coe_toNNReal _ (by positivity : 0≤σ^2/(N:ℝ))] at ht
  have hpow (z : ℝ) : ENNReal.ofReal ((z^2)^p)=ENNReal.ofReal (z^2)^p :=
    ENNReal.ofReal_pow (sq_nonneg z) p
  simp only [hpow,ENNReal.ofReal_pow (show 0≤σ^2/(N:ℝ)*
    (∑j,(BatchTwoContinuous.finalHidden Real.tanh (assemble h 0) x j-
      BatchTwoContinuous.finalHidden Real.tanh (assemble h 0) y j)^2)*(1+2*p) by positivity)] at ht
  simp only [output_pair_assemble]
  apply ht.trans_eq
  rw [show σ^2/(N:ℝ)*(∑j,(BatchTwoContinuous.finalHidden Real.tanh (assemble h 0) x j-
      BatchTwoContinuous.finalHidden Real.tanh (assemble h 0) y j)^2)*(1+2*p)=
      (σ^2/(N:ℝ)*(1+2*p))*hiddenDistanceSq (assemble h 0) x y by unfold hiddenDistanceSq; ring,
    ENNReal.ofReal_mul (by positivity),mul_pow]

def outputPairMomentBase (d N r p : ℕ) (σ : ℝ) (x y : RealInput d) : ℝ :=
  inputDistanceSq x y*σ^2/d*(1+2*p)*(σ^2*((N:ℝ)+2*p))^(r+1)

theorem output_pair_moment_lintegral (hd : 0<d) (hN : 0<N) (hσ : 0<σ)
    (x y : RealInput d) (p : ℕ) (hp : 0<p) :
    (∫⁻w : Weights d N r,ENNReal.ofReal ((output Real.tanh w x-output Real.tanh w y)^2)^p
      ∂smallPrior d N r σ)≤ENNReal.ofReal (outputPairMomentBase d N r p σ x y)^p := by
  have hm : Measurable (fun w : Weights d N r=>ENNReal.ofReal
      ((output Real.tanh w x-output Real.tanh w y)^2)^p) :=
    ((((continuous_output_weights tanh_continuous x).measurable.sub
      (continuous_output_weights tanh_continuous y).measurable).pow_const 2).ennreal_ofReal).pow_const p
  have hs:=MeasurePreserving.symm (weightSplit d N r) (smallPrior_weightSplit d N r σ)
  rw [←hs.map_eq,lintegral_map hm hs.measurable]
  have hf : Measurable (fun z : (HiddenIndex d N r→ℝ)×(Fin N→ℝ)=>ENNReal.ofReal
      ((output Real.tanh ((weightSplit d N r).symm z) x-
        output Real.tanh ((weightSplit d N r).symm z) y)^2)^p) := hm.comp hs.measurable
  rw [lintegral_prod _ hf.aemeasurable]
  simp only [weightSplit_symm]
  calc
    _≤∫⁻h,ENNReal.ofReal (σ^2/(N:ℝ)*(1+2*p))^p*
        ENNReal.ofReal (hiddenDistanceSq (assemble h 0) x y)^p ∂smallHiddenPrior d N r σ :=
      lintegral_mono (fun h=>output_assemble_moment h x y σ p hp)
    _=ENNReal.ofReal (σ^2/(N:ℝ)*(1+2*p))^p*
        (∫⁻h,ENNReal.ofReal (hiddenDistanceSq (assemble h 0) x y)^p ∂smallHiddenPrior d N r σ) := by
      rw [lintegral_const_mul' _ _ (by finiteness)]
    _≤ENNReal.ofReal (σ^2/(N:ℝ)*(1+2*p))^p*
        ENNReal.ofReal (inputDistanceSq x y*(N:ℝ)/d*(σ^2*((N:ℝ)+2*p))^(r+1))^p := by
      rw [hidden_moment_split]
      exact mul_le_mul_left' (hidden_moment_bound hd hN hσ x y p hp r) _
    _=_ := by
      rw [←mul_pow,←ENNReal.ofReal_mul (by positivity)]
      congr 2
      unfold outputPairMomentBase
      have hNR : (N:ℝ)≠0 := Nat.cast_ne_zero.mpr hN.ne'
      field_simp
      <;> ring

theorem output_pair_moment (hd : 0<d) (hN : 0<N) (hσ : 0<σ)
    (x y : RealInput d) (p : ℕ) (hp : 0<p) :
    Integrable (fun w : Weights d N r=>|output Real.tanh w x-output Real.tanh w y|^(2*p))
      (smallPrior d N r σ) ∧
    (∫w : Weights d N r,|output Real.tanh w x-output Real.tanh w y|^(2*p) ∂smallPrior d N r σ)≤
      (outputPairMomentBase d N r p σ x y)^p := by
  have hbound:=output_pair_moment_lintegral (r:=r) hd hN hσ x y p hp
  have hident (w : Weights d N r) : |output Real.tanh w x-output Real.tanh w y|^(2*p)=
      ((output Real.tanh w x-output Real.tanh w y)^2)^p := by rw [pow_mul,sq_abs]
  have hnonneg : ∀ᵐw ∂smallPrior d N r σ,0≤|output Real.tanh w x-output Real.tanh w y|^(2*p) :=
    Filter.Eventually.of_forall (fun w=>by positivity)
  have hm : Measurable (fun w : Weights d N r=>|output Real.tanh w x-output Real.tanh w y|^(2*p)) :=
    (((continuous_output_weights tanh_continuous x).measurable.sub
      (continuous_output_weights tanh_continuous y).measurable).abs).pow_const _
  have hbase : 0≤outputPairMomentBase d N r p σ x y := by
    unfold outputPairMomentBase
    have hdelta:=inputDistanceSq_nonneg x y
    positivity
  have hb : (∫⁻w : Weights d N r,ENNReal.ofReal (|output Real.tanh w x-output Real.tanh w y|^(2*p))
      ∂smallPrior d N r σ)≤ENNReal.ofReal ((outputPairMomentBase d N r p σ x y)^p) := by
    simpa only [hident,ENNReal.ofReal_pow (sq_nonneg _),ENNReal.ofReal_pow hbase] using hbound
  have hi : Integrable (fun w : Weights d N r=>|output Real.tanh w x-output Real.tanh w y|^(2*p))
      (smallPrior d N r σ) := ⟨hm.aestronglyMeasurable,
      (hasFiniteIntegral_iff_ofReal hnonneg).mpr (hb.trans_lt ENNReal.ofReal_lt_top)⟩
  refine ⟨hi,?_⟩
  rw [←ofReal_integral_eq_lintegral_ofReal hi hnonneg] at hb
  exact (ENNReal.ofReal_le_ofReal_iff (by
    unfold outputPairMomentBase
    have hdelta:=inputDistanceSq_nonneg x y
    positivity)).mp hb

end NeuralGeneralization.BatchTwoContinuous.PairMoments
