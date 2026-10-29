import NetworkReadoutCost

/-! Actual layer references, empirical covariance moments, and controlled
row laws for the finite-network witness. These paths are approximate; the
separate covariance-repair theorem must make their moment recursion exact. -/
noncomputable section
set_option linter.unusedSectionVars false
open MeasureTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.BatchTwoActivation
open NeuralGeneralization.NetworkLayerSplit NeuralGeneralization.TanhDifferential
open NeuralGeneralization.GaussianFieldTilt NeuralGeneralization.GaussianDualLayer
open NeuralGeneralization.CovarianceDualLift NeuralGeneralization.DualCertificate
open NeuralGeneralization.ActualBoundedDual NeuralGeneralization.BoundedDual
open NeuralGeneralization.BoundedTilt

/-- Gaussian reference at each sampled layer, conditional on preceding
actual hidden states. All references live on the full Boolean cube. -/
def hiddenReferences (d N : ℕ) (σ : ℝ) :
    (r : ℕ) → Weights d N r → Fin (r+1) → Measure (Cube d→ℝ)
  | 0,_ => fun _=>fieldLaw (activationInputSource d N σ)
  | r+1,w => Fin.snoc (hiddenReferences d N σ r (previousWeights w))
      (fieldLaw (activationLastSource Real.tanh σ (previousWeights w)))

/-- The empirical covariance after each hidden layer. -/
def hiddenMoments (d N : ℕ) (σ : ℝ) :
    (r : ℕ) → Weights d N r → Fin (r+1) → Cube d × Cube d → ℝ
  | 0,w => fun _=>empirical (features Real.tanh)
      (rows (activationInputSource d N σ) (activationInputRows σ w))
  | r+1,w => Fin.snoc (hiddenMoments d N σ r (previousWeights w))
      (empirical (features Real.tanh)
        (rows (activationLastSource Real.tanh σ (previousWeights w)) (activationLastRows σ w)))

instance hiddenReferences_probability (d N : ℕ) (σ : ℝ) :
    ∀ r (w : Weights d N r) (j : Fin (r+1)),
      IsProbabilityMeasure (hiddenReferences d N σ r w j) := by
  intro r
  induction r with
  | zero => intro w j; change IsProbabilityMeasure (fieldLaw _); infer_instance
  | succ r ih =>
    intro w j
    refine Fin.lastCases ?_ (fun i=>?_) j
    · simp only [hiddenReferences,Fin.snoc_last]
      infer_instance
    · simpa only [hiddenReferences,Fin.snoc_castSucc] using ih (previousWeights w) i

lemma hiddenMoments_bound (d N : ℕ) (hN : 0<N) (σ : ℝ) :
    ∀ r (w : Weights d N r) j p, |hiddenMoments d N σ r w j p|≤1 := by
  intro r
  induction r with
  | zero =>
    intro w j p
    exact empirical_abs_le_one (features Real.tanh)
      (features_bound Real.tanh (fun x=>(Real.abs_tanh_lt_one x).le)) hN _ p
  | succ r ih =>
    intro w j p
    refine Fin.lastCases ?_ (fun i=>?_) j
    · simp only [hiddenMoments,Fin.snoc_last]
      exact empirical_abs_le_one (features Real.tanh)
        (features_bound Real.tanh (fun x=>(Real.abs_tanh_lt_one x).le)) hN _ p
    · simpa only [hiddenMoments,Fin.snoc_castSucc] using ih (previousWeights w) _ p

lemma hiddenDenseCost_eq_sum (d N : ℕ) (σ G : ℝ) (M : ℕ) :
    ∀ r (w : Weights d N r), hiddenDenseCost d N σ G M r w =
      ∑ j, denseCost (hiddenReferences d N σ r w j) (features Real.tanh)
        G M N (hiddenMoments d N σ r w j) := by
  intro r
  induction r with
  | zero => intro w; simp [hiddenDenseCost,hiddenReferences,hiddenMoments,gaussianDenseCost]
  | succ r ih =>
    intro w
    rw [Fin.sum_univ_castSucc]
    simp only [hiddenReferences,hiddenMoments,Fin.snoc_castSucc,Fin.snoc_last]
    rw [←ih]
    rfl

