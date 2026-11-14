import NeuralGeneralization.OnlineLowerTanhPaperLPSubgroup
import NeuralGeneralization.OnlineLowerTanhGeometryMass

/-! # The explicit annihilator probability for subgroup overshoot

This is the actual finite Fourier distribution used in the generic
subgroup-positive optimization proof, including its normalization and
pointwise character expectation.  No LP dual or optimizer is assumed.
-/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerGeometry
namespace CubeSubgroup
variable {m : ℕ} (H : CubeSubgroup m)

theorem average_eq_of_invariant (r : ClippingCube m → ℝ)
    (hr : ∀ a ∈ H.carrier, ∀ x, r (cubeTranslation a x) = r x) : H.average r = r := by
  funext x
  unfold average
  have hsum : (∑ a ∈ H.carrier, r (cubeTranslation a x)) = H.carrier.card * r x := by
    calc
      _ = ∑ _a ∈ H.carrier, r x := Finset.sum_congr rfl (fun a ha => hr a ha x)
      _ = _ := by simp
  rw [hsum]
  exact mul_div_cancel_left₀ _ (ne_of_gt (Nat.cast_pos.mpr H.card_pos))

theorem coefficient_zero_of_invariant (r : ClippingCube m → ℝ)
    (hr : ∀ a ∈ H.carrier, ∀ x, r (cubeTranslation a x) = r x)
    (s : Finset (Fin m)) (hs : ¬H.Annihilates s) : walshCoefficients r s = 0 := by
  have h := H.average_coefficient r s
  rw [H.average_eq_of_invariant r hr, if_neg hs] at h
  exact h

/-- Number of cosets of H, obtained as the actual annihilator cardinality. -/
def quotientCard : ℝ := H.annihilator.card

theorem quotientCard_pos : 0 < H.quotientCard := by
  have h := H.annihilator_card_mul
  have hratio : 0 < (H.carrier.card : ℝ) / Fintype.card (ClippingCube m) := by
    exact div_pos (Nat.cast_pos.mpr H.card_pos) (Nat.cast_pos.mpr Fintype.card_pos)
  dsimp [quotientCard]
  nlinarith

theorem annihilator_sum (x : ClippingCube m) :
    (∑ s ∈ H.annihilator, walshCharacter s x) = H.quotientCard * H.indicator x := by
  have h1 := H.annihilator_sum_scaled x
  have h2 := H.annihilator_card_mul
  have hratio : 0 < (H.carrier.card : ℝ) / Fintype.card (ClippingCube m) := by
    exact div_pos (Nat.cast_pos.mpr H.card_pos) (Nat.cast_pos.mpr Fintype.card_pos)
  dsimp [quotientCard]
  apply (mul_left_cancel₀ (ne_of_gt hratio))
  rw [h1, ← mul_assoc, h2, one_mul]

def overshootTotal (r : ClippingCube m → ℝ) : ℝ :=
  H.quotientCard * walshCoefficients r ∅

def overshootDenominator (r : ClippingCube m → ℝ) : ℝ :=
  H.quotientCard - (1 + H.overshootTotal r)

/-- A probability on nonconstant characters annihilating H. -/
def overshootProbability (r : ClippingCube m → ℝ) (s : Finset (Fin m)) : ℝ :=
  if s = ∅ then 0 else if H.Annihilates s then
    (1 + H.quotientCard * walshCoefficients r s) / H.overshootDenominator r else 0

private theorem coeff_abs_le_empty (r : ClippingCube m → ℝ)
    (hr : ∀ x, 0 ≤ r x) (s : Finset (Fin m)) :
    |walshCoefficients r s| ≤ walshCoefficients r ∅ := by
  have h := walshCoefficient_abs_le_mean_abs r s
  have hmean : uniformCubeMean (fun x => |r x|) = walshCoefficients r ∅ := by
    simp_rw [abs_of_nonneg (hr _)]
    simp [walshCoefficients, walshCharacter]
  rwa [hmean] at h

theorem overshootDenominator_pos (r : ClippingCube m → ℝ)
    (hL : 2 ≤ H.quotientCard) (hR : H.overshootTotal r < 1) :
    0 < H.overshootDenominator r := by
  dsimp [overshootDenominator]
  linarith

