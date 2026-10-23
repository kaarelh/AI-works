import NeuralGeneralization.BatchTwoActivationConvexProjection
import NeuralGeneralization.GaussianLinear

/-!
# A measurable bounded Gaussian bulk with a controlled residual

The body is the inverse image of a coordinate box under the actual finite
Gaussian linear map. Its Gaussian mass is proved by scalar Gaussian tails.
Projection onto this body then has a dimension-free squared-residual MGF.
-/

noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation

variable {I : Type*} [Fintype I] {n : ℕ}

def linearObservation (a : I→Fin n→ℝ) (x : EuclideanSpace ℝ (Fin n)) (i : I) : ℝ :=
  ∑ j, a i j*x j

def linearBoxBody (a : I→Fin n→ℝ) (B : ℝ) : Set (EuclideanSpace ℝ (Fin n)) :=
  {x | ∀i, |linearObservation a x i|≤B}

theorem linearBoxBody_closed (a : I→Fin n→ℝ) (B : ℝ) : IsClosed (linearBoxBody a B) := by
  have he : linearBoxBody a B=⋂i, {x | |linearObservation a x i|≤B} := by ext x; simp [linearBoxBody]
  rw [he]
  apply isClosed_iInter
  intro i
  apply isClosed_le _ continuous_const
  unfold linearObservation
  fun_prop

theorem linearBoxBody_nonempty (a : I→Fin n→ℝ) {B : ℝ} (hB : 0≤B) :
    (linearBoxBody a B).Nonempty := by
  refine ⟨0,?_⟩
  intro i
  simpa [linearObservation] using hB

