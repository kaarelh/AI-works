import NeuralGeneralization.PrunedNetwork

/-! # Actual readout rescaling and coefficient control for norm compression -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.CompressionSampling
open ConcreteModel

def rescaleReadout {d N r : ℕ} (c : ℝ) (w : Weights d N r) : Weights d N r
  | Sum.inl ij => w (Sum.inl ij)
  | Sum.inr (Sum.inl sij) => w (Sum.inr (Sum.inl sij))
  | Sum.inr (Sum.inr i) => c * w (Sum.inr (Sum.inr i))

@[simp] theorem rescaleReadout_firstHidden {d N r : ℕ} (c : ℝ) (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d) : firstHidden φ (rescaleReadout c w) x = firstHidden φ w x := rfl

@[simp] theorem rescaleReadout_hiddenStep {d N r : ℕ} (c : ℝ) (φ : ℝ → ℝ)
    (w : Weights d N r) (h : Fin N → ℝ) (s : Fin r) :
    hiddenStep φ (rescaleReadout c w) h s = hiddenStep φ w h s := rfl

@[simp] theorem rescaleReadout_output {d N r : ℕ} (c : ℝ) (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d) :
    networkOutput φ (rescaleReadout c w) x = c * networkOutput φ w x := by
  have hh : finalHidden φ (rescaleReadout c w) x = finalHidden φ w x := rfl
  simp only [networkOutput, hh, rescaleReadout, mul_assoc, Finset.mul_sum]

theorem rescaleReadout_cost_le {d N r : ℕ} {c : ℝ} (hc : 1 ≤ c)
    (w : Weights d N r) : weightedSquaredNorm (rescaleReadout c w) ≤
      c ^ 2 * weightedSquaredNorm w := by
  have hc2 : 1 ≤ c ^ 2 := by nlinarith
  have hf : 0 ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2) := by positivity
  have hi : 0 ≤ ∑ s, ∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j))) ^ 2 := by positivity
  have hfi := mul_nonneg (show 0 ≤ c ^ 2 - 1 by linarith) (add_nonneg hf hi)
  simp only [weightedSquaredNorm, rescaleReadout, mul_pow, ← Finset.mul_sum]
  nlinarith

/-- Once the width dominates the cost, every individual coefficient is bounded
    by that width, including the first-layer scaling `d/N`. -/
theorem boundedWeights_of_cost {d N r : ℕ} (hd : 1 ≤ d) (hN : 1 ≤ N)
    (w : Weights d N r) (hw : weightedSquaredNorm w ≤ (N : ℝ)) :
    boundedWeights N w := by
  have hdR : 1 ≤ (d : ℝ) := by exact_mod_cast hd
  have hNR : 1 ≤ (N : ℝ) := by exact_mod_cast hN
  have hNp : 0 < (N : ℝ) := by linarith
  have hNne : (N : ℝ) ≠ 0 := ne_of_gt hNp
  have hf : 0 ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2) := by positivity
  have hi : 0 ≤ ∑ s, ∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j))) ^ 2 := by positivity
  have ho : 0 ≤ (N : ℝ) * ∑ i, w (Sum.inr (Sum.inr i)) ^ 2 := by positivity
  intro index
  apply abs_le_of_sq_le_sq _ hNp.le
  rcases index with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · have hrow : w (Sum.inl (i,j)) ^ 2 ≤ ∑ b, w (Sum.inl (i,b)) ^ 2 :=
      Finset.single_le_sum (fun b _ => sq_nonneg (w (Sum.inl (i,b)))) (Finset.mem_univ j)
    have hmatrix : (∑ b, w (Sum.inl (i,b)) ^ 2) ≤ ∑ a, ∑ b, w (Sum.inl (a,b)) ^ 2 :=
      Finset.single_le_sum (f := fun a => ∑ b, w (Sum.inl (a,b)) ^ 2)
        (fun _ _ => by positivity) (Finset.mem_univ i)
    have hm := mul_le_mul_of_nonneg_left (hrow.trans hmatrix)
      (show 0 ≤ (d : ℝ) / N by positivity)
    have hterm : (d : ℝ) / N * w (Sum.inl (i,j)) ^ 2 ≤ (N : ℝ) := by
      unfold weightedSquaredNorm at hw
      linarith
    have hmult := mul_le_mul_of_nonneg_right hterm hNp.le
    have hcancel : (d : ℝ) / N * w (Sum.inl (i,j)) ^ 2 * N =
        (d : ℝ) * w (Sum.inl (i,j)) ^ 2 := by field_simp
    rw [hcancel] at hmult
    nlinarith [sq_nonneg (w (Sum.inl (i,j)))]
  · have hrow : w (Sum.inr (Sum.inl (s,i,j))) ^ 2 ≤
        ∑ b, w (Sum.inr (Sum.inl (s,i,b))) ^ 2 :=
      Finset.single_le_sum (fun b _ => sq_nonneg (w (Sum.inr (Sum.inl (s,i,b))))) (Finset.mem_univ j)
    have hmatrix : (∑ b, w (Sum.inr (Sum.inl (s,i,b))) ^ 2) ≤
        ∑ a, ∑ b, w (Sum.inr (Sum.inl (s,a,b))) ^ 2 :=
      Finset.single_le_sum (f := fun a => ∑ b, w (Sum.inr (Sum.inl (s,a,b))) ^ 2)
        (fun _ _ => by positivity) (Finset.mem_univ i)
    have hb := (hrow.trans hmatrix).trans ((internal_squaredNorm_le_cost w s).trans hw)
    nlinarith
  · have hsum : w (Sum.inr (Sum.inr i)) ^ 2 ≤ ∑ b, w (Sum.inr (Sum.inr b)) ^ 2 :=
      Finset.single_le_sum (fun b _ => sq_nonneg (w (Sum.inr (Sum.inr b)))) (Finset.mem_univ i)
    have hm := mul_le_mul_of_nonneg_left hsum hNp.le
    have hb := (output_squaredNorm_mul_width_le_cost w).trans hw
    nlinarith [sq_nonneg (w (Sum.inr (Sum.inr i)))]

/-- Approximation by 1/12, followed by readout rescaling by 3/2, preserves the
    requested strict global 1/2 margin. -/
theorem rescaleReadout_preserves_margin {d N M r : ℕ} (φ : ℝ → ℝ)
    (f : BooleanFunction d) (w : Weights d N r) (v : Weights d M r)
    (hw : w ∈ marginEvent φ (1 / 2) f)
    (herr : ∀ x, |networkOutput φ v x - networkOutput φ w x| ≤ 1 / 12) :
    rescaleReadout (3 / 2) v ∈ marginEvent φ (1 / 2) f := by
  intro x
  have hm := hw x
  have he := herr x
  have habs : |labelReal (f x) * (networkOutput φ v x - networkOutput φ w x)| ≤ 1 / 12 := by
    simpa only [abs_mul, abs_labelReal, one_mul] using he
  have hl := (abs_le.mp habs).1
  simp only [rescaleReadout_output]
  nlinarith

end NeuralGeneralization.CompressionSampling
