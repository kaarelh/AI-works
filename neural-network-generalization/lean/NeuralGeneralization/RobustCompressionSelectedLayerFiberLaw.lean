import NeuralGeneralization.RobustCompressionSelectedLayerFiber
import NeuralGeneralization.RobustCompressionSelectedLayerRightReduction

/-! # Actual conditional next-state law of the selected layer comparison

The comparison's active/coefficient marginal is pushed through the common
state decoder. Its active marginal is the literal original-row pushforward,
so pulling it back recovers exactly the canonical layer kernel. The final
identity copies the untouched future and closes the right-marginal premise.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory Classical
namespace NeuralGeneralization.RobustCompressionCanonicalLayer
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompression RobustCompressionLayerComparison RobustCompressionSelectedBank
open RobustCompressionLayerGaussian CompressionSampling
set_option maxHeartbeats 300000
variable {d N m s r M q : ℕ} [NeZero N] [NeZero m]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)]
  [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "P" => ActivePrefix d N m s
local notation "E" => EuclideanSpace ℝ (Fin N)
local notation "Rows" => Fin N → E
local notation "HRows" => Fin N → EuclideanSpace ℝ (Fin q)
local notation "Base" => P × FutureWeights N r
local notation "S" => Fin m → Fin N
local notation "Coeff" => Fin N → Fin m → ℝ

/-- The actual active/coefficient marginal, with the original active H law. -/
theorem actualSelectedLayerKernel_active_coefficients
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    {a : ℝ} (ha : 0 ≤ a) (t T BH : ℝ) (i : Fin M) (θ : Base) :
    (actualSelectedLayerKernel (q:=q) Q b hb J hJ h hh a t T BH i θ).map
      (fun z => (actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2)) =
      ((selectedHQueryKernel (q:=q) (currentRowJoint (prefixCurrentLaw Q)).condKernel
        b hb J hJ t i).fst ⊗ₖ
          ((Kernel.const (Base × HRows) (iidSamples (uniformIndexLaw N) m)) ⊗ₖ
            ((selectedBankData b hb J hJ h hh).totalizedParameters a t T BH i).coefficientKernel)) θ := by
  have hρ : RobustCompression.parameterMap (currentRowDummyKernel Q)
      (selectedHObservation (q:=q) b J t i) (measurable_selectedHObservation b hb J hJ t i) =
      selectedHQueryKernel (q:=q) (currentRowJoint (prefixCurrentLaw Q)).condKernel b hb J hJ t i := by
    ext p : 1
    rw [RobustCompression.parameterMap_apply,currentRowDummyKernel,Kernel.prod_apply,Kernel.const_apply]
    exact selectedHQueryKernel_augmented_law _ b hb J hJ t i p
  exact fullSampledLayerCoupling_active_coefficients (currentRowDummyKernel Q)
    (selectedHObservation (q:=q) b J t i) (measurable_selectedHObservation b hb J hJ t i)
    (selectedHQueryKernel (q:=q) (currentRowJoint (prefixCurrentLaw Q)).condKernel b hb J hJ t i)
    ((selectedBankData b hb J hJ h hh).totalizedParameters a t T BH i)
    (SelectedBank.totalized_contractive b hb J hJ h hh ha i) hρ θ

/-- Decode the common new prefix by first conditioning on its actual active H. -/
theorem actualSelectedLayerKernel_next_via_H
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    {a : ℝ} (ha : 0 ≤ a) (t T BH BG : ℝ) (i : Fin M) (θ : Base) :
    (actualSelectedLayerKernel (q:=q) Q b hb J hJ h hh a t T BH i θ).map
      (fun z => selectedStateFromH φ b J a t T BH BG θ
        (actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2)) =
      (Kernel.sectR (selectedNextHKernel (q:=q) hφ b hb J hJ h hh a t T BH BG i) θ) ∘ₘ
        (selectedHQueryKernel (q:=q) (currentRowJoint (prefixCurrentLaw Q)).condKernel
          b hb J hJ t i).fst θ := by
  have hH : Measurable (actualActiveH (R:=N) (selectedMessageBasis (q:=q) b J θ) t) := by
    have hc := (measurable_actualActiveH_parameter (R:=N) (selectedMessageBasis (q:=q) b J)
      (measurable_selectedMessageBasis b hb J hJ) t).comp
      (show Measurable (fun g : Rows => (θ,g)) from measurable_prodMk_left)
    simpa only [Function.comp_def] using hc
  have ho : Measurable (fun z : (Rows × (Fin N → ℝ)) × (S × Coeff) =>
      (actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2)) :=
    (hH.comp measurable_fst.fst).prodMk measurable_snd
  have hd : Measurable (selectedStateFromH (q:=q) φ b J a t T BH BG θ) := by
    have hc := (measurable_selectedStateFromH hφ b hb J hJ a t T BH BG).comp
      (show Measurable (fun z : HRows × (S × Coeff) => (θ,z)) from measurable_prodMk_left)
    simpa only [Function.comp_def] using hc
  have hmap := Measure.map_map
    (μ := actualSelectedLayerKernel (q:=q) Q b hb J hJ h hh a t T BH i θ) hd ho
  simp only [Function.comp_def] at hmap
  rw [← hmap,actualSelectedLayerKernel_active_coefficients Q b hb J hJ h hh ha t T BH i θ]
  ext v hv
  rw [Measure.map_apply hd hv,Kernel.compProd_apply (hd hv),
    Measure.bind_apply hv (Kernel.sectR _ θ).aemeasurable]
  apply lintegral_congr
  intro H
  have hHd : Measurable (fun u : S × Coeff =>
      selectedStateFromH φ b J a t T BH BG θ (H,u)) := by
    have hc := hd.comp (show Measurable (fun u : S × Coeff => (H,u)) from measurable_prodMk_left)
    simpa only [Function.comp_def] using hc
  rw [Kernel.sectR_apply,selectedNextHKernel,RobustCompression.parameterMap_apply,
    Measure.map_apply hHd hv]
  rfl

/-- The actual fiber identity, including the unchanged future coordinate. -/
theorem actualSelectedLayerKernel_next_fiber
    (e : Fin M ≃ Cube d)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (heq : ∀ p i, h p i = activeHidden φ p (e i))
    {a : ℝ} (ha : 0 ≤ a) (t T BH BG : ℝ) (i : Fin M) (θ : Base) :
    (actualSelectedLayerKernel (q:=q) Q b hb J hJ h hh a t T BH i θ).map
      (fun z => (selectedStateFromH φ b J a t T BH BG θ
        (actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2),θ.2)) =
      (Kernel.sectR (directSelectedRowKernel (q:=q) J hJ
        (canonicalLayerKernel hφ b hb a t T BH BG)) θ) ∘ₘ
        (currentRowJoint (prefixCurrentLaw Q)).condKernel θ := by
  have hH : Measurable (actualActiveH (R:=N) (selectedMessageBasis (q:=q) b J θ) t) := by
    have hc := (measurable_actualActiveH_parameter (R:=N) (selectedMessageBasis (q:=q) b J)
      (measurable_selectedMessageBasis b hb J hJ) t).comp
      (show Measurable (fun g : Rows => (θ,g)) from measurable_prodMk_left)
    simpa only [Function.comp_def] using hc
  have hnext : Measurable (fun z : (Rows × (Fin N → ℝ)) × (S × Coeff) =>
      selectedStateFromH φ b J a t T BH BG θ
        (actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2)) := by
    have hm : Measurable (fun z : (Rows × (Fin N → ℝ)) × (S × Coeff) =>
        (θ,(actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2))) :=
      measurable_const.prodMk ((hH.comp measurable_fst.fst).prodMk measurable_snd)
    have hc := (measurable_selectedStateFromH hφ b hb J hJ a t T BH BG).comp hm
    simpa only [Function.comp_def] using hc
  have hcopy : Measurable (fun p : ActivePrefix d N m (s+1) => (p,θ.2)) :=
    measurable_prodMk_right
  have hmap := Measure.map_map
    (μ := actualSelectedLayerKernel (q:=q) Q b hb J hJ h hh a t T BH i θ) hcopy hnext
  simp only [Function.comp_def] at hmap
  rw [← hmap,
    actualSelectedLayerKernel_next_via_H Q hφ b hb J hJ h hh ha t T BH BG i θ,
    selectedHQueryKernel_fst,activeHKernel_apply,
    kernel_comp_map_eq _ _ _ hH,Measure.map_comp _ _ hcopy]
  congr 1
  ext g : 1
  rw [Kernel.map_apply _ hcopy,Kernel.comap_apply,Kernel.sectR_apply,
    selectedNextHKernel_actual e hφ b hb J hJ h hh heq a t T BH BG i θ g,
    Kernel.sectR_apply,directSelectedRowKernel_apply]
  rfl

/-- Closed actual right marginal: no fiber-law or entropy oracle remains. -/
theorem selectedLayerJoint_right
    (e : Fin M ≃ Cube d)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (heq : ∀ p i, h p i = activeHidden φ p (e i))
    {a : ℝ} (ha : 0 ≤ a) (t T BH BG : ℝ) (i : Fin M) :
    (selectedLayerJoint (q:=q) Q φ b hb J hJ h hh a t T BH BG i).map Prod.snd =
      canonicalStepLaw Q (selectedMessageKernel (q:=q) J hJ)
        (canonicalLayerKernel hφ b hb a t T BH BG) := by
  apply selectedLayerJoint_right_of_fiber_identity Q hφ b hb J hJ h hh a t T BH BG i
  exact actualSelectedLayerKernel_next_fiber e Q hφ b hb J hJ h hh heq ha t T BH BG i

end NeuralGeneralization.RobustCompressionCanonicalLayer
