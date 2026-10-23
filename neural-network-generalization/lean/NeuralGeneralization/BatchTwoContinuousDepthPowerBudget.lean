import NeuralGeneralization.BatchTwoContinuousFiniteTargetCost

/-! Logarithmic cylinder arithmetic retaining polynomial dependence on depth. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1800000
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open ConcreteModel BatchTwoNonGaussian BatchTwoContinuous.FiniteTarget

def depthLogFactor (d r C : ℕ) (K : ℝ) : ℝ :=
  5+K*cylinderInputFactor d+(r : ℝ)*(3*K+12*((C : ℝ)+2)^2+3*C+1)

theorem depthLogFactor_pos (d r C : ℕ) {K : ℝ} (hK : 0≤K) :
    0<depthLogFactor d r C K := by
  unfold depthLogFactor cylinderInputFactor
  positivity

theorem log_inverseRadius_depth (d r C : ℕ) {K b : ℝ} (hK : 0≤K) (hb : 0≤b) :
    Real.log ((cylinderRadius d r K C (2*(b+C+1)))⁻¹) ≤
      depthLogFactor d r C K+2*(r : ℝ)*(b+1) := by
  let A := 3*K+12*((C : ℝ)+2)^2+3*C+1
  let D := cylinderInputFactor d
  have hA : 1≤A := by dsimp [A]; nlinarith [sq_nonneg ((C : ℝ)+2),Nat.cast_nonneg C (α := ℝ)]
  have hD : 0≤D := by dsimp [D,cylinderInputFactor]; positivity
  have hKD : 0≤K*D := mul_nonneg hK hD
  have hApos : 0<A := lt_of_lt_of_le zero_lt_one hA
  have hp : 1≤A^r := one_le_pow₀ hA
  have hmajor : inverseRadiusFactor d r C K ≤4*(K*D+1)*A^r := by
    dsimp [inverseRadiusFactor,A,D]
    nlinarith
  have hρ := cylinderRadius_pos d r hK (Nat.cast_nonneg C) (B := 2*(b+C+1))
  have ha := inverseRadiusFactor_pos d r C hK
  have hb0 : 0<b+1 := by linarith
  have hl := Real.log_le_log (inv_pos.mpr hρ) (inverseRadius_le_factor d r C hK hb)
  rw [Real.log_mul ha.ne' (pow_pos hb0 _).ne',Real.log_pow] at hl
  have hla := Real.log_le_log ha hmajor
  rw [Real.log_mul (by positivity : (4*(K*D+1) : ℝ)≠0) (pow_pos hApos r).ne',
    Real.log_mul (by norm_num : (4 : ℝ)≠0) (by positivity : K*D+1≠0),Real.log_pow] at hla
  have h4 : Real.log 4≤4 := (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ)<4)).trans (by norm_num)
  have hkd : Real.log (K*D+1)≤K*D+1 :=
    (Real.log_le_sub_one_of_pos (by positivity : 0<K*D+1)).trans (by linarith)
  have ha' : Real.log A≤A := (Real.log_le_sub_one_of_pos hApos).trans (by linarith)
  have hb' : Real.log (b+1)≤b+1 := (Real.log_le_sub_one_of_pos hb0).trans (by linarith)
  have hma := mul_le_mul_of_nonneg_left ha' (Nat.cast_nonneg r : (0 : ℝ)≤r)
  have hmb := mul_le_mul_of_nonneg_left hb' (show (0 : ℝ)≤2*r by positivity)
  push_cast at hl
  change _≤5+K*D+(r : ℝ)*A+2*(r : ℝ)*(b+1)
  linarith

def powerTailCoefficient (d r C : ℕ) (K ℓ : ℝ) : ℝ :=
  (22+1024*(C : ℝ)+2*C*depthLogFactor d r C K+4*C*r)+2*C*ℓ

def powerNoiseBound (ν : CoordinateLaw) (d r C : ℕ) (K ℓ : ℝ) : ℝ :=
  1+16*subGaussianVariance ν*powerTailCoefficient d r C K ℓ

theorem powerTailCoefficient_pos (d r C : ℕ) {K ℓ : ℝ} (hK : 0≤K) (hℓ : 0≤ℓ) :
    0<powerTailCoefficient d r C K ℓ :=
  add_pos_of_pos_of_nonneg ((show 0<(22+1024*(C : ℝ)+2*C*depthLogFactor d r C K+4*C*r) by have := depthLogFactor_pos d r C hK; positivity)) (by positivity)

