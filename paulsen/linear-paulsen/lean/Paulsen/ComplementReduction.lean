import Paulsen.FrameComplement
import Paulsen.FrameAlignment
import Paulsen.QuadraticBound

/-!
# From low-density Parseval corrections to every density

Complementation preserves projection distance and absolute diagonal error.
The relative error changes by the ratio of complementary ranks. Large
relative error is handled by the trivial projection-distance bound.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

/-- Passing from frame distance to projection distance loses at most two. -/
theorem projection_sqDistance_le_twice {n d : ℕ}
    (U V : Frame n d) (hU : IsParseval U) (hV : IsParseval V) :
    sqDistance (frameProjection U) (frameProjection V) ≤ 2 * sqDistance U V := by
  let A := U.transpose * V
  have hnonneg := sqDistance_nonneg A (1 : Matrix (Fin d) (Fin d) ℝ)
  simp only [sqDistance_eq_energies_sub_trace, Matrix.transpose_one, Matrix.mul_one,
    Matrix.trace_one, Fintype.card_fin, Matrix.trace_transpose] at hnonneg
  rw [Matrix.trace_mul_comm A.transpose A] at hnonneg
  rw [parseval_projection_distance_crossGram U V hU hV,
    sqDistance_eq_energies_sub_trace, hU, hV]
  simp only [Matrix.trace_one, Fintype.card_fin]
  change 2 * (d : ℝ) - 2 * (A * A.transpose).trace ≤
    2 * ((d : ℝ) + d - 2 * A.trace)
  linarith

/-- The trivial projection-distance bound depends on rank with coefficient two. -/
theorem parseval_projection_sqDistance_le_twice_rank {n d : ℕ}
    (U V : Frame n d) (hU : IsParseval U) (hV : IsParseval V) :
    sqDistance (frameProjection U) (frameProjection V) ≤ 2 * (d : ℝ) := by
  rw [parseval_projection_distance_crossGram U V hU hV]
  have henergy : 0 ≤ ((U.transpose * V) * (U.transpose * V).transpose).trace := by
    rw [Matrix.trace_mul_comm, ← entry_sq_sum_eq_trace]
    positivity
  linarith

/-- A projection-distance bound from an exact target lifts to a frame correction. -/
theorem hasCorrection_of_projection_distance {n d : ℕ}
    (U W : Frame n d) (hU : IsParseval U) (hW : IsEqualNormParseval W)
    (c : ℝ) (hc : sqDistance (frameProjection U) (frameProjection W) ≤ c) :
    HasCorrection U c := by
  obtain ⟨R, hRR, hRtR, hdist⟩ := exists_parseval_frame_alignment U W hU hW.1
  exact ⟨W * R, ⟨hW.1.mul_orthogonal R hRtR, hW.2.mul_orthogonal R hRR⟩,
    hdist.trans hc⟩

theorem parseval_hasCorrection_trivial {n d : ℕ}
    (hn : 0 < n) (hdn : d ≤ n) (U : Frame n d) (hU : IsParseval U) :
    HasCorrection U (2 * (d : ℝ)) := by
  obtain ⟨W, hW⟩ := exists_equalNormParseval hn hdn
  exact hasCorrection_of_projection_distance U W hU hW _
    (parseval_projection_sqDistance_le_twice_rank U W hU hW.1)

theorem sqDistance_one_sub {n : ℕ} (P Q : Matrix (Fin n) (Fin n) ℝ) :
    sqDistance (1 - P) (1 - Q) = sqDistance P Q := by
  unfold sqDistance
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  simp only [Matrix.sub_apply]
  ring

/-- Correcting the complementary projection gives a correction in the original
rank with exactly the same projection-distance budget. -/
theorem hasCorrection_of_complement_projection_distance {n d : ℕ}
    (hdn : d ≤ n) (U : Frame n d) (V W : Frame n (n - d))
    (hU : IsParseval U)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (hW : IsEqualNormParseval W) (c : ℝ)
    (hc : sqDistance (frameProjection V) (frameProjection W) ≤ c) :
    HasCorrection U c := by
  have hk : n - d ≤ n := Nat.sub_le _ _
  obtain ⟨Z, hZp, hZcomplete, _hZorth⟩ := hW.1.exists_complement W hk
  have hZn := hW.2.complement hk Z hZcomplete
  have hdim : n - (n - d) = d := Nat.sub_sub_self hdn
  have hZ : ∃ Z : Frame n d, IsEqualNormParseval Z ∧
      W * W.transpose + Z * Z.transpose = 1 := by
    have hZ' : ∃ Z : Frame n (n - (n - d)), IsEqualNormParseval Z ∧
        W * W.transpose + Z * Z.transpose = 1 := ⟨Z, ⟨hZp, hZn⟩, hZcomplete⟩
    rw [hdim] at hZ'
    exact hZ'
  obtain ⟨Z, hZ, hZW⟩ := hZ
  apply hasCorrection_of_projection_distance U Z hU hZ c
  have hPU : frameProjection U = 1 - frameProjection V := by
    change U * U.transpose = 1 - V * V.transpose
    exact eq_sub_of_add_eq hcomplete
  have hPZ : frameProjection Z = 1 - frameProjection W := by
    change Z * Z.transpose = 1 - W * W.transpose
    exact eq_sub_of_add_eq (by simpa only [add_comm] using hZW)
  rw [hPU, hPZ, sqDistance_one_sub]
  exact hc

