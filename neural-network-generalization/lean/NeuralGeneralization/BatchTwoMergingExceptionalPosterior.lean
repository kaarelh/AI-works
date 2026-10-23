import NeuralGeneralization.BatchTwoMergingPosterior
import NeuralGeneralization.BatchTwoMergingCompressedTail

/-! # Both truncations are negligible under the actual conditional prior -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

def partitionEntropyBudget (d r Q : ℕ) : ℝ :=
  2*(r+1)*Real.log (Q : ℝ) + (d+2+r*Q)/2*Real.log 2

theorem partitionEntropyBudget_nonneg (d r : ℕ) {Q : ℕ} (hQ : 0 < Q) :
    0 ≤ partitionEntropyBudget d r Q := by
  have hlog : 0 ≤ Real.log (Q : ℝ) := Real.log_nonneg (by exact_mod_cast hQ)
  have hlog2 : 0 ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  unfold partitionEntropyBudget
  positivity

theorem smallPrior_exceptionalPartitions_scaled_tail {d N r Q : ℕ}
    (hd : 0 < d) (hN : 0 < N) (hQ : 0 < Q) {σ : ℝ} (hσ : 0 < σ)
    (hscale : (N : ℝ)*σ^2 ≤ 1) (J : ℝ) :
    (smallPrior d N r σ).real (exceptionalPartitions (Q := Q) J) ≤
      Real.exp (-(J-4*partitionEntropyBudget d r Q)/(4*σ^2)) := by
  apply (smallPrior_exceptionalPartitions_tail hd hN hQ hσ J).trans
  apply Real.exp_le_exp.mpr
  have hs := sq_pos_of_pos hσ
  have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hlog : 0 ≤ Real.log (Q : ℝ) := Real.log_nonneg (by exact_mod_cast hQ)
  have he := partitionEntropyBudget_nonneg d r hQ
  have hcount : (((r+1)*(N+1) : ℕ) : ℝ)*Real.log (Q : ℝ) ≤
      (N : ℝ)*(2*(r+1)*Real.log (Q : ℝ)) := by
    push_cast
    have h := mul_nonneg (show 0 ≤ (r+1 : ℝ) by positivity) hlog
    nlinarith
  have hscaled : (N : ℝ)*partitionEntropyBudget d r Q ≤
      partitionEntropyBudget d r Q/σ^2 := by
    apply (le_div_iff₀ hs).mpr
    have hh := mul_le_mul_of_nonneg_right hscale he
    nlinarith
  have hmid : (((r+1)*(N+1) : ℕ) : ℝ)*Real.log (Q : ℝ) +
      (N : ℝ)/2*(d+2+r*Q : ℕ)*Real.log 2 ≤
        partitionEntropyBudget d r Q/σ^2 := by
    apply le_trans _ hscaled
    unfold partitionEntropyBudget
    push_cast at hcount ⊢
    nlinarith
  calc
    _ ≤ partitionEntropyBudget d r Q/σ^2-J/(4*σ^2) := by linarith
    _ = _ := by ring

theorem posterior_exceptionalPartitions_tail {d N r n Q : ℕ}
    (hd : 0 < d) (hN : 0 < N) (hQ : 0 < Q)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (globalMargin : Bool)
    {σ : ℝ} (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1)
    (f : BooleanFunction d) (sample : Fin n → Cube d) {D J β : ℝ}
    (hβ : 0 < β) (hβ1 : β ≤ 1)
    (hbudget : 4*(D+partitionEntropyBudget d r Q-Real.log β) ≤ J)
    (htarget : Real.exp (-D/σ^2) ≤ (smallPrior d N r σ).real
      (mergingSupport φ ∩ marginEvent φ (1/2) f)) :
    (posterior (N := N) (r := r) φ globalMargin σ f sample).real
      (exceptionalPartitions (Q := Q) J) ≤ β := by
  have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hs1 : σ^2 ≤ 1 := (le_mul_of_one_le_left (sq_nonneg σ) hN1).trans hscale
  apply RobustPosterior.conditional_tail_of_exponential_bounds
    (smallPrior d N r σ) (posteriorEvent φ globalMargin f sample)
    (exceptionalPartitions (Q := Q) J) (measurable_posteriorEvent hφ globalMargin f sample)
    (sq_pos_of_pos hσ) hs1 hβ hβ1
    (posterior_event_mass_lower φ globalMargin σ f sample htarget)
    (smallPrior_exceptionalPartitions_scaled_tail hd hN hQ hσ hscale J)
  linarith

end NeuralGeneralization.BatchTwoMerging
