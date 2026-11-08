import NeuralGeneralization.OnlineLowerGeometryReluDual
import NeuralGeneralization.OnlineLowerGeometryAlgebra
import NeuralGeneralization.OnlineLowerGeometryDualParameters

/-!
# The common rectangle dual on the actual Boolean cube

The construction below is the quotient-free form of the manuscript's
conditioned probability distribution. If `k` is invariant under translation
by `u`, its Fourier coefficients vanish on the odd characters. On the even
characters the subtracted coefficient is `c + |G| * k̂`. This makes every
normalization explicit using the existing finite Walsh transform.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

theorem walshCharacter_eq_one_or_neg_one {m : ℕ} (s : Finset (Fin m))
    (z : ClippingCube m) : walshCharacter s z = 1 ∨ walshCharacter s z = -1 := by
  have h : (walshCharacter s z - 1) * (walshCharacter s z + 1) = 0 := by
    nlinarith [walshCharacter_sq s z]
  rcases mul_eq_zero.mp h with h | h <;> [left; right] <;> linarith

theorem coefficient_of_invariant_eq_zero {m : ℕ} (u : ClippingCube m)
    (f : ClippingCube m → ℝ) (hinv : ∀ z, f (cubeTranslation u z) = f z)
    (s : Finset (Fin m)) (hs : walshCharacter s u ≠ 1) :
    walshCoefficients f s = 0 := by
  have heq : (fun z => f (cubeTranslation u z)) = f := funext hinv
  have h := walshCoefficients_translation u f s
  rw [heq] at h
  have hneg := (walshCharacter_eq_one_or_neg_one s u).resolve_left hs
  rw [hneg] at h
  linarith

