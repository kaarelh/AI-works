import NeuralGeneralization.RobustUnlabeledMain

/-! The same input pool may select the prior before its first n labels are
revealed. Only marginal IID laws and a union bound are needed. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustUnlabeled
open ConcreteModel RobustMainAssembly RobustMainProofs RobustMainStatements RobustConfidence UnlabeledStability

/-- Exact IID marginal law of a finite input samplePrefix. -/
lemma iid_prefix_map {X : Type*} [MeasurableSpace X] (D : Measure X) [IsProbabilityMeasure D]
    {n M : ℕ} (hnM : n ≤ M) :
    (Measure.pi (fun _ : Fin M => D)).map (fun U i => U (Fin.castLE hnM i)) =
      Measure.pi (fun _ : Fin n => D) := by
  have hi : iIndepFun (fun i (U : Fin M → X) => U i) (Measure.pi (fun _ : Fin M => D)) :=
    iIndepFun_pi (X := fun _ => id) (fun _ => aemeasurable_id)
  have he : Function.Injective (Fin.castLE hnM) := by intro i j hij; exact Fin.ext (congrArg (fun k : Fin M => k.val) hij)
  have hj := hi.precomp he
  have hh := hj.map_fun_eq_pi_map (fun i => (measurable_pi_apply (Fin.castLE hnM i)).aemeasurable)
  simpa only [(measurePreserving_eval (fun _ : Fin M => D) _).map_eq] using hh

lemma inputSupport_prefix {d N r n M : ℕ} (hnM : n ≤ M) (c : ℝ) (U : Fin M → Cube d) :
    inputSupport (N := N) (r := r) c U (fun i => U (Fin.castLE hnM i)) =
      poolEvent (stableAt Real.tanh c) U := by
  ext w
  constructor
  · exact fun hw => hw.1
  · exact fun hw => ⟨hw,fun i => hw (Fin.castLE hnM i)⟩

/-- One IID pool, followed by revelation of its first n labels. No independence
between the stability and labeled-sample events is assumed. -/
theorem semi_supervised_pool_learning {d C N r : ℕ}
    (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ ε δ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ) (hδ1 : δ < 1)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (n M : ℕ) (hn : 0 < n) (hnM : n ≤ M)
    (hlabeled : 2*((mainCompressionResources d C r c ε).entropyBudget+Real.log (4/δ)) ≤ (n:ℝ)*(ε/12)^2)
    (hpool : (8/ε)*(digitalMassPolynomial d C r c/σ^2+Real.log (2/δ)) ≤ M) :
    ∃ E : Set (Fin M → Cube d),MeasurableSet E ∧
      1-δ ≤ (Measure.pi (fun _ : Fin M => D)).real E ∧
      ∀ U ∈ E,∀ globalMargin : Bool,
        gibbsMarginRisk D (posterior (N := N) (r := r) c σ globalMargin B.computes U
          (fun i => U (Fin.castLE hnM i))) (fun x => labelReal (B.computes x))
          (networkOutput Real.tanh) (1/4) ≤ ε ∧
        D.real {x | correctConfidence (posterior (N := N) (r := r) c σ globalMargin B.computes U
          (fun i => U (Fin.castLE hnM i))) (fun x => labelReal (B.computes x))
          (networkOutput Real.tanh) (1/4) x ≤ (2/3:ℝ)} ≤ 3*ε := by
  obtain ⟨EU,hEU,hprobU,hU⟩ := posterior_instability_quarter hd B hCN hc hσ hscale hε hδ hδ1 D M hpool
  obtain ⟨ES,hES,hprobS,hS⟩ := common_labeled_event hd B hc hε hε1 hδ D n hn hlabeled
  let samplePrefix : (Fin M → Cube d) → (Fin n → Cube d) := fun U i => U (Fin.castLE hnM i)
  have hprefix : Measurable samplePrefix := measurable_pi_lambda _ (fun i => measurable_pi_apply _)
  let E := EU ∩ samplePrefix ⁻¹' ES
  have hE : MeasurableSet E := hEU.inter (hES.preimage hprefix)
  have hprobPrefix : 1-δ/2 ≤ (Measure.pi (fun _ : Fin M => D)).real (samplePrefix ⁻¹' ES) := by
    rw [← map_measureReal_apply hprefix hES,iid_prefix_map D hnM]
    exact hprobS
  have hbadU : (Measure.pi (fun _ : Fin M => D)).real EUᶜ ≤ δ/2 := by
    rw [probReal_compl_eq_one_sub hEU]
    linarith
  have hbadS : (Measure.pi (fun _ : Fin M => D)).real (samplePrefix ⁻¹' ES)ᶜ ≤ δ/2 := by
    rw [probReal_compl_eq_one_sub (hES.preimage hprefix)]
    linarith
  have hbad : (Measure.pi (fun _ : Fin M => D)).real Eᶜ ≤ δ := by
    dsimp [E]
    rw [Set.compl_inter]
    exact (measureReal_union_le _ _).trans (by linarith)
  refine ⟨E,hE,?_,?_⟩
  · rw [probReal_compl_eq_one_sub hE] at hbad
    linarith
  · intro U hUE globalMargin
    have hinst := hU U hUE.1 n (samplePrefix U) globalMargin
    have hrisk := hS (samplePrefix U) hUE.2 N hCN σ hσ hscale M U globalMargin
    have hb : gibbsMarginRisk D (posterior (N := N) (r := r) c σ globalMargin B.computes U (samplePrefix U))
        (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤ ε := by linarith
    refine ⟨hb,?_⟩
    letI := posterior_probability hd B hCN hc hσ hscale globalMargin U (samplePrefix U)
    have hcfd := margin_confidence_bound D (posterior (N := N) (r := r) c σ globalMargin B.computes U (samplePrefix U))
      (fun x => labelReal (B.computes x)) (networkOutput Real.tanh)
      (fun x => (continuous_networkOutput tanh_continuous x).measurable) (1/4)
      (by norm_num : (2/3:ℝ) < 1) hb
    convert hcfd using 1 <;> ring

end NeuralGeneralization.RobustUnlabeled
