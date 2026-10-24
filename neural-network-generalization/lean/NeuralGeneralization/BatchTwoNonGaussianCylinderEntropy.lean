import NeuralGeneralization.BatchTwoNonGaussianTranslatedMass

/-! Explicit exponential costs for the actual non-Gaussian target cylinder. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel

def scalarCylinderCost (ν : CoordinateLaw) (ρ : ℝ) : ℝ :=
  Real.log (1/(coordinateBallConstant ν*ρ))

def matrixCylinderCost (C : ℕ) (ρ : ℝ) : ℝ :=
  (C : ℝ)*Real.log (1024/ρ^2)+Real.log 2

def networkCylinderCost (ν : CoordinateLaw) (d C r : ℕ) (ρ : ℝ) : ℝ :=
  ((d : ℝ)+2)*scalarCylinderCost ν ρ+(r : ℝ)*matrixCylinderCost C ρ

theorem scalarCylinderCost_exp (ν : CoordinateLaw) {ρ : ℝ} (hρ : 0 < ρ) :
    Real.exp (-scalarCylinderCost ν ρ)=coordinateBallConstant ν*ρ := by
  unfold scalarCylinderCost
  rw [one_div,Real.log_inv,neg_neg,Real.exp_log (mul_pos (coordinateBallConstant_pos ν) hρ)]

theorem scalarCylinderCost_nonneg (ν : CoordinateLaw) {ρ : ℝ} (hρ : 0 < ρ) (hρ1 : ρ ≤ 1) :
    0 ≤ scalarCylinderCost ν ρ := by
  have hsmall := (coordinate_small_ball ν hρ.le hρ1).trans (measureReal_le_one (μ := ν.law))
  apply Real.log_nonneg
  exact (le_div_iff₀ (mul_pos (coordinateBallConstant_pos ν) hρ)).mpr (by simpa)

theorem matrixCylinderCost_nonneg (C : ℕ) {ρ : ℝ} (hρ : 0 < ρ) (hρ1 : ρ ≤ 1) :
    0 ≤ matrixCylinderCost C ρ := by
  have hq : (1 : ℝ) ≤ 1024/ρ^2 := (le_div_iff₀ (sq_pos_of_pos hρ)).mpr (by nlinarith)
  exact add_nonneg (mul_nonneg (Nat.cast_nonneg C) (Real.log_nonneg hq)) (Real.log_nonneg (by norm_num))

theorem networkCylinderCost_nonneg (ν : CoordinateLaw) (d C r : ℕ) {ρ : ℝ}
    (hρ : 0 < ρ) (hρ1 : ρ ≤ 1) : 0 ≤ networkCylinderCost ν d C r ρ := by
  exact add_nonneg (mul_nonneg (by positivity) (scalarCylinderCost_nonneg ν hρ hρ1))
    (mul_nonneg (Nat.cast_nonneg r) (matrixCylinderCost_nonneg C hρ hρ1))

theorem matrixCylinderCost_exp (C N : ℕ) {ρ : ℝ} (hρ : 0 < ρ) :
    Real.exp (-(N : ℝ)*matrixCylinderCost C ρ)=
      (ρ^2/1024)^(C*N)*(1/2 : ℝ)^N := by
  have hlog : Real.log (1024/ρ^2)= -Real.log (ρ^2/1024) := by
    rw [show 1024/ρ^2=(ρ^2/1024)⁻¹ by field_simp, Real.log_inv]
  unfold matrixCylinderCost
  rw [hlog]
  have he : -(N : ℝ)*((C : ℝ)* -Real.log (ρ^2/1024)+Real.log 2)=
      (C*N : ℕ)*Real.log (ρ^2/1024)+(N : ℝ)*Real.log (1/2) := by
    rw [show Real.log (1/2 : ℝ) = -Real.log 2 by rw [one_div,Real.log_inv]]
    push_cast
    ring
  rw [he,Real.exp_add,Real.exp_nat_mul,Real.exp_nat_mul,
    Real.exp_log (by positivity),Real.exp_log (by norm_num)]

