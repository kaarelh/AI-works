import NeuralGeneralization.BatchTwoOnlineReluFiniteMain

/-! Elementary polynomial majorants for the literal finite-variance constants. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel BatchTwoActivation
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

theorem sqrt_le_add_one {x : ℝ} (hx : 0≤x) : Real.sqrt x≤x+1 := by
  nlinarith [Real.sq_sqrt hx,Real.sqrt_nonneg x,sq_nonneg (Real.sqrt x-1)]

def reluRadiusMajorant (r : ℕ) (K : ℝ) : ℝ := 8*(r+2:ℝ)*(K+2)^(r+1)

theorem reluRadiusMajorant_one_le (r : ℕ) {K : ℝ} (hK : 0≤K) : 1≤reluRadiusMajorant r K := by
  have hp : 1≤(K+2)^(r+1) := one_le_pow₀ (by linarith)
  unfold reluRadiusMajorant
  nlinarith [Nat.cast_nonneg r (α:=ℝ)]

theorem relu_radius_inverse_majorant (r : ℕ) {K : ℝ} (hK : 0≤K) :
    (reluPerturbationRadius r K)⁻¹≤reluRadiusMajorant r K := by
  have hL : (1:ℝ)≤r+2 := by linarith [Nat.cast_nonneg r (α:=ℝ)]
  have hroot : Real.sqrt (2*(r+2:ℝ))≤2*(r+2:ℝ) := by
    nlinarith [Real.sq_sqrt (show 0≤2*(r+2:ℝ) by positivity),Real.sqrt_nonneg (2*(r+2:ℝ))]
  have hdiv : K/(r+2:ℝ)≤K := (div_le_iff₀ (by positivity)).mpr (le_mul_of_one_le_right hK hL)
  have hsmall : Real.sqrt (K/(r+2:ℝ))+1≤K+2 := by
    have hh := (Real.sqrt_le_sqrt hdiv).trans (sqrt_le_add_one hK)
    linarith
  have hpow := pow_le_pow_left₀ (by positivity) hsmall (r+1)
  have ha : 4*Real.sqrt (2*(r+2:ℝ))*(Real.sqrt (K/(r+2:ℝ))+1)^(r+1)≤reluRadiusMajorant r K := by
    have hh := mul_le_mul (mul_le_mul_of_nonneg_left hroot (by norm_num : (0:ℝ)≤4)) hpow (by positivity) (by positivity)
    exact hh.trans_eq (by unfold reluRadiusMajorant; ring)
  unfold reluPerturbationRadius
  by_cases h : (1:ℝ)≤(4*Real.sqrt (2*(r+2:ℝ))*(Real.sqrt (K/(r+2:ℝ))+1)^(r+1))⁻¹
  · rw [min_eq_left h,inv_one]
    exact reluRadiusMajorant_one_le r hK
  · rw [min_eq_right (le_of_not_ge h),inv_inv]
    exact ha

def reluMassMajorant (d r : ℕ) (K : ℝ) : ℝ :=
  (K+2)^2+((d:ℝ)+(r+2:ℝ))*3*((d:ℝ)+(r+2:ℝ)+1)*reluRadiusMajorant r K

theorem relu_mass_budget_majorant (d r : ℕ) {K : ℝ} (hK : 0≤K) :
    gaussianBoxBudget K ((d:ℝ)+(r+2:ℝ)) (reluPerturbationRadius r K)≤reluMassMajorant d r K := by
  let S : ℝ := (d:ℝ)+(r+2:ℝ)
  let ρ := reluPerturbationRadius r K
  let R := reluRadiusMajorant r K
  have hS : 0<S := by dsimp [S]; positivity
  have hρ : 0<ρ := reluPerturbationRadius_pos r K
  have hR : 1≤R := reluRadiusMajorant_one_le r hK
  have hrad : ρ⁻¹≤R := relu_radius_inverse_majorant r hK
  have hsqrt : Real.sqrt K+ρ≤K+2 := by
    linarith [sqrt_le_add_one hK,reluPerturbationRadius_le_one r K]
  have hsquare := pow_le_pow_left₀ (by positivity) hsqrt 2
  have hsmall : Real.sqrt S/ρ≤(S+1)*R := by
    rw [div_eq_mul_inv]
    exact mul_le_mul (sqrt_le_add_one hS.le) hrad (inv_nonneg.mpr hρ.le) (by positivity)
  have hone : 1≤(S+1)*R := by nlinarith
  have hmax : max 1 (Real.sqrt S/ρ)≤(S+1)*R := max_le hone hsmall
  have hD : 0<3*max 1 (Real.sqrt S/ρ) := by positivity
  have hlog : Real.log (3*max 1 (Real.sqrt S/ρ))≤3*(S+1)*R := by
    have hh := Real.log_le_sub_one_of_pos hD
    nlinarith
  have hmul := mul_le_mul_of_nonneg_left hlog hS.le
  change (Real.sqrt K+ρ)^2/2+S*Real.log (3*max 1 (Real.sqrt S/ρ))≤(K+2)^2+S*3*(S+1)*R
  nlinarith [sq_nonneg (K+2)]

theorem relu_teacher_energy_majorant (d r : ℕ) (P : ℝ) {Q : ℝ} (hPQ : P^2≤Q) :
    reluTeacherEnergy d r P≤(r+2:ℝ)*(1+4*(d:ℝ)*Q) := by
  have hx : 0≤4*(d:ℝ)*P^2 := by positivity
  have he : 0≤(r+2:ℝ)⁻¹ := by positivity
  have heone : (r+2:ℝ)⁻¹≤1 := by
    rw [inv_le_one₀ (by positivity)]
    linarith [Nat.cast_nonneg r (α:=ℝ)]
  have hh := (Real.rpow_le_rpow hx (le_add_of_nonneg_left zero_le_one) he).trans
    (Real.rpow_le_self_of_one_le (show 1≤1+4*(d:ℝ)*P^2 by linarith) heone)
  have hQ := mul_le_mul_of_nonneg_left hPQ (show 0≤4*(d:ℝ) by positivity)
  exact mul_le_mul_of_nonneg_left (hh.trans (by linarith)) (by positivity)

end NeuralGeneralization.BatchTwoOnlineReluFinite
