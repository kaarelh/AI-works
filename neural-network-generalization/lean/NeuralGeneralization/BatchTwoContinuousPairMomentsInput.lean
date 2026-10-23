import NeuralGeneralization.BatchTwoContinuousPairMomentsLayer

/-! First-layer paired moment with the constant input coordinate cancelling. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuous.PairMoments
open ConcreteModel GaussianAngularFields CompressionSampling FiniteDifferential
open NetworkLayerSplit TowerNetwork GaussianNormMoments BatchTwoActivation RobustCompressionBlockMoments

variable {d N : ℕ} {σ : ℝ}

def inputPairCoefficient (d N : ℕ) (σ : ℝ) (x y : RealInput d) : Fin (d+1)→ℝ :=
  fun j=>σ*Real.sqrt ((N:ℝ)/d)*(augmentedInput x j-augmentedInput y j)

theorem inputPairCoefficient_energy (x y : RealInput d) :
    (∑j,(inputPairCoefficient d N σ x y j)^2)=σ^2*((N:ℝ)/d)*inputDistanceSq x y := by
  simp only [inputPairCoefficient,mul_pow,←Finset.mul_sum,
    Real.sq_sqrt (by positivity : 0≤(N:ℝ)/d),augmentedInput_distance_sq]

theorem inputPairCoefficient_field (hd : 0<d) (hN : 0<N) (hσ : 0<σ)
    (w : Weights d N 0) (x y : RealInput d) (i : Fin N) :
    matrixDifference (inputPairCoefficient d N σ x y) (activationInputRows σ w) i=
      (∑j,w (.inl (i,j))*augmentedInput x j)-(∑j,w (.inl (i,j))*augmentedInput y j) := by
  have hroot : Real.sqrt ((N:ℝ)/d)≠0 := ne_of_gt (Real.sqrt_pos.mpr (by positivity))
  simp only [matrixDifference,inputPairCoefficient,activationInputRows,standardizedWeights,
    whiten,coordinateScale,smallVariance,one_pow,mul_one,←Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro j _
  field_simp
  <;> ring

theorem hiddenDistanceSq_input_le (hd : 0<d) (hN : 0<N) (hσ : 0<σ)
    (w : Weights d N 0) (x y : RealInput d) :
    hiddenDistanceSq w x y≤
      ∑i,(matrixDifference (inputPairCoefficient d N σ x y) (activationInputRows σ w) i)^2 := by
  unfold hiddenDistanceSq
  apply Finset.sum_le_sum
  intro i _
  rw [inputPairCoefficient_field hd hN hσ]
  exact tanh_pair_sq_le _ _

theorem hidden_input_moment (hd : 0<d) (hN : 0<N) (hσ : 0<σ)
    (x y : RealInput d) (p : ℕ) (hp : 0<p) :
    (∫⁻w : Weights d N 0,ENNReal.ofReal (hiddenDistanceSq w x y)^p ∂smallPrior d N 0 σ)≤
      ENNReal.ofReal (inputDistanceSq x y*(N:ℝ)/d*(σ^2*((N:ℝ)+2*p)))^p := by
  have h:=matrixDifference_moment (N:=N) (inputPairCoefficient d N σ x y) 1 p hp
  have hlaw:=activationInputRows_law (r:=0) hd hN hσ
  change (smallPrior d N 0 σ).map (activationInputRows σ)=
    iidSamples (Measure.pi fun _ : Fin (d+1)=>gaussianReal 0 1) N at hlaw
  rw [←hlaw,
    lintegral_map (by fun_prop) (measurable_activationInputRows σ)] at h
  have hc : (∫⁻w : Weights d N 0,ENNReal.ofReal (hiddenDistanceSq w x y)^p ∂smallPrior d N 0 σ)≤
      ∫⁻w : Weights d N 0,ENNReal.ofReal
        (∑i,(matrixDifference (inputPairCoefficient d N σ x y) (activationInputRows σ w) i)^2)^p
        ∂smallPrior d N 0 σ := lintegral_mono (fun w=>pow_le_pow_left'
          (ENNReal.ofReal_le_ofReal (hiddenDistanceSq_input_le hd hN hσ w x y)) p)
  apply (hc.trans h).trans_eq
  rw [inputPairCoefficient_energy,←mul_pow,←ENNReal.ofReal_mul (by positivity)]
  congr 2
  simp only [NNReal.coe_one,one_mul]
  ring

end NeuralGeneralization.BatchTwoContinuous.PairMoments
