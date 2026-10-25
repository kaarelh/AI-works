import AnalyticPrefixReduction
import Mathlib.Data.Nat.Log

open scoped BigOperators RealInnerProductSpace

namespace BooleanDepthResearch

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000

/-- Explicit logarithmic prefix depth, with slack for the margin decoder. -/
def compilerDepth (B : ℕ) : ℕ := 2 * (2 * B.log2 + 7)

/-- Deliberately loose polynomial width. -/
def compilerWidth (B : ℕ) : ℕ := 2 ^ 20 * B ^ 8

lemma compilerDepth_pos (B : ℕ) : 0 < compilerDepth B := by unfold compilerDepth; omega

lemma compilerDepth_le (B : ℕ) (hB : 1 ≤ B) : compilerDepth B ≤ 18 * B := by
  have := Nat.log2_le_self B
  unfold compilerDepth
  omega

lemma compilerWidth_pos (B : ℕ) (hB : 1 ≤ B) : 0 < compilerWidth B := by
  unfold compilerWidth
  positivity

lemma compilerDepth_count (B : ℕ) (hB : 1 ≤ B) : 2 ^ compilerDepth B ≤ 2 ^ 14 * B ^ 4 := by
  have hq : 2 ^ B.log2 ≤ B := Nat.log2_self_le (by omega)
  have he : compilerDepth B = B.log2 * 4 + 14 := by unfold compilerDepth; omega
  rw [he, pow_add, pow_mul]
  calc
    _ ≤ B ^ 4 * 2 ^ 14 := Nat.mul_le_mul_right _ (Nat.pow_le_pow_left hq 4)
    _ = _ := Nat.mul_comm _ _

lemma compilerDepth_radius (B : ℕ) :
    Real.sqrt 2 ^ compilerDepth B = 128 * ((2 : ℝ) ^ B.log2) ^ 2 := by
  unfold compilerDepth
  rw [pow_mul, Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2)]
  have he : 2 * B.log2 + 7 = B.log2 * 2 + 7 := by omega
  rw [he, pow_add, pow_mul]
  norm_num
  ring

lemma compilerDepth_radius_large (B : ℕ) (hB : 1 ≤ B) :
    32 * (B : ℝ) ^ 2 < Real.sqrt 2 ^ compilerDepth B := by
  have hlt : B < 2 ^ (B.log2 + 1) := by
    by_contra h
    have := (Nat.le_log2 (show B ≠ 0 by omega)).mpr (Nat.le_of_not_gt h)
    omega
  have hltR : (B : ℝ) < (2 : ℝ) ^ B.log2 * 2 := by exact_mod_cast (by simpa [pow_succ] using hlt)
  rw [compilerDepth_radius]
  have hq : 0 < (2 : ℝ) ^ B.log2 := by positivity
  have hBR : 0 ≤ (B : ℝ) := Nat.cast_nonneg B
  nlinarith

lemma compiler_budget {K : Type*} [Fintype K] [Nonempty K] {n : ℕ}
    (N : ScalarNetwork n) (B : ℕ) (hB : 1 ≤ B) (hP : N.product ≤ B)
    (hK : Real.log (Fintype.card K) ≤ (B : ℝ) ^ 2) :
    64 * (N.product * B * (compilerDepth B : ℝ)) ^ 2 * (1 + Real.log (Fintype.card K)) ≤
      (compilerWidth B : ℝ) * (1 / 4 : ℝ) ^ 2 := by
  have hBR : (1 : ℝ) ≤ B := by exact_mod_cast hB
  have hB0 : 0 ≤ (B : ℝ) := by positivity
  have hh : (compilerDepth B : ℝ) ≤ 18 * B := by exact_mod_cast compilerDepth_le B hB
  have hN1 : (1 : ℝ) ≤ Fintype.card K := by exact_mod_cast Fintype.card_pos
  have hL0 : 0 ≤ 1 + Real.log (Fintype.card K) := by linarith [Real.log_nonneg hN1]
  have hL : 1 + Real.log (Fintype.card K) ≤ 2 * (B : ℝ) ^ 2 := by nlinarith
  have hc : N.product * B * (compilerDepth B : ℝ) ≤ 18 * (B : ℝ) ^ 3 := by
    calc
      _ ≤ ((B : ℝ) * B) * (18 * B) := mul_le_mul
        (mul_le_mul_of_nonneg_right hP hB0) hh (by positivity) (by positivity)
      _ = _ := by ring
  have hc0 : 0 ≤ N.product * B * (compilerDepth B : ℝ) := by positivity [N.product_nonneg]
  have hsq := (sq_le_sq₀ hc0 (by positivity)).mpr hc
  calc
    _ ≤ 64 * (18 * (B : ℝ) ^ 3) ^ 2 * (2 * (B : ℝ) ^ 2) :=
      mul_le_mul (mul_le_mul_of_nonneg_left hsq (by norm_num)) hL hL0 (by positivity)
    _ = 41472 * (B : ℝ) ^ 8 := by ring
    _ ≤ 65536 * (B : ℝ) ^ 8 := mul_le_mul_of_nonneg_right (by norm_num) (by positivity)
    _ = _ := by norm_num [compilerWidth]; ring

