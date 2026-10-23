import NeuralGeneralization.BatchTwoContinuousPairMomentsSplit
import NeuralGeneralization.BatchTwoGaussianNormMoments

/-! Sharp high moments of an actual independent Gaussian layer. -/
noncomputable section
set_option maxHeartbeats 250000
set_option maxRecDepth 10000
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuous.PairMoments
open ConcreteModel GaussianAngularFields CompressionSampling FiniteDifferential
open NetworkLayerSplit TowerNetwork GaussianNormMoments

variable {d N r n : ℕ}

theorem matrixDifference_moment (c : Fin n→ℝ) (v : ℝ≥0) (p : ℕ) (hp : 0<p) :
    (∫⁻a,ENNReal.ofReal (∑i,(matrixDifference c a i)^2)^p
      ∂iidSamples (Measure.pi fun _ : Fin n=>gaussianReal 0 v) N)≤
      ENNReal.ofReal ((v:ℝ)*((N:ℝ)+2*p))^p*ENNReal.ofReal (∑j,c j^2)^p := by
  have hm : Measurable (fun z : Fin N→ℝ=>ENNReal.ofReal (∑i,z i^2)^p) := by fun_prop
  have h:=gaussian_norm_power_lintegral (ι:=Fin N) (((v:ℝ)*∑j,c j^2).toNNReal) p hp
  simp only [Fintype.card_fin,Real.coe_toNNReal _ (by positivity : 0≤(v:ℝ)*∑j,c j^2)] at h
  rw [←matrixDifference_law (N:=N) c v] at h
  have hpow (z : Fin N→ℝ) : ENNReal.ofReal ((∑i,z i^2)^p)=ENNReal.ofReal (∑i,z i^2)^p :=
    ENNReal.ofReal_pow (by positivity) p
  simp only [hpow,ENNReal.ofReal_pow (show 0≤(v:ℝ)*(∑j,c j^2)*((N:ℝ)+2*p) by positivity)] at h
  rw [lintegral_map hm (measurable_matrixDifference c)] at h
  apply h.trans_eq
  rw [show (v:ℝ)*(∑j,c j^2)*((N:ℝ)+2*p)=((v:ℝ)*((N:ℝ)+2*p))*(∑j,c j^2) by ring,
    ENNReal.ofReal_mul (by positivity),mul_pow]

theorem matrixDifference_flat_moment (c : Fin n→ℝ) (v : ℝ≥0) (p : ℕ) (hp : 0<p) :
    (∫⁻a : Fin N×Fin n→ℝ,ENNReal.ofReal (∑i,(matrixDifference c (fun i j=>a (i,j)) i)^2)^p
      ∂Measure.pi (fun _=>gaussianReal 0 v))≤
      ENNReal.ofReal ((v:ℝ)*((N:ℝ)+2*p))^p*ENNReal.ofReal (∑j,c j^2)^p := by
  have h:=matrixDifference_moment (N:=N) c v p hp
  rw [←gaussianCurry_law N n v,lintegral_map (by fun_prop) (by fun_prop)] at h
  exact h

theorem hidden_append_moment (w : Weights d N r) (x y : RealInput d) (σ : ℝ)
    (p : ℕ) (hp : 0<p) :
    (∫⁻a : Fin N×Fin N→ℝ,ENNReal.ofReal (hiddenDistanceSq (appendLayer w (fun i j=>a (i,j))) x y)^p
      ∂BatchTwoActivation.activationMatrixPrior N σ)≤
      ENNReal.ofReal (σ^2*((N:ℝ)+2*p))^p*ENNReal.ofReal (hiddenDistanceSq w x y)^p := by
  have hpoint (a : Fin N×Fin N→ℝ) :
      ENNReal.ofReal (hiddenDistanceSq (appendLayer w (fun i j=>a (i,j))) x y)^p≤
      ENNReal.ofReal (∑i,(matrixDifference
        (fun j=>BatchTwoContinuous.finalHidden Real.tanh w x j-BatchTwoContinuous.finalHidden Real.tanh w y j)
        (fun i j=>a (i,j)) i)^2)^p :=
    pow_le_pow_left' (ENNReal.ofReal_le_ofReal (hiddenDistanceSq_append_le w (fun i j=>a (i,j)) x y)) p
  have hmono:=lintegral_mono (μ:=BatchTwoActivation.activationMatrixPrior N σ) hpoint
  have h:=matrixDifference_flat_moment (N:=N)
    (fun j=>BatchTwoContinuous.finalHidden Real.tanh w x j-BatchTwoContinuous.finalHidden Real.tanh w y j)
    (σ^2).toNNReal p hp
  apply hmono.trans
  simpa only [Real.coe_toNNReal _ (sq_nonneg σ),hiddenDistanceSq,BatchTwoActivation.activationMatrixPrior] using h

end NeuralGeneralization.BatchTwoContinuous.PairMoments
