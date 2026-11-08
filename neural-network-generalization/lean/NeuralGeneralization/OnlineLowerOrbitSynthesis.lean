import NeuralGeneralization.OnlineLowerHomogeneousWitness
import NeuralGeneralization.OnlineLowerExactHomogeneous
import NeuralGeneralization.OnlineLowerGeometryWalsh
import Mathlib.Algebra.BigOperators.Fin

/-!
# Exact finite synthesis by coordinate-sign orbits

A neuron with nonzero Walsh coefficient on `S` produces the exact character
`χ_S` when its coordinate-sign orbit is averaged with the character signs.
The orbit is a literal finite family of incoming vectors and readouts. Its
weighted atomic cost is calculated exactly, not postulated as a realizable
Fourier norm. The result applies to arbitrary activations; ReLU homogeneity
then removes the separate neuron-allocation-mass constraint.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerGeometry

/-- Output of a single affine neuron on the actual augmented Boolean input. -/
def atomOutput {d : ℕ} (φ : ℝ → ℝ) (a : Fin (d + 1) → ℝ) (x : Cube d) : ℝ :=
  φ (∑ k, a k * inputVector x k)

/-- Flip the physical input coefficients and leave the constant coordinate fixed. -/
def orbitIncoming {d : ℕ} (a : Fin (d + 1) → ℝ) (t : Cube d) : Fin (d + 1) → ℝ :=
  Fin.cases (a 0) (fun i => a i.succ * labelReal (t i))

theorem cubeTranslation_comm {d : ℕ} (t x : Cube d) :
    cubeTranslation t x = cubeTranslation x t := by
  funext i
  cases ht : t i <;> cases hx : x i <;> simp [cubeTranslation, ht, hx]

theorem labelReal_translation {d : ℕ} (t x : Cube d) (i : Fin d) :
    labelReal (cubeTranslation t x i) = labelReal (t i) * labelReal (x i) :=
  cubeCoordinateSign_translation t x i

theorem atomOutput_orbitIncoming {d : ℕ} (φ : ℝ → ℝ)
    (a : Fin (d + 1) → ℝ) (t x : Cube d) :
    atomOutput φ (orbitIncoming a t) x = atomOutput φ a (cubeTranslation t x) := by
  unfold atomOutput
  congr 1
  rw [Fin.sum_univ_succ, Fin.sum_univ_succ]
  simp only [orbitIncoming, inputVector, Fin.cases_zero, Fin.cases_succ,
    mul_one, labelReal_translation]
  congr 1
  apply Finset.sum_congr rfl
  intro i hi
  ring

theorem incomingAtomCost_orbitIncoming {d : ℕ}
    (a : Fin (d + 1) → ℝ) (t : Cube d) :
    incomingAtomCost (orbitIncoming a t) = incomingAtomCost a := by
  unfold incomingAtomCost
  congr 1
  rw [Fin.sum_univ_succ, Fin.sum_univ_succ]
  simp only [orbitIncoming, Fin.cases_zero, Fin.cases_succ, mul_pow]
  have hs (i : Fin d) : labelReal (t i) ^ 2 = 1 := cubeCoordinateSign_sq (t i)
  simp_rw [hs, mul_one]

theorem walshCharacter_abs_one {d : ℕ} (S : Finset (Fin d)) (t : Cube d) :
    |walshCharacter S t| = 1 := by
  have hs := walshCharacter_sq S t
  have ha := abs_nonneg (walshCharacter S t)
  have habssq := sq_abs (walshCharacter S t)
  nlinarith

/-- The exact character projection of the translation orbit. -/
theorem signed_orbit_average {d : ℕ} (φ : ℝ → ℝ)
    (a : Fin (d + 1) → ℝ) (S : Finset (Fin d)) (x : Cube d) :
    (∑ t : Cube d, walshCharacter S t * atomOutput φ a (cubeTranslation t x)) /
      Fintype.card (Cube d) =
      walshCharacter S x * walshCoefficients (atomOutput φ a) S := by
  have h := walshCoefficients_translation x (atomOutput φ a) S
  rw [← h]
  unfold walshCoefficients uniformCubeMean
  congr 1
  apply Finset.sum_congr rfl
  intro t ht
  rw [cubeTranslation_comm t x]
  ring

