import NeuralGeneralization.ArcsineNoiseTail
import Mathlib.Data.Finset.Interval
import Mathlib.Logic.Equiv.Fintype

/-! Inclusion monotonicity of the actual biased neural covariance spectrum. -/

noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

variable {d : ℕ}

/-- Conditional Fourier identity: fixing one coordinate negative removes
its character, with the exact original cube normalization. -/
theorem walsh_coefficient_difference (P Q : ClippingCube d → ℝ)
    (S : Finset (Fin d)) (i : Fin d) (hi : i ∉ S)
    (hnegative : ∀ x, x i = false → P x = Q x)
    (hflip : ∀ x, Q (cubeFlip i x) = Q x) :
    walshCoefficients P S - walshCoefficients P (insert i S) = walshCoefficients Q S := by
  classical
  let D : ClippingCube d → ℝ := fun x =>
    P x * walshCharacter S x * (1 - cubeCoordinateSign (x i))
  have hpoint (x : ClippingCube d) : D x + D (cubeFlip i x) =
      2 * (Q x * walshCharacter S x) := by
    have hχ : walshCharacter S (cubeFlip i x) = walshCharacter S x := by
      rw [walshCharacter_flip, if_neg hi]
    have hs : cubeCoordinateSign (cubeFlip i x i) = -cubeCoordinateSign (x i) := by
      simp [cubeFlip, cubeCoordinateSign_not]
    dsimp [D]
    rw [hχ, hs]
    cases hx : x i with
    | false =>
      rw [hnegative x hx]
      simp [cubeCoordinateSign]
      ring
    | true =>
      have hfalse : cubeFlip i x i = false := by simp [cubeFlip, hx]
      rw [hnegative (cubeFlip i x) hfalse, hflip]
      simp [cubeCoordinateSign]
      ring
  have hsum := congrArg (fun F : ClippingCube d → ℝ => ∑ x, F x) (funext hpoint)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum] at hsum
  rw [(cubeFlip i).sum_comp D] at hsum
  have he : (∑ x : ClippingCube d, D x) = ∑ x : ClippingCube d, Q x * walshCharacter S x := by
    linarith
  unfold walshCoefficients uniformCubeMean
  rw [← sub_div, ← Finset.sum_sub_distrib]
  congr 1
  rw [← he]
  apply Finset.sum_congr rfl
  intro x hx
  simp only [D, walshCharacter, Finset.prod_insert hi]
  ring

/-- After fixing one coordinate negative, the positive bias cancels. -/
def canceledBiasProfile (i : Fin d) (x : ClippingCube d) : ℝ :=
  (∑ j ∈ Finset.univ.erase i, cubeCoordinateSign (x j)) / (d + 1 : ℝ)

theorem canceledBiasProfile_flip (i : Fin d) (x : ClippingCube d) :
    canceledBiasProfile i (cubeFlip i x) = canceledBiasProfile i x := by
  unfold canceledBiasProfile
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  have hji := (Finset.mem_erase.mp hj).1
  simp [cubeFlip, Function.update_of_ne hji]

theorem biasedProfile_negative (i : Fin d) (x : ClippingCube d) (hx : x i = false) :
    biasedProfile id x = canceledBiasProfile i x := by
  unfold biasedProfile canceledBiasProfile
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
  simp [cubeCoordinateSign, hx, add_comm]

theorem canceledBiasProfile_abs_le_one (i : Fin d) (x : ClippingCube d) :
    |canceledBiasProfile i x| ≤ 1 := by
  have h := abs_biasedProfile_id_le_one (Function.update x i false)
  rw [biasedProfile_negative i _ (by simp)] at h
  have he : canceledBiasProfile i (Function.update x i false) = canceledBiasProfile i x := by
    unfold canceledBiasProfile
    congr 1
    apply Finset.sum_congr rfl
    intro j hj
    simp [Function.update_of_ne (Finset.mem_erase.mp hj).1]
  rwa [he] at h

