import NeuralGeneralization.RobustCompressionGluing
import Mathlib.MeasureTheory.Constructions.Polish.Basic

/-! # Jointly measurable gluing for layer-by-layer comparisons

The coupling is a Markov kernel in all previously exposed parameters.  This
version is needed when later transitions depend on an already random prefix;
pointwise choices of couplings would not establish that measurability.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustCompression

variable {A U V W : Type*} [MeasurableSpace A] [MeasurableSpace U]
  [MeasurableSpace V] [MeasurableSpace W]

theorem kernel_map_compProd_comap (P : Kernel A U) [IsSFiniteKernel P]
    (κ : Kernel (A × V) W) [IsSFiniteKernel κ] (f : U → V) (hf : Measurable f) :
    (P ⊗ₖ κ.comap (fun p : A × U => (p.1, f p.2))
      (measurable_fst.prodMk (hf.comp measurable_snd))).map
        (fun p : U × W => (f p.1, p.2)) = (P.map f) ⊗ₖ κ := by
  have hmap : Measurable (fun p : U × W => (f p.1, p.2)) :=
    (hf.comp measurable_fst).prodMk measurable_snd
  ext a : 1
  rw [Kernel.map_apply _ hmap, Kernel.compProd_apply_eq_compProd_sectR,
    Kernel.compProd_apply_eq_compProd_sectR, Kernel.map_apply _ hf]
  have hsect : Kernel.sectR
      (κ.comap (fun p : A × U => (p.1, f p.2))
        (measurable_fst.prodMk (hf.comp measurable_snd))) a =
        (Kernel.sectR κ a).comap f hf := by
    ext u s hs
    rfl
  rw [hsect, map_compProd_comap]

variable [StandardBorelSpace V] [StandardBorelSpace W] [Nonempty W]

/-- A measurable family of glued comparisons, retaining the old history.
Its conditional new law depends on the shared state and the external parameter.
-/
def glueKernel (P : Kernel A (U × V)) (R : Kernel A (V × W))
    [IsFiniteKernel R] : Kernel A ((U × V) × W) :=
  P ⊗ₖ R.condKernel.comap
    (fun p : A × (U × V) => (p.1, p.2.2))
    (measurable_fst.prodMk (measurable_snd.comp measurable_snd))

instance glueKernel_markov (P : Kernel A (U × V)) (R : Kernel A (V × W))
    [IsMarkovKernel P] [IsMarkovKernel R] : IsMarkovKernel (glueKernel P R) := by
  unfold glueKernel
  infer_instance

theorem glueKernel_old (P : Kernel A (U × V)) (R : Kernel A (V × W))
    [IsSFiniteKernel P] [IsFiniteKernel R] : (glueKernel P R).fst = P := by
  exact Kernel.fst_compProd P _

theorem glueKernel_new (P : Kernel A (U × V)) (R : Kernel A (V × W))
    [IsSFiniteKernel P] [IsFiniteKernel R] (hshared : P.snd = R.fst) :
    (glueKernel P R).map (fun p => (p.1.2, p.2)) = R := by
  rw [glueKernel, kernel_map_compProd_comap P R.condKernel Prod.snd measurable_snd]
  rw [← Kernel.snd_eq, hshared, Kernel.disintegrate R R.condKernel]

end NeuralGeneralization.RobustCompression