/-- The readout coefficients that synthesize a prescribed parity amplitude. -/
def orbitReadout {d : ℕ} (φ : ℝ → ℝ) (a : Fin (d + 1) → ℝ)
    (S : Finset (Fin d)) (v : ℝ) (t : Cube d) : ℝ :=
  v * walshCharacter S t /
    ((Fintype.card (Cube d) : ℝ) * walshCoefficients (atomOutput φ a) S)

theorem orbitReadout_abs {d : ℕ} (φ : ℝ → ℝ) (a : Fin (d + 1) → ℝ)
    (S : Finset (Fin d)) (v : ℝ) (t : Cube d) :
    |orbitReadout φ a S v t| = |v| /
      ((Fintype.card (Cube d) : ℝ) * |walshCoefficients (atomOutput φ a) S|) := by
  have hM : (0 : ℝ) < Fintype.card (Cube d) := Nat.cast_pos.mpr Fintype.card_pos
  simp [orbitReadout, abs_div, abs_mul, walshCharacter_abs_one]

/-- Literal finite readouts and literal flipped incoming weights realize the
specified parity, with no approximation. -/
theorem orbit_synthesizes_character {d : ℕ} (φ : ℝ → ℝ)
    (a : Fin (d + 1) → ℝ) (S : Finset (Fin d)) (v : ℝ)
    (hq : walshCoefficients (atomOutput φ a) S ≠ 0) (x : Cube d) :
    (∑ t : Cube d, orbitReadout φ a S v t * atomOutput φ (orbitIncoming a t) x) =
      v * walshCharacter S x := by
  have hM : (Fintype.card (Cube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  simp_rw [atomOutput_orbitIncoming]
  calc
    _ = (v / walshCoefficients (atomOutput φ a) S) *
        ((∑ t : Cube d, walshCharacter S t * atomOutput φ a (cubeTranslation t x)) /
          Fintype.card (Cube d)) := by
      unfold orbitReadout
      rw [Finset.sum_div, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro t ht
      field_simp
    _ = (v / walshCoefficients (atomOutput φ a) S) *
        (walshCharacter S x * walshCoefficients (atomOutput φ a) S) := by
      rw [signed_orbit_average]
    _ = v * walshCharacter S x := by field_simp

/-- The exact weighted atomic cost of the full orbit. -/
theorem orbit_weighted_cost {d : ℕ} (φ : ℝ → ℝ)
    (a : Fin (d + 1) → ℝ) (S : Finset (Fin d)) (v : ℝ)
    (hq : walshCoefficients (atomOutput φ a) S ≠ 0) :
    (∑ t : Cube d, 2 * |orbitReadout φ a S v t| *
      Real.sqrt (incomingAtomCost (orbitIncoming a t))) =
      2 * |v| * Real.sqrt (incomingAtomCost a) /
        |walshCoefficients (atomOutput φ a) S| := by
  have hM : (Fintype.card (Cube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have hqabs : |walshCoefficients (atomOutput φ a) S| ≠ 0 := abs_ne_zero.mpr hq
  simp_rw [incomingAtomCost_orbitIncoming, orbitReadout_abs]
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

theorem orbitReadout_ne_zero {d : ℕ} (φ : ℝ → ℝ)
    (a : Fin (d + 1) → ℝ) (S : Finset (Fin d)) (v : ℝ)
    (hq : walshCoefficients (atomOutput φ a) S ≠ 0) (hv : v ≠ 0) (t : Cube d) :
    orbitReadout φ a S v t ≠ 0 := by
  have hχ : walshCharacter S t ≠ 0 := by
    intro h
    have ha := walshCharacter_abs_one S t
    simp [h] at ha
  have hM : (Fintype.card (Cube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  exact div_ne_zero (mul_ne_zero hv hχ) (mul_ne_zero hM hq)

/-- Simultaneously synthesize a finite family of actual parity coefficients.
The returned vectors/readouts are indexed exactly as required by the concrete
finite-width copying theorem. No unspecified atomic representation is assumed. -/
theorem finite_orbit_synthesis {d r : ℕ} (φ : ℝ → ℝ)
    (S : Fin r → Finset (Fin d)) (a : Fin r → Fin (d + 1) → ℝ) (v : Fin r → ℝ)
    (hq : ∀ j, walshCoefficients (atomOutput φ (a j)) (S j) ≠ 0)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (hv : ∀ j, v j ≠ 0) :
    ∃ A : Fin (r * Fintype.card (Cube d)) → Fin (d + 1) → ℝ,
    ∃ c : Fin (r * Fintype.card (Cube d)) → ℝ,
      (∀ i, 0 < incomingAtomCost (A i)) ∧ (∀ i, c i ≠ 0) ∧
      (∀ x, atomicScore φ A c x = ∑ j, v j * walshCharacter (S j) x) ∧
      atomicWeightedCost A c =
        ∑ j, 2 * |v j| * Real.sqrt (incomingAtomCost (a j)) /
          |walshCoefficients (atomOutput φ (a j)) (S j)| := by
  classical
  let e : (Fin r × Cube d) ≃ Fin (r * Fintype.card (Cube d)) :=
    Fintype.equivOfCardEq (by simp)
  let A : Fin (r * Fintype.card (Cube d)) → Fin (d + 1) → ℝ :=
    fun i => orbitIncoming (a (e.symm i).1) (e.symm i).2
  let c : Fin (r * Fintype.card (Cube d)) → ℝ :=
    fun i => orbitReadout φ (a (e.symm i).1) (S (e.symm i).1) (v (e.symm i).1) (e.symm i).2
  refine ⟨A, c, ?_, ?_, ?_, ?_⟩
  · intro i
    dsimp [A]
    rw [incomingAtomCost_orbitIncoming]
    exact ha _
  · intro i
    exact orbitReadout_ne_zero φ _ _ _ (hq _) (hv _) _
  · intro x
    let F : Fin r × Cube d → ℝ := fun p =>
      orbitReadout φ (a p.1) (S p.1) (v p.1) p.2 *
        atomOutput φ (orbitIncoming (a p.1) p.2) x
    change (∑ i, F (e.symm i)) = _
    rw [e.symm.sum_comp, Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro j hj
    exact orbit_synthesizes_character φ (a j) (S j) (v j) (hq j) x
  · let F : Fin r × Cube d → ℝ := fun p =>
      2 * |orbitReadout φ (a p.1) (S p.1) (v p.1) p.2| *
        Real.sqrt (incomingAtomCost (orbitIncoming (a p.1) p.2))
    change (∑ i, F (e.symm i)) = _
    rw [e.symm.sum_comp, Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro j hj
    exact orbit_weighted_cost φ (a j) (S j) (v j) (hq j)

/-- Fully concrete finite-width realization of a closed-margin Fourier score
for ReLU or another positively homogeneous activation. The only coefficient
premise is nonvanishing of the displayed actual finite Walsh sums. -/
theorem homogeneous_fourier_score_strict_witness_all_large {d r : ℕ}
    (φ : ℝ → ℝ) (hφ : ∀ scale : ℝ, 0 < scale → ∀ t, φ (scale * t) = scale * φ t)
    (S : Fin r → Finset (Fin d)) (a : Fin r → Fin (d + 1) → ℝ) (v : Fin r → ℝ)
    (hq : ∀ j, walshCoefficients (atomOutput φ (a j)) (S j) ≠ 0)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (hv : ∀ j, v j ≠ 0)
    (g : BooleanFunction d)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g x) * (∑ j, v j * walshCharacter (S j) x))
    (B : ℝ) (hbudget : (∑ j, 2 * |v j| * Real.sqrt (incomingAtomCost (a j)) /
      |walshCoefficients (atomOutput φ (a j)) (S j)|) < B) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N →
      ∃ w : Weights d N 0, w ∈ marginEvent φ (1 / 2) g ∧ weightedSquaredNorm w < B := by
  obtain ⟨A, c, hA, hc, hscore, hcost⟩ := finite_orbit_synthesis φ S a v hq ha hv
  apply homogeneous_closed_score_strict_witness_all_large φ hφ A c hA hc g
  · intro x
    simpa only [hscore x] using hmargin x
  · simpa only [hcost] using hbudget

/-- Exact Fourier-score realization and exact cost at the explicit width
threshold given by the full orbit count. -/
theorem homogeneous_fourier_score_exact_at_width {d r N : ℕ}
    (φ : ℝ → ℝ) (hφ : ∀ scale : ℝ, 0 < scale → ∀ t, φ (scale * t) = scale * φ t)
    (S : Fin r → Finset (Fin d)) (a : Fin r → Fin (d + 1) → ℝ) (v : Fin r → ℝ)
    (hq : ∀ j, walshCoefficients (atomOutput φ (a j)) (S j) ≠ 0)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (hv : ∀ j, v j ≠ 0)
    (hN : 0 < N) (hwidth : r * Fintype.card (Cube d) ≤ N) :
    ∃ w : Weights d N 0,
      (∀ x, networkOutput φ w x = ∑ j, v j * walshCharacter (S j) x) ∧
      weightedSquaredNorm w =
        ∑ j, 2 * |v j| * Real.sqrt (incomingAtomCost (a j)) /
          |walshCoefficients (atomOutput φ (a j)) (S j)| := by
  obtain ⟨A, c, hA, hc, hscore, hcost⟩ := finite_orbit_synthesis φ S a v hq ha hv
  obtain ⟨w, hw, he⟩ := homogeneous_atomic_exact_at_width φ hφ A c hA hc hN hwidth
  exact ⟨w, fun x => (hw x).trans (hscore x), he.trans hcost⟩

/-- The actual strict-margin Fourier witness at every width above the full
orbit count. The threshold does not depend on the energy-gap size. -/
theorem homogeneous_fourier_score_strict_witness_at_width {d r N : ℕ}
    (φ : ℝ → ℝ) (hφ : ∀ scale : ℝ, 0 < scale → ∀ t, φ (scale * t) = scale * φ t)
    (S : Fin r → Finset (Fin d)) (a : Fin r → Fin (d + 1) → ℝ) (v : Fin r → ℝ)
    (hq : ∀ j, walshCoefficients (atomOutput φ (a j)) (S j) ≠ 0)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (hv : ∀ j, v j ≠ 0)
    (g : BooleanFunction d)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g x) * (∑ j, v j * walshCharacter (S j) x))
    (B : ℝ) (hbudget : (∑ j, 2 * |v j| * Real.sqrt (incomingAtomCost (a j)) /
      |walshCoefficients (atomOutput φ (a j)) (S j)|) < B)
    (hN : 0 < N) (hwidth : r * Fintype.card (Cube d) ≤ N) :
    ∃ w : Weights d N 0, w ∈ marginEvent φ (1 / 2) g ∧ weightedSquaredNorm w < B := by
  obtain ⟨A, c, hA, hc, hscore, hcost⟩ := finite_orbit_synthesis φ S a v hq ha hv
  apply homogeneous_closed_score_strict_witness_at_width φ hφ A c hA hc g
  · intro x
    simpa only [hscore x] using hmargin x
  · simpa only [hcost] using hbudget
  · exact hN
  · exact hwidth

end NeuralGeneralization.OnlineLower
