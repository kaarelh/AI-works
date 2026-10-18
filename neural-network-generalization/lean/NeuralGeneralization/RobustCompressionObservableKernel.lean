import NeuralGeneralization.RobustCompressionGluingKernel

/-! # Measurable lifting of parameter-dependent observables to complete fields -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustCompression

variable {A U V W X Y : Type*} [MeasurableSpace A] [MeasurableSpace U]
  [MeasurableSpace V] [MeasurableSpace W] [MeasurableSpace X] [MeasurableSpace Y]

/-- Apply an observable that may depend on the external parameter. -/
def parameterMap (P : Kernel A U) (f : A × U → V) (_hf : Measurable f) : Kernel A V :=
  (Kernel.id ×ₖ P).map f

instance parameterMap_markov (P : Kernel A U) [IsMarkovKernel P]
    (f : A × U → V) (hf : Measurable f) : IsMarkovKernel (parameterMap P f hf) := by
  unfold parameterMap
  exact Kernel.IsMarkovKernel.map _ hf

theorem parameterMap_apply (P : Kernel A U) [IsSFiniteKernel P]
    (f : A × U → V) (hf : Measurable f) (a : A) :
    parameterMap P f hf a = (P a).map (fun u => f (a, u)) := by
  rw [parameterMap, Kernel.map_apply _ hf, Kernel.prod_apply, Kernel.id_apply,
    Measure.dirac_prod, Measure.map_map hf measurable_prodMk_left]
  rfl

variable [StandardBorelSpace V] [StandardBorelSpace W] [Nonempty W]

def liftObservableKernel (P : Kernel A U) (f : A × U → V) (hf : Measurable f)
    (R : Kernel A (V × W)) [IsFiniteKernel R] : Kernel A (U × W) :=
  P ⊗ₖ R.condKernel.comap (fun p : A × U => (p.1, f p))
    (measurable_fst.prodMk hf)

instance liftObservableKernel_markov (P : Kernel A U) [IsMarkovKernel P]
    (f : A × U → V) (hf : Measurable f)
    (R : Kernel A (V × W)) [IsFiniteKernel R] :
    IsMarkovKernel (liftObservableKernel P f hf R) := by
  unfold liftObservableKernel
  infer_instance

theorem liftObservableKernel_fst (P : Kernel A U) [IsSFiniteKernel P]
    (f : A × U → V) (hf : Measurable f)
    (R : Kernel A (V × W)) [IsFiniteKernel R] :
    (liftObservableKernel P f hf R).fst = P :=
  Kernel.fst_compProd P _

theorem liftObservableKernel_comparison (P : Kernel A U) [IsSFiniteKernel P]
    (f : A × U → V) (hf : Measurable f)
    (R : Kernel A (V × W)) [IsFiniteKernel R]
    (hshared : parameterMap P f hf = R.fst) (a : A) :
    (liftObservableKernel P f hf R a).map (fun p => (f (a, p.1), p.2)) = R a := by
  have hfa : Measurable (fun u => f (a, u)) := hf.comp measurable_prodMk_left
  have hsect : Kernel.sectR
      (R.condKernel.comap (fun p : A × U => (p.1, f p)) (measurable_fst.prodMk hf)) a =
      (Kernel.sectR R.condKernel a).comap (fun u => f (a, u)) hfa := by
    ext u s hs
    rfl
  rw [liftObservableKernel, Kernel.compProd_apply_eq_compProd_sectR, hsect]
  have heq := map_compProd_comap (P a) (Kernel.sectR R.condKernel a)
    (fun u => f (a, u)) hfa
  refine heq.trans ?_
  have hm := congrArg (fun K : Kernel A V => K a) hshared
  rw [parameterMap_apply] at hm
  rw [hm, ← Kernel.compProd_apply_eq_compProd_sectR, Kernel.disintegrate R R.condKernel]

theorem liftObservableKernel_snd (P : Kernel A U) [IsSFiniteKernel P]
    (f : A × U → V) (hf : Measurable f)
    (R : Kernel A (V × W)) [IsFiniteKernel R]
    (hshared : parameterMap P f hf = R.fst) :
    (liftObservableKernel P f hf R).snd = R.snd := by
  ext a : 1
  have hmap : Measurable (fun p : U × W => (f (a, p.1), p.2)) :=
    ((hf.comp measurable_prodMk_left).comp measurable_fst).prodMk measurable_snd
  have hh := congrArg (fun μ : Measure (V × W) => μ.map Prod.snd)
    (liftObservableKernel_comparison P f hf R hshared a)
  rw [Measure.map_map measurable_snd hmap] at hh
  exact hh

section Both

variable [StandardBorelSpace U] [Nonempty U]
  [StandardBorelSpace X] [StandardBorelSpace Y] [Nonempty Y]

