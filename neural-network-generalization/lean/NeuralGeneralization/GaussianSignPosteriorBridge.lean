import NeuralGeneralization.FieldPosteriorBridge
import NeuralGeneralization.GaussianPosteriorFeatures
import NeuralGeneralization.GaussianConditionalLogCDF
import NeuralGeneralization.WalshGaussianLaw
import NeuralGeneralization.NetworkGaussianFunctionLimit

/-! Exact identification of the limiting Gaussian function posterior with
the actual latent Gaussian sign-conditioned posterior. -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp Set
open scoped BigOperators
namespace NeuralGeneralization.GaussianSignPosteriorBridge
open ConcreteModel FieldPosteriorBridge GaussianPosteriorFeatures
open GaussianConditionalLogCDF GaussianCoordinateIntegration
variable {d n : ℕ}

def walshField (w : Finset (Fin d) → ℝ) : (Finset (Fin d) → ℝ) → Cube d → ℝ :=
  gaussianField (fun S x => walshCharacter S x) w

def walshFunctionMass (w : Finset (Fin d) → ℝ) (a : ℝ) (g : BooleanFunction d) : ℝ :=
  (WalshGaussianLaw.law w).real (WalshGaussianLaw.orthant g a)

theorem measurable_walshField (w : Finset (Fin d) → ℝ) (x : Cube d) :
    Measurable (fun z => walshField w z x) := by
  unfold walshField gaussianField
  fun_prop

theorem toLp_walshField (w : Finset (Fin d) → ℝ) (z : Finset (Fin d) → ℝ) :
    toLp 2 (walshField w z) = GaussianReadout.readout (WalshGaussianLaw.features w) z := by
  ext x
  change (∑ S, Real.sqrt (w S)*z S*walshCharacter S x) =
    ∑ S, z S*(Real.sqrt (w S)*walshCharacter S x)
  apply Finset.sum_congr rfl
  intro S _
  ring

theorem walshLaw_eq_map (w : Finset (Fin d) → ℝ) :
    WalshGaussianLaw.law w =
      (law (Finset (Fin d))).map (fun z => toLp 2 (walshField w z)) := by
  simp only [toLp_walshField]
  rfl

theorem measurable_toLp_walshField (w : Finset (Fin d) → ℝ) :
    Measurable (fun z => toLp 2 (walshField w z)) := by
  simp only [toLp_walshField]
  exact (GaussianReadout.continuous_readout _).measurable

theorem walshFunctionMass_eq_fieldMass (w : Finset (Fin d) → ℝ) (a : ℝ) (g : BooleanFunction d) :
    walshFunctionMass w a g = fieldMass (law (Finset (Fin d))) (walshField w) a g := by
  rw [walshFunctionMass, measureReal_def, walshLaw_eq_map,
    Measure.map_apply (measurable_toLp_walshField w) (WalshGaussianLaw.isOpen_orthant g a).measurableSet]
  rfl

theorem walshField_boundary_null (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S) (x : Cube d) :
    law (Finset (Fin d)) {z | walshField w z x=0}=0 := by
  have h := WalshGaussianLaw.coordinate_boundary_null w hw x 0
  rw [walshLaw_eq_map, Measure.map_apply (measurable_toLp_walshField w)
    (isClosed_eq (by fun_prop) continuous_const).measurableSet] at h
  exact h

def trainingCoefficients (w : Finset (Fin d) → ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) : Fin n → Finset (Fin d) → ℝ :=
  trainingMatrix (fun S x => walshCharacter S x) w sample (fun j => labelReal (f (sample j)))

def predictionCoefficients (w : Finset (Fin d) → ℝ) (f : BooleanFunction d) (x : Cube d)
    (S : Finset (Fin d)) : ℝ := labelReal (f x)*Real.sqrt (w S)*walshCharacter S x

theorem signCone_trainingCoefficients (w : Finset (Fin d) → ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) :
    GaussianSignCone.signCone (trainingCoefficients w f sample) = trainingEvent (walshField w) f sample :=
  signCone_trainingMatrix_eq _ _ _ _

theorem linear_predictionCoefficients (w : Finset (Fin d) → ℝ) (f : BooleanFunction d)
    (x : Cube d) (z : Finset (Fin d) → ℝ) :
    GaussianSignCDF.linear (predictionCoefficients w f x) z = labelReal (f x)*walshField w z x := by
  unfold GaussianSignCDF.linear predictionCoefficients walshField gaussianField
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro S _
  ring