theorem matrixNoiseCylinder_exp_lower (ν : CoordinateLaw) {C k p N : ℕ}
    (hN : 0 < N) (hk : 0 < k) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    {ρ b : ℝ} (hρ : 0 < ρ) (hρhalf : ρ ≤ 1/2) (hb : 0 ≤ b)
    (hsize : 4*(smallBallTilt ρ)^2 ≤ (k : ℝ))
    (herr : (replacementConstant ν standardGaussian*lindebergPolynomial (smallBallTilt ρ))^2 ≤ (k : ℝ))
    (htail : 2*(9 : ℝ)^(N+N)*Real.exp (-b^2*N/(8*subGaussianVariance ν)) ≤
      (1/2)*(ρ^2/1024)^(C*N)) :
    Real.exp (-(N : ℝ)*matrixCylinderCost C ρ) ≤
      (Measure.pi fun _ : Fin N × Fin N => ν.law).real (matrixNoiseCylinder e ρ b) := by
  have ht := matrixNoiseCylinder_lower ν hk e hρ hρhalf hb hsize herr
  rw [matrixCylinderCost_exp C N hρ]
  have hp : (1/2 : ℝ)^N ≤ 1/2 := by
    exact (pow_le_pow_of_le_one (by norm_num : (0 : ℝ) ≤ 1/2) (by norm_num : (1/2 : ℝ) ≤ 1)
      (by omega : 1 ≤ N)).trans_eq (pow_one _)
  have hm := mul_le_mul_of_nonneg_left hp (pow_nonneg (by positivity : 0 ≤ ρ^2/1024) (C*N))
  linarith

theorem noiseCylinder_exp_lower (ν : CoordinateLaw) {C k p N : ℕ} (d r : ℕ)
    (hN : 0 < N) (hk : 0 < k) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    {ρ b : ℝ} (hρ : 0 < ρ) (hρhalf : ρ ≤ 1/2) (hb : 0 ≤ b)
    (hsize : 4*(smallBallTilt ρ)^2 ≤ (k : ℝ))
    (herr : (replacementConstant ν standardGaussian*lindebergPolynomial (smallBallTilt ρ))^2 ≤ (k : ℝ))
    (htail : 2*(9 : ℝ)^(N+N)*Real.exp (-b^2*N/(8*subGaussianVariance ν)) ≤
      (1/2)*(ρ^2/1024)^(C*N)) :
    Real.exp (-(N : ℝ)*networkCylinderCost ν d C r ρ) ≤
      (rawPrior ν d N r).real (noiseCylinder d e ρ b r) := by
  have hs := coordinate_small_ball ν hρ.le (by linarith : ρ ≤ 1)
  have hm := matrixNoiseCylinder_exp_lower ν hN hk e hρ hρhalf hb hsize herr htail
  rw [←scalarCylinderCost_exp ν hρ] at hs
  rw [noiseCylinder_probability]
  have hp := mul_le_mul (pow_le_pow_left₀ (Real.exp_nonneg _) hs (N*(d+2)))
    (pow_le_pow_left₀ (Real.exp_nonneg _) hm r) (pow_nonneg (Real.exp_nonneg _) r)
    (pow_nonneg ENNReal.toReal_nonneg _)
  have he : Real.exp (-(N : ℝ)*networkCylinderCost ν d C r ρ)=
      (Real.exp (-scalarCylinderCost ν ρ))^(N*(d+2))*
        (Real.exp (-(N : ℝ)*matrixCylinderCost C ρ))^r := by
    rw [←Real.exp_nat_mul,←Real.exp_nat_mul,←Real.exp_add]
    congr 1
    unfold networkCylinderCost
    push_cast
    ring
  exact he.le.trans hp

