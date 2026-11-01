import NeuralGeneralization.BatchTwoOnlineNonuniformRisk
import Mathlib.NumberTheory.Harmonic.Bounds

/-! Summable unseen mass and the explicit nonuniform cutoff in the paper. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnline
variable {X : Type*} [Fintype X]

theorem weighted_geometric_sum (a : ℝ) (N : ℕ) :
    (∑ n∈Finset.range N,a*(1-a)^n)=1-(1-a)^N := by
  induction N with
  | zero => simp
  | succ N ih => rw [Finset.sum_range_succ,ih,pow_succ]; ring

theorem expectedUnseen_nonneg (D : X→ℝ) (hD : ∀ x,0≤D x) (hD1 : ∀ x,D x≤1) (n : ℕ) :
    0≤expectedUnseen D n :=
  Finset.sum_nonneg fun x _ => mul_nonneg (hD x) (pow_nonneg (sub_nonneg.mpr (hD1 x)) _)

theorem expectedUnseen_sum (D : X→ℝ) (N : ℕ) :
    (∑ n∈Finset.range N,expectedUnseen D n)=∑ x : X,(1-(1-D x)^N) := by
  unfold expectedUnseen
  rw [Finset.sum_comm]
  simp only [weighted_geometric_sum]

theorem expectedUnseen_sum_le_card (D : X→ℝ) (hD1 : ∀ x,D x≤1) (N : ℕ) :
    (∑ n∈Finset.range N,expectedUnseen D n)≤(Fintype.card X:ℝ) := by
  rw [expectedUnseen_sum]
  calc
    _ ≤ ∑ _x : X,(1:ℝ) := Finset.sum_le_sum fun x _ => by
      have := pow_nonneg (sub_nonneg.mpr (hD1 x)) N
      linarith
    _ = _ := by simp

theorem expectedUnseen_tail_le (D : X→ℝ) (hD : ∀ x,0≤D x) (hD1 : ∀ x,D x≤1)
    {p : ℝ} (hp : ∀ x,p≤D x) (T N : ℕ) :
    (∑ n∈Finset.range N,expectedUnseen D (n+T))≤
      (Fintype.card X:ℝ)*Real.exp (-(T:ℝ)*p) := by
  unfold expectedUnseen
  rw [Finset.sum_comm]
  calc
    _ = ∑ x,(1-D x)^T*(1-(1-D x)^N) := by
      apply Finset.sum_congr rfl
      intro x _
      rw [← weighted_geometric_sum (D x) N,Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro n _
      rw [pow_add]
      ring
    _ ≤ ∑ _x : X,Real.exp (-(T:ℝ)*p) := by
      apply Finset.sum_le_sum
      intro x _
      calc
        _ ≤ (1-D x)^T := mul_le_of_le_one_right
          (pow_nonneg (sub_nonneg.mpr (hD1 x)) _) (by have := pow_nonneg (sub_nonneg.mpr (hD1 x)) N; linarith)
        _ ≤ Real.exp (-(T:ℝ)*D x) := pow_one_sub_le_exp (D x) (hD1 x) T
        _ ≤ _ := Real.exp_le_exp.mpr (mul_le_mul_of_nonpos_left (hp x) (neg_nonpos.mpr (Nat.cast_nonneg T)))
    _ = _ := by simp

def nonuniformCutoff (p : ℝ) : ℕ := ⌈p⁻¹*Real.log (2/p)⌉₊

theorem nonuniformCutoff_pos {p : ℝ} (hp : 0<p) (hp1 : p≤1) :
    0<nonuniformCutoff p := by
  apply Nat.ceil_pos.mpr
  apply mul_pos (inv_pos.mpr hp)
  apply Real.log_pos
  exact (one_lt_div hp).mpr (by linarith)

theorem nonuniformCutoff_tail {p : ℝ} (hp : 0<p) :
    Real.exp (-(nonuniformCutoff p:ℝ)*p)≤p/2 := by
  have hc := Nat.le_ceil (p⁻¹*Real.log (2/p))
  have hb := mul_le_mul_of_nonneg_left hc hp.le
  have he : p*(p⁻¹*Real.log (2/p))=Real.log (2/p) := by field_simp
  rw [he] at hb
  change Real.log (2/p)≤p*(nonuniformCutoff p:ℝ) at hb
  calc
    _ ≤ Real.exp (-Real.log (2/p)) := Real.exp_le_exp.mpr (by linarith)
    _ = p/2 := by rw [Real.exp_neg,Real.exp_log (div_pos (by norm_num) hp)]; field_simp

end NeuralGeneralization.BatchTwoOnline
