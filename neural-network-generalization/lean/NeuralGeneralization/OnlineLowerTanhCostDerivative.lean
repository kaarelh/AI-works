import NeuralGeneralization.OnlineLowerTanhCostIdentification
import NeuralGeneralization.OnlineLowerCauchyOrder
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas

/-! Quantitative high derivatives of the actual optimized tanh cost.
The constants come from the proved holomorphic expansion, not a scalar
certificate assumed by the final theorem. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped Topology
open Complex Set Metric
namespace NeuralGeneralization.OnlineLowerTanh

def optimizedCostRemainder (b:ActualGainBranch) (z:ℂ) : ℂ :=
  holomorphicOptimizedCost b z-((optimizedCostSlope:ℂ)*z+
    (optimizedCostIntercept:ℂ)+(optimizedCostCurvature:ℂ)/z)

lemma cauchy_gain_disk_domain (u T:ℝ) (j:ℕ) (hT:0≤T)
    (hu:(j+1:ℕ)*T<u) {z:ℂ}
    (hz:z∈closedBall (u:ℂ) (u*(j:ℝ)/((j:ℝ)+1))) :
    0<z.re ∧ T<‖z‖ := by
  have hj:0<(j:ℝ)+1 := by positivity
  have hu0:0<u := lt_of_le_of_lt (by positivity) hu
  have hdist:‖z-(u:ℂ)‖≤u*(j:ℝ)/((j:ℝ)+1) := by
    simpa only [Metric.mem_closedBall,dist_eq_norm] using hz
  have hre:=Complex.abs_re_le_norm (z-(u:ℂ))
  simp only [Complex.sub_re,Complex.ofReal_re] at hre
  have hzlow:u-u*(j:ℝ)/((j:ℝ)+1)≤z.re := by
    have hh:=neg_abs_le (z.re-u)
    linarith
  have he:u-u*(j:ℝ)/((j:ℝ)+1)=u/((j:ℝ)+1) := by field_simp; ring
  rw [he] at hzlow
  have hsmall:T<u/((j:ℝ)+1) := (lt_div_iff₀ hj).mpr (by simpa only [Nat.cast_add,Nat.cast_one,mul_comm] using hu)
  have hzT:T<z.re := hsmall.trans_le hzlow
  exact ⟨lt_of_le_of_lt hT hzT,hzT.trans_le ((le_abs_self _).trans (Complex.abs_re_le_norm z))⟩

/-- The averaged Cauchy estimate applies to all derivative orders up to a
linear fraction of the degree; its relative loss is `O(j/u)`. -/
theorem optimizedCostRemainder_all_derivative_bounds (b:ActualGainBranch) :
    ∃T K:ℝ,2≤T ∧ 0<K ∧ b.threshold≤T ∧
      DifferentiableOn ℂ (holomorphicOptimizedCost b) {z:ℂ|0<z.re ∧ T<‖z‖} ∧
      ∀j:ℕ,0<j→∀u:ℝ,(j+1:ℕ)*T<u→
        ‖iteratedDeriv j (optimizedCostRemainder b) (u:ℂ)‖≤
          6*K*(j:ℝ)*(j.factorial:ℝ)/u^(j+2) := by
  obtain ⟨T,K,hT,hK,hb,ha,hbound⟩:=holomorphicOptimizedCost_uniform_expansion b
  refine ⟨T,K,hT,hK,hb,ha,?_⟩
  intro j hj u hu
  have hT0:0≤T := le_trans (by norm_num) hT
  have hu0:0<u := lt_of_le_of_lt (by positivity) hu
  have hdom (z:ℂ) (hz:z∈closedBall (u:ℂ) (u*(j:ℝ)/((j:ℝ)+1))) :=
    cauchy_gain_disk_domain u T j hT0 hu hz
  apply quadraticRemainder_deriv_order_bound (optimizedCostRemainder b) u K hu0 hK.le j hj
  · apply DifferentiableOn.sub (ha.mono (fun z hz=>hdom z hz))
    apply DifferentiableOn.add
    · fun_prop
    · apply DifferentiableOn.div (differentiableOn_const _) differentiableOn_id
      intro z hz hzero
      have hp:0<z.re := (hdom z hz).1
      simpa [hzero] using hp
  · intro z hz
    exact hbound z (hdom z (sphere_subset_closedBall hz)).1
      (hdom z (sphere_subset_closedBall hz)).2

end NeuralGeneralization.OnlineLowerTanh
