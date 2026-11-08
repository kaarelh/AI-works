import NeuralGeneralization.OnlineLowerTanhConditionalSupport
import NeuralGeneralization.OnlineLowerReluUniformMarginal
import NeuralGeneralization.KernelEnergy

/-!
# Literal physical-subset support stability for tanh atoms

This module reindexes an arbitrary selected set of physical Boolean inputs
into two independent cubes. It identifies the actual Walsh coefficient and
all incoming squared norms with the previously checked conditional-parity
support theorem. The intrinsic sharp parity bound remains a named input here;
the global single-parity theorem is responsible for discharging it.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

/-- Selected incoming coordinates in the canonical finite-set order. -/
def subsetWeights {d : ℕ} (A : Finset (Fin d)) (u : Fin d → ℝ) : Fin A.card → ℝ :=
  fun i => u ((A.equivFin.symm i).val)

/-- The corresponding selected input cube. -/
def subsetInputs {d : ℕ} (A : Finset (Fin d)) (x : Cube d) : Cube A.card :=
  fun i => x ((A.equivFin.symm i).val)

/-- Exact product decomposition, with the outside cube first so its average
is the outer conditional expectation. -/
def subsetCubeEquiv {d : ℕ} (A : Finset (Fin d)) :
    Cube d ≃ Cube Aᶜ.card × Cube A.card where
  toFun x := (subsetInputs Aᶜ x, subsetInputs A x)
  invFun y i := if h : i ∈ A then y.2 (A.equivFin ⟨i,h⟩)
    else y.1 (Aᶜ.equivFin ⟨i,Finset.mem_compl.mpr h⟩)
  left_inv x := by
    funext i
    dsimp [subsetInputs]
    split_ifs <;> simp
  right_inv y := by
    apply Prod.ext
    · funext i
      have hi : (Aᶜ.equivFin.symm i).val ∉ A :=
        Finset.mem_compl.mp (Aᶜ.equivFin.symm i).property
      simp [subsetInputs,hi]
    · funext i
      have hi : (A.equivFin.symm i).val ∈ A := (A.equivFin.symm i).property
      simp [subsetInputs,hi]

/-- Canonical finite-set reindexing preserves a sum. -/
theorem subset_sum_reindex {d : ℕ} (A : Finset (Fin d)) (f : Fin d → ℝ) :
    (∑ i : Fin A.card, f (A.equivFin.symm i).val) = ∑ i ∈ A, f i := by
  rw [A.equivFin.symm.sum_comp (fun i : A => f i.val)]
  exact (Finset.sum_subtype A (fun _ => Iff.rfl) f).symm

/-- Canonical finite-set reindexing preserves a product. -/
theorem subset_prod_reindex {d : ℕ} (A : Finset (Fin d)) (f : Fin d → ℝ) :
    (∏ i : Fin A.card, f (A.equivFin.symm i).val) = ∏ i ∈ A, f i := by
  rw [A.equivFin.symm.prod_comp (fun i : A => f i.val)]
  exact (Finset.prod_subtype A (fun _ => Iff.rfl) f).symm

theorem incomingEnergy_subsetWeights {d : ℕ} (A : Finset (Fin d)) (u : Fin d → ℝ) :
    incomingEnergy (subsetWeights A u) = ∑ i ∈ A, u i^2 :=
  subset_sum_reindex A (fun i => u i^2)

theorem incomingEnergy_partition {d : ℕ} (A : Finset (Fin d)) (u : Fin d → ℝ) :
    incomingEnergy (subsetWeights A u) + incomingEnergy (subsetWeights Aᶜ u) =
      incomingEnergy u := by
  rw [incomingEnergy_subsetWeights, incomingEnergy_subsetWeights]
  exact Finset.sum_add_sum_compl A (fun i => u i^2)

theorem incomingLinear_partition {d : ℕ} (A : Finset (Fin d))
    (u : Fin d → ℝ) (x : Cube d) :
    incomingLinear (subsetWeights A u) (subsetInputs A x) +
        incomingLinear (subsetWeights Aᶜ u) (subsetInputs Aᶜ x) = incomingLinear u x := by
  unfold incomingLinear subsetWeights subsetInputs
  rw [subset_sum_reindex A (fun i => u i * labelReal (x i)),
    subset_sum_reindex Aᶜ (fun i => u i * labelReal (x i))]
  exact Finset.sum_add_sum_compl A (fun i => u i * labelReal (x i))

