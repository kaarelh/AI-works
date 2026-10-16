import Mathlib.Analysis.InnerProductSpace.Projection.Minimal
import Mathlib.Analysis.Convex.Topology
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

/-!
# Existence of bounded readout dual coefficients

This is the finite geometric readout lemma used in the mean-field proof.
It is proved from the minimum-norm point of a finite convex hull, rather
than taking KKT multipliers as an assumption. It does not use Gaussian
probability, the neural-network compression theorem, or new axioms.
-/

namespace NeuralGeneralization.ReadoutDual

open scoped BigOperators
open Finset

variable {ι E : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]

omit [Nonempty ι] in
/-- Every point of a finite indexed convex hull has simplex coefficients
on the original full index type, including repeated feature vectors. -/
lemma convexHull_range_weights (a : ι → E) {c : E}
    (hc : c ∈ convexHull ℝ (Set.range a)) :
    ∃ w : ι → ℝ, (∀ i, 0 ≤ w i) ∧ ∑ i, w i = 1 ∧
      (∑ i, w i • a i) = c := by
  rw [convexHull_range_eq_exists_affineCombination] at hc
  obtain ⟨s, w, hw, hsum, hrep⟩ := hc
  rw [Finset.affineCombination_eq_linear_combination s a w hsum] at hrep
  let v : ι → ℝ := fun i => if i ∈ s then w i else 0
  refine ⟨v, ?_, ?_, ?_⟩
  · intro i
    by_cases hi : i ∈ s
    · simpa [v, hi] using hw i hi
    · simp [v, hi]
  · simpa [v] using hsum
  · simpa [v, ite_smul] using hrep

/-- Given a positive margin witness, there are nonnegative dual coefficients
whose induced readout retains that margin and whose total mass is bounded
by the squared norm of the witness divided by the margin. -/
theorem exists_readout_dual (a : ι → E) (u : E) {margin : ℝ}
    (hmargin_pos : 0 < margin)
    (hmargin : ∀ i, margin ≤ inner ℝ (a i) u) :
    ∃ lam : ι → ℝ, (∀ i, 0 ≤ lam i) ∧
      margin * (∑ i, lam i) ≤ ‖u‖ ^ 2 ∧
      ∀ i, margin ≤ inner ℝ (a i) (∑ j, lam j • a j) := by
  classical
  let K : Set E := convexHull ℝ (Set.range a)
  have haK (i : ι) : a i ∈ K := subset_convexHull ℝ (Set.range a) ⟨i, rfl⟩
  have hKne : K.Nonempty := by
    obtain ⟨i⟩ := ‹Nonempty ι›
    exact ⟨a i, haK i⟩
  have hKcompact : IsCompact K := (Set.finite_range a).isCompact_convexHull ℝ
  have hKconvex : Convex ℝ K := convex_convexHull ℝ (Set.range a)
  obtain ⟨c, hc, hmin⟩ := exists_norm_eq_iInf_of_complete_convex hKne
    hKcompact.isComplete hKconvex (0 : E)
  have hproj := (norm_eq_iInf_iff_real_inner_le_zero hKconvex hc).mp hmin
  have hsupport (i : ι) : ‖c‖ ^ 2 ≤ inner ℝ (a i) c := by
    have hi := hproj (a i) (haK i)
    simp only [zero_sub, inner_neg_left, inner_sub_right,
      real_inner_self_eq_norm_sq] at hi
    rw [real_inner_comm (a i) c] at hi
    linarith
  obtain ⟨w, hw, hsumw, hrep⟩ := convexHull_range_weights a hc
  have hcu : margin ≤ inner ℝ c u := by
    rw [← hrep, sum_inner]
    simp only [real_inner_smul_left]
    calc
      margin = ∑ i, w i * margin := by rw [← Finset.sum_mul, hsumw, one_mul]
      _ ≤ ∑ i, w i * inner ℝ (a i) u := by
        apply Finset.sum_le_sum
        intro i hi
        exact mul_le_mul_of_nonneg_left (hmargin i) (hw i)
  have hc_ne : c ≠ 0 := by
    intro hz
    rw [hz, inner_zero_left] at hcu
    linarith
  have hcnorm_pos : 0 < ‖c‖ := norm_pos_iff.mpr hc_ne
  have hcsq_pos : 0 < ‖c‖ ^ 2 := sq_pos_of_pos hcnorm_pos
  have hcs : margin ≤ ‖c‖ * ‖u‖ := hcu.trans (real_inner_le_norm c u)
  have hcs_sq : margin ^ 2 ≤ ‖c‖ ^ 2 * ‖u‖ ^ 2 := by
    have h := mul_self_le_mul_self hmargin_pos.le hcs
    nlinarith
  let t : ℝ := margin / ‖c‖ ^ 2
  have ht_nonneg : 0 ≤ t := div_nonneg hmargin_pos.le hcsq_pos.le
  have ht_cancel : t * ‖c‖ ^ 2 = margin := by
    exact div_mul_cancel₀ margin (ne_of_gt hcsq_pos)
  let lam : ι → ℝ := fun i => t * w i
  have hsumlam : ∑ i, lam i = t := by
    simp only [lam, ← Finset.mul_sum, hsumw, mul_one]
  have hlamrep : (∑ i, lam i • a i) = t • c := by
    simp only [lam, mul_smul]
    rw [← Finset.smul_sum, hrep]
  refine ⟨lam, ?_, ?_, ?_⟩
  · intro i
    exact mul_nonneg ht_nonneg (hw i)
  · rw [hsumlam]
    change margin * (margin / ‖c‖ ^ 2) ≤ ‖u‖ ^ 2
    rw [← mul_div_assoc]
    apply (div_le_iff₀ hcsq_pos).2
    nlinarith [hcs_sq]
  · intro i
    rw [hlamrep, real_inner_smul_right]
    calc
      margin = t * ‖c‖ ^ 2 := ht_cancel.symm
      _ ≤ t * inner ℝ (a i) c := mul_le_mul_of_nonneg_left (hsupport i) ht_nonneg

