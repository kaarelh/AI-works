import NeuralGeneralization.BatchTwoMergingSharpScales
import Mathlib.Analysis.Asymptotics.Lemmas

/-! Elementary width-growth bookkeeping, keeping exactly three logarithmic
factors in the final quadratic width bound. -/
noncomputable section
open scoped BigOperators
open Filter Asymptotics
namespace NeuralGeneralization.BatchTwoMerging

def WidthGrowth (f:ℕ→ℝ) (p q:ℕ):Prop :=
  ∃a:ℝ,0<a ∧ ∀C:ℕ,1≤C→|f C|≤a*(C:ℝ)^p*(1+Real.log C)^q

namespace WidthGrowth

theorem factors {C:ℕ} (hC:1≤C):1≤(C:ℝ) ∧ 1≤1+Real.log C := by
  have hc:(1:ℝ)≤C := by exact_mod_cast hC
  exact ⟨hc,by linarith [Real.log_nonneg hc]⟩

theorem const (a:ℝ):WidthGrowth (fun _=>a) 0 0 := by
  refine ⟨|a|+1,by positivity,?_⟩
  intro C hC
  simp only [pow_zero,mul_one]
  linarith

theorem width:WidthGrowth (fun C=>(C:ℝ)) 1 0 := by
  refine ⟨1,by norm_num,?_⟩
  intro C hC
  simp [abs_of_nonneg (Nat.cast_nonneg C : (0:ℝ)≤C)]

theorem mono {f:ℕ→ℝ} {p q p' q':ℕ} (h:WidthGrowth f p q) (hp:p≤p') (hq:q≤q'):
    WidthGrowth f p' q' := by
  obtain ⟨a,ha,h⟩:=h
  refine ⟨a,ha,?_⟩
  intro C hC
  obtain ⟨hc,hl⟩:=factors hC
  exact (h C hC).trans (mul_le_mul
    (mul_le_mul_of_nonneg_left (pow_le_pow_right₀ hc hp) ha.le)
    (pow_le_pow_right₀ hl hq) (by positivity) (by positivity))

theorem add {f g:ℕ→ℝ} {p q:ℕ} (hf:WidthGrowth f p q) (hg:WidthGrowth g p q):
    WidthGrowth (fun C=>f C+g C) p q := by
  obtain ⟨a,ha,hf⟩:=hf
  obtain ⟨b,hb,hg⟩:=hg
  refine ⟨a+b,by positivity,?_⟩
  intro C hC
  calc
    _ ≤ |f C|+|g C| := abs_add_le _ _
    _ ≤ a*(C:ℝ)^p*(1+Real.log C)^q+b*(C:ℝ)^p*(1+Real.log C)^q := add_le_add (hf C hC) (hg C hC)
    _ = _ := by ring

theorem mul {f g:ℕ→ℝ} {p q p' q':ℕ} (hf:WidthGrowth f p q) (hg:WidthGrowth g p' q'):
    WidthGrowth (fun C=>f C*g C) (p+p') (q+q') := by
  obtain ⟨a,ha,hf⟩:=hf
  obtain ⟨b,hb,hg⟩:=hg
  refine ⟨a*b,by positivity,?_⟩
  intro C hC
  obtain ⟨hc,hl⟩:=factors hC
  rw [abs_mul]
  calc
    _ ≤ (a*(C:ℝ)^p*(1+Real.log C)^q)*(b*(C:ℝ)^p'*(1+Real.log C)^q') :=
      mul_le_mul (hf C hC) (hg C hC) (abs_nonneg _) (by positivity)
    _ = _ := by rw [pow_add,pow_add]; ring

theorem const_mul {f:ℕ→ℝ} {p q:ℕ} (h:WidthGrowth f p q) (a:ℝ):
    WidthGrowth (fun C=>a*f C) p q := by simpa using (const a).mul h

theorem pow {f:ℕ→ℝ} {p q:ℕ} (h:WidthGrowth f p q) (n:ℕ):
    WidthGrowth (fun C=>f C^n) (p*n) (q*n) := by
  induction n with
  | zero => simpa using const 1
  | succ n ih =>
    simpa only [pow_succ,Nat.mul_succ] using ih.mul h

