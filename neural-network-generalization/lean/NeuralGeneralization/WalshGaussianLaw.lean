import NeuralGeneralization.NeuralKernelSpectrum
import NeuralGeneralization.GaussianReadout
import NeuralGeneralization.ModelFacts

/-!
# The actual Gaussian field with positive Walsh spectrum

The field is constructed from independent scalar Gaussians and explicit Walsh
features. Its covariance, full support, and null affine coordinate boundaries
are proved from that construction.
-/

noncomputable section
open MeasureTheory ProbabilityTheory WithLp Set
open scoped BigOperators RealInnerProductSpace NNReal

namespace NeuralGeneralization.WalshGaussianLaw

variable {d : ℕ}

def features (w : Finset (Fin d) → ℝ) (S : Finset (Fin d)) (x : ClippingCube d) : ℝ :=
  Real.sqrt (w S) * walshCharacter S x

def law (w : Finset (Fin d) → ℝ) : Measure (EuclideanSpace ℝ (ClippingCube d)) :=
  (Measure.pi fun _ : Finset (Fin d) => gaussianReal 0 1).map
    (GaussianReadout.readout (features w))

instance (w : Finset (Fin d) → ℝ) : IsProbabilityMeasure (law w) :=
  Measure.isProbabilityMeasure_map (GaussianReadout.continuous_readout _).measurable.aemeasurable

