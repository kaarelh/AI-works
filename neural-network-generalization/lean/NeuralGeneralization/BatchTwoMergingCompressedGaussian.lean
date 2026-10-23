import NeuralGeneralization.BatchTwoMergingBasis

/-! # The independent Gaussian law of all compressed network coordinates -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.BatchTwoMerging

open ConcreteModel

abbrev CompressedIndex (d N r : ℕ) (p : LayerPartitions N r) :=
  (Fin (populationCount (p 0)) × Fin (d + 1)) ⊕
    ((Σ s : Fin r, Fin (populationCount (p s.succ)) ×
      Fin (populationCount (p s.castSucc))) ⊕
        Fin (populationCount (p (Fin.last r))))

def compressionRow {d N r : ℕ} (p : LayerPartitions N r) :
    CompressedIndex d N r p → WeightIndex d N r → ℝ
  | Sum.inl (a, b), Sum.inl (i, j) =>
      populationBasis (p 0) a i * if b = j then 1 else 0
  | Sum.inr (Sum.inl ⟨s, a, b⟩), Sum.inr (Sum.inl (t, i, j)) =>
      if s = t then populationBasis (p s.succ) a i *
        populationBasis (p s.castSucc) b j else 0
  | Sum.inr (Sum.inr a), Sum.inr (Sum.inr i) =>
      populationBasis (p (Fin.last r)) a i
  | _, _ => 0

theorem tensor_populationBasis_gram {N : ℕ} (p q : PopulationPartition N)
    (a a' : Fin (populationCount p)) (b b' : Fin (populationCount q)) :
    (∑ i, ∑ j, (populationBasis p a i * populationBasis q b j) *
      (populationBasis p a' i * populationBasis q b' j)) =
        (if a = a' then 1 else 0) * (if b = b' then 1 else 0) := by
  calc
    _ = ∑ i, (populationBasis p a i * populationBasis p a' i) *
        ∑ j, populationBasis q b j * populationBasis q b' j := by
      apply Finset.sum_congr rfl
      intro i _
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      ring
    _ = (∑ i, populationBasis p a i * populationBasis p a' i) *
        ∑ j, populationBasis q b j * populationBasis q b' j := by rw [Finset.sum_mul]
    _ = _ := by rw [populationBasis_sum_mul, populationBasis_sum_mul]

theorem compressionRow_gram {d N r : ℕ} (p : LayerPartitions N r)
    (a b : CompressedIndex d N r p) :
    (∑ i, compressionRow p a i * compressionRow p b i) = if a = b then 1 else 0 := by
  classical
  rcases a with ⟨a, j⟩ | a <;> rcases b with ⟨b, k⟩ | b
  · simp only [Fintype.sum_sum_type, Fintype.sum_prod_type, compressionRow,
      zero_mul, Finset.sum_const_zero, add_zero]
    by_cases hjk : j = k
    · subst k
      simp only [mul_ite, mul_one, mul_zero, ite_mul, zero_mul]
      simp only [Finset.sum_ite_eq', Finset.sum_ite_eq, Finset.mem_univ, ↓reduceIte,
        ite_self]
      rw [populationBasis_sum_mul]
      simp
    · have hsum (i : Fin N) :
          (∑ t : Fin (d + 1), (populationBasis (p 0) a i * if j = t then 1 else 0) *
            (populationBasis (p 0) b i * if k = t then 1 else 0)) = 0 := by
        apply Finset.sum_eq_zero
        intro t _
        by_cases hj : j = t
        · have hk : k ≠ t := by intro hk; exact hjk (hj.trans hk.symm)
          simp [hk]
        · simp [hj]
      simp only [hsum, Finset.sum_const_zero]
      simp [hjk]
  · rcases b with b | b <;>
      simp [Fintype.sum_sum_type, Fintype.sum_prod_type, compressionRow]
  · rcases a with a | a <;>
      simp [Fintype.sum_sum_type, Fintype.sum_prod_type, compressionRow]
  · rcases a with ⟨s, a, a'⟩ | a <;> rcases b with ⟨t, b, b'⟩ | b
    · simp only [Fintype.sum_sum_type, Fintype.sum_prod_type, compressionRow,
        zero_mul, Finset.sum_const_zero, zero_add, add_zero]
      by_cases hst : s = t
      · subst t
        simp only [ite_mul_ite, zero_mul, Finset.sum_ite_irrel, Finset.sum_const_zero]
        simp only [Finset.sum_ite_eq', Finset.sum_ite_eq, Finset.mem_univ, ↓reduceIte,
          ite_self]
        rw [tensor_populationBasis_gram]
        by_cases ha : a = b <;> by_cases hb : a' = b' <;> simp [ha, hb]
      · have hsum (u : Fin r) (i j : Fin N) :
            (if s = u then populationBasis (p s.succ) a i *
                populationBasis (p s.castSucc) a' j else 0) *
              (if t = u then populationBasis (p t.succ) b i *
                populationBasis (p t.castSucc) b' j else 0) = 0 := by
          by_cases hs : s = u
          · have ht : t ≠ u := by intro ht; exact hst (hs.trans ht.symm)
            simp [ht]
          · simp [hs]
        simp only [hsum, Finset.sum_const_zero]
        simp [hst]
    · simp [Fintype.sum_sum_type, Fintype.sum_prod_type, compressionRow]
    · simp [Fintype.sum_sum_type, Fintype.sum_prod_type, compressionRow]
    · simp only [Fintype.sum_sum_type, Fintype.sum_prod_type, compressionRow,
        zero_mul, Finset.sum_const_zero, zero_add]
      rw [populationBasis_sum_mul]
      simp

def compressedWhitened {d N r : ℕ} (p : LayerPartitions N r)
    (w : Weights d N r) : CompressedIndex d N r p → ℝ :=
  fun a => ∑ i, compressionRow p a i * whiten w i

theorem measurable_compressedWhitened {d N r : ℕ} (p : LayerPartitions N r) :
    Measurable (compressedWhitened (d := d) p) := by
  unfold compressedWhitened
  apply measurable_pi_lambda
  intro a
  exact Finset.measurable_sum _ fun i _ =>
    measurable_const.mul ((measurable_pi_apply i).comp (continuous_whiten d N r).measurable)

/-- All first, internal, and readout compressed coordinates are independent,
with common variance `σ²=t²/N`, under the actual finite network prior. -/
theorem smallPrior_map_compressedWhitened {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (p : LayerPartitions N r) :
    (smallPrior d N r σ).map (compressedWhitened p) =
      Measure.pi (fun _ : CompressedIndex d N r p => gaussianReal 0 (σ ^ 2).toNNReal) := by
  have heq : compressedWhitened p =
      (fun z a => ∑ i, compressionRow p a i * z i) ∘ (whiten : Weights d N r → _) := rfl
  rw [heq, ← Measure.map_map (by fun_prop) (continuous_whiten d N r).measurable,
    map_smallPrior_whiten hd hN hσ]
  exact productGaussian_map_orthonormal_rows (compressionRow p) (compressionRow_gram p) _

end NeuralGeneralization.BatchTwoMerging
