import NeuralGeneralization.RobustStatisticsCoupling
import Mathlib.Probability.Kernel.Disintegration.StandardBorel
import Mathlib.Probability.Kernel.Composition.MeasureCompProd

/-!
# Gluing compression comparisons without losing their original history

A comparison for a new layer is initially constructed using its canonical
state marginal.  The preceding comparison may retain additional original
history.  Disintegration joins these two laws along their common state
marginal.  Both required joint laws are preserved exactly; in particular,
no independence from the discarded history is assumed.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustCompression

variable {U V W : Type*}
  [MeasurableSpace U] [MeasurableSpace V] [MeasurableSpace W]

/-- Transporting the exposed coordinate of a kernel product commutes with
first mapping the base law.  The kernel may depend arbitrarily on the exposed
coordinate. -/
theorem map_compProd_comap (μ : Measure U) [SFinite μ]
    (κ : Kernel V W) [IsSFiniteKernel κ] (f : U → V) (hf : Measurable f) :
    (μ ⊗ₘ κ.comap f hf).map (fun p => (f p.1, p.2)) = μ.map f ⊗ₘ κ := by
  ext s hs
  have hmap : Measurable (fun p : U × W => (f p.1, p.2)) :=
    (hf.comp measurable_fst).prodMk measurable_snd
  rw [Measure.map_apply hmap hs,
    Measure.compProd_apply (hs.preimage hmap),
    Measure.compProd_apply hs,
    lintegral_map (Kernel.measurable_kernel_prodMk_left hs) hf]
  rfl

section CommonMarginal

variable [StandardBorelSpace W] [Nonempty W]

/-- The next coordinate is drawn from its conditional law given the shared
state; the complete old pair is retained unchanged. -/
def glue (P : Measure (U × V)) (R : Measure (V × W)) [IsFiniteMeasure R] :
    Measure ((U × V) × W) :=
  P ⊗ₘ R.condKernel.comap Prod.snd measurable_snd

instance glue_probability (P : Measure (U × V)) (R : Measure (V × W))
    [IsProbabilityMeasure P] [IsProbabilityMeasure R] :
    IsProbabilityMeasure (glue P R) := by
  unfold glue
  infer_instance

/-- The entire previous joint comparison is preserved, including all its
dependences on the original history. -/
theorem glue_old (P : Measure (U × V)) (R : Measure (V × W))
    [SFinite P] [IsFiniteMeasure R] : (glue P R).fst = P := by
  exact Measure.fst_compProd P _

/-- The newly constructed state/comparison joint law is also preserved. -/
theorem glue_new (P : Measure (U × V)) (R : Measure (V × W))
    [SFinite P] [IsFiniteMeasure R] (hshared : P.snd = R.fst) :
    (glue P R).map (fun p => (p.1.2, p.2)) = R := by
  rw [glue, map_compProd_comap]
  change P.snd ⊗ₘ R.condKernel = R
  rw [hshared, Measure.disintegrate R R.condKernel]

/-- Common-marginal gluing as an existence theorem.  The three variables are
the complete old history, the shared canonical state, and the new comparison.
-/
theorem exists_gluing (P : Measure (U × V)) (R : Measure (V × W))
    [IsProbabilityMeasure P] [IsProbabilityMeasure R] (hshared : P.snd = R.fst) :
    ∃ T : Measure ((U × V) × W), IsProbabilityMeasure T ∧
      T.map Prod.fst = P ∧ T.map (fun p => (p.1.2, p.2)) = R := by
  exact ⟨glue P R, inferInstance, glue_old P R, glue_new P R hshared⟩

end CommonMarginal

section Observable

variable [StandardBorelSpace W] [Nonempty W]

/-- Lift a comparison of an observable to a comparison retaining the entire
original random field. -/
def liftObservable (μ : Measure U) (f : U → V) (hf : Measurable f)
    (R : Measure (V × W)) [IsFiniteMeasure R] : Measure (U × W) :=
  μ ⊗ₘ R.condKernel.comap f hf

