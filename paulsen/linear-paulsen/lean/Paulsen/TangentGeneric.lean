import Paulsen.FullSparkDensity
import Paulsen.TangentSeed

/-!
# Generic tangent seeds by varying one scalar

For full-spark input, any fixed tangent perturbation gives full-spark seeds
outside a finite set of amplitudes. Thus strict good-event inequalities can
be retained while choosing a generic seed, without multivariate zero-set
measure theory.
-/

namespace Paulsen

open Filter
open scoped Topology

theorem IsFullSpark.smul {n d : ℕ} {X : Frame n d} (hX : IsFullSpark X)
    (s : ℝ) (hs : s ≠ 0) : IsFullSpark (s • X) := by
  intro f
  change (s • (X.submatrix f id)).det ≠ 0
  rw [Matrix.det_smul]
  exact mul_ne_zero (pow_ne_zero _ hs) (hX f)

/-- The nonsingular coefficient may be the constant term of the pencil. -/
theorem eventually_fullSpark_pencil_of_constant {n d : ℕ}
    (X Z : Frame n d) (hX : IsFullSpark X) :
    ∀ᶠ t : ℝ in cofinite, IsFullSpark (X + t • Z) := by
  have hi : Tendsto (fun t : ℝ => t⁻¹) cofinite cofinite :=
    (inv_injective : Function.Injective (fun t : ℝ => t⁻¹)).tendsto_cofinite
  filter_upwards [hi.eventually (eventually_fullSpark_pencil Z X hX),
    eventually_cofinite_ne (0 : ℝ)] with t ht ht0
  have heq : X + t • Z = t • (Z + t⁻¹ • X) := by
    rw [smul_add, smul_smul, mul_inv_cancel₀ ht0, one_smul, add_comm]
  rw [heq]
  exact ht.smul t ht0

theorem tangentSeed_fullSpark_of_pencil {n d : ℕ}
    (X Z : Frame n d) (a t : ℝ) (ha : 0 < a)
    (hX : IsFullSpark (X + t • Z)) : IsFullSpark (tangentSeed X Z a t) := by
  have h := hX.diagonal_mul
    (fun i => (Real.sqrt (1 + t ^ 2 * tangentRatio a Z i))⁻¹)
    (fun i => inv_ne_zero (ne_of_gt (Real.sqrt_pos.mpr (tangent_denominator_pos a t ha Z i))))
  convert h using 1
  ext i j
  simp only [tangentSeed, Matrix.of_apply, Matrix.diagonal_mul,
    Matrix.add_apply, Matrix.smul_apply, smul_eq_mul]
  ring

/-- Only finitely many amplitudes can destroy full spark. -/
theorem eventually_fullSpark_tangentSeed {n d : ℕ}
    (X Z : Frame n d) (a : ℝ) (ha : 0 < a) (hX : IsFullSpark X) :
    ∀ᶠ t : ℝ in cofinite, IsFullSpark (tangentSeed X Z a t) := by
  filter_upwards [eventually_fullSpark_pencil_of_constant X Z hX] with t ht
  exact tangentSeed_fullSpark_of_pencil X Z a t ha ht

theorem continuous_tangentSeed_parameter {n d : ℕ}
    (X Z : Frame n d) (a : ℝ) (ha : 0 < a) :
    Continuous (fun t : ℝ => tangentSeed X Z a t) := by
  apply continuous_pi
  intro i
  apply continuous_pi
  intro j
  change Continuous (fun t : ℝ => (X i j + t * Z i j) /
    Real.sqrt (1 + t ^ 2 * tangentRatio a Z i))
  apply Continuous.div
  · fun_prop
  · fun_prop
  · intro t
    exact ne_of_gt (Real.sqrt_pos.mpr (tangent_denominator_pos a t ha Z i))

/-- Every open collection of good seed properties can be retained while
making the seed full spark by an arbitrarily small change of amplitude. -/
theorem exists_fullSpark_tangentSeed_in_open {n d : ℕ}
    (X Z : Frame n d) (a t₀ : ℝ) (ha : 0 < a) (hX : IsFullSpark X)
    (S : Set (Frame n d)) (hS : IsOpen S) (hmem : tangentSeed X Z a t₀ ∈ S) :
    ∃ t : ℝ, IsFullSpark (tangentSeed X Z a t) ∧ tangentSeed X Z a t ∈ S := by
  have hnear : ∀ᶠ t : ℝ in 𝓝[≠] t₀, tangentSeed X Z a t ∈ S :=
    ((continuous_tangentSeed_parameter X Z a ha).tendsto t₀).mono_left
      nhdsWithin_le_nhds |>.eventually (hS.mem_nhds hmem)
  have hgood := (eventually_fullSpark_tangentSeed X Z a ha hX).filter_mono
    (nhdsNE_le_cofinite t₀)
  exact (hgood.and hnear).exists

end Paulsen
