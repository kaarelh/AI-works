import Paulsen.Paper.SampleAuxBall

/-!
# Helpers for `ModerateSample`: the soft count `F_i` of (S3)

`F_i(g) = (1/n) ∑_{k ≠ i} φ((P_ik + t Y_ik)/s)` with `s = t √(a/n)`: smoothness, the gradient
bound `‖∇F_i‖ ≤ 4/(h√d)`, and the bound on `E F_i`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators NNReal

noncomputable section

/-- The coordinate `g ↦ Y_ik(g)` as a continuous linear functional. -/
abbrev tangentCoord {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i k : Fin n) :
    StrongDual ℝ (FrameVector n d) :=
  gaussianCoordinate (tangentF U ρ) (i, k)

/-- The soft count `F_i`. -/
def softCount {n d : ℕ} (U : Frame n d) (ρ t s : ℝ) (φ : ℝ → ℝ) (i : Fin n)
    (g : FrameVector n d) : ℝ :=
  (1 / (n : ℝ)) * ∑ k ∈ Finset.univ.erase i,
    φ ((frameProjection U i k + t * tangentCoord U ρ i k g) / s)

theorem softCount_eq {n d : ℕ} (U : Frame n d) (ρ t s : ℝ) (φ : ℝ → ℝ) (i : Fin n) :
    (fun g : FrameVector n d => (1 / (n : ℝ)) * ∑ k ∈ Finset.univ.erase i,
      φ ((frameProjection U i k + t * tangentY U (moderateNoise U ρ g) i k) / s)) =
      softCount U ρ t s φ i := by
  funext g
  simp only [softCount, tangentY_moderateNoise_apply, gaussianCoordinate_apply]

theorem hasFDerivAt_softCount {n d : ℕ} (U : Frame n d) (ρ t s : ℝ) {φ : ℝ → ℝ}
    (hφ : ContDiff ℝ 1 φ) (i : Fin n) (g : FrameVector n d) :
    HasFDerivAt (softCount U ρ t s φ i)
      ((1 / (n : ℝ)) • ∑ k ∈ Finset.univ.erase i,
        deriv φ ((frameProjection U i k + t * tangentCoord U ρ i k g) / s) •
          (s⁻¹ • (t • tangentCoord U ρ i k))) g := by
  have hd : Differentiable ℝ φ := hφ.differentiable (by norm_num)
  have hk : ∀ k ∈ Finset.univ.erase i, HasFDerivAt
      (fun g => φ ((frameProjection U i k + t * tangentCoord U ρ i k g) / s))
      (deriv φ ((frameProjection U i k + t * tangentCoord U ρ i k g) / s) •
        (s⁻¹ • (t • tangentCoord U ρ i k))) g := by
    intro k _
    have hin : HasFDerivAt (fun g => (frameProjection U i k + t * tangentCoord U ρ i k g) / s)
        (s⁻¹ • (t • tangentCoord U ρ i k)) g := by
      have h0 := ((((tangentCoord U ρ i k).hasFDerivAt (x := g)).const_mul t).const_add
        (frameProjection U i k)).mul_const s⁻¹
      exact h0.congr_of_eventuallyEq (Filter.Eventually.of_forall fun y => div_eq_mul_inv _ _)
    exact (hd _).hasDerivAt.comp_hasFDerivAt g hin
  exact (HasFDerivAt.fun_sum hk).const_mul (1 / (n : ℝ))

theorem contDiff_softCount {n d : ℕ} (U : Frame n d) (ρ t s : ℝ) {φ : ℝ → ℝ}
    (hφ : ContDiff ℝ 1 φ) (i : Fin n) : ContDiff ℝ 1 (softCount U ρ t s φ i) := by
  unfold softCount
  apply ContDiff.mul contDiff_const
  apply ContDiff.sum
  intro k _
  apply hφ.comp
  exact ContDiff.div_const (ContDiff.add contDiff_const
    (ContDiff.mul contDiff_const (tangentCoord U ρ i k).contDiff)) s

/-- `∑_{k ≠ i} Y_ik(v)² ≤ ‖Y_v‖_F² ≤ (2/n)‖v‖²`. -/
theorem sum_sq_tangentCoord_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U) {ρ : ℝ}
    (hρ : 0 ≤ ρ) (i : Fin n) (v : FrameVector n d) :
    ∑ k ∈ Finset.univ.erase i, (tangentCoord U ρ i k v) ^ 2 ≤ 2 / (n : ℝ) * ‖v‖ ^ 2 := by
  have h1 : ∑ k ∈ Finset.univ.erase i, (tangentCoord U ρ i k v) ^ 2 ≤
      ∑ k, (Matrix.toEuclideanLin (tangentF U ρ) v (i, k)) ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun _ _ _ => sq_nonneg _)
  have h2 : ∑ k, (Matrix.toEuclideanLin (tangentF U ρ) v (i, k)) ^ 2 ≤
      ‖Matrix.toEuclideanLin (tangentF U ρ) v‖ ^ 2 := by
    rw [EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type]
    exact Finset.single_le_sum (f := fun j => ∑ k, (Matrix.toEuclideanLin (tangentF U ρ) v (j, k)) ^ 2)
      (fun j _ => Finset.sum_nonneg fun k _ => sq_nonneg _) (Finset.mem_univ i)
  have h3 : ‖Matrix.toEuclideanLin (tangentF U ρ) v‖ ^ 2 ≤ opNorm (tangentF U ρ) ^ 2 * ‖v‖ ^ 2 := by
    rw [← mul_pow]
    exact pow_le_pow_left₀ (norm_nonneg _)
      ((Matrix.toEuclideanLin (tangentF U ρ)).toContinuousLinearMap.le_opNorm v) 2
  have h4 := mul_le_mul_of_nonneg_right (opNorm_tangentF_sq hU hρ) (sq_nonneg ‖v‖)
  linarith

