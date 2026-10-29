import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.Order.Floor.Semiring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.NormNum

noncomputable section
set_option maxHeartbeats 1000000
namespace ConditionalNonpolynomial.Analytic

def targetAllocationConstant (c cPur K B : ℝ) : ℝ := 4*(B+1/c+4+K+3/cPur)
def targetScale (c cPur K B T : ℝ) (H : ℕ) : ℝ := targetAllocationConstant c cPur K B*T/H
def targetCoolingLength (c p : ℝ) : ℕ := ⌈1/(c*p)⌉₊
def targetGrowthLength (K T p : ℝ) : ℕ := ⌈(1+K)*T/p⌉₊
def targetPurificationLength (cPur T p : ℝ) : ℕ := ⌈3*T/(cPur*p)⌉₊

theorem targetAllocationConstant_pos {c cPur K B : ℝ} (hc : 0<c) (hPur : 0<cPur)
    (hK : 0≤K) (hB : 0≤B) : 0<targetAllocationConstant c cPur K B := by
  unfold targetAllocationConstant
  positivity

theorem targetScale_bounds {c cPur K B T : ℝ} {H : ℕ}
    (hc : 0<c) (hPur : 0<cPur) (hK : 0≤K) (hB : 0≤B) (hT : 1≤T)
    (hH : 256*targetAllocationConstant c cPur K B*T ≤ (H:ℝ)) :
    0<targetScale c cPur K B T H ∧ targetScale c cPur K B T H≤1/256 := by
  have hA := targetAllocationConstant_pos hc hPur hK hB
  have hT0 : 0<T := by linarith
  have hH0 : 0<(H:ℝ) := lt_of_lt_of_le (by positivity) hH
  constructor
  · exact div_pos (mul_pos hA hT0) hH0
  · apply (div_le_iff₀ hH0).mpr
    linarith

theorem targetLengths_budget {c cPur K B T : ℝ} {H m : ℕ}
    (hc : 0<c) (hPur : 0<cPur) (hK : 0≤K) (hB : 0≤B) (hT : 1≤T)
    (hH : 256*targetAllocationConstant c cPur K B*T ≤ (H:ℝ))
    (hm : (m:ℝ)*targetScale c cPur K B T H ≤ B) :
    ((targetCoolingLength c (targetScale c cPur K B T H) +
      targetGrowthLength K T (targetScale c cPur K B T H) +
      targetPurificationLength cPur T (targetScale c cPur K B T H)+m : ℕ):ℝ) ≤ (H:ℝ)/4 := by
  let A := targetAllocationConstant c cPur K B
  let p := targetScale c cPur K B T H
  have hA : 0<A := targetAllocationConstant_pos hc hPur hK hB
  have hp : 0<p := (targetScale_bounds hc hPur hK hB hT hH).1
  have hp1 : p≤1 := (targetScale_bounds hc hPur hK hB hT hH).2.trans (by norm_num)
  have hH0 : 0<(H:ℝ) := lt_of_lt_of_le (by positivity) hH
  have hpH : p*(H:ℝ)=A*T := by dsimp [p,targetScale,A]; field_simp
  have h0 := (Nat.ceil_lt_add_one (show 0≤1/(c*p) by positivity)).le
  have h1 := (Nat.ceil_lt_add_one (show 0≤(1+K)*T/p by positivity)).le
  have h2 := (Nat.ceil_lt_add_one (show 0≤3*T/(cPur*p) by positivity)).le
  have hm0 := mul_le_mul_of_nonneg_right h0 hp.le
  have hm1 := mul_le_mul_of_nonneg_right h1 hp.le
  have hm2 := mul_le_mul_of_nonneg_right h2 hp.le
  have e0 : (1/(c*p)+1)*p=1/c+p := by field_simp
  have e1 : ((1+K)*T/p+1)*p=(1+K)*T+p := by field_simp
  have e2 : (3*T/(cPur*p)+1)*p=3*T/cPur+p := by field_simp
  rw [e0] at hm0
  rw [e1] at hm1
  rw [e2] at hm2
  have hbT := mul_le_mul_of_nonneg_left hT hB
  have hcT := mul_le_mul_of_nonneg_left hT (show 0≤1/c by positivity)
  have hpT : p≤T := hp1.trans hT
  have heA : A*T=(4*B+4/c+16+4*K+12/cPur)*T := by dsimp [A,targetAllocationConstant]; ring
  change ((targetCoolingLength c p+targetGrowthLength K T p+targetPurificationLength cPur T p+m : ℕ):ℝ)≤_
  push_cast
  apply (mul_le_mul_iff_right₀ hp).mp
  have halloc : p*((H:ℝ)/4)=A*T/4 := by nlinarith [hpH]
  rw [halloc,heA]
  change (m:ℝ)*p≤B at hm
  dsimp only [targetCoolingLength,targetGrowthLength,targetPurificationLength]
  simp only [div_eq_mul_inv] at hm0 hm1 hm2 hcT ⊢
  nlinarith

theorem targetLengths_requirements {c cPur K T p : ℝ}
    (hc : 0<c) (hPur : 0<cPur) (hp : 0<p) :
    1/(c*p)≤(targetCoolingLength c p:ℝ) ∧
    (1+K)*T≤(targetGrowthLength K T p:ℝ)*p ∧
    3*T≤cPur*p*(targetPurificationLength cPur T p:ℝ) := by
  refine ⟨Nat.le_ceil _,?_,?_⟩
  · exact (div_le_iff₀ hp).mp (Nat.le_ceil _)
  · have hh := (div_le_iff₀ (mul_pos hPur hp)).mp
      (Nat.le_ceil (3*T/(cPur*p)))
    simpa only [targetPurificationLength,mul_comm] using hh

#print axioms targetLengths_budget
end ConditionalNonpolynomial.Analytic
