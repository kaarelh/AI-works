import NeuralGeneralization.OnlineLowerTanhGeometryCalibration
import NeuralGeneralization.OnlineLowerGeometryReluFourier

/-! # Actual live masses and quantitative rectangle reconstruction -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

def rectangleMassScore {m : ℕ} (u : ClippingCube m) (p : ClippingCube m → ℝ)
    (z : ClippingCube m) : ℝ :=
  rectangleBaseline u z + p z - p (cubeTranslation u z)

def rectangleObservedError {m : ℕ} (H : CubeSubgroup m) (v u : ClippingCube m)
    (g : ClippingCube m → ℝ) (z : ClippingCube m) : ℝ :=
  if z ∈ rectangleObserved H v u then |g z - reluReference z| else 0

lemma rectangleObservedError_nonneg {m : ℕ} (H : CubeSubgroup m) (v u : ClippingCube m)
    (g : ClippingCube m → ℝ) (z : ClippingCube m) :
    0 ≤ rectangleObservedError H v u g z := by
  unfold rectangleObservedError
  split_ifs <;> positivity

lemma rectangleMassScore_on_live {m : ℕ} (H : CubeSubgroup m) (v u : ClippingCube m)
    (hu : u ∉ H.carrier) (hv : v ∉ (H.adjoinPoint u).carrier)
    (g : ClippingCube m → ℝ) (z : ClippingCube m)
    (hz : cubeTranslation v z ∈ H.carrier) :
    rectangleMassScore u (reluLiveMass H v g) z = g z := by
  have hp := H.coset_partner_not_mem u v z hu hz
  obtain ⟨hz0, hzu⟩ := H.coset_mem_not_anchor_or_shift u v z hv hz
  simp only [rectangleMassScore, rectangleBaseline, pointIndicator, if_neg hz0,
    if_neg hzu, reluLiveMass, if_pos hz, if_neg hp]
  ring

lemma rectangleMassScore_on_partner {m : ℕ} (H : CubeSubgroup m) (v u : ClippingCube m)
    (hu : u ∉ H.carrier) (hv : v ∉ (H.adjoinPoint u).carrier)
    (g : ClippingCube m → ℝ) (z : ClippingCube m)
    (hz : cubeTranslation v (cubeTranslation u z) ∈ H.carrier) :
    rectangleMassScore u (reluLiveMass H v g) z = -1 - g (cubeTranslation u z) := by
  have hp := H.coset_partner_not_mem u v (cubeTranslation u z) hu hz
  simp only [cubeTranslation_involutive] at hp
  obtain ⟨huz0, huzu⟩ := H.coset_mem_not_anchor_or_shift u v (cubeTranslation u z) hv hz
  have hz0 : z ≠ cubeOne m := fun h => huzu ((cubeTranslation_eq_point_iff u z).mpr h)
  have hzu : z ≠ u := fun h => huz0 ((cubeTranslation_eq_one_iff u z).mpr h)
  simp only [rectangleMassScore, rectangleBaseline, pointIndicator, if_neg hz0,
    if_neg hzu, reluLiveMass, if_pos hz, if_neg hp]
  ring