theorem paritySign_subsetInputs {d : ℕ} (A : Finset (Fin d)) (x : Cube d) :
    paritySign (subsetInputs A x) = walshCharacter A x := by
  unfold paritySign subsetInputs walshCharacter
  rw [subset_prod_reindex A (fun i => labelReal (x i))]
  rfl

/-- The normalizations used by the analytic and Fourier modules agree. -/
theorem cubeMean_eq_finiteAverage {d : ℕ} (f : Cube d → ℝ) :
    cubeMean f = OnlineLowerRelu.finiteAverage f := by
  simp [cubeMean, OnlineLowerRelu.finiteAverage, Cube, div_eq_mul_inv, mul_comm]

theorem cubeMean_subset_product {d : ℕ} (A : Finset (Fin d))
    (f : Cube Aᶜ.card → Cube A.card → ℝ) :
    cubeMean (fun x => f (subsetInputs Aᶜ x) (subsetInputs A x)) =
      cubeMean (fun y => cubeMean (f y)) := by
  rw [cubeMean_eq_finiteAverage]
  have he := OnlineLowerRelu.finiteAverage_equiv (subsetCubeEquiv A)
    (fun y => f y.1 y.2)
  change OnlineLowerRelu.finiteAverage (fun x =>
      f (subsetInputs Aᶜ x) (subsetInputs A x)) = _ at he
  rw [he]
  simp only [OnlineLowerRelu.finiteAverage, cubeMean, Fintype.sum_prod_type,
    Fintype.card_prod, Nat.cast_mul, Cube, Fintype.card_fun, Fintype.card_fin,
    Fintype.card_bool, Nat.cast_pow, Nat.cast_ofNat]
  simp only [← Finset.mul_sum]
  ring

/-- An actual arbitrary-support Walsh coefficient is precisely the nested
coefficient on the selected and outside cubes. -/
theorem tanh_walshCoefficient_eq_conditioned {d : ℕ}
    (A : Finset (Fin d)) (u : Fin d → ℝ) (b : ℝ) :
    walshCoefficients (fun x => Real.tanh (b + incomingLinear u x)) A =
      conditionedParityCorrelation (subsetWeights A u) (subsetWeights Aᶜ u) b := by
  have hpoint (x : Cube d) :
      Real.tanh (b + incomingLinear u x) * walshCharacter A x =
        paritySign (subsetInputs A x) * Real.tanh
          ((b + incomingLinear (subsetWeights Aᶜ u) (subsetInputs Aᶜ x)) +
            incomingLinear (subsetWeights A u) (subsetInputs A x)) := by
    rw [paritySign_subsetInputs, ← incomingLinear_partition A u x]
    rw [mul_comm]
    congr 1
    congr 1
    ring
  change OnlineLowerRelu.finiteAverage _ = _
  rw [← cubeMean_eq_finiteAverage]
  simp_rw [hpoint]
  rw [cubeMean_subset_product A (fun y z => paritySign z * Real.tanh
    ((b + incomingLinear (subsetWeights Aᶜ u) y) + incomingLinear (subsetWeights A u) z))]
  unfold conditionedParityCorrelation
  apply cubeMean_congr
  intro y
  simp [cubeMean, parityCorrelation, Cube]

/-- Exact physical form of the affine support estimate. The incoming norm
includes every physical coordinate and the bias; the coefficient is the
literal Walsh coefficient of the tanh neuron. -/
theorem intrinsicParityBound_physical_support {d : ℕ}
    (A : Finset (Fin d)) (hA : Odd A.card) (w : ℝ) (hw : 0 ≤ w)
    (hsharp : IntrinsicParityBound A.card w) (u : Fin d → ℝ) (b : ℝ) :
    let r := Real.sqrt (b^2 + incomingEnergy u)
    let q := w * |walshCoefficients (fun x => Real.tanh (b + incomingLinear u x)) A|
    q ≤ r ∧ b^2 + (∑ i ∈ Aᶜ, u i^2) ≤ max 2 (288*w^2) * r * (r-q) := by
  have h := intrinsicParityBound_conditioned_support hA w hw hsharp
    (subsetWeights A u) (subsetWeights Aᶜ u) b
  dsimp only at h ⊢
  rw [← tanh_walshCoefficient_eq_conditioned] at h
  have hnorm : incomingEnergy (subsetWeights A u) +
      (b^2 + incomingEnergy (subsetWeights Aᶜ u)) = b^2 + incomingEnergy u := by
    rw [← incomingEnergy_partition A u]
    ring
  rw [hnorm, incomingEnergy_subsetWeights] at h
  exact h

end NeuralGeneralization.OnlineLowerTanh
