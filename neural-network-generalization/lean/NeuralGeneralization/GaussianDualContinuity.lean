import NeuralGeneralization.GaussianDualLayer

/-! Joint measurability of the Gaussian dual bad event as its incoming
coefficient matrix varies with the preceding network weights. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianDualContinuity
open ConcreteModel FiniteDifferential GaussianAngularFields GaussianFieldTilt
open BoundedDual BoundedTilt ActualBoundedDual CovarianceDualLift DualCertificate GaussianDualLayer
open TanhDifferential
variable {d N : ℕ} {J : Type*} [Fintype J]

theorem continuous_field_coeff (z : J → ℝ) :
    Continuous (fun A : Cube d → J → ℝ => fieldLinear A z) := by
  apply continuous_pi
  intro x
  simp only [fieldLinear_apply]
  fun_prop

theorem continuous_fieldPartition (v : Cube d × Cube d → ℝ) :
    Continuous (fun A : Cube d → J → ℝ =>
      partition (fieldLaw A) (potential (features Real.tanh) v)) := by
  have hpot : Continuous (potential (features Real.tanh) v) := by
    unfold potential pairing features
    fun_prop
  have heq (A : Cube d → J → ℝ) :
      partition (fieldLaw A) (potential (features Real.tanh) v) =
      ∫ z, Real.exp (potential (features Real.tanh) v (fieldLinear A z)) ∂standardLaw J := by
    unfold partition
    exact integral_fieldLaw A _ (Real.continuous_exp.comp hpot).measurable
  simp_rw [heq]
  apply continuous_of_dominated (bound := fun _ : J → ℝ => Real.exp (entryL1 v))
  · intro A
    exact ((Real.continuous_exp.comp hpot).measurable.comp (fieldLinear A).continuous.measurable).aestronglyMeasurable
  · intro A
    apply ae_of_all
    intro z
    rw [Real.norm_eq_abs, Real.abs_exp]
    exact Real.exp_le_exp.mpr ((le_abs_self _).trans
      (potential_bound (features Real.tanh)
        (features_bound Real.tanh (fun x => (Real.abs_tanh_lt_one x).le)) v _))
  · exact integrable_const _
  · exact ae_of_all _ (fun z => (Real.continuous_exp.comp hpot).comp (continuous_field_coeff z))

theorem continuous_fieldObjective (v : Cube d × Cube d → ℝ) :
    Continuous (fun p : (Cube d → J → ℝ) × (Cube d × Cube d → ℝ) =>
      objective (fieldLaw p.1) (features Real.tanh) p.2 v) := by
  have hlog := ((continuous_fieldPartition (J := J) v).comp continuous_fst).log (fun p : (Cube d → J → ℝ) × (Cube d × Cube d → ℝ) =>
    (partition_pos (fieldLaw p.1) _
      (measurable_potential (features Real.tanh)
        (fun ij => (continuous_tanhPairValue ij.1 ij.2).measurable) v)
      (potential_bound (features Real.tanh)
        (features_bound Real.tanh (fun x => (Real.abs_tanh_lt_one x).le)) v)).ne')
  exact (by unfold pairing; fun_prop : Continuous
    (fun p : (Cube d → J → ℝ) × (Cube d × Cube d → ℝ) => pairing v p.2)).sub hlog

theorem continuous_empirical_fields :
    Continuous (fun a : Fin N → Cube d → ℝ => empirical (features Real.tanh) a) := by
  apply continuous_pi
  intro p
  unfold empirical features
  fun_prop

/-- The joint exceptional event is open even though it quantifies over a
continuum of dual parameters and permits singular incoming covariances. -/
theorem isOpen_badFieldPair (G K : ℝ) :
    IsOpen {p : (Cube d → J → ℝ) × (Fin N → Cube d → ℝ) |
      p.2 ∈ badEvent (fieldLaw p.1) (features Real.tanh) N G K} := by
  have heq : {p : (Cube d → J → ℝ) × (Fin N → Cube d → ℝ) |
      p.2 ∈ badEvent (fieldLaw p.1) (features Real.tanh) N G K} =
      ⋃ v : Cube d × Cube d → ℝ, ⋃ _hv : entryL1 v ≤ G,
        {p | K < objective (fieldLaw p.1) (features Real.tanh)
          (empirical (features Real.tanh) p.2) v} := by
    ext p
    simp only [Set.mem_setOf_eq, badEvent, Set.mem_iUnion]
    tauto
  rw [heq]
  apply isOpen_iUnion
  intro v
  apply isOpen_iUnion
  intro hv
  apply isOpen_lt continuous_const
  exact (continuous_fieldObjective v).comp
    (continuous_fst.prodMk (continuous_empirical_fields.comp continuous_snd))

end NeuralGeneralization.GaussianDualContinuity
end