theorem walshCoefficients_character (S T : Finset (Fin d)) :
    walshCoefficients (walshCharacter T) S = if S = T then 1 else 0 := by
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold walshCoefficients uniformCubeMean
  rw [walshCharacter_orthogonal]
  by_cases h : S = T
  · subst T
    simp
  · simp [h, Ne.symm h]

theorem canceledBiasProfile_coefficient_nonneg (i : Fin d) (S : Finset (Fin d)) :
    0 ≤ walshCoefficients (canceledBiasProfile i) S := by
  classical
  have he : canceledBiasProfile i = fun x => ∑ j ∈ Finset.univ.erase i,
      (1 / (d + 1 : ℝ)) * walshCharacter {j} x := by
    funext x
    simp only [canceledBiasProfile, walshCharacter, Finset.prod_singleton]
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro j hj
    ring
  rw [he, walshCoefficients_finite_sum]
  apply Finset.sum_nonneg
  intro j hj
  rw [walshCoefficients_character]
  positivity

/-- Actual normalized arcsine composition preserves nonnegative spectrum
for every bounded cube profile, including the bias-canceled one. -/
theorem iteratedArcsine_profile_coefficient_nonneg (P : ClippingCube d → ℝ)
    (hbound : ∀ x, |P x| ≤ 1) (hP : ∀ S, 0 ≤ walshCoefficients P S)
    (k : ℕ) (S : Finset (Fin d)) :
    0 ≤ walshCoefficients (fun x => iteratedArcsine k (P x)) S := by
  induction k generalizing S with
  | zero => exact hP S
  | succ k ih =>
    apply profile_series_coefficient_nonneg
      (fun x => iteratedArcsine k (P x)) (fun x => iteratedArcsine (k + 1) (P x))
      arcsineLinkCoefficient (fun n => 2 * n + 1)
      ih
      (fun n => (arcsineLinkCoefficient_pos n).le) (by norm_num)
    intro x
    exact (hasSum_arcsineLink_closed (abs_iteratedArcsine_le_one (hbound x) k)).tendsto_sum_nat

/-- Every actual neural eigenvalue decreases when one coordinate is added
 to its Walsh subset. The proof uses cancellation of the positive bias. -/
theorem arcsineProfile_coefficient_insert_le (k : ℕ) (S : Finset (Fin d))
    (i : Fin d) (hi : i ∉ S) :
    walshCoefficients (arcsineProfile d k) (insert i S) ≤
      walshCoefficients (arcsineProfile d k) S := by
  have he := walsh_coefficient_difference (arcsineProfile d k)
    (fun x => iteratedArcsine k (canceledBiasProfile i x)) S i hi
    (fun x hx => congrArg (iteratedArcsine k) (biasedProfile_negative i x hx))
    (fun x => congrArg (iteratedArcsine k) (canceledBiasProfile_flip i x))
  have hpos := iteratedArcsine_profile_coefficient_nonneg (canceledBiasProfile i)
    (canceledBiasProfile_abs_le_one i) (canceledBiasProfile_coefficient_nonneg i) k S
  linarith

/-- Inclusion monotonicity for arbitrary pairs of subsets. -/
theorem arcsineProfile_coefficient_antitone (k : ℕ) :
    Antitone (fun S : Finset (Fin d) => walshCoefficients (arcsineProfile d k) S) := by
  classical
  apply Finset.antitone_iff_forall_insert_le.mpr
  intro S i hi
  exact arcsineProfile_coefficient_insert_le k S i hi

/-- Reindexing input coordinates is an exact cube permutation. -/
def cubeReindex (e : Equiv.Perm (Fin d)) : ClippingCube d ≃ ClippingCube d where
  toFun x i := x (e i)
  invFun x i := x (e.symm i)
  left_inv x := by funext i; simp
  right_inv x := by funext i; simp

