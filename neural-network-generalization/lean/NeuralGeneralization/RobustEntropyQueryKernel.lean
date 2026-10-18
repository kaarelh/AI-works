import NeuralGeneralization.RobustEntropyResidualKernel

/-! # Zero-safe measurable Gaussian query kernels

A query already in the active span needs no residual information. We attach a
fresh dummy standard Gaussian on that branch, whose coefficient in the actual
activation is zero. This avoids imposing finite entropy on a Dirac coordinate
relative to a nondegenerate Gaussian.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal RealInnerProductSpace Classical

namespace NeuralGeneralization.RobustEntropy
open RobustGaussianGeometry
set_option maxHeartbeats 400000

variable {A : Type*} [MeasurableSpace A] {N M R : ℕ}
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
local notation "E" => EuclideanSpace ℝ (Fin N)

/-- Jointly measurable selected inputs, including rank changes and padding. -/
theorem measurable_selected_maskedInputs
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) :
    Measurable (fun a => maskedInputs (b a) (J a)) := by
  have h : Measurable (fun p : (Fin M → E) × Finset (Fin M) => maskedInputs p.1 p.2) :=
    measurable_from_prod_countable_left fun S => measurable_maskedInputs S
  exact h.comp (hb.prodMk hJ)

theorem measurable_selected_projection
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) :
    Measurable (fun p : A × (Fin R → E) => rowProjection R (inputSpan (b p.1) (J p.1)) p.2) := by
  have h : Measurable (fun p : ((Fin M → E) × (Fin R → E)) × Finset (Fin M) =>
      inputRowProjection R p.2 p.1) :=
    measurable_from_prod_countable_left fun S => measurable_inputRowProjection R S
  have hm : Measurable (fun p : A × (Fin R → E) => ((b p.1,p.2),J p.1)) :=
    ((hb.comp measurable_fst).prodMk measurable_snd).prodMk (hJ.comp measurable_fst)
  have hh := h.comp hm
  simpa only [Function.comp_def,inputRowProjection] using hh

theorem measurable_selected_residual
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) :
    Measurable (fun a => queryResidual (maskedInputs (b a) (J a)) (b a i)) :=
  measurable_queryResidual.comp
    ((measurable_selected_maskedInputs b hb J hJ).prodMk ((measurable_pi_apply i).comp hb))

theorem measurable_selected_query
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) :
    Measurable (fun p : A × (Fin R → E) => rowQuery R (inputSpan (b p.1) (J p.1))
      (normalizedQueryResidual (maskedInputs (b p.1) (J p.1)) (b p.1 i)) p.2) := by
  have hr := measurable_selected_residual b hb J hJ i
  have hv : Measurable (fun a => normalizedQueryResidual (maskedInputs (b a) (J a)) (b a i)) := by
    unfold normalizedQueryResidual
    exact hr.norm.inv.smul hr
  unfold rowQuery
  apply (measurable_selected_projection b hb J hJ).prodMk
  apply measurable_pi_lambda
  intro j
  exact continuous_inner.measurable.comp
    ((hv.comp measurable_fst).prodMk ((measurable_pi_apply j).comp measurable_snd))

def activeQueryKernel (κ : Kernel A (Fin R → E))
    (b : A → Fin M → E) (J : A → Finset (Fin M)) : Kernel A (Fin R → E) :=
  parameterMap κ (fun p => rowProjection R (inputSpan (b p.1) (J p.1)) p.2)

def pairQueryKernel (κ : Kernel A (Fin R → E))
    (b : A → Fin M → E) (J : A → Finset (Fin M)) (i : Fin M) :
    Kernel A ((Fin R → E) × (Fin R → ℝ)) :=
  parameterMap κ (fun p => rowQuery R (inputSpan (b p.1) (J p.1))
    (normalizedQueryResidual (maskedInputs (b p.1) (J p.1)) (b p.1 i)) p.2)

theorem activeQueryKernel_markov (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) :
    IsMarkovKernel (activeQueryKernel κ b J) := by
  unfold activeQueryKernel parameterMap
  exact Kernel.IsMarkovKernel.map _ (measurable_selected_projection b hb J hJ)

theorem pairQueryKernel_markov (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) :
    IsMarkovKernel (pairQueryKernel κ b J i) := by
  unfold pairQueryKernel parameterMap
  exact Kernel.IsMarkovKernel.map _ (measurable_selected_query b hb J hJ i)

theorem activeQueryKernel_apply (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (a : A) :
    activeQueryKernel κ b J a = (κ a).map (rowProjection R (inputSpan (b a) (J a))) :=
  parameterMap_apply κ (measurable_selected_projection b hb J hJ) a

theorem pairQueryKernel_apply (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) (a : A) :
    pairQueryKernel κ b J i a = (κ a).map (rowQuery R (inputSpan (b a) (J a))
      (normalizedQueryResidual (maskedInputs (b a) (J a)) (b a i))) :=
  parameterMap_apply κ (measurable_selected_query b hb J hJ i) a

def safeQueryKernel (κ : Kernel A (Fin R → E))
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) :
    Kernel A ((Fin R → E) × (Fin R → ℝ)) :=
  Kernel.piecewise ((measurable_selected_residual b hb J hJ i)
    (measurableSet_singleton 0))
    (activeQueryKernel κ b J ×ₖ Kernel.const A (RobustCoupling.standardGaussianVector R))
    (pairQueryKernel κ b J i)

