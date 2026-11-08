import NeuralGeneralization.OnlineLowerGeometryReluCalibration
import NeuralGeneralization.OnlineLowerGeometryAlgebra

/-! # Actual Fourier mass and second moment for the ReLU live-fiber score

The score and its live mass are the literal finite cube functions from
`OnlineLowerGeometryReluCalibration`.  All Fourier estimates below are
proved from that dual and the observed margins.
-/

noncomputable section
open scoped BigOperators Classical symmDiff

namespace NeuralGeneralization.OnlineLowerGeometry

private theorem cube_card_posR (m : ℕ) : (0 : ℝ) < Fintype.card (ClippingCube m) :=
  Nat.cast_pos.mpr Fintype.card_pos

private theorem coeff_abs_le_mean_abs {m : ℕ} (g : ClippingCube m → ℝ)
    (S : Finset (Fin m)) : |walshCoefficients g S| ≤ uniformCubeMean (fun z => |g z|) := by
  unfold walshCoefficients uniformCubeMean
  rw [abs_div, abs_of_pos (cube_card_posR m)]
  apply div_le_div_of_nonneg_right _ (cube_card_posR m).le
  calc
    _ ≤ ∑ z, |g z * walshCharacter S z| := Finset.abs_sum_le_sum_abs _ _
    _ = _ := by simp only [abs_mul, abs_walshCharacter, mul_one]

def reluOutsideError {m : ℕ} (H : CubeSubgroup m) (v : ClippingCube m)
    (g : ClippingCube m → ℝ) (z : ClippingCube m) : ℝ :=
  if cubeTranslation v z ∈ H.carrier then 0 else g z - reluReference z

theorem relu_score_decomposition {m : ℕ} (H : CubeSubgroup m)
    (v : ClippingCube m) (hv : v ∉ H.carrier) (g : ClippingCube m → ℝ) (z) :
    g z = reluReference z + reluLiveMass H v g z + reluOutsideError H v g z := by
  by_cases hz : cubeTranslation v z ∈ H.carrier
  · rw [reluReference_on_coset H v z hv hz]
    simp only [reluLiveMass, reluOutsideError, if_pos hz]
    ring
  · simp only [reluLiveMass, reluOutsideError, if_neg hz]
    ring

theorem reluReference_coefficient_nonempty {m : ℕ} (S : Finset (Fin m))
    (hS : S ≠ ∅) :
    walshCoefficients reluReference S = 1 / Fintype.card (ClippingCube m) := by
  change walshCoefficients (fun z => (-(1 : ℝ) / 2) + pointIndicator (cubeOne m) z) S = _
  rw [walshCoefficients_add, walshCoefficients_const,
    walshCoefficients_pointIndicator, walshCharacter_one, if_neg hS]
  ring

theorem reluOutsideError_mean_abs {m : ℕ} (H : CubeSubgroup m)
    (v : ClippingCube m) (g : ClippingCube m → ℝ) :
    uniformCubeMean (fun z => |reluOutsideError H v g z|) =
      uniformCubeMean (fun z => if cubeTranslation v z ∉ H.carrier then
        |g z - reluReference z| else 0) := by
  congr 1
  funext z
  by_cases hz : cubeTranslation v z ∈ H.carrier <;> simp [reluOutsideError, hz]

theorem reluLiveMass_eq_product {m : ℕ} (H : CubeSubgroup m)
    (v : ClippingCube m) (g : ClippingCube m → ℝ) :
    reluLiveMass H v g = fun z => (g z + 1 / 2) * H.cosetIndicator v z := by
  funext z
  simp only [reluLiveMass, CubeSubgroup.cosetIndicator, CubeSubgroup.indicator]
  split_ifs <;> ring

