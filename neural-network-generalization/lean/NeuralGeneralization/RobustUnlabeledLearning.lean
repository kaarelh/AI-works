import NeuralGeneralization.RobustUnlabeledRetained
import NeuralGeneralization.PointwiseRobustMainCompression
import NeuralGeneralization.PointwiseRobustStatistics

/-! Width-independent labeled learning with an explicit instability term, for
the actual input-adapted Gaussian posterior. No compressor premise remains. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustUnlabeled
open ConcreteModel RobustMainAssembly RobustMainProofs RobustStatistics RobustConfidence UnlabeledStability
variable {d C N r m n : ℕ}

theorem risk_on_common_event (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ ε : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (hε : 0 < ε) (hε1 : ε < 1) (globalMargin : Bool)
    (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (U : Fin m → Cube d) (S : Fin n → Cube d) (hn : 0 < n)
    (hS : S ∈ generalizationEvent D (candidateLoss B.computes (pointwiseCandidate d C r c ε)) n (ε/12)) :
    gibbsMarginRisk D (posterior (N := N) (r := r) c σ globalMargin B.computes U S)
      (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤
      ε/3+2*(∫ w,instability D (stableAt Real.tanh c) w
        ∂posterior (N := N) (r := r) c σ globalMargin B.computes U S) := by
  let Q := posterior (N := N) (r := r) c σ globalMargin B.computes U S
  let Q' := retained (N := N) (r := r) c σ (mainReadoutCap d C r c ε) globalMargin B.computes U S
  obtain ⟨hQ,hQ',hKL,hsupport,hrestore,hdom⟩ := retained_inputs hd B hCN hc hσ hscale hε hε1 globalMargin U S
  letI : IsProbabilityMeasure Q := hQ
  letI : IsProbabilityMeasure Q' := hQ'
  have hC : 0 < C := Nat.pos_of_ne_zero (fun hz => by simpa [hz] using B.constant.isLt)
  have hN := hC.trans_le hCN
  obtain ⟨Γ,hΓ,π,hfail⟩ := pointwise_main_compression hd hN hc hε hε1 hσ hscale Q' hKL
    (hsupport.mono (fun _ hw => hw.2.2))
  letI : IsProbabilityMeasure Γ := hΓ
  have hinstnull (i : Fin n) : Q'.real {w | ¬ stableAt Real.tanh c w (S i)} = 0 := by
    apply RobustPosterior.cond_null_of_disjoint _ _ _
      ((measurable_posteriorEvent hc globalMargin B.computes U S).inter (RobustPosterior.measurable_readoutCap _))
    apply Set.disjoint_left.mpr
    intro w hw hbad
    exact hbad (hw.1.1.1.2 i)
  have htrain (i : Fin n) : Q'.real {w | labelReal (B.computes (S i))*networkOutput Real.tanh w (S i) ≤ 1/2} = 0 := by
    apply RobustPosterior.cond_null_of_disjoint _ _ _
      ((measurable_posteriorEvent hc globalMargin B.computes U S).inter (RobustPosterior.measurable_readoutCap _))
    apply Set.disjoint_left.mpr
    intro w hw hbad
    exact (not_le_of_gt (hw.1.1.2 i)) hbad
  have hh := pointwise_posterior_margin_risk_on_event D B.computes (pointwiseCandidate d C r c ε)
    hn S hS Q Q' Γ (networkOutput Real.tanh) (fun x => (continuous_networkOutput tanh_continuous x).measurable)
    π (fun x => Q.real {w | ¬ stableAt Real.tanh c w x})
    (fun x => (hfail x).trans (add_le_add le_rfl (hdom {w | ¬ stableAt Real.tanh c w x})))
    (fun i => by simpa only [hinstnull i,add_zero] using hfail (S i)) htrain
    (fun x => hrestore {w | labelReal (B.computes x)*networkOutput Real.tanh w x ≤ 1/4})
  rw [instability_integral_swap Q D (stableAt Real.tanh c) (measurable_stableAt tanh_continuous hc)] at hh
  convert hh using 1 <;> ring

/-- A common labeled sample event works for every eligible width, scale,
unlabeled pool and both clean-margin conventions. -/
theorem common_labeled_event (hd : 0 < d) (B : LayeredBooleanCircuit d C r)
    {c ε δ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (n : ℕ) (hn : 0 < n)
    (hbudget : 2*((mainCompressionResources d C r c ε).entropyBudget+Real.log (4/δ)) ≤ (n:ℝ)*(ε/12)^2) :
    ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
      1-δ/2 ≤ (Measure.pi (fun _ : Fin n => D)).real E ∧
      ∀ S ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
        ∀ m : ℕ,∀ U : Fin m → Cube d,∀ globalMargin : Bool,
          gibbsMarginRisk D (posterior (N := N) (r := r) c σ globalMargin B.computes U S)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤
            ε/3+2*(∫ w,instability D (stableAt Real.tanh c) w
              ∂posterior (N := N) (r := r) c σ globalMargin B.computes U S) := by
  let p := mainCompressionResources d C r c ε
  have hp := mainResources_valid d C r hc hε hε1
  have hR : 0 < p.inverseRadius := by change 0 < (mainCompressionResources d C r c ε).inverseRadius; omega
  letI : Nonempty (PointwiseCode d C r c ε) := ⟨fun _ => ⟨0,by apply Finset.mem_Icc.mpr; constructor <;> omega⟩⟩
  let E := generalizationEvent D (candidateLoss B.computes (pointwiseCandidate d C r c ε)) n (ε/12)
  have hevent := common_sample_event_probability D B.computes (pointwiseCandidate d C r c ε) n hn
    (by positivity : 0 ≤ ε/12) (show 0 < δ/2 by positivity)
    (p.log_code_card_le_entropyBudget hR) (by
      have heq : 2/(δ/2) = 4/δ := by ring
      rwa [heq])
  refine ⟨E,hevent.1,hevent.2,?_⟩
  intro S hS N hCN σ hσ hscale m U globalMargin
  exact risk_on_common_event hd B hCN hc hσ hscale hε hε1 globalMargin D U S hn hS

end NeuralGeneralization.RobustUnlabeled
