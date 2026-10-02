import Paulsen.EmbeddingIncidence
import Paulsen.ExponentialCoercivity

/-!
# Balanced squared-minor weights by direct minimization

The centered tuple sums form a linear subspace of zero-sum vectors.
Minimizing the Cauchy--Binet exponential sum on that subspace gives
equal inclusion marginals by differentiation. No entropy theorem is used.
-/

namespace Paulsen

open scoped BigOperators

noncomputable section

def centeredEmbeddingMap (n d : ℕ) :
    (Fin n → ℝ) →ₗ[ℝ] ((Fin d ↪ Fin n) → ℝ) where
  toFun c f := (∑ j, c (f j)) - (d : ℝ) / n * ∑ i, c i
  map_add' c e := by
    ext f
    simp only [Pi.add_apply, Finset.sum_add_distrib]
    ring
  map_smul' t c := by
    ext f
    simp only [Pi.smul_apply, smul_eq_mul, ← Finset.mul_sum, RingHom.id_apply]
    ring

theorem sum_centeredEmbeddingMap {n d : ℕ} (hn : 0 < n) (hd : d ≤ n)
    (c : Fin n → ℝ) : (∑ f, centeredEmbeddingMap n d c f) = 0 := by
  letI : Nonempty (Fin d ↪ Fin n) := ⟨Fin.castLEEmb hd⟩
  have havg (i : Fin n) : (∑ f : Fin d ↪ Fin n, embeddingIncidence f i) =
      ((d : ℝ) / n) * Fintype.card (Fin d ↪ Fin n) := by
    exact (div_eq_iff (Nat.cast_ne_zero.mpr Fintype.card_ne_zero)).mp
      (embeddingIncidence_average hn hd i)
  change (∑ f : Fin d ↪ Fin n, ((∑ j, c (f j)) - (d : ℝ) / n * ∑ i, c i)) = 0
  rw [Finset.sum_sub_distrib]
  have hfirst : (∑ f : Fin d ↪ Fin n, ∑ j, c (f j)) =
      (Fintype.card (Fin d ↪ Fin n) : ℝ) * ((d : ℝ) / n * ∑ i, c i) := by
    calc
      (∑ f : Fin d ↪ Fin n, ∑ j, c (f j)) =
          ∑ f : Fin d ↪ Fin n, ∑ i, c i * embeddingIncidence f i := by
        simp only [sum_mul_embeddingIncidence]
      _ = ∑ i, c i * ∑ f : Fin d ↪ Fin n, embeddingIncidence f i := by
        rw [Finset.sum_comm]
        simp only [Finset.mul_sum]
      _ = _ := by
        simp only [havg, ← Finset.sum_mul]
        ring
  rw [hfirst]
  simp

/-- A positive reference measure on ordered minors has a balanced tilt,
proved by minimizing its exponential sum on the centered tuple-sum space. -/
theorem exists_balanced_embedding_tilt_coercive {n d : ℕ}
    (hn : 0 < n) (hd : d ≤ n)
    (μ : (Fin d ↪ Fin n) → ℝ) (hμ : ∀ f, 0 < μ f) :
    ∃ ν : (Fin d ↪ Fin n) → ℝ, (∀ f, 0 < ν f) ∧ (∑ f, ν f) = 1 ∧
      (∀ i, (∑ f, embeddingIncidence f i * ν f) = (d : ℝ) / (n : ℝ)) ∧
      ∃ c₀ : ℝ, ∃ c : Fin n → ℝ, ∀ f,
        ν f = μ f * Real.exp (c₀ + (∑ j : Fin d, c (f j)) - 1) := by
  classical
  letI : Nonempty (Fin d ↪ Fin n) := ⟨Fin.castLEEmb hd⟩
  let L := centeredEmbeddingMap n d
  obtain ⟨y, hy, hmin⟩ := exists_min_positiveExponentialSum μ hμ L.range (by
    intro y hy
    obtain ⟨c, rfl⟩ := hy
    exact sum_centeredEmbeddingMap hn hd c)
  obtain ⟨c, hc⟩ := hy
  let Z := positiveExponentialSum μ y
  have hZ : 0 < Z := Finset.sum_pos (fun f _ => mul_pos (hμ f) (Real.exp_pos _))
    Finset.univ_nonempty
  let ν : (Fin d ↪ Fin n) → ℝ := fun f => μ f * Real.exp (y f) / Z
  have hν : ∀ f, 0 < ν f := fun f => div_pos (mul_pos (hμ f) (Real.exp_pos _)) hZ
  have hsum : (∑ f, ν f) = 1 := by
    dsimp [ν]
    rw [← Finset.sum_div]
    exact div_self (ne_of_gt hZ)
  have hstationary (i : Fin n) :
      (∑ f, μ f * Real.exp (y f) * (embeddingIncidence f i - (d : ℝ) / n)) = 0 := by
    let e : Fin n → ℝ := fun k => if k = i then 1 else 0
    have hLe (f : Fin d ↪ Fin n) : L e f = embeddingIncidence f i - (d : ℝ) / n := by
      simp [L, centeredEmbeddingMap, e, embeddingIncidence]
    have hlocal : IsLocalMin (fun t : ℝ => positiveExponentialSum μ (y + t • L e)) 0 := by
      apply Filter.Eventually.of_forall
      intro t
      simp only [zero_smul, add_zero]
      apply hmin
      exact L.range.add_mem ⟨c, hc⟩ (L.range.smul_mem t (LinearMap.mem_range_self L e))
    simpa only [hLe] using hlocal.hasDerivAt_eq_zero
      (positiveExponentialSum_hasDerivAt_line μ y (L e))
  refine ⟨ν, hν, hsum, ?_, 1 - (d : ℝ) / n * ∑ i, c i - Real.log Z, c, ?_⟩
  · intro i
    have hs := hstationary i
    have hnum : (∑ f, embeddingIncidence f i * (μ f * Real.exp (y f))) =
        (d : ℝ) / n * Z := by
      have heq : (∑ f, μ f * Real.exp (y f) * (embeddingIncidence f i - (d : ℝ) / n)) =
          (∑ f, embeddingIncidence f i * (μ f * Real.exp (y f))) - (d : ℝ) / n * Z := by
        dsimp [Z, positiveExponentialSum]
        rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
        apply Finset.sum_congr rfl
        intro f _
        ring
      linarith
    simp only [ν, ← mul_div_assoc, ← Finset.sum_div, hnum]
    exact mul_div_cancel_right₀ _ (ne_of_gt hZ)
  · intro f
    have hyf : y f = (∑ j, c (f j)) - (d : ℝ) / n * ∑ i, c i := by
      simpa [L, centeredEmbeddingMap] using congrFun hc.symm f
    rw [show 1 - (d : ℝ) / n * (∑ i, c i) - Real.log Z + (∑ j, c (f j)) - 1 =
      y f - Real.log Z by rw [hyf]; ring, Real.exp_sub, Real.exp_log hZ]
    dsimp [ν]
    ring

end
end Paulsen
