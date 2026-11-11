import NeuralGeneralization.BatchTwoContinuousDepthFiniteTrainingMass
import NeuralGeneralization.BatchTwoContinuousDepthFiniteConcentration

/-! An actual continuous low-energy representative, obtained by convex projection. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous BatchTwoActivation
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

def sourceToWeights {d N r : ℕ} (σ : ℝ) (z : Weights d N r) : Weights d N r :=
  unwhiten (fun q => σ*z q)

def standardizedSource {d N r : ℕ} (σ : ℝ) (w : Weights d N r) : Weights d N r :=
  fun q => whiten w q/σ

theorem continuous_sourceToWeights (d N r : ℕ) (σ : ℝ) :
    Continuous (sourceToWeights (d:=d) (N:=N) (r:=r) σ) :=
  (continuous_unwhiten d N r).comp (by fun_prop)

theorem continuous_standardizedSource (d N r : ℕ) (σ : ℝ) :
    Continuous (standardizedSource (d:=d) (N:=N) (r:=r) σ) := by
  apply continuous_pi
  intro q
  exact ((continuous_apply q).comp (continuous_whiten d N r)).div_const σ

theorem standardizedSource_sourceToWeights {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (z : Weights d N r) :
    standardizedSource σ (sourceToWeights σ z)=z := by
  unfold standardizedSource sourceToWeights
  rw [whiten_unwhiten hd hN]
  funext q
  exact mul_div_cancel_left₀ _ hσ.ne'

theorem sourceToWeights_standardizedSource {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (w : Weights d N r) :
    sourceToWeights σ (standardizedSource σ w)=w := by
  unfold sourceToWeights standardizedSource
  simp only [mul_div_cancel₀ _ hσ.ne']
  exact unwhiten_whiten hd hN w

theorem sourceToWeights_gaussian_law {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) :
    (Measure.pi fun _ : WeightIndex d N r => gaussianReal 0 1).map (sourceToWeights σ)=
      smallPrior d N r σ := by
  have hh := BatchTwoNonGaussian.map_gaussian_smallScale (r:=r) hd hN σ 1 (by norm_num)
  simp only [one_div,inv_one,Real.toNNReal_one,Real.sqrt_one,div_one] at hh
  have he : sourceToWeights (d:=d) (N:=N) (r:=r) σ=
      (fun z q => BatchTwoNonGaussian.smallScale d N r σ q*z q) := by
    funext z q
    rw [BatchTwoNonGaussian.smallScale_eq_mul_coordinateScale hd hN hσ]
    dsimp [sourceToWeights,unwhiten]
    ring
  rwa [he]

def bodyProjection (d N r : ℕ) : EnergySpace d N r → EnergySpace d N r :=
  convexProjection (typicalBody d N r) (typicalBody_nonempty d N r)
    (typicalBody_closed d N r) (typicalBody_convex d N r)

theorem bodyProjection_mem (d N r : ℕ) (u : EnergySpace d N r) :
    bodyProjection d N r u ∈ typicalBody d N r := convexProjection_mem _ _ _ _ _

theorem continuous_bodyProjection (d N r : ℕ) : Continuous (bodyProjection d N r) :=
  (convexProjection_lipschitz _ _ _ _).continuous

theorem bodyProjection_distance (d N r : ℕ) (u : EnergySpace d N r) :
    ‖u-bodyProjection d N r u‖=Metric.infDist u (typicalBody d N r) :=
  convexProjection_distance _ _ _ _ _

def residualCoordinates {d N r : ℕ} (σ : ℝ) (w : Weights d N r) : Weights d N r :=
  fun q => σ*(standardizedSource σ w q-bodyProjection d N r (WithLp.toLp 2 (standardizedSource σ w)) q)

def residualRepresentative {d N r : ℕ} (σ : ℝ) (w : Weights d N r) : Weights d N r :=
  unwhiten (residualCoordinates σ w)

theorem continuous_residualRepresentative (d N r : ℕ) (σ : ℝ) :
    Continuous (residualRepresentative (d:=d) (N:=N) (r:=r) σ) := by
  apply (continuous_unwhiten d N r).comp
  apply continuous_pi
  intro q
  have hp := (continuous_bodyProjection d N r).comp
    ((PiLp.continuous_toLp 2 _).comp (continuous_standardizedSource d N r σ))
  exact continuous_const.mul (((continuous_apply q).comp (continuous_standardizedSource d N r σ)).sub
    ((PiLp.continuous_apply 2 _ q).comp hp))

theorem residualRepresentative_energy {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (σ : ℝ) (w : Weights d N r) :
    weightedSquaredNorm (residualRepresentative σ w)=σ^2*
      (finiteGaussianDistance (typicalBody d N r) (standardizedSource σ w))^2 := by
  rw [residualRepresentative,weightedSquaredNorm_unwhiten hd hN]
  simp only [residualCoordinates,mul_pow,← Finset.mul_sum]
  congr 1
  have he := EuclideanSpace.real_norm_sq_eq
    (WithLp.toLp 2 (standardizedSource σ w)-bodyProjection d N r (WithLp.toLp 2 (standardizedSource σ w)))
  rw [bodyProjection_distance] at he
  simpa only [finiteGaussianDistance,PiLp.sub_apply,PiLp.toLp_apply] using he.symm

theorem residualRepresentative_approximation {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {K h σ : ℝ} (hK : 0 ≤ K) (hh : 0 < h) (hσ : 0 < σ)
    (hscale : σ*Real.sqrt N*noiseRadius d (r+2) ≤ approximationRadius (r+2) K h)
    (w : Weights d N r) (hE : weightedSquaredNorm (residualRepresentative σ w) ≤ K+1)
    (x : RealInput d) (hx : ∑ i,x i^2 ≤ 1) :
    |output Real.tanh w x-output Real.tanh (residualRepresentative σ w) x| ≤ h := by
  let p := bodyProjection d N r (WithLp.toLp 2 (standardizedSource σ w))
  let v : Weights d N r := fun q => σ*p q
  have hp := typicalBody_smallEnergyBlocks p (bodyProjection_mem _ _ _ _) hσ.le hscale
  have hu : (∑ q,residualCoordinates σ w q^2) ≤ K+1 := by
    rwa [residualRepresentative,weightedSquaredNorm_unwhiten hd hN] at hE
  have hsum : unwhiten (residualCoordinates σ w+v)=w := by
    have he : residualCoordinates σ w+v=fun q => σ*standardizedSource σ w q := by
      funext q
      dsimp [residualCoordinates,v,p]
      ring
    rw [he]
    exact sourceToWeights_standardizedSource hd hN hσ w
  have ha := normalized_perturbation_at_radius hd hN (residualCoordinates σ w) v hK hh hp hu x hx
  rw [hsum] at ha
  exact ha

theorem prior_residual_energy_tail {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ θ : ℝ} (hσ : 0 < σ) (hθ : 0 < θ) (K : ℝ) :
    (smallPrior d N r σ).real {w | K+1 < weightedSquaredNorm (residualRepresentative σ w)} ≤
      Real.exp (Real.log 2/θ-((K+1)/σ^2)/(2*(1+θ))) := by
  let μ : Measure (Weights d N r) := Measure.pi fun _ => gaussianReal 0 1
  let A : Set (Weights d N r) := {w | K+1 < weightedSquaredNorm (residualRepresentative σ w)}
  have hA : MeasurableSet A := (isOpen_lt continuous_const
    (continuous_weightedEnergy.comp (continuous_residualRepresentative d N r σ))).measurableSet
  have hm : (smallPrior d N r σ).real A=μ.real ((sourceToWeights σ) ⁻¹' A) := by
    rw [← sourceToWeights_gaussian_law hd hN hσ]
    simp only [Measure.real,Measure.map_apply (continuous_sourceToWeights d N r σ).measurable hA]
    rfl
  change (smallPrior d N r σ).real A ≤ _
  rw [hm]
  have hsub : (sourceToWeights σ) ⁻¹' A ⊆
      {z | (K+1)/σ^2 ≤ (finiteGaussianDistance (typicalBody d N r) z)^2} := by
    intro z hz
    change K+1 < weightedSquaredNorm (residualRepresentative σ (sourceToWeights σ z)) at hz
    rw [residualRepresentative_energy hd hN,standardizedSource_sourceToWeights hd hN hσ] at hz
    exact (div_le_iff₀ (sq_pos_of_pos hσ)).mpr (by nlinarith only [hz])
  exact (measureReal_mono hsub).trans (finite_gaussian_distance_tail (typicalBody d N r)
    (typicalBody_closed d N r) (typicalBody_gaussian_mass (by omega)) ((K+1)/σ^2) hθ)

end NeuralGeneralization.BatchTwoContinuousDepthPaper
