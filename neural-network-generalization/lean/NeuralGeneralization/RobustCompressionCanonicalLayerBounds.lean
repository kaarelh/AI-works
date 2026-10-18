import NeuralGeneralization.RobustCompressionCanonicalLayer

/-! # Bounded coefficients under the actual canonical layer law

All generated rows satisfy the bound, including bad source banks. The absorbing
abort then preserves this support assertion without requiring any probability
bound on the unsuccessful branch.
-/
noncomputable section
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.RobustCompressionCanonicalLayer
open ConcreteModel RobustCompressionInduction RobustCompressionReconstruction

variable {d N m s q : ℕ} {I : Type*} [Fintype I]
  [MeasurableSpace (QueryMessage I q)] [MeasurableSingletonClass (QueryMessage I q)]

theorem payloadBounded_mono {B B' : ℝ} (hB : B ≤ B')
    (p : PrefixPayload d N m s) (hp : payloadBounded d N m B s p) :
    payloadBounded d N m B' s p := by
  cases s with
  | zero => exact fun i j => (hp i j).trans hB
  | succ s => exact ⟨fun i => (hp.1 i).trans hB,fun i j => (hp.2 i j).trans hB⟩

theorem activePrefixBounded_mono {B B' : ℝ} (hB : B ≤ B')
    (p : ActivePrefix d N m s) (hp : activePrefixBounded B p) :
    activePrefixBounded B' p :=
  fun hlive => payloadBounded_mono hB p.2 (hp hlive)

theorem measurableSet_payloadBounded (B : ℝ) (s : ℕ) :
    MeasurableSet {p : PrefixPayload d N m s | payloadBounded d N m B s p} := by
  cases s with
  | zero =>
    change MeasurableSet {p : Fin N → Fin (d+1) → ℝ | ∀ i j, |p i j| ≤ B}
    simp only [Set.setOf_forall]
    exact MeasurableSet.iInter fun i => MeasurableSet.iInter fun j =>
      measurableSet_le (by fun_prop) measurable_const
  | succ s =>
    change MeasurableSet {p : Weights d m s × (Fin N → Fin m → ℝ) |
      (∀ i, |p.1 i| ≤ B) ∧ ∀ i j, |p.2 i j| ≤ B}
    simp only [Set.setOf_and,Set.setOf_forall]
    exact (MeasurableSet.iInter fun i => measurableSet_le (by fun_prop) measurable_const).inter
      (MeasurableSet.iInter fun i => MeasurableSet.iInter fun j =>
        measurableSet_le (by fun_prop) measurable_const)

theorem measurableSet_activePrefixBounded (B : ℝ) :
    MeasurableSet {p : ActivePrefix d N m s | activePrefixBounded B p} := by
  change MeasurableSet {p : ActivePrefix d N m s |
    p.1 = true → payloadBounded d N m B s p.2}
  simp only [imp_iff_not_or]
  exact (measurableSet_eq_fun measurable_fst measurable_const).compl.union
    ((measurableSet_payloadBounded B s).preimage measurable_snd)

theorem canonicalDrawKernel_bounded [NeZero N]
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    {a t T BH BG B : ℝ} (hm : 0 < m) (ha : 0 ≤ a) (ht : |t| ≤ 1)
    (hT : 0 ≤ T) (hBH : 0 ≤ BH) (hBG : 0 ≤ BG) (hB : BH*T+BG ≤ B)
    (z : CanonicalLayerInput d N m s q I) :
    ∀ᵐ draw ∂canonicalDrawKernel b hb a t T BH BG z, ∀ i j, |draw.2 i j| ≤ B := by
  rw [canonicalDrawKernel, Kernel.comap_apply, reconstructionKernel_apply]
  apply (ae_map_iff ((measurable_reconstructionDraw a t T BH BG).comp
    measurable_prodMk_left).aemeasurable ?_).mpr
  · exact Filter.Eventually.of_forall fun ω i j =>
      (reconstructionDraw_bound_simple hm ha ht hT hBH hBG _ ω i j).trans hB
  · simp only [Set.setOf_forall]
    exact MeasurableSet.iInter fun i => MeasurableSet.iInter fun j =>
      measurableSet_le (by fun_prop) measurable_const

theorem canonicalLayerKernel_bounded [NeZero N] {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    {a t T BH BG B : ℝ} (hm : 0 < m) (ha : 0 ≤ a) (ht : |t| ≤ 1)
    (hT : 0 ≤ T) (hBH : 0 ≤ BH) (hBG : 0 ≤ BG) (hB : 0 ≤ B)
    (hbound : BH*T+BG ≤ B) (z : CanonicalLayerInput d N m s q I)
    (hz : activePrefixBounded B z.1.1) :
    ∀ᵐ p ∂canonicalLayerKernel hφ b hb a t T BH BG z, activePrefixBounded B p := by
  rw [canonicalLayerKernel, RobustCompression.parameterMap_apply]
  have hm' : Measurable (fun z : CanonicalLayerInput d N m s q I × ReconstructionOutput N m =>
      stepActive z.1.1.1 z.2 (canonicalLayerSuccess φ b a T z.1 z.2)) :=
    measurable_stepActive _ _ _ (by fun_prop) (by fun_prop)
      (measurable_canonicalLayerSuccess hφ b hb a T)
  apply (ae_map_iff (hm'.comp measurable_prodMk_left).aemeasurable
    (measurableSet_activePrefixBounded B)).mpr
  filter_upwards [canonicalDrawKernel_bounded b hb hm ha ht hT hBH hBG hbound z] with draw hdraw
  exact stepActive_bounded hB z.1.1 draw _ hz hdraw

end NeuralGeneralization.RobustCompressionCanonicalLayer
