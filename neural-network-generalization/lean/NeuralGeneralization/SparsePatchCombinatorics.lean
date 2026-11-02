import NeuralGeneralization.FinitePosterior
import Mathlib.Data.Finset.Powerset
import Mathlib.Tactic

/-! Exact finite-subset survival probabilities, including repeated samples. -/
noncomputable section
open scoped BigOperators
open Classical
namespace NeuralGeneralization.SparsePatches

/-- Uniform probability that an r-subset contains a prescribed s-subset. -/
def survival (M r s : ℕ) : ℝ := (Nat.choose (M-s) (r-s) : ℝ) / Nat.choose M r

lemma survival_zero {M r : ℕ} (hr : r ≤ M) : survival M r 0 = 1 := by
  simp [survival, (show (Nat.choose M r : ℝ) ≠ 0 by exact_mod_cast Nat.choose_ne_zero hr)]

lemma survival_step {M r s : ℕ} (hs : s < r) (hr : r ≤ M) :
    survival M r (s+1) = survival M r s * ((r-s : ℕ) : ℝ) / (M-s : ℕ) := by
  have hM : M-(s+1)+1 = M-s := by omega
  have hR : r-(s+1)+1 = r-s := by omega
  have he := Nat.add_one_mul_choose_eq (M-(s+1)) (r-(s+1))
  rw [hM,hR] at he
  have he' : ((M-s : ℕ) : ℝ) * (Nat.choose (M-(s+1)) (r-(s+1)) : ℝ) =
      (Nat.choose (M-s) (r-s) : ℝ) * ((r-s : ℕ) : ℝ) := by exact_mod_cast he
  have hc : (Nat.choose M r : ℝ) ≠ 0 := by exact_mod_cast Nat.choose_ne_zero hr
  have hm : ((M-s : ℕ) : ℝ) ≠ 0 := by exact_mod_cast (show M-s ≠ 0 by omega)
  unfold survival
  field_simp
  nlinarith [he']

lemma survival_step_lower {M r s : ℕ} (hM : 0 < M) (hr : r ≤ M) (hs : 2*s < r) :
    (r:ℝ)/(2*M) ≤ ((r-s : ℕ) : ℝ) / (M-s : ℕ) := by
  have hsR : s ≤ r := by omega
  have hsM : s < M := by omega
  have hm : (0:ℝ) < (M-s : ℕ) := by exact_mod_cast Nat.sub_pos_of_lt hsM
  have hmp : (0:ℝ) < M := by exact_mod_cast hM
  rw [div_le_div_iff₀ (by positivity) hm]
  rw [Nat.cast_sub hsR, Nat.cast_sub hsM.le]
  have hs' : (2:ℝ)*s ≤ r := by exact_mod_cast (show 2*s ≤ r by omega)
  nlinarith [mul_nonneg (show (0:ℝ) ≤ r by positivity) (show (0:ℝ) ≤ s by positivity)]

/-- The exact hypergeometric survival probability has the paper's lower bound. -/
theorem survival_lower {M r s : ℕ} (hM : 0 < M) (hr : r ≤ M) (hs : 2*s ≤ r) :
    ((r:ℝ)/(2*M))^s ≤ survival M r s := by
  induction s with
  | zero => simp [survival_zero hr]
  | succ s ih =>
    have hs' : 2*s ≤ r := by omega
    have hh := ih hs'
    have hfactor := survival_step_lower hM hr (show 2*s < r by omega)
    rw [survival_step (show s < r by omega) hr, pow_succ, mul_div_assoc]
    exact mul_le_mul hh hfactor (by positivity) (div_nonneg (by positivity) (by positivity))

abbrev Patch (M r : ℕ) := ↥((Finset.univ : Finset (Fin M)).powersetCard r)

lemma patch_card {M r : ℕ} (B : Patch M r) : B.val.card = r :=
  (Finset.mem_powersetCard.mp B.property).2

lemma patch_count (M r : ℕ) : Fintype.card (Patch M r) = Nat.choose M r := by
  simp [Patch]

lemma patch_survivors {M r : ℕ} (S : Finset (Fin M)) (hs : S.card ≤ r) :
    (∑ B : Patch M r, if S ⊆ B.val then (1:ℝ) else 0) =
      Nat.choose (M-S.card) (r-S.card) := by
  rw [Finset.sum_coe_sort ((Finset.univ : Finset (Fin M)).powersetCard r) (fun B => if S ⊆ B then (1:ℝ) else 0)]
  rw [← Finset.sum_filter]
  simp only [Finset.sum_const, nsmul_eq_mul, mul_one]
  rw [Finset.card_filter_powersetCard_subset S Finset.univ r (Finset.subset_univ S) hs]
  simp

/-- Duplicates do not change the event, and never make survival less likely. -/
theorem sample_survival_lower {M r n : ℕ} (hM : 0 < M) (hr : r ≤ M)
    (hn : 2*n ≤ r) (sample : Fin n → Fin M) :
    ((r:ℝ)/(2*M))^n ≤
      (∑ B : Patch M r, if ∀ i, sample i ∈ B.val then (1:ℝ) else 0) / Nat.choose M r := by
  let S := Finset.univ.image sample
  have hs : S.card ≤ n := by simpa [S] using Finset.card_image_le (s := Finset.univ) (f := sample)
  have he (B : Patch M r) : (∀ i, sample i ∈ B.val) ↔ S ⊆ B.val := by
    simp [S, Finset.image_subset_iff]
  simp_rw [he]
  rw [patch_survivors S (by omega)]
  change _ ≤ survival M r S.card
  have hb : (r:ℝ)/(2*M) ≤ 1 := by
    apply (div_le_one (by positivity : (0:ℝ) < 2*M)).mpr
    have : (r:ℝ) ≤ M := by exact_mod_cast hr
    linarith
  exact (pow_le_pow_of_le_one (by positivity) hb hs).trans (survival_lower hM hr (by omega))

end NeuralGeneralization.SparsePatches
