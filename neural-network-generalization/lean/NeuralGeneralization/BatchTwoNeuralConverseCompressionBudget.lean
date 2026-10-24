import NeuralGeneralization.BatchTwoHilbertBernstein
import Mathlib.Analysis.Complex.ExponentialBounds

/-! The exact width budget and numerical union bound for the depth-polynomial
neural mistake converse. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoNeuralConverse

def compressionWidth (d r : ℕ) (K ρ : ℝ) : ℕ :=
  ⌈256*K/ρ^2*((d : ℝ)+Real.log (400*((r : ℝ)+2)))⌉₊

theorem compressionWidth_lower {d r : ℕ} {K ρ : ℝ} :
    256*K/ρ^2*((d : ℝ)+Real.log (400*((r : ℝ)+2))) ≤
      (compressionWidth d r K ρ : ℝ) := Nat.le_ceil _

theorem compressionWidth_resources {d r : ℕ} (hd : 1 ≤ d) {K ρ : ℝ}
    (hK : 1 ≤ K) (hρ : 0 < ρ) (hρ6 : ρ ≤ 1/6) :
    0 < compressionWidth d r K ρ ∧ 16*K ≤ (compressionWidth d r K ρ : ℝ) := by
  have hd1 : (1 : ℝ)≤d := by exact_mod_cast hd
  have hlog : 0≤Real.log (400*((r : ℝ)+2)) := Real.log_nonneg (by nlinarith [Nat.cast_nonneg (α:=ℝ) r])
  have hS : 1≤(d : ℝ)+Real.log (400*((r : ℝ)+2)) := by linarith
  have hρsq : ρ^2≤1 := by nlinarith only [hρ,hρ6]
  have hmain := compressionWidth_lower (d:=d) (r:=r) (K:=K) (ρ:=ρ)
  have hb : 16*K ≤ 256*K/ρ^2*((d : ℝ)+Real.log (400*((r : ℝ)+2))) := by
    calc
      _ ≤ 256*K := by nlinarith only [hK]
      _ ≤ 256*K/ρ^2 := (le_div_iff₀ (sq_pos_of_pos hρ)).mpr (by nlinarith only [hρsq,hK])
      _ ≤ _ := le_mul_of_one_le_right (by positivity) hS
  have hh := hb.trans hmain
  exact ⟨by exact_mod_cast (lt_of_lt_of_le (by nlinarith only [hK] : (0 : ℝ)<16*K) hh),hh⟩

theorem compressionWidth_exponent {d r : ℕ} {K ρ : ℝ}
    (hK : 0 < K) (hρ : 0 < ρ) :
    2*((d : ℝ)+Real.log (400*((r : ℝ)+2))) ≤
      (compressionWidth d r K ρ : ℝ)*ρ^2/(128*K) := by
  have h := mul_le_mul_of_nonneg_right (compressionWidth_lower (d:=d) (r:=r) (K:=K) (ρ:=ρ))
    (show 0≤ρ^2/(128*K) by positivity)
  have he : (256*K/ρ^2*((d : ℝ)+Real.log (400*((r : ℝ)+2))))*(ρ^2/(128*K)) =
      2*((d : ℝ)+Real.log (400*((r : ℝ)+2))) := by field_simp; ring
  rw [he] at h
  simpa only [mul_div_assoc] using h

