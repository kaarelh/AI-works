import NeuralGeneralization.TwoMarginLocalizedLearning
import NeuralGeneralization.RobustLocalizedMain

/-! One pair of finite-class sample events gives the exact union-conditioned
Gaussian guarantee simultaneously at every eligible width and scale. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.TwoMarginTransport.Localized
open ConcreteModel RobustStatistics RobustConfidence
variable {d C r M : ℕ}

/-- Independent validation inputs. The event is chosen before N and σ; the
training likelihood remains the strict 1/2-margin condition at every input. -/
theorem localized_union_learning (hd : 0 < d) (T : LayeredBooleanCircuit d C r)
    (B : Fin M → Set (Cube d)) (j0 : Fin M) (hzero : B j0 = ∅)
    {c ρ ε δ : ℝ} (hc : 0 < c) (hρ : 0 ≤ ρ)
    (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ) (hδ1 : δ < 1)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hvalidation : 2*(Real.log (M:ℝ)+Real.log (4/δ)) ≤ (m:ℝ)*(ε/12)^2)
    (hlabeled : 2*(Real.log (M:ℝ)+
      (RobustConditioned.resources d r (componentCost d C r M c ε) c ε).entropyBudget+
      Real.log (4/δ)) ≤ (n:ℝ)*(ε/12)^2) :
    ∃ E : Set ((Fin m → Cube d) × (Fin n → Cube d)),MeasurableSet E ∧
      1-δ ≤ ((Measure.pi (fun _ : Fin m => D)).prod (Measure.pi (fun _ : Fin n => D))).real E ∧
      ∀ VS ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
        gibbsMarginRisk D (posterior (N := N) (r := r) B c ρ σ T.computes VS.1 VS.2)
          (fun x => labelReal (T.computes x)) (networkOutput Real.tanh) (1/4) ≤ ρ+ε := by
  obtain ⟨EV,hEV,hprobV,hV⟩ := RobustLocalized.validation_event B j0 hε hδ D m hm hvalidation
  obtain ⟨ES,hES,hprobS,hS⟩ := RobustLocalized.labeled_event B j0 T.computes hc hε hε1 hδ D n hn hlabeled
  refine ⟨EV ×ˢ ES,hEV.prod hES,?_,?_⟩
  · rw [measureReal_prod_prod]
    have hh := mul_le_mul hprobV hprobS (show 0 ≤ 1-δ/2 by linarith) measureReal_nonneg
    nlinarith [sq_nonneg δ]
  · intro VS hVS N hCN σ hσ hscale
    exact risk_on_common_events hd T hCN B j0 hzero hc hρ hσ hscale hε hε1
      D VS.1 VS.2 hn (hV VS.1 hVS.1) (hS VS.2 hVS.2)

/-- The same labeled inputs can select the support: both events are uniform,
and their failure probabilities are added without an independence premise. -/
theorem localized_same_inputs (hd : 0 < d) (T : LayeredBooleanCircuit d C r)
    (B : Fin M → Set (Cube d)) (j0 : Fin M) (hzero : B j0 = ∅)
    {c ρ ε δ : ℝ} (hc : 0 < c) (hρ : 0 ≤ ρ)
    (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (n : ℕ) (hn : 0 < n)
    (hvalidation : 2*(Real.log (M:ℝ)+Real.log (4/δ)) ≤ (n:ℝ)*(ε/12)^2)
    (hlabeled : 2*(Real.log (M:ℝ)+
      (RobustConditioned.resources d r (componentCost d C r M c ε) c ε).entropyBudget+
      Real.log (4/δ)) ≤ (n:ℝ)*(ε/12)^2) :
    ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
      1-δ ≤ (Measure.pi (fun _ : Fin n => D)).real E ∧
      ∀ S ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
        gibbsMarginRisk D (posterior (N := N) (r := r) B c ρ σ T.computes S S)
          (fun x => labelReal (T.computes x)) (networkOutput Real.tanh) (1/4) ≤ ρ+ε := by
  obtain ⟨EV,hEV,hprobV,hV⟩ := RobustLocalized.validation_event B j0 hε hδ D n hn hvalidation
  obtain ⟨ES,hES,hprobS,hS⟩ := RobustLocalized.labeled_event B j0 T.computes hc hε hε1 hδ D n hn hlabeled
  refine ⟨EV ∩ ES,hEV.inter hES,?_,?_⟩
  · have hv : (Measure.pi (fun _ : Fin n => D)).real EVᶜ ≤ δ/2 := by
      rw [probReal_compl_eq_one_sub hEV]; linarith
    have hs : (Measure.pi (fun _ : Fin n => D)).real ESᶜ ≤ δ/2 := by
      rw [probReal_compl_eq_one_sub hES]; linarith
    have hb := measureReal_union_le (μ := Measure.pi (fun _ : Fin n => D)) EVᶜ ESᶜ
    rw [← Set.compl_inter,probReal_compl_eq_one_sub (hEV.inter hES)] at hb
    linarith
  · intro S hSE N hCN σ hσ hscale
    exact risk_on_common_events hd T hCN B j0 hzero hc hρ hσ hscale hε hε1 D S S hn (hV S hSE.1) (hS S hSE.2)

end NeuralGeneralization.TwoMarginTransport.Localized