instance safeQueryKernel_markov (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) :
    IsMarkovKernel (safeQueryKernel κ b hb J hJ i) := by
  letI := activeQueryKernel_markov κ b hb J hJ
  letI := pairQueryKernel_markov κ b hb J hJ i
  unfold safeQueryKernel
  infer_instance

theorem safeQueryKernel_apply (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) (a : A) :
    safeQueryKernel κ b hb J hJ i a =
      if queryResidual (maskedInputs (b a) (J a)) (b a i) = 0 then
        (activeQueryKernel κ b J a).prod (RobustCoupling.standardGaussianVector R)
      else pairQueryKernel κ b J i a := by
  letI := activeQueryKernel_markov κ b hb J hJ
  rw [safeQueryKernel,Kernel.piecewise_apply]
  simp only [Set.mem_preimage,Set.mem_singleton_iff,Kernel.prod_apply,Kernel.const_apply]

theorem pairQueryKernel_fst (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) :
    (pairQueryKernel κ b J i).fst = activeQueryKernel κ b J := by
  ext a : 1
  rw [Kernel.fst_apply,pairQueryKernel_apply κ b hb J hJ i,
    activeQueryKernel_apply κ b hb J hJ,
    Measure.map_map measurable_fst (measurable_rowQuery _ _ _)]
  rfl

theorem safeQueryKernel_fst (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) :
    (safeQueryKernel κ b hb J hJ i).fst = activeQueryKernel κ b J := by
  ext a : 1
  rw [Kernel.fst_apply,safeQueryKernel_apply]
  split_ifs
  · simp only [Measure.map_fst_prod,measure_univ,one_smul]
  · exact congrArg (fun K : Kernel A (Fin R → E) => K a)
      (pairQueryKernel_fst κ b hb J hJ i)

/-- The zero-safe joint law has exactly the entropy cost of its genuine
nonzero query, and zero cost when the input was already in the active span. -/
theorem safeQueryKernel_cost (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) (a : A)
    (δ : ℝ)
    (hcost : queryResidual (maskedInputs (b a) (J a)) (b a i) ≠ 0 →
      klDiv ((κ a).map (rowQuery R (inputSpan (b a) (J a))
        (normalizedQueryResidual (maskedInputs (b a) (J a)) (b a i))))
        (((κ a).map (rowProjection R (inputSpan (b a) (J a)))).prod
          (Measure.pi fun _ : Fin R => gaussianReal 0 1)) ≤ ENNReal.ofReal δ) :
    klDiv (safeQueryKernel κ b hb J hJ i a)
      (((safeQueryKernel κ b hb J hJ i).fst a).prod
        (RobustCoupling.standardGaussianVector R)) ≤ ENNReal.ofReal δ := by
  letI := activeQueryKernel_markov κ b hb J hJ
  rw [safeQueryKernel_fst κ b hb J hJ i,safeQueryKernel_apply]
  split_ifs with hz
  · simp only [klDiv_self]
    exact bot_le
  · rw [pairQueryKernel_apply κ b hb J hJ i,
      activeQueryKernel_apply κ b hb J hJ]
    exact hcost hz

/-- The zero-safe law automatically has the averaged residual entropy budget
needed by the two-scale coupling theorem. Exceptional infinite-KL parameter
fibers may be discarded through the stated almost-everywhere cost premise. -/
theorem safeQueryKernel_averaged_cost
    (μ : Measure A) [IsProbabilityMeasure μ]
    (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M)
    (δ : ℝ)
    (hcost : ∀ᵐ a ∂μ, queryResidual (maskedInputs (b a) (J a)) (b a i) ≠ 0 →
      klDiv ((κ a).map (rowQuery R (inputSpan (b a) (J a))
        (normalizedQueryResidual (maskedInputs (b a) (J a)) (b a i))))
        (((κ a).map (rowProjection R (inputSpan (b a) (J a)))).prod
          (Measure.pi fun _ : Fin R => gaussianReal 0 1)) ≤ ENNReal.ofReal δ) :
    (∫⁻ p, klDiv ((safeQueryKernel κ b hb J hJ i).condKernel p)
      (RobustCoupling.standardGaussianVector R)
      ∂μ ⊗ₘ (safeQueryKernel κ b hb J hJ i).fst) ≤ ENNReal.ofReal δ := by
  rw [averaged_conditional_residual_entropy_eq]
  calc
    _ ≤ ∫⁻ _a, ENNReal.ofReal δ ∂μ := by
      apply lintegral_mono_ae
      filter_upwards [hcost] with a ha
      exact safeQueryKernel_cost κ b hb J hJ i a δ ha
    _ = _ := by simp

end NeuralGeneralization.RobustEntropy
