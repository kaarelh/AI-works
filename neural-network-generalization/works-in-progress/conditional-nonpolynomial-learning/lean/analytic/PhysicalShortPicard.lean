import PhysicalShortDynamics
import FeatureGramContraction

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel

lemma ControlledMarginPath.feature_norm_le_two {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (j : ℕ) (hj : j≤H) (x : Cube d) :
    ‖P.feature j x‖≤2 := by
  cases j with
  | zero =>
    have hh := P.initial x x
    simp only [real_inner_self_eq_norm_sq] at hh
    have hn := normalizedInputFeature_norm_sq_le_two hd x
    nlinarith [norm_nonneg (P.feature 0 x)]
  | succ j => exact (P.hidden_norm_le_one j (by omega) x).trans (by norm_num)

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

def normLinear (M : FiniteCanonicalDynamics P S states) :=
  normalizedLinear M.linearGain M.linear

def normResidual (M : FiniteCanonicalDynamics P S states) (η : ℝ) :=
  normalizedResidual M.linearGain (M.residual η)

def normState (M : FiniteCanonicalDynamics P S states) (x : Cube d) :=
  normalizedState M.linearGain (M.state x)

def affineBase (M : FiniteCanonicalDynamics P S states) (x : Cube d) (j : ℕ) :=
  propagation M.normLinear j 0 (M.normState x 0)

def propagator (M : FiniteCanonicalDynamics P S states) (j i : ℕ) :=
  propagation M.normLinear j (i+1)

def iterate (M : FiniteCanonicalDynamics P S states) (η : ℝ) (x : Cube d) :=
  picard (M.affineBase x) M.propagator (M.normResidual η)

theorem normLinear_norm_le (M : FiniteCanonicalDynamics P S states) (j : ℕ) :
    ‖M.normLinear j‖≤1 :=
  normalizedLinear_norm_le _ _ M.linearGain_one_le M.linear_norm_le j

theorem normResidual_lipschitz (M : FiniteCanonicalDynamics P S states)
    {η : ℝ} (hη : 0<η) (j : ℕ) (x y : CanonicalAmbient states H) :
    ‖M.normResidual η j x-M.normResidual η j y‖≤M.nonlinearGain η j*‖x-y‖ :=
  normalizedResidual_lipschitz _ _ _ M.linearGain_one_le (M.nonlinearGain_nonneg η)
    (M.residual_lipschitz hη) j x y

theorem normResidual_range (M : FiniteCanonicalDynamics P S states)
    {η : ℝ} (hη : 0<η) (j : ℕ) (x : CanonicalAmbient states H) :
    ‖M.normResidual η j x‖≤M.residualRange η j :=
  normalizedResidual_range _ _ _ M.linearGain_one_le (M.residual_range hη) j x

theorem normState_recursion (M : FiniteCanonicalDynamics P S states) {η : ℝ} (hη : 0<η)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η)
    (x : Cube d) (j : ℕ) :
    M.normState x (j+1)=M.normLinear j (M.normState x j)+M.normResidual η j (M.normState x j) :=
  normalizedState_recursion _ _ _ _ M.linearGain_one_le (M.recursion hη hquery x) j

theorem propagator_norm_le (M : FiniteCanonicalDynamics P S states) (j i : ℕ) :
    ‖M.propagator j i‖≤1 := propagation_contracts _ M.normLinear_norm_le j (i+1)

theorem normState_volterra (M : FiniteCanonicalDynamics P S states) {η : ℝ} (hη : 0<η)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η)
    (x : Cube d) (j : ℕ) :
    M.normState x j=volterra (M.affineBase x) M.propagator (M.normResidual η) (M.normState x) j :=
  sequential_eq_volterra _ _ _ (M.normState_recursion hη hquery x) j

theorem state_norm_le (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {η : ℝ} (hη : 0≤η)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η)
    (x : Cube d) (j : ℕ) : ‖M.state x j‖≤2+η := by
  unfold state
  split_ifs with hj
  · rw [LinearIsometry.norm_map]
    exact (hquery j hj x).norm_le.trans (add_le_add (ControlledMarginPath.feature_norm_le_two P hd j hj x) le_rfl)
  · simp only [norm_zero]
    linarith

