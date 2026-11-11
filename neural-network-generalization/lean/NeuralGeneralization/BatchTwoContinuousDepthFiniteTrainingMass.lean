import NeuralGeneralization.BatchTwoContinuousDepthFinitePerturbation
import NeuralGeneralization.BatchTwoContinuousDepthFiniteBulkMass
import NeuralGeneralization.BatchTwoNonGaussianTranslatedMass
import NeuralGeneralization.BatchTwoNonGaussianGaussianPrior

/-! The exact half-Gaussian shifted-body lower bound on training mass. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous
set_option maxHeartbeats 1400000
set_option backward.isDefEq.respectTransparency false

theorem whiten_energy_sum {d N r : ℕ} (hd : 0 < d) (hN : 0 < N) (w : Weights d N r) :
    ∑ q,(whiten w q)^2=weightedSquaredNorm w := by
  rw [← weightedSquaredNorm_unwhiten hd hN,unwhiten_whiten hd hN]

theorem translatedNoise_eq_unwhiten {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (w z : Weights d N r) :
    BatchTwoNonGaussian.translatedNoise w σ z=unwhiten (whiten w+(fun q => σ*z q)) := by
  funext q
  simp only [BatchTwoNonGaussian.translatedNoise,unwhiten,whiten,Pi.add_apply]
  rw [BatchTwoNonGaussian.smallScale_eq_mul_coordinateScale hd hN hσ]
  field_simp [(coordinateScale_pos hd hN q).ne']
  <;> ring

theorem finite_training_mass_lower {d N r n : ℕ} (hd : 0 < d) (hN : 0 < N)
    {K h ρ σ : ℝ} (hK : 0 ≤ K) (hh : 0 < h) (hρ : h < ρ) (hσ : 0 < σ)
    (hscale : σ*Real.sqrt N*noiseRadius d (r+2) ≤ approximationRadius (r+2) K h)
    (f : RealInput d → ℝ) (s : Fin n → RealInput d) (hs : ∀ i,∑ j,(s i j)^2 ≤ 1)
    (w : Weights d N r) (hfit : w ∈ exactInterpolants Real.tanh f s)
    (henergy : weightedSquaredNorm w ≤ K) :
    (1/2)*Real.exp (-K/(2*σ^2)) ≤
      (smallPrior d N r σ).real (trainingEvent Real.tanh f ρ s) := by
  let E : Set (Weights d N r) := (WithLp.toLp 2) ⁻¹' typicalBody d N r
  have hE : MeasurableSet E :=
    (typicalBody_closed d N r).measurableSet.preimage (PiLp.continuous_toLp 2 _).measurable
  have hsym (z : Weights d N r) : -z ∈ E ↔ z ∈ E := by
    change WithLp.toLp 2 (-z) ∈ typicalBody d N r ↔ _
    rw [WithLp.toLp_neg]
    exact typicalBody_neg d N r (WithLp.toLp 2 z)
  have hcontain : ∀ z ∈ E,BatchTwoNonGaussian.translatedNoise w σ z ∈ trainingEvent Real.tanh f ρ s := by
    intro z hz i
    have hblocks := typicalBody_smallEnergyBlocks (WithLp.toLp 2 z) hz hσ.le hscale
    have hwE : (∑ q,whiten w q^2) ≤ K+1 := by
      rw [whiten_energy_sum hd hN]
      linarith
    have happ := normalized_perturbation_at_radius hd hN (whiten w) (fun q => σ*z q)
      hK hh hblocks hwE (s i) (hs i)
    rw [← translatedNoise_eq_unwhiten hd hN hσ,unwhiten_whiten hd hN,hfit i] at happ
    exact happ.trans_lt hρ
  have hmass := BatchTwoNonGaussian.smallPrior_translated_event_mass
    BatchTwoNonGaussian.standardGaussian hd hN hσ E (trainingEvent Real.tanh f ρ s)
    hE hsym (isOpen_trainingEvent tanh_continuous f ρ s).measurableSet w hcontain
  rw [BatchTwoNonGaussian.standardGaussian_smallPrior hd hN] at hmass
  have hbody : (1/2 : ℝ) ≤ (BatchTwoNonGaussian.rawPrior BatchTwoNonGaussian.standardGaussian d N r).real E :=
    typicalBody_gaussian_mass (by omega)
  have he : Real.exp (-K/(2*σ^2)) ≤
      Real.exp (-(BatchTwoNonGaussian.standardGaussian.upperCurvature/2*weightedSquaredNorm w/σ^2)) := by
    apply Real.exp_le_exp.mpr
    change -K/(2*σ^2) ≤ -((1 : ℝ)/2*weightedSquaredNorm w/σ^2)
    rw [show -((1 : ℝ)/2*weightedSquaredNorm w/σ^2)= -weightedSquaredNorm w/(2*σ^2) by ring]
    exact div_le_div_of_nonneg_right (neg_le_neg henergy) (by positivity)
  exact (mul_le_mul hbody he (Real.exp_nonneg _) measureReal_nonneg).trans hmass

end NeuralGeneralization.BatchTwoContinuousDepthPaper