/-- A jointly measurable lift of both scalar observables to their complete,
possibly correlated original fields. -/
def liftBothObservablesKernel
    (P : Kernel A U) [IsMarkovKernel P] (Q : Kernel A V) [IsMarkovKernel Q]
    (f : A × U → X) (hf : Measurable f) (g : A × V → Y) (hg : Measurable g)
    (R : Kernel A (X × Y)) [IsMarkovKernel R] : Kernel A (U × V) :=
  (liftObservableKernel Q g hg (liftObservableKernel P f hf R).swapRight).swapRight

instance liftBothObservablesKernel_markov
    (P : Kernel A U) [IsMarkovKernel P] (Q : Kernel A V) [IsMarkovKernel Q]
    (f : A × U → X) (hf : Measurable f) (g : A × V → Y) (hg : Measurable g)
    (R : Kernel A (X × Y)) [IsMarkovKernel R] :
    IsMarkovKernel (liftBothObservablesKernel P Q f hf g hg R) := by
  unfold liftBothObservablesKernel
  infer_instance

theorem liftBothObservablesKernel_fst
    (P : Kernel A U) [IsMarkovKernel P] (Q : Kernel A V) [IsMarkovKernel Q]
    (f : A × U → X) (hf : Measurable f) (g : A × V → Y) (hg : Measurable g)
    (R : Kernel A (X × Y)) [IsMarkovKernel R]
    (hleft : parameterMap P f hf = R.fst) (hright : parameterMap Q g hg = R.snd) :
    (liftBothObservablesKernel P Q f hf g hg R).fst = P := by
  rw [liftBothObservablesKernel, Kernel.fst_swapRight]
  have hshared : parameterMap Q g hg = (liftObservableKernel P f hf R).swapRight.fst := by
    rw [Kernel.fst_swapRight, liftObservableKernel_snd P f hf R hleft]
    exact hright
  rw [liftObservableKernel_snd Q g hg _ hshared, Kernel.snd_swapRight,
    liftObservableKernel_fst]

theorem liftBothObservablesKernel_snd
    (P : Kernel A U) [IsMarkovKernel P] (Q : Kernel A V) [IsMarkovKernel Q]
    (f : A × U → X) (hf : Measurable f) (g : A × V → Y) (hg : Measurable g)
    (R : Kernel A (X × Y)) [IsMarkovKernel R] :
    (liftBothObservablesKernel P Q f hf g hg R).snd = Q := by
  rw [liftBothObservablesKernel, Kernel.snd_swapRight, liftObservableKernel_fst]

theorem liftBothObservablesKernel_comparison
    (P : Kernel A U) [IsMarkovKernel P] (Q : Kernel A V) [IsMarkovKernel Q]
    (f : A × U → X) (hf : Measurable f) (g : A × V → Y) (hg : Measurable g)
    (R : Kernel A (X × Y)) [IsMarkovKernel R]
    (hleft : parameterMap P f hf = R.fst) (hright : parameterMap Q g hg = R.snd)
    (a : A) :
    (liftBothObservablesKernel P Q f hf g hg R a).map
      (fun p => (f (a, p.1), g (a, p.2))) = R a := by
  let R₁ := liftObservableKernel P f hf R
  let R₂ := liftObservableKernel Q g hg R₁.swapRight
  have hshared : parameterMap Q g hg = R₁.swapRight.fst := by
    rw [Kernel.fst_swapRight, liftObservableKernel_snd P f hf R hleft]
    exact hright
  have h₁ := liftObservableKernel_comparison P f hf R hleft a
  have h₂ := liftObservableKernel_comparison Q g hg R₁.swapRight hshared a
  have hmap : Measurable (fun p : Y × U => (f (a, p.2), p.1)) :=
    ((hf.comp measurable_prodMk_left).comp measurable_snd).prodMk measurable_fst
  have hmap₂ : Measurable (fun p : V × U => (g (a, p.1), p.2)) :=
    ((hg.comp measurable_prodMk_left).comp measurable_fst).prodMk measurable_snd
  have hh := congrArg (fun μ : Measure (Y × U) => μ.map (fun p => (f (a, p.2), p.1))) h₂
  change ((R₂ a).map (fun p => (g (a, p.1), p.2))).map _ =
    ((R₁ a).map Prod.swap).map _ at hh
  rw [Measure.map_map hmap hmap₂, Measure.map_map hmap measurable_swap] at hh
  change (R₂ a).map (fun p => (f (a, p.2), g (a, p.1))) =
    (R₁ a).map (fun p => (f (a, p.1), p.2)) at hh
  change (R₁ a).map (fun p => (f (a, p.1), p.2)) = R a at h₁
  rw [h₁] at hh
  change ((R₂ a).map Prod.swap).map (fun p => (f (a, p.1), g (a, p.2))) = R a
  have hfinal : Measurable (fun p : U × V => (f (a, p.1), g (a, p.2))) :=
    ((hf.comp measurable_prodMk_left).comp measurable_fst).prodMk
      ((hg.comp measurable_prodMk_left).comp measurable_snd)
  rw [Measure.map_map hfinal measurable_swap]
  exact hh

end Both

end NeuralGeneralization.RobustCompression
