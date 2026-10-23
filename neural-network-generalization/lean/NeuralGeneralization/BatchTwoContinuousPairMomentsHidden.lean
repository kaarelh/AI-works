import NeuralGeneralization.BatchTwoContinuousPairMomentsInput

/-! Actual adaptive layer iteration of the paired hidden-state moments. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuous.PairMoments
open ConcreteModel GaussianAngularFields CompressionSampling FiniteDifferential
open NetworkLayerSplit TowerNetwork GaussianNormMoments BatchTwoActivation

variable {d N : ℕ} {σ : ℝ}

theorem hidden_moment_bound (hd : 0<d) (hN : 0<N) (hσ : 0<σ)
    (x y : RealInput d) (p : ℕ) (hp : 0<p) (r : ℕ) :
    (∫⁻w : Weights d N r,ENNReal.ofReal (hiddenDistanceSq w x y)^p ∂smallPrior d N r σ)≤
      ENNReal.ofReal (inputDistanceSq x y*(N:ℝ)/d*(σ^2*((N:ℝ)+2*p))^(r+1))^p := by
  induction r with
  | zero => simpa only [zero_add,pow_one] using hidden_input_moment hd hN hσ x y p hp
  | succ r ih =>
    have hm : Measurable (fun w : Weights d N (r+1)=>ENNReal.ofReal (hiddenDistanceSq w x y)^p) :=
      ((measurable_hiddenDistanceSq x y).ennreal_ofReal).pow_const p
    have hs:=MeasurePreserving.symm (split d N r) (activationSmallPrior_split d N r σ)
    rw [←hs.map_eq,lintegral_map hm hs.measurable]
    have hf : Measurable (fun z : Weights d N r×(Fin N×Fin N→ℝ)=>
        ENNReal.ofReal (hiddenDistanceSq ((split d N r).symm z) x y)^p) := hm.comp hs.measurable
    rw [lintegral_prod _ hf.aemeasurable]
    simp only [split_symm_apply]
    calc
      _≤∫⁻w,ENNReal.ofReal (σ^2*((N:ℝ)+2*p))^p*ENNReal.ofReal (hiddenDistanceSq w x y)^p
          ∂smallPrior d N r σ := lintegral_mono (fun w=>hidden_append_moment w x y σ p hp)
      _=ENNReal.ofReal (σ^2*((N:ℝ)+2*p))^p*
          (∫⁻w,ENNReal.ofReal (hiddenDistanceSq w x y)^p ∂smallPrior d N r σ) := by
        rw [lintegral_const_mul _ (((measurable_hiddenDistanceSq x y).ennreal_ofReal).pow_const p)]
      _≤ENNReal.ofReal (σ^2*((N:ℝ)+2*p))^p*
          ENNReal.ofReal (inputDistanceSq x y*(N:ℝ)/d*(σ^2*((N:ℝ)+2*p))^(r+1))^p :=
        mul_le_mul_left' ih _
      _=_ := by
        rw [←mul_pow,←ENNReal.ofReal_mul (by positivity)]
        congr 2
        rw [pow_succ]
        ring

end NeuralGeneralization.BatchTwoContinuous.PairMoments