theorem arcsineProfile_reindex (k : ℕ) (e : Equiv.Perm (Fin d)) (x : ClippingCube d) :
    arcsineProfile d k (cubeReindex e x) = arcsineProfile d k x := by
  unfold arcsineProfile biasedProfile
  congr 2
  exact congrArg (fun t : ℝ => 1 + t) (Equiv.sum_comp e (fun i => cubeCoordinateSign (x i)))

theorem walshCharacter_reindex (S : Finset (Fin d)) (e : Equiv.Perm (Fin d))
    (x : ClippingCube d) :
    walshCharacter S (cubeReindex e x) = walshCharacter (S.map e.toEmbedding) x := by
  simp [walshCharacter, Finset.prod_map, cubeReindex]

theorem arcsineProfile_coefficient_map (k : ℕ) (e : Equiv.Perm (Fin d))
    (S : Finset (Fin d)) :
    walshCoefficients (arcsineProfile d k) (S.map e.toEmbedding) =
      walshCoefficients (arcsineProfile d k) S := by
  have h := (cubeReindex e).sum_comp
    (fun x => arcsineProfile d k x * walshCharacter S x)
  simp_rw [arcsineProfile_reindex, walshCharacter_reindex] at h
  exact congrArg (fun t : ℝ => t / (Fintype.card (ClippingCube d) : ℝ)) h

/-- The actual spectrum depends only on the cardinality of the Walsh set. -/
theorem arcsineProfile_coefficient_eq_of_card_eq (k : ℕ) (S T : Finset (Fin d))
    (hcard : S.card = T.card) :
    walshCoefficients (arcsineProfile d k) S = walshCoefficients (arcsineProfile d k) T := by
  classical
  let e : S ≃ T := Finset.equivOfCardEq hcard
  have hmap : S.map e.extendSubtype.toEmbedding = T := by
    apply Finset.eq_of_subset_of_card_le
    · intro x hx
      obtain ⟨y, hy, hxy⟩ := Finset.mem_map.mp hx
      subst x
      exact e.extendSubtype_mem y hy
    · simpa only [Finset.card_map] using hcard.symm.le
  have h := arcsineProfile_coefficient_map k e.extendSubtype S
  rw [hmap] at h
  exact h.symm

/-- Every eigenvalue in degrees at least `r` is bounded by the trace tail
divided by the number of degree-`r` Walsh characters. -/
theorem arcsineProfile_coefficient_binomial_le_tail (k r : ℕ) (S : Finset (Fin d))
    (hrS : r ≤ S.card) :
    (d.choose r : ℝ) * walshCoefficients (arcsineProfile d k) S ≤
      walshSpectralTail (arcsineProfile d k) r := by
  classical
  obtain ⟨T, hTS, hTcard⟩ := Finset.exists_subset_card_eq hrS
  have hST := arcsineProfile_coefficient_antitone k hTS
  let A : Finset (Finset (Fin d)) := Finset.univ.powersetCard r
  have hcard : A.card = d.choose r := by simp [A, Finset.card_powersetCard]
  calc
    _ = ∑ U ∈ A, walshCoefficients (arcsineProfile d k) S := by
      simp only [Finset.sum_const, nsmul_eq_mul, hcard]
    _ ≤ ∑ U ∈ A, walshCoefficients (arcsineProfile d k) U := by
      apply Finset.sum_le_sum
      intro U hU
      have hUcard := (Finset.mem_powersetCard.mp hU).2
      rw [arcsineProfile_coefficient_eq_of_card_eq k U T (hUcard.trans hTcard.symm)]
      exact hST
    _ ≤ _ := by
      apply Finset.sum_le_sum_of_subset_of_nonneg
      · intro U hU
        apply Finset.mem_filter.mpr
        exact ⟨Finset.mem_univ _, (Finset.mem_powersetCard.mp hU).2.ge⟩
      · intro U hU hnot
        exact arcsineProfile_coefficient_nonneg d k U

