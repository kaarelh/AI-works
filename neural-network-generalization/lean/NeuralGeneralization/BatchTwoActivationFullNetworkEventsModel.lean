import NeuralGeneralization.BatchTwoActivationDiagonalPropagation
import NeuralGeneralization.RobustCompressionBlockMoments
import NeuralGeneralization.NetworkLayerSplit
import NeuralGeneralization.LayerGramConcentration
import NeuralGeneralization.ProductFiberBound

/-! Actual standardized Gaussian source arrays and recursive good events for
an arbitrary zero-at-zero Lipschitz activation. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel GaussianAngularFields CompressionSampling FiniteDifferential
open RobustCompressionBlockMoments NetworkLayerSplit TowerNetwork

variable {d N r : ℕ}

def activationInputSource (d N : ℕ) (σ : ℝ) (x : Cube d) (j : Fin (d+1)) : ℝ :=
  σ*Real.sqrt ((N:ℝ)/d)*inputVector x j

def activationInputRows (σ : ℝ) (w : Weights d N r) (i : Fin N) (j : Fin (d+1)) : ℝ :=
  standardizedWeights σ w (.inl (i,j))

def activationLastSource (φ : ℝ → ℝ) (σ : ℝ) (w : Weights d N r)
    (x : Cube d) (j : Fin N) : ℝ := σ*finalHidden φ w x j

def activationLastRows (σ : ℝ) (w : Weights d N (r+1)) (i j : Fin N) : ℝ :=
  lastMatrix w (i,j)/σ

def activationInputBad (b d K H N : ℕ) (φ : ℝ → ℝ) (σ : ℝ) : Set (Weights d N 0) :=
  {w | activationInputRows σ w∈polynomialLayerBad (activationInputSource d N σ) φ
    (activationStageBudget H (activationBaseBudget b d K H) 0) N
    (activationDiagonalBudget b d K 0) (4*(K:ℝ))}

def activationLastBad (b d K H N r : ℕ) (φ : ℝ → ℝ) (σ : ℝ) : Set (Weights d N (r+1)) :=
  {w | activationLastRows σ w∈polynomialLayerBad
    (activationLastSource φ σ (previousWeights w)) φ
    (activationStageBudget H (activationBaseBudget b d K H) (r+1)) N
    (activationDiagonalBudget b d K (r+1)) (4*(K:ℝ))}

def ActivationGoodHidden (b d K H N : ℕ) (φ : ℝ → ℝ) (σ : ℝ) :
    (r : ℕ) → Weights d N r → Prop
  | 0,w => w∉activationInputBad b d K H N φ σ
  | r+1,w => ActivationGoodHidden b d K H N φ σ r (previousWeights w) ∧
      w∉activationLastBad b d K H N r φ σ

@[fun_prop] theorem measurable_activationInputRows (σ : ℝ) :
    Measurable (activationInputRows (d:=d) (N:=N) (r:=r) σ) := by
  exact measurable_pi_lambda _ (fun i => measurable_pi_lambda _ (fun j =>
    (measurable_pi_apply (.inl (i,j))).comp (measurable_standardizedWeights σ)))

@[fun_prop] theorem measurable_activationLastRows (σ : ℝ) :
    Measurable (activationLastRows (d:=d) (N:=N) (r:=r) σ) := by
  unfold activationLastRows
  fun_prop

@[fun_prop] theorem measurable_activationLastSource {φ : ℝ → ℝ} (hφ : Continuous φ) (σ : ℝ) :
    Measurable (activationLastSource (d:=d) (N:=N) (r:=r) φ σ) := by
  exact measurable_pi_lambda _ (fun x => measurable_pi_lambda _ (fun j =>
    ((continuous_finalHidden hφ x j).measurable.const_mul σ)))

theorem activationInputRows_field (hd : 0<d) (hN : 0<N) {σ : ℝ} (hσ : 0<σ)
    (w : Weights d N r) (x : Cube d) (i : Fin N) :
    fieldLinear (activationInputSource d N σ) (activationInputRows σ w i) x=
      ∑j,w (.inl (i,j))*inputVector x j := by
  have hroot : Real.sqrt ((N:ℝ)/d)≠0 := ne_of_gt (Real.sqrt_pos.mpr (by positivity))
  rw [fieldLinear_apply]
  unfold activationInputSource activationInputRows standardizedWeights whiten coordinateScale
  simp only [smallVariance,one_pow,mul_one]
  apply Finset.sum_congr rfl
  intro j _
  field_simp

theorem activationLastRows_field {σ : ℝ} (hσ : 0<σ)
    (w : Weights d N (r+1)) (x : Cube d) (i : Fin N) :
    fieldLinear (activationLastSource φ σ (previousWeights w)) (activationLastRows σ w i) x=
      ∑j,lastMatrix w (i,j)*finalHidden φ (previousWeights w) x j := by
  rw [fieldLinear_apply]
  unfold activationLastSource activationLastRows
  apply Finset.sum_congr rfl
  intro j _
  field_simp

theorem activationInputRows_output (hd : 0<d) (hN : 0<N) {σ : ℝ} (hσ : 0<σ)
    (φ : ℝ → ℝ) (w : Weights d N 0) (x : Cube d) (i : Fin N) :
    φ (fieldLinear (activationInputSource d N σ) (activationInputRows σ w i) x)=finalHidden φ w x i := by
  rw [activationInputRows_field hd hN hσ]
  rfl

theorem activationLastRows_output {σ : ℝ} (hσ : 0<σ)
    (φ : ℝ → ℝ) (w : Weights d N (r+1)) (x : Cube d) (i : Fin N) :
    φ (fieldLinear (activationLastSource φ σ (previousWeights w)) (activationLastRows σ w i) x)=
      finalHidden φ w x i := by
  rw [activationLastRows_field hσ]
  have hh := congrFun (finalHidden_appendLayer φ (previousWeights w) (fun i j=>lastMatrix w (i,j)) x) i
  rw [append_prefix_last] at hh
  exact hh.symm

end NeuralGeneralization.BatchTwoActivation