lemma compiler_radius_small {n : ℕ} (N : ScalarNetwork n) (B : ℕ) (hB : 1 ≤ B)
    (hP : N.product ≤ B) :
    (2 * ((B : ℝ) / Real.sqrt 2 ^ compilerDepth B)) * (2 * N.product) < 1 := by
  have hBR : (1 : ℝ) ≤ B := by exact_mod_cast hB
  have hden : 0 < Real.sqrt 2 ^ compilerDepth B := by positivity
  have hbig := compilerDepth_radius_large B hB
  have hnum : 4 * (B : ℝ) * N.product < Real.sqrt 2 ^ compilerDepth B := by
    have hp := mul_le_mul_of_nonneg_left hP (by positivity : 0 ≤ (B : ℝ))
    nlinarith
  have he : (2 * ((B : ℝ) / Real.sqrt 2 ^ compilerDepth B)) * (2 * N.product) =
      (4 * (B : ℝ) * N.product) / Real.sqrt 2 ^ compilerDepth B := by ring
  rw [he]
  exact (div_lt_one hden).mpr hnum

lemma compiler_cover_radius_le (B : ℕ) (hB : 1 ≤ B) :
    2 * ((B : ℝ) / Real.sqrt 2 ^ compilerDepth B) ≤ 1 / (16 * B) := by
  have hBR : 0 < (B : ℝ) := by exact_mod_cast (show 0 < B by omega)
  have hden : 0 < Real.sqrt 2 ^ compilerDepth B := by positivity
  have hbig := compilerDepth_radius_large B hB
  rw [← mul_div_assoc]
  apply (div_le_div_iff₀ hden (by positivity : (0 : ℝ) < 16 * B)).mpr
  nlinarith

lemma label_sign_of_margin (a b : ℝ) (ha : |a| = 1) (hab : 0 < a * b) :
    (0 ≤ a ↔ 0 ≤ b) := by
  constructor
  · intro ha0
    rw [abs_of_nonneg ha0] at ha
    subst a
    simpa using hab.le
  · intro hb
    by_contra ha0
    have := mul_nonpos_of_nonpos_of_nonneg (le_of_lt (lt_of_not_ge ha0)) hb
    linarith

