import NeuralGeneralization.BatchTwoContinuousMinimizers
import NeuralGeneralization.BatchTwoParameterPriorRate
import Mathlib.MeasureTheory.Measure.OpenPos
import Mathlib.MeasureTheory.Measure.ProbabilityMeasure

/-! Actual Gaussian posterior positivity and concentration at the infimum of
energy over the open, tolerance-conditioned training event. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter
open scoped Topology
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel BatchTwoParameterPriorRate

theorem smallPrior_open_positive {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    {σ : ℝ} (hσ : 0<σ) : (smallPrior d N r σ).IsOpenPosMeasure := by
  have hi (i : WeightIndex d N r) :
      (gaussianReal 0 (smallVariance d N r σ i).toNNReal).IsOpenPosMeasure :=
    (gaussianReal_absolutelyContinuous' 0
      (ne_of_gt (Real.toNNReal_pos.mpr (smallVariance_pos hd hN hσ i)))).isOpenPosMeasure
  letI := hi
  unfold smallPrior productGaussian
  infer_instance

theorem posterior_probability {d N r n : ℕ} (hd : 0<d) (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : RealInput d→ℝ) (s : Fin n→RealInput d)
    {σ ρ : ℝ} (hσ : 0<σ) (hne : (trainingEvent (N:=N) (r:=r) φ f ρ s).Nonempty) :
    IsProbabilityMeasure (posterior φ (smallPrior d N r σ) f ρ s) := by
  letI := smallPrior_open_positive (r:=r) hd hN hσ
  exact cond_isProbabilityMeasure ((isOpen_trainingEvent hφ f ρ s).measure_ne_zero _ hne)

/-- The actual conditioned probability measure, with positivity proved from
an open nonempty training event and positive scale. -/
def posteriorProbability {d N r n : ℕ} (hd : 0<d) (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : RealInput d→ℝ) (s : Fin n→RealInput d)
    {σ ρ : ℝ} (hσ : 0<σ) (hne : (trainingEvent (N:=N) (r:=r) φ f ρ s).Nonempty) :
    ProbabilityMeasure (Weights d N r) :=
  ⟨posterior φ (smallPrior d N r σ) f ρ s, posterior_probability hd hN hφ f s hσ hne⟩

/-- Exact energy-tail concentration, not merely a fixed positive tail bound.
The cutoff may be arbitrarily close to the open-event energy infimum. -/
theorem posterior_energy_tail_tendsto_zero {d N r n : ℕ} (hd : 0<d) (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : RealInput d→ℝ) (s : Fin n→RealInput d)
    {ρ K : ℝ} (hne : (trainingEvent (N:=N) (r:=r) φ f ρ s).Nonempty)
    (hK : 2*eventEnergy (trainingEvent (N:=N) (r:=r) φ f ρ s)<K) :
    Tendsto (fun σ => (posterior φ (smallPrior d N r σ) f ρ s).real
      {w | K<weightedSquaredNorm w}) (𝓝[>] (0:ℝ)) (𝓝 0) := by
  let V := trainingEvent (N:=N) (r:=r) φ f ρ s
  let U : Set (Weights d N r) := {w | K<weightedSquaredNorm w}
  have hV : IsOpen V := isOpen_trainingEvent hφ f ρ s
  have hU : IsOpen U := isOpen_lt continuous_const continuous_weightedEnergy
  have hrV := gaussian_open_rate hd hN V hV hne
  have hr : Tendsto (fun σ => (smallPrior d N r σ).real U/(smallPrior d N r σ).real V)
      (𝓝[>] (0:ℝ)) (𝓝 0) := by
    by_cases hUne : U.Nonempty
    · have hrU := gaussian_open_rate hd hN U hU hUne
      have he := eventEnergy_ge hUne (K:=K) (fun w hw => hw.le)
      exact hrU.ratio_tendsto_zero hrV (by dsimp [V] at *; linarith)
        tendsto_inverse_square_nhdsGT_zero_atTop
    · have hz : U=∅ := Set.not_nonempty_iff_eq_empty.mp hUne
      simp only [hz, measureReal_empty, zero_div]
      exact tendsto_const_nhds
  apply squeeze_zero (fun _ => measureReal_nonneg) _ hr
  intro σ
  exact RobustPosterior.cond_real_le_ratio _ V U hV.measurableSet

end NeuralGeneralization.BatchTwoContinuous
