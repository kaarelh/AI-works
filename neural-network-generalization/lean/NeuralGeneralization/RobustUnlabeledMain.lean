import NeuralGeneralization.RobustUnlabeledLearning

/-! The robust paper's unlabeled-pool learning theorem, for the actual Gaussian
posterior and independent IID labeled and unlabeled inputs. The labeled budget
is independent of width and scale; the unlabeled budget explicitly is not. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustUnlabeled
open ConcreteModel RobustMainAssembly RobustMainProofs RobustMainStatements RobustConfidence
variable {d C N r : ℕ}

/-- The complete posterior guarantee at the explicit finite-class labeled
budget and the paper's literal unlabeled budget 8(K+log(2/δ))/ε. -/
theorem unlabeled_pool_learning (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ ε δ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ) (hδ1 : δ < 1)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (n m : ℕ) (hn : 0 < n)
    (hlabeled : 2*((mainCompressionResources d C r c ε).entropyBudget+Real.log (4/δ)) ≤ (n:ℝ)*(ε/12)^2)
    (hunlabeled : (8/ε)*(digitalMassPolynomial d C r c/σ^2+Real.log (2/δ)) ≤ m) :
    ∃ E : Set ((Fin m → Cube d) × (Fin n → Cube d)),MeasurableSet E ∧
      1-δ ≤ ((Measure.pi (fun _ : Fin m => D)).prod (Measure.pi (fun _ : Fin n => D))).real E ∧
      ∀ p ∈ E,∀ globalMargin : Bool,
        gibbsMarginRisk D (posterior (N := N) (r := r) c σ globalMargin B.computes p.1 p.2)
          (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤ ε ∧
        D.real {x | correctConfidence (posterior (N := N) (r := r) c σ globalMargin B.computes p.1 p.2)
          (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x ≤ (2/3:ℝ)} ≤ 3*ε := by
  obtain ⟨EU,hEU,hprobU,hU⟩ := posterior_instability_quarter hd B hCN hc hσ hscale hε hδ hδ1 D m hunlabeled
  obtain ⟨ES,hES,hprobS,hS⟩ := common_labeled_event hd B hc hε hε1 hδ D n hn hlabeled
  refine ⟨EU ×ˢ ES,hEU.prod hES,?_,?_⟩
  · rw [measureReal_prod_prod]
    have hδhalf : 0 ≤ 1-δ/2 := by linarith
    have hh := mul_le_mul hprobU hprobS hδhalf measureReal_nonneg
    nlinarith [sq_nonneg δ]
  · intro p hp globalMargin
    have hinst := hU p.1 hp.1 n p.2 globalMargin
    have hrisk := hS p.2 hp.2 N hCN σ hσ hscale m p.1 globalMargin
    have hb : gibbsMarginRisk D (posterior (N := N) (r := r) c σ globalMargin B.computes p.1 p.2)
        (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤ ε := by linarith
    refine ⟨hb,?_⟩
    letI := posterior_probability hd B hCN hc hσ hscale globalMargin p.1 p.2
    have hcfd := margin_confidence_bound D (posterior (N := N) (r := r) c σ globalMargin B.computes p.1 p.2)
      (fun x => labelReal (B.computes x)) (networkOutput Real.tanh)
      (fun x => (continuous_networkOutput tanh_continuous x).measurable) (1/4)
      (by norm_num : (2/3:ℝ) < 1) hb
    convert hcfd using 1 <;> ring

/-- Universal polynomial labeled complexity. The coefficient and degree are
chosen before dimension, depth, circuit, width, scale, input law and accuracy.
Here σ²=t²/N, so D*/σ² is exactly the manuscript's aD*. -/
theorem unlabeled_pool_polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ d C r : ℕ,0 < d → ∀ B : LayeredBooleanCircuit d C r,
      ∀ c ε δ : ℝ,0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      ∀ D : Measure (Cube d),IsProbabilityMeasure D →
      ∀ n : ℕ,depthPolynomialEnvelope A k d C r c ε (δ/2) ≤ n →
      ∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
      ∀ m : ℕ,(8/ε)*(digitalMassPolynomial d C r c/σ^2+Real.log (2/δ)) ≤ m →
      ∃ E : Set ((Fin m → Cube d) × (Fin n → Cube d)),MeasurableSet E ∧
        1-δ ≤ ((Measure.pi (fun _ : Fin m => D)).prod (Measure.pi (fun _ : Fin n => D))).real E ∧
        ∀ p ∈ E,∀ globalMargin : Bool,
          gibbsMarginRisk D (posterior (N := N) (r := r) c σ globalMargin B.computes p.1 p.2)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤ ε ∧
          D.real {x | correctConfidence (posterior (N := N) (r := r) c σ globalMargin B.computes p.1 p.2)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x ≤ (2/3:ℝ)} ≤ 3*ε := by
  obtain ⟨A,hA,k,hpoly⟩ := mainCompressionSampleBudget_polynomial
  refine ⟨A,hA,k,?_⟩
  intro d C r hd B c ε δ hc hε hε1 hδ hδ1 D hD n hn N hCN σ hσ hscale m hm
  letI := hD
  have hdhalf : 0 < δ/2 := by positivity
  have hdhalf1 : δ/2 < 1 := by linarith
  have hbase := (mainPolynomialBase_bounds d C r hc hε hdhalf hdhalf1).1
  have hpos : 0 < depthPolynomialEnvelope A k d C r c ε (δ/2) := by
    change 0 < A*(mainPolynomialBase d C r c ε (δ/2))^k
    positivity
  have hnpos : 0 < n := by exact_mod_cast hpos.trans_le hn
  have hbudget : 2*((mainCompressionResources d C r c ε).entropyBudget+Real.log (4/δ)) ≤ (n:ℝ)*(ε/12)^2 := by
    apply (div_le_iff₀ (sq_pos_of_pos (by positivity : 0 < ε/12))).mp
    have heq : 2/(δ/2) = 4/δ := by ring
    have hp := hpoly d C r c ε (δ/2) hc hε hε1 hdhalf hdhalf1
    rw [heq] at hp
    exact hp.trans hn
  exact unlabeled_pool_learning hd B hCN hc hσ hscale hε hε1 hδ hδ1 D n m hnpos hbudget hm

#print axioms unlabeled_pool_polynomial
end NeuralGeneralization.RobustUnlabeled
