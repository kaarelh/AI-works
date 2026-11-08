import NeuralGeneralization.OnlineLowerTanhCodePhysicalPhases
import NeuralGeneralization.OnlineLowerTanhCodeSwitches

/-! # Binomial-shell suppression for actual physical competing orientations -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

/-- The actual product of an orientation differing in j rails is at most
exp(-a*j*R/2), uniformly up to a constant times sqrt R in frequency. -/
theorem carrier_switch_product_bound {p R : ℕ} (hp:0<p) (hRpos:0<R)
    (size : Fin p→Bool→ℕ) (hR:∀i s,R≤size i s)
    (u : Fin (carrierDimension size)→ℝ) (old new : Fin p→Bool) (hne:new≠old)
    (s t h μ K a b : ℝ) (hs : h≤s) (hh:0<h) (ht:0≤t)
    (hμ:0<μ) (hμ1:μ≤1) (hK:0<K) (ha:0<a) (hb:0≤b)
    (hpeak:μ≤|trigProduct (carrierTransversal size old) (fun j=>s*u j)|)
    (henergy:8*s^2*incomingEnergy u/Real.pi^2-4*Real.log μ≤K*(p*R:ℕ))
    (hKa:8*K*a≤1) (hba:b^2*(-2*Real.log μ)≤h^2*a)
    (htR:t≤b*Real.sqrt (R:ℝ)) :
    |trigProduct (carrierTransversal size new) (fun j=>t*u j)|≤
      (Real.exp (-a*(R:ℝ)/2))^(changedRails old new).card := by
  let j : ℕ := (changedRails old new).card
  have hj : 1≤j := Finset.card_pos.mpr (changedRails_nonempty old new hne)
  have hjR : (R:ℝ)≤((j*R:ℕ):ℝ) := by exact_mod_cast Nat.le_mul_of_pos_left R hj
  have hD : (0:ℝ)<(p*R:ℕ) := by positivity
  have hspos : 0<s := hh.trans_le hs
  have hdelta : 0≤-2*Real.log μ := by
    have hl := Real.log_nonpos hμ.le hμ1
    linarith
  have hcard : 8*(K*(p*R:ℕ))*(a*(j*R:ℕ))≤
      (((carrierTransversal size old\carrierTransversal size new).card:ℕ):ℝ)*
        ((carrierTransversal size new).card:ℝ) := by
    apply le_trans ?_ (carrierTransversal_determinant_mass size hR old new)
    have hm := mul_le_mul_of_nonneg_right hKa (show 0≤((j*R:ℕ):ℝ)*(p*R:ℕ) by positivity)
    dsimp [j] at *
    nlinarith only [hm]
  have hshift : (t/s)^2*(-2*Real.log μ)≤a*(j*R:ℕ) := by
    have ht2 := pow_le_pow_left₀ ht htR 2
    rw [mul_pow,Real.sq_sqrt (by positivity : (0:ℝ)≤R)] at ht2
    have hm := mul_le_mul_of_nonneg_right ht2 hdelta
    have hbR := mul_le_mul_of_nonneg_right hba (show (0:ℝ)≤R by positivity)
    have hhs := pow_le_pow_left₀ hh.le hs 2
    have hhR := mul_le_mul_of_nonneg_right hhs (show 0≤a*(R:ℝ) by positivity)
    have hfirst : t^2*(-2*Real.log μ)≤s^2*a*(R:ℝ) := by nlinarith only [hm,hbR,hhR]
    have hlast := mul_le_mul_of_nonneg_left hjR (show 0≤s^2*a by positivity)
    rw [div_pow,div_mul_eq_mul_div]
    apply (div_le_iff₀ (sq_pos_of_pos hspos)).mpr
    nlinarith only [hfirst,hlast]
  have hmain := physical_trig_product_localization (carrierTransversal size old)
    (carrierTransversal size new) u s t μ (K*(p*R:ℕ)) (a*(j*R:ℕ)) hspos.ne' hμ
    (mul_pos hK hD) hpeak henergy hcard hshift
  have hexp : Real.exp (-(a*(j*R:ℕ))/2)=(Real.exp (-a*(R:ℝ)/2))^j := by
    rw [←Real.exp_nat_mul]
    congr 1
    push_cast
    ring
  rwa [hexp] at hmain

/-- Summation counts switched rail sets, not all codewords independently.
This is the exact finite binomial shell expression used by localization. -/
theorem carrier_switch_sum_bound {p R : ℕ} (hp:0<p) (hRpos:0<R)
    (size : Fin p→Bool→ℕ) (hR:∀i s,R≤size i s)
    (u : Fin (carrierDimension size)→ℝ) (old : Fin p→Bool)
    (A : Finset (Fin p→Bool)) (s t h μ K a b : ℝ) (hs:h≤s) (hh:0<h) (ht:0≤t)
    (hμ:0<μ) (hμ1:μ≤1) (hK:0<K) (ha:0<a) (hb:0≤b)
    (hpeak:μ≤|trigProduct (carrierTransversal size old) (fun j=>s*u j)|)
    (henergy:8*s^2*incomingEnergy u/Real.pi^2-4*Real.log μ≤K*(p*R:ℕ))
    (hKa:8*K*a≤1) (hba:b^2*(-2*Real.log μ)≤h^2*a)
    (htR:t≤b*Real.sqrt (R:ℝ)) :
    (∑θ∈A.erase old,|trigProduct (carrierTransversal size θ) (fun j=>t*u j)|)≤
      (1+Real.exp (-a*(R:ℝ)/2))^p-1 := by
  have hh' := retained_switch_sum_bound old A
    (fun θ=>|trigProduct (carrierTransversal size θ) (fun j=>t*u j)|)
    1 (Real.exp (-a*(R:ℝ)/2)) (by norm_num) (Real.exp_pos _).le (by
      intro θ hθ
      simpa only [one_mul] using carrier_switch_product_bound hp hRpos size hR u old θ
        (Finset.mem_erase.mp hθ).1 s t h μ K a b hs hh ht hμ hμ1 hK ha hb hpeak henergy hKa hba htR)
  simpa only [one_mul] using hh'

end NeuralGeneralization.OnlineLowerTanh