theorem compressionWidth_union_bound {d r : ℕ} (hd : 1 ≤ d) {K ρ : ℝ}
    (hK : 1 ≤ K) (hρ : 0 < ρ) :
    ((r : ℝ)+1)*2^d*Real.exp (1-(compressionWidth d r K ρ : ℝ)*ρ^2/(128*K)) < 1/200 := by
  let L : ℝ := (r : ℝ)+2
  have hL : 2≤L := by dsimp [L]; linarith [Nat.cast_nonneg (α:=ℝ) r]
  have hL0 : 0<L := by linarith
  have hd0 : (0 : ℝ)≤d := Nat.cast_nonneg d
  have hexp := compressionWidth_exponent (d:=d) (r:=r) (by linarith : 0<K) hρ
  have htwo : (2 : ℝ)≤Real.exp 1 := by linarith only [Real.add_one_le_exp 1]
  have hp : (2 : ℝ)^d≤Real.exp (d : ℝ) := by
    have hh := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤2) htwo d
    simpa only [← Real.exp_nat_mul,mul_one] using hh
  have hb : ((r : ℝ)+1)*2^d*Real.exp (1-(compressionWidth d r K ρ : ℝ)*ρ^2/(128*K)) ≤
      L*Real.exp (1-2*Real.log (400*L)) := by
    calc
      _ ≤ L*Real.exp (d : ℝ)*Real.exp (1-2*((d : ℝ)+Real.log (400*L))) := by
        gcongr
        · dsimp [L]; linarith
      _ = L*Real.exp (1-(d : ℝ)-2*Real.log (400*L)) := by
        rw [mul_assoc,← Real.exp_add]
        congr 2
        ring
      _ ≤ _ := by gcongr; linarith only [hd0]
  have he : L*Real.exp (1-2*Real.log (400*L)) = Real.exp 1/(160000*L) := by
    rw [Real.exp_sub,show Real.exp (2*Real.log (400*L))=(Real.exp (Real.log (400*L)))^2 by
      simpa using Real.exp_nat_mul (Real.log (400*L)) 2,Real.exp_log (by positivity)]
    field_simp
    ring
  rw [he] at hb
  have hexp1 : Real.exp (1 : ℝ)<3 := Real.exp_one_lt_three
  have hlt : Real.exp 1/(160000*L)<1/200 := by
    apply (div_lt_iff₀ (by positivity : 0<160000*L)).mpr
    nlinarith only [hexp1,hL]
  exact hb.trans_lt hlt

def certifiedCompressionRadius (r : ℕ) (K Λ : ℝ) : ℝ :=
  1/(16*Λ*Real.sqrt (1+((r : ℝ)+1)*K))

theorem certifiedCompressionRadius_bounds {r : ℕ} {K Λ : ℝ}
    (hK : 1≤K) (hΛ : 1<Λ) :
    0<certifiedCompressionRadius r K Λ ∧ certifiedCompressionRadius r K Λ≤1/6 := by
  have hh : 1≤1+((r : ℝ)+1)*K := by
    have hp : 0≤((r : ℝ)+1)*K := by positivity
    linarith only [hp]
  have hs : 1≤Real.sqrt (1+((r : ℝ)+1)*K) := by simpa only [Real.sqrt_one] using Real.sqrt_le_sqrt hh
  have hden : 0<16*Λ*Real.sqrt (1+((r : ℝ)+1)*K) := by positivity
  refine ⟨one_div_pos.mpr hden,?_⟩
  unfold certifiedCompressionRadius
  apply (div_le_iff₀ hden).mpr
  have hm := mul_le_mul_of_nonneg_left hs (show 0≤Λ by linarith)
  nlinarith only [hm,hΛ]

theorem certifiedCompressionWidth_eq {d r : ℕ} {K Λ : ℝ}
    (hK : 1≤K) (hΛ : 1<Λ) :
    compressionWidth d r K (certifiedCompressionRadius r K Λ) =
      ⌈65536*Λ^2*K*(1+((r : ℝ)+1)*K)*
        ((d : ℝ)+Real.log (400*((r : ℝ)+2)))⌉₊ := by
  unfold compressionWidth certifiedCompressionRadius
  congr 1
  rw [div_pow,mul_pow,mul_pow,Real.sq_sqrt (by positivity)]
  field_simp
  ring

theorem compression_width_dominates_weights {M : ℕ} {K : ℝ}
    (hK : 0≤K) (hM : 16*K≤(M : ℝ)) : 4*Real.sqrt ((M : ℝ)*K)≤M := by
  have hs := Real.sq_sqrt (mul_nonneg (Nat.cast_nonneg M) hK)
  have hm := mul_le_mul_of_nonneg_left hM (Nat.cast_nonneg M : (0 : ℝ)≤M)
  nlinarith only [hs,hm,Real.sqrt_nonneg ((M : ℝ)*K),Nat.cast_nonneg (α:=ℝ) M]

end NeuralGeneralization.BatchTwoNeuralConverse
