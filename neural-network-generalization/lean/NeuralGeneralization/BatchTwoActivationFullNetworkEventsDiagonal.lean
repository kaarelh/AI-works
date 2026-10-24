import NeuralGeneralization.BatchTwoActivationFullNetworkEventsLaw
import NeuralGeneralization.NetworkGramBasics

/-! Validated diagonal budgets for every layer of the physical network. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel GaussianAngularFields CompressionSampling FiniteDifferential
open RobustCompressionBlockMoments NetworkLayerSplit TowerNetwork NetworkGramBasics

variable {b d K H N r : ℕ} {σ ℓ : ℝ} {φ : ℝ→ℝ}

theorem activationInputSource_energy (hd : 0<d) (hscale : (N:ℝ)*σ^2≤1)
    (x : Cube d) : ∑j,(activationInputSource d N σ x j)^2≤
      (activationDiagonalBudget b d K 0:ℝ) := by
  have hdR : (0:ℝ)<d := Nat.cast_pos.mpr hd
  have h1d : (1:ℝ)≤d := Nat.one_le_cast.mpr hd
  have hh : ∑j,(activationInputSource d N σ x j)^2=
      σ^2*((N:ℝ)/d)*((d:ℝ)+1) := by
    simp only [activationInputSource,mul_pow,←Finset.mul_sum,
      Real.sq_sqrt (div_nonneg (Nat.cast_nonneg N) hdR.le),inputVector_square_sum]
  rw [hh]
  have hdiv : σ^2*((N:ℝ)/d)≤1/(d:ℝ) := by
    calc
      σ^2*((N:ℝ)/d)=((N:ℝ)*σ^2)/d := by ring
      _≤1/(d:ℝ) := div_le_div_of_nonneg_right hscale hdR.le
  have hm:=mul_le_mul_of_nonneg_right hdiv (show 0≤(d:ℝ)+1 by positivity)
  have hsmall : (1/(d:ℝ))*((d:ℝ)+1)≤2 := by
    rw [div_mul_eq_mul_div,one_mul]
    apply (div_le_iff₀ hdR).mpr
    linarith
  simpa [activationDiagonalBudget] using hm.trans hsmall

theorem activationLastSource_energy (hN : 0<N) (hscale : (N:ℝ)*σ^2≤1)
    (w : Weights d N r) (M : ℝ) (hM : 0≤M)
    (hdiag : ∀x,(∑j,(finalHidden φ w x j)^2)/(N:ℝ)≤M) (x : Cube d) :
    ∑j,(activationLastSource φ σ w x j)^2≤M := by
  have hNR : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have hh : ∑j,(activationLastSource φ σ w x j)^2=
      ((N:ℝ)*σ^2)*((∑j,(finalHidden φ w x j)^2)/(N:ℝ)) := by
    simp only [activationLastSource,mul_pow,←Finset.mul_sum]
    field_simp
  rw [hh]
  exact (mul_le_mul_of_nonneg_left (hdiag x) (by positivity)).trans
    (by simpa using mul_le_mul_of_nonneg_right hscale hM)

theorem ActivationGoodHidden.diagonal (hd : 0<d) (hN : 0<N) (hb : 1≤b) (hK : 1≤K)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0≤ℓ) (hℓ : ℓ≤b) :
    ∀(r : ℕ)(w : Weights d N r),ActivationGoodHidden b d K H N φ σ r w→
    ∀x,(∑j,(finalHidden φ w x j)^2)/(N:ℝ)≤activationDiagonalBudget b d K (r+1) := by
  intro r
  induction r with
  | zero =>
    intro w hw x
    have hh:=polynomial_good_layer_diagonal (s:=0) hb hK
      (activationInputSource d N σ) (activationInputRows σ w)
      (activationStageBudget H (activationBaseBudget b d K H) 0)
      hφ hℓ0 hℓ hN (activationInputSource_energy hd hscale) hw x
    simpa only [activationInputRows_output hd hN hσ] using hh
  | succ r ih =>
    intro w hw x
    have hprev:=ih (previousWeights w) hw.1
    have hvar:=activationLastSource_energy hN hscale (previousWeights w)
      (activationDiagonalBudget b d K (r+1)) (Nat.cast_nonneg _) hprev
    have hh:=polynomial_good_layer_diagonal (s:=r+1) hb hK
      (activationLastSource φ σ (previousWeights w)) (activationLastRows σ w)
      (activationStageBudget H (activationBaseBudget b d K H) (r+1))
      hφ hℓ0 hℓ hN hvar hw.2 x
    simpa only [activationLastRows_output hσ] using hh

end NeuralGeneralization.BatchTwoActivation
