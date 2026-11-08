import NeuralGeneralization.OnlineLowerTanhCodeLaplaceProduct
import Mathlib.Analysis.MeanInequalities

/-! # Actual small-frequency control for rail products -/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

theorem prod_abs_le_norm_scale_pow {ι : Type*} [Fintype ι]
    (hn : 0<Fintype.card ι) (u : ι→ℝ) (z : ℝ) (hz : 0≤z)
    (he : (∑ i,u i^2)≤Fintype.card ι*z^2) :
    (∏ i,|u i|)≤z^Fintype.card ι := by
  have hn0 : (Fintype.card ι:ℝ)≠0 := by positivity
  have hweights : (∑ _ : ι,(Fintype.card ι:ℝ)⁻¹)=1 := by simp [hn0]
  have hh := Real.geom_mean_le_arith_mean_weighted Finset.univ
    (fun _ : ι => (Fintype.card ι:ℝ)⁻¹) (fun i => u i^2)
    (fun _ _ => by positivity) hweights (fun _ _ => sq_nonneg _)
  have hp := pow_le_pow_left₀
    (Finset.prod_nonneg (fun i _ => Real.rpow_nonneg (sq_nonneg (u i)) _)) hh (Fintype.card ι)
  rw [←Finset.prod_pow] at hp
  simp_rw [Real.rpow_inv_natCast_pow (sq_nonneg _) (Nat.ne_of_gt hn)] at hp
  have hmean : (∑ i,(Fintype.card ι:ℝ)⁻¹*u i^2)≤z^2 := by
    rw [←Finset.mul_sum,inv_mul_eq_div,div_le_iff₀ (by positivity : (0:ℝ)<Fintype.card ι)]
    simpa only [mul_comm] using he
  have htop := pow_le_pow_left₀
    (Finset.sum_nonneg fun i _ => mul_nonneg (by positivity) (sq_nonneg _)) hmean (Fintype.card ι)
  have hh2 := hp.trans htop
  have hprod : (∏ i,|u i|)^2=∏ i,u i^2 := by rw [←Finset.prod_pow];simp only [sq_abs]
  have hpow : (z^Fintype.card ι)^2=(z^2)^Fintype.card ι := by rw [←pow_mul,←pow_mul,Nat.mul_comm]
  have hp0 : 0≤∏ i,|u i| := Finset.prod_nonneg fun _ _ => abs_nonneg _
  have hz0 := pow_nonneg hz (Fintype.card ι)
  nlinarith

theorem trimmedRailProduct_le_one (p R : ℕ) (hR : 0<R)
    (a b : Fin p→Fin R→ℝ) (t : ℝ) : trimmedRailProduct p R a b t ≤ 1 := by
  apply Finset.prod_le_one
  · intro i _; positivity
  · intro i _
    have hh := Finset.prod_add_prod_le (s:=Finset.univ) (i:=(⟨0,hR⟩:Fin R))
      (f:=fun _=> (1:ℝ))
      (g:=fun k=>|Real.sin (a i k*t)| *|Real.cos (b i k*t)|)
      (h:=fun k=>|Real.cos (a i k*t)| *|Real.sin (b i k*t)|)
      (Finset.mem_univ _) (sine_cosine_pair_le_one _ _)
      (fun k _ _ => mul_le_one₀ (Real.abs_sin_le_one _) (abs_nonneg _) (Real.abs_cos_le_one _))
      (fun k _ _ => mul_le_one₀ (Real.abs_cos_le_one _) (abs_nonneg _) (Real.abs_sin_le_one _))
      (fun _ _=>by positivity) (fun _ _=>by positivity)
    simpa using hh

def selectedRailTerm (p R : ℕ) (a b : Fin p→Fin R→ℝ)
    (θ : Fin p→Bool) (t : ℝ) : ℝ :=
  ∏ i, ∏ k, if θ i then |Real.cos (a i k*t)| *|Real.sin (b i k*t)|
    else |Real.sin (a i k*t)| *|Real.cos (b i k*t)|