/-- An actual normalized spectral second-moment upper bound. -/
theorem arcsineProfile_tail_second_moment (k r : ℕ) :
    (d.choose r : ℝ) *
        (∑ S ∈ (Finset.univ.filter (fun S : Finset (Fin d) => r ≤ S.card)),
          walshCoefficients (arcsineProfile d k) S ^ 2) ≤
      walshSpectralTail (arcsineProfile d k) r ^ 2 := by
  classical
  rw [Finset.mul_sum]
  calc
    _ ≤ ∑ S ∈ (Finset.univ.filter (fun S : Finset (Fin d) => r ≤ S.card)),
        walshSpectralTail (arcsineProfile d k) r * walshCoefficients (arcsineProfile d k) S := by
      apply Finset.sum_le_sum
      intro S hS
      have h := mul_le_mul_of_nonneg_right
        (arcsineProfile_coefficient_binomial_le_tail k r S (Finset.mem_filter.mp hS).2)
        (arcsineProfile_coefficient_nonneg d k S)
      nlinarith only [h]
    _ = _ := by
      rw [← Finset.mul_sum]
      change walshSpectralTail (arcsineProfile d k) r * walshSpectralTail (arcsineProfile d k) r = _
      ring

/-- Negating all input coordinates is an exact cube permutation. -/
def cubeNegate : ClippingCube d ≃ ClippingCube d where
  toFun x i := !(x i)
  invFun x i := !(x i)
  left_inv x := by funext i; simp
  right_inv x := by funext i; simp

theorem walshCharacter_negate (S : Finset (Fin d)) (x : ClippingCube d) :
    walshCharacter S (cubeNegate x) = (-1 : ℝ) ^ S.card * walshCharacter S x := by
  simp only [walshCharacter, cubeNegate, Equiv.coe_fn_mk, cubeCoordinateSign_not,
    Finset.prod_neg]

theorem iteratedArcsine_odd (k : ℕ) (t : ℝ) :
    iteratedArcsine k (-t) = -iteratedArcsine k t := by
  induction k with
  | zero => rfl
  | succ k ih => simp [iteratedArcsine, ih, arcsineLink, Real.arcsin_neg]

theorem canceledBiasProfile_negate (i : Fin d) (x : ClippingCube d) :
    canceledBiasProfile i (cubeNegate x) = -canceledBiasProfile i x := by
  simp only [canceledBiasProfile, cubeNegate, Equiv.coe_fn_mk, cubeCoordinateSign_not,
    Finset.sum_neg_distrib, neg_div]

/-- The exact paired equality between each even level and the next odd
level is a consequence of the zero-bias profile's oddness. -/
theorem arcsineProfile_coefficient_even_pair (k : ℕ) (S : Finset (Fin d))
    (i : Fin d) (hi : i ∉ S) (hEven : Even S.card) :
    walshCoefficients (arcsineProfile d k) S =
      walshCoefficients (arcsineProfile d k) (insert i S) := by
  have he := walsh_coefficient_difference (arcsineProfile d k)
    (fun x => iteratedArcsine k (canceledBiasProfile i x)) S i hi
    (fun x hx => congrArg (iteratedArcsine k) (biasedProfile_negative i x hx))
    (fun x => congrArg (iteratedArcsine k) (canceledBiasProfile_flip i x))
  have hsum := (cubeNegate (d := d)).sum_comp
    (fun x => iteratedArcsine k (canceledBiasProfile i x) * walshCharacter S x)
  simp_rw [canceledBiasProfile_negate, iteratedArcsine_odd, walshCharacter_negate,
    hEven.neg_one_pow, one_mul, neg_mul, Finset.sum_neg_distrib] at hsum
  have hzero : (∑ x : ClippingCube d,
      iteratedArcsine k (canceledBiasProfile i x) * walshCharacter S x) = 0 := by linarith
  have hcoef : walshCoefficients (fun x => iteratedArcsine k (canceledBiasProfile i x)) S = 0 := by
    simp only [walshCoefficients, uniformCubeMean, hzero, zero_div]
  rw [hcoef] at he
  linarith

