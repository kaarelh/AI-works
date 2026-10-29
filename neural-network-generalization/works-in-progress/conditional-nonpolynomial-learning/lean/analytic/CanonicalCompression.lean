import CanonicalReadoutProgram

noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

lemma QueryFeatureClose.mono {X E F : Type*} [Fintype X] [DecidableEq X]
    [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [NormedAddCommGroup F] [InnerProductSpace ℝ F]
    {P : X → E} {B : X → F} {S : Finset X} {x : X} {ε η : ℝ}
    (h : QueryFeatureClose P B S x ε) (he : ε≤η) : QueryFeatureClose P B S x η := by
  obtain ⟨U,V,hU,hV,hS,hx⟩ := h
  exact ⟨U,V,hU,hV,hS,hx.trans he⟩

lemma canonicalQueryError_monotone {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (δ : ℕ → ℝ) : Monotone (canonicalQueryError P δ) := by
  apply monotone_nat_of_le_succ
  intro j
  have he := canonicalQueryError_nonneg P δ j
  have hp := mul_nonneg (Real.sqrt_nonneg (2*criticalLayerCost P j)) he
  simp only [canonicalQueryError]
  nlinarith [Real.sqrt_nonneg (8*Real.sqrt (δ j))]

def canonicalEntropySum {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) : ℝ :=
  ∑j∈Finset.range H,Real.sqrt (2*criticalLayerCost P j)

def canonicalPrecision {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (η : ℝ) : ℝ :=
  (η/(4*((H:ℝ)+1)*Real.exp (canonicalEntropySum P)))^4

lemma canonicalPrecision_pos {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) {η : ℝ} (hη : 0<η) :
    0<canonicalPrecision P η := by
  unfold canonicalPrecision
  positivity

theorem canonicalPrecision_error {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) {η : ℝ} (hη : 0<η) (j : ℕ) (hj : j≤H) :
    canonicalQueryError P (fun _ => canonicalPrecision P η) j≤η := by
  apply (canonicalQueryError_monotone P (fun _ => canonicalPrecision P η) hj).trans
  have hh := canonicalQueryError_bound P (fun _ => canonicalPrecision P η) H
  simp only [Finset.sum_const,Finset.card_range,nsmul_eq_mul] at hh
  let u := η/(4*((H:ℝ)+1)*Real.exp (canonicalEntropySum P))
  have hu : 0≤u := by dsimp [u]; positivity
  have hsqrt : Real.sqrt (8*Real.sqrt (u^4))≤4*u := by
    apply (Real.sqrt_le_iff).mpr
    constructor
    · positivity
    · have he : Real.sqrt (u^4)=u^2 := by
        rw [show u^4=(u^2)^2 by ring,Real.sqrt_sq_eq_abs,abs_of_nonneg (sq_nonneg u)]
      rw [he]
      nlinarith [sq_nonneg u]
  have hwidth : 0<4*((H:ℝ)+1)*Real.exp (canonicalEntropySum P) := by positivity
  have hid : (4*((H:ℝ)+1)*Real.exp (canonicalEntropySum P))*u=η :=
    mul_div_cancel₀ η hwidth.ne'
  have hb : (H:ℝ)*(4*u)*Real.exp (canonicalEntropySum P)≤η := by
    have hp := mul_nonneg hu (Real.exp_pos (canonicalEntropySum P)).le
    nlinarith
  apply hh.trans
  change (H:ℝ)*Real.sqrt (8*Real.sqrt (u^4))*Real.exp (canonicalEntropySum P)≤η
  exact (mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_left hsqrt (Nat.cast_nonneg H)) (Real.exp_pos _).le).trans hb

/-- Quantitative compression of an actual critical controlled margin path.
The only exponential resource is in its square-root entropy sum, which the
separate occupation theorem bounds logarithmically near the baseline. -/
theorem critical_canonical_compression {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (hH : 0<H) {η ρ : ℝ} (hη : 0<η) (hρ : 0<ρ) :
    ∃S : Finset (Cube d), ∃states : ℕ → CanonicalProgramState d,
      ∃c : EuclideanSpace ℝ (states H).Index,
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (S.card:ℝ)≤(∑j:Fin H,criticalLayerCost P j/canonicalPrecision P η)+‖P.readout‖^2/ρ^2 ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      (∀j<H,CanonicalProgramStep P S j (states j) (states (j+1))) ∧
      (∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η) ∧
      ‖c‖≤‖P.readout‖ ∧
      ∀x,|inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x)|≤ρ+‖P.readout‖*η := by
  obtain ⟨S,states,c,hzero,hcard,hdim,hstep,hquery,hc,herror⟩ := critical_canonical_readout_program
    P hH (fun _ => canonicalPrecision P η) (fun _ _ => canonicalPrecision_pos P hη) hρ
  refine ⟨S,states,c,hzero,hcard,hdim,hstep,?_,hc,?_⟩
  · intro j hj x
    exact (hquery j hj x).mono (canonicalPrecision_error P hη j hj)
  · intro x
    exact (herror x).trans (add_le_add le_rfl
      (mul_le_mul_of_nonneg_left (canonicalPrecision_error P hη H le_rfl) (norm_nonneg _)))

#print axioms canonicalPrecision_error
#print axioms critical_canonical_compression
end ConditionalNonpolynomial.Analytic
