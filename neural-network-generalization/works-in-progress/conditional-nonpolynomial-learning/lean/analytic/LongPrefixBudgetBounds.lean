import UniformBlockConstants

noncomputable section
set_option maxHeartbeats 1000000
namespace ConditionalNonpolynomial.Analytic

theorem prefix_raw_cost_bound {J K T a C c D E : ℝ}
    (hJ0 : 0≤J) (hK : 1≤K) (hT : 0≤T) (ha : 0<a) (hC : 0≤C)
    (hJ : J≤(K+1)*T/a) (hE : E≤C*a*T) (hc : c≤a^2/4)
    (hD : D≤J*c+E) :
    D≤(K/2+C+1)*a*T := by
  have hj := (le_div_iff₀ ha).mp hJ
  have hmul := mul_le_mul_of_nonneg_right hj ha.le
  have hcost := mul_le_mul_of_nonneg_left hc hJ0
  have hpositive := mul_nonneg (show 0≤K/4+3/4 by linarith) (mul_nonneg ha.le hT)
  nlinarith only [hmul,hcost,hE,hD,hpositive]

theorem prefix_forcing_sqrt_bound {J K T a C E : ℝ}
    (hJ0 : 0≤J) (hK : 1≤K) (hT : 0≤T) (ha : 0<a) (hC : 0≤C) (hE0 : 0≤E)
    (hJ : J≤(K+1)*T/a) (hE : E≤C*a*T) :
    Real.sqrt (J*E)≤Real.sqrt (2*C)*Real.sqrt K*T := by
  have hj := (le_div_iff₀ ha).mp hJ
  have h1 := mul_le_mul_of_nonneg_left hE hJ0
  have h2 := mul_le_mul_of_nonneg_right hj (mul_nonneg hC hT)
  have h3 := mul_nonneg (show 0≤K-1 by linarith) (mul_nonneg hC (sq_nonneg T))
  have hJE : J*E≤2*C*K*T^2 := by nlinarith only [h1,h2,h3]
  have htarget : (Real.sqrt (2*C)*Real.sqrt K*T)^2=2*C*K*T^2 := by
    rw [mul_pow,mul_pow,Real.sq_sqrt (by positivity),Real.sq_sqrt (by linarith : 0≤K)]
  have hnorm := Real.sq_sqrt (mul_nonneg hJ0 hE0)
  have hp : 0≤Real.sqrt (2*C)*Real.sqrt K*T := by positivity
  nlinarith [Real.sqrt_nonneg (J*E)]

/-- This applies both to the original variance occupation and to its
canonical replacement, with any fixed additive/linear constants. -/
theorem prefix_nonlinear_budget_bound {J K T a C E L M₀ M₁ : ℝ}
    (hJ0 : 0≤J) (hK : 1≤K) (hT : 1≤T) (ha : 0<a) (hC : 0≤C) (hE0 : 0≤E)
    (hM₀ : 0≤M₀) (hM₁ : 0≤M₁)
    (hJ : J≤(K+1)*T/a) (hE : E≤C*a*T) (hL : L≤T) :
    M₀+M₁*(L+Real.sqrt (J*E))≤
      (M₀+M₁*(1+Real.sqrt (2*C)))*(1+Real.sqrt K)*T := by
  have hT0 : 0≤T := by linarith
  have hs := prefix_forcing_sqrt_bound hJ0 hK hT0 ha hC hE0 hJ hE
  have hstep := mul_le_mul_of_nonneg_left (add_le_add hL hs) hM₁
  have hMbase : M₀≤M₀*(1+Real.sqrt K)*T := by
    have hx : 1≤(1+Real.sqrt K)*T := by
      nlinarith [Real.sqrt_nonneg K,mul_nonneg (Real.sqrt_nonneg K) hT0]
    nlinarith [mul_le_mul_of_nonneg_left hx hM₀]
  have hcross : 0≤M₁*(Real.sqrt K+Real.sqrt (2*C))*T := by positivity
  nlinarith only [hstep,hMbase,hcross]

theorem prefix_entropy_sqrt_bound {J K T a C D : ℝ}
    (hJ0 : 0≤J) (hK : 1≤K) (hT : 0≤T) (ha : 0<a) (hC : 0≤C) (hD0 : 0≤D)
    (hJ : J≤(K+1)*T/a) (hD : D≤(K/2+C+1)*a*T) :
    Real.sqrt (J*D)≤(K+C+2)*T := by
  have hj := (le_div_iff₀ ha).mp hJ
  have hc : 0≤K/2+C+1 := by linarith
  have h1 := mul_le_mul_of_nonneg_left hD hJ0
  have h2 := mul_le_mul_of_nonneg_right hj (mul_nonneg hc hT)
  have hscalar : (K+1)*(K/2+C+1)≤(K+C+2)^2 := by
    nlinarith [sq_nonneg K,sq_nonneg C,mul_nonneg (show 0≤K by linarith) hC]
  have h3 := mul_le_mul_of_nonneg_right hscalar (sq_nonneg T)
  have hJE : J*D≤((K+C+2)*T)^2 := by nlinarith only [h1,h2,h3]
  have hs := Real.sq_sqrt (mul_nonneg hJ0 hD0)
  have hp : 0≤(K+C+2)*T := by positivity
  nlinarith [Real.sqrt_nonneg (J*D)]

#print axioms prefix_raw_cost_bound
#print axioms prefix_nonlinear_budget_bound
#print axioms prefix_entropy_sqrt_bound
end ConditionalNonpolynomial.Analytic