theorem powerNoiseBound_pos (ν : CoordinateLaw) (d r C : ℕ) {K ℓ : ℝ}
    (hK : 0≤K) (hℓ : 0≤ℓ) : 0<powerNoiseBound ν d r C K ℓ := by
  have := powerTailCoefficient_pos d r C hK hℓ
  have := subGaussianVariance_pos ν
  unfold powerNoiseBound
  positivity

theorem powerNoiseBound_budget (ν : CoordinateLaw) (d r C : ℕ) {K q ℓ : ℝ}
    (hK : 0≤K) (hq : 0<q) (hℓ : 0≤ℓ) (hlogq : Real.log (1/q) ≤ ℓ) :
    let b := powerNoiseBound ν d r C K ℓ
    let ρ := q*cylinderRadius d r K C (2*(b+C+1))
    2*Real.log 9+(C : ℝ)*Real.log (1024/ρ^2)+2*Real.log 2 ≤
      b^2/(8*subGaussianVariance ν) := by
  let b := powerNoiseBound ν d r C K ℓ
  let ρ := q*cylinderRadius d r K C (2*(b+C+1))
  let D := powerTailCoefficient d r C K ℓ
  let a := depthLogFactor d r C K
  have hb : 0 ≤ b := (powerNoiseBound_pos ν d r C hK hℓ).le
  have hρ : 0 < ρ := mul_pos hq (cylinderRadius_pos d r hK (Nat.cast_nonneg C))
  have hv := subGaussianVariance_pos ν
  have ha : 0 < a := depthLogFactor_pos d r C hK
  have hD : 0 < D := powerTailCoefficient_pos d r C hK hℓ
  have hl : Real.log (ρ⁻¹) ≤ ℓ+a+2*(r : ℝ)*(b+1) := by
    have hh := log_inverseRadius_depth d r C hK hb
    dsimp only [ρ]
    rw [mul_inv_rev,Real.log_mul (inv_pos.mpr (cylinderRadius_pos d r hK (Nat.cast_nonneg C))).ne'
      (inv_pos.mpr hq).ne']
    simp only [one_div] at hlogq
    linarith
  have hlog : Real.log (1024/ρ^2)=Real.log 1024+2*Real.log (ρ⁻¹) := by
    rw [Real.log_div (by norm_num) (sq_pos_of_pos hρ).ne',Real.log_pow,Real.log_inv]
    ring
  have hl9 : Real.log 9 ≤ 9 := (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 9)).trans (by norm_num)
  have hl2 : Real.log 2 ≤ 2 := (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)).trans (by norm_num)
  have hl1024 : Real.log 1024 ≤ 1024 :=
    (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 1024)).trans (by norm_num)
  have hcoef : 4*(C : ℝ)*r ≤ D := by
    dsimp [D,powerTailCoefficient,cylinderTailCoefficient]
    nlinarith [mul_nonneg (Nat.cast_nonneg C : (0 : ℝ) ≤ C) ha.le,
      mul_nonneg (Nat.cast_nonneg C : (0 : ℝ) ≤ C) hℓ]
  have hlogbound : 2*Real.log 9+(C : ℝ)*Real.log (1024/ρ^2)+2*Real.log 2 ≤ D*(b+1) := by
    rw [hlog]
    have hh := mul_le_mul_of_nonneg_left hl (Nat.cast_nonneg C : (0 : ℝ) ≤ C)
    have hconst := mul_le_mul_of_nonneg_left hl1024 (Nat.cast_nonneg C : (0 : ℝ) ≤ C)
    have hB := mul_le_mul_of_nonneg_right hcoef hb
    dsimp [D,powerTailCoefficient,a] at hB ⊢
    nlinarith
  apply hlogbound.trans
  apply (le_div_iff₀ (mul_pos (by norm_num) hv)).mpr
  change D*(b+1)*(8*subGaussianVariance ν) ≤ b^2
  have hbdef : b=1+16*subGaussianVariance ν*D := rfl
  rw [hbdef]
  nlinarith [sq_nonneg (subGaussianVariance ν*D),mul_nonneg hv.le hD.le]


