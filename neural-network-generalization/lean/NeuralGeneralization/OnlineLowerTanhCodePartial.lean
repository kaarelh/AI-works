import NeuralGeneralization.OnlineLowerTanhCodeDifferences

/-! # Partial-coordinate cancellation in actual physical tanh Walsh coefficients -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

@[simp] theorem subsetInputs_join_selected {d : ℕ} (A : Finset (Fin d))
    (y : Cube Aᶜ.card) (z : Cube A.card) :
    subsetInputs A ((subsetCubeEquiv A).symm (y,z)) = z :=
  congrArg Prod.snd ((subsetCubeEquiv A).apply_symm_apply (y,z))

@[simp] theorem subsetInputs_join_outside {d : ℕ} (A : Finset (Fin d))
    (y : Cube Aᶜ.card) (z : Cube A.card) :
    subsetInputs Aᶜ ((subsetCubeEquiv A).symm (y,z)) = y :=
  congrArg Prod.fst ((subsetCubeEquiv A).apply_symm_apply (y,z))

theorem incomingLinear_join {d : ℕ} (A : Finset (Fin d)) (u : Fin d → ℝ)
    (y : Cube Aᶜ.card) (z : Cube A.card) :
    incomingLinear u ((subsetCubeEquiv A).symm (y,z)) =
      incomingLinear (subsetWeights A u) z + incomingLinear (subsetWeights Aᶜ u) y := by
  have h := incomingLinear_partition A u ((subsetCubeEquiv A).symm (y,z))
  simpa only [subsetInputs_join_selected, subsetInputs_join_outside] using h.symm

theorem cubeMean_join {d : ℕ} (A : Finset (Fin d)) (f : Cube d → ℝ) :
    cubeMean f = cubeMean (fun y => cubeMean (fun z => f ((subsetCubeEquiv A).symm (y,z)))) := by
  have h := cubeMean_subset_product A
    (fun y z => f ((subsetCubeEquiv A).symm (y,z)))
  have he (x : Cube d) : (subsetCubeEquiv A).symm (subsetInputs Aᶜ x,subsetInputs A x) = x :=
    (subsetCubeEquiv A).symm_apply_apply x
  simpa only [he] using h

/-- The character on the remaining selected coordinates, after holding all
coordinates in `A` at the sign identity. -/
def outsideWalsh {d : ℕ} (A B : Finset (Fin d)) (y : Cube Aᶜ.card) : ℝ :=
  walshCharacter (B\A) ((subsetCubeEquiv A).symm (y,fun _ => true))

theorem outsideWalsh_abs_one {d : ℕ} (A B : Finset (Fin d)) (y : Cube Aᶜ.card) :
    |outsideWalsh A B y| = 1 := by
  have hs := walshCharacter_sq (B\A) ((subsetCubeEquiv A).symm (y,fun _ => true))
  change outsideWalsh A B y ^ 2 = 1 at hs
  nlinarith [sq_abs (outsideWalsh A B y),abs_nonneg (outsideWalsh A B y)]

theorem walshCharacter_join {d : ℕ} (A B : Finset (Fin d)) (hAB : A ⊆ B)
    (y : Cube Aᶜ.card) (z : Cube A.card) :
    walshCharacter B ((subsetCubeEquiv A).symm (y,z)) =
      paritySign z * outsideWalsh A B y := by
  classical
  have hsplit (x : Cube d) : walshCharacter B x = walshCharacter A x * walshCharacter (B\A) x := by
    unfold walshCharacter
    have hd : Disjoint A (B\A) := Finset.disjoint_left.mpr (fun i hi hj =>
      (Finset.mem_sdiff.mp hj).2 hi)
    rw [← Finset.prod_union hd, Finset.union_sdiff_of_subset hAB]
  rw [hsplit]
  have hsel : walshCharacter A ((subsetCubeEquiv A).symm (y,z)) = paritySign z := by
    rw [← paritySign_subsetInputs, subsetInputs_join_selected]
  rw [hsel]
  congr 1
  unfold walshCharacter outsideWalsh
  apply Finset.prod_congr rfl
  intro i hi
  have hnot : i ∉ A := (Finset.mem_sdiff.mp hi).2
  simp [subsetCubeEquiv,hnot]

/-- Conditioning on all unchosen coordinates leaves a literal smaller
parity problem, with its sign multiplied by a unit-modulus outside character. -/
theorem tanh_walshCoefficient_partial_formula {d : ℕ}
    (A B : Finset (Fin d)) (hAB : A ⊆ B) (u : Fin d → ℝ) (b : ℝ) :
    walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) B =
      cubeMean (fun y => outsideWalsh A B y * ridgeParity Real.tanh (subsetWeights A u)
        (b+incomingLinear (subsetWeights Aᶜ u) y)) := by
  change OnlineLowerRelu.finiteAverage _ = _
  rw [← cubeMean_eq_finiteAverage, cubeMean_join A]
  apply cubeMean_congr
  intro y
  unfold ridgeParity
  rw [← cubeMean_const_mul]
  apply cubeMean_congr
  intro z
  dsimp only
  rw [incomingLinear_join,walshCharacter_join A B hAB]
  have he : b+(incomingLinear (subsetWeights A u) z+incomingLinear (subsetWeights Aᶜ u) y) =
      (b+incomingLinear (subsetWeights Aᶜ u) y)+incomingLinear (subsetWeights A u) z := by ring
  rw [he]
  ring

/-- Every chosen subset of a parity support contributes a factor of its
incoming coordinate magnitude, independent of all the other weights and bias. -/
theorem tanh_walshCoefficient_partial_bound {d : ℕ}
    (A B : Finset (Fin d)) (hAB : A ⊆ B) (u : Fin d → ℝ) (b : ℝ) :
    |walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) B| ≤
      (A.card.factorial : ℝ) * ∏ i ∈ A, |u i| := by
  rw [tanh_walshCoefficient_partial_formula A B hAB]
  apply (abs_cubeMean_le _).trans
  have hp : (∏ i, |subsetWeights A u i|) = ∏ i ∈ A, |u i| :=
    subset_prod_reindex A (fun i => |u i|)
  have h := cubeMean_mono
    (fun y => |outsideWalsh A B y * ridgeParity Real.tanh (subsetWeights A u)
      (b+incomingLinear (subsetWeights Aᶜ u) y)|)
    (fun _ : Cube Aᶜ.card => (A.card.factorial : ℝ)*∏ i ∈ A, |u i|)
    (fun y => by
      rw [abs_mul, outsideWalsh_abs_one, one_mul]
      simpa only [hp] using tanh_ridgeParity_abs_le_factorial_product (subsetWeights A u)
        (b+incomingLinear (subsetWeights Aᶜ u) y))
  simpa only [cubeMean_const] using h

end NeuralGeneralization.OnlineLowerTanh
