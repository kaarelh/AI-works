import NeuralGeneralization.OnlineLowerReluConditionalLaw
import NeuralGeneralization.OnlineLowerReluComparison

/-! # Aggregate opposite-rail mass from the randomized minimum -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

def flipRailCoordinate {ι : Type*} [DecidableEq ι] (i : ι) :
    (ι → Bool) ≃ (ι → Bool) where
  toFun ε j := if j = i then !ε j else ε j
  invFun ε j := if j = i then !ε j else ε j
  left_inv ε := by funext j; by_cases h : j = i <;> simp [h]
  right_inv ε := by funext j; by_cases h : j = i <;> simp [h]

theorem railBit_not (b : Bool) : railBit (!b) = -railBit b := by
  cases b <;> norm_num [railBit]

theorem finiteAverage_add {Ω : Type*} [Fintype Ω] (f g : Ω → ℝ) :
    finiteAverage (fun ω => f ω + g ω) = finiteAverage f + finiteAverage g := by
  unfold finiteAverage
  rw [Finset.sum_add_distrib, add_div]

theorem finiteAverage_railBit {ι : Type*} [Fintype ι] [DecidableEq ι] (i : ι) :
    finiteAverage (fun ε : ι → Bool => railBit (ε i)) = 0 := by
  have h := finiteAverage_perm (flipRailCoordinate i) (fun ε : ι → Bool => railBit (ε i))
  have heq : finiteAverage (fun ε : ι → Bool => railBit (flipRailCoordinate i ε i)) =
      -finiteAverage (fun ε : ι → Bool => railBit (ε i)) := by
    simp only [flipRailCoordinate, Equiv.coe_fn_mk, ite_true, railBit_not]
    unfold finiteAverage
    rw [Finset.sum_neg_distrib, neg_div]
  rw [heq] at h
  linarith

theorem average_minimumRailAmplitude_le {ι : Type*}
    [Fintype ι] [Nonempty ι] [DecidableEq ι]
    (a b : ι → ℝ) (i : ι) : finiteAverage (minimumRailAmplitude a b) ≤ a i := by
  have h := finiteAverage_mono (minimumRailAmplitude a b)
    (fun ε : ι → Bool => a i + railBit (ε i) * b i)
    (fun ε => minimumRailAmplitude_le a b ε i)
  have heq : finiteAverage (fun ε : ι → Bool => a i + railBit (ε i) * b i) = a i := by
    rw [finiteAverage_add, finiteAverage_const]
    have hmul : (fun ε : ι → Bool => railBit (ε i) * b i) =
        (fun ε : ι → Bool => b i * railBit (ε i)) := by funext ε; ring
    rw [hmul, finiteAverage_mul_left, finiteAverage_railBit]
    ring
  rwa [heq] at h

theorem four_flips_minimum_bound {ι : Type*}
    [Fintype ι] [Nonempty ι] [DecidableEq ι]
    (a b : ι → ℝ) (hb : ∀ i, 0 ≤ b i) (i j : ι) (hij : i ≠ j)
    (ε : ι → Bool) :
    minimumRailAmplitude a b ε + minimumRailAmplitude a b (flipRailCoordinate i ε) +
      minimumRailAmplitude a b (flipRailCoordinate j ε) +
      minimumRailAmplitude a b (flipRailCoordinate i (flipRailCoordinate j ε)) ≤
      2 * (a i + a j) - (b i + b j) := by
  have hp (δ : ι → Bool) : minimumRailAmplitude a b δ ≤
      min (a i + railBit (δ i) * b i) (a j + railBit (δ j) * b j) :=
    le_min (minimumRailAmplitude_le a b δ i) (minimumRailAmplitude_le a b δ j)
  have h1 := hp ε
  have h2 := hp (flipRailCoordinate i ε)
  have h3 := hp (flipRailCoordinate j ε)
  have h4 := hp (flipRailCoordinate i (flipRailCoordinate j ε))
  have hbound := four_signed_minimum_bound (a i) (b i) (a j) (b j) (hb i) (hb j)
  cases hi : ε i <;> cases hj : ε j <;>
    simp [flipRailCoordinate, hij, Ne.symm hij, hi, hj, railBit,
      sub_eq_add_neg] at h1 h2 h3 h4 hbound ⊢ <;>
    linarith