/-- The margin-1/2 version has total dual mass at most twice the energy. -/
theorem exists_half_margin_readout_dual (a : ι → E) (u : E) {energy : ℝ}
    (hmargin : ∀ i, (1 / 2 : ℝ) ≤ inner ℝ (a i) u)
    (henergy : ‖u‖ ^ 2 ≤ energy) :
    ∃ lam : ι → ℝ, (∀ i, 0 ≤ lam i) ∧ (∑ i, lam i) ≤ 2 * energy ∧
      ∀ i, (1 / 2 : ℝ) ≤ inner ℝ (a i) (∑ j, lam j • a j) := by
  obtain ⟨lam, hlam, hbound, hpred⟩ := exists_readout_dual a u (by norm_num) hmargin
  exact ⟨lam, hlam, by linarith, hpred⟩

/-- Signed feature vectors yield an actual signed dual with an ℓ¹ bound.
For the paper, set `h_i` to the original feature row divided by `sqrt N`
and set `u` to `sqrt N` times the original readout. -/
theorem exists_signed_half_margin_readout_dual
    (h : ι → E) (g : ι → ℝ) (u : E) {energy : ℝ}
    (hg : ∀ i, |g i| = 1)
    (hmargin : ∀ i, (1 / 2 : ℝ) ≤ g i * inner ℝ (h i) u)
    (henergy : ‖u‖ ^ 2 ≤ energy) :
    ∃ beta : ι → ℝ, (∑ i, |beta i|) ≤ 2 * energy ∧
      ∀ i, (1 / 2 : ℝ) ≤ g i * inner ℝ (h i) (∑ j, beta j • h j) := by
  let a : ι → E := fun i => g i • h i
  have hamargin (i : ι) : (1 / 2 : ℝ) ≤ inner ℝ (a i) u := by
    simpa only [a, real_inner_smul_left] using hmargin i
  obtain ⟨lam, hlam, hbound, hpred⟩ :=
    exists_half_margin_readout_dual a u hamargin henergy
  let beta : ι → ℝ := fun i => lam i * g i
  have hrep : (∑ j, lam j • a j) = ∑ j, beta j • h j := by
    simp only [a, beta, smul_smul]
  refine ⟨beta, ?_, ?_⟩
  · calc
      (∑ i, |beta i|) = ∑ i, lam i := by
        apply Finset.sum_congr rfl
        intro i hi
        simp only [beta, abs_mul, hg i, abs_of_nonneg (hlam i), mul_one]
      _ ≤ 2 * energy := hbound
  · intro i
    have hi := hpred i
    rw [hrep] at hi
    simpa only [a, real_inner_smul_left] using hi

/-- The normalized Gram-matrix form used by the network theorem.

Taking `scale = N`, `h i` equal to row `i` of the full activation matrix,
and `u` equal to its original readout gives exactly the empirical covariance
`Q = H Hᵀ / N`. No invertibility hypothesis is used. -/
theorem exists_normalized_gram_dual
    (h : ι → E) (g : ι → ℝ) (u : E) {scale energy : ℝ}
    (hscale : 0 < scale)
    (hg : ∀ i, |g i| = 1)
    (hmargin : ∀ i, (1 / 2 : ℝ) ≤ g i * inner ℝ (h i) u)
    (henergy : scale * ‖u‖ ^ 2 ≤ energy) :
    ∃ beta : ι → ℝ, (∑ i, |beta i|) ≤ 2 * energy ∧
      ∀ i, (1 / 2 : ℝ) ≤
        g i * ((∑ j, beta j * inner ℝ (h i) (h j)) / scale) := by
  have henergy' : ‖u‖ ^ 2 ≤ energy / scale := by
    apply (le_div_iff₀ hscale).2
    simpa only [mul_comm] using henergy
  obtain ⟨beta₀, hbound, hpred⟩ :=
    exists_signed_half_margin_readout_dual h g u hg hmargin henergy'
  let beta : ι → ℝ := fun i => scale * beta₀ i
  have habs : (∑ i, |beta i|) = scale * ∑ i, |beta₀ i| := by
    simp only [beta, abs_mul, abs_of_pos hscale, Finset.mul_sum]
  have hcancel : scale * (2 * (energy / scale)) = 2 * energy := by
    calc
      scale * (2 * (energy / scale)) = 2 * (scale * (energy / scale)) := by ring
      _ = 2 * energy := by rw [mul_div_cancel₀ _ (ne_of_gt hscale)]
  refine ⟨beta, ?_, ?_⟩
  · rw [habs]
    exact (mul_le_mul_of_nonneg_left hbound hscale.le).trans_eq hcancel
  · intro i
    have hi := hpred i
    rw [inner_sum] at hi
    simp only [real_inner_smul_right] at hi
    have hgram : (∑ j, beta j * inner ℝ (h i) (h j)) / scale =
        ∑ j, beta₀ j * inner ℝ (h i) (h j) := by
      simp only [beta, mul_assoc, ← Finset.mul_sum]
      exact mul_div_cancel_left₀ _ (ne_of_gt hscale)
    rwa [hgram]

end NeuralGeneralization.ReadoutDual
