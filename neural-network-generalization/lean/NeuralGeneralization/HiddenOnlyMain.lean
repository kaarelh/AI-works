import NeuralGeneralization.HiddenOnlyPosterior
import NeuralGeneralization.RobustMainReduction

/-! The hidden-only replacement theorem with an explicit finite-class
budget and a single event for all widths, scales, and optional clean-margin
conditioning choices. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.HiddenOnly
open ConcreteModel RobustStatistics RobustConfidence RobustPosterior RobustMainAssembly
variable {d C N r n : ℕ}

theorem risk_on_common_event (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c ε σ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1)
    (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (globalMargin : Bool)
    (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (S : Fin n → Cube d) (hn : 0 < n)
    (hs : S ∈ generalizationEvent D (TwoMarginTransport.rule.candidateLoss B.computes
      (ScoreTransform.candidate d r (digitalMassPolynomial d C r c) c ε (1/20))) n (ε/12)) :
    gibbsMarginRisk D (posterior (N := N) (r := r) c σ globalMargin B.computes S)
      (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤ ε/3 := by
  let K := digitalMassPolynomial d C r c
  let E := posteriorEvent (N := N) (r := r) c globalMargin B.computes S
  let Q := cond (smallPrior d N r σ) E
  let Q' := cond (smallPrior d N r σ) (E ∩ readoutCap (RobustConditioned.cap K ε))
  have hC : 0 < C := Nat.pos_of_ne_zero (fun hz => by simpa [hz] using B.constant.isLt)
  have hN := hC.trans_le hCN
  have hE := measurable_posteriorEvent (N := N) (r := r) hc globalMargin B.computes S
  obtain ⟨hQ,hQ',hKL,hsupport,hrestore⟩ := RobustConditioned.retained_inputs hd hN
    (digitalMassPolynomial_nonneg d C r c) hc hσ hscale hε hε1 E hE
    (posterior_target_mass hd B hCN hc hσ hscale globalMargin S)
  letI : IsProbabilityMeasure Q := hQ
  letI : IsProbabilityMeasure Q' := hQ'
  obtain ⟨Γ,hΓ,π,hfail⟩ := pointwise_compression hd hN (digitalMassPolynomial_nonneg d C r c)
    hc hε hε1 hσ hscale Q' hKL (hsupport.mono fun _ hw => hw.2)
  letI : IsProbabilityMeasure Γ := hΓ
  have hnull (x : Cube d) : Q'.real {w | ¬ atInput Real.tanh c w x} = 0 := by
    apply cond_null_of_disjoint _ _ _ (hE.inter (measurable_readoutCap _))
    apply Set.disjoint_left.mpr
    intro w hw hbad
    exact hbad (hw.1.1.1 x)
  have htrain (i : Fin n) : Q'.real {w | labelReal (B.computes (S i))*networkOutput Real.tanh w (S i) ≤ 1/2} = 0 := by
    apply cond_null_of_disjoint _ _ _ (hE.inter (measurable_readoutCap _))
    apply Set.disjoint_left.mpr
    intro w hw hbad
    exact (not_le_of_gt (hw.1.1.2 i)) hbad
  have hh := TwoMarginTransport.rule.posterior_margin_risk_on_event D B.computes
    (ScoreTransform.candidate d r K c ε (1/20)) hn S hs Q Q' Γ
    (networkOutput Real.tanh) (fun x => (continuous_networkOutput tanh_continuous x).measurable)
    π (fun x => by simpa only [hnull x,add_zero] using hfail x) htrain
    (fun x => hrestore {w | labelReal (B.computes x)*networkOutput Real.tanh w x ≤ 1/4})
  change gibbsMarginRisk D Q _ _ _ ≤ ε/3
  linarith

/-- The finite-class budget uses the hidden-noise resources. Global separation
is quantified after the same sample event, as are width and prior scale. -/
theorem learning (hd : 0 < d) (B : LayeredBooleanCircuit d C r)
    {c ε δ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (n : ℕ) (hn : 0 < n)
    (hbudget : 2*((ScoreTransform.resources d r (digitalMassPolynomial d C r c) c ε (1/20)).entropyBudget+Real.log (2/δ)) ≤
      (n:ℝ)*(ε/12)^2) :
    ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
      1-δ ≤ (CompressionSampling.iidSamples D n).real E ∧
      ∀ S ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
      ∀ globalMargin : Bool,
        0 < (smallPrior d N r σ).real (posteriorEvent c globalMargin B.computes S) ∧
        gibbsMarginRisk D (posterior (N := N) (r := r) c σ globalMargin B.computes S)
          (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤ ε/3 ∧
        D.real {x | correctConfidence (posterior (N := N) (r := r) c σ globalMargin B.computes S)
          (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x ≤ (2/3:ℝ)} ≤ ε := by
  let K := digitalMassPolynomial d C r c
  let p := ScoreTransform.resources d r K c ε (1/20)
  have hp := ScoreTransform.resources_valid d r (by norm_num : (0:ℝ)<1/20) (digitalMassPolynomial_nonneg d C r c) hc hε hε1
  have hR : 0 < p.inverseRadius := lt_of_lt_of_le (by decide : 0 < 6) hp.2.2.2.1
  letI : Nonempty (ScoreTransform.Code d r K c ε (1/20)) :=
    ⟨fun _ => ⟨0,by apply Finset.mem_Icc.mpr; constructor <;> omega⟩⟩
  let a := ScoreTransform.candidate d r K c ε (1/20)
  let E := generalizationEvent D (TwoMarginTransport.rule.candidateLoss B.computes a) n (ε/12)
  have hevent : MeasurableSet E ∧ 1-δ ≤ (CompressionSampling.iidSamples D n).real E := by
    refine ⟨measurable_generalizationEvent D _ (fun _ => measurable_of_finite _) n (ε/12),?_⟩
    exact finite_class_good_probability_log D _ (fun _ => measurable_of_finite _)
      (fun h x => TwoMarginTransport.rule.loss_bounds (B.computes x) (a h x)) n hn
      (by positivity : 0 ≤ ε/12) hδ (p.log_code_card_le_entropyBudget hR) hbudget
  refine ⟨E,hevent.1,hevent.2,?_⟩
  intro S hS N hCN σ hσ hscale globalMargin
  letI := posterior_probability hd B hCN hc hσ hscale globalMargin S
  have hrisk := risk_on_common_event hd B hCN hc hε hε1 hσ hscale globalMargin D S hn hS
  refine ⟨(Real.exp_pos _).trans_le (posterior_target_mass hd B hCN hc hσ hscale globalMargin S),hrisk,?_⟩
  have hconf := two_thirds_confidence_bound D
    (posterior (N := N) (r := r) c σ globalMargin B.computes S)
    (fun x => labelReal (B.computes x)) (networkOutput Real.tanh)
    (fun x => (continuous_networkOutput tanh_continuous x).measurable) (1/4) hrisk
  linarith

end NeuralGeneralization.HiddenOnly