/-- The full-parity direction attains the smallest normalized eigenvalue. -/
theorem arcsineProfile_fullParity_min (k : ℕ) (S : Finset (Fin d)) :
    walshCoefficients (arcsineProfile d k) Finset.univ ≤
      walshCoefficients (arcsineProfile d k) S :=
  arcsineProfile_coefficient_antitone k (Finset.subset_univ S)

/-- Explicit individual-eigenvalue decay with the correct all-depth tail
exponent and a binomial denominator, valid throughout the high spectrum. -/
theorem arcsineProfile_coefficient_power_upper (k r : ℕ) (S : Finset (Fin d))
    (hr : 0 < r) (hrS : r ≤ S.card) :
    (2 * r : ℝ) *
      (((d.choose r : ℝ) * walshCoefficients (arcsineProfile d k) S) / 4) ^ (2 ^ k) ≤ 1 := by
  have h := arcsineProfile_coefficient_binomial_le_tail k r S hrS
  have hscaled := div_le_div_of_nonneg_right h (by norm_num : (0 : ℝ) ≤ 4)
  have hnonneg : 0 ≤ ((d.choose r : ℝ) * walshCoefficients (arcsineProfile d k) S) / 4 :=
    div_nonneg (mul_nonneg (Nat.cast_nonneg _) (arcsineProfile_coefficient_nonneg d k S))
      (by norm_num)
  have hp := pow_le_pow_left₀ hnonneg hscaled (2 ^ k)
  exact (mul_le_mul_of_nonneg_left hp (by positivity : (0 : ℝ) ≤ 2 * r)).trans
    (iterated_arcsine_spectral_tail_power d k r hr)

/-- Actual spectral high-pass covariance, with the same normalized
population eigenvalues as the full covariance. -/
def arcsineTailCovariance (d k r : ℕ) : ClippingCube d → ClippingCube d → ℝ :=
  walshKernel (fun S => if r ≤ S.card then walshCoefficients (arcsineProfile d k) S else 0)

theorem walshKernel_square_row (w : Finset (Fin d) → ℝ) (x : ClippingCube d) :
    uniformCubeMean (fun y => walshKernel w x y ^ 2) = ∑ S, w S ^ 2 := by
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have he : walshKernel w x = walshExpansion (fun S => w S * walshCharacter S x) := by
    funext y
    unfold walshKernel featureKernel walshExpansion
    apply Finset.sum_congr rfl
    intro S hS
    ring
  rw [he]
  unfold uniformCubeMean
  rw [walshExpansion_parseval]
  simp only [mul_pow, walshCharacter_sq, mul_one]
  field_simp

theorem arcsineTailCovariance_diagonal (k r : ℕ) (x : ClippingCube d) :
    arcsineTailCovariance d k r x x = walshSpectralTail (arcsineProfile d k) r := by
  classical
  unfold arcsineTailCovariance walshKernel featureKernel walshSpectralTail
  simp only [mul_assoc, ← pow_two, walshCharacter_sq, mul_one]
  rw [Finset.sum_filter]

theorem arcsineTailCovariance_square_row (k r : ℕ) (x : ClippingCube d) :
    uniformCubeMean (fun y => arcsineTailCovariance d k r x y ^ 2) =
      ∑ S ∈ (Finset.univ.filter (fun S : Finset (Fin d) => r ≤ S.card)),
        walshCoefficients (arcsineProfile d k) S ^ 2 := by
  classical
  unfold arcsineTailCovariance
  rw [walshKernel_square_row, Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro S hS
  by_cases h : r ≤ S.card <;> simp [h]

/-- Every row of the actual tail covariance has the checked small mean
square required as an input to Gram-matrix concentration. -/
theorem arcsineTailCovariance_square_row_upper (k r : ℕ) (x : ClippingCube d) :
    (d.choose r : ℝ) * uniformCubeMean (fun y => arcsineTailCovariance d k r x y ^ 2) ≤
      walshSpectralTail (arcsineProfile d k) r ^ 2 := by
  rw [arcsineTailCovariance_square_row]
  exact arcsineProfile_tail_second_moment k r

end NeuralGeneralization
