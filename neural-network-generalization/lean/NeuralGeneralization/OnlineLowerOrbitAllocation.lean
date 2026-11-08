import NeuralGeneralization.OnlineLowerOrbitSynthesis

/-! # Finite orbit witnesses with the allocation mass retained

Unlike positive homogeneity, the explicit mass bound works for tanh and
other nonhomogeneous activations. Zero Fourier coefficients are removed
before copying neurons, without changing the score, energy, or mass.
-/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerGeometry

theorem orbit_allocation_mass {d : ℕ} (φ : ℝ → ℝ)
    (a : Fin (d + 1) → ℝ) (S : Finset (Fin d)) (v : ℝ) :
    (∑ t : Cube d, |orbitReadout φ a S v t| /
      Real.sqrt (incomingAtomCost (orbitIncoming a t))) =
      |v| / (|walshCoefficients (atomOutput φ a) S| * Real.sqrt (incomingAtomCost a)) := by
  have hM : (Fintype.card (Cube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  simp_rw [incomingAtomCost_orbitIncoming, orbitReadout_abs]
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

theorem finite_orbit_synthesis_with_mass {d r : ℕ} (φ : ℝ → ℝ)
    (S : Fin r → Finset (Fin d)) (a : Fin r → Fin (d + 1) → ℝ) (v : Fin r → ℝ)
    (hq : ∀ j, walshCoefficients (atomOutput φ (a j)) (S j) ≠ 0)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (hv : ∀ j, v j ≠ 0) :
    ∃ A : Fin (r * Fintype.card (Cube d)) → Fin (d + 1) → ℝ,
    ∃ c : Fin (r * Fintype.card (Cube d)) → ℝ,
      (∀ i, 0 < incomingAtomCost (A i)) ∧ (∀ i, c i ≠ 0) ∧
      (∀ x, atomicScore φ A c x = ∑ j, v j * walshCharacter (S j) x) ∧
      atomicWeightedCost A c =
        ∑ j, 2 * |v j| * Real.sqrt (incomingAtomCost (a j)) /
          |walshCoefficients (atomOutput φ (a j)) (S j)| ∧
      atomicAllocationMass A c =
        ∑ j, |v j| / (|walshCoefficients (atomOutput φ (a j)) (S j)| *
          Real.sqrt (incomingAtomCost (a j))) := by
  classical
  let e : (Fin r × Cube d) ≃ Fin (r * Fintype.card (Cube d)) :=
    Fintype.equivOfCardEq (by simp)
  let A : Fin (r * Fintype.card (Cube d)) → Fin (d + 1) → ℝ :=
    fun i => orbitIncoming (a (e.symm i).1) (e.symm i).2
  let c : Fin (r * Fintype.card (Cube d)) → ℝ :=
    fun i => orbitReadout φ (a (e.symm i).1) (S (e.symm i).1) (v (e.symm i).1) (e.symm i).2
  refine ⟨A, c, ?_, ?_, ?_, ?_, ?_⟩
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

  · let F : Fin r × Cube d → ℝ := fun p =>
      |orbitReadout φ (a p.1) (S p.1) (v p.1) p.2| /
        Real.sqrt (incomingAtomCost (orbitIncoming (a p.1) p.2))
    change (∑ i, F (e.symm i)) = _
    rw [e.symm.sum_comp, Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro j hj
    exact orbit_allocation_mass φ (a j) (S j) (v j)


private theorem sum_active_orbit {ι : Type*} [Fintype ι]
    (v : ι → ℝ) (F : ι → ℝ) (hzero : ∀ i, v i = 0 → F i = 0) :
    (∑ i : {i : ι // v i ≠ 0}, F i.val) = ∑ i, F i := by
  have hh := Fintype.sum_subtype_add_sum_subtype (fun i => v i ≠ 0) F
  have hz : (∑ i : {i : ι // ¬ v i ≠ 0}, F i.val) = 0 := by
    apply Finset.sum_eq_zero
    intro i _
    exact hzero i.val (not_not.mp i.property)
  rw [hz, add_zero] at hh
  exact hh

/-- A literal finite orbit representation with strict allocation slack
produces strict feasible networks at every sufficiently large fixed width.
The Fourier index type is arbitrary and zero coefficients are allowed. -/
theorem allocated_fourier_strict_witness_all_large {d : ℕ} {ι : Type*} [Fintype ι]
    (φ : ℝ → ℝ) (S : ι → Finset (Fin d))
    (a : ι → Fin (d + 1) → ℝ) (v : ι → ℝ)
    (hq : ∀ j, walshCoefficients (atomOutput φ (a j)) (S j) ≠ 0)
    (ha : ∀ j, 0 < incomingAtomCost (a j))
    (hslack : (∑ j, |v j| / (|walshCoefficients (atomOutput φ (a j)) (S j)| *
      Real.sqrt (incomingAtomCost (a j)))) < 1)
    (g : BooleanFunction d)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g x) * ∑ j, v j * walshCharacter (S j) x)
    (B : ℝ) (hbudget : (∑ j, 2 * |v j| * Real.sqrt (incomingAtomCost (a j)) /
      |walshCoefficients (atomOutput φ (a j)) (S j)|) < B) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N →
      ∃ w : Weights d N 0, w ∈ marginEvent φ (1 / 2) g ∧ weightedSquaredNorm w < B := by
  let I := {i : ι // v i ≠ 0}
  let e := Fintype.equivFin I
  let s : Fin (Fintype.card I) → ι := fun j => (e.symm j).val
  have hs (j) : v (s j) ≠ 0 := (e.symm j).property
  have hsum (F : ι → ℝ) (hzero : ∀ i, v i = 0 → F i = 0) :
      (∑ j : Fin (Fintype.card I), F (s j)) = ∑ i, F i := by
    rw [show (∑ j : Fin (Fintype.card I), F (s j)) = ∑ i : I, F i.val from
      e.symm.sum_comp (fun i : I => F i.val)]
    exact sum_active_orbit v F hzero
  obtain ⟨A, c, hA, hc, hscore, hcost, hmass⟩ := finite_orbit_synthesis_with_mass φ
    (fun j => S (s j)) (fun j => a (s j)) (fun j => v (s j))
    (fun j => hq (s j)) (fun j => ha (s j)) hs
  apply closed_atomic_score_strict_witness_all_large φ A c hA hc
  · rw [hmass, hsum (fun j => |v j| /
        (|walshCoefficients (atomOutput φ (a j)) (S j)| * Real.sqrt (incomingAtomCost (a j))))
      (by intro j hj; simp [hj])]
    exact hslack
  · intro x
    rw [hscore x, hsum (fun j => v j * walshCharacter (S j) x) (by intro j hj; simp [hj])]
    exact hmargin x
  · rw [hcost, hsum (fun j => 2 * |v j| * Real.sqrt (incomingAtomCost (a j)) /
        |walshCoefficients (atomOutput φ (a j)) (S j)|) (by intro j hj; simp [hj])]
    exact hbudget

end NeuralGeneralization.OnlineLower
