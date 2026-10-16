import NeuralGeneralization.KernelSpectrum

/-!
# Exact coordinate-walk formula for the biased power spectrum

The endpoint is defined by the actual sequence of coordinate flips;
selecting the bias coordinate leaves it unchanged. A degree character's
power-kernel eigenvalue equals the fraction of all paths reaching that
specified subset. This is the finite combinatorial walk representation
used before Poissonization in the paper.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators

variable {d : ℕ}

def toggleCoordinate (S : Finset (Fin d)) (i : Fin d) : Finset (Fin d) :=
  if i ∈ S then S.erase i else insert i S

theorem walshCharacter_toggle (S : Finset (Fin d)) (i : Fin d) (x : ClippingCube d) :
    walshCharacter (toggleCoordinate S i) x =
      cubeCoordinateSign (x i) * walshCharacter S x := by
  classical
  by_cases hi : i ∈ S
  · simp only [toggleCoordinate, if_pos hi]
    have hprod : walshCharacter S x =
        cubeCoordinateSign (x i) * walshCharacter (S.erase i) x :=
      (Finset.mul_prod_erase S (fun j => cubeCoordinateSign (x j)) hi).symm
    rw [hprod]
    calc
      _ = cubeCoordinateSign (x i) ^ 2 * walshCharacter (S.erase i) x := by
        rw [cubeCoordinateSign_sq, one_mul]
      _ = _ := by ring
  · simp [toggleCoordinate, hi, walshCharacter, Finset.prod_insert]

def biasedPathEndpoint : {m : ℕ} → (Fin m → Option (Fin d)) → Finset (Fin d)
  | 0, _ => ∅
  | m + 1, p => match p 0 with
    | none => biasedPathEndpoint (fun i : Fin m => p i.succ)
    | some i => toggleCoordinate (biasedPathEndpoint (fun i : Fin m => p i.succ)) i

theorem biasedTensorFeature_endpoint {m : ℕ} (p : Fin m → Option (Fin d))
    (x : ClippingCube d) :
    biasedTensorFeature m p x = walshCharacter (biasedPathEndpoint p) x := by
  induction m with
  | zero => simp [biasedTensorFeature, biasedPathEndpoint, walshCharacter]
  | succ m ih =>
    unfold biasedTensorFeature
    rw [Fin.prod_univ_succ]
    have htail : (∏ i : Fin m, biasedCoordinate x (p i.succ)) =
        walshCharacter (biasedPathEndpoint (fun i : Fin m => p i.succ)) x :=
      ih (fun i : Fin m => p i.succ)
    rw [htail]
    cases hp : p 0 with
    | none => simp [biasedPathEndpoint, hp, biasedCoordinate]
    | some i => simp [biasedPathEndpoint, hp, biasedCoordinate, walshCharacter_toggle]

def biasedPathCount (m : ℕ) (S : Finset (Fin d)) : ℕ :=
  (Finset.univ.filter (fun p : Fin m → Option (Fin d) => biasedPathEndpoint p = S)).card

/-- Exact path-count formula: the denominator is the number of equally
likely coordinate-or-bias choices in each of the `m` steps. -/
theorem biasedDot_power_coefficient_walk (m : ℕ) (S : Finset (Fin d)) :
    walshCoefficients (biasedProfile (fun t => t ^ m)) S =
      (biasedPathCount m S : ℝ) / (d + 1 : ℝ) ^ m := by
  classical
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have hinner (p : Fin m → Option (Fin d)) :
      (∑ x : ClippingCube d, walshCharacter S x * biasedTensorFeature m p x) =
        if biasedPathEndpoint p = S then (Fintype.card (ClippingCube d) : ℝ) else 0 := by
    simp_rw [biasedTensorFeature_endpoint]
    rw [walshCharacter_orthogonal]
    simp only [eq_comm]
  have h := biasedDot_power_coefficient_formula m S
  simp_rw [hinner] at h
  have hsum : (∑ p : Fin m → Option (Fin d), (1 / (d + 1 : ℝ) ^ m) *
      (if biasedPathEndpoint p = S then (Fintype.card (ClippingCube d) : ℝ) else 0) ^ 2) =
      (biasedPathCount m S : ℝ) *
        ((1 / (d + 1 : ℝ) ^ m) * (Fintype.card (ClippingCube d) : ℝ) ^ 2) := by
    simp only [ite_pow, zero_pow (by decide : 2 ≠ 0), mul_ite, mul_zero]
    rw [← Finset.sum_filter]
    simp [biasedPathCount]
  rw [hsum] at h
  apply (mul_left_cancel₀ (pow_ne_zero 2 hM))
  calc
    (Fintype.card (ClippingCube d) : ℝ) ^ 2 *
        walshCoefficients (biasedProfile (fun t => t ^ m)) S = _ := h
    _ = _ := by ring

/-- A coordinate walk can activate at most one new coordinate per step. -/
theorem biasedPathEndpoint_card_le {m : ℕ} (p : Fin m → Option (Fin d)) :
    (biasedPathEndpoint p).card ≤ m := by
  induction m with
  | zero => simp [biasedPathEndpoint]
  | succ m ih =>
    have htail := ih (fun i : Fin m => p i.succ)
    cases hp : p 0 with
    | none => simp only [biasedPathEndpoint, hp]; omega
    | some i =>
      simp only [biasedPathEndpoint, hp]
      unfold toggleCoordinate
      split_ifs with hi
      · have hcard := Finset.card_le_card
          (Finset.erase_subset (s := biasedPathEndpoint (fun j : Fin m => p j.succ)) i)
        omega
      · rw [Finset.card_insert_of_notMem hi]
        omega

/-- A polynomial power has no Walsh coefficients above its actual degree. -/
theorem biasedDot_power_coefficient_zero (m : ℕ) (S : Finset (Fin d))
    (hdegree : m < S.card) :
    walshCoefficients (biasedProfile (fun t => t ^ m)) S = 0 := by
  classical
  rw [biasedDot_power_coefficient_walk]
  have hempty : (Finset.univ.filter
      (fun p : Fin m → Option (Fin d) => biasedPathEndpoint p = S)) = ∅ := by
    apply Finset.eq_empty_iff_forall_notMem.mpr
    intro p hp
    have he := (Finset.mem_filter.mp hp).2
    have hc := biasedPathEndpoint_card_le p
    rw [he] at hc
    omega
  simp [biasedPathCount, hempty]

/-- The sum of the normalized power-kernel eigenvalues is its unit diagonal. -/
theorem biasedDot_power_coefficient_sum (m : ℕ) :
    (∑ S : Finset (Fin d), walshCoefficients (biasedProfile (fun t => t ^ m)) S) = 1 := by
  have h := walshExpansion_coefficients
    (biasedProfile (d := d) (fun t => t ^ m)) (fun _ => true)
  have hden : (d + 1 : ℝ) ≠ 0 := by positivity
  simpa [walshExpansion, walshCharacter, biasedProfile, cubeCoordinateSign,
    add_comm, hden] using h

end NeuralGeneralization
