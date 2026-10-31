import NeuralGeneralization.BatchTwoQuadraticEnvelopeRate
import NeuralGeneralization.LearningBudget
import NeuralGeneralization.ModelLearning
import NeuralGeneralization.Statements

/-! The missing two-sided-quadratic-envelope strong-prior learning theorem.
The sample polynomial depends only on depth and a bound on the ratio of the
quadratic exponents. Coordinate prefactors affect only the fixed-width
small-scale threshold, which is chosen before D, n, and δ. -/
noncomputable section
open MeasureTheory Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.QuadraticEnvelope
open ConcreteModel

theorem strong_prior_quadratic_envelopes (r k : ℕ) (hk : 1≤k) :
    ∃A : ℝ,0<A ∧ ∃m : ℕ,
    ∀a b : ℝ,0<a→0<b→b≤a*k→
    ∀d : ℕ,1≤d→∀φ : ℝ→ℝ,admissibleActivation φ→
    ∀f : BooleanFunction d,∀C : ℕ,realizesAtComplexity (r:=r) φ f C→
    ∀N : ℕ,C≤N→∀ν : WeightIndex d N r→Coordinate a b,
    ∀ε : ℝ,0<ε→ε<1→∃σ₀ : ℝ,0<σ₀ ∧
    ∀σ : ℝ,0<σ→σ<σ₀→∀D : InputLaw d,∀δ : ℝ,0<δ→δ<1→∀n : ℕ,
    (6/ε)*(MainStatements.polynomialEnvelope A m d C 0+Real.log (1/δ))≤(n:ℝ)→
      (∀sample : Fin n→Cube d,0<posteriorDenominator φ (1/2) (smallPrior ν σ) f sample) ∧
      1-δ≤sampleProbability D n (fun sample=>
        posteriorRisk D f (networkPosterior φ (1/2) (smallPrior ν σ) f sample)≤ε/3 ∧
        ConcreteModel.confidenceFailure D f (networkPosterior φ (1/2) (smallPrior ν σ) f sample)≤ε) := by
  have hgrowth : PolynomialGrowth2 (fun d C=>strongCapacity d r (k*C)) :=
    (strongCapacity_polynomialGrowth r).compositionRight
      ((PolynomialGrowth2.const k).mul PolynomialGrowth2.right)
  obtain ⟨A,hA,m,hpoly⟩ := hgrowth.real_envelope
  refine ⟨A,hA,m,?_⟩
  intro a b ha hb hcompare d hd φ hφ f C hf N hCN ν ε hε hε1
  have hN : 0<N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hcφ := admissibleActivation_continuous hφ
  let H := BatchTwoNonGaussian.energyClass d N r (k*C) φ
  have htail := energyClass_tail_ratio ν (by omega : 0<d) ha hb hk hcompare hcφ f hf hCN
  have hpos : ∀ᶠσ in 𝓝[>] (0:ℝ),0<functionMass φ (1/2) (smallPrior ν σ) f := by
    filter_upwards [self_mem_nhdsWithin] with σ hσ
    exact smallMass_pos ν (by omega : 0<d) hb hcφ f hf hCN hσ
  have hcount : (H.card:ℝ)≤Real.exp (strongCapacity d r (k*C):ℝ) :=
    BatchTwoNonGaussian.energyClass_card_le_exp hd hN hφ
  obtain ⟨σ₀,hσ₀,hlearn⟩ := small_variance_network_learning_of_tail_ratio φ (1/2)
    (fun σ=>smallPrior ν σ) f H hpos htail (ε/3) (by linarith) (by linarith)
  refine ⟨σ₀,hσ₀,?_⟩
  intro σ hσ hσlt D δ hδ _hδ1 n hsize
  constructor
  · intro sample
    exact posteriorDenominator_pos φ (1/2) (smallPrior ν σ) f sample
      (smallMass_pos ν (by omega : 0<d) hb hcφ f hf hCN hσ)
  · have hcap : (strongCapacity d r (k*C):ℝ)≤MainStatements.polynomialEnvelope A m d C 0 := by
      simpa only [MainStatements.polynomialEnvelope,add_zero] using hpoly d C
    have hbudget : ((strongCapacity d r (k*C):ℝ)+Real.log (1/δ))/((ε/3)/2)≤(n:ℝ) := by
      calc
        _ ≤ (MainStatements.polynomialEnvelope A m d C 0+Real.log (1/δ))/((ε/3)/2) :=
          div_le_div_of_nonneg_right (add_le_add hcap le_rfl) (by linarith)
        _ = (6/ε)*(MainStatements.polynomialEnvelope A m d C 0+Real.log (1/δ)) := by
          field_simp [hε.ne']
          ring
        _ ≤ _ := hsize
    have hfail := NeuralGeneralization.exponential_sample_bound (H.card:ℝ)
      (strongCapacity d r (k*C):ℝ) ((ε/3)/2) δ n hcount hδ
      ((div_le_iff₀ (by linarith : 0<(ε/3)/2)).mp hbudget)
    have hh := hlearn σ hσ hσlt D δ n hfail
    simpa only [show 3*(ε/3)=ε by ring] using hh

end NeuralGeneralization.QuadraticEnvelope