/-- An explicit polynomial analytic prefix reduction. The hypotheses on B are
exactly the bounds available after relevant-coordinate reduction on the Boolean
cube: product≤B, input norm≤B, and log(input count)≤B². The theorem proves an
actual finite positive-prototype decoder; it does not claim a circuit compiler. -/
theorem polynomial_analytic_prefix {K : Type*} [Fintype K] [Nonempty K] {n : ℕ}
    (N : ScalarNetwork n) (B : ℕ) (hB : 1 ≤ B) (hP : N.product ≤ B)
    (x : K → Euclid n) (hx : ∀ k, ‖x k‖ ≤ B)
    (hK : Real.log (Fintype.card K) ≤ (B : ℝ) ^ 2)
    (f : K → ℝ) (hf : ∀ k, |f k| = 1) (hmargin : ∀ k, 1 ≤ f k * N.eval (x k)) :
    ∃ M : ScalarNetwork n, 0 < M.product ∧ M.product ≤ 2 * B ∧
      M.hiddenDepth ≤ N.hiddenDepth ∧ M.PrefixWidth (compilerWidth B) (compilerDepth B) ∧
      (∀ k, (3 / 2 : ℝ) ≤ f k * M.eval (x k)) ∧
      (M.hiddenDepth < compilerDepth B ∨
        (M.prefixDim (compilerDepth B) ≤ compilerWidth B ∧
          ∃ C : Finset (Euclid (M.prefixDim (compilerDepth B))), C.card ≤ 2 ^ 14 * B ^ 4 ∧
            (∀ c ∈ C, ∃ k, M.normalizedPrefix (compilerDepth B) (x k) = c) ∧
            (∀ c ∈ C, ‖c‖ ≤ B) ∧
            (∀ k, ∃ c ∈ C, dist (M.normalizedPrefix (compilerDepth B) (x k)) c ≤ 1 / (16 * B)) ∧
            (∀ k, (0 ≤ f k ↔ ∃ c ∈ C,
              dist (M.normalizedPrefix (compilerDepth B) (x k)) c ≤ 1 / (8 * B) ∧
              0 ≤ M.normalizedSuffix (compilerDepth B) c)))) := by
  have hBR : 0 < (B : ℝ) := by exact_mod_cast (show 0 < B by omega)
  obtain ⟨M, hpos, hp, hd, hw, hmargin', hcases⟩ :=
    N.analytic_prefix_reduction (compilerDepth B) (compilerDepth_pos B) x f hf hmargin B hBR hx
      (compilerWidth B) (compilerWidth_pos B hB) (compiler_budget N B hB hP hK)
      (compiler_radius_small N B hB hP)
  have hMp : M.product ≤ 2 * B := hp.trans (mul_le_mul_of_nonneg_left hP (by norm_num))
  refine ⟨M, hpos, hMp, hd, hw, hmargin', ?_⟩
  rcases hcases with hshort | ⟨hdim, C, hCcard, hCactual, hCnorm, hCcover, _⟩
  · exact Or.inl hshort
  · right
    have hAbs : ∀ k, 1 ≤ |M.eval (x k)| := by
      intro k
      have ha := le_abs_self (f k * M.eval (x k))
      rw [abs_mul, hf k, one_mul] at ha
      linarith only [ha, hmargin' k]
    have hsmall : (1 / (8 * B : ℝ)) * M.product < 1 := by
      have hc : (1 / (8 * B : ℝ)) * (2 * B) = 1 / 4 := by field_simp; ring
      have he := mul_le_mul_of_nonneg_left hMp (by positivity : 0 ≤ 1 / (8 * B : ℝ))
      rw [hc] at he
      linarith only [he]
    have hsign : ∀ c k, dist (M.normalizedPrefix (compilerDepth B) (x k)) c ≤ 1 / (8 * B) →
        (0 ≤ M.eval (x k) ↔ 0 ≤ M.normalizedSuffix (compilerDepth B) c) := by
      intro c k hkc
      have hm : 1 ≤ |M.normalizedSuffix (compilerDepth B)
          (M.normalizedPrefix (compilerDepth B) (x k))| := by
        rw [M.normalized_eval_factor (compilerDepth B) hpos]
        exact hAbs k
      have hh := unit_margin_sign_center (M.normalizedSuffix_lipschitz (compilerDepth B)) hkc hm
        (by simpa only [NNReal.coe_mk] using hsmall)
      simpa only [M.normalized_eval_factor (compilerDepth B) hpos] using hh
    have hcover : ∀ k, ∃ c ∈ C, dist (M.normalizedPrefix (compilerDepth B) (x k)) c ≤ 1 / (16 * B) := by
      intro k
      obtain ⟨c, hc, hkc⟩ := hCcover k
      exact ⟨c, hc, hkc.trans (compiler_cover_radius_le B hB)⟩
    refine ⟨hdim, C, hCcard.trans (compilerDepth_count B hB), hCactual, hCnorm, hcover, ?_⟩
    intro k
    have hlabel : 0 ≤ f k ↔ 0 ≤ M.eval (x k) := label_sign_of_margin _ _ (hf k) (by linarith only [hmargin' k])
    constructor
    · intro hfk
      obtain ⟨c, hc, hkc⟩ := hcover k
      have hr : (1 / (16 * B : ℝ)) ≤ 1 / (8 * B) := by
        apply (div_le_div_iff₀ (by positivity : (0 : ℝ) < 16 * B) (by positivity : (0 : ℝ) < 8 * B)).mpr
        nlinarith only [hBR]
      exact ⟨c, hc, hkc.trans hr, (hsign c k (hkc.trans hr)).mp (hlabel.mp hfk)⟩
    · rintro ⟨c, _, hkc, hcpos⟩
      exact hlabel.mpr ((hsign c k hkc).mpr hcpos)

#print axioms polynomial_analytic_prefix

end
end BooleanDepthResearch