theorem sqrt {f:ℕ→ℝ} {p q:ℕ} (h:WidthGrowth f p q):
    WidthGrowth (fun C=>Real.sqrt (f C)) p q := by
  obtain ⟨a,ha,hf⟩:=h
  refine ⟨a+1,by positivity,?_⟩
  intro C hC
  obtain ⟨hc,hl⟩:=factors hC
  have hs:Real.sqrt (f C)≤|f C|+1 := by
    by_cases hp:0≤f C
    · have hh:=Real.sq_sqrt hp
      rw [abs_of_nonneg hp]
      nlinarith [Real.sqrt_nonneg (f C),sq_nonneg (f C)]
    · rw [Real.sqrt_eq_zero_of_nonpos (le_of_not_ge hp)]
      positivity
  have hh:=hf C hC
  have hp:=one_le_pow₀ hc (n:=p)
  have hq:=one_le_pow₀ hl (n:=q)
  rw [abs_of_nonneg (Real.sqrt_nonneg _)]
  nlinarith [one_le_mul_of_one_le_of_one_le hp hq]

theorem max_growth {f g:ℕ→ℝ} {p q:ℕ} (hf:WidthGrowth f p q) (hg:WidthGrowth g p q):
    WidthGrowth (fun C=>max (f C) (g C)) p q := by
  obtain ⟨a,ha,hf⟩:=hf
  obtain ⟨b,hb,hg⟩:=hg
  refine ⟨a+b,by positivity,?_⟩
  intro C hC
  have hh:|max (f C) (g C)|≤|f C|+|g C| := by
    by_cases h:f C≤g C
    · rw [max_eq_right h]; linarith [abs_nonneg (f C)]
    · rw [max_eq_left (le_of_not_ge h)]; linarith [abs_nonneg (g C)]
  nlinarith [hf C hC,hg C hC]

theorem ceil {f:ℕ→ℝ} {p q:ℕ} (h:WidthGrowth f p q):
    WidthGrowth (fun C=>(⌈f C⌉₊:ℝ)) p q := by
  obtain ⟨a,ha,hf⟩:=h
  refine ⟨a+1,by positivity,?_⟩
  intro C hC
  obtain ⟨hc,hl⟩:=factors hC
  have hs:(⌈f C⌉₊:ℝ)≤|f C|+1 := by
    by_cases hp:0≤f C
    · rw [abs_of_nonneg hp]
      exact (Nat.ceil_lt_add_one hp).le
    · rw [Nat.ceil_eq_zero.mpr (le_of_not_ge hp)]
      simp only [Nat.cast_zero]
      positivity
  have hh:=hf C hC
  have hp:=one_le_pow₀ hc (n:=p)
  have hq:=one_le_pow₀ hl (n:=q)
  rw [abs_of_nonneg (Nat.cast_nonneg _)]
  nlinarith [one_le_mul_of_one_le_of_one_le hp hq]

theorem log {f:ℕ→ℝ} {p q:ℕ} (h:WidthGrowth f p q)
    (h1:∀C,1≤C→1≤f C):WidthGrowth (fun C=>Real.log (f C)) 0 1 := by
  obtain ⟨a,ha,hf⟩:=h
  refine ⟨|Real.log (a+1)|+p+q+1,by positivity,?_⟩
  intro C hC
  obtain ⟨hc,hl⟩:=factors hC
  have hc0:(0:ℝ)<C := by linarith
  have hl0:0<1+Real.log C := by linarith
  have hp0:0≤(p:ℝ) := Nat.cast_nonneg p
  have hq0:0≤(q:ℝ) := Nat.cast_nonneg q
  have hfc:0<f C := lt_of_lt_of_le zero_lt_one (h1 C hC)
  have hh: f C≤(a+1)*(C:ℝ)^p*(1+Real.log C)^q := by
    have hh:=hf C hC
    have hpq:0≤(C:ℝ)^p*(1+Real.log C)^q := by positivity
    nlinarith [le_abs_self (f C)]
  have hx:=Real.log_le_log hfc hh
  rw [Real.log_mul (by positivity : (a+1)*(C:ℝ)^p≠0) (by positivity : (1+Real.log C)^q≠0),
    Real.log_mul (by positivity : a+1≠0) (by positivity : (C:ℝ)^p≠0),Real.log_pow,Real.log_pow] at hx
  have hlb:=Real.log_le_sub_one_of_pos hl0
  have hlc:=Real.log_nonneg hc
  have ha':=le_abs_self (Real.log (a+1))
  have ha'':=mul_le_mul_of_nonneg_left hl (abs_nonneg (Real.log (a+1)))
  have hpp:=mul_le_mul_of_nonneg_left (show Real.log C≤1+Real.log C by linarith) hp0
  have hqq:=mul_le_mul_of_nonneg_left hlb hq0
  rw [abs_of_nonneg (Real.log_nonneg (h1 C hC)),pow_zero,pow_one,mul_one]
  nlinarith