instance liftObservable_probability (μ : Measure U) [IsProbabilityMeasure μ]
    (f : U → V) (hf : Measurable f) (R : Measure (V × W)) [IsFiniteMeasure R] :
    IsProbabilityMeasure (liftObservable μ f hf R) := by
  unfold liftObservable
  infer_instance

theorem liftObservable_fst (μ : Measure U) [SFinite μ]
    (f : U → V) (hf : Measurable f) (R : Measure (V × W)) [IsFiniteMeasure R] :
    (liftObservable μ f hf R).fst = μ := by
  exact Measure.fst_compProd μ _

theorem liftObservable_comparison (μ : Measure U) [SFinite μ]
    (f : U → V) (hf : Measurable f) (R : Measure (V × W)) [IsFiniteMeasure R]
    (hshared : μ.map f = R.fst) :
    (liftObservable μ f hf R).map (fun p => (f p.1, p.2)) = R := by
  rw [liftObservable, map_compProd_comap, hshared, Measure.disintegrate R R.condKernel]

theorem liftObservable_snd (μ : Measure U) [SFinite μ]
    (f : U → V) (hf : Measurable f) (R : Measure (V × W)) [IsFiniteMeasure R]
    (hshared : μ.map f = R.fst) : (liftObservable μ f hf R).snd = R.snd := by
  have hmap : Measurable (fun p : U × W => (f p.1, p.2)) :=
    (hf.comp measurable_fst).prodMk measurable_snd
  have h := congrArg (fun ρ : Measure (V × W) => ρ.map Prod.snd)
    (liftObservable_comparison μ f hf R hshared)
  rw [Measure.map_map measurable_snd hmap] at h
  exact h

