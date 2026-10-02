import Paulsen.Paper.Toolbox
import Paulsen.ProjectionFactor
import Paulsen.ComplementReduction

/-!
# Helper for `Paulsen.Paper.Assembly`: complements of projections and row normalisation

* `complement_facts`: `(I-P)_{ii} - (n-k)/n = -(P_{ii} - k/n)` and `rank(I-P) = n - k`
  (the complement symmetry of the proof of `thm:projection`);
* `rowNormalize_facts`: for `x_i = √a u_i/‖u_i‖`, `‖X-U‖_F² ≤ δ²d` and
  `‖XᵀX - I‖ ≤ δ/(1-δ) ≤ 2δ` when `|p_i - a| ≤ δa`, `δ < 1/2`.
-/

namespace Paulsen.Paper.AssemblyAux

open Matrix Paulsen
open scoped BigOperators

noncomputable section

/-- Complement symmetry: diagonal errors and ranks of `I - P`. -/
theorem complement_facts {n : ℕ} (hn : 0 < n) (P : Frame n n) (k : ℕ)
    (hs : P.transpose = P) (hi : P * P = P) (hr : P.rank = k) :
    (∀ i, |(1 - P) i i - ((n - k : ℕ) : ℝ) / n| = |P i i - (k : ℝ) / n|) ∧
    (1 - P).rank = n - k := by
  have hkn : k ≤ n := hr ▸ Matrix.rank_le_height P
  have hnR : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  refine ⟨fun i => ?_, ?_⟩
  · rw [Matrix.sub_apply, Matrix.one_apply_eq, Nat.cast_sub hkn]
    have : (1 : ℝ) - P i i - ((n : ℝ) - k) / n = -(P i i - (k : ℝ) / n) := by
      field_simp; ring
    rw [this, abs_neg]
  · obtain ⟨U, hU, hUP⟩ := exists_parseval_of_symmetric_idempotent P hs hi
    obtain ⟨V, hV, hcomp, -⟩ := IsParseval.exists_complement U hU (Matrix.rank_le_height P)
    have h1 : 1 - P = frameProjection V := by
      have e : P = U * U.transpose := hUP.symm
      calc 1 - P = U * U.transpose + V * V.transpose - U * U.transpose := by rw [hcomp, ← e]
        _ = frameProjection V := by unfold frameProjection; abel
    rw [h1, hV.frameProjection_rank, hr]

/-- `(√a - √p)² ≤ (p - a)²/a` for `a > 0`, `p ≥ 0`. -/
theorem sqrt_sub_sq_le {a p : ℝ} (ha : 0 < a) (hp : 0 ≤ p) :
    (Real.sqrt a - Real.sqrt p) ^ 2 ≤ (p - a) ^ 2 / a := by
  have hsa : 0 < Real.sqrt a := Real.sqrt_pos.mpr ha
  have hsp : 0 ≤ Real.sqrt p := Real.sqrt_nonneg p
  have hpa : (p - a) ^ 2 = (Real.sqrt a - Real.sqrt p) ^ 2 * (Real.sqrt a + Real.sqrt p) ^ 2 := by
    have h1 := Real.sq_sqrt ha.le
    have h2 := Real.sq_sqrt hp
    nlinarith [h1, h2]
  rw [hpa, le_div_iff₀ ha]
  have hge : a ≤ (Real.sqrt a + Real.sqrt p) ^ 2 := by
    have h1 := Real.sq_sqrt ha.le
    nlinarith
  have := sq_nonneg (Real.sqrt a - Real.sqrt p)
  nlinarith

