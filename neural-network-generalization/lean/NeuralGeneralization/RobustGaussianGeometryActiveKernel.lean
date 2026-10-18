import NeuralGeneralization.RobustGaussianGeometryEntropy
import NeuralGeneralization.RobustEntropyQueries
import NeuralGeneralization.RobustEntropyProjection

/-! # Averaged actual active-coordinate energy for a parameter-dependent row law -/
noncomputable section
set_option maxHeartbeats 400000
open MeasureTheory ProbabilityTheory InformationTheory InnerProductSpace WithLp
open scoped BigOperators ENNReal RealInnerProductSpace
namespace NeuralGeneralization.RobustGaussianGeometry
open GaussianOrthogonal
variable {N q R : ℕ}

/-- The literal scaled active coefficient vectors of all original rows. -/
def actualActiveH (b : Fin q → EuclideanSpace ℝ (Fin N)) (t : ℝ)
    (X : Fin R → EuclideanSpace ℝ (Fin N)) : Fin R → EuclideanSpace ℝ (Fin q) :=
  fun i => t • toLp 2 (evaluations (gramSchmidtNormed ℝ b) (X i))

theorem measurable_actualActiveH (t : ℝ) :
    Measurable (fun p : (Fin q → EuclideanSpace ℝ (Fin N)) ×
      (Fin R → EuclideanSpace ℝ (Fin N)) => actualActiveH p.1 t p.2) := by
  apply measurable_pi_lambda
  intro i
  have hp : Measurable (fun p : (Fin q → EuclideanSpace ℝ (Fin N)) ×
      (Fin R → EuclideanSpace ℝ (Fin N)) => (p.1, p.2 i)) := by fun_prop
  have hm := (measurable_active_coordinates (N := N) (q := q)).comp hp
  exact ((WithLp.measurable_toLp 2 (Fin q → ℝ)).comp hm).const_smul t

/-- Exact row normalization before applying an entropy bound. -/
theorem actualActiveH_energy (b : Fin q → EuclideanSpace ℝ (Fin N)) (t : ℝ)
    (X : Fin R → EuclideanSpace ℝ (Fin N)) :
    (∑ i, ‖actualActiveH b t X i‖^2) =
      t^2 * ∑ i, ‖activeProjection b (X i)‖^2 := by
  have he (i : Fin R) : ‖actualActiveH b t X i‖^2 =
      t^2 * ‖activeProjection b (X i)‖^2 := by
    simp only [actualActiveH, norm_smul, mul_pow, Real.norm_eq_abs, sq_abs,
      EuclideanSpace.real_norm_sq_eq]
    rw [active_energy_eq_projection]
    rw [EuclideanSpace.real_norm_sq_eq]
  simp only [he, Finset.mul_sum]

/-- A pointwise extended-integral statement valid even for infinite KL. The
zero-scale case is handled separately, avoiding 0*infinity ambiguity. -/
theorem actualActiveH_lintegral_le
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (t : ℝ)
    (Q : Measure (Fin R → EuclideanSpace ℝ (Fin N))) [IsProbabilityMeasure Q] :
    (∫⁻ X, ENNReal.ofReal (∑ i, ‖actualActiveH b t X i‖^2) ∂Q) ≤
      ENNReal.ofReal (4*t^2) *
        klDiv Q (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)) +
      ENNReal.ofReal (2*t^2*(R : ℝ)*q) := by
  by_cases ht : t = 0
  · subst t
    simp [actualActiveH]
  by_cases hfin : klDiv Q (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)) = ∞
  · rw [hfin, ENNReal.mul_top (by positivity), top_add]
    exact le_top
  obtain ⟨hi,hb⟩ := active_matrix_entropy_second_moment_of_full b Q hfin
  have hcost : Integrable (fun X => ∑ i, ‖actualActiveH b t X i‖^2) Q := by
    simp_rw [actualActiveH_energy]
    exact hi.const_mul (t^2)
  rw [← ofReal_integral_eq_lintegral_ofReal hcost
    (Filter.Eventually.of_forall (fun X => by positivity))]
  have he : (∫ X, (∑ i, ‖actualActiveH b t X i‖^2) ∂Q) ≤
      4*t^2*(klDiv Q (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1))).toReal +
      2*t^2*(R : ℝ)*q := by
    simp_rw [actualActiveH_energy]
    rw [integral_const_mul]
    have hh := mul_le_mul_of_nonneg_left hb (sq_nonneg t)
    nlinarith
  apply (ENNReal.ofReal_le_ofReal he).trans_eq
  rw [ENNReal.ofReal_add (by positivity) (by positivity),
    ENNReal.ofReal_mul (by positivity), ENNReal.ofReal_toReal hfin]

