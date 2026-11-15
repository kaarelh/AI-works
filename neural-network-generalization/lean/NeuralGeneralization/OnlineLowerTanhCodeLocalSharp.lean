import NeuralGeneralization.OnlineLowerTanhCodeLocal
import NeuralGeneralization.OnlineLowerTanhCodeVanishingSharp
import Mathlib.Tactic.FieldSimp

/-! # Full finite local off-orientation estimate for actual tanh neurons -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

/-- Literal weighted Walsh mass of all retained competing orientations.
Only the inactive energy relative to one support is small; the bias and all
selected incoming weights are arbitrary. -/
theorem tanh_local_offmass_sharp {p R : ℕ} (size : Fin p → Bool → ℕ)
    (hR : 2 ≤ R) (hsize : ∀ i b, R ≤ size i b)
    (s : Fin p → Bool) (J : Finset (Fin p → Bool))
    (weight : (Fin p → Bool) → ℝ) (W : ℝ)
    (hw : ∀ t ∈ J, 0 ≤ weight t) (hW : ∀ t ∈ J, weight t ≤ W) (hW0 : 0 ≤ W)
    (u : Fin (carrierDimension size) → ℝ) (b τ ρ : ℝ)
    (hτ : 0 ≤ τ) (hτρ : τ ≤ ρ) (hρ : 0 < ρ)
    (henergy : (∑ i ∈ (carrierTransversal size s)ᶜ, u i^2) ≤ τ^2) :
    (∑ t ∈ J.erase s, weight t * |walshCoefficients
      (fun x => Real.tanh (b+incomingLinear u x)) (carrierTransversal size t)|) ≤
      (W*τ^2/ρ^2)*((1+(Real.sqrt ((p*R : ℕ) : ℝ)*ρ)^R)^p-1) := by
  let D : ℝ := Real.sqrt (p*R : ℕ)
  let x := (D*ρ)^R
  apply retained_switch_sum_bound s J _ (W*τ^2/ρ^2) x (by positivity) (by dsimp [x,D]; positivity)
  intro t ht
  have htJ : t ∈ J := Finset.mem_of_mem_erase ht
  have hts : t ≠ s := (Finset.mem_erase.mp ht).1
  let k := (changedRails s t).card * R
  have hk : 2 ≤ k := by
    have hc : 1 ≤ (changedRails s t).card := (changedRails_nonempty s t hts).card_pos
    dsimp [k]
    exact hR.trans (by nlinarith)
  have hki : k ≤ (carrierTransversal size t\carrierTransversal size s).card :=
    carrierTransversal_difference_card_lower size hsize s t
  have hD : (k : ℝ) ≤ (p*R : ℕ) := by
    dsimp [k]
    exact_mod_cast Nat.mul_le_mul_right R (changedRails_card_le s t)
  have hcoeff := tanh_walshCoefficient_inactive_energy_bound
    (carrierTransversal size s) (carrierTransversal size t) u b τ (p*R : ℕ) k hki hD hτ henergy
  calc
    _ ≤ weight t*(D*τ)^k := mul_le_mul_of_nonneg_left hcoeff (hw t htJ)
    _ ≤ W*(D*τ)^k := mul_le_mul_of_nonneg_right (hW t htJ) (by dsimp [D]; positivity)
    _ ≤ (W*τ^2/ρ^2)*(D*ρ)^k := weighted_power_quadratic D τ ρ W k
      (by dsimp [D]; positivity) hτ hτρ hρ hW0 hk
    _ = (W*τ^2/ρ^2)*x^(changedRails s t).card := by
      dsimp [x,k]
      rw [← pow_mul]
      congr 2
      exact Nat.mul_comm _ _

/-- Small-base simplification of the actual local offmass bound. -/
theorem tanh_local_offmass_sharp_small {p R : ℕ} (size : Fin p → Bool → ℕ)
    (hR : 2 ≤ R) (hsize : ∀ i b, R ≤ size i b)
    (s : Fin p → Bool) (J : Finset (Fin p → Bool))
    (weight : (Fin p → Bool) → ℝ) (W : ℝ)
    (hw : ∀ t ∈ J, 0 ≤ weight t) (hW : ∀ t ∈ J, weight t ≤ W) (hW0 : 0 ≤ W)
    (u : Fin (carrierDimension size) → ℝ) (b τ ρ : ℝ)
    (hτ : 0 ≤ τ) (hτρ : τ ≤ ρ) (hρ : 0 < ρ)
    (henergy : (∑ i ∈ (carrierTransversal size s)ᶜ, u i^2) ≤ τ^2)
    (hsmall : (p : ℝ)*((Real.sqrt ((p*R : ℕ) : ℝ)*ρ)^R) ≤ 1/2) :
    (∑ t ∈ J.erase s, weight t * |walshCoefficients
      (fun x => Real.tanh (b+incomingLinear u x)) (carrierTransversal size t)|) ≤
      2*W*(p : ℝ)*((Real.sqrt ((p*R : ℕ) : ℝ)*ρ)^R)/ρ^2*τ^2 := by
  have h := tanh_local_offmass_sharp size hR hsize s J weight W hw hW hW0 u b τ ρ hτ hτρ hρ henergy
  have hb := local_switch_sum_bound ((Real.sqrt ((p*R : ℕ) : ℝ)*ρ)^R) p (by positivity) hsmall
  have hm := mul_le_mul_of_nonneg_left hb (show 0 ≤ W*τ^2/ρ^2 by positivity)
  apply h.trans
  convert hm using 1 <;> ring