theorem overshootProbability_bounds (r : ClippingCube m → ℝ)
    (hr : ∀ x, 0 ≤ r x) (hL : 2 ≤ H.quotientCard) (hR : H.overshootTotal r < 1)
    (s : Finset (Fin m)) :
    0 ≤ H.overshootProbability r s ∧
      H.overshootProbability r s ≤ (1+H.overshootTotal r)/H.overshootDenominator r ∧
      (s ≠ ∅ → H.Annihilates s → 0 < H.overshootProbability r s) := by
  have hZ := H.overshootDenominator_pos r hL hR
  have hc := coeff_abs_le_empty r hr s
  have hc0 := coeff_abs_le_empty r hr ∅
  have hR0 : 0 ≤ H.overshootTotal r := by
    unfold overshootTotal
    exact mul_nonneg H.quotientCard_pos.le ((abs_nonneg _).trans hc0)
  have hbound : |H.quotientCard * walshCoefficients r s| ≤ H.overshootTotal r := by
    rw [abs_mul, abs_of_nonneg H.quotientCard_pos.le]
    exact mul_le_mul_of_nonneg_left hc H.quotientCard_pos.le
  unfold overshootProbability
  split_ifs with hs hA
  · refine ⟨le_rfl, by positivity, ?_⟩
    exact fun hn => False.elim (hn hs)
  · have hh := abs_le.mp hbound
    have hn : 0 < 1 + H.quotientCard * walshCoefficients r s := by linarith
    exact ⟨(div_pos hn hZ).le,
      div_le_div_of_nonneg_right (by linarith) hZ.le,
      fun _ _ => div_pos hn hZ⟩
  · refine ⟨le_rfl, by positivity, ?_⟩
    exact fun _ hp => False.elim (hA hp)

theorem overshootProbability_character_mean (r : ClippingCube m → ℝ)
    (hr : ∀ a ∈ H.carrier, ∀ x, r (cubeTranslation a x) = r x)
    (x : ClippingCube m) :
    walshExpansion (H.overshootProbability r) x =
      (H.quotientCard * (H.indicator x + r x) - (1+H.overshootTotal r)) /
        H.overshootDenominator r := by
  let a : Finset (Fin m) → ℝ := fun s => if H.Annihilates s then
    1 + H.quotientCard * walshCoefficients r s else 0
  have hEmpty : H.Annihilates ∅ := by intro z hz; simp [walshCharacter]
  have ha0 : a ∅ = 1 + H.overshootTotal r := by simp [a, hEmpty, overshootTotal]
  have heq (s : Finset (Fin m)) : H.overshootProbability r s =
      (a s - (if s=∅ then a ∅ else 0)) / H.overshootDenominator r := by
    unfold overshootProbability a
    split_ifs <;> simp_all
  have hexp : walshExpansion a x = H.quotientCard * (H.indicator x + r x) := by
    have hterm (s : Finset (Fin m)) : a s * walshCharacter s x =
        (if H.Annihilates s then walshCharacter s x else 0) +
          H.quotientCard * (walshCoefficients r s * walshCharacter s x) := by
      by_cases hs : H.Annihilates s
      · simp [a, hs]; ring
      · simp [a, hs, H.coefficient_zero_of_invariant r hr s hs]
    unfold walshExpansion
    simp_rw [hterm]
    rw [Finset.sum_add_distrib, ← Finset.mul_sum]
    have hsum : (∑ s, if H.Annihilates s then walshCharacter s x else 0) =
        H.quotientCard * H.indicator x := by
      simpa [annihilator, Finset.sum_filter] using H.annihilator_sum x
    rw [hsum, ← walshExpansion, walshExpansion_coefficients]
    ring
  unfold walshExpansion
  simp_rw [heq, div_mul_eq_mul_div, ← Finset.sum_div, sub_mul, Finset.sum_sub_distrib]
  have hz : (∑ s, (if s=∅ then a ∅ else 0) * walshCharacter s x) = a ∅ := by
    simp [ite_mul, walshCharacter]
  rw [hz, ← walshExpansion, hexp, ha0]

theorem overshootProbability_sum (r : ClippingCube m → ℝ)
    (hr : ∀ a ∈ H.carrier, ∀ x, r (cubeTranslation a x) = r x)
    (hr0 : r (cubeOne m) = 0)
    (hL : 2 ≤ H.quotientCard) (hR : H.overshootTotal r < 1) :
    ∑ s, H.overshootProbability r s = 1 := by
  have h := H.overshootProbability_character_mean r hr (cubeOne m)
  simp only [walshExpansion, walshCharacter_one, mul_one, indicator, if_pos H.one_mem,
    hr0, add_zero] at h
  rw [h]
  exact div_self (ne_of_gt (H.overshootDenominator_pos r hL hR))

end CubeSubgroup
end NeuralGeneralization.OnlineLowerGeometry