/-- A direct pointwise reconstruction estimate. Its constant is deliberately
loose, so it does not require a separate cardinality estimate for the live coset. -/
theorem rectangleMassScore_error_pointwise {m : ℕ} (H : CubeSubgroup m)
    (v u : ClippingCube m) (hu : u ∉ H.carrier)
    (hv : v ∉ (H.adjoinPoint u).carrier) (g : ClippingCube m → ℝ) (δ : ℝ)
    (hδ : 0 ≤ δ) (hsym : ∀ z, |g z + g (cubeTranslation u z) + 1| ≤ 4 * δ)
    (z : ClippingCube m) :
    |g z - rectangleMassScore u (reluLiveMass H v g) z| ≤
      rectangleObservedError H v u g z +
        rectangleObservedError H v u g (cubeTranslation u z) + 4 * δ := by
  have he0 := rectangleObservedError_nonneg H v u g z
  have he1 := rectangleObservedError_nonneg H v u g (cubeTranslation u z)
  by_cases hz : cubeTranslation v z ∈ H.carrier
  · rw [rectangleMassScore_on_live H v u hu hv g z hz, sub_self, abs_zero]
    positivity
  · by_cases hp : cubeTranslation v (cubeTranslation u z) ∈ H.carrier
    · rw [rectangleMassScore_on_partner H v u hu hv g z hp]
      have he : g z - (-1 - g (cubeTranslation u z)) =
          g z + g (cubeTranslation u z) + 1 := by ring
      rw [he]
      linarith [hsym z]
    · have hout : cubeTranslation v z ∉ (H.adjoinPoint u).carrier := by
        intro h
        exact ((H.coset_mem_adjoinPoint u v z).mp h).elim hz hp
      by_cases hzu : z = u
      · subst z
        have hu0 : u ≠ cubeOne m := fun h => hu (h ▸ H.one_mem)
        have hone : cubeOne m ∈ rectangleObserved H v u := by
          constructor
          · simpa only [cubeTranslation_comm v (cubeOne m), cubeTranslation_one] using hv
          · exact Ne.symm hu0
        have hpu0 : cubeTranslation v (cubeOne m) ∉ H.carrier := by
          intro h
          exact hv (by simpa only [cubeTranslation_comm v (cubeOne m), cubeTranslation_one]
            using H.subset_adjoinPoint u h)
        have heone : rectangleObservedError H v u g (cubeOne m) =
            |g (cubeOne m) - 1 / 2| := by
          norm_num [rectangleObservedError, hone, reluReference, pointIndicator]
        have hscore : rectangleMassScore u (reluLiveMass H v g) u = -(3 : ℝ) / 2 := by
          simp [rectangleMassScore, rectangleBaseline, pointIndicator, hu0,
            reluLiveMass, hz, hpu0, cubeTranslation_self]
          <;> ring
        rw [hscore, cubeTranslation_self, heone]
        have hs := abs_le.mp (hsym u)
        simp only [cubeTranslation_self] at hs
        apply abs_le.mpr
        constructor <;> linarith [le_abs_self (g (cubeOne m) - 1 / 2),
          neg_le_abs (g (cubeOne m) - 1 / 2)]
      · have ho : z ∈ rectangleObserved H v u := ⟨hout, hzu⟩
        have hscore : rectangleMassScore u (reluLiveMass H v g) z = reluReference z := by
          simp only [rectangleMassScore, rectangleBaseline, reluReference, pointIndicator,
            if_neg hzu, reluLiveMass, if_neg hz, if_neg hp]
          ring
        rw [hscore]
        have he : rectangleObservedError H v u g z = |g z - reluReference z| := by
          simp only [rectangleObservedError, if_pos ho]
        rw [← he]
        linarith

/-- Averaged reconstruction from anti-invariance and actual observed slack. -/
theorem rectangleMassScore_mean_error {m : ℕ} (H : CubeSubgroup m)
    (v u : ClippingCube m) (hu : u ∉ H.carrier)
    (hv : v ∉ (H.adjoinPoint u).carrier) (g : ClippingCube m → ℝ) (δ s : ℝ)
    (hδ : 0 ≤ δ) (hsδ : s ≤ δ)
    (hsym : ∀ z, |g z + g (cubeTranslation u z) + 1| ≤ 4 * δ)
    (hobs : uniformCubeMean (rectangleObservedError H v u g) ≤ s) :
    uniformCubeMean (fun z =>
      |g z - rectangleMassScore u (reluLiveMass H v g) z|) ≤ 6 * δ := by
  have hmean := uniformCubeMean_mono _ _
    (rectangleMassScore_error_pointwise H v u hu hv g δ hδ hsym)
  have htranslation : uniformCubeMean (fun z =>
      rectangleObservedError H v u g (cubeTranslation u z)) =
        uniformCubeMean (rectangleObservedError H v u g) := by
    unfold uniformCubeMean
    rw [(cubeTranslation u).sum_comp]
  rw [uniformCubeMean_add, uniformCubeMean_add, htranslation] at hmean
  have hconst : uniformCubeMean (fun _ : ClippingCube m => (4 : ℝ) * δ) = 4 * δ := by
    simp [uniformCubeMean, Fintype.card_ne_zero]
  rw [hconst] at hmean
  linarith

