import NeuralGeneralization.OnlineLowerTanhGainIdentification
import NeuralGeneralization.OnlineLowerTanhHolomorphicCost
import NeuralGeneralization.OnlineLowerTanhScalarBounds

/-! The actual holomorphic cost interpolates the inverse optimized tanh
coefficient, including its exact square-root normalization. -/
noncomputable section
open Complex
namespace NeuralGeneralization.OnlineLowerTanh

theorem holomorphicOptimizedCost_odd (b:ActualGainBranch) (r:ℕ)
    (hr:b.threshold<(2*r+1:ℕ)) :
    holomorphicOptimizedCost b ((2*r+1:ℕ):ℂ)=(balancedCost r:ℂ) := by
  unfold holomorphicOptimizedCost
  rw [actualGainBranch_eq_balancedGain b r hr,complexF_odd_eq_balanced]
  have hH := centralBinomialHolomorphic_odd r
  have hH' : centralBinomialHolomorphic ((2*r+1:ℕ):ℂ)=
      (oddParityKappa r*Real.sqrt (Real.pi*((2*r+1:ℕ):ℝ)/2):ℝ) := by
    simpa only [Nat.cast_add,Nat.cast_mul,Nat.cast_ofNat,Nat.cast_one] using hH
  rw [hH']
  let n:ℝ := (2*r+1:ℕ)
  have hn:0<n := by dsimp [n]; positivity
  have hpi:0<Real.sqrt (Real.pi/2) := Real.sqrt_pos.2 (by positivity)
  have hs:Real.sqrt (Real.pi*n/2)=Real.sqrt (Real.pi/2)*Real.sqrt n := by
    rw [show Real.pi*n/2=(Real.pi/2)*n by ring,Real.sqrt_mul (by positivity)]
  have hnroot:Real.sqrt n*Real.sqrt n=n := Real.mul_self_sqrt hn.le
  have hk:oddParityKappa r≠0 := (oddParityKappa_pos r).ne'
  have hq:balancedParity r (balancedGain r)≠0 := (balancedParity_gain_pos r).ne'
  change (Real.sqrt (Real.pi/2):ℂ)*(n:ℂ)*
    ((balancedGain r:ℂ)/((oddParityKappa r*Real.sqrt (Real.pi*n/2):ℝ)*
      (balancedParity r (balancedGain r)/oddParityKappa r:ℝ))) = _
  rw [hs]
  unfold balancedCost
  change _ = ((balancedGain r*Real.sqrt n/balancedParity r (balancedGain r):ℝ):ℂ)
  push_cast
  have hk':(oddParityKappa r:ℂ)≠0 := by exact_mod_cast hk
  have hq':(balancedParity r (balancedGain r):ℂ)≠0 := by exact_mod_cast hq
  have hp':(Real.sqrt (Real.pi/2):ℂ)≠0 := by exact_mod_cast hpi.ne'
  have hs':(Real.sqrt n:ℂ)≠0 := by exact_mod_cast (Real.sqrt_pos.2 hn).ne'
  field_simp
  have he : n*balancedGain r=balancedGain r*(Real.sqrt n)^2 := by nlinarith [congrArg (fun x:ℝ=>balancedGain r*x) hnroot]
  exact_mod_cast he

end NeuralGeneralization.OnlineLowerTanh