theorem conditionedOutput_sign_mass (w : Finset (Fin d) → ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) (x : Cube d) :
    (conditionedOutput (trainingCoefficients w f sample) (predictionCoefficients w f x)).real (Ioi 0) =
      (cond (law (Finset (Fin d))) (trainingEvent (walshField w) f sample)).real
        (correctEvent (walshField w) f x) := by
  rw [measureReal_def, conditionedOutput, Measure.map_apply (measurable_linear _) measurableSet_Ioi,
    signCone_trainingCoefficients]
  have heq : GaussianSignCDF.linear (predictionCoefficients w f x) ⁻¹' Ioi 0 =
      correctEvent (walshField w) f x := by
    ext z
    simp only [mem_preimage, mem_Ioi, correctEvent, mem_setOf_eq, linear_predictionCoefficients]
  rw [heq]
  rfl

/-- Exact confidence identity under zero-margin sign conditioning, including
repeated sample inputs and arbitrary target labels. -/
theorem walsh_correctConfidence_eq_conditionedOutput (w : Finset (Fin d) → ℝ)
    (hw : ∀ S, 0 < w S) (f : BooleanFunction d) (sample : Fin n → Cube d) (x : Cube d) :
    ConcreteModel.correctConfidence f (posterior (walshFunctionMass w 0) (consistent f sample)) x =
      (conditionedOutput (trainingCoefficients w f sample) (predictionCoefficients w f x)).real (Ioi 0) := by
  have heq : walshFunctionMass w 0 = fieldMass (law (Finset (Fin d))) (walshField w) 0 :=
    funext fun g => walshFunctionMass_eq_fieldMass w 0 g
  rw [heq, correctConfidence_eq_training_conditional _ _ (measurable_walshField w)
    (walshField_boundary_null w hw), conditionedOutput_sign_mass]

/-- The gamma=0 limit retains the global absolute margin as required by the
actual model convention. -/
theorem walsh_correctConfidence_eq_global_conditional (w : Finset (Fin d) → ℝ)
    {a : ℝ} (ha : 0 ≤ a) (f : BooleanFunction d) (sample : Fin n → Cube d) (x : Cube d) :
    ConcreteModel.correctConfidence f (posterior (walshFunctionMass w a) (consistent f sample)) x =
      (cond (law (Finset (Fin d))) (conditioningEvent (walshField w) a f sample)).real
        (correctEvent (walshField w) f x) := by
  have heq : walshFunctionMass w a = fieldMass (law (Finset (Fin d))) (walshField w) a :=
    funext fun g => walshFunctionMass_eq_fieldMass w a g
  rw [heq]
  exact correctConfidence_eq_conditional _ _ (measurable_walshField w) ha f sample x

theorem training_probability_ne_zero (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (f : BooleanFunction d) (sample : Fin n → Cube d) :
    law (Finset (Fin d)) (GaussianSignCone.signCone (trainingCoefficients w f sample)) ≠ 0 := by
  rw [signCone_trainingCoefficients]
  have hmass : 0 < fieldMass (law (Finset (Fin d))) (walshField w) 0 f := by
    rw [← walshFunctionMass_eq_fieldMass]
    exact ENNReal.toReal_pos (WalshGaussianLaw.orthant_pos w hw f 0).ne' (measure_ne_top _ _)
  have hsub : fieldOrthant (walshField w) 0 f ⊆ trainingEvent (walshField w) f sample :=
    fun _ hz i => hz (sample i)
  intro hz
  have hz' := measure_mono_null hsub hz
  simp only [fieldMass, measureReal_def, hz', ENNReal.toReal_zero, lt_self_iff_false] at hmass

theorem arcsine_correctConfidence_eq_conditionedOutput (r : ℕ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) (x : Cube d) :
    ConcreteModel.correctConfidence f
      (posterior (NetworkGaussianFunctionLimit.gaussianFunctionMass d r 0) (consistent f sample)) x =
      (conditionedOutput (trainingCoefficients (walshCoefficients (arcsineProfile d (r+1))) f sample)
        (predictionCoefficients (walshCoefficients (arcsineProfile d (r+1))) f x)).real (Ioi 0) :=
  walsh_correctConfidence_eq_conditionedOutput _ (iterated_arcsine_coefficient_pos d r) f sample x

end NeuralGeneralization.GaussianSignPosteriorBridge
end
