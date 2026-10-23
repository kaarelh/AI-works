import NeuralGeneralization.BatchTwoContinuousDepthPowerMass

/-! A universal degree-seven envelope for the lower-order cylinder entropy. -/
noncomputable section
set_option maxHeartbeats 2000000
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open ConcreteModel BatchTwoNonGaussian BatchTwoContinuous.FiniteTarget

def noisePolynomialCoefficient (ν : CoordinateLaw) : ℝ :=
  1000000*(1+subGaussianVariance ν+|Real.log (1/coordinateBallConstant ν)|)

theorem noisePolynomialCoefficient_pos (ν : CoordinateLaw) :
    0<noisePolynomialCoefficient ν := by
  have := subGaussianVariance_pos ν
  unfold noisePolynomialCoefficient
  positivity

theorem powerPolynomialNoiseCost_global (ν : CoordinateLaw) {d C r : ℕ} {K ℓ S : ℝ}
    (hS : 1≤S) (hd : (d : ℝ)≤S) (hC : (C : ℝ)≤S) (hr : (r : ℝ)≤S)
    (hK0 : 0≤K) (hK : K≤S) (hℓ0 : 0≤ℓ) (hℓ : ℓ≤S) :
    powerPolynomialNoiseCost ν d r C K ℓ≤noisePolynomialCoefficient ν*S^7 := by
  have hS0 : 0≤S := by linarith
  have hS2 : S≤S^2 := by simpa using pow_le_pow_right₀ hS (show 1≤2 by omega)
  have hS3 : S≤S^3 := by simpa using pow_le_pow_right₀ hS (show 1≤3 by omega)
  have hS4 : S≤S^4 := by simpa using pow_le_pow_right₀ hS (show 1≤4 by omega)
  have hS5 : S≤S^5 := by simpa using pow_le_pow_right₀ hS (show 1≤5 by omega)
  have h23 : S^2≤S^3 := pow_le_pow_right₀ hS (by omega)
  have h24 : S^2≤S^4 := pow_le_pow_right₀ hS (by omega)
  have h35 : S^3≤S^5 := pow_le_pow_right₀ hS (by omega)
  have h47 : S^4≤S^7 := pow_le_pow_right₀ hS (by omega)
  have h67 : S^6≤S^7 := pow_le_pow_right₀ hS (by omega)
  have h27 : S^2≤S^7 := pow_le_pow_right₀ hS (by omega)
  have h17 : S≤S^7 := by simpa using pow_le_pow_right₀ hS (show 1≤7 by omega)
  have h1S3 : 1≤S^3 := one_le_pow₀ hS
  have h1S4 : 1≤S^4 := one_le_pow₀ hS
  have h1S2 : 1≤S^2 := one_le_pow₀ hS
  have hD : cylinderInputFactor d≤5*S^2 := by
    unfold cylinderInputFactor
    have hh : ((d : ℝ)+1)^2≤(2*S)^2 := by gcongr; linarith
    nlinarith
  have hA : 3*K+12*((C : ℝ)+2)^2+3*C+1≤115*S^2 := by
    have hh : ((C : ℝ)+2)^2≤(3*S)^2 := by gcongr; linarith
    nlinarith
  have hKD : K*cylinderInputFactor d≤5*S^3 := by
    calc
      _ ≤ S*(5*S^2) := mul_le_mul hK hD (by unfold cylinderInputFactor; positivity) hS0
      _ = _ := by ring
  have hrA : (r : ℝ)*(3*K+12*((C : ℝ)+2)^2+3*C+1)≤115*S^3 := by
    calc
      _ ≤ S*(115*S^2) := mul_le_mul hr hA (by positivity) hS0
      _ = _ := by ring
  have hfac : depthLogFactor d r C K≤125*S^3 := by unfold depthLogFactor; linarith
  have hfac0 := (depthLogFactor_pos d r C hK0).le
  have hCf : 2*(C : ℝ)*depthLogFactor d r C K≤250*S^4 := by
    calc
      _ ≤ 2*S*(125*S^3) := mul_le_mul (by linarith) hfac hfac0 (by positivity)
      _ = _ := by ring
  have hCr : 4*(C : ℝ)*r≤4*S^2 := by nlinarith [mul_le_mul hC hr (Nat.cast_nonneg r : (0 : ℝ)≤r) hS0]
  have hCℓ : 2*(C : ℝ)*ℓ≤2*S^2 := by nlinarith [mul_le_mul hC hℓ hℓ0 hS0]
  have htail : powerTailCoefficient d r C K ℓ≤1302*S^4 := by
    unfold powerTailCoefficient
    linarith
  let V := subGaussianVariance ν
  have hV : 0≤V := (subGaussianVariance_pos ν).le
  have hnoise : powerNoiseBound ν d r C K ℓ≤(1+20832*V)*S^4 := by
    have hh := mul_le_mul_of_nonneg_left htail (show 0≤16*V by positivity)
    unfold powerNoiseBound
    change 1+16*V*powerTailCoefficient d r C K ℓ≤_
    nlinarith
  have hnoisesum : powerNoiseBound ν d r C K ℓ+1≤(2+20832*V)*S^4 := by nlinarith
  have hrnoise : 2*(r : ℝ)*(powerNoiseBound ν d r C K ℓ+1)≤(4+41664*V)*S^5 := by
    calc
      _ ≤ 2*S*((2+20832*V)*S^4) := mul_le_mul (by linarith) hnoisesum
        (by have := powerNoiseBound_pos ν d r C hK0 hℓ0; positivity) (by positivity)
      _ = _ := by ring
  let H := 130+41664*V
  have hH : 0≤H := by dsimp [H]; positivity
  have hlog : powerLogRadiusBound ν d r C K ℓ≤H*S^5 := by
    unfold powerLogRadiusBound
    dsimp only [H]
    nlinarith
  let a := |Real.log (1/coordinateBallConstant ν)|
  have ha : 0≤a := abs_nonneg _
  have hleft : ((d : ℝ)+2)*(a+powerLogRadiusBound ν d r C K ℓ)≤3*a*S+3*H*S^6 := by
    calc
      _ ≤ 3*S*(a+H*S^5) := mul_le_mul (by linarith) (by linarith)
        (by have := powerLogRadiusBound_nonneg ν d r C hK0 hℓ0; positivity) (by positivity)
      _ = _ := by ring
  have hinner : (C : ℝ)*(1024+2*powerLogRadiusBound ν d r C K ℓ)+2≤1024*S+2*H*S^6+2 := by
    have hh := mul_le_mul hC (show 1024+2*powerLogRadiusBound ν d r C K ℓ≤1024+2*H*S^5 by linarith)
      (by have := powerLogRadiusBound_nonneg ν d r C hK0 hℓ0; positivity) hS0
    nlinarith
  have hright : (r : ℝ)*((C : ℝ)*(1024+2*powerLogRadiusBound ν d r C K ℓ)+2)≤1024*S^2+2*H*S^7+2*S := by
    calc
      _ ≤ S*(1024*S+2*H*S^6+2) := mul_le_mul hr hinner
        (by have := powerLogRadiusBound_nonneg ν d r C hK0 hℓ0; positivity) hS0
      _ = _ := by ring
  have hcoef : 3*a+5*H+1026≤noisePolynomialCoefficient ν := by
    unfold noisePolynomialCoefficient
    dsimp only [H,V,a] at *
    linarith [subGaussianVariance_pos ν,abs_nonneg (Real.log (1/coordinateBallConstant ν))]
  have hbound : powerPolynomialNoiseCost ν d r C K ℓ≤(3*a+5*H+1026)*S^7 := by
    unfold powerPolynomialNoiseCost
    change ((d : ℝ)+2)*(a+powerLogRadiusBound ν d r C K ℓ)+_≤_
    nlinarith [mul_le_mul_of_nonneg_left h17 (show 0≤3*a by positivity),
      mul_le_mul_of_nonneg_left h67 (show 0≤3*H by positivity)]
  exact hbound.trans (mul_le_mul_of_nonneg_right hcoef (by positivity))

end NeuralGeneralization.BatchTwoContinuousDepthPower
