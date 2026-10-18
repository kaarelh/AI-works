import NeuralGeneralization.RobustCompressionObservableKernel
import Mathlib.Probability.Kernel.Composition.Lemmas

/-!
# Reassembling a conditional comparison and lifting the complete original field

A comparison conditional on the revealed active coordinates is integrated
against their actual marginal. The resulting joint retains the entire original
active/residual law, and can then be lifted to the unexposed original field.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory
namespace NeuralGeneralization.RobustCompression

variable {A H Z Ξ Ω V W : Type*}
  [MeasurableSpace A] [MeasurableSpace H] [MeasurableSpace Z]
  [MeasurableSpace Ξ] [MeasurableSpace Ω] [MeasurableSpace V] [MeasurableSpace W]

/-- Mapping the second component of a kernel's conditional product. -/
theorem kernel_compProd_map (P : Kernel A H) [IsSFiniteKernel P]
    (τ : Kernel (A × H) V) [IsSFiniteKernel τ] (f : V → W) (hf : Measurable f) :
    P ⊗ₖ (τ.map f) = (P ⊗ₖ τ).map (Prod.map id f) := by
  ext a : 1
  rw [Kernel.compProd_apply_eq_compProd_sectR, Kernel.map_apply _ (by fun_prop),
    Kernel.compProd_apply_eq_compProd_sectR]
  have hs : Kernel.sectR (τ.map f) a = (Kernel.sectR τ a).map f := by
    ext h : 1
    simp only [Kernel.sectR_apply, Kernel.map_apply _ hf]
  rw [hs]
  exact Measure.compProd_map hf

/-- Integrate the conditional coupling and reassociate to expose the complete
original pair as the first marginal. -/
def conditionalJoint (ρ : Kernel A (H × Z)) (τ : Kernel (A × H) (Z × Ξ)) :
    Kernel A ((H × Z) × Ξ) :=
  (ρ.fst ⊗ₖ τ).map (fun p => ((p.1,p.2.1),p.2.2))

instance conditionalJoint_markov (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (τ : Kernel (A × H) (Z × Ξ)) [IsMarkovKernel τ] :
    IsMarkovKernel (conditionalJoint ρ τ) := by
  unfold conditionalJoint
  exact Kernel.IsMarkovKernel.map _ (by fun_prop)

variable [StandardBorelSpace H] [StandardBorelSpace Z] [Nonempty Z]

theorem conditionalJoint_fst (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (τ : Kernel (A × H) (Z × Ξ)) [IsMarkovKernel τ]
    (hleft : τ.fst = ρ.condKernel) : (conditionalJoint ρ τ).fst = ρ := by
  rw [Kernel.fst_eq, conditionalJoint, ← Kernel.map_comp_right _ (by fun_prop) measurable_fst]
  have he : (Prod.fst ∘ (fun p : H × (Z × Ξ) => ((p.1,p.2.1),p.2.2))) =
      Prod.map id Prod.fst := rfl
  rw [he, ← kernel_compProd_map _ τ Prod.fst measurable_fst, ← Kernel.fst_eq,
    hleft, Kernel.disintegrate ρ ρ.condKernel]

theorem conditionalJoint_active_candidate (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (τ : Kernel (A × H) (Z × Ξ)) [IsMarkovKernel τ] :
    (conditionalJoint ρ τ).map (fun p => (p.1.1,p.2)) = ρ.fst ⊗ₖ τ.snd := by
  rw [conditionalJoint, ← Kernel.map_comp_right _ (by fun_prop) (by fun_prop)]
  have he : ((fun p : (H × Z) × Ξ => (p.1.1,p.2)) ∘
      (fun p : H × (Z × Ξ) => ((p.1,p.2.1),p.2.2))) = Prod.map id Prod.snd := rfl
  rw [he, ← kernel_compProd_map _ τ Prod.snd measurable_snd, ← Kernel.snd_eq]

variable [StandardBorelSpace Ξ] [Nonempty Ξ]

/-- The actual original-field comparison; no independence from the revealed
active coordinates is asserted or required. -/
def conditionalFieldLift (κ : Kernel A Ω) (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (τ : Kernel (A × H) (Z × Ξ)) [IsMarkovKernel τ] : Kernel A (Ω × Ξ) :=
  liftObservableKernel κ o ho (conditionalJoint ρ τ)

instance conditionalFieldLift_markov (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (τ : Kernel (A × H) (Z × Ξ)) [IsMarkovKernel τ] :
    IsMarkovKernel (conditionalFieldLift κ o ho ρ τ) := by
  unfold conditionalFieldLift
  infer_instance

theorem conditionalFieldLift_fst (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (τ : Kernel (A × H) (Z × Ξ)) [IsMarkovKernel τ] :
    (conditionalFieldLift κ o ho ρ τ).fst = κ :=
  liftObservableKernel_fst κ o ho (conditionalJoint ρ τ)

theorem conditionalFieldLift_observables (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (τ : Kernel (A × H) (Z × Ξ)) [IsMarkovKernel τ]
    (hρ : parameterMap κ o ho = ρ) (hleft : τ.fst = ρ.condKernel) (a : A) :
    (conditionalFieldLift κ o ho ρ τ a).map (fun p => (o (a,p.1),p.2)) =
      conditionalJoint ρ τ a := by
  apply liftObservableKernel_comparison
  rw [conditionalJoint_fst ρ τ hleft]
  exact hρ

theorem conditionalFieldLift_active_candidate (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (τ : Kernel (A × H) (Z × Ξ)) [IsMarkovKernel τ]
    (hρ : parameterMap κ o ho = ρ) (hleft : τ.fst = ρ.condKernel) (a : A) :
    (conditionalFieldLift κ o ho ρ τ a).map (fun p => ((o (a,p.1)).1,p.2)) =
      (ρ.fst ⊗ₖ τ.snd) a := by
  have hh := congrArg (fun μ : Measure ((H × Z) × Ξ) => μ.map (fun p => (p.1.1,p.2)))
    (conditionalFieldLift_observables κ o ho ρ τ hρ hleft a)
  rw [Measure.map_map (by fun_prop) (by
    exact ((ho.comp measurable_prodMk_left).comp measurable_fst).prodMk measurable_snd)] at hh
  have he := congrArg (fun K : Kernel A (H × Ξ) => K a) (conditionalJoint_active_candidate ρ τ)
  rw [Kernel.map_apply _ (by fun_prop)] at he
  exact hh.trans he

end NeuralGeneralization.RobustCompression