def powerLogRadiusBound (ν : CoordinateLaw) (d r C : ℕ) (K ℓ : ℝ) : ℝ :=
  ℓ+depthLogFactor d r C K+2*(r : ℝ)*(powerNoiseBound ν d r C K ℓ+1)

def powerPolynomialNoiseCost (ν : CoordinateLaw) (d r C : ℕ) (K ℓ : ℝ) : ℝ :=
  ((d : ℝ)+2)*(|Real.log (1/coordinateBallConstant ν)|+powerLogRadiusBound ν d r C K ℓ)+
    (r : ℝ)*((C : ℝ)*(1024+2*powerLogRadiusBound ν d r C K ℓ)+2)

theorem powerLogRadiusBound_nonneg (ν : CoordinateLaw) (d r C : ℕ) {K ℓ : ℝ}
    (hK : 0≤K) (hℓ : 0≤ℓ) : 0≤powerLogRadiusBound ν d r C K ℓ := by
  have := depthLogFactor_pos d r C hK
  have := powerNoiseBound_pos ν d r C hK hℓ
  unfold powerLogRadiusBound
  positivity

theorem powerPolynomialNoiseCost_nonneg (ν : CoordinateLaw) (d r C : ℕ) {K ℓ : ℝ}
    (hK : 0≤K) (hℓ : 0≤ℓ) : 0≤powerPolynomialNoiseCost ν d r C K ℓ := by
  have := powerLogRadiusBound_nonneg ν d r C hK hℓ
  unfold powerPolynomialNoiseCost
  positivity

theorem networkCylinderCost_le_powerPolynomial (ν : CoordinateLaw) (d r C : ℕ)
    {K q ℓ : ℝ} (hK : 0≤K) (hq : 0<q) (hℓ : 0≤ℓ) (hlogq : Real.log (1/q)≤ℓ) :
    let b := powerNoiseBound ν d r C K ℓ
    let η := q*cylinderRadius d r K C (2*(b+C+1))
    networkCylinderCost ν d C r η ≤ powerPolynomialNoiseCost ν d r C K ℓ := by
  let b := powerNoiseBound ν d r C K ℓ
  let η := q*cylinderRadius d r K C (2*(b+C+1))
  have hη : 0<η := mul_pos hq (cylinderRadius_pos d r hK (Nat.cast_nonneg C))
  have hlog : Real.log (η⁻¹) ≤ powerLogRadiusBound ν d r C K ℓ := by
    have hh := log_inverseRadius_depth d r C hK (powerNoiseBound_pos ν d r C hK hℓ).le
    dsimp only [η,powerLogRadiusBound]
    rw [mul_inv_rev,Real.log_mul
      (inv_pos.mpr (cylinderRadius_pos d r hK (Nat.cast_nonneg C))).ne' (inv_pos.mpr hq).ne']
    simp only [one_div] at hlogq
    linarith
  have hscalar : scalarCylinderCost ν η ≤
      |Real.log (1/coordinateBallConstant ν)|+powerLogRadiusBound ν d r C K ℓ := by
    unfold scalarCylinderCost
    rw [show 1/(coordinateBallConstant ν*η)=(1/coordinateBallConstant ν)*η⁻¹ by ring,
      Real.log_mul (one_div_pos.mpr (coordinateBallConstant_pos ν)).ne' (inv_pos.mpr hη).ne']
    exact add_le_add (le_abs_self _) hlog
  have hmatrix : matrixCylinderCost C η ≤
      (C : ℝ)*(1024+2*powerLogRadiusBound ν d r C K ℓ)+2 := by
    have h1024 : Real.log 1024≤(1024 : ℝ) :=
      (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ)<1024)).trans (by norm_num)
    have h2 : Real.log 2≤(2 : ℝ) :=
      (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ)<2)).trans (by norm_num)
    have he : Real.log (1024/η^2)=Real.log 1024+2*Real.log (η⁻¹) := by
      rw [Real.log_div (by norm_num) (sq_pos_of_pos hη).ne',Real.log_pow,Real.log_inv]
      ring
    unfold matrixCylinderCost
    rw [he]
    exact add_le_add (mul_le_mul_of_nonneg_left (by linarith) (Nat.cast_nonneg C)) h2
  exact add_le_add (mul_le_mul_of_nonneg_left hscalar (by positivity))
    (mul_le_mul_of_nonneg_left hmatrix (Nat.cast_nonneg r))

end NeuralGeneralization.BatchTwoContinuousDepthPower
