import Paulsen.Paper.SampleAuxBall2

/-!
# Helpers for `ModerateSample`: the mean and the tail of the soft count `F_i` (S3)
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators NNReal

noncomputable section

theorem integrable_phi_comp {n d : ℕ} (φ : ℝ → ℝ) (hφc : Continuous φ)
    (hφ01 : ∀ x, 0 ≤ φ x ∧ φ x ≤ 1) (L : StrongDual ℝ (FrameVector n d)) (m t s : ℝ) :
    Integrable (fun g => φ ((m + t * L g) / s)) (gaussAmb n d) := by
  apply (integrable_const (1 : ℝ)).mono'
  · exact (hφc.comp ((continuous_const.add (continuous_const.mul L.continuous)).div_const
      s)).aestronglyMeasurable
  · exact ae_of_all _ fun g => by
      rw [Real.norm_eq_abs, abs_of_nonneg (hφ01 _).1]; exact (hφ01 _).2

/-- The bound on `E F_i` from the variance count. -/
theorem integral_softCount_le {n d : ℕ} (U : Frame n d) (hn : 0 < n) {ρ t h : ℝ} (ht : 0 < t)
    (hh : 0 < h) (ha : 0 < (d : ℝ) / n) {φ : ℝ → ℝ} (hφ : ContDiff ℝ 1 φ)
    (hφ01 : ∀ x, 0 ≤ φ x ∧ φ x ≤ 1) (hφ0 : ∀ x, 2 * h < |x| → φ x = 0) (i : Fin n)
    (hgood : 99 / 100 * (n : ℝ) ≤
      ((Finset.univ.filter (fun k => k ≠ i ∧ (d : ℝ) / n / (16 * n) ≤
        ∫ g, tangentY U (moderateNoise U ρ g) i k ^ 2 ∂gaussAmb n d)).card : ℝ)) :
    ∫ g, softCount U ρ t (t * Real.sqrt (((d : ℝ) / n) / n)) φ i g ∂gaussAmb n d ≤
      1 / 100 + 4 * h / Real.sqrt (2 * Real.pi / 16) := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hφc : Continuous φ := hφ.continuous
  have han : 0 < ((d : ℝ) / n) / n := by positivity
  set B := Real.sqrt (((d : ℝ) / n) / n) with hBdef
  have hB : 0 < B := Real.sqrt_pos.mpr han
  set s := t * B
  have hs : 0 < s := by positivity
  set A := Real.sqrt (2 * Real.pi / 16) with hAdef
  have hA : 0 < A := Real.sqrt_pos.mpr (by positivity)
  set c := 4 * h / A
  have hc : 0 ≤ c := by positivity
  set S := Finset.univ.erase i
  set G := Finset.univ.filter (fun k => k ≠ i ∧ (d : ℝ) / n / (16 * n) ≤
    ∫ g, tangentY U (moderateNoise U ρ g) i k ^ 2 ∂gaussAmb n d)
  set f : Fin n → ℝ := fun k => ∫ g, φ ((frameProjection U i k + t * tangentCoord U ρ i k g) / s)
    ∂gaussAmb n d
  have hint : ∫ g, softCount U ρ t s φ i g ∂gaussAmb n d = (1 / (n : ℝ)) * ∑ k ∈ S, f k := by
    unfold softCount
    rw [integral_const_mul, integral_finsetSum _ (fun k _ =>
      integrable_phi_comp φ hφc hφ01 (tangentCoord U ρ i k) _ t s)]
  have hf1 : ∀ k, f k ≤ 1 := by
    intro k
    calc f k ≤ ∫ _g, (1 : ℝ) ∂gaussAmb n d :=
          integral_mono (integrable_phi_comp φ hφc hφ01 _ _ t s) (integrable_const _)
            (fun g => (hφ01 _).2)
      _ = 1 := by simp
  have hfc : ∀ k ∈ G, f k ≤ c := by
    intro k hk
    have hk' := (Finset.mem_filter.mp hk).2
    have hvar : ‖tangentCoord U ρ i k‖ ^ 2 = ∫ g, tangentY U (moderateNoise U ρ g) i k ^ 2
        ∂gaussAmb n d := by
      rw [← integral_sq_dual_stdGaussian]
      simp_rw [tangentY_moderateNoise_apply]
      rfl
    have hL2 : ((d : ℝ) / n) / n / 16 ≤ ‖tangentCoord U ρ i k‖ ^ 2 := by
      rw [hvar]
      calc ((d : ℝ) / n) / n / 16 = (d : ℝ) / n / (16 * n) := by ring
        _ ≤ _ := hk'.2
    have hL : 0 < ‖tangentCoord U ρ i k‖ := by
      have : 0 < ‖tangentCoord U ρ i k‖ ^ 2 := lt_of_lt_of_le (by positivity) hL2
      exact lt_of_le_of_ne (norm_nonneg _) (fun h0 => by rw [← h0] at this; simp at this)
    have h1 := integral_phi_affine_le_density φ hφc hφ01 hh hφ0 (tangentCoord U ρ i k) hL
      (frameProjection U i k) hs ht
    refine h1.trans ?_
    have hden : A * B ≤ Real.sqrt (2 * Real.pi * ‖tangentCoord U ρ i k‖ ^ 2) := by
      rw [hAdef, hBdef, ← Real.sqrt_mul (by positivity)]
      apply Real.sqrt_le_sqrt
      nlinarith [Real.pi_pos]
    calc 4 * h * s / t * (Real.sqrt (2 * Real.pi * ‖tangentCoord U ρ i k‖ ^ 2))⁻¹
        ≤ 4 * h * s / t * (A * B)⁻¹ := by
          apply mul_le_mul_of_nonneg_left _ (by positivity)
          exact inv_anti₀ (by positivity) hden
      _ = c := by
          simp only [s, c]
          field_simp
  have hGS : S.filter (fun k => k ∈ G) = G := by
    ext k
    simp only [Finset.mem_filter, S, Finset.mem_erase, G, Finset.mem_univ, true_and, and_true]
    tauto
  have hsplit := Finset.sum_filter_add_sum_filter_not S (fun k => k ∈ G) f
  have hcard := Finset.card_filter_add_card_filter_not (s := S) (fun k => k ∈ G)
  have hScard : S.card = n - 1 := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ, Fintype.card_fin]
  rw [hGS] at hsplit hcard
  have hbad : ((S.filter (fun k => k ∉ G)).card : ℝ) ≤ 1 / 100 * n := by
    have h1 : (G.card : ℝ) + ((S.filter (fun k => k ∉ G)).card : ℝ) = (n : ℝ) - 1 := by
      have h2 : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
        rw [Nat.cast_sub (by omega)]; simp
      rw [← h2, ← hScard]; exact_mod_cast hcard
    linarith
  have hsum1 : ∑ k ∈ G, f k ≤ (G.card : ℝ) * c := by
    have := Finset.sum_le_card_nsmul G f c hfc
    simpa [nsmul_eq_mul] using this
  have hsum2 : ∑ k ∈ S.filter (fun k => k ∉ G), f k ≤ ((S.filter (fun k => k ∉ G)).card : ℝ) := by
    have := Finset.sum_le_card_nsmul (S.filter (fun k => k ∉ G)) f 1 (fun k _ => hf1 k)
    simpa [nsmul_eq_mul] using this
  have hGc : (G.card : ℝ) ≤ n := by
    have := Finset.card_le_univ G
    simp only [Fintype.card_fin] at this
    exact_mod_cast this
  rw [hint, ← hsplit]
  have hmain : ∑ k ∈ G, f k + ∑ k ∈ S.filter (fun k => k ∉ G), f k ≤ (n : ℝ) * c + 1 / 100 * n := by
    have := mul_le_mul_of_nonneg_right hGc hc
    linarith
  calc (1 / (n : ℝ)) * (∑ k ∈ G, f k + ∑ k ∈ S.filter (fun k => k ∉ G), f k)
      ≤ (1 / (n : ℝ)) * ((n : ℝ) * c + 1 / 100 * n) :=
        mul_le_mul_of_nonneg_left hmain (by positivity)
    _ = 1 / 100 + c := by field_simp; ring