theorem trimmedRailProduct_expansion (p R : ℕ) (a b : Fin p→Fin R→ℝ) (t : ℝ) :
    trimmedRailProduct p R a b t = ∑ θ : Fin p→Bool,selectedRailTerm p R a b θ t := by
  have hh := Fintype.prod_sum (fun (i : Fin p) (s : Bool) =>
    ∏ k,if s then |Real.cos (a i k*t)| *|Real.sin (b i k*t)|
      else |Real.sin (a i k*t)| *|Real.cos (b i k*t)|)
  simpa only [Fintype.sum_bool,Bool.false_eq_true,if_false,if_true,trimmedRailProduct,
    selectedRailTerm,add_comm] using hh

/-- Every orientation has degree pR. AM--GM uses the total rail energy,
so no individual incoming coordinate needs to be bounded. -/
theorem selectedRailTerm_near_zero (p R : ℕ) (hp : 0<p) (hR : 0<R)
    (a b : Fin p→Fin R→ℝ) (θ : Fin p→Bool) (t z : ℝ) (ht : 0≤t) (hz : 0≤z)
    (he : (∑ i : Fin p,∑ k : Fin R,((a i k)^2+(b i k)^2))≤(p*R:ℕ)*z^2) :
    selectedRailTerm p R a b θ t ≤ (z*t)^(p*R) := by
  let u : Fin p × Fin R→ℝ := fun j=>if θ j.1 then b j.1 j.2 else a j.1 j.2
  have heu : (∑ j,u j^2)≤Fintype.card (Fin p × Fin R)*z^2 := by
    simp only [Fintype.sum_prod_type,Fintype.card_prod,Fintype.card_fin]
    apply le_trans (Finset.sum_le_sum fun i _=> Finset.sum_le_sum fun k _=>?_) he
    dsimp [u]
    split <;> nlinarith [sq_nonneg (a i k),sq_nonneg (b i k)]
  have hu := prod_abs_le_norm_scale_pow (ι:=Fin p × Fin R) (by simp; omega) u z hz heu
  have hbnd : selectedRailTerm p R a b θ t ≤ ∏ j : Fin p × Fin R,t*|u j| := by
    rw [Fintype.prod_prod_type]
    apply Finset.prod_le_prod
    · intro i _; exact Finset.prod_nonneg fun k _=>by split <;> positivity
    · intro i _
      apply Finset.prod_le_prod
      · intro k _; split <;> positivity
      · intro k _
        dsimp [u]
        split
        · have hs : |Real.sin (b i k*t)|≤t*|b i k| :=
            Real.abs_sin_le_abs.trans (by rw [abs_mul,abs_of_nonneg ht,mul_comm])
          exact (mul_le_of_le_one_left (abs_nonneg _) (Real.abs_cos_le_one _)).trans hs
        · have hs : |Real.sin (a i k*t)|≤t*|a i k| :=
            Real.abs_sin_le_abs.trans (by rw [abs_mul,abs_of_nonneg ht,mul_comm])
          exact (mul_le_of_le_one_right (abs_nonneg _) (Real.abs_cos_le_one _)).trans hs
  calc
    _ ≤ ∏ j : Fin p × Fin R,t*|u j| := hbnd
    _ = t^(p*R)*∏ j,|u j| := by simp [Finset.prod_mul_distrib]
    _ ≤ t^(p*R)*z^(p*R) := by
      simpa only [Fintype.card_prod,Fintype.card_fin] using mul_le_mul_of_nonneg_left hu (pow_nonneg ht (p*R))
    _ = (z*t)^(p*R) := by rw [mul_pow,mul_comm]

theorem trimmedRailProduct_near_zero (p R : ℕ) (hp : 0<p) (hR : 0<R)
    (a b : Fin p→Fin R→ℝ) (t z : ℝ) (ht : 0≤t) (hz : 0≤z)
    (he : (∑ i : Fin p,∑ k : Fin R,((a i k)^2+(b i k)^2))≤(p*R:ℕ)*z^2) :
    trimmedRailProduct p R a b t ≤ 2^p*(z*t)^(p*R) := by
  rw [trimmedRailProduct_expansion]
  have hh := Finset.sum_le_sum (fun θ (_:θ∈Finset.univ)=>selectedRailTerm_near_zero p R hp hR a b θ t z ht hz he)
  simpa using hh


