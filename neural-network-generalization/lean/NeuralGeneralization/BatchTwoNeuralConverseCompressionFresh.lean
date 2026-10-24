import NeuralGeneralization.BatchTwoNeuralConverseCompressionVirtual
import Mathlib.MeasureTheory.Integral.Pi
import Mathlib.MeasureTheory.Integral.Prod

/-! Conditional fresh-source estimates under the actual full list law. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical Set MeasureTheory ProbabilityTheory
open ConcreteModel CompressionSampling

/-- A uniform bound after replacing one list integrates to the same bound under
all the independently sampled layer lists. -/
theorem allLayerLists_fresh_bound (N M r : ℕ) [NeZero N] (s : Fin (r+1))
    (E : Set (Fin (r+1) → Fin M → Fin N)) {p : ℝ} (hp : 0≤p)
    (hsections : ∀ I, (iidSamples (uniformIndexLaw N) M).real
      {J | Function.update I s J ∈ E}≤p) :
    (allLayerLists N M r).real E≤p := by
  let μ := iidSamples (uniformIndexLaw N) M
  let ν := Measure.pi (fun _ : Fin r => μ)
  let insert := fun z : (Fin r → Fin M → Fin N) × (Fin M → Fin N) => s.insertNth (α := fun _ => Fin M → Fin N) z.2 z.1
  have hpres : MeasurePreserving insert (ν.prod μ) (allLayerLists N M r) := by
    have h := (measurePreserving_piFinSuccAbove (fun _ : Fin (r+1) => μ) s).symm
    have hc := h.comp (Measure.measurePreserving_swap (μ := ν) (ν := μ))
    convert hc using 1
    · funext z
      simp only [Function.comp_apply,MeasurableEquiv.piFinSuccAbove_symm_apply,Fin.insertNthEquiv,Equiv.coe_fn_mk]
      rfl
    · rfl
  have hm : (ν.prod μ).real (insert ⁻¹' E)=(allLayerLists N M r).real E :=
    hpres.measureReal_preimage (Set.toFinite E).measurableSet.nullMeasurableSet
  rw [←hm]
  apply independent_row_mixture_le ν μ (insert ⁻¹' E) (Set.toFinite _).measurableSet hp
  intro rest
  let j0 : Fin M → Fin N := fun _ => ⟨0,NeZero.pos N⟩
  have hh := hsections (s.insertNth (α := fun _ => Fin M → Fin N) j0 rest)
  simpa only [Fin.update_insertNth,Set.preimage,Set.mem_setOf_eq,insert,μ] using hh

end
end NeuralGeneralization.BatchTwoNeuralConverse
