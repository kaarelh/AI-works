import NeuralGeneralization.WalshLaplacian

/-!
# From polynomial approximation to failure of buffered confidence

This deterministic closing argument uses the actual confidence values, a
conditional-mean margin outside an explicit exceptional set, and squared
Fourier approximation bounds. The sampling and spectral bounds producing
these hypotheses remain separate mathematical obligations.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators

namespace NeuralGeneralization.ConfidenceClipping
open Classical
attribute [local instance] Classical.propDecidable

variable {d : ℕ}

def fraction (A : Set (ClippingCube d)) : ℝ :=
  uniformCubeMean (fun x => if x ∈ A then 1 else 0)

def failure (q : ClippingCube d → ℝ) (θ : ℝ) : ℝ := fraction {x | q x ≤ θ}

theorem mean_mono (f g : ClippingCube d → ℝ) (h : ∀ x, f x ≤ g x) :
    uniformCubeMean f ≤ uniformCubeMean g :=
  div_le_div_of_nonneg_right (Finset.sum_le_sum fun x _ => h x) (Nat.cast_nonneg _)

theorem mean_const (c : ℝ) : uniformCubeMean (fun _ : ClippingCube d => c) = c := by
  simp [uniformCubeMean]

theorem fraction_union_le (A B : Set (ClippingCube d)) :
    fraction (A ∪ B) ≤ fraction A + fraction B := by
  unfold fraction uniformCubeMean
  rw [← add_div, ← Finset.sum_add_distrib]
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg _)
  apply Finset.sum_le_sum
  intro x hx
  by_cases hA : x ∈ A <;> by_cases hB : x ∈ B <;> simp [hA, hB]

theorem fraction_large_residual_le (R : ClippingCube d → ℝ) (b : ℝ) (hb : 0 < b) :
    fraction {x | b ≤ |R x|} ≤ uniformCubeMean (fun x => R x ^ 2) / b ^ 2 := by
  have hh := mean_mono (fun x => if b ≤ |R x| then (1 : ℝ) else 0)
    (fun x => R x ^ 2 / b ^ 2) (fun x => by
      split_ifs with hx
      · apply (le_div_iff₀ (sq_pos_of_pos hb)).mpr
        have hs := mul_self_le_mul_self hb.le hx
        simpa only [one_mul, ← pow_two, sq_abs] using hs
      · positivity)
  simpa only [fraction, Set.mem_setOf_eq, uniformCubeMean, Finset.sum_div, div_right_comm] using hh

theorem signed_clip_lower (P : ClippingCube d → ℝ) (b : ℝ) (hb : 0 < b) (x : ClippingCube d) :
    -1 ≤ fullParity x * symmetricClip b (P x) := by
  rw [← symmetricClip_mul_sign b (P x) (fullParity x) (fullParity_sign x),
    symmetricClip_eq_max_min b _ hb]
  exact le_max_left _ _

theorem signed_clip_eq_one (P : ClippingCube d → ℝ) (b : ℝ) (hb : 0 < b)
    (x : ClippingCube d) (hx : b ≤ fullParity x * P x) :
    fullParity x * symmetricClip b (P x) = 1 := by
  rw [← symmetricClip_mul_sign b (P x) (fullParity x) (fullParity_sign x),
    symmetricClip_eq_max_min b _ hb]
  have hh : 1 ≤ fullParity x * P x / b := (le_div_iff₀ hb).mpr (by simpa using hx)
  simp [min_eq_left hh]