theorem linearBoxBody_convex (a : I→Fin n→ℝ) (B : ℝ) : Convex ℝ (linearBoxBody a B) := by
  intro x hx y hy α β hα hβ hsum i
  have he : linearObservation a (α • x+β • y) i=
      α*linearObservation a x i+β*linearObservation a y i := by
    simp only [linearObservation, PiLp.add_apply, PiLp.smul_apply, smul_eq_mul,
      Finset.mul_sum, ← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [he]
  calc
    _ ≤ |α*linearObservation a x i|+|β*linearObservation a y i| := abs_add_le _ _
    _ = α*|linearObservation a x i|+β*|linearObservation a y i| := by
      rw [abs_mul, abs_mul, abs_of_nonneg hα, abs_of_nonneg hβ]
    _ ≤ α*B+β*B := add_le_add
      (mul_le_mul_of_nonneg_left (hx i) hα) (mul_le_mul_of_nonneg_left (hy i) hβ)
    _ = B := by rw [← add_mul, hsum, one_mul]

def gaussianBulkThreshold (I : Type*) [Fintype I] (M : ℝ) : ℝ :=
  Real.sqrt (2*M*Real.log (4*((Fintype.card I : ℝ)+1)))

theorem gaussian_linearBox_mass (a : I→Fin n→ℝ) {M : ℝ} (hM : 0<M)
    (hvar : ∀i, (∑ j, (a i j)^2)≤M) :
    (1/2:ℝ)≤(standardGaussian n).real
      ((WithLp.toLp 2) ⁻¹' linearBoxBody a (gaussianBulkThreshold I M)) := by
  classical
  let B := gaussianBulkThreshold I M
  let C := ((WithLp.toLp 2) ⁻¹' linearBoxBody a B)
  let E := fun i => {x : Fin n→ℝ | B≤|∑ j, a i j*x j|}
  have hB : 0≤B := Real.sqrt_nonneg _
  have hlog : 0≤Real.log (4*((Fintype.card I : ℝ)+1)) := Real.log_nonneg (by
    have := Nat.cast_nonneg (Fintype.card I) (α := ℝ)
    linarith)
  have hsq : B^2=2*M*Real.log (4*((Fintype.card I : ℝ)+1)) := by
    exact Real.sq_sqrt (by positivity)
  have hprob (i : I) : (standardGaussian n).real (E i)≤
      2*Real.exp (-B^2/(2*M)) := by
    exact GaussianTail.gaussian_linear_form_abs_tail (fun _ : Fin n => 1) (a i) M B hM hB
      (by simpa using hvar i)
  have hsub : Cᶜ⊆⋃i, E i := by
    intro x hx
    by_contra hh
    apply hx
    intro i
    have hi : ¬B≤|∑ j, a i j*x j| := by
      intro h
      exact hh (Set.mem_iUnion.mpr ⟨i,h⟩)
    exact (lt_of_not_ge hi).le
  have htail : (standardGaussian n).real Cᶜ≤
      (Fintype.card I : ℝ)*(2*Real.exp (-B^2/(2*M))) := by
    calc
      _ ≤ (standardGaussian n).real (⋃i, E i) := measureReal_mono hsub
      _ ≤ ∑ i, (standardGaussian n).real (E i) := measureReal_iUnion_fintype_le E
      _ ≤ ∑ _i : I, 2*Real.exp (-B^2/(2*M)) := Finset.sum_le_sum (fun i _ => hprob i)
      _ = _ := by simp
  have hexp : Real.exp (-B^2/(2*M))=1/(4*((Fintype.card I : ℝ)+1)) := by
    rw [hsq]
    have he : -(2*M*Real.log (4*((Fintype.card I : ℝ)+1)))/(2*M)=
        -Real.log (4*((Fintype.card I : ℝ)+1)) := by field_simp
    rw [he, Real.exp_neg, Real.exp_log (by positivity)]
    simp only [one_div]
  rw [hexp] at htail
  have hb : (Fintype.card I : ℝ)*(2*(1/(4*((Fintype.card I : ℝ)+1))))≤1/2 := by
    have hp : 0<(Fintype.card I : ℝ)+1 := by positivity
    apply (le_div_iff₀ (by norm_num : (0:ℝ)<2)).mpr
    field_simp
    nlinarith
  have hC : MeasurableSet C := (linearBoxBody_closed a B).measurableSet.preimage
    (PiLp.continuous_toLp 2 _).measurable
  rw [probReal_compl_eq_one_sub hC] at htail
  change 1/2≤(standardGaussian n).real C
  linarith

/-- The actual Gaussian bulk projection, including its measurability and
exponential residual estimate. The input-set size appears only logarithmically
in the coordinate cap; the Gaussian source dimension does not enter the MGF. -/
theorem gaussian_linearBox_projection_moment (a : I→Fin n→ℝ) {M : ℝ} (hM : 0<M)
    (hvar : ∀i, (∑ j, (a i j)^2)≤M) :
    let B := gaussianBulkThreshold I M
    let K := linearBoxBody a B
    let hne := linearBoxBody_nonempty a (Real.sqrt_nonneg _)
    let P := convexProjection K hne (linearBoxBody_closed a B) (linearBoxBody_convex a B)
    Measurable (fun x : Fin n→ℝ => P (WithLp.toLp 2 x)) ∧
      (∀x i, |linearObservation a (P (WithLp.toLp 2 x)) i|≤B) ∧
      (∫⁻ x, ENNReal.ofReal (Real.exp (‖WithLp.toLp 2 x-P (WithLp.toLp 2 x)‖^2/8))
        ∂standardGaussian n)≤3 := by
  dsimp only
  have h := gaussian_convex_projection_moment (linearBoxBody a (gaussianBulkThreshold I M))
    (linearBoxBody_nonempty a (Real.sqrt_nonneg _))
    (linearBoxBody_closed a (gaussianBulkThreshold I M))
    (linearBoxBody_convex a (gaussianBulkThreshold I M))
    (gaussian_linearBox_mass a hM hvar)
  refine ⟨h.1,?_,h.2⟩
  intro x i
  have hm := convexProjection_mem (linearBoxBody a (gaussianBulkThreshold I M))
    (linearBoxBody_nonempty a (Real.sqrt_nonneg _))
    (linearBoxBody_closed a (gaussianBulkThreshold I M))
    (linearBoxBody_convex a (gaussianBulkThreshold I M)) (WithLp.toLp 2 x)
  exact hm i

end NeuralGeneralization.BatchTwoActivation