theorem randomized_minimum_pair_debt {ι : Type*}
    [Fintype ι] [Nonempty ι] [DecidableEq ι]
    (a b : ι → ℝ) (hb : ∀ i, 0 ≤ b i) (i j : ι) (hij : i ≠ j) :
    b i + b j ≤ 2 * ((a i - finiteAverage (minimumRailAmplitude a b)) +
      (a j - finiteAverage (minimumRailAmplitude a b))) := by
  have h := finiteAverage_mono
    (fun ε : ι → Bool => minimumRailAmplitude a b ε +
      minimumRailAmplitude a b (flipRailCoordinate i ε) +
      minimumRailAmplitude a b (flipRailCoordinate j ε) +
      minimumRailAmplitude a b (flipRailCoordinate i (flipRailCoordinate j ε)))
    (fun _ : ι → Bool => 2 * (a i + a j) - (b i + b j))
    (four_flips_minimum_bound a b hb i j hij)
  simp_rw [finiteAverage_add] at h
  rw [finiteAverage_perm (flipRailCoordinate i), finiteAverage_perm (flipRailCoordinate j)] at h
  rw [finiteAverage_perm (flipRailCoordinate j)
      (fun δ => minimumRailAmplitude a b (flipRailCoordinate i δ)),
    finiteAverage_perm (flipRailCoordinate i),
    finiteAverage_const] at h
  linarith

/-- If every pair of distinct entries has nonnegative sum, the total sum
is nonnegative on a finite type with at least two elements. -/
theorem sum_nonneg_of_distinct_pair_sums {ι : Type*} [Fintype ι] [Nontrivial ι]
    (u : ι → ℝ) (hp : ∀ i j, i ≠ j → 0 ≤ u i + u j) : 0 ≤ ∑ i, u i := by
  classical
  by_cases hnonneg : ∀ i, 0 ≤ u i
  · exact Finset.sum_nonneg (fun i _ => hnonneg i)
  push Not at hnonneg
  obtain ⟨i, hi⟩ := hnonneg
  obtain ⟨j, hj⟩ := exists_ne i
  have hrest (k : ι) (hk : k ∈ Finset.univ.erase i) : 0 ≤ u k := by
    have hki := (Finset.mem_erase.mp hk).1
    have hpair := hp i k (Ne.symm hki)
    linarith
  have hsum := Finset.single_le_sum hrest (show j ∈ Finset.univ.erase i by simp [hj])
  have hsplit := Finset.sum_erase_add (s := Finset.univ) (f := u) (Finset.mem_univ i)
  have hpair := hp i j (Ne.symm hj)
  linarith

/-- The aggregate debt used in the exact atom comparison is a consequence
of the actual uniform randomized minimum, not an assumed scalar relation. -/
theorem randomized_minimum_aggregate_debt {ι : Type*}
    [Fintype ι] [Nonempty ι] [Nontrivial ι] [DecidableEq ι]
    (a b : ι → ℝ) (hb : ∀ i, 0 ≤ b i) :
    (∑ i, b i) ≤ 2 * ∑ i, (a i - finiteAverage (minimumRailAmplitude a b)) := by
  have h := sum_nonneg_of_distinct_pair_sums
    (fun i => 2 * (a i - finiteAverage (minimumRailAmplitude a b)) - b i)
    (fun i j hij => by have := randomized_minimum_pair_debt a b hb i j hij; linarith)
  simp_rw [Finset.sum_sub_distrib, ← Finset.mul_sum] at h
  linarith

end NeuralGeneralization.OnlineLowerRelu
