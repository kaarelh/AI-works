import PhysicalShortSignBudgets
import StrictCausalPicardFinite
import PhysicalAbsoluteCompression

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel

lemma canonicalNonlinearBudget_nonneg {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (η : ℝ) : 0≤canonicalNonlinearBudget P η := by
  unfold canonicalNonlinearBudget
  exact Finset.sum_nonneg (fun j _ => by positivity)

def canonicalSignIterations {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : ℕ :=
  causalSignIterations (canonicalEntropySum P)
    (canonicalNonlinearBudget P (canonicalSignPrecision P)) ‖P.readout‖

def canonicalSignRounding {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : ℝ :=
  causalSignRounding (canonicalEntropySum P)
    (canonicalNonlinearBudget P (canonicalSignPrecision P)) ‖P.readout‖

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

theorem rounded_iterate_error (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {η δ : ℝ} (hη : 0<η) (hδ : 0≤δ)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η)
    (x : Cube d) (u : ℕ → ℕ → CanonicalAmbient states H)
    (hinit : ∀j≤H,‖u 0 j-M.affineBase x j‖≤δ)
    (hupdate : ∀k j,j≤H → ‖u (k+1) j-volterra (M.affineBase x) M.propagator (M.normResidual η) (u k) j‖≤δ)
    (k : ℕ) : ‖u k H-M.normState x H‖≤
      (4+2*η)*(canonicalNonlinearBudget P η)^k/(k.factorial:ℝ)+δ*Real.exp (canonicalNonlinearBudget P η) := by
  have hh := inexact_picard_factorial_error_rounded_finite H (M.affineBase x) M.propagator (M.normResidual η)
    (M.nonlinearGain η) (M.nonlinearGain_nonneg η)
    (fun j i _ => M.propagator_norm_le j i) (M.normResidual_lipschitz hη)
    (M.normState x) (fun j _ => M.normState_volterra hη hquery x j) (by positivity : 0≤4+2*η) hδ
    (fun j _ => M.affineBase_error hd hη.le hquery x j) u hinit hupdate k H le_rfl
  simpa only [M.nonlinear_sum η] using hh

/-- Rounded parallel evaluation preserves the sign with a strict quarter
margin. Its inputs are the actual maps already constructed from the
controlled path, and its only numerical hypotheses are local evaluator errors. -/
theorem rounded_predict_margin (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x (canonicalSignPrecision P))
    (c : EuclideanSpace ℝ (states H).Index) (hc : ‖c‖≤‖P.readout‖)
    (hcompress : ∀x,|inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x)|≤1/16)
    (x : Cube d) (u : ℕ → ℕ → CanonicalAmbient states H)
    (hinit : ∀j≤H,‖u 0 j-M.affineBase x j‖≤canonicalSignRounding P)
    (hupdate : ∀k j,j≤H → ‖u (k+1) j-volterra (M.affineBase x) M.propagator
      (M.normResidual (canonicalSignPrecision P)) (u k) j‖≤canonicalSignRounding P) :
    (1:ℝ)/4<labelReal (f x)*M.predict c (u (canonicalSignIterations P) H) := by
  have hη := canonicalSignPrecision_pos P
  have hδ : 0≤canonicalSignRounding P :=
    (causalSignRounding_pos _ _ (norm_nonneg P.readout)).le
  let k := canonicalSignIterations P
  let η := canonicalSignPrecision P
  let Λ := canonicalNonlinearBudget P η
  let e := (4+2*η)*Λ^k/(k.factorial:ℝ)+canonicalSignRounding P*Real.exp Λ
  have hΛ : 0≤Λ := canonicalNonlinearBudget_nonneg P η
  have hη0 : 0≤η := hη.le
  have he : 0≤e := by dsimp only [e]; positivity
  have hu : ‖u k H-M.normState x H‖≤e :=
    M.rounded_iterate_error hd hη hδ hquery x u hinit hupdate k
  have hpred := M.predict_error c x (u k H) hu
  have hcost := causalSignBudgets (E:=canonicalEntropySum P) (canonicalNonlinearBudget_nonneg P η)
    (norm_nonneg P.readout) hη.le (canonicalSignPrecision_le_one P)
  have hsmall : |M.predict c (u k H)-inner ℝ c ((states H).feature x)|≤1/32 := by
    apply hpred.trans
    apply le_trans (mul_le_mul_of_nonneg_right
      (mul_le_mul_of_nonneg_left hc (Real.exp_nonneg _)) he)
    exact hcost
  have htotal : |inner ℝ P.readout (P.feature H x)-M.predict c (u k H)|≤3/32 := by
    have ht := abs_add_le (inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x))
      (inner ℝ c ((states H).feature x)-M.predict c (u k H))
    rw [sub_add_sub_cancel,abs_sub_comm (inner ℝ c ((states H).feature x))] at ht
    linarith [hcompress x]
  have hlabel : |labelReal (f x)*(inner ℝ P.readout (P.feature H x)-M.predict c (u k H))|≤3/32 := by
    simpa only [abs_mul,abs_labelReal,one_mul] using htotal
  have hle := (abs_le.mp hlabel).2
  have hm := P.margin x
  dsimp [k] at *
  nlinarith
end FiniteCanonicalDynamics

/-- Every genuine physical controlled margin path yields a concrete finite
canonical dynamics whose finite-precision parallel evaluation computes its
Boolean target. This theorem has no circuit-size conclusion yet: the separate
finite arithmetic compiler supplies that remaining resource bound. -/
theorem critical_finite_parallel_sign_program {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 0<H) :
    ∃S : Finset (Cube d),∃states : ℕ → CanonicalProgramState d,
      ∃c : EuclideanSpace ℝ (states H).Index,∃M : FiniteCanonicalDynamics P S states,
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (S.card:ℝ)≤(H:ℝ)/(2*physicalAbsolutePrecision P (canonicalSignPrecision P))+
        1024*‖P.readout‖^2 ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      (∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x (canonicalSignPrecision P)) ∧
      ‖c‖≤‖P.readout‖ ∧
      ∀x (u : ℕ → ℕ → CanonicalAmbient states H),
        (∀j≤H,‖u 0 j-M.affineBase x j‖≤canonicalSignRounding P) →
        (∀k j,j≤H → ‖u (k+1) j-volterra (M.affineBase x) M.propagator
          (M.normResidual (canonicalSignPrecision P)) (u k) j‖≤canonicalSignRounding P) →
        (1:ℝ)/4<labelReal (f x)*M.predict c (u (canonicalSignIterations P) H) := by
  obtain ⟨S,states,c,hzero,hcard,hdim,hstep,hquery,hc,herror⟩ :=
    physical_absolute_compression P hd hH (canonicalSignPrecision_pos P) (canonicalSignPrecision_le_one P) (by norm_num : (0:ℝ)<1/32)
  obtain ⟨M⟩ := finiteCanonicalDynamics_exists P S states hstep
  refine ⟨S,states,c,M,hzero,?_,hdim,hquery,hc,?_⟩
  · convert hcard using 1 <;> ring
  · intro x u hinit hupdate
    exact M.rounded_predict_margin hd hquery c hc
      (fun x => (herror x).trans (by linarith [canonicalSignPrecision_readout P])) x u hinit hupdate

#print axioms critical_finite_parallel_sign_program
end ConditionalNonpolynomial.Analytic.PhysicalShort