theorem congr {f g:ℕ→ℝ} {p q:ℕ} (h:WidthGrowth f p q)
    (he:∀C,1≤C→f C=g C):WidthGrowth g p q := by
  obtain ⟨a,ha,hf⟩:=h
  exact ⟨a,ha,fun C hC=>by rw [←he C hC];exact hf C hC⟩

theorem comp_mul {f:ℕ→ℝ} {p q:ℕ} (h:WidthGrowth f p q) {k:ℕ} (hk:1≤k):
    WidthGrowth (fun C=>f (k*C)) p q := by
  obtain ⟨a,ha,hf⟩:=h
  have hkr:(1:ℝ)≤k := by exact_mod_cast hk
  have hk0:(0:ℝ)<k := by linarith
  have hlk:0≤Real.log k := Real.log_nonneg hkr
  refine ⟨a*(k:ℝ)^p*(1+Real.log k)^q,by positivity,?_⟩
  intro C hC
  obtain ⟨hc,hl⟩:=factors hC
  have hc0:(0:ℝ)<C := by linarith
  have hck:1≤k*C := Nat.mul_le_mul hk hC
  have hh:=hf (k*C) hck
  push_cast at hh
  rw [Real.log_mul hk0.ne' hc0.ne',mul_pow] at hh
  have hs:1+(Real.log k+Real.log C)≤(1+Real.log k)*(1+Real.log C) := by
    have hx:=mul_nonneg hlk (Real.log_nonneg hc)
    nlinarith
  have hp:=pow_le_pow_left₀ (by linarith : 0≤1+(Real.log k+Real.log C)) hs q
  have hm:=mul_le_mul_of_nonneg_left hp (show 0≤a*((k:ℝ)^p*(C:ℝ)^p) by positivity)
  rw [mul_pow] at hm
  nlinarith

theorem isBigO {f:ℕ→ℝ} {p q:ℕ} (h:WidthGrowth f p q):
    f =O[atTop] (fun C=>(C:ℝ)^p*(Real.log ((C:ℝ)+2))^q) := by
  obtain ⟨a,ha,hf⟩:=h
  apply Asymptotics.isBigO_iff.mpr
  refine ⟨a*2^q,Filter.eventually_atTop.mpr ⟨max 1 ⌈Real.exp 1⌉₊,?_⟩⟩
  intro C hC
  have hC1:1≤C := (le_max_left _ _).trans hC
  have hCe:⌈Real.exp 1⌉₊≤C := (le_max_right _ _).trans hC
  have he:Real.exp 1≤(C:ℝ) := (Nat.le_ceil _).trans (by exact_mod_cast hCe)
  obtain ⟨hc,hl⟩:=factors hC1
  have hlog1:1≤Real.log C := by
    have hh:=Real.log_le_log (Real.exp_pos 1) he
    simpa only [Real.log_exp] using hh
  have hlcmp:Real.log C≤Real.log ((C:ℝ)+2) := Real.log_le_log (by linarith) (by linarith)
  have hlog0:0≤Real.log ((C:ℝ)+2) := by linarith
  have hs:1+Real.log C≤2*Real.log ((C:ℝ)+2) := by linarith
  have hp:=pow_le_pow_left₀ (by linarith : 0≤1+Real.log C) hs q
  have hm:=mul_le_mul_of_nonneg_left hp (show 0≤a*(C:ℝ)^p by positivity)
  have hh:=hf C hC1
  simp only [Real.norm_eq_abs]
  rw [abs_of_nonneg (show 0≤(C:ℝ)^p*Real.log ((C:ℝ)+2)^q by positivity)]
  rw [mul_pow] at hm
  nlinarith

end WidthGrowth
end NeuralGeneralization.BatchTwoMerging
