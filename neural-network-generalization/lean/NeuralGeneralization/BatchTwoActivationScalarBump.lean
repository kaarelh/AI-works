import Mathlib.Analysis.Calculus.BumpFunction.InnerProduct
import Mathlib.Analysis.Calculus.ContDiff.Deriv
import Mathlib.Analysis.Calculus.Deriv.Support
import Mathlib.Analysis.Normed.Group.Bounded

/-! A fixed compactly supported scalar cutoff with universal derivative bounds. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoActivation

def scalarCutoff : ContDiffBump (0:ℝ) := ⟨2,4,by norm_num,by norm_num⟩

theorem scalarCutoff_contDiff : ContDiff ℝ (3:ℕ) scalarCutoff := scalarCutoff.contDiff

theorem scalarCutoff_deriv_contDiff : ContDiff ℝ (2:ℕ) (deriv scalarCutoff) :=
  scalarCutoff_contDiff.deriv'

theorem scalarCutoff_second_contDiff : ContDiff ℝ (1:ℕ) (deriv (deriv scalarCutoff)) :=
  scalarCutoff_deriv_contDiff.deriv'

theorem scalarCutoff_hasDerivAt (t : ℝ) :
    HasDerivAt scalarCutoff (deriv scalarCutoff t) t :=
  (scalarCutoff_contDiff.differentiable (by norm_num)).differentiableAt.hasDerivAt

theorem scalarCutoff_first_hasDerivAt (t : ℝ) :
    HasDerivAt (deriv scalarCutoff) (deriv (deriv scalarCutoff) t) t :=
  (scalarCutoff_deriv_contDiff.differentiable (by norm_num)).differentiableAt.hasDerivAt

theorem scalarCutoff_eq_one {t : ℝ} (ht : |t|≤2) : scalarCutoff t=1 := by
  apply scalarCutoff.one_of_mem_closedBall
  simpa [Metric.mem_closedBall,Real.dist_eq,scalarCutoff] using ht

theorem scalarCutoff_eq_zero {t : ℝ} (ht : 4≤|t|) : scalarCutoff t=0 := by
  have hnot : t∉Function.support (scalarCutoff : ℝ→ℝ) := by
    rw [scalarCutoff.support_eq]
    simpa [Metric.mem_ball,Real.dist_eq,scalarCutoff] using not_lt_of_ge ht
  exact Function.notMem_support.mp hnot

theorem scalarCutoff_deriv_eq_zero {t : ℝ} (ht : 4 < |t|) : deriv scalarCutoff t=0 := by
  apply deriv_of_notMem_tsupport
  rw [scalarCutoff.tsupport_eq]
  simpa [Metric.mem_closedBall,Real.dist_eq,scalarCutoff] using not_le_of_gt ht

theorem scalarCutoff_second_eq_zero {t : ℝ} (ht : 4 < |t|) : deriv (deriv scalarCutoff) t=0 := by
  apply deriv_of_notMem_tsupport
  intro h
  have hh := tsupport_deriv_subset h
  rw [scalarCutoff.tsupport_eq] at hh
  have : |t|≤4 := by simpa [Metric.mem_closedBall,Real.dist_eq,scalarCutoff] using hh
  exact (not_le_of_gt ht) this

/-- The constant is independent of dimension, scale, and activation. -/
theorem scalarCutoff_uniform_bounds : ∃B:ℝ, 1≤B ∧
    (∀t, |deriv scalarCutoff t|≤B) ∧ (∀t, |deriv (deriv scalarCutoff) t|≤B) := by
  obtain ⟨B₁,h₁⟩ := scalarCutoff.hasCompactSupport.deriv.exists_bound_of_continuous
    scalarCutoff_deriv_contDiff.continuous
  obtain ⟨B₂,h₂⟩ := scalarCutoff.hasCompactSupport.deriv.deriv.exists_bound_of_continuous
    scalarCutoff_second_contDiff.continuous
  refine ⟨1+|B₁|+|B₂|,by linarith [abs_nonneg B₁,abs_nonneg B₂],?_,?_⟩
  · intro t
    have h := h₁ t
    rw [Real.norm_eq_abs] at h
    exact h.trans (by linarith [le_abs_self B₁,abs_nonneg B₂])
  · intro t
    have h := h₂ t
    rw [Real.norm_eq_abs] at h
    exact h.trans (by linarith [le_abs_self B₂,abs_nonneg B₁])

end NeuralGeneralization.BatchTwoActivation
