import NeuralGeneralization.OnlineLowerTanhHolomorphicDerivativeExpansion
import NeuralGeneralization.OnlineLowerTanhStationary
import Mathlib.Analysis.Complex.RealDeriv

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open Complex Set Filter Metric
namespace NeuralGeneralization.OnlineLowerTanh

lemma weightedLogistic_differentiableOn (w:ℕ→ℂ) (K:ℝ) (n:ℕ)
    (hw:∀j,‖w j‖≤K*((j:ℝ)+1)^n) :
    DifferentiableOn ℂ (fun a=>∑'j:ℕ,w j*complexLogistic j a) {a:ℂ|1<a.re} := by
  refine differentiableOn_tsum_of_summable_norm ((logisticMajorant_poly_summable n).mul_left K)
    ?_ (isOpen_lt continuous_const Complex.continuous_re) ?_
  · intro j a ha
    exact (complexLogistic_differentiableAt j ha.le).const_mul _ |>.differentiableWithinAt
  · intro j a ha
    rw [norm_mul]
    calc
      _ ≤ (K*((j:ℝ)+1)^n)*logisticMajorant j :=
        mul_le_mul (hw j) (complexLogistic_bound j ha.le) (norm_nonneg _) ((norm_nonneg _).trans (hw j))
      _ = _ := by ring

lemma weightedLogisticFirst_differentiableOn (w:ℕ→ℂ) (K:ℝ) (n:ℕ)
    (hw:∀j,‖w j‖≤K*((j:ℝ)+1)^n) :
    DifferentiableOn ℂ (fun a=>∑'j:ℕ,w j*complexLogisticFirst j a) {a:ℂ|1<a.re} := by
  refine differentiableOn_tsum_of_summable_norm ((logisticFirstMajorant_poly_summable n).mul_left K)
    ?_ (isOpen_lt continuous_const Complex.continuous_re) ?_
  · intro j a ha
    exact (complexLogisticFirst_differentiableAt j ha.le).const_mul _ |>.differentiableWithinAt
  · intro j a ha
    rw [norm_mul]
    calc
      _ ≤ (K*((j:ℝ)+1)^n)*logisticFirstMajorant j :=
        mul_le_mul (hw j) (complexLogisticFirst_bound j ha.le) (norm_nonneg _) ((norm_nonneg _).trans (hw j))
      _ = _ := by ring

lemma complexF0_differentiableOn : DifferentiableOn ℂ complexF0 {a:ℂ|1<a.re} := by
  apply DifferentiableOn.sub (differentiableOn_const 1)
  apply DifferentiableOn.const_mul
  exact weightedLogistic_differentiableOn (fun j=>(-1:ℂ)^j) 1 0 (fun j=>by simp)

lemma complexF0Derivative_differentiableOn :
    DifferentiableOn ℂ complexF0Derivative {a:ℂ|1<a.re} := by
  apply DifferentiableOn.const_mul
  exact weightedLogisticFirst_differentiableOn (fun j=>(-1:ℂ)^j) 1 0 (fun j=>by simp)

lemma complexLogisticFirst_ofReal (j:ℕ) (a:ℝ) :
    complexLogisticFirst j (a:ℂ)=(logisticFirst j a:ℂ) := by
  unfold complexLogisticFirst logisticFirst logisticSlopeY
  rw [logisticPower_exp]
  push_cast
  rfl

lemma complexF0Derivative_ofReal (a:ℝ) :
    complexF0Derivative (a:ℂ)=(scalarF0First a:ℂ) := by
  unfold complexF0Derivative scalarF0First scalarF0FirstY
  push_cast
  congr 1
  apply tsum_congr
  intro j
  rw [complexLogisticFirst_ofReal]
  simp [logisticFirst]

lemma complexF1Derivative_ofReal (a:ℝ) :
    complexF1Derivative (a:ℂ)=(scalarF1First a:ℂ) := by
  unfold complexF1Derivative scalarF1First scalarF1FirstY
  push_cast
  rw [show (-4:ℂ)=4*(-1) by ring,mul_assoc,←tsum_mul_left]
  congr 1
  apply tsum_congr
  intro j
  rw [complexLogisticFirst_ofReal]
  unfold prefactoredFirst ratioFirst logisticFirst
  push_cast
  ring

def complexStationary0 (a:ℂ) : ℂ := a*complexF0Derivative a-complexF0 a
def complexStationary1 (a:ℂ) : ℂ := a*complexF1Derivative a-complexF1 a
def complexStationary2 (a:ℂ) : ℂ := a*complexF2Derivative a-complexF2 a

lemma complexStationary0_differentiableOn :
    DifferentiableOn ℂ complexStationary0 {a:ℂ|1<a.re} :=
  (differentiableOn_id.mul complexF0Derivative_differentiableOn).sub complexF0_differentiableOn

lemma complexStationary0_ofReal (a:ℝ) :
    complexStationary0 (a:ℂ)=(scalarStationary a:ℂ) := by
  unfold complexStationary0 scalarStationary
  rw [complexF0Derivative_ofReal,complexF0_ofReal]
  push_cast
  rfl

lemma complexStationary0_hasDerivAt_real (a:ℝ) (ha:6/5<a) :
    HasDerivAt complexStationary0 (a*scalarF0Second a:ℝ) (a:ℂ) := by
  have hc := (complexStationary0_differentiableOn.differentiableAt
    ((isOpen_lt continuous_const Complex.continuous_re).mem_nhds
      (show 1<(a:ℂ).re by simp; linarith))).hasDerivAt
  have hr := hc.comp_ofReal
  have hreal := (hasDerivAt_scalarStationary a ha).ofReal_comp
  have he : (fun y:ℝ=>complexStationary0 (y:ℂ))=(fun y:ℝ=>(scalarStationary y:ℂ)) :=
    funext complexStationary0_ofReal
  rw [he] at hr
  have hder:=hr.unique hreal
  rw [hder] at hc
  exact hc

lemma complexStationary0_limitingGain : complexStationary0 (limitingGain:ℂ)=0 := by
  rw [complexStationary0_ofReal,limitingGain_stationary,Complex.ofReal_zero]

lemma complexStationary0_limitingGain_deriv :
    deriv complexStationary0 (limitingGain:ℂ)=(limitingGain*scalarF0Second limitingGain:ℝ) :=
  (complexStationary0_hasDerivAt_real limitingGain (by linarith [limitingGain_mem.1])).deriv

lemma complexStationary0_limitingGain_deriv_ne : deriv complexStationary0 (limitingGain:ℂ)≠0 := by
  rw [complexStationary0_limitingGain_deriv]
  exact_mod_cast limitingGain_nondegenerate

end NeuralGeneralization.OnlineLowerTanh