/-- Quantitative target mass at every prior scale at most mean-field, once the
explicit clone-group and tail inequalities are met. The cost is independent of
learner width; its remaining parameters are displayed rather than hidden in an
assumed concentration principle. -/
theorem smallPrior_cloned_exp_mass (ν : CoordinateLaw) {d C k p N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (teacher : Weights d C r)
    (f : BooleanFunction d) {K b σ : ℝ} (hK : 0 ≤ K) (hb : 0 ≤ b) (hσ : 0 < σ)
    (hscale : (N : ℝ)*σ^2 ≤ 1) (hv : weightedSquaredNorm (clonedWeights e teacher) ≤ K)
    (hmargin : clonedWeights e teacher ∈ marginEvent Real.tanh (3/2) f)
    (hsize : 4*(smallBallTilt (cylinderRadius d r K C (2*(b+C+1))))^2 ≤ (k : ℝ))
    (herr : (replacementConstant ν standardGaussian*lindebergPolynomial
      (smallBallTilt (cylinderRadius d r K C (2*(b+C+1)))))^2 ≤ (k : ℝ))
    (htail : 2*(9 : ℝ)^(N+N)*Real.exp (-b^2*N/(8*subGaussianVariance ν)) ≤
      (1/2)*((cylinderRadius d r K C (2*(b+C+1)))^2/1024)^(C*N)) :
    Real.exp (-(ν.upperCurvature/2*K+
      networkCylinderCost ν d C r (cylinderRadius d r K C (2*(b+C+1))))/σ^2) ≤
      functionMass Real.tanh (1/2) (smallPrior ν d N r σ) f := by
  let ρ := cylinderRadius d r K C (2*(b+C+1))
  have hρ : 0 < ρ := cylinderRadius_pos d r hK (Nat.cast_nonneg C)
  have hρhalf : ρ ≤ 1/2 := by
    have hA : 0 ≤ cylinderAmplification K C (2*(b+C+1)) := by
      unfold cylinderAmplification
      positivity
    have hD : 0 ≤ cylinderInputFactor d := by unfold cylinderInputFactor; positivity
    have hden : 2 ≤ 2*(2*K*cylinderInputFactor d*(cylinderAmplification K C (2*(b+C+1)))^r+2) := by
      have : 0 ≤ 2*K*cylinderInputFactor d*(cylinderAmplification K C (2*(b+C+1)))^r := by positivity
      linarith
    simpa only [ρ, cylinderRadius, one_div] using one_div_le_one_div_of_le (by norm_num : (0 : ℝ) < 2) hden
  have ht := smallPrior_cloned_cylinder_mass ν hd hN hk e teacher f hK hb hσ hscale hv hmargin
  change _*Real.exp (-(ν.upperCurvature/2*K/σ^2)) ≤ _ at ht
  rw [←noiseCylinder_probability ν d e ρ b r] at ht
  have hn := noiseCylinder_exp_lower ν d r hN hk e hρ hρhalf hb hsize herr htail
  have hprod := mul_le_mul_of_nonneg_right hn (Real.exp_nonneg (-(ν.upperCurvature/2*K/σ^2)))
  have he : Real.exp (-(ν.upperCurvature/2*K+networkCylinderCost ν d C r ρ)/σ^2) ≤
      Real.exp (-(N : ℝ)*networkCylinderCost ν d C r ρ)*
        Real.exp (-(ν.upperCurvature/2*K/σ^2)) := by
    rw [←Real.exp_add]
    apply Real.exp_le_exp.mpr
    have hNle : (N : ℝ) ≤ 1/σ^2 := (le_div_iff₀ (sq_pos_of_pos hσ)).mpr hscale
    have hm := mul_le_mul_of_nonneg_right hNle
      (networkCylinderCost_nonneg ν d C r hρ (by linarith : ρ ≤ 1))
    ring_nf at hm ⊢
    linarith
  exact he.trans (hprod.trans ht)

end NeuralGeneralization.BatchTwoNonGaussian
