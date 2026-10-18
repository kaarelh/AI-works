import NeuralGeneralization.RobustCouplingKernel
import NeuralGeneralization.RobustEntropyKernel
import Mathlib.Probability.Kernel.Composition.IntegralCompProd
import Mathlib.Probability.Kernel.Composition.Lemmas

/-!
# Sequential extension of couplings

Appending one scalar conditional coupling retains the full original prefix
law, and the reference coordinate remains independent of its entire paired
past. This is the structural step needed to recover the factor 1/N in
layerwise entropy compression.
-/

noncomputable section
open MeasureTheory ProbabilityTheory Set InformationTheory
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustCoupling

variable {Z A Y B : Type*} [MeasurableSpace Z] [MeasurableSpace A]
  [MeasurableSpace Y] [MeasurableSpace B]

/-- Push a joint measure through one map on each coordinate, when the mapped
conditional law depends only on the mapped first coordinate. -/
theorem map_compProd_pair (π : Measure Z) [IsProbabilityMeasure π]
    (κ : Kernel Z Y) [IsMarkovKernel κ] (η : Kernel A B) [IsMarkovKernel η]
    (f : Z → A) (g : Y → B) (hf : Measurable f) (hg : Measurable g)
    (hmap : ∀ z, (κ z).map g = η (f z)) :
    (π ⊗ₘ κ).map (fun p => (f p.1, g p.2)) = (π.map f) ⊗ₘ η := by
  ext s hs
  have hpair : Measurable (fun p : Z × Y => (f p.1, g p.2)) :=
    (hf.comp measurable_fst).prodMk (hg.comp measurable_snd)
  rw [Measure.map_apply hpair hs, Measure.compProd_apply (hs.preimage hpair),
    Measure.compProd_apply hs]
  rw [lintegral_map (Kernel.measurable_kernel_prodMk_left hs) hf]
  apply lintegral_congr
  intro z
  have hh := congrArg (fun m : Measure B => m (Prod.mk (f z) ⁻¹' s)) (hmap z)
  rw [Measure.map_apply hg (hs.preimage measurable_prodMk_left)] at hh
  exact hh

variable (π : Measure (A × B)) [IsProbabilityMeasure π]
  (κ : Kernel A ℝ) [IsMarkovKernel κ] (G : Measure ℝ) [IsProbabilityMeasure G]

def appendCoupling : Measure ((A × ℝ) × (B × ℝ)) :=
  (π ⊗ₘ ((entropyCouplingKernel κ (Kernel.const A G)).comap Prod.fst measurable_fst)).map
    (fun p => ((p.1.1, p.2.1), (p.1.2, p.2.2)))

instance appendCoupling_isProbability : IsProbabilityMeasure (appendCoupling π κ G) := by
  unfold appendCoupling
  apply Measure.isProbabilityMeasure_map
  fun_prop

theorem appendCoupling_fst :
    (appendCoupling π κ G).map Prod.fst = (π.map Prod.fst) ⊗ₘ κ := by
  have hm : Measurable (fun p : (A × B) × (ℝ × ℝ) =>
      ((p.1.1, p.2.1), (p.1.2, p.2.2))) := by fun_prop
  rw [appendCoupling, Measure.map_map measurable_fst hm]
  exact map_compProd_pair π
    ((entropyCouplingKernel κ (Kernel.const A G)).comap Prod.fst measurable_fst)
    κ Prod.fst Prod.fst measurable_fst measurable_fst
    (fun p => entropyCouplingKernel_fst κ (Kernel.const A G) p.1)

theorem appendCoupling_snd :
    (appendCoupling π κ G).map Prod.snd = (π.map Prod.snd).prod G := by
  have hm : Measurable (fun p : (A × B) × (ℝ × ℝ) =>
      ((p.1.1, p.2.1), (p.1.2, p.2.2))) := by fun_prop
  rw [appendCoupling, Measure.map_map measurable_snd hm, ← Measure.compProd_const]
  exact map_compProd_pair π
    ((entropyCouplingKernel κ (Kernel.const A G)).comap Prod.fst measurable_fst)
    (Kernel.const B G) Prod.snd Prod.snd measurable_snd measurable_snd
    (fun p => entropyCouplingKernel_snd κ (Kernel.const A G) p.1)

/-- The scalar mismatch bound in extended nonnegative form, including infinite KL. -/
theorem entropyCoupling_disagreement_le_ennreal
    (μ ν : Measure ℝ) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    {s : ℝ} (hs : 0 < s) :
    entropyCoupling μ ν {p | p.1 ≠ p.2} ≤
      ENNReal.ofReal (1 / s) * klDiv μ ν + ENNReal.ofReal s := by
  by_cases hk : klDiv μ ν = ⊤
  · rw [hk, ENNReal.mul_top (ENNReal.ofReal_pos.mpr (one_div_pos.mpr hs)).ne']
    simp
  · have hh := entropyCoupling_disagreement_le_parameter μ ν hk hs
    change (entropyCoupling μ ν {p | p.1 ≠ p.2}).toReal ≤ _ at hh
    apply ENNReal.toReal_le_toReal (measure_ne_top _ _) (by finiteness) |>.mp
    rw [ENNReal.toReal_add (by finiteness) (by finiteness), ENNReal.toReal_mul,
      ENNReal.toReal_ofReal (one_div_pos.mpr hs).le, ENNReal.toReal_ofReal hs.le]
    simpa [div_eq_mul_inv, mul_comm] using hh

variable {Θ : Type*} [MeasurableSpace Θ]

/-- Measurable family version of one-coordinate coupling extension. -/
def appendCouplingKernel (piK : Kernel Θ (A × B)) [IsMarkovKernel piK]
    (κ : Kernel (Θ × A) ℝ) [IsMarkovKernel κ]
    (G : Measure ℝ) [IsProbabilityMeasure G] : Kernel Θ ((A × ℝ) × (B × ℝ)) :=
  (piK ⊗ₖ ((entropyCouplingKernel κ (Kernel.const (Θ × A) G)).comap
    (fun p : Θ × (A × B) => (p.1, p.2.1)) (by fun_prop))).map
    (fun p => ((p.1.1, p.2.1), (p.1.2, p.2.2)))

instance appendCouplingKernel_markov (piK : Kernel Θ (A × B)) [IsMarkovKernel piK]
    (κ : Kernel (Θ × A) ℝ) [IsMarkovKernel κ]
    (G : Measure ℝ) [IsProbabilityMeasure G] :
    IsMarkovKernel (appendCouplingKernel piK κ G) := by
  unfold appendCouplingKernel
  apply Kernel.IsMarkovKernel.map
  fun_prop

theorem appendCouplingKernel_apply (piK : Kernel Θ (A × B)) [IsMarkovKernel piK]
    (κ : Kernel (Θ × A) ℝ) [IsMarkovKernel κ]
    (G : Measure ℝ) [IsProbabilityMeasure G] (θ : Θ) :
    appendCouplingKernel piK κ G θ = appendCoupling (piK θ) (κ.sectR θ) G := by
  rw [appendCouplingKernel, Kernel.map_apply _ (by fun_prop),
    Kernel.compProd_apply_eq_compProd_sectR]
  unfold appendCoupling
  congr 2
  ext p
  simp only [Kernel.sectR_apply, Kernel.comap_apply, entropyCouplingKernel_apply,
    Kernel.const_apply]

def scalarMismatch (p : ℝ × ℝ) : ℝ≥0∞ :=
  {p : ℝ × ℝ | p.1 ≠ p.2}.indicator (fun _ => 1) p

@[fun_prop] theorem measurable_scalarMismatch : Measurable scalarMismatch := by
  exact measurable_const.indicator (measurableSet_eq_fun measurable_fst measurable_snd).compl

theorem lintegral_scalarMismatch (μ : Measure (ℝ × ℝ)) :
    ∫⁻ p, scalarMismatch p ∂μ = μ {p | p.1 ≠ p.2} := by
  exact lintegral_indicator_one (measurableSet_eq_fun measurable_fst measurable_snd).compl

/-- The cost added by one coordinate is charged to its conditional KL. -/
theorem lintegral_appendCoupling_cost_le
    (F : A × B → ℝ≥0∞) (hF : Measurable F) {s : ℝ} (hs : 0 < s) :
    (∫⁻ p, F (p.1.1, p.2.1) + scalarMismatch (p.1.2, p.2.2)
      ∂appendCoupling π κ G) ≤
      (∫⁻ p, F p ∂π) + ENNReal.ofReal (1 / s) *
        (∫⁻ a, klDiv (κ a) G ∂π.map Prod.fst) + ENNReal.ofReal s := by
  have hm : Measurable (fun p : (A × B) × (ℝ × ℝ) =>
      ((p.1.1, p.2.1), (p.1.2, p.2.2))) := by fun_prop
  rw [appendCoupling, lintegral_map (by fun_prop) hm,
    Measure.lintegral_compProd (by fun_prop)]
  simp only [Kernel.comap_apply, entropyCouplingKernel_apply, Kernel.const_apply]
  simp only [lintegral_add_left measurable_const, lintegral_const, measure_univ, mul_one]
  change (∫⁻ p, F p + (∫⁻ u, scalarMismatch u ∂entropyCoupling (κ p.1) G) ∂π) ≤ _
  simp_rw [lintegral_scalarMismatch]
  have hmeas : Measurable (fun a => klDiv (κ a) G) :=
    NeuralGeneralization.RobustEntropy.measurable_kernel_klDiv κ (Kernel.const A G)
  have hmeas2 : Measurable (fun p : A × B => klDiv (κ p.1) G) :=
    hmeas.comp measurable_fst
  have hmeas3 : Measurable (fun p : A × B => ENNReal.ofReal (1 / s) * klDiv (κ p.1) G) :=
    measurable_const.mul hmeas2
  calc
    _ ≤ ∫⁻ p, F p + (ENNReal.ofReal (1 / s) * klDiv (κ p.1) G + ENNReal.ofReal s) ∂π := by
      apply lintegral_mono
      intro p
      exact add_le_add le_rfl (entropyCoupling_disagreement_le_ennreal (κ p.1) G hs)
    _ = _ := by
      rw [lintegral_add_left hF, lintegral_add_left hmeas3,
        lintegral_const_mul _ hmeas2, lintegral_const,
        measure_univ, mul_one, lintegral_map hmeas measurable_fst]
      exact (add_assoc _ _ _).symm

end NeuralGeneralization.RobustCoupling
