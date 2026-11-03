import NeuralGeneralization.RobustLocalizedLearning

/-! One pair of finite-class sample events gives the exact union-conditioned
Gaussian guarantee simultaneously at every eligible width and scale. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustLocalized
open ConcreteModel RobustStatistics RobustConfidence
variable {d C r M : ℕ}

def maskedLosses (B : Fin M → Set (Cube d)) (f : BooleanFunction d) (c ε : ℝ) :
    (Fin M × RobustConditioned.Code d r (componentCost d C r M c ε) c ε) → Cube d → ℝ :=
  fun jh => maskedCandidateLoss (B jh.1) f
    (RobustConditioned.candidate d r (componentCost d C r M c ε) c ε) jh.2

lemma validation_event (B : Fin M → Set (Cube d)) (j0 : Fin M)
    {ε δ : ℝ} (hε : 0 < ε) (hδ : 0 < δ)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (m : ℕ) (hm : 0 < m)
    (hbudget : 2*(Real.log (M:ℝ)+Real.log (4/δ)) ≤ (m:ℝ)*(ε/12)^2) :
    ∃ E : Set (Fin m → Cube d),MeasurableSet E ∧
      1-δ/2 ≤ (Measure.pi (fun _ : Fin m => D)).real E ∧
      ∀ V ∈ E,∀ j,D.real (B j) ≤ empiricalLoss (exceptionLoss B) V j+ε/12 := by
  classical
  letI : Nonempty (Fin M) := ⟨j0⟩
  let E := generalizationEvent D (exceptionLoss B) m (ε/12)
  have hb (j : Fin M) (x : Cube d) : 0 ≤ exceptionLoss B j x ∧ exceptionLoss B j x ≤ 1 := by
    by_cases hx : x ∈ B j <;> simp [exceptionLoss,hx]
  refine ⟨E,measurable_generalizationEvent D _ (fun _ => measurable_of_finite _) m (ε/12),?_,?_⟩
  · apply finite_class_good_probability_log D _ (fun _ => measurable_of_finite _) hb m hm
      (show 0 ≤ ε/12 by positivity) (show 0 < δ/2 by positivity)
      (by simp only [Fintype.card_fin]; exact le_rfl)
    simpa only [show 2/(δ/2) = 4/δ by ring] using hbudget
  · intro V hV j
    have hh := hV j
    have hid : (∫ x,exceptionLoss B j x ∂D) = D.real (B j) := by
      exact integral_indicator_one ((Set.to_countable (B j)).measurableSet)
    rwa [hid] at hh

lemma labeled_event (B : Fin M → Set (Cube d)) (j0 : Fin M) (f : BooleanFunction d)
    {c ε δ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (n : ℕ) (hn : 0 < n)
    (hbudget : 2*(Real.log (M:ℝ)+
      (RobustConditioned.resources d r (componentCost d C r M c ε) c ε).entropyBudget+
      Real.log (4/δ)) ≤ (n:ℝ)*(ε/12)^2) :
    ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
      1-δ/2 ≤ (Measure.pi (fun _ : Fin n => D)).real E ∧
      ∀ S ∈ E,∀ j,S ∈ generalizationEvent D
        (maskedCandidateLoss (B j) f (RobustConditioned.candidate d r (componentCost d C r M c ε) c ε)) n (ε/12) := by
  classical
  letI : Nonempty (Fin M) := ⟨j0⟩
  let K := componentCost d C r M c ε
  let p := RobustConditioned.resources d r K c ε
  have hK := componentCost_nonneg d C r (Nat.zero_lt_of_lt j0.isLt) c hε hε1
  have hp := RobustConditioned.resources_valid d r hK hc hε hε1
  have hR : 0 < p.inverseRadius := lt_of_lt_of_le (by decide : 0 < 6) hp.2.2.2.1
  letI : Nonempty (RobustConditioned.Code d r K c ε) :=
    ⟨fun _ => ⟨0,by apply Finset.mem_Icc.mpr; constructor <;> omega⟩⟩
  have hcount : Real.log (Fintype.card (Fin M × RobustConditioned.Code d r K c ε):ℝ) ≤
      Real.log (M:ℝ)+p.entropyBudget := by
    rw [Fintype.card_prod,Nat.cast_mul,Real.log_mul (by positivity) (by positivity),Fintype.card_fin]
    exact add_le_add le_rfl (p.log_code_card_le_entropyBudget hR)
  let loss := maskedLosses (C := C) (r := r) B f c ε
  let E := generalizationEvent D loss n (ε/12)
  have hb : ∀ jh x,0 ≤ loss jh x ∧ loss jh x ≤ 1 := fun jh x =>
    maskedCandidateLoss_bounds (B jh.1) f _ jh.2 x
  refine ⟨E,measurable_generalizationEvent D _ (fun _ => measurable_of_finite _) n (ε/12),?_,?_⟩
  · apply finite_class_good_probability_log D _ (fun _ => measurable_of_finite _) hb n hn
      (show 0 ≤ ε/12 by positivity) (show 0 < δ/2 by positivity) hcount
    simpa only [show 2/(δ/2) = 4/δ by ring] using hbudget
  · intro S hS j h
    exact hS (j,h)

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
  obtain ⟨EV,hEV,hprobV,hV⟩ := validation_event B j0 hε hδ D m hm hvalidation
  obtain ⟨ES,hES,hprobS,hS⟩ := labeled_event B j0 T.computes hc hε hε1 hδ D n hn hlabeled
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
  obtain ⟨EV,hEV,hprobV,hV⟩ := validation_event B j0 hε hδ D n hn hvalidation
  obtain ⟨ES,hES,hprobS,hS⟩ := labeled_event B j0 T.computes hc hε hε1 hδ D n hn hlabeled
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

end NeuralGeneralization.RobustLocalized
