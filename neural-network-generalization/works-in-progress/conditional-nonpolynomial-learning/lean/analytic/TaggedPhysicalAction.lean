import ScalarMomentExcess
import TaggedScalarAppend

noncomputable section
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic

theorem TaggedScalarPath.priorHiddenCost_eq_reused {t v r : ℝ} (P : TaggedScalarPath t v r)
    (Q : ℕ→Measure ℝ) (H : ℕ) (hlen : P.length=H)
    (hcontrol : ∀j<H,P.control j=(Q j).prod scoreSignLaw) :
    P.priorHiddenCost=∑j∈Finset.range H,
      (klDiv ((Q j).prod scoreSignLaw) (taggedGaussianReference t)).toReal := by
  rw [P.priorHiddenCost_eq_sum,
    Fin.sum_univ_eq_sum_range (fun j=>(klDiv (P.control j) (taggedGaussianReference t)).toReal),hlen]
  apply Finset.sum_congr rfl
  intro j hj
  rw [hcontrol j (Finset.mem_range.mp hj)]

/-- A uniform physical action estimate retaining coefficient one on the
critical action K. Only the excess scalar moments and readout variance pay the
additional subcritical correction. -/
theorem tagged_reused_physical_action {t v r K S : ℝ} (ht : 0<t) (ht1 : t≤1)
    (P : TaggedScalarPath t v r) (Q : ℕ→Measure ℝ) (H : ℕ) (hlen : P.length=H)
    (hcontrol : ∀j<H,P.control j=(Q j).prod scoreSignLaw)
    (hprob : ∀j<H,IsProbabilityMeasure (Q j))
    (hKL : ∀j<H,klDiv (Q j) (gaussianReal 0 1)≠∞)
    (hcost : (∑j∈Finset.range H,(klDiv (Q j) (gaussianReal 0 1)).toReal)+1/(8*P.terminal.1)≤K)
    (hsqrt : (∑j∈Finset.range H,Real.sqrt (klDiv (Q j) (gaussianReal 0 1)).toReal)≤S) :
    P.cost≤t^2*((H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+K+
      ((t^2)⁻¹-1)/2*(2*Real.sqrt 2*S+2*K)) := by
  let D := ∑j∈Finset.range H,(klDiv (Q j) (gaussianReal 0 1)).toReal
  let M := ∑j∈Finset.range H,((∫z:ℝ,z^2 ∂Q j)-1)
  let R := 1/(8*P.terminal.1)
  let θ := ((t^2)⁻¹-1)/2
  have hθ : 0≤θ := by
    have hh : 1≤(t^2)⁻¹ := (one_le_inv₀ (sq_pos_of_pos ht)).mpr (by nlinarith)
    dsimp [θ]
    linarith
  have hM : M≤2*Real.sqrt 2*S+2*D := by
    have hh := scalar_moment_excess_sum Q H hprob hKL
    have hm := mul_le_mul_of_nonneg_left hsqrt (by positivity : 0≤2*Real.sqrt 2)
    dsimp [M,D]
    linarith
  have htotal : D+R≤K := hcost
  have hfull : D+R+θ*(M+2*R)≤K+θ*(2*Real.sqrt 2*S+2*K) := by
    have hm : M+2*R≤2*Real.sqrt 2*S+2*K := by linarith
    have hh := mul_le_mul_of_nonneg_left hm hθ
    linarith
  have hreference : P.priorHiddenCost=D+(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+θ*M := by
    rw [P.priorHiddenCost_eq_reused Q H hlen hcontrol,tagged_controls_entropy_sum Q H ht hprob hKL]
  have hidentity : t^2*(1+2*θ)=1 := by
    dsimp [θ]
    field_simp
    ring
  have haction : P.cost=t^2*((H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+
      (D+R+θ*(M+2*R))) := by
    rw [TaggedScalarPath.cost,hreference]
    change t^2*(D+(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+θ*M)+R=_
    have hh := congrArg (fun z:ℝ=>z*R) hidentity
    nlinarith only [hh]
  rw [haction]
  apply mul_le_mul_of_nonneg_left _ (sq_nonneg t)
  change _≤(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+K+θ*(2*Real.sqrt 2*S+2*K)
  linarith

#print axioms tagged_reused_physical_action
end ConditionalNonpolynomial.Analytic
