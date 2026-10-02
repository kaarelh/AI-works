import Mathlib.Analysis.Normed.Module.FiniteDimension
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.Calculus.LocalExtr.Basic
import Mathlib.Topology.Order.Compact
import Mathlib.Tactic

/-!
# Direct coercivity of a finite exponential sum

On any linear subspace of zero-sum vectors, a sublevel of a positive
weighted exponential sum is compact: every coordinate is bounded above
by its exponential term, and the zero-sum identity bounds it below.
This supplies the Cauchy--Binet minimization used for radial scaling,
without entropy minimization or a theorem about frame scaling.
-/

namespace Paulsen

open scoped BigOperators

noncomputable section

def positiveExponentialSum {ι : Type*} [Fintype ι]
    (μ : ι → ℝ) (y : ι → ℝ) : ℝ := ∑ i, μ i * Real.exp (y i)

theorem positiveExponentialSum_continuous {ι : Type*} [Fintype ι]
    (μ : ι → ℝ) : Continuous (positiveExponentialSum μ) := by
  unfold positiveExponentialSum
  fun_prop

/-- Coercivity in tuple coordinates gives a minimum on every zero-sum
linear subspace, including subspaces of dimension zero. -/
theorem exists_min_positiveExponentialSum {ι : Type*} [Fintype ι]
    (μ : ι → ℝ) (hμ : ∀ i, 0 < μ i)
    (V : Submodule ℝ (ι → ℝ))
    (hV : ∀ y ∈ V, (∑ i, y i) = 0) :
    ∃ y ∈ V, ∀ z ∈ V, positiveExponentialSum μ y ≤ positiveExponentialSum μ z := by
  classical
  let P := positiveExponentialSum μ
  let C : ℝ := ∑ i, |Real.log (P 0 / μ i)|
  let K : Set (ι → ℝ) := {y | y ∈ V ∧ P y ≤ P 0}
  have hC : 0 ≤ C := Finset.sum_nonneg (fun i _ => abs_nonneg _)
  have hupper (y : ι → ℝ) (hy : y ∈ K) (i : ι) : y i ≤ C := by
    have hterm : μ i * Real.exp (y i) ≤ P y :=
      Finset.single_le_sum (fun j _ => mul_nonneg (hμ j).le (Real.exp_pos _).le)
        (Finset.mem_univ i)
    have hexp : Real.exp (y i) ≤ P 0 / μ i :=
      (le_div_iff₀ (hμ i)).mpr (by simpa [mul_comm] using hterm.trans hy.2)
    have hlog : y i ≤ Real.log (P 0 / μ i) :=
      (Real.le_log_iff_exp_le ((Real.exp_pos _).trans_le hexp)).mpr hexp
    have habs : |Real.log (P 0 / μ i)| ≤ C := by
      dsimp [C]
      exact Finset.single_le_sum (fun j _ => abs_nonneg (Real.log (P 0 / μ j)))
        (Finset.mem_univ i)
    exact hlog.trans ((le_abs_self _).trans habs)
  have hclosed : IsClosed K :=
    V.closed_of_finiteDimensional.inter
      (isClosed_le (positiveExponentialSum_continuous μ) continuous_const)
  have hcompact : IsCompact K := by
    apply isCompact_Icc.of_isClosed_subset hclosed
    intro y hy
    constructor
    · intro i
      have hsum : (∑ j ∈ Finset.univ.erase i, y j) + y i = 0 := by
        rw [Finset.sum_erase_add _ _ (Finset.mem_univ i)]
        exact hV y hy.1
      have hbound : (∑ j ∈ Finset.univ.erase i, y j) ≤ (Fintype.card ι : ℝ) * C := by
        calc
          (∑ j ∈ Finset.univ.erase i, y j) ≤ ∑ j ∈ Finset.univ.erase i, C :=
            Finset.sum_le_sum (fun j _ => hupper y hy j)
          _ ≤ ∑ _j : ι, C :=
            Finset.sum_le_sum_of_subset_of_nonneg (Finset.erase_subset _ _)
              (fun j _ _ => hC)
          _ = _ := by simp
      change -(Fintype.card ι : ℝ) * C ≤ y i
      linarith
    · intro i
      exact hupper y hy i
  obtain ⟨y, hy, hmin⟩ := hcompact.exists_isMinOn
    (show K.Nonempty from ⟨0, V.zero_mem, le_rfl⟩)
    (positiveExponentialSum_continuous μ).continuousOn
  refine ⟨y, hy.1, ?_⟩
  intro z hz
  by_cases hp : P z ≤ P 0
  · exact hmin ⟨hz, hp⟩
  · exact hy.2.trans (le_of_not_ge hp)

/-- The derivative of the finite exponential sum along a line. -/
theorem positiveExponentialSum_hasDerivAt_line {ι : Type*} [Fintype ι]
    (μ y v : ι → ℝ) :
    HasDerivAt (fun t : ℝ => positiveExponentialSum μ (y + t • v))
      (∑ i, μ i * Real.exp (y i) * v i) 0 := by
  unfold positiveExponentialSum
  apply HasDerivAt.fun_sum
  intro i _
  have hline : HasDerivAt (fun t : ℝ => y i + t * v i) (v i) 0 := by
    simpa using ((hasDerivAt_id (0 : ℝ)).mul_const (v i)).const_add (y i)
  simpa [mul_assoc] using hline.exp.const_mul (μ i)

end
end Paulsen