theorem walshCoefficient_abs_le_mean_abs {m : ℕ} (f : ClippingCube m → ℝ)
    (e : Finset (Fin m)) : |walshCoefficients f e| ≤ uniformCubeMean (fun z => |f z|) := by
  have hM : (0 : ℝ) < Fintype.card (ClippingCube m) := Nat.cast_pos.mpr Fintype.card_pos
  unfold walshCoefficients uniformCubeMean
  rw [abs_div, abs_of_pos hM]
  apply div_le_div_of_nonneg_right _ hM.le
  calc
    _ ≤ ∑ z, |f z * walshCharacter e z| := Finset.abs_sum_le_sum_abs _ _
    _ = _ := by simp only [abs_mul, abs_walshCharacter, mul_one]

theorem rectangleMassScore_coefficient {m : ℕ} (u : ClippingCube m)
    (p : ClippingCube m → ℝ) (e : Finset (Fin m)) :
    walshCoefficients (rectangleMassScore u p) e =
      (if e = ∅ then -(1 : ℝ) / 2 else 0) +
        (1 - walshCharacter e u) *
          (1 / Fintype.card (ClippingCube m) + walshCoefficients p e) := by
  unfold rectangleMassScore rectangleBaseline
  rw [walshCoefficients_sub, walshCoefficients_add, walshCoefficients_sub,
    walshCoefficients_add, walshCoefficients_const, walshCoefficients_pointIndicator,
    walshCoefficients_pointIndicator, walshCoefficients_translation, walshCharacter_one]
  ring

theorem rectangleMassScore_annihilator_coefficient {m : ℕ} (H : CubeSubgroup m)
    (v u : ClippingCube m) (g : ClippingCube m → ℝ) (e : Finset (Fin m))
    (he : e ∈ H.differenceAnnihilator v) (heu : walshCharacter e u = -1) :
    walshCoefficients (rectangleMassScore u (reluLiveMass H v g)) e =
      2 * (1 - ∑ z, reluLiveMass H v g z) / Fintype.card (ClippingCube m) := by
  have he0 : e ≠ ∅ := fun h => H.empty_not_differenceAnnihilator v (h ▸ he)
  have heA : H.Annihilates e := (Finset.mem_filter.mp (Finset.mem_filter.mp he).1).2
  have hev : walshCharacter e v = -1 := (Finset.mem_filter.mp he).2
  rw [rectangleMassScore_coefficient, if_neg he0, heu,
    reluLiveMass_character_annihilator H v g e heA, hev]
  unfold uniformCubeMean
  ring

/-- One annihilating character that changes sign under the rectangle shift
controls the entire live mass. -/
theorem rectangleLiveMass_total_bound {m : ℕ} (H : CubeSubgroup m)
    (v u : ClippingCube m) (g : ClippingCube m → ℝ) (δ : ℝ)
    (e : Finset (Fin m)) (he : e ∈ H.differenceAnnihilator v)
    (heu : walshCharacter e u = -1)
    (herror : uniformCubeMean (fun z =>
      |g z - rectangleMassScore u (reluLiveMass H v g) z|) ≤ 6 * δ)
    (hcoef : -2 * δ ≤ walshCoefficients g e) :
    (∑ z, reluLiveMass H v g z) ≤ 1 + 4 * Fintype.card (ClippingCube m) * δ := by
  have hd := walshCoefficient_abs_le_mean_abs
    (fun z => g z - rectangleMassScore u (reluLiveMass H v g) z) e
  rw [walshCoefficients_sub, rectangleMassScore_annihilator_coefficient H v u g e he heu] at hd
  have hlo := (abs_le.mp (hd.trans herror)).2
  have hM : (0 : ℝ) < Fintype.card (ClippingCube m) := Nat.cast_pos.mpr Fintype.card_pos
  have hr : -8 * δ ≤ 2 * (1 - ∑ z, reluLiveMass H v g z) /
      Fintype.card (ClippingCube m) := by linarith
  have hh := (le_div_iff₀ hM).mp hr
  nlinarith