/-- The upper tail of `F_i`, from `lem:gauss`(b). -/
theorem softCount_tail {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (hn : 0 < n)
    (hd : 0 < d) {ρ t h : ℝ} (hρ : 0 ≤ ρ) (ht : 0 < t) (hh : 0 < h) {φ : ℝ → ℝ}
    (hφ : ContDiff ℝ 1 φ) (hφ' : ∀ x, |deriv φ x| ≤ 2 / h) (i : Fin n) :
    (gaussAmb n d).real {g | ∫ g', softCount U ρ t (t * Real.sqrt (((d : ℝ) / n) / n)) φ i g'
        ∂gaussAmb n d + 1 / 100 < softCount U ρ t (t * Real.sqrt (((d : ℝ) / n) / n)) φ i g} ≤
      2 * Real.exp (-2 * (1 / 100) ^ 2 / (Real.pi ^ 2 * (4 / (h * Real.sqrt d)) ^ 2)) := by
  have hb := lem_gauss_b (softCount U ρ t (t * Real.sqrt (((d : ℝ) / n) / n)) φ i)
    (contDiff_softCount U ρ t _ hφ i) (ℓ := 4 / (h * Real.sqrt d))
    (fun g => norm_fderiv_softCount_le hU hn hd hρ ht hh hφ hφ' i g)
    (u := 1 / 100) (by norm_num)
  refine (measureReal_mono ?_).trans hb
  intro g hg
  simp only [Set.mem_setOf_eq] at hg ⊢
  rw [lt_abs]
  left
  linarith

end

end Paulsen.Paper