theorem gram_features (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (x y : ClippingCube d) : GaussianReadout.gram (features w) x y = walshKernel w x y := by
  unfold GaussianReadout.gram features walshKernel featureKernel
  apply Finset.sum_congr rfl
  intro S hS
  calc
    _ = Real.sqrt (w S) ^ 2 * walshCharacter S x * walshCharacter S y := by ring
    _ = _ := by rw [Real.sq_sqrt (hw S)]

theorem charFun_law (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (t : EuclideanSpace ℝ (ClippingCube d)) :
    charFun (law w) t = Complex.exp (((-(∑ x, ∑ y,
      t x * walshKernel w x y * t y) / 2 : ℝ) : ℂ)) := by
  rw [law, GaussianReadout.charFun_readout_gram]
  simp only [NNReal.coe_one, neg_mul, one_mul, gram_features w hw]

theorem readout_surjective (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S) :
    Function.Surjective (GaussianReadout.readout (features w)) := by
  intro z
  refine ⟨fun S => walshCoefficients (fun x => z x) S / Real.sqrt (w S), ?_⟩
  ext x
  change (∑ S, (walshCoefficients (fun x => z x) S / Real.sqrt (w S)) *
    (Real.sqrt (w S) * walshCharacter S x)) = z x
  have hh (S : Finset (Fin d)) :
      (walshCoefficients (fun x => z x) S / Real.sqrt (w S)) *
        (Real.sqrt (w S) * walshCharacter S x) =
          walshCoefficients (fun x => z x) S * walshCharacter S x := by
    field_simp [(Real.sqrt_pos.mpr (hw S)).ne']
  simp_rw [hh]
  exact walshExpansion_coefficients (fun x => z x) x

theorem open_pos (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (U : Set (EuclideanSpace ℝ (ClippingCube d))) (hU : IsOpen U) (hne : U.Nonempty) :
    0 < law w U := by
  letI : Measure.IsOpenPosMeasure (gaussianReal (0 : ℝ) (1 : ℝ≥0)) :=
    ConcreteModel.gaussianReal_openPos 0 (v := 1) (by norm_num)
  rw [law, Measure.map_apply (GaussianReadout.continuous_readout _).measurable hU.measurableSet]
  apply (hU.preimage (GaussianReadout.continuous_readout _)).measure_pos
    (Measure.pi fun _ : Finset (Fin d) => gaussianReal 0 1)
  obtain ⟨z, hz⟩ := hne
  obtain ⟨a, ha⟩ := readout_surjective w hw z
  exact ⟨a, by simpa only [mem_preimage, ha] using hz⟩

theorem coordinate_variance_pos (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (x : ClippingCube d) : 0 < ∑ S, features w S x ^ 2 := by
  apply Finset.sum_pos'
  · exact fun S _ => sq_nonneg _
  · refine ⟨∅, Finset.mem_univ _, ?_⟩
    simp [features, walshCharacter, Real.sq_sqrt (hw ∅).le, hw ∅]

theorem coordinate_boundary_null (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (x : ClippingCube d) (a : ℝ) : law w {z | z x = a} = 0 := by
  rw [law, Measure.map_apply (GaussianReadout.continuous_readout _).measurable
    (isClosed_eq (by fun_prop) continuous_const).measurableSet]
  have h := GaussianReadout.scalar_linear_boundary_null (fun S => features w S x) 1
    (by simpa using coordinate_variance_pos w hw x) a
  simpa only [Set.preimage_setOf_eq, GaussianReadout.readout, mul_comm] using h

/-- Strict full-sign event with an arbitrary common margin. -/
def orthant (g : ConcreteModel.BooleanFunction d) (a : ℝ) :
    Set (EuclideanSpace ℝ (ClippingCube d)) :=
  {z | ∀ x, a < ConcreteModel.labelReal (g x) * z x}

theorem isOpen_orthant (g : ConcreteModel.BooleanFunction d) (a : ℝ) :
    IsOpen (orthant g a) := by
  have hh : orthant g a = ⋂ x, {z | a < ConcreteModel.labelReal (g x) * z x} := by
    ext z
    simp [orthant]
  rw [hh]
  exact isOpen_iInter_of_finite (fun x => isOpen_lt continuous_const (by fun_prop))

theorem orthant_nonempty (g : ConcreteModel.BooleanFunction d) (a : ℝ) :
    (orthant g a).Nonempty := by
  refine ⟨toLp 2 (fun x => ConcreteModel.labelReal (g x) * (a + 1)), ?_⟩
  intro x
  cases hx : g x <;> simp [ConcreteModel.labelReal, hx]

theorem orthant_pos (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (g : ConcreteModel.BooleanFunction d) (a : ℝ) : 0 < law w (orthant g a) :=
  open_pos w hw _ (isOpen_orthant g a) (orthant_nonempty g a)

theorem frontier_orthant_subset (g : ConcreteModel.BooleanFunction d) (a : ℝ) :
    frontier (orthant g a) ⊆ ⋃ x, {z | z x = ConcreteModel.labelReal (g x) * a} := by
  have hclosed : IsClosed {z : EuclideanSpace ℝ (ClippingCube d) |
      ∀ x, a ≤ ConcreteModel.labelReal (g x) * z x} := by
    have hh : {z : EuclideanSpace ℝ (ClippingCube d) |
        ∀ x, a ≤ ConcreteModel.labelReal (g x) * z x} =
        ⋂ x, {z | a ≤ ConcreteModel.labelReal (g x) * z x} := by ext z; simp
    rw [hh]
    exact isClosed_iInter (fun x => isClosed_le continuous_const (by fun_prop))
  have hclosure := closure_minimal
    (show orthant g a ⊆ {z | ∀ x, a ≤ ConcreteModel.labelReal (g x) * z x}
      from fun z hz x => (hz x).le) hclosed
  intro z hz
  have hzclosed := hclosure hz.1
  have hznot : ¬ ∀ x, a < ConcreteModel.labelReal (g x) * z x := by
    intro hzall
    apply hz.2
    rw [(isOpen_orthant g a).interior_eq]
    exact hzall
  push Not at hznot
  obtain ⟨x, hx⟩ := hznot
  apply mem_iUnion.mpr
  refine ⟨x, ?_⟩
  have he := le_antisymm hx (hzclosed x)
  cases hg : g x <;> simp [ConcreteModel.labelReal, hg] at he ⊢ <;> linarith

theorem orthant_frontier_null (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (g : ConcreteModel.BooleanFunction d) (a : ℝ) :
    law w (frontier (orthant g a)) = 0 := by
  apply measure_mono_null (frontier_orthant_subset g a)
  exact measure_iUnion_null (fun x => coordinate_boundary_null w hw x _)

def arcsineLaw (d r : ℕ) : Measure (EuclideanSpace ℝ (ClippingCube d)) :=
  law (walshCoefficients (arcsineProfile d (r + 1)))

instance (d r : ℕ) : IsProbabilityMeasure (arcsineLaw d r) := by
  unfold arcsineLaw
  infer_instance

theorem charFun_arcsineLaw (d r : ℕ) (t : EuclideanSpace ℝ (ClippingCube d)) :
    charFun (arcsineLaw d r) t = Complex.exp (((-(∑ x, ∑ y,
      t x * arcsineCovariance d (r + 1) x y * t y) / 2 : ℝ) : ℂ)) := by
  rw [arcsineLaw, charFun_law _ (fun S => (iterated_arcsine_coefficient_pos d r S).le)]
  simp only [arcsineCovariance_walsh]

end NeuralGeneralization.WalshGaussianLaw