/-- The manuscript local constant, in an algebraically equivalent square-root
form; the proof actually gives the smaller base sqrt(D)/D². -/
theorem tanh_local_offmass_paper {p R : ℕ} (hp : 1≤p) (hR : 2≤R)
    (size : Fin p → Bool → ℕ) (hsize : ∀i b,R≤size i b)
    (s : Fin p→Bool) (J : Finset (Fin p→Bool))
    (weight : (Fin p→Bool)→ℝ) (W : ℝ)
    (hw : ∀t∈J,0≤weight t) (hW : ∀t∈J,weight t≤W) (hW0 : 0≤W)
    (u : Fin (carrierDimension size)→ℝ) (b τ : ℝ)
    (hτ : 0≤τ) (hτρ : τ≤(((p*R:ℕ):ℝ)^2)⁻¹)
    (henergy : (∑i∈(carrierTransversal size s)ᶜ,u i^2)≤τ^2) :
    (∑t∈J.erase s,weight t*|walshCoefficients
      (fun x=>Real.tanh (b+incomingLinear u x)) (carrierTransversal size t)|) ≤
      2*W*(p:ℝ)*((p*R:ℕ):ℝ)^4*
        (4*Real.sqrt ((p*R:ℕ):ℝ)/(Real.pi*((p*R:ℕ):ℝ)^2))^R*τ^2 := by
  let D:ℝ:=(p*R:ℕ)
  have hD2:(2:ℝ)≤D := by dsimp [D];exact_mod_cast (show 2≤p*R by nlinarith)
  have hpD:2*(p:ℝ)≤D := by dsimp [D];exact_mod_cast (show 2*p≤p*R by nlinarith)
  have hDp:0<D:=by linarith
  have hbase:0≤Real.sqrt D*(D^2)⁻¹:=by positivity
  have hsD:Real.sqrt D≤D:=by nlinarith [Real.sq_sqrt hDp.le,Real.sqrt_nonneg D]
  have hbaseD:Real.sqrt D*(D^2)⁻¹≤D⁻¹ := by
    rw [←div_eq_mul_inv]
    apply (div_le_iff₀ (by positivity : 0<D^2)).mpr
    calc
      _ ≤ D:=hsD
      _ = _ := by field_simp <;> ring
  have hDinv:D⁻¹≤1:=by exact inv_le_one_of_one_le₀ (by linarith)
  have hpow:(Real.sqrt D*(D^2)⁻¹)^R≤(D⁻¹)^2:=by
    exact (pow_le_pow_left₀ hbase hbaseD R).trans
      (pow_le_pow_of_le_one (by positivity) hDinv hR)
  have hsmall:(p:ℝ)*(Real.sqrt D*(D^2)⁻¹)^R≤1/2:=by
    calc
      _ ≤ (p:ℝ)*(D⁻¹)^2:=mul_le_mul_of_nonneg_left hpow (by positivity)
      _ ≤ 1/2:=by
        rw [inv_pow,←div_eq_mul_inv]
        apply (div_le_iff₀ (by positivity : 0<D^2)).mpr
        nlinarith
  have hh:=tanh_local_offmass_sharp_small size hR hsize s J weight W hw hW hW0
    u b τ ((D^2)⁻¹) hτ hτρ (by positivity) henergy hsmall
  have hratio:Real.sqrt D*(D^2)⁻¹≤4*Real.sqrt D/(Real.pi*D^2):=by
    have hpi:Real.pi≤4:=Real.pi_le_four
    apply (le_div_iff₀ (mul_pos Real.pi_pos (sq_pos_of_pos hDp))).mpr
    have hid:(Real.sqrt D*(D^2)⁻¹)*(Real.pi*D^2)=Real.sqrt D*Real.pi:=by field_simp <;> ring
    rw [hid]
    nlinarith [Real.sqrt_nonneg D]
  have hpowers:=pow_le_pow_left₀ hbase hratio R
  have hconvert:2*W*(p:ℝ)*(Real.sqrt D*(D^2)⁻¹)^R/((D^2)⁻¹)^2*τ^2 =
      2*W*(p:ℝ)*D^4*(Real.sqrt D*(D^2)⁻¹)^R*τ^2:=by field_simp <;> ring
  change _≤2*W*(p:ℝ)*D^4*(4*Real.sqrt D/(Real.pi*D^2))^R*τ^2
  apply hh.trans
  rw [hconvert]
  gcongr


end NeuralGeneralization.OnlineLowerTanh
