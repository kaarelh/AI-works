import FiniteChannelWidthBudget

noncomputable section
set_option maxHeartbeats 1600000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

theorem finiteChannelWidthBudget_envelope {M B S v κ τ K : ℝ} {H : ℕ}
    (hM : 1≤M) (hK : 1≤K) (hB0 : 0≤B) (hv : 0<v) (hκ : 0<κ) (hτ : 0<τ)
    (hH : (H:ℝ)+1≤K) (hB : B≤K) (hS : Real.exp S≤K)
    (hvK : 1/v≤K) (hκK : 1/κ≤K) (hτK : 1/τ≤K) :
    finiteChannelWidthBudget M H B S v κ τ≤2^28*M*K^20 := by
  have hM0 : 0≤M := by linarith
  have hK0 : 0≤K := by linarith
  have hK1 : 1≤K^20 := one_le_pow₀ hK
  have hK3 : K^3≤K^20 := pow_le_pow_right₀ hK (by norm_num)
  have hKK : K≤K^20 := by simpa only [pow_one] using pow_le_pow_right₀ hK (show 1≤20 by norm_num)
  have he : 2*64^4*((H:ℝ)+1)^5*(1+2*M)*B^4*(Real.exp S)^4/(κ^5*v^2)=
      2*64^4*((H:ℝ)+1)^5*(1+2*M)*B^4*(Real.exp S)^4*(1/κ)^5*(1/v)^2 := by ring
  have hmain : 2*64^4*((H:ℝ)+1)^5*(1+2*M)*B^4*(Real.exp S)^4/(κ^5*v^2)≤
      6*64^4*M*K^20 := by
    rw [he]
    calc
      _ ≤ 2*64^4*K^5*(3*M)*K^4*K^4*K^5*K^2 := by
        gcongr
        linarith
      _ = _ := by ring
  have hread : 64*M/κ^3≤64*M*K^20 := by
    calc
      _ = 64*M*(1/κ)^3 := by ring
      _ ≤ 64*M*K^3 := by gcongr
      _ ≤ _ := by gcongr
  have hlog0 : 0≤Real.log 2 := Real.log_nonneg (by norm_num)
  have hlog : Real.log 2≤1 := by
    have h := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at h ⊢
    exact h
  have hlast : 4*Real.log 2/τ≤4*M*K^20 := by
    calc
      _ = 4*Real.log 2*(1/τ) := by ring
      _ ≤ 4*1*K := by gcongr
      _ ≤ 4*M*K^20 := by nlinarith
  have hone : 1≤M*K^20 := by nlinarith
  unfold finiteChannelWidthBudget
  nlinarith

/-- One common polynomial envelope for the resources yields a single natural
power of R. The exponential factor is just the number of Boolean inputs. -/
theorem finiteChannelWidthBudget_polynomial {R M B S v κ τ : ℝ} {H p : ℕ}
    (hR : 2≤R) (hM : 1≤M) (hB0 : 0≤B) (hv : 0<v) (hκ : 0<κ) (hτ : 0<τ)
    (hH : (H:ℝ)+1≤R^p) (hB : B≤R^p) (hS : Real.exp S≤R^p)
    (hvR : 1/v≤R^p) (hκR : 1/κ≤R^p) (hτR : 1/τ≤R^p) :
    finiteChannelWidthBudget M H B S v κ τ≤M*R^(20*p+28) := by
  have hr : 1≤R := by linarith
  have hh := finiteChannelWidthBudget_envelope hM (one_le_pow₀ hr) hB0 hv hκ hτ
    hH hB hS hvR hκR hτR
  apply hh.trans
  have hp : (2:ℝ)^28≤R^28 := pow_le_pow_left₀ (by norm_num) hR _
  calc
    _ ≤ R^28*M*(R^p)^20 := by gcongr
    _ = _ := by rw [←pow_mul,pow_add,Nat.mul_comm p 20]; ring

#print axioms finiteChannelWidthBudget_polynomial
end ConditionalNonpolynomial.Analytic
