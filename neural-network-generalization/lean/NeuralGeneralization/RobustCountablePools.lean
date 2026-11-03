import NeuralGeneralization.RobustSemisupervisedPool
import NeuralGeneralization.BatchTwoOnlineIIDMeasure

/-! A prescribed countable family of widths and scales, with one common
labeled event and nested unlabeled prefixes of an actual infinite IID stream.
No independence between the different pool events is required. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustUnlabeled
open ConcreteModel RobustMainAssembly RobustMainProofs RobustConfidence UnlabeledStability
open BatchTwoOnline (sequencePrefix measurable_sequencePrefix infinitePi_map_sequencePrefix)

/-- A countable union bound in real probability, with an explicit summable
allocation. This does not require independence of the events. -/
lemma countable_event_coverage {X : Type*} [MeasurableSpace X]
    (μ : Measure X) [IsProbabilityMeasure μ] (E : ℕ → Set X)
    (hE : ∀ j, MeasurableSet (E j)) (δ : ℕ → ℝ)
    (hδ : ∀ j, 0 ≤ δ j) (hsum : Summable δ)
    (hprob : ∀ j, 1-δ j ≤ μ.real (E j)) :
    1-(∑' j,δ j) ≤ μ.real (⋂ j,E j) := by
  have hbad (j : ℕ) : μ ((E j)ᶜ) ≤ ENNReal.ofReal (δ j) := by
    have hh : μ.real ((E j)ᶜ) ≤ δ j := by
      rw [probReal_compl_eq_one_sub (hE j)]
      linarith [hprob j]
    have he := ENNReal.ofReal_le_ofReal hh
    rwa [measureReal_def,ENNReal.ofReal_toReal (measure_ne_top _ _)] at he
  have hb : μ (⋃ j,(E j)ᶜ) ≤ ENNReal.ofReal (∑' j,δ j) := by
    apply (measure_iUnion_le _).trans
    rw [ENNReal.ofReal_tsum_of_nonneg hδ hsum]
    exact ENNReal.tsum_le_tsum hbad
  have ht : 0 ≤ ∑' j,δ j := tsum_nonneg hδ
  have hr := ENNReal.toReal_mono ENNReal.ofReal_ne_top hb
  rw [ENNReal.toReal_ofReal ht] at hr
  have heq : (⋂ j,E j)ᶜ = ⋃ j,(E j)ᶜ := Set.compl_iInter _
  change μ.real (⋃ j,(E j)ᶜ) ≤ _ at hr
  rw [← heq,probReal_compl_eq_one_sub (MeasurableSet.iInter hE)] at hr
  linarith

/-- The paper's countable-family claim, with literal individual budgets
`8*(D*/σ_j²+log(1/δ_j))/ε`. The finite-class labeled budget is paid once.
All learners use prefixes of the same infinite IID unlabeled stream. -/
theorem countable_pool_learning {d C r : ℕ}
    (hd : 0 < d) (B : LayeredBooleanCircuit d C r)
    {c ε δ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1)
    (hδ : 0 < δ) (hδ1 : δ < 1)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (n : ℕ) (hn : 0 < n)
    (hlabeled : 2*((mainCompressionResources d C r c ε).entropyBudget+Real.log (4/δ)) ≤ (n:ℝ)*(ε/12)^2)
    (N : ℕ → ℕ) (σ : ℕ → ℝ) (m : ℕ → ℕ) (δj : ℕ → ℝ)
    (hCN : ∀ j,C ≤ N j) (hσ : ∀ j,0 < σ j)
    (hscale : ∀ j,(N j:ℝ)*(σ j)^2 ≤ 1)
    (hδj : ∀ j,0 < δj j) (hsum : Summable δj) (halloc : (∑' j,δj j) ≤ δ/2)
    (hpools : ∀ j,(8/ε)*(digitalMassPolynomial d C r c/(σ j)^2+Real.log (1/δj j)) ≤ m j) :
    ∃ E : Set ((ℕ → Cube d) × (Fin n → Cube d)),MeasurableSet E ∧
      1-δ ≤ ((Measure.infinitePi (fun _ : ℕ => D)).prod (Measure.pi (fun _ : Fin n => D))).real E ∧
      ∀ p ∈ E,∀ j : ℕ,∀ globalMargin : Bool,
        gibbsMarginRisk D (posterior (N := N j) (r := r) c (σ j) globalMargin B.computes
          (sequencePrefix (m j) p.1) p.2)
          (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤ ε ∧
        D.real {x | correctConfidence (posterior (N := N j) (r := r) c (σ j) globalMargin B.computes
          (sequencePrefix (m j) p.1) p.2) (fun x => labelReal (B.computes x))
          (networkOutput Real.tanh) (1/4) x ≤ (2/3:ℝ)} ≤ 3*ε := by
  have hsmall (j : ℕ) : 2*δj j < 1 := by
    have hh := (hsum.le_tsum j (fun i _ => (hδj i).le)).trans halloc
    linarith
  have hex (j : ℕ) := posterior_instability_quarter hd B (hCN j) hc (hσ j) (hscale j)
    hε (mul_pos (by norm_num) (hδj j)) (hsmall j) D (m j) (by
      have heq : 2/(2*δj j) = 1/δj j := by ring
      simpa only [heq] using hpools j)
  choose EU hEU hprobU hU using hex
  obtain ⟨ES,hES,hprobS,hS⟩ := common_labeled_event hd B hc hε hε1 hδ D n hn hlabeled
  let F : ℕ → Set (ℕ → Cube d) := fun j => sequencePrefix (m j) ⁻¹' EU j
  have hF (j : ℕ) : MeasurableSet (F j) := (hEU j).preimage (measurable_sequencePrefix _)
  have hprobF (j : ℕ) : 1-δj j ≤ (Measure.infinitePi (fun _ : ℕ => D)).real (F j) := by
    dsimp [F]
    rw [← map_measureReal_apply (measurable_sequencePrefix _) (hEU j),infinitePi_map_sequencePrefix]
    convert hprobU j using 1 <;> ring
  have hprobAll : 1-δ/2 ≤ (Measure.infinitePi (fun _ : ℕ => D)).real (⋂ j,F j) :=
    (by linarith : 1-δ/2 ≤ 1-(∑' j,δj j)).trans
      (countable_event_coverage _ F hF δj (fun j => (hδj j).le) hsum hprobF)
  refine ⟨(⋂ j,F j) ×ˢ ES,(MeasurableSet.iInter hF).prod hES,?_,?_⟩
  · rw [measureReal_prod_prod]
    have hh := mul_le_mul hprobAll hprobS (by linarith : 0 ≤ 1-δ/2) measureReal_nonneg
    nlinarith [sq_nonneg δ]
  · intro p hp j globalMargin
    have hinst := hU j (sequencePrefix (m j) p.1) (Set.mem_iInter.mp hp.1 j) n p.2 globalMargin
    have hrisk := hS p.2 hp.2 (N j) (hCN j) (σ j) (hσ j) (hscale j)
      (m j) (sequencePrefix (m j) p.1) globalMargin
    have hb : gibbsMarginRisk D (posterior (N := N j) (r := r) c (σ j) globalMargin B.computes
        (sequencePrefix (m j) p.1) p.2) (fun x => labelReal (B.computes x))
        (networkOutput Real.tanh) (1/4) ≤ ε := by linarith
    refine ⟨hb,?_⟩
    letI := posterior_probability hd B (hCN j) hc (hσ j) (hscale j) globalMargin
      (sequencePrefix (m j) p.1) p.2
    have hcfd := margin_confidence_bound D
      (posterior (N := N j) (r := r) c (σ j) globalMargin B.computes (sequencePrefix (m j) p.1) p.2)
      (fun x => labelReal (B.computes x)) (networkOutput Real.tanh)
      (fun x => (continuous_networkOutput tanh_continuous x).measurable) (1/4)
      (by norm_num : (2/3:ℝ) < 1) hb
    convert hcfd using 1 <;> ring

#print axioms countable_pool_learning
end NeuralGeneralization.RobustUnlabeled
