import NeuralGeneralization.BatchTwoContinuousDepthPowerConcentration
import NeuralGeneralization.BatchTwoActivationConvexProjection
import NeuralGeneralization.BatchTwoNonGaussianSpectralLaw

/-! Finite-coordinate convex distance concentration and the additive-energy
posterior comparison at the manuscript's small-noise scale. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open BatchTwoActivation BatchTwoContinuousDepthPower
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false

theorem finite_gaussian_zeroSet_tail {ι : Type*} [Fintype ι]
    (F : (ι → ℝ) → ℝ) (hF : Measurable F)
    (hLip : ∀ x y, (F x-F y)^2 ≤ ∑ i,(x i-y i)^2)
    (A : Set (ι → ℝ)) (hA : MeasurableSet A)
    (hmass : (1/2 : ℝ) ≤ (Measure.pi fun _ : ι => gaussianReal 0 1).real A)
    (hzero : ∀ x ∈ A,F x=0) (s : ℝ) {θ : ℝ} (hθ : 0 < θ) :
    (Measure.pi fun _ : ι => gaussianReal 0 1).real {x | s ≤ F x^2} ≤
      Real.exp (Real.log 2/θ-s/(2*(1+θ))) := by
  classical
  let e := Fintype.equivFin ι
  let reindex : (Fin (Fintype.card ι) → ℝ) → (ι → ℝ) := fun x i => x (e i)
  have hm : (standardGaussian (Fintype.card ι)).map reindex =
      Measure.pi (fun _ : ι => gaussianReal 0 1) :=
    BatchTwoNonGaussian.productLaw_map_subfamily (gaussianReal 0 1) e e.injective
  have hmeas : Measurable reindex := by fun_prop
  have hpre (B : Set (ι → ℝ)) (hB : MeasurableSet B) :
      (standardGaussian (Fintype.card ι)).real (reindex ⁻¹' B)=
        (Measure.pi fun _ : ι => gaussianReal 0 1).real B := by
    rw [← hm]
    simp only [Measure.real,Measure.map_apply hmeas hB]
  have hLip' : SquareLipschitz (F ∘ reindex) := by
    intro x y
    have hh := hLip (reindex x) (reindex y)
    have hs : (∑ i,(reindex x i-reindex y i)^2)=∑ j,(x j-y j)^2 :=
      Equiv.sum_comp e (fun j => (x j-y j)^2)
    rw [hs] at hh
    exact hh
  have ht := gaussian_zeroSet_square_tail_weighted (F ∘ reindex) (hF.comp hmeas) hLip'
    (reindex ⁻¹' A) (hA.preimage hmeas) (by rw [hpre A hA];exact hmass)
    (fun x hx => hzero (reindex x) hx) s hθ
  change (standardGaussian (Fintype.card ι)).real
    (reindex ⁻¹' {x | s ≤ F x^2}) ≤ _ at ht
  rwa [hpre _ (measurableSet_le measurable_const (hF.pow_const 2))] at ht

def finiteGaussianDistance {ι : Type*} [Fintype ι]
    (A : Set (EuclideanSpace ℝ ι)) (x : ι → ℝ) : ℝ :=
  Metric.infDist (WithLp.toLp 2 x) A

theorem finiteGaussianDistance_measurable {ι : Type*} [Fintype ι]
    (A : Set (EuclideanSpace ℝ ι)) : Measurable (finiteGaussianDistance A) :=
  ((Metric.lipschitz_infDist_pt A).continuous.comp (PiLp.continuous_toLp 2 _)).measurable

theorem finiteGaussianDistance_squared_lipschitz {ι : Type*} [Fintype ι]
    (A : Set (EuclideanSpace ℝ ι)) (x y : ι → ℝ) :
    (finiteGaussianDistance A x-finiteGaussianDistance A y)^2 ≤ ∑ i,(x i-y i)^2 := by
  have hh := (Metric.lipschitz_infDist_pt A).dist_le_mul (WithLp.toLp 2 x) (WithLp.toLp 2 y)
  simp only [NNReal.coe_one,one_mul,Real.dist_eq,dist_eq_norm] at hh
  have hs := pow_le_pow_left₀ (abs_nonneg _) hh 2
  simpa only [Real.norm_eq_abs,sq_abs,← WithLp.toLp_sub,EuclideanSpace.real_norm_sq_eq,
    PiLp.toLp_apply,Pi.sub_apply,finiteGaussianDistance] using hs

theorem finite_gaussian_distance_tail {ι : Type*} [Fintype ι]
    (A : Set (EuclideanSpace ℝ ι)) (hA : IsClosed A)
    (hmass : (1/2 : ℝ) ≤ (Measure.pi fun _ : ι => gaussianReal 0 1).real
      ((WithLp.toLp 2) ⁻¹' A)) (s : ℝ) {θ : ℝ} (hθ : 0 < θ) :
    (Measure.pi fun _ : ι => gaussianReal 0 1).real
      {x | s ≤ finiteGaussianDistance A x^2} ≤
        Real.exp (Real.log 2/θ-s/(2*(1+θ))) :=
  finite_gaussian_zeroSet_tail (finiteGaussianDistance A) (finiteGaussianDistance_measurable A)
    (finiteGaussianDistance_squared_lipschitz A) ((WithLp.toLp 2) ⁻¹' A)
    (hA.measurableSet.preimage (PiLp.continuous_toLp 2 _).measurable) hmass
    (fun x hx => Metric.infDist_zero_of_mem hx) s hθ

/-- The existing transport concentration estimate suffices at the literal
width threshold; no sharp Gaussian isoperimetric inequality is assumed. -/
theorem finite_energy_tail_ratio {N : ℕ} {K σ : ℝ} (hN : 1 ≤ N)
    (hK : 0 ≤ K) (hσ : 0 < σ) (hsmall : (N : ℝ)*σ^2*(K+1) ≤ 1/16) :
    Real.exp (Real.log 2/(1/(2*(K+1)))-((K+1)/σ^2)/(2*(1+1/(2*(K+1))))) /
      ((1/2)*Real.exp (-K/(2*σ^2))) ≤ 2*Real.exp (-(N : ℝ)/2) := by
  have hKp : 0 < K+1 := by linarith
  have hNR : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hθ : 0 < 1+1/(2*(K+1)) := by positivity
  have hgap : K+1/2 ≤ (K+1)/(1+1/(2*(K+1))) := by
    apply (le_div_iff₀ hθ).mpr
    apply (mul_le_mul_iff_right₀ (by positivity : 0 < 2*(K+1))).mp
    have he : (K+1/2)*(1+1/(2*(K+1)))*(2*(K+1))=(K+1/2)*(2*K+3) := by field_simp <;> ring
    nlinarith only [he,hK]
  have hdivide := div_le_div_of_nonneg_right hgap (show 0 ≤ 2*σ^2 by positivity)
  have hex : Real.log 2/(1/(2*(K+1)))-((K+1)/σ^2)/(2*(1+1/(2*(K+1)))) - (-K/(2*σ^2)) ≤
      2*(K+1)*Real.log 2-1/(4*σ^2) := by
    have h1 : ((K+1)/σ^2)/(2*(1+1/(2*(K+1))))=((K+1)/(1+1/(2*(K+1))))/(2*σ^2) := by field_simp <;> ring
    have h2 : (K+1/2)/(2*σ^2)-K/(2*σ^2)=1/(4*σ^2) := by ring
    have h0 : Real.log 2/(1/(2*(K+1)))=2*(K+1)*Real.log 2 := by field_simp <;> ring
    rw [h1,h0]
    simp only [neg_div]
    linarith only [hdivide,h2]
  have hlarge : 4*(N : ℝ)*(K+1) ≤ 1/(4*σ^2) := by
    apply (le_div_iff₀ (by positivity : 0 < 4*σ^2)).mpr
    nlinarith only [hsmall]
  have hlog : Real.log 2 ≤ 1 := by linarith only [Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ)<2)]
  have hlast : 2*(K+1)*Real.log 2-1/(4*σ^2) ≤ -(N : ℝ)/2 := by
    have hh := mul_le_mul_of_nonneg_left hlog (show 0 ≤ 2*(K+1) by positivity)
    have hNK := mul_nonneg (show 0 ≤ (N : ℝ)-1 by linarith) hKp.le
    have hNK' := mul_nonneg (Nat.cast_nonneg N : (0 : ℝ) ≤ N) hK
    nlinarith
  have he (a b : ℝ) : Real.exp a/((1/2)*Real.exp b)=2*Real.exp (a-b) := by
    rw [Real.exp_sub]
    field_simp
    <;> ring
  rw [he]
  exact mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr (hex.trans hlast)) (by norm_num)

theorem width_probability_tail {N : ℕ} {β : ℝ} (hβ : 0 < β)
    (hN : 2*Real.log (2/β) ≤ (N : ℝ)) :
    2*Real.exp (-(N : ℝ)/2) ≤ β := by
  calc
    _ ≤ 2*Real.exp (-Real.log (2/β)) := by
      apply mul_le_mul_of_nonneg_left _ (by norm_num)
      apply Real.exp_le_exp.mpr
      linarith
    _ = β := by
      rw [Real.exp_neg,Real.exp_log (by positivity)]
      field_simp

end NeuralGeneralization.BatchTwoContinuousDepthPaper