/-- The unnormalized absolute coefficient bound used for the explicit
paired-cost function, with its literal cube-cardinality factor. -/
theorem coefficient_abs_mul_card_le_sum {m : ℕ} (f : ClippingCube m → ℝ)
    (s : Finset (Fin m)) :
    |(Fintype.card (ClippingCube m) : ℝ) * walshCoefficients f s| ≤ ∑ z, |f z| := by
  have hM : (Fintype.card (ClippingCube m) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold walshCoefficients uniformCubeMean
  rw [mul_div_cancel₀ _ hM]
  calc
    _ ≤ ∑ z, |f z * walshCharacter s z| := Finset.abs_sum_le_sum_abs _ _
    _ = _ := by simp only [abs_mul, abs_walshCharacter, mul_one]

theorem even_character_sum {m : ℕ} (u z : ClippingCube m) :
    (∑ s : Finset (Fin m), if walshCharacter s u = 1 then walshCharacter s z else 0) =
      (Fintype.card (ClippingCube m) : ℝ) / 2 *
        (pointIndicator (cubeOne m) z + pointIndicator u z) := by
  have hterm (s : Finset (Fin m)) :
      (if walshCharacter s u = 1 then walshCharacter s z else 0) =
        (walshCharacter s (cubeOne m) * walshCharacter s z +
          walshCharacter s u * walshCharacter s z) / 2 := by
    rw [walshCharacter_one]
    rcases walshCharacter_eq_one_or_neg_one s u with h | h <;> norm_num [h]
  simp_rw [hterm]
  rw [← Finset.sum_div, Finset.sum_add_distrib,
    walshCharacter_dual_orthogonal, walshCharacter_dual_orthogonal]
  have hdelta (x : ClippingCube m) :
      (if x = z then (Fintype.card (ClippingCube m) : ℝ) else 0) =
        Fintype.card (ClippingCube m) * pointIndicator x z := by
    by_cases h : z = x
    · simp only [if_pos h.symm, pointIndicator, if_pos h, mul_one]
    · simp only [if_neg (Ne.symm h), pointIndicator, if_neg h, mul_zero]
  rw [hdelta, hdelta]
  ring

/-- The actual positive maximum on each two-element translation orbit;
the anchor orbit is omitted. -/
def rectanglePairedCost {m : ℕ} (w : Finset (Fin m) → ℝ)
    (u z : ClippingCube m) : ℝ :=
  if z = cubeOne m ∨ z = u then 0 else
    max 0 (max (walshExpansion w z / Fintype.card (ClippingCube m))
      (walshExpansion w (cubeTranslation u z) / Fintype.card (ClippingCube m)))

def rectanglePairedTotal {m : ℕ} (w : Finset (Fin m) → ℝ) (u : ClippingCube m) : ℝ :=
  (∑ z, rectanglePairedCost w u z) / 2

theorem rectanglePairedCost_nonneg {m : ℕ} (w : Finset (Fin m) → ℝ)
    (u z : ClippingCube m) : 0 ≤ rectanglePairedCost w u z := by
  unfold rectanglePairedCost
  split_ifs
  · exact le_rfl
  · exact le_max_left _ _

theorem rectanglePairedCost_invariant {m : ℕ} (w : Finset (Fin m) → ℝ)
    (u z : ClippingCube m) :
    rectanglePairedCost w u (cubeTranslation u z) = rectanglePairedCost w u z := by
  have h0 : cubeTranslation u z = cubeOne m ↔ z = u := by
    constructor
    · intro h
      have hh := congrArg (cubeTranslation u) h
      simpa only [cubeTranslation_involutive, cubeTranslation_comm u (cubeOne m),
        cubeTranslation_one] using hh
    · rintro rfl
      exact cubeTranslation_self _
  have hu : cubeTranslation u z = u ↔ z = cubeOne m := by
    constructor
    · intro h
      have hh := congrArg (cubeTranslation u) h
      simpa only [cubeTranslation_involutive, cubeTranslation_self] using hh
    · rintro rfl
      rw [cubeTranslation_comm, cubeTranslation_one]
  simp only [rectanglePairedCost, h0, hu, cubeTranslation_involutive, or_comm]
  rw [max_comm (walshExpansion w (cubeTranslation u z) / _)]

def rectangleDualCoefficients {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (k : ClippingCube m → ℝ)
    (a c : ℝ) (s : Finset (Fin m)) : ℝ :=
  w s - (if s = ∅ then a else 0) - (if walshCharacter s u = 1 then c else 0) -
    Fintype.card (ClippingCube m) * walshCoefficients k s -
    (if s ∈ H.differenceAnnihilator v then a / (H.differenceAnnihilator v).card else 0)

def rectangleDualScore {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (k : ClippingCube m → ℝ)
    (a c : ℝ) : ClippingCube m → ℝ :=
  walshExpansion (rectangleDualCoefficients w H v u k a c)

/-- Exact inversion, before any scalar dominance hypotheses are imposed. -/
theorem rectangleDualScore_formula {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (k : ClippingCube m → ℝ)
    (a c : ℝ) (hv : v ∉ H.carrier) (hE : 0 < (H.differenceAnnihilator v).card)
    (z : ClippingCube m) :
    rectangleDualScore w H v u k a c z = walshExpansion w z - a -
      c * ((Fintype.card (ClippingCube m) : ℝ) / 2) *
        (pointIndicator (cubeOne m) z + pointIndicator u z) -
      Fintype.card (ClippingCube m) * k z - a * H.indicator z + a * H.cosetIndicator v z := by
  have hEne : ((H.differenceAnnihilator v).card : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr hE)
  have hzero : (∑ s : Finset (Fin m), (if s = ∅ then a else 0) * walshCharacter s z) = a := by
    simp [ite_mul, walshCharacter]
  have heven : (∑ s : Finset (Fin m),
      (if walshCharacter s u = 1 then c else 0) * walshCharacter s z) =
      c * ((Fintype.card (ClippingCube m) : ℝ) / 2) *
        (pointIndicator (cubeOne m) z + pointIndicator u z) := by
    calc
      _ = c * ∑ s : Finset (Fin m), if walshCharacter s u = 1 then walshCharacter s z else 0 := by
        simp only [Finset.mul_sum, mul_ite, ite_mul, mul_zero, zero_mul]
      _ = _ := by rw [even_character_sum]; ring
  have hk : (∑ s : Finset (Fin m),
      (Fintype.card (ClippingCube m) : ℝ) * walshCoefficients k s * walshCharacter s z) =
      Fintype.card (ClippingCube m) * k z := by
    rw [show (∑ s : Finset (Fin m),
      (Fintype.card (ClippingCube m) : ℝ) * walshCoefficients k s * walshCharacter s z) =
      Fintype.card (ClippingCube m) * walshExpansion (walshCoefficients k) z by
        simp only [walshExpansion, Finset.mul_sum, mul_assoc]]
    rw [walshExpansion_coefficients]
  have hann : (∑ s : Finset (Fin m),
      (if s ∈ H.differenceAnnihilator v then a / (H.differenceAnnihilator v).card else 0) *
        walshCharacter s z) = a * (H.indicator z - H.cosetIndicator v z) := by
    calc
      _ = (a / (H.differenceAnnihilator v).card) *
          ∑ s ∈ H.differenceAnnihilator v, walshCharacter s z := by
        simp only [ite_mul, zero_mul, Fintype.sum_ite_mem, Finset.mul_sum]
      _ = _ := by rw [H.affine_coset_character_identity v hv z]; field_simp [hEne]
  unfold rectangleDualScore walshExpansion rectangleDualCoefficients
  simp_rw [sub_mul]
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, Finset.sum_sub_distrib,
    Finset.sum_sub_distrib, hzero, heven, hk, hann]
  ring

def commonDualC (L h K : ℝ) : ℝ := commonDualB L h K - 2 * K

theorem commonDualC_lower (L h K wstar : ℝ)
    (hL : 1 < L) (hh : 3 * wstar / 4 ≤ h) (hwstar : 0 < wstar)
    (hK : 0 ≤ K) (hKup : K ≤ wstar / 4) :
    wstar ≤ commonDualC L h K - 2 * K := by
  have hden : 0 < L - 1 := by linarith
  have hh0 : 0 < h := by linarith
  have hc : 2 * h ≤ commonDualC L h K := by
    unfold commonDualC commonDualB
    apply (le_sub_iff_add_le).mpr
    apply (le_div_iff₀ hden).mpr
    nlinarith
  linarith

theorem commonDualC_cancellation (L w₀ wstar K : ℝ) (hL : 2 < L) :
    commonDualC L (commonDualH L w₀ wstar K) K * L +
      2 * commonDualA L w₀ (commonDualH L w₀ wstar K) K = 2 * L * wstar := by
  have h₀ : L ≠ 0 := by linarith
  have h₁ : L - 1 ≠ 0 := by linarith
  have h₂ : L - 2 ≠ 0 := by linarith
  unfold commonDualC commonDualA commonDualB commonDualH
  field_simp [h₀, h₁, h₂]
  ring

theorem rectangleDual_coefficient_empty {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (k : ClippingCube m → ℝ)
    (a c K : ℝ) (hsum : ∑ z, k z = 2 * K) (htotal : a + c + 2 * K = 2 * w ∅) :
    rectangleDualCoefficients w H v u k a c ∅ = -w ∅ := by
  have hM : (Fintype.card (ClippingCube m) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have hk : (Fintype.card (ClippingCube m) : ℝ) * walshCoefficients k ∅ = 2 * K := by
    simp only [walshCoefficients, uniformCubeMean, walshCharacter, Finset.prod_empty, mul_one]
    rw [mul_div_cancel₀ _ hM, hsum]
  simp only [rectangleDualCoefficients, if_pos rfl, walshCharacter, Finset.prod_empty,
    H.empty_not_differenceAnnihilator, if_false, sub_zero]
  change w ∅ - a - c - (Fintype.card (ClippingCube m) : ℝ) * walshCoefficients k ∅ = -w ∅
  rw [hk]
  linarith

/-- The dual saturates the positive side on every `u`-odd character. -/
theorem rectangleDual_coefficient_odd {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (k : ClippingCube m → ℝ)
    (a c : ℝ) (hu : u ∈ H.carrier)
    (hinv : ∀ z, k (cubeTranslation u z) = k z)
    (s : Finset (Fin m)) (hs : walshCharacter s u ≠ 1) :
    rectangleDualCoefficients w H v u k a c s = w s := by
  have hs0 : s ≠ ∅ := by intro h; subst s; exact hs (by simp [walshCharacter])
  have hsE : s ∉ H.differenceAnnihilator v := by
    intro h
    exact hs ((Finset.mem_filter.mp (Finset.mem_filter.mp h).1).2 u hu)
  simp only [rectangleDualCoefficients, if_neg hs0, if_neg hs, if_neg hsE,
    coefficient_of_invariant_eq_zero u k hinv s hs, mul_zero, sub_zero]

/-- Both coefficient slacks are bounded below on every nonconstant
`u`-even character. All hypotheses here are explicit scalar inequalities. -/
theorem rectangleDual_coefficient_even_slack {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (k : ClippingCube m → ℝ)
    (a c K wstar : ℝ) (hk : ∀ z, 0 ≤ k z) (hsum : ∑ z, k z = 2 * K)
    (hw : ∀ s, w ∅ ≤ w s) (ha : 0 ≤ a)
    (htotal : a + c + 2 * K = 2 * w ∅) (hb : c + 2 * K ≤ w ∅ / 4)
    (hlower : wstar ≤ c - 2 * K) (hsmall : wstar ≤ w ∅ / 16)
    (hE : 2 ≤ (H.differenceAnnihilator v).card)
    (s : Finset (Fin m)) (hs0 : s ≠ ∅) (hseven : walshCharacter s u = 1) :
    wstar ≤ w s - rectangleDualCoefficients w H v u k a c s ∧
      wstar ≤ w s + rectangleDualCoefficients w H v u k a c s := by
  have hcoeff := coefficient_abs_mul_card_le_sum k s
  have habssum : (∑ z, |k z|) = 2 * K := by
    simp only [abs_of_nonneg (hk _)]
    exact hsum
  rw [habssum] at hcoeff
  obtain ⟨hcoefflo, hcoeffhi⟩ := abs_le.mp hcoeff
  have hEr : (2 : ℝ) ≤ (H.differenceAnnihilator v).card := by exact_mod_cast hE
  have hEpos : (0 : ℝ) < (H.differenceAnnihilator v).card := by linarith
  have hfrac0 : 0 ≤ a / (H.differenceAnnihilator v).card := div_nonneg ha hEpos.le
  have hfrac : a / (H.differenceAnnihilator v).card ≤ a / 2 := by
    apply (div_le_iff₀ hEpos).mpr
    nlinarith [mul_nonneg ha (by linarith : 0 ≤ ((H.differenceAnnihilator v).card : ℝ) - 2)]
  simp only [rectangleDualCoefficients, if_neg hs0, if_pos hseven, sub_zero]
  split_ifs <;> constructor <;> nlinarith [hw s]

theorem rectangleDual_coefficients_feasible {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (k : ClippingCube m → ℝ)
    (a c K wstar : ℝ) (hu : u ∈ H.carrier) (hk : ∀ z, 0 ≤ k z)
    (hinv : ∀ z, k (cubeTranslation u z) = k z) (hsum : ∑ z, k z = 2 * K)
    (hw0 : 0 ≤ w ∅) (hw : ∀ s, w ∅ ≤ w s) (ha : 0 ≤ a) (hwstar : 0 ≤ wstar)
    (htotal : a + c + 2 * K = 2 * w ∅) (hb : c + 2 * K ≤ w ∅ / 4)
    (hlower : wstar ≤ c - 2 * K) (hsmall : wstar ≤ w ∅ / 16)
    (hE : 2 ≤ (H.differenceAnnihilator v).card) (s : Finset (Fin m)) :
    |rectangleDualCoefficients w H v u k a c s| ≤ w s := by
  by_cases hs0 : s = ∅
  · subst s
    rw [rectangleDual_coefficient_empty w H v u k a c K hsum htotal, abs_neg,
      abs_of_nonneg hw0]
  · by_cases hseven : walshCharacter s u = 1
    · obtain ⟨hlo, hhi⟩ := rectangleDual_coefficient_even_slack w H v u k a c K wstar
        hk hsum hw ha htotal hb hlower hsmall hE s hs0 hseven
      exact abs_le.mpr ⟨by linarith, by linarith⟩
    · rw [rectangleDual_coefficient_odd w H v u k a c hu hinv s hseven,
        abs_of_nonneg (hw0.trans (hw s))]

end NeuralGeneralization.OnlineLowerGeometry
