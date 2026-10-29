import PhysicalCompressionPrecision
import CanonicalProgramBudgets

/-! Absolute-error form of the actual physical compression, with polynomial
precision controlled by the final physical gain and readout norm. -/
noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

def physicalPartialGainBound (P : ControlledMarginPath d H t f) : ℝ :=
  1+2*‖P.readout‖*physicalGainProduct P H

lemma physicalPartialGainBound_pos (P : ControlledMarginPath d H t f) :
    0<physicalPartialGainBound P := by
  have hh : 0≤2*‖P.readout‖*physicalGainProduct P H :=
    mul_nonneg (by positivity) (physicalGainProduct_pos P H).le
  unfold physicalPartialGainBound
  linarith

lemma physicalGainProduct_le_partialBound (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j≤H) : physicalGainProduct P j≤physicalPartialGainBound P := by
  by_cases hz : j=0
  · subst j
    rw [physicalGainProduct_zero]
    unfold physicalPartialGainBound
    have hh : 0≤2*‖P.readout‖*physicalGainProduct P H :=
      mul_nonneg (by positivity) (physicalGainProduct_pos P H).le
    linarith
  · have hh := physical_partial_gain_readout_bound P j hj (by omega)
    unfold physicalPartialGainBound
    linarith

def physicalAbsolutePrecision (P : ControlledMarginPath d H t f) (ε : ℝ) : ℝ :=
  (ε/(128*((H:ℝ)+1)*(physicalPartialGainBound P+1)))^8

lemma physicalAbsolutePrecision_pos (P : ControlledMarginPath d H t f) {ε : ℝ} (hε : 0<ε) :
    0<physicalAbsolutePrecision P ε := by
  unfold physicalAbsolutePrecision
  positivity [physicalPartialGainBound_pos P]

lemma physicalAbsolutePrecision_error (P : ControlledMarginPath d H t f)
    {ε : ℝ} (hε : 0<ε) (hε1 : ε≤1) (j : ℕ) (hj : j≤H) :
    (j:ℝ)*normalizedAnchorError (physicalAbsolutePrecision P ε)*physicalGainProduct P j≤ε := by
  have hh := physical_compression_error_precision (H:=H) (W:=1) (G:=physicalPartialGainBound P)
    zero_le_one (physicalPartialGainBound_pos P).le hε hε1
  have heq : 64*((H:ℝ)+1)*((1:ℝ)+1)*(physicalPartialGainBound P+1)=
      128*((H:ℝ)+1)*(physicalPartialGainBound P+1) := by ring
  rw [heq,one_mul] at hh
  apply le_trans _ hh
  change (j:ℝ)*normalizedAnchorError (physicalAbsolutePrecision P ε)*physicalGainProduct P j≤
    (H:ℝ)*normalizedAnchorError (physicalAbsolutePrecision P ε)*physicalPartialGainBound P
  exact mul_le_mul
    (mul_le_mul_of_nonneg_right (by exact_mod_cast hj) (normalizedAnchorError_nonneg _))
    (physicalGainProduct_le_partialBound P j hj) (physicalGainProduct_pos P j).le
    (mul_nonneg (Nat.cast_nonneg _) (normalizedAnchorError_nonneg _))

theorem physical_absolute_compression (P : ControlledMarginPath d H t f)
    (hd : 1≤d) (hH : 0<H) {ε ρ : ℝ} (hε : 0<ε) (hε1 : ε≤1) (hρ : 0<ρ) :
    ∃S : Finset (Cube d), ∃states : ℕ→CanonicalProgramState d,
      ∃c : EuclideanSpace ℝ (states H).Index,
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (S.card:ℝ)≤(H:ℝ)/(2*physicalAbsolutePrecision P ε)+‖P.readout‖^2/ρ^2 ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      (∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1))) ∧
      (∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x ε) ∧
      ‖c‖≤‖P.readout‖ ∧
      ∀x,|inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x)|≤ρ+‖P.readout‖*ε := by
  obtain ⟨S,states,c,hzero,hcard,hdim,hstep,hquery,hc,herr⟩ :=
    physical_normalized_compression P hd hH (physicalAbsolutePrecision_pos P hε) hρ
  refine ⟨S,states,c,hzero,hcard,hdim,hstep,?_,hc,?_⟩
  · intro j hj x
    exact (hquery j hj x).mono (physicalAbsolutePrecision_error P hε hε1 j hj)
  · intro x
    exact (herr x).trans (add_le_add le_rfl (mul_le_mul_of_nonneg_left
      (physicalAbsolutePrecision_error P hε hε1 H le_rfl) (norm_nonneg _)))

#print axioms physical_absolute_compression
end ConditionalNonpolynomial.Analytic