/-- Projection onto any larger subspace preserves every actual active
coordinate, including zero columns of the normalized GS family. -/
theorem evaluations_starProjection_eq
    (b : Fin q → EuclideanSpace ℝ (Fin N))
    (K : Submodule ℝ (EuclideanSpace ℝ (Fin N)))
    (hspan : Submodule.span ℝ (Set.range b) ≤ K)
    (g : EuclideanSpace ℝ (Fin N)) :
    evaluations (gramSchmidtNormed ℝ b) (K.starProjection g) =
      evaluations (gramSchmidtNormed ℝ b) g := by
  funext j
  have hmem : gramSchmidtNormed ℝ b j ∈ Submodule.span ℝ (Set.range b) := by
    have hs : Submodule.span ℝ (Set.range (gramSchmidtNormed ℝ b)) =
        Submodule.span ℝ (Set.range b) := by
      rw [span_gramSchmidtNormed_range, span_gramSchmidt]
    rw [← hs]
    exact Submodule.subset_span (Set.mem_range_self j)
  unfold evaluations
  rw [← K.inner_starProjection_left_eq_right,
    K.starProjection_eq_self_iff.mpr (hspan hmem)]

/-- The literal H arrays can be decoded from the full active projection. -/
theorem actualActiveH_rowProjection_eq
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (t : ℝ)
    (K : Submodule ℝ (EuclideanSpace ℝ (Fin N)))
    (hspan : Submodule.span ℝ (Set.range b) ≤ K)
    (g : Fin R → EuclideanSpace ℝ (Fin N)) :
    actualActiveH b t (RobustEntropy.rowProjection R K g) = actualActiveH b t g := by
  funext i
  simp only [actualActiveH, RobustEntropy.rowProjection,
    evaluations_starProjection_eq b K hspan]

/-- Consequently the projected observation has exactly the original active-H
pushforward law; this is equality of measures, not merely of moments. -/
theorem map_actualActiveH_rowProjection
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (t : ℝ)
    (K : Submodule ℝ (EuclideanSpace ℝ (Fin N)))
    (hspan : Submodule.span ℝ (Set.range b) ≤ K)
    (Q : Measure (Fin R → EuclideanSpace ℝ (Fin N))) :
    (Q.map (RobustEntropy.rowProjection R K)).map (actualActiveH b t) =
      Q.map (actualActiveH b t) := by
  have hp : Measurable (fun X : Fin R → EuclideanSpace ℝ (Fin N) => (b,X)) :=
    measurable_prodMk_left
  have hm : Measurable (actualActiveH b t :
      (Fin R → EuclideanSpace ℝ (Fin N)) → (Fin R → EuclideanSpace ℝ (Fin q))) := by
    simpa only [Function.comp_def] using (measurable_actualActiveH t).comp hp
  rw [Measure.map_map hm (RobustEntropy.measurable_rowProjection R K)]
  congr 1
  funext X
  exact actualActiveH_rowProjection_eq b t K hspan X

variable {A : Type*} [MeasurableSpace A]

@[fun_prop] theorem measurable_actualActiveH_parameter
    (b : A → Fin q → EuclideanSpace ℝ (Fin N)) (hb : Measurable b) (t : ℝ) :
    Measurable (fun p : A × (Fin R → EuclideanSpace ℝ (Fin N)) =>
      actualActiveH (b p.1) t p.2) := by
  have hp : Measurable (fun p : A × (Fin R → EuclideanSpace ℝ (Fin N)) =>
      (b p.1,p.2)) := (hb.comp measurable_fst).prodMk measurable_snd
  have hm := (measurable_actualActiveH (N := N) (q := q) (R := R) t).comp hp
  simpa only [Function.comp_def] using hm

/-- The actual pushforward coefficient kernel, not an assumed active-energy
law. Its basis may be selected measurably from prefix and future parameters. -/
def activeHKernel (κ : Kernel A (Fin R → EuclideanSpace ℝ (Fin N)))
    (b : A → Fin q → EuclideanSpace ℝ (Fin N)) (_hb : Measurable b) (t : ℝ) :
    Kernel A (Fin R → EuclideanSpace ℝ (Fin q)) :=
  (Kernel.id ×ₖ κ).map (fun p => actualActiveH (b p.1) t p.2)

