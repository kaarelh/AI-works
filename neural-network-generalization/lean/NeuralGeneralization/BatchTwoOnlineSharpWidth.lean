import NeuralGeneralization.BatchTwoOnlineSharpCompression
import NeuralGeneralization.BatchTwoOnlineSharpUnion

/-! The exact width in the online appendix satisfies the actual retained-row
union bound; the maximum with the energy cap causes no extra cost. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
namespace NeuralGeneralization.BatchTwoOnlineSharp

def normSamplingWidthReal (d r : ℕ) (K : ℝ) : ℝ :=
  256*(normRho r K)⁻¹^4*((d:ℝ)+Real.log (((r:ℝ)+2)/normRho r K))

theorem normSamplingWidthReal_ge_energy {d r : ℕ} {K : ℝ} (hd : 1≤d) (hK : 1≤K) :
    9*K≤normSamplingWidthReal d r K := by
  have hρ:=normRho_pos (r:=r) hK
  have hρ1:=normRho_le_one_twentyfour (r:=r) hK
  have hdR:(1:ℝ)≤d:=by exact_mod_cast hd
  have hr0:(0:ℝ)≤r:=Nat.cast_nonneg _
  have hs:1≤Real.sqrt K:=(Real.one_le_sqrt).mpr hK
  have hsp:Real.sqrt K≤(Real.sqrt K)^(r+1):=by
    simpa only [pow_one] using pow_le_pow_right₀ hs (show 1≤r+1 by omega)
  have h2:1≤(2:ℝ)^(r+2):=one_le_pow₀ (by norm_num)
  have hi:Real.sqrt K≤(normRho r K)⁻¹:=by
    simp only [normRho,inv_inv]
    have hf:1≤12*((r:ℝ)+1)*(2:ℝ)^(r+2):=by nlinarith
    exact hsp.trans (le_mul_of_one_le_left (by positivity) hf)
  have hpow:K^2≤(normRho r K)⁻¹^4:=by
    have hh:=pow_le_pow_left₀ (Real.sqrt_nonneg K) hi 4
    have he:(Real.sqrt K)^4=K^2:=by rw [show 4=2*2 by norm_num,pow_mul,Real.sq_sqrt (by linarith)]
    rwa [he] at hh
  have hlog:0≤Real.log (((r:ℝ)+2)/normRho r K):=
    Real.log_nonneg ((one_le_div hρ).mpr (by linarith))
  have hsum:1≤(d:ℝ)+Real.log (((r:ℝ)+2)/normRho r K):=by linarith
  have hh:=mul_le_mul hpow hsum (by norm_num : (0:ℝ)≤1) (by positivity : 0≤(normRho r K)⁻¹^4)
  dsimp [normSamplingWidthReal]
  nlinarith

theorem normWidth_eq_ceil {d r : ℕ} {K : ℝ} (hd : 1≤d) (hK : 1≤K) :
    normWidth d r K=⌈normSamplingWidthReal d r K⌉₊ := by
  apply max_eq_right
  exact Nat.ceil_mono (normSamplingWidthReal_ge_energy (r:=r) hd hK)

theorem normWidth_ge_energy (d r : ℕ) (K : ℝ) : 9*K≤(normWidth d r K:ℝ) := by
  have hh:⌈9*K⌉₊≤normWidth d r K:=le_max_left _ _
  exact (Nat.le_ceil (9*K)).trans (by exact_mod_cast hh)

theorem normWidth_pos {d r : ℕ} {K : ℝ} (hK : 1≤K) : 0<normWidth d r K := by
  have hh:=normWidth_ge_energy d r K
  have hp:(0:ℝ)<normWidth d r K:=by linarith
  exact_mod_cast hp

theorem normWidth_row_bound {d r : ℕ} {K : ℝ} (hd : 1≤d) (hK : 1≤K) :
    (((r:ℝ)*(normWidth d r K)+1)*2^d*(2*Real.exp (-(normRho r K)^4*(normWidth d r K:ℝ)/32)))≤1/4 := by
  have hA:0≤normSamplingWidthReal d r K:=by
    have hh:=normSamplingWidthReal_ge_energy (r:=r) hd hK
    linarith
  have hlo:normSamplingWidthReal d r K≤(normWidth d r K:ℝ):=by
    rw [normWidth_eq_ceil hd hK]
    exact Nat.le_ceil _
  have hhi:(normWidth d r K:ℝ)≤normSamplingWidthReal d r K+1:=by
    rw [normWidth_eq_ceil hd hK]
    exact (Nat.ceil_lt_add_one hA).le
  have hh:=BatchTwoOnline.sharp_retained_union_bound (L:=r+2) hd (by omega) (normRho_pos hK)
    (normRho_le_one_twentyfour hK) (by simpa only [normSamplingWidthReal,Nat.cast_add,Nat.cast_ofNat] using hlo)
    (by simpa only [normSamplingWidthReal,Nat.cast_add,Nat.cast_ofNat] using hhi)
  convert hh using 1 <;> push_cast <;> ring

end NeuralGeneralization.BatchTwoOnlineSharp
