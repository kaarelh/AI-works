import NeuralGeneralization.OnlineLowerReluDebt

/-! # Finite coefficient-mass accounting for the weighted ReLU atom bound -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

def oppositeMarginal {σ ι : Type*} [Fintype σ] [DecidableEq ι]
    (swapped : σ → Finset ι) (c : σ → ℝ) (i : ι) : ℝ :=
  ∑ s, if i ∈ swapped s then c s else 0

theorem oppositeMarginal_nonneg {σ ι : Type*} [Fintype σ] [DecidableEq ι]
    (swapped : σ → Finset ι) (c : σ → ℝ) (hc : ∀ s, 0 ≤ c s) (i : ι) :
    0 ≤ oppositeMarginal swapped c i := by
  apply Finset.sum_nonneg
  intro s _
  split_ifs <;> simp [hc]

theorem sum_swapped_costs {σ ι : Type*} [Fintype σ] [Fintype ι] [DecidableEq ι]
    (swapped : σ → Finset ι) (c : σ → ℝ) (δ : ι → ℝ) :
    (∑ s, c s * ∑ i ∈ swapped s, δ i) =
      ∑ i, δ i * oppositeMarginal swapped c i := by
  unfold oppositeMarginal
  simp_rw [Finset.mul_sum, mul_ite, mul_zero]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro s _
  rw [← Finset.sum_ite_mem_eq (swapped s) (fun i => c s * δ i)]
  apply Finset.sum_congr rfl
  intro i _
  split_ifs <;> ring

/-- Total coefficient mass controls the base cost; each opposite-rail
marginal pays only its rail-size increment. -/
theorem weighted_coefficient_mass_bound {σ ι : Type*}
    [Fintype σ] [Fintype ι] [DecidableEq ι]
    (swapped : σ → Finset ι) (c cost : σ → ℝ) (δ b : ι → ℝ)
    (base κ Δ t D : ℝ)
    (hc : ∀ s, 0 ≤ c s) (hbase : 0 ≤ base) (hΔ : 0 ≤ Δ) (hκ : 0 ≤ κ)
    (hb : ∀ i, 0 ≤ b i) (hδzero : ∀ i, 0 ≤ δ i) (hδ : ∀ i, δ i ≤ Δ)
    (hnormalize : base * κ = Real.sqrt D)
    (htotal : ∑ s, c s ≤ κ * t)
    (hmarginal : ∀ i, 0 < δ i → oppositeMarginal swapped c i ≤ κ * b i)
    (hcost : ∀ s, cost s ≤ base + 3 * ∑ i ∈ swapped s, δ i) :
    (∑ s, cost s * c s) ≤ Real.sqrt D * t + 3 * κ * Δ * ∑ i, b i := by
  have hweighted : (∑ s, cost s * c s) ≤
      base * (∑ s, c s) + 3 * ∑ i, δ i * oppositeMarginal swapped c i := by
    calc
      (∑ s, cost s * c s) ≤ ∑ s, (base + 3 * ∑ i ∈ swapped s, δ i) * c s :=
        Finset.sum_le_sum (fun s _ => mul_le_mul_of_nonneg_right (hcost s) (hc s))
      _ = base * (∑ s, c s) + 3 * ∑ s, c s * ∑ i ∈ swapped s, δ i := by
        simp_rw [add_mul, Finset.sum_add_distrib, Finset.mul_sum, Finset.sum_mul]
        congr 1
        apply Finset.sum_congr rfl
        intro s _
        apply Finset.sum_congr rfl
        intro i _
        ring
      _ = _ := by rw [sum_swapped_costs]
  have hbasebound := mul_le_mul_of_nonneg_left htotal hbase
  have hmarg : (∑ i, δ i * oppositeMarginal swapped c i) ≤ κ * Δ * ∑ i, b i := by
    calc
      (∑ i, δ i * oppositeMarginal swapped c i) ≤
          ∑ i, Δ * (κ * b i) := by
        apply Finset.sum_le_sum
        intro i _
        by_cases hi : 0 < δ i
        · exact (mul_le_mul_of_nonneg_right (hδ i) (oppositeMarginal_nonneg swapped c hc i)).trans
            (mul_le_mul_of_nonneg_left (hmarginal i hi) hΔ)
        · have hz : δ i = 0 := by linarith [hδzero i]
          rw [hz, zero_mul]
          exact mul_nonneg hΔ (mul_nonneg hκ (hb i))
      _ = _ := by rw [← Finset.mul_sum, ← Finset.mul_sum]; ring
  have hnormalizet := congrArg (fun z : ℝ => z * t) hnormalize
  nlinarith

/-- Combining coefficient accounting with the actual randomized minimum
and its proved debt gives projection onto the balanced dominant-rail ray. -/
theorem weighted_atom_projection_bound {σ ι : Type*}
    [Fintype σ] [Fintype ι] [Nonempty ι] [Nontrivial ι] [DecidableEq ι]
    (swapped : σ → Finset ι) (c cost : σ → ℝ) (δ p a b : ι → ℝ)
    (base κ Δ R D : ℝ)
    (hc : ∀ s, 0 ≤ c s) (hbase : 0 ≤ base) (hΔ : 0 ≤ Δ) (hκ : 0 ≤ κ)
    (hδzero : ∀ i, 0 ≤ δ i) (hδ : ∀ i, δ i ≤ Δ) (hnormalize : base * κ = Real.sqrt D)
    (htotal : ∑ s, c s ≤ κ * finiteAverage (minimumRailAmplitude a b))
    (hmarginal : ∀ i, 0 < δ i → oppositeMarginal swapped c i ≤ κ * b i)
    (hcost : ∀ s, cost s ≤ base + 3 * ∑ i ∈ swapped s, δ i)
    (hD : 0 < D) (hDsum : ∑ i, p i = D) (hp : ∀ i, R ≤ p i)
    (hb : ∀ i, 0 ≤ b i) (hκD : κ * Real.sqrt D ≤ 1) (hR : 6 * Δ ≤ R) :
    (∑ s, cost s * c s) ≤ (∑ i, p i * a i) / Real.sqrt D := by
  apply weighted_projection_bound p a b (finiteAverage (minimumRailAmplitude a b))
    R Δ κ D _ hD hDsum hp (average_minimumRailAmplitude_le a b) hb hΔ hκD hR
  · exact randomized_minimum_aggregate_debt a b hb
  · exact weighted_coefficient_mass_bound swapped c cost δ b base κ Δ
      (finiteAverage (minimumRailAmplitude a b)) D hc hbase hΔ hκ hb hδzero hδ hnormalize
      htotal hmarginal hcost

end NeuralGeneralization.OnlineLowerRelu
