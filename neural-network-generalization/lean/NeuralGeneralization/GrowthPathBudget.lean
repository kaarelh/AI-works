import NeuralGeneralization.WeightedFiniteChaining
import NeuralGeneralization.GreedyGrowthCover

/-!
# Summing growth-functional charges along finite paths

Runs of unchanged diameter are separated by shrink steps. Each run has
one possible last-right-turn charge. Four shrink steps suffice for the
greedy inner-ball test when the quasi-triangle constant is four. The
result below telescopes the genuine potential drops; it does not assume
a bound on the completed chaining path.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.GrowthPath

/-- A shifted telescoping identity with an arbitrary delay. -/
theorem sum_delayed_drop (P : ℕ → ℝ) (n k : ℕ) :
    (∑ i ∈ Finset.range n, (P i - P (i+k))) =
      (∑ i ∈ Finset.range k, P i) - ∑ i ∈ Finset.range k, P (n+i) := by
  have h₁ := Finset.sum_range_add P n k
  have h₂ := Finset.sum_range_add P k n
  rw [Nat.add_comm k n] at h₂
  simp_rw [Nat.add_comm k] at h₂
  rw [Finset.sum_sub_distrib]
  linarith

/-- At most `k` copies of the initial potential are spent by all delayed
charges, regardless of the path length. -/
theorem sum_delayed_drop_le (P : ℕ → ℝ) (hP : ∀ i, 0 ≤ P i)
    (hmono : Antitone P) (n k : ℕ) :
    (∑ i ∈ Finset.range n, (P i - P (i+k))) ≤ k * P 0 := by
  rw [sum_delayed_drop]
  have hlo : 0 ≤ ∑ i ∈ Finset.range k, P (n+i) :=
    Finset.sum_nonneg (fun i _ => hP _)
  have hhi : (∑ i ∈ Finset.range k, P i) ≤ k * P 0 := by
    calc
      _ ≤ ∑ i ∈ Finset.range k, P 0 :=
        Finset.sum_le_sum (fun i _ => hmono (Nat.zero_le i))
      _ = _ := by simp
  linarith

theorem total_charge_le (P Z : ℕ → ℝ) (hP : ∀ i, 0 ≤ P i)
    (hmono : Antitone P) (κ : ℝ) (hκ : 0 < κ) (k L : ℕ)
    (hcharge : ∀ i < L, κ * Z i ≤ P i - P (i+k)) :
    (∑ i ∈ Finset.range L, Z i) ≤ k * P 0 / κ := by
  apply (le_div_iff₀ hκ).mpr
  calc
    _ = ∑ i ∈ Finset.range L, κ * Z i := by rw [← Finset.mul_sum]; ring
    _ ≤ ∑ i ∈ Finset.range L, (P i - P (i+k)) :=
      Finset.sum_le_sum (fun i hi => hcharge i (Finset.mem_range.mp hi))
    _ ≤ _ := sum_delayed_drop_le P hP hmono L k

/-- A run with no right turn contracts by a factor four; a run with a
right turn is paid by twice its last-right-turn weight. This elementary
recurrence controls the sum of all run endpoints. -/
theorem stage_recurrence_budget (W Z : ℕ → ℝ) (D : ℝ)
    (hW : ∀ i, 0 ≤ W i) (hD : 0 ≤ D)
    (hfirst : W 0 ≤ D + 2 * Z 0)
    (hstep : ∀ i, W (i+1) ≤ W i / 4 + 2 * Z (i+1)) (L : ℕ) :
    (3 : ℝ) / 4 * (∑ i ∈ Finset.range L, W i) ≤
      D + 2 * ∑ i ∈ Finset.range L, Z i := by
  have hstrong (n : ℕ) :
      (3 : ℝ) / 4 * (∑ i ∈ Finset.range (n+1), W i) + W n / 4 ≤
        D + 2 * ∑ i ∈ Finset.range (n+1), Z i := by
    induction n with
    | zero =>
      norm_num only [Nat.zero_add, Finset.sum_range_one]
      linarith
    | succ n ih =>
      rw [Finset.sum_range_succ W (n+1), Finset.sum_range_succ Z (n+1)]
      have hs := hstep n
      linarith
  cases L with
  | zero => simpa using hD
  | succ n => have hh := hstrong n; linarith [hW n]

/-- Uniform path budget from actual four-step potential drops. `cost` is
bounded by twice the sum of the run endpoint weights. -/
theorem four_stage_path_budget (P W Z : ℕ → ℝ) (D c B cost : ℝ) (L : ℕ)
    (hP : ∀ i, 0 ≤ P i) (hmono : Antitone P) (hB : P 0 ≤ B)
    (hW : ∀ i, 0 ≤ W i) (hD : 0 ≤ D) (hc : 0 < c)
    (hfirst : W 0 ≤ D + 2 * Z 0)
    (hstep : ∀ i, W (i+1) ≤ W i / 4 + 2 * Z (i+1))
    (hcharge : ∀ i < L, (c / 64) * Z i ≤ P i - P (i+4))
    (hcost : cost ≤ 2 * ∑ i ∈ Finset.range L, W i) :
    cost ≤ 4 * D + 2048 * B / c := by
  have hκ : 0 < c / 64 := by positivity
  have hz := total_charge_le P Z hP hmono (c / 64) hκ 4 L hcharge
  have hz' : c * (∑ i ∈ Finset.range L, Z i) ≤ 256 * B := by
    have hh := (le_div_iff₀ hκ).mp hz
    norm_num at hh
    nlinarith
  have hs := stage_recurrence_budget W Z D hW hD hfirst hstep L
  have hs' := mul_le_mul_of_nonneg_left hs hc.le
  have hcost' := mul_le_mul_of_nonneg_left hcost hc.le
  have hBnonneg : 0 ≤ B := (hP 0).trans hB
  apply (mul_le_mul_iff_right₀ hc).mp
  have he : c * (4 * D + 2048 * B / c) = c * (4 * D) + 2048 * B := by field_simp
  rw [he]
  nlinarith [mul_nonneg hD hc.le]

end NeuralGeneralization.GrowthPath