/-- A quantitative event bound on the observable coupling survives lifting
with exactly the same probability, not merely an upper bound. -/
theorem liftObservable_event (μ : Measure U) [SFinite μ]
    (f : U → V) (hf : Measurable f) (R : Measure (V × W)) [IsFiniteMeasure R]
    (hshared : μ.map f = R.fst) (s : Set (V × W)) (hs : MeasurableSet s) :
    liftObservable μ f hf R ((fun p => (f p.1, p.2)) ⁻¹' s) = R s := by
  have hmap : Measurable (fun p : U × W => (f p.1, p.2)) :=
    (hf.comp measurable_fst).prodMk measurable_snd
  rw [← Measure.map_apply hmap hs, liftObservable_comparison μ f hf R hshared]

/-- Packaging the lift in the same concrete coupling type used by the
statistical theorem. -/
def liftObservableCoupling (μ : Measure U) [IsProbabilityMeasure μ]
    (ν : Measure W) (f : U → V) (hf : Measurable f)
    (π : RobustStatistics.ProbabilityCoupling (μ.map f) ν) :
    RobustStatistics.ProbabilityCoupling μ ν where
  joint := liftObservable μ f hf π.joint
  probability := inferInstance
  left := liftObservable_fst μ f hf π.joint
  right := by
    change (liftObservable μ f hf π.joint).snd = ν
    rw [liftObservable_snd μ f hf π.joint π.left.symm]
    exact π.right

theorem liftObservableCoupling_comparison (μ : Measure U) [IsProbabilityMeasure μ]
    (ν : Measure W) (f : U → V) (hf : Measurable f)
    (π : RobustStatistics.ProbabilityCoupling (μ.map f) ν) :
    (liftObservableCoupling μ ν f hf π).joint.map (fun p => (f p.1, p.2)) =
      π.joint :=
  liftObservable_comparison μ f hf π.joint π.left.symm

end Observable

section BothObservables

variable {X Y : Type*} [MeasurableSpace X] [MeasurableSpace Y]

def swapCoupling {μ : Measure U} {ν : Measure V}
    (π : RobustStatistics.ProbabilityCoupling μ ν) :
    RobustStatistics.ProbabilityCoupling ν μ where
  joint := π.joint.map Prod.swap
  probability := Measure.isProbabilityMeasure_map measurable_swap.aemeasurable
  left := by
    rw [Measure.map_map measurable_fst measurable_swap]
    exact π.right
  right := by
    rw [Measure.map_map measurable_snd measurable_swap]
    exact π.left

/-- Lift a coupling of two observables to both complete random fields.  This
is useful for scalar Gaussian comparisons of two correlated feature vectors:
all the other coordinates retain their prescribed joint marginal laws. -/
def liftBothObservables [StandardBorelSpace U] [Nonempty U]
    [StandardBorelSpace V] [Nonempty V]
    (μ : Measure U) [IsProbabilityMeasure μ]
    (ν : Measure V) [IsProbabilityMeasure ν]
    (f : U → X) (hf : Measurable f) (g : V → Y) (hg : Measurable g)
    (π : RobustStatistics.ProbabilityCoupling (μ.map f) (ν.map g))
    [StandardBorelSpace Y] [Nonempty Y] :
    RobustStatistics.ProbabilityCoupling μ ν :=
  swapCoupling (liftObservableCoupling ν μ g hg
    (swapCoupling (liftObservableCoupling μ (ν.map g) f hf π)))

theorem liftBothObservables_comparison [StandardBorelSpace U] [Nonempty U]
    [StandardBorelSpace V] [Nonempty V]
    (μ : Measure U) [IsProbabilityMeasure μ]
    (ν : Measure V) [IsProbabilityMeasure ν]
    (f : U → X) (hf : Measurable f) (g : V → Y) (hg : Measurable g)
    (π : RobustStatistics.ProbabilityCoupling (μ.map f) (ν.map g))
    [StandardBorelSpace Y] [Nonempty Y] :
    (liftBothObservables μ ν f hf g hg π).joint.map
      (fun p => (f p.1, g p.2)) = π.joint := by
  let π₁ := liftObservableCoupling μ (ν.map g) f hf π
  let π₂ := liftObservableCoupling ν μ g hg (swapCoupling π₁)
  have h₁ := liftObservableCoupling_comparison μ (ν.map g) f hf π
  have h₂ := liftObservableCoupling_comparison ν μ g hg (swapCoupling π₁)
  have hmap : Measurable (fun p : U × Y => (f p.1, p.2)) :=
    (hf.comp measurable_fst).prodMk measurable_snd
  have hmap' : Measurable (fun p : Y × U => (f p.2, p.1)) :=
    (hf.comp measurable_snd).prodMk measurable_fst
  have hmap₂ : Measurable (fun p : V × U => (g p.1, p.2)) :=
    (hg.comp measurable_fst).prodMk measurable_snd
  have hh := congrArg (fun ρ : Measure (Y × U) =>
    ρ.map (fun p => (f p.2, p.1))) h₂
  change (π₂.joint.map (fun p => (g p.1, p.2))).map _ =
    (π₁.joint.map Prod.swap).map _ at hh
  rw [Measure.map_map hmap' hmap₂, Measure.map_map hmap' measurable_swap] at hh
  change π₂.joint.map (fun p => (f p.2, g p.1)) =
    π₁.joint.map (fun p => (f p.1, p.2)) at hh
  change π₁.joint.map (fun p => (f p.1, p.2)) = π.joint at h₁
  rw [h₁] at hh
  change (π₂.joint.map Prod.swap).map (fun p => (f p.1, g p.2)) = π.joint
  have hfinal : Measurable (fun p : U × V => (f p.1, g p.2)) :=
    (hf.comp measurable_fst).prodMk (hg.comp measurable_snd)
  rw [Measure.map_map hfinal measurable_swap]
  exact hh

end BothObservables

end NeuralGeneralization.RobustCompression