theorem reluLiveMass_algebra_bound {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (g : ClippingCube m → ℝ)
    (B : ℝ) (hw0 : 0 < w ∅) (hw : ∀ S, w ∅ ≤ w S)
    (hcost : weightedWalshCost w g ≤ B) :
    walshAlgebraNorm (reluLiveMass H v g) ≤ B / w ∅ + 1 / 2 := by
  rw [reluLiveMass_eq_product]
  calc
    _ ≤ walshAlgebraNorm (fun z => g z + 1 / 2) * walshAlgebraNorm (H.cosetIndicator v) :=
      walshAlgebraNorm_product _ _
    _ = walshAlgebraNorm (fun z => g z + 1 / 2) := by rw [walshAlgebraNorm_coset, mul_one]
    _ ≤ walshAlgebraNorm g + walshAlgebraNorm (fun _ : ClippingCube m => (1 : ℝ) / 2) :=
      walshAlgebraNorm_add _ _
    _ ≤ B / w ∅ + 1 / 2 := by
      rw [walshAlgebraNorm_const]
      norm_num
      exact (walshAlgebraNorm_le_weighted w (w ∅) hw0 hw g).trans
        (div_le_div_of_nonneg_right hcost hw0.le)

theorem reluLiveMass_character_annihilator {m : ℕ} (H : CubeSubgroup m)
    (v : ClippingCube m) (g : ClippingCube m → ℝ) (S : Finset (Fin m))
    (hS : H.Annihilates S) :
    walshCoefficients (reluLiveMass H v g) S =
      walshCharacter S v * uniformCubeMean (reluLiveMass H v g) := by
  have hpoint (z : ClippingCube m) :
      reluLiveMass H v g z * walshCharacter S z =
        walshCharacter S v * reluLiveMass H v g z := by
    by_cases hz : cubeTranslation v z ∈ H.carrier
    · have hχ := hS (cubeTranslation v z) hz
      rw [walshCharacter_translation] at hχ
      have hsq := walshCharacter_sq S v
      have heq : walshCharacter S z = walshCharacter S v := by
        calc
          _ = (walshCharacter S v ^ 2) * walshCharacter S z := by rw [hsq, one_mul]
          _ = walshCharacter S v * (walshCharacter S v * walshCharacter S z) := by ring
          _ = _ := by rw [hχ, mul_one]
      rw [heq, mul_comm]
    · simp [reluLiveMass, hz]
  unfold walshCoefficients uniformCubeMean
  simp_rw [hpoint]
  rw [← Finset.mul_sum]
  ring

theorem reluLiveMass_difference_negate {m : ℕ} (H : CubeSubgroup m)
    (v : ClippingCube m) (g : ClippingCube m → ℝ) (e S : Finset (Fin m))
    (he : e ∈ H.differenceAnnihilator v) :
    walshCoefficients (reluLiveMass H v g) (e ∆ S) =
      -walshCoefficients (reluLiveMass H v g) S := by
  rw [← walshCoefficients_mul_character]
  have hpoint : (fun z => reluLiveMass H v g z * walshCharacter e z) =
      fun z => -reluLiveMass H v g z := by
    funext z
    by_cases hz : cubeTranslation v z ∈ H.carrier
    · rw [H.difference_character_on_coset v z hz e he]
      ring
    · simp [reluLiveMass, hz]
  rw [hpoint]
  simp only [walshCoefficients, uniformCubeMean, neg_mul, Finset.sum_neg_distrib]
  ring

theorem annihilator_symmDiff_iff {m : ℕ} (H : CubeSubgroup m)
    (e S : Finset (Fin m)) (he : H.Annihilates e) :
    H.Annihilates (e ∆ S) ↔ H.Annihilates S := by
  constructor
  · intro h z hz
    have h' := h z hz
    simpa only [OnlineLowerRelu.walshCharacter_symmDiff, he z hz, one_mul] using h'
  · intro h z hz
    simp only [OnlineLowerRelu.walshCharacter_symmDiff, he z hz, h z hz, mul_one]



def reluDualDeficit {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (g : ClippingCube m → ℝ)
    (B : ℝ) : ℝ := B - uniformCubeMean (fun z => reluDualScore w H v z * g z)

private theorem relu_defect_sum {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (g : ClippingCube m → ℝ) :
    (∑ S, (w S * |walshCoefficients g S| -
      reluDualCoefficients w H v S * walshCoefficients g S)) =
      weightedWalshCost w g - uniformCubeMean (fun z => reluDualScore w H v z * g z) := by
  rw [walsh_inner_identity]
  simp only [reluDualScore, walshCoefficients_expansion, Finset.sum_sub_distrib,
    weightedWalshCost, weightedL1]

/-- At least one coefficient on the difference annihilator has small
absolute value. This is derived from the *sum* of the concrete dual
coefficient slacks, rather than assuming a coefficient bound. -/
theorem relu_exists_small_difference_coefficient {m : ℕ}
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v : ClippingCube m)
    (g : ClippingCube m → ℝ) (B : ℝ) (hw0 : 0 < w ∅)
    (hw : ∀ S, w ∅ ≤ w S) (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hcost : weightedWalshCost w g ≤ B) :
    ∃ e ∈ H.differenceAnnihilator v,
      |walshCoefficients g e| ≤ reluDualDeficit w H v g B / (2 * w ∅) := by
  let E := H.differenceAnnihilator v
  have hEn : E.Nonempty := Finset.card_pos.mp (by dsimp [E]; omega)
  obtain ⟨e, he, hmin⟩ := E.exists_min_image (fun S => |walshCoefficients g S|) hEn
  refine ⟨e, he, ?_⟩
  have hER : (0 : ℝ) < E.card := Nat.cast_pos.mpr (by dsimp [E]; omega)
  let δ : ℝ := 2 * w ∅ / E.card
  have hδ0 : 0 ≤ δ := div_nonneg (by linarith) hER.le
  have hδ : δ ≤ w ∅ := by
    apply (div_le_iff₀ hER).mpr
    have : (2 : ℝ) ≤ E.card := by exact_mod_cast hcard
    nlinarith
  have hfeas := reluDual_coefficients_feasible w H v hw0.le hw hcard
  have hterm (S) (hS : S ∈ E) :
      δ * |walshCoefficients g e| ≤ w S * |walshCoefficients g S| -
        reluDualCoefficients w H v S * walshCoefficients g S := by
    have hS0 : S ≠ ∅ := fun h => H.empty_not_differenceAnnihilator v (h ▸ hS)
    have hdual : reluDualCoefficients w H v S = w S - δ := by
      simp [reluDualCoefficients, hS0, show S ∈ H.differenceAnnihilator v from hS, δ, E]
    have hslack : δ ≤ w S - |reluDualCoefficients w H v S| := by
      rw [hdual, abs_of_nonneg (by linarith [hw S])]
      linarith
    exact (mul_le_mul_of_nonneg_left (hmin S hS) hδ0).trans
      (coefficient_slack _ _ _ _ hslack)
  have hsum := Finset.sum_le_sum hterm
  have hsub : (∑ S ∈ E, (w S * |walshCoefficients g S| -
      reluDualCoefficients w H v S * walshCoefficients g S)) ≤
      ∑ S, (w S * |walshCoefficients g S| -
        reluDualCoefficients w H v S * walshCoefficients g S) := by
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ E)
      (fun S _ _ => coefficient_defect_nonneg _ _ _ (hfeas S))
  have heq : (∑ S ∈ E, δ * |walshCoefficients g e|) =
      2 * w ∅ * |walshCoefficients g e| := by
    simp only [Finset.sum_const, nsmul_eq_mul]
    dsimp [δ]
    field_simp
  rw [heq] at hsum
  rw [relu_defect_sum] at hsub
  apply (le_div_iff₀ (by linarith : 0 < 2 * w ∅)).mpr
  dsimp [reluDualDeficit]
  nlinarith [hsum.trans hsub]

/-- Every coefficient outside the annihilator has the required one-sided
bound because its dual coefficient is fully saturated at `+w S`. -/
theorem relu_coefficient_lower_outside_annihilator {m : ℕ}
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v : ClippingCube m)
    (g : ClippingCube m → ℝ) (B : ℝ) (hw0 : 0 < w ∅)
    (hw : ∀ S, w ∅ ≤ w S) (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hcost : weightedWalshCost w g ≤ B) (S : Finset (Fin m))
    (hS : ¬ H.Annihilates S) :
    -reluDualDeficit w H v g B / (2 * w ∅) ≤ walshCoefficients g S := by
  have hfeas := reluDual_coefficients_feasible w H v hw0.le hw hcard
  have hS0 : S ≠ ∅ := by
    intro h
    subst S
    exact hS (by intro z hz; simp [walshCharacter])
  have hSE : S ∉ H.differenceAnnihilator v := by
    intro h
    exact hS (Finset.mem_filter.mp (Finset.mem_filter.mp h).1).2
  have hdual : reluDualCoefficients w H v S = w S := by
    simp [reluDualCoefficients, hS0, hSE]
  have hnonneg : 0 ≤ reluDualDeficit w H v g B := by
    have hh := walsh_dual_bound w g (reluDualScore w H v) (fun T => by
      rw [reluDualScore, walshCoefficients_expansion]; exact hfeas T)
    dsimp [reluDualDeficit]
    linarith
  by_cases ha : 0 ≤ walshCoefficients g S
  · exact (div_nonpos_of_nonpos_of_nonneg (by linarith) (by linarith)).trans ha
  have hat : walshCoefficients g S < 0 := lt_of_not_ge ha
  have hterm := Finset.single_le_sum
    (fun T (_ : T ∈ Finset.univ) => coefficient_defect_nonneg (w T) (walshCoefficients g T) (reluDualCoefficients w H v T) (hfeas T))
    (Finset.mem_univ S)
  rw [relu_defect_sum, hdual, abs_of_neg hat] at hterm
  have hproduct : -(2 * w ∅) * walshCoefficients g S ≤
      -(2 * w S) * walshCoefficients g S := by
    nlinarith [mul_nonneg (sub_nonneg.mpr (hw S)) (neg_nonneg.mpr hat.le)]
  apply (div_le_iff₀ (by linarith : 0 < 2 * w ∅)).mpr
  dsimp [reluDualDeficit]
  nlinarith