/-- Every Parseval frame also has a trivial correction costing twice its
complementary rank. This includes the full-rank, zero-cost endpoint. -/
theorem parseval_hasCorrection_complement_trivial {n d : ℕ}
    (hn : 0 < n) (hdn : d ≤ n) (U : Frame n d) (hU : IsParseval U) :
    HasCorrection U (2 * ((n - d : ℕ) : ℝ)) := by
  obtain ⟨V, hV, hcomplete, _⟩ := hU.exists_complement U hdn
  obtain ⟨W, hW⟩ := exists_equalNormParseval hn (Nat.sub_le n d)
  exact hasCorrection_of_complement_projection_distance hdn U V W hU hcomplete hW _
    (parseval_projection_sqDistance_le_twice_rank V W hV hW.1)

/-- A uniform low-density theorem for small positive relative row error implies
an all-density Parseval theorem. The low-density theorem remains an explicit
hypothesis; all geometry and large-error cases are proved here. -/
theorem all_density_parseval_bound_of_low_density (C : ℝ) (hC : 0 ≤ C)
    (H : ∀ n d : ℕ, 0 < d → 2 * d ≤ n → ∀ ε : ℝ,
      0 < ε → ε ≤ 1 / 2 → ∀ U : Frame n d,
      IsParseval U → IsNearlyEqualNorm ε U → HasCorrection U (C * ε * (d : ℝ))) :
    ∀ n d : ℕ, 0 < d → d ≤ n → ∀ ε : ℝ, 0 < ε →
      ∀ U : Frame n d, IsParseval U → IsNearlyEqualNorm ε U →
        HasCorrection U ((2 * C + 4) * ε * (d : ℝ)) := by
  intro n d hd hdn ε hε U hU hUn
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  have hdR : 0 ≤ (d : ℝ) := Nat.cast_nonneg d
  have hcost0 : 0 ≤ (2 * C + 4) * ε * (d : ℝ) := by positivity
  by_cases hlow : 2 * d ≤ n
  · by_cases hsmall : ε ≤ 1 / 2
    · apply (H n d hd hlow ε hε hsmall U hU hUn).mono
      have hcoeff : C ≤ 2 * C + 4 := by linarith
      exact mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hcoeff hε.le) hdR
    · apply (parseval_hasCorrection_trivial hn hdn U hU).mono
      have hlarge : 1 / 2 < ε := lt_of_not_ge hsmall
      have hfour : 2 * (d : ℝ) ≤ 4 * ε * (d : ℝ) := by
        nlinarith [mul_nonneg (show 0 ≤ 2 * ε - 1 by linarith) hdR]
      exact hfour.trans (mul_le_mul_of_nonneg_right
        (mul_le_mul_of_nonneg_right (by linarith : (4 : ℝ) ≤ 2 * C + 4) hε.le) hdR)
  · by_cases hk0 : n - d = 0
    · apply (parseval_hasCorrection_complement_trivial hn hdn U hU).mono
      simpa only [hk0, Nat.cast_zero, mul_zero] using hcost0
    · have hk : 0 < n - d := Nat.pos_of_ne_zero hk0
      have hkn : 2 * (n - d) ≤ n := by omega
      have hkd : d < n := by omega
      have hkR : 0 < ((n - d : ℕ) : ℝ) := Nat.cast_pos.mpr hk
      let δ := ε * (d : ℝ) / ((n - d : ℕ) : ℝ)
      have hδ : 0 < δ := div_pos (mul_pos hε (Nat.cast_pos.mpr hd)) hkR
      have hcancel : δ * ((n - d : ℕ) : ℝ) = ε * (d : ℝ) :=
        div_mul_cancel₀ _ (ne_of_gt hkR)
      by_cases hsmall : δ ≤ 1 / 2
      · obtain ⟨V, hV, hcomplete, _⟩ := hU.exists_complement U hdn
        have hVn := hUn.complement hkd V hcomplete
        obtain ⟨W, hW, hVW⟩ := H n (n - d) hk hkn δ hδ hsmall V hV hVn
        apply hasCorrection_of_complement_projection_distance hdn U V W hU hcomplete hW
          ((2 * C + 4) * ε * (d : ℝ))
        have hproj := projection_sqDistance_le_twice V W hV hW.1
        have hcost : C * δ * ((n - d : ℕ) : ℝ) = C * ε * (d : ℝ) := by
          rw [mul_assoc, hcancel]
          ring
        rw [hcost] at hVW
        nlinarith [mul_nonneg hε.le hdR]
      · apply (parseval_hasCorrection_complement_trivial hn hdn U hU).mono
        have hlarge : 1 / 2 < δ := lt_of_not_ge hsmall
        have hfour : 2 * ((n - d : ℕ) : ℝ) ≤ 4 * ε * (d : ℝ) := by
          nlinarith [mul_nonneg (show 0 ≤ 2 * δ - 1 by linarith) hkR.le]
        exact hfour.trans (mul_le_mul_of_nonneg_right
          (mul_le_mul_of_nonneg_right (by linarith : (4 : ℝ) ≤ 2 * C + 4) hε.le) hdR)

end Paulsen