/-- The calibrated negative partners rule out significant negative live mass. -/
theorem rectangleLiveMass_negative_bound {m : ℕ} (H : CubeSubgroup m)
    (v u : ClippingCube m) (g : ClippingCube m → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
    (hsym : ∀ z, |g z + g (cubeTranslation u z) + 1| ≤ 4 * δ)
    (hpartner : ∀ z, cubeTranslation v z ∈ H.carrier →
      g (cubeTranslation u z) ≤ -(1 : ℝ) / 2) :
    (∑ z, negativePart (reluLiveMass H v g z)) ≤
      4 * Fintype.card (ClippingCube m) * δ := by
  have hpoint (z : ClippingCube m) : negativePart (reluLiveMass H v g z) ≤ 4 * δ := by
    by_cases hz : cubeTranslation v z ∈ H.carrier
    · have hs := (abs_le.mp (hsym z)).1
      have hp := hpartner z hz
      simp only [negativePart, reluLiveMass, if_pos hz]
      exact max_le (by linarith) (by positivity)
    · simp only [negativePart, reluLiveMass, if_neg hz, neg_zero, max_self]
      positivity
  have hs := Finset.sum_le_sum fun z (_ : z ∈ Finset.univ) => hpoint z
  simpa only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_left_comm,
    mul_assoc] using hs

lemma positivePart_eq_add_negativePart (r : ℝ) : positivePart r = r + negativePart r := by
  by_cases hr : 0 ≤ r
  · simp [positivePart, negativePart, max_eq_left hr, max_eq_right (by linarith : -r ≤ 0)]
  · have hneg : r ≤ 0 := le_of_lt (lt_of_not_ge hr)
    simp [positivePart, negativePart, max_eq_right hneg,
      max_eq_left (by linarith : 0 ≤ -r)]

/-- Complete quantitative rounding from actual rectangle reconstruction.
The numerical constant 44 replaces the optimized 11, leaving all asymptotic
absorption and resource bounds unchanged. -/
theorem rectangle_live_candidate_rounding {m : ℕ} (H : CubeSubgroup m)
    (v u : ClippingCube m) (hu : u ∉ H.carrier)
    (hv : v ∉ (H.adjoinPoint u).carrier) (g : ClippingCube m → ℝ) (δ s : ℝ)
    (hδ : 0 ≤ δ) (hsδ : s ≤ δ)
    (hsym : ∀ z, |g z + g (cubeTranslation u z) + 1| ≤ 4 * δ)
    (hobs : uniformCubeMean (rectangleObservedError H v u g) ≤ s)
    (e : Finset (Fin m)) (he : e ∈ H.differenceAnnihilator v)
    (heu : walshCharacter e u = -1) (hcoef : -2 * δ ≤ walshCoefficients g e)
    (hpartner : ∀ z, cubeTranslation v z ∈ H.carrier →
      g (cubeTranslation u z) ≤ -(1 : ℝ) / 2)
    (live : ClippingCube m → Prop)
    (hremoved : ∀ z, ¬ live z → reluLiveMass H v g z ≤ 0) :
    ∃ q, IsLiveCandidate live q ∧
      l1Distance (reluLiveMass H v g) q ≤
        44 * Fintype.card (ClippingCube m) * δ +
          4 * ∑ z, fractionalPenalty (reluLiveMass H v g z) := by
  have herror := rectangleMassScore_mean_error H v u hu hv g δ s hδ hsδ hsym hobs
  have htotal := rectangleLiveMass_total_bound H v u g δ e he heu herror hcoef
  have hnegative := rectangleLiveMass_negative_bound H v u g δ hδ hsym hpartner
  let η : ℝ := 4 * Fintype.card (ClippingCube m) * δ
  have hη : 0 ≤ η := by dsimp [η]; positivity
  have hpositive : (∑ z, positivePart (reluLiveMass H v g z)) ≤ 1 + 3 * η := by
    simp_rw [positivePart_eq_add_negativePart]
    rw [Finset.sum_add_distrib]
    change _ ≤ 1 + 3 * (4 * Fintype.card (ClippingCube m) * δ)
    have hprod : 0 ≤ (Fintype.card (ClippingCube m) : ℝ) * δ := by positivity
    nlinarith
  obtain ⟨q, hq, hround⟩ := live_candidate_rounding (reluLiveMass H v g) live η hη
    hnegative hpositive hremoved
  refine ⟨q, hq, ?_⟩
  dsimp only [η] at hround
  nlinarith only [hround]

end NeuralGeneralization.OnlineLowerGeometry