/-- The affine coset supplies both signs of every nonannihilating Fourier
character. A single small difference coefficient controls the total mass. -/
theorem reluLiveMass_fourier_bounds {m : ℕ} (H : CubeSubgroup m)
    (v : ClippingCube m) (hv : v ∉ H.carrier) (g : ClippingCube m → ℝ)
    (e : Finset (Fin m)) (he : e ∈ H.differenceAnnihilator v)
    (δ ε : ℝ) (hδ : 0 ≤ δ) (hε : 0 ≤ ε)
    (hsmall : |walshCoefficients g e| ≤ δ)
    (hlower : ∀ S, ¬ H.Annihilates S → -δ ≤ walshCoefficients g S)
    (herror : uniformCubeMean (fun z => |reluOutsideError H v g z|) ≤ ε) :
    |(∑ z, reluLiveMass H v g z) - 1| ≤
      (Fintype.card (ClippingCube m) : ℝ) * (δ + ε) ∧
    ∀ S, |walshCoefficients (reluLiveMass H v g) S| ≤
      1 / Fintype.card (ClippingCube m) + δ + ε := by
  let M : ℝ := Fintype.card (ClippingCube m)
  let p := reluLiveMass H v g
  let r := reluOutsideError H v g
  have hM : 0 < M := cube_card_posR m
  have he0 : e ≠ ∅ := fun h => H.empty_not_differenceAnnihilator v (h ▸ he)
  have heA : H.Annihilates e := (Finset.mem_filter.mp (Finset.mem_filter.mp he).1).2
  have heχ : walshCharacter e v = -1 := (Finset.mem_filter.mp he).2
  have hcoeff (S : Finset (Fin m)) (hS : S ≠ ∅) :
      walshCoefficients g S = 1 / M + walshCoefficients p S + walshCoefficients r S := by
    have hfun : g = fun z => reluReference z + p z + r z := by
      funext z
      exact relu_score_decomposition H v hv g z
    rw [hfun, walshCoefficients_add, walshCoefficients_add,
      reluReference_coefficient_nonempty S hS]
  have herr (S : Finset (Fin m)) : |walshCoefficients r S| ≤ ε :=
    (coeff_abs_le_mean_abs r S).trans herror
  have hmassnorm : |uniformCubeMean p - 1 / M| ≤ δ + ε := by
    have hh := hcoeff e he0
    rw [reluLiveMass_character_annihilator H v g e heA, heχ] at hh
    have he' := (abs_le.mp hsmall)
    have hr' := (abs_le.mp (herr e))
    apply abs_le.mpr
    constructor <;> linarith
  have hmass : |(∑ z, p z) - 1| ≤ M * (δ + ε) := by
    have heq : (∑ z, p z) - 1 = M * (uniformCubeMean p - 1 / M) := by
      unfold uniformCubeMean
      dsimp [M]
      field_simp
    rw [heq, abs_mul, abs_of_pos hM]
    exact mul_le_mul_of_nonneg_left hmassnorm hM.le
  refine ⟨hmass, ?_⟩
  intro S
  by_cases hSA : H.Annihilates S
  · rw [reluLiveMass_character_annihilator H v g S hSA, abs_mul,
      abs_walshCharacter, one_mul]
    have hmass' := abs_le.mp hmassnorm
    apply abs_le.mpr
    constructor <;> linarith [one_div_nonneg.mpr hM.le]
  · have hS0 : S ≠ ∅ := by
      intro h
      subst S
      exact hSA (by intro z hz; simp [walshCharacter])
    have hES : ¬ H.Annihilates (e ∆ S) := by
      intro h
      exact hSA ((annihilator_symmDiff_iff H e S heA).mp h)
    have hES0 : e ∆ S ≠ ∅ := by
      intro h
      apply hES
      rw [h]
      intro z hz
      simp [walshCharacter]
    have hplus := hcoeff S hS0
    have hminus := hcoeff (e ∆ S) hES0
    rw [reluLiveMass_difference_negate H v g e S he] at hminus
    have hp := hlower S hSA
    have hn := hlower (e ∆ S) hES
    have herp := (abs_le.mp (herr S))
    have hern := (abs_le.mp (herr (e ∆ S)))
    apply abs_le.mpr
    constructor <;> linarith