/-- The gradient bound `‖∇F_i‖ ≤ 4/(h√d)` for `s = t√(a/n)`. -/
theorem norm_fderiv_softCount_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (hn : 0 < n)
    (hd : 0 < d) {ρ t h : ℝ} (hρ : 0 ≤ ρ) (ht : 0 < t) (hh : 0 < h) {φ : ℝ → ℝ}
    (hφ : ContDiff ℝ 1 φ) (hφ' : ∀ x, |deriv φ x| ≤ 2 / h) (i : Fin n) (g : FrameVector n d) :
    ‖fderiv ℝ (softCount U ρ t (t * Real.sqrt (((d : ℝ) / n) / n)) φ i) g‖ ≤
      4 / (h * Real.sqrt d) := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  set s := t * Real.sqrt (((d : ℝ) / n) / n)
  have hsq : Real.sqrt (((d : ℝ) / n) / n) = Real.sqrt d / n := by
    rw [div_div, Real.sqrt_div hdR.le, Real.sqrt_mul_self hnR.le]
  have hsd : 0 < Real.sqrt d := Real.sqrt_pos.mpr hdR
  have hs : 0 < s := by simp only [s]; rw [hsq]; positivity
  have hts : s⁻¹ * t = n / Real.sqrt d := by
    simp only [s, hsq]; field_simp
  rw [(hasFDerivAt_softCount U ρ t s hφ i g).fderiv]
  apply ContinuousLinearMap.opNorm_le_bound _ (by positivity)
  intro v
  simp only [_root_.smul_apply, _root_.sum_apply, smul_eq_mul, Real.norm_eq_abs]
  set S := Finset.univ.erase i
  have hS : (S.card : ℝ) ≤ n := by
    have := Finset.card_le_univ S
    simp only [Fintype.card_fin] at this
    exact_mod_cast this
  have hcs : ∑ k ∈ S, |tangentCoord U ρ i k v| ≤
      Real.sqrt S.card * Real.sqrt (∑ k ∈ S, (tangentCoord U ρ i k v) ^ 2) := by
    have := Real.sum_mul_le_sqrt_mul_sqrt S (fun _ => (1 : ℝ)) (fun k => |tangentCoord U ρ i k v|)
    simpa using this
  have hsum := sum_sq_tangentCoord_le hU hρ i v
  have hroot : Real.sqrt (∑ k ∈ S, (tangentCoord U ρ i k v) ^ 2) ≤
      Real.sqrt (2 / (n : ℝ)) * ‖v‖ := by
    rw [← Real.sqrt_sq (norm_nonneg v), ← Real.sqrt_mul (by positivity)]
    exact Real.sqrt_le_sqrt hsum
  have hterm : ∀ k ∈ S, |deriv φ ((frameProjection U i k + t * tangentCoord U ρ i k g) / s) *
      (s⁻¹ * (t * tangentCoord U ρ i k v))| ≤ 2 / h * (n / Real.sqrt d) *
        |tangentCoord U ρ i k v| := by
    intro k _
    rw [show s⁻¹ * (t * tangentCoord U ρ i k v) = (s⁻¹ * t) * tangentCoord U ρ i k v by ring,
      hts, abs_mul, abs_mul, abs_of_pos (by positivity : (0 : ℝ) < n / Real.sqrt d)]
    rw [← mul_assoc]
    exact mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right (hφ' _) (by positivity))
      (abs_nonneg _)
  calc |1 / (n : ℝ) * ∑ k ∈ S, deriv φ ((frameProjection U i k + t * tangentCoord U ρ i k g) / s) *
        (s⁻¹ * (t * tangentCoord U ρ i k v))|
      ≤ 1 / (n : ℝ) * ∑ k ∈ S, 2 / h * (n / Real.sqrt d) * |tangentCoord U ρ i k v| := by
        rw [abs_mul, abs_of_pos (by positivity : (0 : ℝ) < 1 / n)]
        exact mul_le_mul_of_nonneg_left ((Finset.abs_sum_le_sum_abs _ _).trans
          (Finset.sum_le_sum hterm)) (by positivity)
    _ = 2 / h * (1 / Real.sqrt d) * ∑ k ∈ S, |tangentCoord U ρ i k v| := by
        rw [← Finset.mul_sum]; field_simp
    _ ≤ 2 / h * (1 / Real.sqrt d) * (Real.sqrt n * (Real.sqrt (2 / (n : ℝ)) * ‖v‖)) := by
        apply mul_le_mul_of_nonneg_left _ (by positivity)
        refine hcs.trans ?_
        exact mul_le_mul (Real.sqrt_le_sqrt hS) hroot (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
    _ = 2 / h * (1 / Real.sqrt d) * (Real.sqrt 2 * ‖v‖) := by
        have e : Real.sqrt n * Real.sqrt (2 / n) = Real.sqrt 2 := by
          rw [← Real.sqrt_mul hnR.le, mul_div_cancel₀ _ hnR.ne']
        rw [← e]; ring
    _ ≤ 4 / (h * Real.sqrt d) * ‖v‖ := by
        have h2 : Real.sqrt 2 ≤ 2 := by
          rw [Real.sqrt_le_left (by norm_num)]; norm_num
        have e : 2 / h * (1 / Real.sqrt d) * (Real.sqrt 2 * ‖v‖) =
            (2 * Real.sqrt 2) / (h * Real.sqrt d) * ‖v‖ := by field_simp
        rw [e]
        apply mul_le_mul_of_nonneg_right _ (norm_nonneg v)
        apply div_le_div_of_nonneg_right _ (by positivity)
        linarith

end

end Paulsen.Paper