lemma bounded_power_le_linear (F x : ℝ) (D : ℕ) (hD : 1≤D)
    (hx : 0≤x) (hF1 : F≤1) (hFp : F≤x^D) : F≤x := by
  by_cases h : x≤1
  · exact hFp.trans (by simpa using pow_le_pow_of_le_one hx h hD)
  · exact hF1.trans (le_of_not_ge h)

lemma bounded_power_sqrt_cubic (F x : ℝ) (D : ℕ) (hD : 6≤D)
    (hF : 0≤F) (hx : 0≤x) (hF1 : F≤1) (hFp : F≤x^D) : Real.sqrt F≤x^3 := by
  have hs := Real.sq_sqrt hF
  have hsr := Real.sqrt_nonneg F
  have hx3 := pow_nonneg hx 3
  by_cases h : x≤1
  · have hpow : F≤x^6 := hFp.trans (pow_le_pow_of_le_one hx h hD)
    have hid : x^6=(x^3)^2 := by ring
    rw [hid] at hpow
    nlinarith
  · have hx1 : 1≤x := (le_of_not_ge h)
    have hxpow : 1≤x^3 := one_le_pow₀ hx1
    nlinarith

theorem trimmedRailProduct_near_zero_scaled (p R : ℕ) (hp : 0<p) (hR : 0<R)
    (a b : Fin p→Fin R→ℝ) (t z : ℝ) (ht : 0≤t) (hz : 0≤z)
    (he : (∑ i : Fin p,∑ k : Fin R,((a i k)^2+(b i k)^2))≤(p*R:ℕ)*z^2) :
    trimmedRailProduct p R a b t ≤ (2*z*t)^(p*R) := by
  have hn : p≤p*R := by nlinarith
  have hpow : (2:ℝ)^p≤2^(p*R) := pow_le_pow_right₀ (by norm_num) hn
  calc
    _ ≤ 2^p*(z*t)^(p*R) := trimmedRailProduct_near_zero p R hp hR a b t z ht hz he
    _ ≤ 2^(p*R)*(z*t)^(p*R) := mul_le_mul_of_nonneg_right hpow (by positivity)
    _ = (2*z*t)^(p*R) := by rw [←mul_pow];congr 1;ring

theorem trimmedRailProduct_linear (p R : ℕ) (hp : 0<p) (hR : 0<R)
    (a b : Fin p→Fin R→ℝ) (t z : ℝ) (ht : 0≤t) (hz : 0≤z)
    (he : (∑ i : Fin p,∑ k : Fin R,((a i k)^2+(b i k)^2))≤(p*R:ℕ)*z^2) :
    trimmedRailProduct p R a b t ≤ 2*z*t :=
  bounded_power_le_linear _ _ (p*R) (by nlinarith) (by positivity)
    (trimmedRailProduct_le_one p R hR a b t)
    (trimmedRailProduct_near_zero_scaled p R hp hR a b t z ht hz he)

theorem sqrt_trimmedRailProduct_cubic (p R : ℕ) (hp : 0<p) (hR : 0<R)
    (hD : 6≤p*R) (a b : Fin p→Fin R→ℝ) (t z : ℝ) (ht : 0≤t) (hz : 0≤z)
    (he : (∑ i : Fin p,∑ k : Fin R,((a i k)^2+(b i k)^2))≤(p*R:ℕ)*z^2) :
    Real.sqrt (trimmedRailProduct p R a b t) ≤ 8*z^3*t^3 := by
  have hh := bounded_power_sqrt_cubic _ _ (p*R) hD
    (trimmedRailProduct_nonneg p R a b t) (by positivity)
    (trimmedRailProduct_le_one p R hR a b t)
    (trimmedRailProduct_near_zero_scaled p R hp hR a b t z ht hz he)
  convert hh using 1 <;> ring

end NeuralGeneralization.OnlineLowerTanh