private theorem coefficient_type_card (m : ℕ) :
    Fintype.card (Finset (Fin m)) = Fintype.card (ClippingCube m) := by
  simp [ClippingCube, Fintype.card_finset, Fintype.card_pi]

/-- Parseval turns the actual coefficient bound into the required
second moment, with no independence assumption on logical coordinates. -/
theorem walsh_second_moment_of_coefficient_bound {m : ℕ}
    (p : ClippingCube m → ℝ) (b : ℝ) (hb : 0 ≤ b)
    (hcoeff : ∀ S, |walshCoefficients p S| ≤ b) :
    (∑ z, p z ^ 2) ≤ (Fintype.card (ClippingCube m) : ℝ) ^ 2 * b ^ 2 := by
  have hsum : (∑ S, walshCoefficients p S ^ 2) ≤
      (Fintype.card (ClippingCube m) : ℝ) * b ^ 2 := by
    calc
      _ ≤ ∑ _ : Finset (Fin m), b ^ 2 := Finset.sum_le_sum fun S _ => by
        nlinarith [hcoeff S, sq_abs (walshCoefficients p S),
          abs_nonneg (walshCoefficients p S)]
      _ = _ := by simp
  have hparseval := walsh_inner_identity p p
  have hparseval' : (∑ z, p z ^ 2) =
      (Fintype.card (ClippingCube m) : ℝ) * ∑ S, walshCoefficients p S ^ 2 := by
    simp only [← pow_two] at hparseval
    unfold uniformCubeMean at hparseval
    exact (div_eq_iff (ne_of_gt (cube_card_posR m))).mp hparseval |>.trans (mul_comm _ _)
  rw [hparseval']
  nlinarith [mul_le_mul_of_nonneg_left hsum (cube_card_posR m).le]

/-- A second Parseval estimate uses the actual Walsh algebra norm, and
is linear rather than quadratic in the coefficient bound. -/
theorem walsh_second_moment_of_algebra_bound {m : ℕ}
    (p : ClippingCube m → ℝ) (b A : ℝ) (hb : 0 ≤ b)
    (hcoeff : ∀ S, |walshCoefficients p S| ≤ b)
    (halgebra : walshAlgebraNorm p ≤ A) :
    (∑ z, p z ^ 2) ≤ (Fintype.card (ClippingCube m) : ℝ) * b * A := by
  have hsum : (∑ S, walshCoefficients p S ^ 2) ≤ b * A := by
    calc
      _ ≤ ∑ S, b * |walshCoefficients p S| := Finset.sum_le_sum fun S _ => by
        nlinarith [mul_le_mul_of_nonneg_right (hcoeff S) (abs_nonneg (walshCoefficients p S)),
          sq_abs (walshCoefficients p S)]
      _ = b * walshAlgebraNorm p := by rw [← Finset.mul_sum]; rfl
      _ ≤ b * A := mul_le_mul_of_nonneg_left halgebra hb
  have hparseval := walsh_inner_identity p p
  simp only [← pow_two] at hparseval
  unfold uniformCubeMean at hparseval
  have hmul := (div_eq_iff (ne_of_gt (cube_card_posR m))).mp hparseval
  rw [hmul]
  nlinarith [mul_le_mul_of_nonneg_left hsum (cube_card_posR m).le]



def reluFourierEta {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (g : ClippingCube m → ℝ)
    (B : ℝ) : ℝ := (Fintype.card (ClippingCube m) : ℝ) *
      (reluDualDeficit w H v g B + reluCalibrationSlack w H v g) / (2 * w ∅)

/-- All inputs to the manuscript's `45 η + 6 V` rounding lemma are
consequences of the literal dual and observed margins. In particular,
`p` is not assumed to be a probability vector or to have bounded norm. -/
theorem relu_live_mass_and_second_moment {m : ℕ}
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v : ClippingCube m)
    (g : ClippingCube m → ℝ) (B : ℝ)
    (hv : v ∉ H.carrier) (hw0 : 0 < w ∅) (hw : ∀ S, w ∅ ≤ w S)
    (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hsum : 6 * w ∅ ≤ ∑ S, w S)
    (hcostsign : ∀ z, z ≠ cubeOne m → walshExpansion w z ≤ 0)
    (hanchor : (1 : ℝ) / 2 ≤ g (cubeOne m))
    (hnegative : ∀ z, cubeTranslation v z ∉ H.carrier → z ≠ cubeOne m →
      g z ≤ -(1 : ℝ) / 2)
    (hcost : weightedWalshCost w g ≤ B) (hbudget : B / w ∅ ≤ 10) :
    let p := reluLiveMass H v g
    let η := reluFourierEta w H v g B
    0 ≤ η ∧ |(∑ z, p z) - 1| ≤ η ∧
      (∑ z, p z ^ 2) ≤ (1 + η) ^ 2 ∧
      (1 < η → (∑ z, p z ^ 2) ≤ 21 * η) := by
  dsimp only
  let D := reluDualDeficit w H v g B
  let S := reluCalibrationSlack w H v g
  let M : ℝ := Fintype.card (ClippingCube m)
  let δ := D / (2 * w ∅)
  let ε := S / (2 * w ∅)
  let η := reluFourierEta w H v g B
  let p := reluLiveMass H v g
  have hM : 0 < M := cube_card_posR m
  have hw2 : 0 < 2 * w ∅ := by linarith
  have hcp : 0 < (H.differenceAnnihilator v).card := by omega
  have hS : 0 ≤ S := reluCalibrationSlack_nonneg w H v hv hcp hw0.le
    hsum hcostsign g hanchor hnegative
  have hD : 0 ≤ D := by
    have hh := walsh_dual_bound w g (reluDualScore w H v) (fun T => by
      rw [reluDualScore, walshCoefficients_expansion]
      exact reluDual_coefficients_feasible w H v hw0.le hw hcard T)
    dsimp [D, reluDualDeficit]
    linarith
  have hδ : 0 ≤ δ := div_nonneg hD hw2.le
  have hε : 0 ≤ ε := div_nonneg hS hw2.le
  have hηeq : η = M * (δ + ε) := by
    dsimp [η, reluFourierEta, M, δ, ε, D, S]
    ring
  have hη : 0 ≤ η := by rw [hηeq]; positivity
  obtain ⟨e, he, hsmall⟩ := relu_exists_small_difference_coefficient w H v g B hw0 hw hcard hcost
  have herror : uniformCubeMean (fun z => |reluOutsideError H v g z|) ≤ ε := by
    rw [reluOutsideError_mean_abs]
    apply (le_div_iff₀ hw2).mpr
    have hh := relu_calibration_deviation_bound w H v hv hcp hw0.le
      hsum hcostsign g hanchor hnegative
    dsimp [S]
    nlinarith
  obtain ⟨hmass, hcoeff⟩ := reluLiveMass_fourier_bounds H v hv g e he δ ε hδ hε hsmall
    (by intro T hT; simpa only [δ, D, neg_div] using
      relu_coefficient_lower_outside_annihilator w H v g B hw0 hw hcard hcost T hT) herror
  have hb : 0 ≤ 1 / M + δ + ε := by positivity
  have halgebra : walshAlgebraNorm p ≤ (21 : ℝ) / 2 := by
    have hh := reluLiveMass_algebra_bound w H v g B hw0 hw hcost
    dsimp [p]
    linarith
  have hMb : M * (1 / M + δ + ε) = 1 + η := by
    rw [hηeq]
    field_simp
    <;> ring
  have hsmallL2 : (∑ z, p z ^ 2) ≤ (1 + η) ^ 2 := by
    have hh := walsh_second_moment_of_coefficient_bound p (1 / M + δ + ε) hb hcoeff
    have heq : M ^ 2 * (1 / M + δ + ε) ^ 2 = (1 + η) ^ 2 := by
      rw [← mul_pow, hMb]
    change (∑ z, p z ^ 2) ≤ M ^ 2 * (1 / M + δ + ε) ^ 2 at hh
    rwa [heq] at hh
  refine ⟨hη, ?_, hsmallL2, ?_⟩
  · change |(∑ z, p z) - 1| ≤ M * (δ + ε) at hmass
    rwa [← hηeq] at hmass
  · intro hη1
    have hh := walsh_second_moment_of_algebra_bound p (1 / M + δ + ε)
      ((21 : ℝ) / 2) hb hcoeff halgebra
    change (∑ z, p z ^ 2) ≤ M * (1 / M + δ + ε) * (21 / 2) at hh
    rw [hMb] at hh
    linarith

end NeuralGeneralization.OnlineLowerGeometry