theorem normState_norm_le (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {η : ℝ} (hη : 0≤η)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η)
    (x : Cube d) (j : ℕ) : ‖M.normState x j‖≤2+η := by
  have hs := normalizingScale_one_le M.linearGain M.linearGain_one_le j
  have hi : 0≤(normalizingScale M.linearGain j)⁻¹ := inv_nonneg.mpr (by linarith)
  have hib : (normalizingScale M.linearGain j)⁻¹≤1 := inv_le_one_of_one_le₀ hs
  rw [normState,normalizedState,norm_smul,Real.norm_eq_abs,abs_of_nonneg hi]
  exact (mul_le_mul hib (M.state_norm_le hd hη hquery x j) (norm_nonneg _) (by norm_num)).trans_eq (one_mul _)

theorem affineBase_norm_le (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {η : ℝ} (hη : 0≤η)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η)
    (x : Cube d) (j : ℕ) : ‖M.affineBase x j‖≤2+η := by
  apply ((propagation M.normLinear j 0).le_opNorm _).trans
  exact (mul_le_mul (propagation_contracts _ M.normLinear_norm_le j 0)
    (M.normState_norm_le hd hη hquery x 0) (norm_nonneg _) (by norm_num)).trans_eq (one_mul _)

theorem affineBase_error (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {η : ℝ} (hη : 0≤η)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η)
    (x : Cube d) (j : ℕ) : ‖M.affineBase x j-M.normState x j‖≤4+2*η := by
  exact (norm_sub_le _ _).trans ((add_le_add (M.affineBase_norm_le hd hη hquery x j)
    (M.normState_norm_le hd hη hquery x j)).trans_eq (by ring))

theorem iterate_error (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {η : ℝ} (hη : 0<η)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η)
    (x : Cube d) (k : ℕ) :
    ‖M.iterate η x k H-M.normState x H‖≤
      (4+2*η)*(canonicalNonlinearBudget P η)^k/(k.factorial:ℝ) := by
  have hh := picard_factorial_error (M.affineBase x) M.propagator (M.normResidual η)
    (M.nonlinearGain η) (M.nonlinearGain_nonneg η)
    (fun j i _ => M.propagator_norm_le j i) (M.normResidual_lipschitz hη)
    (M.normState x) (M.normState_volterra hη hquery x) (by positivity : 0≤4+2*η)
    (M.affineBase_error hd hη.le hquery x) k H
  simpa only [iterate,M.nonlinear_sum η] using hh

theorem inexact_iterate_error (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {η δ : ℝ} (hη : 0<η) (hδ : 0≤δ)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η)
    (x : Cube d) (u : ℕ → ℕ → CanonicalAmbient states H)
    (hinit : ∀j,u 0 j=M.affineBase x j)
    (hupdate : ∀k j,‖u (k+1) j-volterra (M.affineBase x) M.propagator (M.normResidual η) (u k) j‖≤δ)
    (k : ℕ) : ‖u k H-M.normState x H‖≤
      (4+2*η)*(canonicalNonlinearBudget P η)^k/(k.factorial:ℝ)+δ*Real.exp (canonicalNonlinearBudget P η) := by
  have hh := inexact_picard_factorial_error (M.affineBase x) M.propagator (M.normResidual η)
    (M.nonlinearGain η) (M.nonlinearGain_nonneg η)
    (fun j i _ => M.propagator_norm_le j i) (M.normResidual_lipschitz hη)
    (M.normState x) (M.normState_volterra hη hquery x) (by positivity : 0≤4+2*η) hδ
    (M.affineBase_error hd hη.le hquery x) u hinit hupdate k H
  simpa only [M.nonlinear_sum η] using hh

end FiniteCanonicalDynamics
#print axioms FiniteCanonicalDynamics.iterate_error
#print axioms FiniteCanonicalDynamics.inexact_iterate_error
end ConditionalNonpolynomial.Analytic.PhysicalShort
