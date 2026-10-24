import NeuralGeneralization.BatchTwoImprovedLayerJoint

/-! Exact right marginal of the sharp selected compression coupling. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory Classical
namespace NeuralGeneralization.BatchTwoImprovedSelectedBank
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompression RobustCompressionCanonicalLayer BatchTwoImprovedCanonicalLayer
open RobustCompressionLayerGaussian CompressionSampling
set_option maxHeartbeats 300000
variable {d N m s r M q : ℕ} [NeZero N]
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

/-- Decode the common new prefix by first conditioning on its actual active H. -/
theorem actualSharpLayerKernel_next_via_H (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH BG : ℝ) (i : Fin M) (θ : Base) :
    (actualSharpLayerKernel (q:=q) hq Q b hb J hJ h hh t BH i θ).map
      (fun z => sharpSelectedStateFromH b J t BH BG θ
        (actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2)) =
      (Kernel.sectR (sharpNextHKernel (q:=q) hq b hb J hJ h hh t BH BG i) θ) ∘ₘ
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
  have hd : Measurable (sharpSelectedStateFromH (q:=q) b J t BH BG θ) := by
    have hc := (measurable_sharpSelectedStateFromH b hb J hJ t BH BG).comp
      (show Measurable (fun z : HRows × (S × Coeff) => (θ,z)) from measurable_prodMk_left)
    simpa only [Function.comp_def] using hc
  have hmap := Measure.map_map
    (μ := actualSharpLayerKernel (q:=q) hq Q b hb J hJ h hh t BH i θ) hd ho
  simp only [Function.comp_def] at hmap
  rw [← hmap,actualSharpLayerKernel_active_coefficients hq Q b hb J hJ h hh t BH i θ]
  ext v hv
  rw [Measure.map_apply hd hv,Kernel.compProd_apply (hd hv),
    Measure.bind_apply hv (Kernel.sectR _ θ).aemeasurable]
  apply lintegral_congr
  intro H
  have hHd : Measurable (fun u : S × Coeff =>
      sharpSelectedStateFromH b J t BH BG θ (H,u)) := by
    have hc := hd.comp (show Measurable (fun u : S × Coeff => (H,u)) from measurable_prodMk_left)
    simpa only [Function.comp_def] using hc
  rw [Kernel.sectR_apply,sharpNextHKernel,RobustCompression.parameterMap_apply,
    Measure.map_apply hHd hv]
  rfl

/-- The actual fiber identity, including the unchanged future coordinate. -/
theorem actualSharpLayerKernel_next_fiber (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH BG : ℝ) (i : Fin M) (θ : Base) :
    (actualSharpLayerKernel (q:=q) hq Q b hb J hJ h hh t BH i θ).map
      (fun z => (sharpSelectedStateFromH b J t BH BG θ
        (actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2),θ.2)) =
      (Kernel.sectR (directSelectedRowKernel (q:=q) J hJ
        (sharpCanonicalLayerKernel (Nat.pos_of_neZero N) hq b hb t BH BG)) θ) ∘ₘ
        (currentRowJoint (prefixCurrentLaw Q)).condKernel θ := by
  have hH : Measurable (actualActiveH (R:=N) (selectedMessageBasis (q:=q) b J θ) t) := by
    have hc := (measurable_actualActiveH_parameter (R:=N) (selectedMessageBasis (q:=q) b J)
      (measurable_selectedMessageBasis b hb J hJ) t).comp
      (show Measurable (fun g : Rows => (θ,g)) from measurable_prodMk_left)
    simpa only [Function.comp_def] using hc
  have hnext : Measurable (fun z : (Rows × (Fin N → ℝ)) × (S × Coeff) =>
      sharpSelectedStateFromH b J t BH BG θ
        (actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2)) := by
    have hm : Measurable (fun z : (Rows × (Fin N → ℝ)) × (S × Coeff) =>
        (θ,(actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2))) :=
      measurable_const.prodMk ((hH.comp measurable_fst.fst).prodMk measurable_snd)
    have hc := (measurable_sharpSelectedStateFromH b hb J hJ t BH BG).comp hm
    simpa only [Function.comp_def] using hc
  have hcopy : Measurable (fun p : ActivePrefix d N m (s+1) => (p,θ.2)) :=
    measurable_prodMk_right
  have hmap := Measure.map_map
    (μ := actualSharpLayerKernel (q:=q) hq Q b hb J hJ h hh t BH i θ) hcopy hnext
  simp only [Function.comp_def] at hmap
  rw [← hmap,
    actualSharpLayerKernel_next_via_H hq Q b hb J hJ h hh t BH BG i θ,
    selectedHQueryKernel_fst,activeHKernel_apply,
    kernel_comp_map_eq _ _ _ hH,Measure.map_comp _ _ hcopy]
  congr 1
  ext g : 1
  rw [Kernel.map_apply _ hcopy,Kernel.comap_apply,Kernel.sectR_apply,
    sharpNextHKernel_actual hq b hb J hJ h hh t BH BG i θ g,
    Kernel.sectR_apply,directSelectedRowKernel_apply]
  rfl

/-- Both marginals are literal canonical state laws, even on aborted banks. -/
theorem sharpLayerJoint_right (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH BG : ℝ) (i : Fin M) :
    (sharpLayerJoint hq Q b hb J hJ h hh t BH BG i).map Prod.snd =
      canonicalStepLaw Q (selectedMessageKernel (q:=q) J hJ)
        (sharpCanonicalLayerKernel (Nat.pos_of_neZero N) hq b hb t BH BG) := by
  rw [sharpLayerJoint,Measure.map_map measurable_snd
    (measurable_sharpSelectedStatePair b hb J hJ t BH BG),
    canonicalStepLaw_eq_disintegrated_rows]
  apply map_compProd_eq_of_fiber_identity _ _ _ _ _
    (measurable_snd.comp (measurable_sharpSelectedStatePair b hb J hJ t BH BG))
  exact actualSharpLayerKernel_next_fiber hq Q b hb J hJ h hh t BH BG i

end NeuralGeneralization.BatchTwoImprovedSelectedBank