instance activeHKernel_markov
    (κ : Kernel A (Fin R → EuclideanSpace ℝ (Fin N))) [IsMarkovKernel κ]
    (b : A → Fin q → EuclideanSpace ℝ (Fin N)) (hb : Measurable b) (t : ℝ) :
    IsMarkovKernel (activeHKernel κ b hb t) := by
  unfold activeHKernel
  apply Kernel.IsMarkovKernel.map
  exact measurable_actualActiveH_parameter b hb t

theorem activeHKernel_apply
    (κ : Kernel A (Fin R → EuclideanSpace ℝ (Fin N))) [IsMarkovKernel κ]
    (b : A → Fin q → EuclideanSpace ℝ (Fin N)) (hb : Measurable b) (t : ℝ) (a : A) :
    activeHKernel κ b hb t a = (κ a).map (actualActiveH (b a) t) := by
  have hm : Measurable (fun p : A × (Fin R → EuclideanSpace ℝ (Fin N)) =>
      actualActiveH (b p.1) t p.2) :=
    measurable_actualActiveH_parameter b hb t
  rw [activeHKernel, Kernel.map_apply _ hm, Kernel.prod_apply, Kernel.id_apply,
    Measure.dirac_prod, Measure.map_map hm measurable_prodMk_left]
  rfl

/-- Averaged actual active-H energy under any subprobability parameter law.
No pointwise finite-KL premise is imposed; infinite-KL null fibers are included
by the preceding extended-integral inequality. -/
theorem activeHKernel_energy_le
    (μ : Measure A) (hμ : μ Set.univ ≤ 1)
    (κ : Kernel A (Fin R → EuclideanSpace ℝ (Fin N))) [IsMarkovKernel κ]
    (b : A → Fin q → EuclideanSpace ℝ (Fin N)) (hb : Measurable b) (t : ℝ)
    (K : ℝ≥0∞)
    (hKL : (∫⁻ a, klDiv (κ a)
      (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)) ∂μ) ≤ K) :
    (∫⁻ a, ∫⁻ H, ENNReal.ofReal (∑ i : Fin R, ‖H i‖^2) ∂activeHKernel κ b hb t a ∂μ) ≤
      ENNReal.ofReal (4*t^2)*K + ENNReal.ofReal (2*t^2*(R : ℝ)*q) := by
  have hm : Measurable (fun a => klDiv (κ a)
      (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1))) := by
    simpa only [Kernel.const_apply] using RobustEntropy.measurable_kernel_klDiv κ
      (Kernel.const A (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)))
  have hpoint (a : A) :
      (∫⁻ H, ENNReal.ofReal (∑ i : Fin R, ‖H i‖^2) ∂activeHKernel κ b hb t a) ≤
        ENNReal.ofReal (4*t^2)*klDiv (κ a)
          (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)) +
        ENNReal.ofReal (2*t^2*(R : ℝ)*q) := by
    rw [activeHKernel_apply, lintegral_map (by fun_prop)]
    · exact actualActiveH_lintegral_le (b a) t (κ a)
    · have hp : Measurable (fun X : Fin R → EuclideanSpace ℝ (Fin N) => (a,X)) :=
        measurable_prodMk_left
      have hmap := (measurable_actualActiveH_parameter b hb t).comp hp
      simpa only [Function.comp_def] using hmap
  calc
    _ ≤ ∫⁻ a, ENNReal.ofReal (4*t^2)*klDiv (κ a)
        (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)) +
        ENNReal.ofReal (2*t^2*(R : ℝ)*q) ∂μ := lintegral_mono hpoint
    _ = ENNReal.ofReal (4*t^2)*(∫⁻ a, klDiv (κ a)
        (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)) ∂μ) +
        ENNReal.ofReal (2*t^2*(R : ℝ)*q)*μ Set.univ := by
      rw [lintegral_add_left (hm.const_mul _), lintegral_const_mul _ hm, lintegral_const]
    _ ≤ _ := by
      exact add_le_add (mul_le_mul_right hKL _) ((mul_le_mul_right hμ _).trans_eq (mul_one _))

end NeuralGeneralization.RobustGaussianGeometry
