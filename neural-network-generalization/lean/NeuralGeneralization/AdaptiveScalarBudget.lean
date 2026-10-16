import NeuralGeneralization.AdaptiveDimensionCutoff
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-! Elementary scalar budgets after adaptive binomial cancellation. These
inequalities retain the literal comparator, Gram and spectral quantities. -/
noncomputable section
namespace NeuralGeneralization.AdaptiveCutoff

lemma rpow_weight_ratio {d r β : ℝ} (hr : 0<r) (hrd : r≤d) (hβ : β≤1) :
    d^β*r^(-β)≤d/r := by
  have hd : 0<d := hr.trans_le hrd
  rw [Real.rpow_neg hr.le,←div_eq_mul_inv,←Real.div_rpow hd.le hr.le]
  have hh := Real.rpow_le_rpow_of_exponent_le ((le_div_iff₀ hr).mpr (by simpa using hrd)) hβ
  simpa only [Real.rpow_one] using hh

lemma weighted_gram_bound {d r L C G W T : ℝ}
    (hd : 0<d) (hr : 0<r) (hL : 0≤L) (hC : 0≤C)
    (hW : 0≤W) (hT : 0≤T) (hWT : W*T≤d/r)
    (hG : G≤C*T*(1+Real.sqrt (d*L)/r+L/r)) :
    r^2*G*W≤C*d*(r+Real.sqrt (d*L)+L) := by
  have hfactor : 0≤1+Real.sqrt (d*L)/r+L/r := by positivity
  have hg := mul_le_mul_of_nonneg_right hG (mul_nonneg (sq_nonneg r) hW)
  have hw := mul_le_mul_of_nonneg_left hWT
    (mul_nonneg (mul_nonneg (sq_nonneg r) hC) hfactor)
  have he : r^2*C*(1+Real.sqrt (d*L)/r+L/r)*(d/r)=
      C*d*(r+Real.sqrt (d*L)+L) := by field_simp <;> ring
  nlinarith only [hg,hw,he]

lemma weighted_eigenvalue_bound {d r L C n ell W T : ℝ}
    (hr : 0<r) (hL : 0≤L) (hC : 0≤C) (hW : 0≤W)
    (hWT : W*T≤d/r) (hell : n*ell≤C*L*T/r) :
    r^2*n*ell*W≤C*d*L := by
  have hh := mul_le_mul_of_nonneg_right hell (mul_nonneg (sq_nonneg r) hW)
  have hw := mul_le_mul_of_nonneg_left hWT (show 0≤r*C*L by positivity)
  have he : (C*L*T/r)*(r^2*W)=r*C*L*(W*T) := by field_simp <;> ring
  have he' : r*C*L*(d/r)=C*d*L := by field_simp <;> ring
  nlinarith only [hh,hw,he,he']

/-- The normalized head error is controlled by r/d and sqrt(log(8n)/d),
without entropy inversion or a lower bound on r/d. -/
theorem head_budget_of_scaled_bounds {d r u n L C G B ell W T ε : ℝ}
    (hd : 0<d) (hr : 0<r) (hn : 0<n) (hL : 0≤L) (hC : 0≤C)
    (hu : 0≤u) (hur : u≤2*r) (hG0 : 0≤G) (hell0 : 0≤ell)
    (hW : 0≤W) (hT : 0≤T) (hB0 : 0≤B)
    (hWT : W*T≤d/r)
    (hG : G≤C*T*(1+Real.sqrt (d*L)/r+L/r))
    (hell : n*ell≤C*L*T/r) (hB : B≤C*n*W)
    (hε0 : 0≤ε) (hε1 : ε≤1) (hrsmall : r≤ε*d) (hLsmall : L≤ε^2*d) :
    u^2*(4*G*B/n+ell*B)≤60*C^2*ε*d^2 := by
  have hg := weighted_gram_bound hd hr hL hC hW hT hWT hG
  have he := weighted_eigenvalue_bound hr hL hC hW hWT hell
  have hBn : B/n≤C*W := by
    apply (div_le_iff₀ hn).mpr
    nlinarith only [hB]
  have hcore : r^2*(4*G*B/n+ell*B)≤C^2*d*(4*r+4*Real.sqrt (d*L)+5*L) := by
    have h1 := mul_le_mul_of_nonneg_left hBn (show 0≤4*r^2*G by positivity)
    have h2 := mul_le_mul_of_nonneg_left hB (show 0≤r^2*ell by positivity)
    have h3 := mul_le_mul_of_nonneg_left hg (show 0≤4*C by positivity)
    have h4 := mul_le_mul_of_nonneg_left he hC
    have hid : 4*r^2*G*(B/n)+r^2*ell*B=r^2*(4*G*B/n+ell*B) := by ring
    nlinarith only [h1,h2,h3,h4,hid]
  have hu2 : u^2≤4*r^2 := by nlinarith only [hu,hur,hr]
  have hcore0 : 0≤4*G*B/n+ell*B := by positivity
  have hpre := (mul_le_mul_of_nonneg_right hu2 hcore0).trans
    (show 4*r^2*(4*G*B/n+ell*B)≤4*(C^2*d*(4*r+4*Real.sqrt (d*L)+5*L)) by
      nlinarith only [hcore])
  have hsqrt : Real.sqrt (d*L)≤ε*d := by
    apply (Real.sqrt_le_left (by positivity : 0≤ε*d)).mpr
    have hh := mul_le_mul_of_nonneg_left hLsmall hd.le
    nlinarith only [hh]
  have hLe : L≤ε*d := by
    have hh := mul_le_mul_of_nonneg_left hε1 (mul_nonneg hε0 hd.le)
    nlinarith only [hLsmall,hh]
  have hsum : 4*r+4*Real.sqrt (d*L)+5*L≤15*ε*d := by linarith only [hrsmall,hsqrt,hLe,mul_nonneg hε0 hd.le]
  have hh := mul_le_mul_of_nonneg_left hsum (show 0≤4*C^2*d by positivity)
  nlinarith only [hpre,hh]

end NeuralGeneralization.AdaptiveCutoff
