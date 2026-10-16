import NeuralGeneralization.NetworkCylinderIndex
import NeuralGeneralization.NetworkGaussianCylinder

/-!
# Probability of the actual free network coordinates

The unconstrained internal coordinates are identified with one stacked
rectangular Gaussian matrix. One norm event controls every layer and has
probability at least one half, including when there are no internal layers.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.ConcreteModel
variable {d N r : ℕ}

/-- The free coordinates reshaped into their actual internal row and column indices. -/
def freeCoordinateMatrix (J : Finset (Fin N))
    (z : {q : WeightIndex d N r // ¬constrainedIndex J q} → ℝ) :
    (Fin r × Fin N) × {j : Fin N // j ∉ J} → ℝ :=
  fun q => z ((freeIndexEquiv J).symm q)

/-- Simultaneous bound on all free internal directions. -/
def freeCoordinateEvent (J : Finset (Fin N)) (B : ℝ) :
    Set ({q : WeightIndex d N r // ¬constrainedIndex J q} → ℝ) :=
  {z | ‖coordinateMatrixOperator (freeCoordinateMatrix J z)‖ ≤ B}

theorem freeCoordinateEvent_mass (J : Finset (Fin N)) (B : ℝ) (v : ℝ≥0) :
    (Measure.pi fun _ : {q : WeightIndex d N r // ¬constrainedIndex J q} =>
      gaussianReal 0 v) (freeCoordinateEvent J B) =
    (Measure.pi fun _ : (Fin r × Fin N) × {j : Fin N // j ∉ J} =>
      gaussianReal 0 v) {z | ‖coordinateMatrixOperator z‖ ≤ B} := by
  let e := MeasurableEquiv.piCongrLeft
    (fun _ : (Fin r × Fin N) × {j : Fin N // j ∉ J} => ℝ)
    (freeIndexEquiv (d := d) J)
  change (Measure.pi fun _ : {q : WeightIndex d N r // ¬constrainedIndex J q} =>
    gaussianReal 0 v) (e ⁻¹' {z | ‖coordinateMatrixOperator z‖ ≤ B}) = _
  rw [← e.map_apply,
    (measurePreserving_piCongrLeft
      (fun _ : (Fin r × Fin N) × {j : Fin N // j ∉ J} => gaussianReal 0 v)
      (freeIndexEquiv (d := d) J)).map_eq]

/-- At or above mean-field scaling the free-direction event has a fixed
positive probability, uniformly in all widths. -/
theorem freeCoordinateEvent_real_ge_half (hN : 0 < N)
    (J : Finset (Fin N)) {σ : ℝ} (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) :
    (1:ℝ)/2 ≤
      (Measure.pi fun _ : {q : WeightIndex d N r // ¬constrainedIndex J q} =>
        gaussianReal 0 (σ^2).toNNReal).real
        (freeCoordinateEvent J (16*((r:ℝ)+1))) := by
  have hM : 1 ≤ (r+1)*N := Nat.mul_pos (Nat.succ_pos r) hN
  have hcard : Fintype.card (Fin r × Fin N) + Fintype.card {j : Fin N // j ∉ J} ≤
      ((r+1)*N)+((r+1)*N) := by
    have hc := Fintype.card_subtype_le (fun j : Fin N => j ∉ J)
    simp only [Fintype.card_prod, Fintype.card_fin] at hc ⊢
    simp only [Nat.add_mul, Nat.one_mul]
    omega
  have hv : 0 < ((σ^2).toNNReal : ℝ) := by
    rw [Real.coe_toNNReal _ (sq_nonneg σ)]
    exact sq_pos_of_pos hσ
  have hm := GaussianTail.gaussian_matrix_good_mass_at_scale
    (m := Fin r × Fin N) (n := {j : Fin N // j ∉ J}) ((r+1)*N) hM hcard
    (σ^2).toNNReal hv
  have hsqrt : Real.sqrt (((r+1)*N:ℕ) * ((σ^2).toNNReal:ℝ)) ≤ (r:ℝ)+1 := by
    apply (Real.sqrt_le_iff).mpr
    constructor
    · positivity
    · rw [Real.coe_toNNReal _ (sq_nonneg σ)]
      push_cast
      have hs := mul_le_mul_of_nonneg_left hscale (by positivity : 0 ≤ (r:ℝ)+1)
      have hr : (0:ℝ) ≤ r := Nat.cast_nonneg r
      nlinarith
  unfold Measure.real
  rw [freeCoordinateEvent_mass]
  apply hm.trans
  apply measureReal_mono _ (measure_ne_top _ _)
  intro z hz
  exact hz.trans (mul_le_mul_of_nonneg_left hsqrt (by norm_num))

end NeuralGeneralization.ConcreteModel