/-- Row normalisation `x_i = √a u_i / ‖u_i‖` of a Parseval frame with small relative row error. -/
theorem rowNormalize_facts {n d : ℕ} (hn : 0 < n) (hd : 1 ≤ d) (U : Frame n d)
    (hU : IsParseval U) {β : ℝ} (hβ : 0 ≤ β)
    (herr : ∀ i, |rowNormSq U i - (d : ℝ) / n| ≤ β) (hδ : β / ((d : ℝ) / n) < 1 / 2) :
    IsEqualNorm (Matrix.of fun i j =>
        Real.sqrt ((d : ℝ) / n) * U i j / Real.sqrt (rowNormSq U i) : Frame n d) ∧
    sqDistance (Matrix.of fun i j =>
        Real.sqrt ((d : ℝ) / n) * U i j / Real.sqrt (rowNormSq U i) : Frame n d) U ≤
      (β / ((d : ℝ) / n)) ^ 2 * d ∧
    IsNearlyParseval (2 * (β / ((d : ℝ) / n))) (Matrix.of fun i j =>
        Real.sqrt ((d : ℝ) / n) * U i j / Real.sqrt (rowNormSq U i) : Frame n d) := by
  set a := (d : ℝ) / n with ha_def
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd
  have ha : 0 < a := div_pos hdR hnR
  set δ := β / a with hδ_def
  have hδ0 : 0 ≤ δ := div_nonneg hβ ha.le
  have hβa : β = δ * a := by rw [hδ_def]; field_simp
  have hp : ∀ i, a / 2 < rowNormSq U i := by
    intro i
    have h := abs_le.mp (herr i)
    have : β < a / 2 := by rw [hβa]; nlinarith
    linarith [h.1]
  have hp0 : ∀ i, 0 < rowNormSq U i := fun i => lt_trans (by positivity) (hp i)
  set X : Frame n d := Matrix.of fun i j => Real.sqrt a * U i j / Real.sqrt (rowNormSq U i)
    with hX
  have hXrow : ∀ i j, X i j = (Real.sqrt a / Real.sqrt (rowNormSq U i)) * U i j := by
    intro i j; simp only [hX, Matrix.of_apply]; ring
  have hsq : ∀ i, (Real.sqrt a / Real.sqrt (rowNormSq U i)) ^ 2 = a / rowNormSq U i := by
    intro i
    rw [div_pow, Real.sq_sqrt ha.le, Real.sq_sqrt (hp0 i).le]
  refine ⟨?_, ?_, ?_⟩
  · intro i
    unfold rowNormSq
    simp only [hXrow, mul_pow, ← Finset.mul_sum, hsq]
    change a / rowNormSq U i * rowNormSq U i = a
    field_simp [(hp0 i).ne']
  · -- `‖X - U‖_F² = ∑_i (√a - √p_i)² ≤ ∑ (p_i - a)²/a ≤ n β²/a = δ² d`
    have hrow : ∀ i, ∑ j, (X i j - U i j) ^ 2 =
        (Real.sqrt a - Real.sqrt (rowNormSq U i)) ^ 2 := by
      intro i
      have hs : Real.sqrt (rowNormSq U i) ≠ 0 := (Real.sqrt_pos.mpr (hp0 i)).ne'
      have h1 : ∀ j, (X i j - U i j) ^ 2 =
          (Real.sqrt a / Real.sqrt (rowNormSq U i) - 1) ^ 2 * U i j ^ 2 := by
        intro j; rw [hXrow]; ring
      simp only [h1, ← Finset.mul_sum]
      change (Real.sqrt a / Real.sqrt (rowNormSq U i) - 1) ^ 2 * rowNormSq U i = _
      set s := Real.sqrt (rowNormSq U i) with hs_def
      have hp' : rowNormSq U i = s ^ 2 := (Real.sq_sqrt (hp0 i).le).symm
      rw [hp']
      field_simp
    unfold sqDistance
    simp only [hrow]
    calc ∑ i, (Real.sqrt a - Real.sqrt (rowNormSq U i)) ^ 2
        ≤ ∑ _i : Fin n, β ^ 2 / a := by
          apply Finset.sum_le_sum; intro i _
          refine (sqrt_sub_sq_le ha (hp0 i).le).trans ?_
          apply div_le_div_of_nonneg_right _ ha.le
          have := herr i
          rw [← sq_abs]
          exact pow_le_pow_left₀ (abs_nonneg _) this 2
      _ = δ ^ 2 * d := by
          rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, hβa, ha_def]
          field_simp
  · intro x
    have hE : frameEnergy X x = ∑ i, a / rowNormSq U i * (∑ j, U i j * x j) ^ 2 := by
      unfold frameEnergy
      apply Finset.sum_congr rfl; intro i _
      simp only [hXrow, mul_assoc, ← Finset.mul_sum, mul_pow, hsq]
    have hEU : ∑ i, (∑ j, U i j * x j) ^ 2 = vectorNormSq x := hU.frameEnergy_eq x
    have hcoef : ∀ i, |a / rowNormSq U i - 1| ≤ 2 * δ := by
      intro i
      have hpi := hp0 i
      have h1 : a / rowNormSq U i - 1 = (a - rowNormSq U i) / rowNormSq U i := by
        field_simp
      rw [h1, abs_div, abs_of_pos hpi, div_le_iff₀ hpi]
      have h2 := herr i
      rw [abs_sub_comm] at h2
      have h3 : a / 2 < rowNormSq U i := hp i
      have h4 : β ≤ 2 * δ * (a / 2) := by rw [hβa]; linarith
      nlinarith
    have hlow : ∀ i, (1 - 2 * δ) * (∑ j, U i j * x j) ^ 2 ≤
        a / rowNormSq U i * (∑ j, U i j * x j) ^ 2 := by
      intro i
      apply mul_le_mul_of_nonneg_right _ (sq_nonneg _)
      linarith [(abs_le.mp (hcoef i)).1]
    have hupp : ∀ i, a / rowNormSq U i * (∑ j, U i j * x j) ^ 2 ≤
        (1 + 2 * δ) * (∑ j, U i j * x j) ^ 2 := by
      intro i
      apply mul_le_mul_of_nonneg_right _ (sq_nonneg _)
      linarith [(abs_le.mp (hcoef i)).2]
    rw [hE, ← hEU]
    constructor
    · rw [Finset.mul_sum]; exact Finset.sum_le_sum fun i _ => hlow i
    · rw [Finset.mul_sum]; exact Finset.sum_le_sum fun i _ => hupp i

/-- `‖X‖_F² = tr XᵀX ≤ (1+ε)d` for an `ε`-nearly Parseval `X`. -/
theorem frobSq_le_of_nearlyParseval {n d : ℕ} {ε : ℝ} (X : Frame n d)
    (hX : IsNearlyParseval ε X) : frobSq X ≤ (1 + ε) * d := by
  have h : frobSq X = ∑ j : Fin d, frameEnergy X (Pi.single j 1) := by
    unfold frobSq frameEnergy
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl; intro j _
    apply Finset.sum_congr rfl; intro i _
    congr 1
    simp [Pi.single_apply]
  rw [h]
  calc ∑ j : Fin d, frameEnergy X (Pi.single j 1) ≤ ∑ _j : Fin d, (1 + ε) := by
        apply Finset.sum_le_sum; intro j _
        have := (hX (Pi.single j 1)).2
        have hv : vectorNormSq (Pi.single j (1 : ℝ) : Fin d → ℝ) = 1 := by
          simp [vectorNormSq, Pi.single_apply]
        rwa [hv, mul_one] at this
    _ = (1 + ε) * d := by simp; ring

end

end Paulsen.Paper.AssemblyAux
