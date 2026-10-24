import NeuralGeneralization.BatchTwoNonGaussianStrongClass
import NeuralGeneralization.BatchTwoNonGaussianStatements
import NeuralGeneralization.ModelLearning
import NeuralGeneralization.LearningBudget
import NeuralGeneralization.Activation

/-! The exact non-Gaussian strong-prior learning theorem.  The density model,
Gaussian comparison, rate-gap argument, compression, polynomial envelope, and
actual consistency posterior are all supplied by proved results. -/

noncomputable section
open MeasureTheory Filter
open scoped BigOperators Topology
open NeuralGeneralization.ConcreteModel
namespace NeuralGeneralization.BatchTwoNonGaussian

theorem smallMass_pos (ν : CoordinateLaw) {d C N r : ℕ} (hd : 0 < d)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N)
    {σ : ℝ} (hσ : 0 < σ) : 0 < functionMass φ (1 / 2) (smallPrior ν d N r σ) f := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hc.1) hCN
  have hp := small_functionMass_pos hd hφ f hc hCN
    (div_pos hσ (Real.sqrt_pos.mpr ν.upperCurvature_pos))
  have hcoef : 0 < ν.comparisonFactor ν.upperCurvature ^ Fintype.card (WeightIndex d N r) :=
    pow_pos (ν.comparisonFactor_pos _ ν.upperCurvature_pos) _
  exact (mul_pos hcoef hp).trans_le (smallMass_gaussian_lower ν hd hN σ φ (1 / 2) f)

/-- Paper Theorem 2.1 with its exact model, confidence criterion, all widths,
and scale-threshold quantifier order. -/
theorem strongPrior : StrongPriorGeneralization := by
  intro r ν
  obtain ⟨k, hk⟩ := exists_nat_gt (max 1 (ν.upperCurvature / ν.lowerCurvature))
  have hkreal : (1 : ℝ) ≤ k := (le_max_left _ _).trans hk.le
  have hkNat : 1 ≤ k := by exact_mod_cast hkreal
  have hcurv : ν.upperCurvature ≤ ν.lowerCurvature * k := by
    have hdiv := (le_max_right (1 : ℝ) (ν.upperCurvature / ν.lowerCurvature)).trans hk.le
    have hmul := (div_le_iff₀ ν.lowerCurvature_pos).mp hdiv
    nlinarith
  have hgrowth : PolynomialGrowth2 (fun d C => strongCapacity d r (k * C)) :=
    (strongCapacity_polynomialGrowth r).compositionRight
      ((PolynomialGrowth2.const k).mul PolynomialGrowth2.right)
  obtain ⟨A, hA, m, hpoly⟩ := hgrowth.real_envelope
  refine ⟨A, hA, m, ?_⟩
  intro d hd f C hc N hCN ε hε hε1
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hc.1.1) hCN
  let H := energyClass d N r (k * C) Real.tanh
  have htail := energyClass_tail_ratio ν (Nat.succ_le_iff.mp hd) hkNat hcurv
    tanh_continuous f hc.1 hCN
  have hpos : ∀ᶠ σ in 𝓝[>] (0 : ℝ), 0 < functionMass Real.tanh (1 / 2) (smallPrior ν d N r σ) f := by
    filter_upwards [self_mem_nhdsWithin] with σ hσ
    exact smallMass_pos ν (Nat.succ_le_iff.mp hd) tanh_continuous f hc.1 hCN hσ
  have hcount : (H.card : ℝ) ≤ Real.exp (strongCapacity d r (k * C) : ℝ) :=
    energyClass_card_le_exp hd hN tanh_admissible
  obtain ⟨σ₀, hσ₀, hlearn⟩ := small_variance_network_learning_of_tail_ratio Real.tanh (1 / 2)
    (fun σ => smallPrior ν d N r σ) f H hpos htail (ε / 3) (by linarith) (by linarith)
  refine ⟨σ₀, hσ₀, ?_⟩
  intro σ hσ hσlt D δ hδ _hδ1 n hsize
  constructor
  · intro sample
    exact posteriorDenominator_pos Real.tanh (1 / 2) (smallPrior ν d N r σ) f sample
      (smallMass_pos ν (Nat.succ_le_iff.mp hd) tanh_continuous f hc.1 hCN hσ)
  · have hcap : (strongCapacity d r (k * C) : ℝ) ≤ MainStatements.polynomialEnvelope A m d C 0 := by
      simpa only [MainStatements.polynomialEnvelope, add_zero] using hpoly d C
    have hbudget : ((strongCapacity d r (k * C) : ℝ) + Real.log (1 / δ)) / ((ε / 3) / 2) ≤ (n : ℝ) := by
      calc
        _ ≤ (MainStatements.polynomialEnvelope A m d C 0 + Real.log (1 / δ)) / ((ε / 3) / 2) :=
          div_le_div_of_nonneg_right (add_le_add hcap le_rfl) (by linarith)
        _ = (6 / ε) * (MainStatements.polynomialEnvelope A m d C 0 + Real.log (1 / δ)) := by
          field_simp [hε.ne']
          ring
        _ ≤ _ := hsize
    have hfail := NeuralGeneralization.exponential_sample_bound (H.card : ℝ)
      (strongCapacity d r (k * C) : ℝ) ((ε / 3) / 2) δ n hcount hδ
      ((div_le_iff₀ (by linarith : 0 < (ε / 3) / 2)).mp hbudget)
    have h := hlearn σ hσ hσlt D δ n hfail
    have heq : 3 * (ε / 3) = ε := by ring
    simpa only [heq] using h

end NeuralGeneralization.BatchTwoNonGaussian
