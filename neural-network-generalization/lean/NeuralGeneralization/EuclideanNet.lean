import Mathlib.MeasureTheory.Measure.Lebesgue.EqHaar
import Mathlib.MeasureTheory.Measure.OpenPos
import Mathlib.MeasureTheory.Measure.Real
import Mathlib.Order.Lattice.Nat
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

/-!
# Sharp finite-dimensional nets from Haar-volume packing

A maximal finite quarter-separated subset of the unit ball is a quarter-net.
Disjoint radius-eighth balls give at most `9^dimension` points. In particular
this does not incur the extra logarithm of dimension from a coordinate grid.
-/

noncomputable section

namespace NeuralGeneralization

open MeasureTheory MeasureTheory.Measure Metric
open scoped BigOperators

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
  [MeasurableSpace E] [BorelSpace E] [FiniteDimensional ℝ E]
  (μ : Measure E) [IsAddHaarMeasure μ]

lemma haar_real_ball_scale (x : E) (r : ℝ) (hr : 0 < r) :
    μ.real (ball x r) = r ^ Module.finrank ℝ E * μ.real (ball (0 : E) 1) := by
  simp only [measureReal_def, Measure.addHaar_ball_of_pos μ x hr,
    ENNReal.toReal_mul, ENNReal.toReal_ofReal (pow_nonneg hr.le _)]

include μ

/-- The sharp cardinal bound for any quarter-separated unit-ball packing. -/
theorem quarter_separated_card_le (s : Finset E)
    (hunit : ∀ x ∈ s, ‖x‖ ≤ 1)
    (hsep : ∀ x ∈ s, ∀ y ∈ s, x ≠ y → (1 / 4 : ℝ) < dist x y) :
    s.card ≤ 9 ^ Module.finrank ℝ E := by
  have hdisj : Set.PairwiseDisjoint (s : Set E) (fun x => ball x (1 / 8 : ℝ)) := by
    intro x hx y hy hxy
    apply ball_disjoint_ball
    have hh := hsep x hx y hy hxy
    linarith
  have hsubset : (⋃ x ∈ s, ball x (1 / 8 : ℝ)) ⊆ ball (0 : E) (9 / 8 : ℝ) := by
    intro z hz
    obtain ⟨x, hx, hzx⟩ := Set.mem_iUnion₂.mp hz
    have hdist := dist_triangle z x (0 : E)
    have hnorm : dist x (0 : E) ≤ 1 := by simpa using hunit x hx
    change dist z (0 : E) < (9 / 8 : ℝ)
    change dist z x < (1 / 8 : ℝ) at hzx
    linarith
  have hmeasure := measureReal_mono (μ := μ) hsubset
  rw [measureReal_biUnion_finset hdisj (fun _ _ => measurableSet_ball)] at hmeasure
  simp_rw [haar_real_ball_scale μ _ _ (by norm_num : (0 : ℝ) < 1 / 8)] at hmeasure
  rw [haar_real_ball_scale μ _ _ (by norm_num : (0 : ℝ) < 9 / 8)] at hmeasure
  simp only [Finset.sum_const, nsmul_eq_mul] at hmeasure
  have hv : 0 < μ.real (ball (0 : E) 1) :=
    ENNReal.toReal_pos (ne_of_gt (measure_ball_pos μ (0 : E) (by norm_num))) measure_ball_ne_top
  have hpower : 0 < (1 / 8 : ℝ) ^ Module.finrank ℝ E := pow_pos (by norm_num) _
  have hscale : (9 / 8 : ℝ) ^ Module.finrank ℝ E =
      (9 : ℝ) ^ Module.finrank ℝ E * (1 / 8 : ℝ) ^ Module.finrank ℝ E := by
    rw [← mul_pow]
    congr 1
    norm_num
  rw [hscale] at hmeasure
  have hcancel : (s.card : ℝ) ≤ (9 : ℝ) ^ Module.finrank ℝ E := by
    apply (mul_le_mul_iff_right₀ (mul_pos hpower hv)).mp
    simpa only [mul_assoc, mul_comm, mul_left_comm] using hmeasure
  exact_mod_cast hcancel

/-- A quarter-net in the unit ball with at most `9^dimension` points. The
net points themselves lie in the unit ball, which is needed for Gaussian
bilinear-form variance bounds. -/
theorem exists_quarter_net :
    ∃ s : Finset E, s.card ≤ 9 ^ Module.finrank ℝ E ∧
      (∀ x ∈ s, ‖x‖ ≤ 1) ∧
      ∀ x : E, ‖x‖ ≤ 1 → ∃ y ∈ s, dist x y ≤ (1 / 4 : ℝ) := by
  classical
  let P : Finset E → Prop := fun s =>
    (∀ x ∈ s, ‖x‖ ≤ 1) ∧
    (∀ x ∈ s, ∀ y ∈ s, x ≠ y → (1 / 4 : ℝ) < dist x y)
  let cards : Set ℕ := {n | ∃ s : Finset E, P s ∧ s.card = n}
  have hne : cards.Nonempty := by
    refine ⟨0, ∅, ?_, rfl⟩
    simp only [P, Finset.notMem_empty, false_implies, implies_true, and_self]
  have hbdd : BddAbove cards := by
    refine ⟨9 ^ Module.finrank ℝ E, ?_⟩
    rintro n ⟨s, hs, rfl⟩
    exact quarter_separated_card_le μ s hs.1 hs.2
  obtain ⟨s, hs, hcard⟩ := Nat.sSup_mem hne hbdd
  refine ⟨s, quarter_separated_card_le μ s hs.1 hs.2, hs.1, ?_⟩
  intro x hx
  by_contra hcover
  have hfar : ∀ y ∈ s, (1 / 4 : ℝ) < dist x y := by
    intro y hy
    exact lt_of_not_ge (fun hxy => hcover ⟨y, hy, hxy⟩)
  have hnot : x ∉ s := by
    intro hxs
    have hh := hfar x hxs
    simp only [dist_self] at hh
    norm_num at hh
  have hinsert : P (insert x s) := by
    constructor
    · intro y hy
      rcases Finset.mem_insert.mp hy with rfl | hy
      · exact hx
      · exact hs.1 y hy
    · intro y hy z hz hyz
      rcases Finset.mem_insert.mp hy with hyx | hyS
      · subst y
        rcases Finset.mem_insert.mp hz with hzx | hzS
        · exact (hyz hzx.symm).elim
        · exact hfar z hzS
      · rcases Finset.mem_insert.mp hz with hzx | hzS
        · subst z
          simpa only [dist_comm] using hfar y hyS
        · exact hs.2 y hyS z hzS hyz
  have hmem : (insert x s).card ∈ cards := ⟨insert x s, hinsert, rfl⟩
  have hle := le_csSup hbdd hmem
  rw [Finset.card_insert_of_notMem hnot, ← hcard] at hle
  omega

end NeuralGeneralization
