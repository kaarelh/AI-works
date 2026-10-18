import NeuralGeneralization.RobustCompressionTerminalReadout
import NeuralGeneralization.RobustCompressionInductionRows
import NeuralGeneralization.RobustEntropyFeatureNormalization

/-! # The actual canonical prefix supplies bounded active queries -/
noncomputable section
open MeasureTheory
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel

def prefixQueries {d N m s : ℕ} (φ : ℝ → ℝ) (p : ActivePrefix d N m s)
    (x : Cube d) : EuclideanSpace ℝ (Fin N) :=
  WithLp.toLp 2 (fun i => activeHidden φ p x i / Real.sqrt (N : ℝ))

theorem measurable_prefixQueries {d N m s : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ)
    (x : Cube d) : Measurable (fun p : ActivePrefix d N m s => prefixQueries φ p x) := by
  apply (WithLp.measurable_toLp 2 (Fin N → ℝ)).comp
  apply measurable_pi_lambda
  intro i
  exact ((measurable_pi_apply i).comp (measurable_activeHidden hφ x)).div_const _

theorem measurable_prefixQueriesFamily {d N m s : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) : Measurable (prefixQueries (d:=d) (N:=N) (m:=m) (s:=s) φ) :=
  measurable_pi_lambda _ (fun x => measurable_prefixQueries hφ x)

def indexedPrefixQueries {d N m s : ℕ} (φ : ℝ → ℝ) (p : ActivePrefix d N m s)
    (i : Fin (Fintype.card (Cube d))) : EuclideanSpace ℝ (Fin N) :=
  prefixQueries φ p ((Fintype.equivFin (Cube d)).symm i)

theorem measurable_indexedPrefixQueries {d N m s : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) :
    Measurable (indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) φ) :=
  measurable_pi_lambda _ (fun i => measurable_prefixQueries hφ _)

theorem prefixQueries_norm_le {d N m s : ℕ} (hN : 0 < N) (φ : ℝ → ℝ)
    (hφ : ∀ z,|φ z|≤1) (p : ActivePrefix d N m s) (x : Cube d) :
    ‖prefixQueries φ p x‖ ≤ 1 := by
  have hNR : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  have hs : ‖prefixQueries φ p x‖^2 ≤ 1 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    simp only [prefixQueries,div_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
    rw [← Finset.sum_div]
    apply (div_le_iff₀ hNR).mpr
    calc
      ∑ i,activeHidden φ p x i ^2 ≤ ∑ _i : Fin N,(1 : ℝ) := by
        apply Finset.sum_le_sum
        intro i hi
        have hb := activeHidden_bounded φ hφ p x i
        nlinarith [sq_abs (activeHidden φ p x i),abs_nonneg (activeHidden φ p x i)]
      _ = _ := by simp
  nlinarith [norm_nonneg (prefixQueries φ p x)]

theorem prefixQueries_eq_normalizedFeature {d N m s : ℕ} (φ : ℝ → ℝ)
    (p : ActivePrefix d N m s) (x : Cube d) :
    prefixQueries φ p x = RobustGaussianGeometry.normalizedFeature (activeHidden φ p x) := rfl

/-- The active-query scalar is the actual original layer preactivation,
with t = sigma sqrt(N), including the manuscript's width normalization. -/
theorem prefixQueries_actual_preactivation {d N m s : ℕ} (hN : 0 < N)
    (φ : ℝ → ℝ) (p : ActivePrefix d N m s) (x : Cube d)
    (z : InternalBlock N) (i : Fin N) (σ : ℝ) :
    (σ*Real.sqrt (N : ℝ))*⟪prefixQueries φ p x,internalRows N z i⟫ =
      ∑ j, (σ*z (i,j))*activeHidden φ p x j := by
  have hs : Real.sqrt (N : ℝ) ≠ 0 := (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN)).ne'
  simp only [prefixQueries,internalRows,EuclideanSpace.inner_eq_star_dotProduct,
    dotProduct,star_trivial,Pi.star_apply]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  change (σ*Real.sqrt (N:ℝ))*(z (i,j)*(activeHidden φ p x j/Real.sqrt (N:ℝ))) = _
  field_simp
  <;> ring

end NeuralGeneralization.RobustCompressionInduction
