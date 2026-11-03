import NeuralGeneralization.BatchTwoOnlineRawSampled

/-! Identification of the finite error-bit law with actual, independently
sampled posterior parameters. Posterior parameter spaces may be continuous. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
open Classical
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnlineRaw
open BatchTwoOnline SquaredSampling
variable {W : Type*} [MeasurableSpace W]

lemma measurable_errorBit (err : W → Prop) (he : MeasurableSet {w | err w}) :
    Measurable (fun w => decide (err w)) := by
  apply measurable_to_bool
  simpa only [Set.preimage,Set.mem_singleton_iff,decide_eq_true_eq] using he

lemma errorBit_law (Q : Measure W) [IsProbabilityMeasure Q]
    (err : W → Prop) (he : MeasurableSet {w | err w}) :
    Q.map (fun w => decide (err w)) =
      finiteWeightLaw (errorBitWeight (Q.real {w | err w}))
        (errorBitWeight_nonneg ⟨measureReal_nonneg,measureReal_le_one⟩) (errorBitWeight_sum _) := by
  apply Measure.ext_of_singleton
  intro b
  rw [Measure.map_apply (measurable_errorBit err he) (measurableSet_singleton b),finiteWeightLaw_singleton]
  have htrue : (fun w => decide (err w)) ⁻¹' {true} = {w | err w} := by ext w; simp
  have hfalse : (fun w => decide (err w)) ⁻¹' {false} = {w | err w}ᶜ := by ext w; simp
  cases b
  · simp only [hfalse,errorBitWeight,Bool.false_eq_true,if_false]
    rw [← probReal_compl_eq_one_sub he,measureReal_def,ENNReal.ofReal_toReal (measure_ne_top _ _)]
  · simp only [htrue,errorBitWeight,if_true,measureReal_def,ENNReal.ofReal_toReal (measure_ne_top _ _)]

variable {m : ℕ} {X : Type*}

def actualErrorCount (err : W → X → Prop) (π : Fin m → X) (draw : Fin m → W) : ℝ :=
  ∑ i,if err (draw i) (π i) then 1 else 0

/-- Exact probability of any sampled-count tail, obtained by pushing the
product of the actual posterior measures to its error indicators. -/
theorem actual_draw_tail_identity
    (Q : Fin m → Measure W) [∀ i,IsProbabilityMeasure (Q i)]
    (err : W → X → Prop) (herr : ∀ x,MeasurableSet {w | err w x})
    (π : Fin m → X) (U : ℝ) :
    (Measure.pi Q).real {draw | U < actualErrorCount err π draw} =
      ∑ b,if U < errorCount b then
        independentWeight (fun i => errorBitWeight ((Q i).real {w | err w (π i)})) b else 0 := by
  let f : (Fin m → W) → (Fin m → Bool) := fun draw i => decide (err (draw i) (π i))
  have hf : Measurable f := measurable_pi_lambda _ (fun i =>
    (measurable_errorBit _ (herr (π i))).comp (measurable_pi_apply i))
  have hmap : (Measure.pi Q).map f = Measure.pi (fun i =>
      finiteWeightLaw (errorBitWeight ((Q i).real {w | err w (π i)}))
        (errorBitWeight_nonneg ⟨measureReal_nonneg,measureReal_le_one⟩) (errorBitWeight_sum _)) := by
    rw [Measure.pi_map_pi (fun i => (measurable_errorBit _ (herr (π i))).aemeasurable)]
    simp_rw [errorBit_law _ _ (herr _)]
  have hset : {draw | U < actualErrorCount err π draw} = f ⁻¹' {b | U < errorCount b} := by
    ext draw
    simp [f,errorCount,actualErrorCount]
  rw [hset,← map_measureReal_apply hf ((Set.to_countable _).measurableSet),hmap,measureReal_def,
    productWeightLaw_event]
  rw [ENNReal.toReal_ofReal]
  · congr! 6
  · apply Finset.sum_nonneg
    intro b _
    split_ifs
    · exact independentWeight_nonneg _ (fun i => errorBitWeight_nonneg ⟨measureReal_nonneg,measureReal_le_one⟩) b
    · exact le_rfl

variable {H : Type*} [Fintype H] [DecidableEq H]
variable {A : Finset H} {good : H → Fin m → Prop} {β : ℝ}

/-- The exact manuscript sampled-error tail for continuous posterior draws,
whenever their actual risks are controlled by an adapted finite cover. -/
theorem actual_posterior_draw_tail (hm : 0 < m) (P : CoverProcess A good β)
    (Q : Fin m → Equiv.Perm (Fin m) → Measure W)
    (hQ : ∀ i π,IsProbabilityMeasure (Q i π))
    (err : W → Fin m → Prop) (herr : ∀ x,MeasurableSet {w | err w x})
    (hrisk : ∀ i π,P.risk i π=(Q i π).real {w | err w (π i)})
    (h δ : ℝ) (hh : 0 ≤ h) (hβ : 0 ≤ β) (hδ : 0 < δ) (hδ1 : δ < 1)
    (hcard : (A.card:ℝ) ≤ Real.exp h) :
    finiteMean (fun π => (Measure.pi (fun i => Q i π)).real
      {draw | (Real.exp 1-1)*(1+2*(h+Real.log (2*(m:ℝ)/δ))*harmonicSum (m-1)+m*β)+Real.log (2/δ)
        < actualErrorCount err π draw}) ≤ δ := by
  have heq (π : Equiv.Perm (Fin m)) (U : ℝ) :
      (Measure.pi (fun i => Q i π)).real {draw | U < actualErrorCount err π draw} =
        ∑ b,if U < errorCount b then sampledWeight P π b else 0 := by
    letI : ∀ i,IsProbabilityMeasure (Q i π) := fun i => hQ i π
    rw [actual_draw_tail_identity _ err herr π U]
    simp_rw [sampledWeight,hrisk]
  simp_rw [heq]
  exact sampled_error_tail hm P h δ hh hβ hδ hδ1 hcard

#print axioms actual_posterior_draw_tail
end NeuralGeneralization.BatchTwoOnlineRaw