/-- The actual hidden witness admits a finite sequence of row probability
laws with Mathlib KL budget at most its hidden dense statistic. -/
theorem actual_network_controlled_path (d N r : ℕ) (hN : 0<N)
    (σ G : ℝ) (hG : 0<G) {M : ℕ} (hM : 0<M) (w : Weights d N r) :
    ∃ star : Fin (r+1) → Cube d × Cube d → ℝ,
      (∀ j,entryL1 (star j)≤G) ∧
      (∀ j,IsProbabilityMeasure ((hiddenReferences d N σ r w j).tilted
        (potential (features Real.tanh) (star j)))) ∧
      (∀ j,klDiv ((hiddenReferences d N σ r w j).tilted
        (potential (features Real.tanh) (star j))) (hiddenReferences d N σ r w j)≠∞) ∧
      (∑ j,(klDiv ((hiddenReferences d N σ r w j).tilted
        (potential (features Real.tanh) (star j))) (hiddenReferences d N σ r w j)).toReal)
          ≤hiddenDenseCost d N σ G M r w ∧
      ∀ j,maxAbs (hiddenMoments d N σ r w j-
        mean (hiddenReferences d N σ r w j) (features Real.tanh) (star j))
          ≤hiddenDenseCost d N σ G M r w/G := by
  exact exists_controlled_path_of_cost (hiddenReferences d N σ r w) (features Real.tanh)
    (fun p=>(continuous_tanhPairValue p.1 p.2).measurable)
    (features_bound Real.tanh (fun x=>(Real.abs_tanh_lt_one x).le))
    (hiddenMoments d N σ r w) (hiddenMoments_bound d N hN σ r w)
    hG hM hN (hiddenDenseCost_eq_sum d N σ G M r w).symm.le

/-- Full finite-network event extraction, including the projected readout.
Every law and relative entropy in the conclusion is concrete. The only mass
premise is the explicit nonasymptotic Gaussian finite-grid tail. -/
theorem actual_network_event_controlled_path (d N r : ℕ) (hd : 0<d) (hN : 0<N)
    (σ G s B : ℝ) (hσ : 0<σ) (hG : 0<G) (hs : 0<s) (hs1 : s≤1)
    {M : ℕ} (hM : 0<M) (E : Set (Weights d N r))
    (hMass : (denseOverhead d N M G^(r+1)*(Real.sqrt s)⁻¹^(Fintype.card (Cube d))) /
      Real.exp ((N:ℝ)*B) < (smallPrior d N r σ).real E) :
    ∃ w∈E,∃ star : Fin (r+1) → Cube d × Cube d → ℝ,
      (∀ j,entryL1 (star j)≤G) ∧
      (∀ j,IsProbabilityMeasure ((hiddenReferences d N σ r w j).tilted
        (potential (features Real.tanh) (star j)))) ∧
      (∀ j,klDiv ((hiddenReferences d N σ r w j).tilted
        (potential (features Real.tanh) (star j))) (hiddenReferences d N σ r w j)≠∞) ∧
      (∑ j,(klDiv ((hiddenReferences d N σ r w j).tilted
        (potential (features Real.tanh) (star j))) (hiddenReferences d N σ r w j)).toReal)
          +((1-s)/(2*N))*projectedReadoutSquared σ w≤B ∧
      ∀ j,maxAbs (hiddenMoments d N σ r w j-
        mean (hiddenReferences d N σ r w j) (features Real.tanh) (star j))≤B/G := by
  obtain ⟨w,hw,hcost⟩ := full_network_event_witness d N r hd hN σ G s B hσ hs hs1 M E hMass
  obtain ⟨star,hstar,hprob,hfinite,hkl,herr⟩ :=
    actual_network_controlled_path d N r hN σ G hG hM w
  have hread : 0≤((1-s)/(2*N))*projectedReadoutSquared σ w := by
    apply mul_nonneg
    · exact div_nonneg (sub_nonneg.mpr hs1) (by positivity)
    · exact sq_nonneg _
  have hh : hiddenDenseCost d N σ G M r w≤B := by
    unfold fullDenseCost at hcost
    linarith
  refine ⟨w,hw,star,hstar,hprob,hfinite,?_,?_⟩
  · unfold fullDenseCost at hcost
    linarith
  · intro j
    exact (herr j).trans (div_le_div_of_nonneg_right hh hG.le)

#print axioms actual_network_event_controlled_path
#print axioms actual_network_controlled_path
end ConditionalNonpolynomial.Analytic