theorem correlation_lower_of_confidence_margin (q P : ClippingCube d → ℝ)
    (θ b : ℝ) (hb : 0 < b) (B : Set (ClippingCube d))
    (hm : ∀ x, θ < q x → x ∉ B → b ≤ fullParity x * P x) :
    1 - 2 * failure q θ - 2 * fraction B ≤
      uniformCubeMean (fun x => fullParity x * symmetricClip b (P x)) := by
  have hp (x : ClippingCube d) :
      1 - 2 * (if q x ≤ θ then (1 : ℝ) else 0) -
        2 * (if x ∈ B then (1 : ℝ) else 0) ≤ fullParity x * symmetricClip b (P x) := by
    have hl := signed_clip_lower P b hb x
    by_cases hq : q x ≤ θ
    · by_cases hB : x ∈ B <;> simp only [hq, hB, if_true, if_false] <;> linarith
    · by_cases hB : x ∈ B
      · simp only [if_neg hq, if_pos hB]
        linarith
      · rw [if_neg hq, if_neg hB, signed_clip_eq_one P b hb x
          (hm x (lt_of_not_ge hq) hB)]
        norm_num
  have hh := mean_mono _ _ hp
  have he : uniformCubeMean (fun x =>
      1 - 2 * (if q x ≤ θ then (1 : ℝ) else 0) - 2 * (if x ∈ B then (1 : ℝ) else 0)) =
      1 - 2 * failure q θ - 2 * fraction B := by
    unfold failure fraction uniformCubeMean
    simp only [Set.mem_setOf_eq, Finset.sum_sub_distrib, ← Finset.mul_sum,
      Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
    have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
      ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
    field_simp
  rwa [he] at hh

theorem failure_lower_of_polynomial_margin {u : ℕ} (hd : 0 < d)
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ u)
    (q : ClippingCube d → ℝ) (θ b : ℝ) (hb : 0 < b) (B : Set (ClippingCube d))
    (hm : ∀ x, θ < q x → x ∉ B → b ≤ fullParity x * walshExpansion a x)
    (hB : fraction B ≤ 1 / 16)
    (hhead : (u : ℝ) ^ 2 * uniformCubeMean (fun x => walshExpansion a x ^ 2) ≤
      (b * (d : ℝ)) ^ 2 / 64) :
    (3 : ℝ) / 8 ≤ failure q θ := by
  let corr := uniformCubeMean (fun x => fullParity x * symmetricClip b (walshExpansion a x))
  have hs := (cube_clipped_parity_degree_bound_squared hd a hdegree b hb).trans hhead
  have hbd : 0 < (b * (d : ℝ)) ^ 2 := sq_pos_of_pos (mul_pos hb (Nat.cast_pos.mpr hd))
  have hc2 : corr ^ 2 ≤ 1 / 64 := by
    apply (mul_le_mul_iff_right₀ hbd).mp
    simpa only [corr, div_eq_mul_inv, one_mul] using hs
  have hc : corr ≤ 1 / 8 := by nlinarith [sq_nonneg (corr - 1 / 8)]
  have hl := correlation_lower_of_confidence_margin q (walshExpansion a) θ b hb B hm
  change _ ≤ corr at hl
  linarith

/-- The negative-exponent closing step with actual residual and variance
exceptional sets: a small squared residual and a small exceptional fraction
are sufficient for the explicit three-eighths buffered-confidence failure. -/
theorem failure_lower_of_mean_approximation {u : ℕ} (hd : 0 < d)
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ u)
    (q m : ClippingCube d → ℝ) (θ b : ℝ) (hb : 0 < b) (V : Set (ClippingCube d))
    (hm : ∀ x, θ < q x → x ∉ V → 2 * b ≤ fullParity x * m x)
    (hV : fraction V ≤ 1 / 32)
    (htail : uniformCubeMean (fun x => (m x - walshExpansion a x) ^ 2) ≤ b ^ 2 / 32)
    (hhead : (u : ℝ) ^ 2 * uniformCubeMean (fun x => walshExpansion a x ^ 2) ≤
      (b * (d : ℝ)) ^ 2 / 64) :
    (3 : ℝ) / 8 ≤ failure q θ := by
  let T : Set (ClippingCube d) := {x | b ≤ |m x - walshExpansion a x|}
  have hT : fraction T ≤ 1 / 32 := by
    have hh := fraction_large_residual_le (fun x => m x - walshExpansion a x) b hb
    have hb2 := sq_pos_of_pos hb
    apply hh.trans
    apply (div_le_iff₀ hb2).mpr
    nlinarith
  apply failure_lower_of_polynomial_margin hd a hdegree q θ b hb (V ∪ T) _ _ hhead
  · intro x hq hx
    have hVx : x ∉ V := fun h => hx (Or.inl h)
    have hTx : x ∉ T := fun h => hx (Or.inr h)
    have hr : |m x - walshExpansion a x| < b := lt_of_not_ge hTx
    have hmean := hm x hq hVx
    have ha := abs_le.mp hr.le
    rcases fullParity_sign x with hf | hf <;> rw [hf] at hmean ⊢ <;> nlinarith
  · exact (fraction_union_le V T).trans (by linarith)

end NeuralGeneralization.ConfidenceClipping
