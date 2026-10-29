import GaussianFieldScalarization
import Mathlib.Data.Finset.Max

/-! Maximum-variance occupation for an actual finite Gaussian-controlled path.
The maximizing query may change at every layer. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open NeuralGeneralization.GaussianFieldTilt
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic

variable {X I J : Type*} [Fintype X] [Nonempty X] [Fintype I] [Fintype J]

def featureMaximizer (P : X → EuclideanSpace ℝ I) : X :=
  Classical.choose (Finset.exists_max_image Finset.univ (fun x => ‖P x‖^2) Finset.univ_nonempty)

def maxFeatureVariance (P : X → EuclideanSpace ℝ I) : ℝ := ‖P (featureMaximizer P)‖^2

theorem feature_variance_le_max (P : X → EuclideanSpace ℝ I) (x : X) :
    ‖P x‖^2 ≤ maxFeatureVariance P :=
  (Classical.choose_spec (Finset.exists_max_image Finset.univ (fun x => ‖P x‖^2)
    Finset.univ_nonempty)).2 x (Finset.mem_univ x)

theorem maxFeatureVariance_nonneg (P : X → EuclideanSpace ℝ I) :
    0 ≤ maxFeatureVariance P := sq_nonneg _

theorem field_tanh_moment_le_one (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q] (x : X) :
    (∫ z, (Real.tanh (z x))^2 ∂Q) ≤ 1 := by
  have hp (z : X → ℝ) : (Real.tanh (z x))^2 ≤ 1 :=
    (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le
  have hi : Integrable (fun z : X → ℝ => (Real.tanh (z x))^2) Q := by
    apply (integrable_const (1:ℝ)).mono'
      (((NeuralGeneralization.TanhDifferential.continuous_tanh.measurable.comp
        (measurable_pi_apply x)).pow_const 2).aestronglyMeasurable)
    filter_upwards [] with z
    simpa only [Real.norm_eq_abs, Function.comp_apply, abs_of_nonneg (sq_nonneg (Real.tanh (z x)))] using hp z
  have h := integral_mono hi (integrable_const (1:ℝ)) hp
  simpa using h

theorem field_tanh_moment_lt_one (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q] (x : X) :
    (∫ z, (Real.tanh (z x))^2 ∂Q) < 1 := by
  let f : (X → ℝ) → ℝ := fun z => (Real.tanh (z x))^2
  have hp (z : X → ℝ) : f z < 1 := by
    exact (sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one _)
  have hi : Integrable f Q := by
    apply (integrable_const (1:ℝ)).mono'
      (((NeuralGeneralization.TanhDifferential.continuous_tanh.measurable.comp
        (measurable_pi_apply x)).pow_const 2).aestronglyMeasurable)
    filter_upwards [] with z
    simpa only [Real.norm_eq_abs, Function.comp_apply,
      abs_of_nonneg (sq_nonneg (Real.tanh (z x)))] using (hp z).le
  have hsupport : Function.support (fun z => 1-f z) = Set.univ := by
    ext z
    simp only [Function.mem_support, Set.mem_univ, iff_true]
    exact (sub_pos.mpr (hp z)).ne'
  have hpos : 0 < ∫ z, 1-f z ∂Q := by
    apply (integral_pos_iff_support_of_nonneg (fun z => (sub_pos.mpr (hp z)).le)
      ((integrable_const 1).sub hi)).mpr
    rw [hsupport, measure_univ]
    exact zero_lt_one
  rw [integral_sub (integrable_const 1) hi] at hpos
  simpa only [integral_const, probReal_univ, one_smul, sub_pos] using hpos

/-- The diagonal-variance premise of the field theorem follows directly
from any Gaussian amplitude with absolute value at most one. -/
theorem scaled_source_variance_le (P : X → EuclideanSpace ℝ I)
    (t : ℝ) (ht : |t| ≤ 1) (x : X) :
    ‖WithLp.toLp 2 (fun i => t * P x i)‖^2 ≤ ‖P x‖^2 := by
  have heq : WithLp.toLp 2 (fun i => t * P x i) = t • P x := by
    ext i
    rfl
  rw [heq, norm_smul, Real.norm_eq_abs, mul_pow, sq_abs]
  have hs : t^2 ≤ 1 := (sq_le_one_iff_abs_le_one _).mpr ht
  simpa only [one_mul] using mul_le_mul_of_nonneg_right hs (sq_nonneg ‖P x‖)

/-- A genuine nonzero readout margin forces positive terminal variance and
the scalar reciprocal readout cost used by the Bellman argument. -/
theorem margin_implies_max_variance_readout (P : X → EuclideanSpace ℝ I)
    (b : EuclideanSpace ℝ I) (x : X) (hmargin : (1/2:ℝ) ≤ |⟪b,P x⟫|) :
    0 < maxFeatureVariance P ∧ 1/(8*maxFeatureVariance P) ≤ ‖b‖^2/2 := by
  have hc := (hmargin.trans (abs_real_inner_le_norm b (P x)))
  have hsq : (1/4:ℝ) ≤ ‖b‖^2*‖P x‖^2 := by
    have hnorm : 0 ≤ ‖b‖*‖P x‖ := mul_nonneg (norm_nonneg _) (norm_nonneg _)
    nlinarith
  have hq := mul_le_mul_of_nonneg_left (feature_variance_le_max P x) (sq_nonneg ‖b‖)
  have hpos : 0 < maxFeatureVariance P := by
    have hn := maxFeatureVariance_nonneg P
    by_contra hh
    have hz : maxFeatureVariance P = 0 := le_antisymm (not_lt.mp hh) hn
    rw [hz, mul_zero] at hq
    linarith
  refine ⟨hpos, ?_⟩
  apply (div_le_iff₀ (show 0 < 8*maxFeatureVariance P by positivity)).mpr
  nlinarith

theorem controlled_field_max_variance_pos (H : ℕ)
    (P : ℕ → X → EuclideanSpace ℝ I) (A : ℕ → X → J → ℝ)
    (Q : ℕ → Measure (X → ℝ))
    (hprob : ∀ j<H, IsProbabilityMeasure (Q j))
    (hfinite : ∀ j<H, klDiv (Q j) (fieldLaw (A j)) ≠ ∞)
    (hvar : ∀ j<H, ∀ x, ‖WithLp.toLp 2 (A j x)‖^2 ≤ ‖P j x‖^2)
    (hrec : ∀ j<H, ∀ x, ‖P (j+1) x‖^2 = ∫ z, (Real.tanh (z x))^2 ∂Q j)
    (hterminal : 0 < maxFeatureVariance (P H)) :
    ∀ j≤H, 0 < maxFeatureVariance (P j) := by
  intro j hj
  apply Nat.decreasingInduction (motive := fun j _ => 0 < maxFeatureVariance (P j))
    (n := H) ?_ hterminal hj
  intro k hk hnext
  letI := hprob k hk
  let x := featureMaximizer (P (k+1))
  have hpos : 0 < ∫ z, (Real.tanh (z x))^2 ∂Q k := by
    rw [← hrec k hk x]
    exact hnext
  have hsource := controlled_field_positive_source (A k) x (Q k) (hfinite k hk) hpos
  exact hsource.trans_le ((hvar k hk x).trans (feature_variance_le_max (P k) x))

theorem controlled_field_max_variance_le_one (H : ℕ)
    (P : ℕ → X → EuclideanSpace ℝ I) (Q : ℕ → Measure (X → ℝ))
    (hprob : ∀ j<H, IsProbabilityMeasure (Q j))
    (hrec : ∀ j<H, ∀ x, ‖P (j+1) x‖^2 = ∫ z, (Real.tanh (z x))^2 ∂Q j)
    (hinit : ∀ x, ‖P 0 x‖^2 ≤ 1) :
    ∀ j≤H, maxFeatureVariance (P j) ≤ 1 := by
  intro j hj
  cases j with
  | zero => exact hinit _
  | succ k =>
    letI := hprob k (by omega)
    unfold maxFeatureVariance
    rw [hrec k (by omega)]
    exact field_tanh_moment_le_one (Q k) _

def fieldEntropyOccupationBound (H : ℕ) (ε : ℝ) : ℝ :=
  Real.sqrt (526337*(H:ℝ)*ε+526336)+
    ((Nat.log2 (H+1)+1:ℕ):ℝ)*dyadicBlockConstant 526336

/-- A near-baseline budget on an actual controlled field path bounds both
its maximum-variance occupation and the sum of square roots of its full
layer entropies. All scalar laws, positive variances, and Bellman hypotheses
are derived from the field recursion and the genuine readout margin. -/
theorem controlled_field_occupation (H : ℕ)
    (P : ℕ → X → EuclideanSpace ℝ I) (A : ℕ → X → J → ℝ)
    (Q : ℕ → Measure (X → ℝ))
    (hprob : ∀ j<H, IsProbabilityMeasure (Q j))
    (hfinite : ∀ j<H, klDiv (Q j) (fieldLaw (A j)) ≠ ∞)
    (hvar : ∀ j<H, ∀ x, ‖WithLp.toLp 2 (A j x)‖^2 ≤ ‖P j x‖^2)
    (hrec : ∀ j<H, ∀ x, ‖P (j+1) x‖^2 = ∫ z, (Real.tanh (z x))^2 ∂Q j)
    (hinit : ∀ x, ‖P 0 x‖^2 ≤ 1)
    (b : EuclideanSpace ℝ I) (x : X) (hmargin : (1/2:ℝ) ≤ |⟪b,P H x⟫|)
    (ε : ℝ) (hε : 0≤ε)
    (hnear : (∑ j ∈ Finset.range H,(klDiv (Q j) (fieldLaw (A j))).toReal)+‖b‖^2/2 ≤
      scalarBaseline.toReal+ε) :
    (∑ j ∈ Finset.range H,Real.sqrt ((klDiv (Q j) (fieldLaw (A j))).toReal)) ≤
        fieldEntropyOccupationBound H ε ∧
    (driftDissipation/2)*(∑ j ∈ Finset.range H,maxFeatureVariance (P j)) ≤
      ((driftDissipation/2)*varianceEntropyConstant+3)*fieldEntropyOccupationBound H ε+
        Real.log (8*(257+ε)) := by
  classical
  let q := fun j => maxFeatureVariance (P j)
  let a := fun j => ‖WithLp.toLp 2 (A j (featureMaximizer (P (j+1))))‖^2
  let e := fun j => (klDiv (Q j) (fieldLaw (A j))).toReal
  obtain ⟨hterminal,hreadout⟩ := margin_implies_max_variance_readout (P H) b x hmargin
  have hq : ∀ j≤H, 0<q j :=
    controlled_field_max_variance_pos H P A Q hprob hfinite hvar hrec hterminal
  have hq1 : ∀ j≤H, q j≤1 :=
    controlled_field_max_variance_le_one H P Q hprob hrec hinit
  have ha : ∀ j<H, 0≤a j := fun j _ => sq_nonneg _
  have haq : ∀ j<H, a j≤q j := by
    intro j hj
    exact (hvar j hj _).trans (feature_variance_le_max (P j) _)
  have hex (j : ℕ) : ∃ R : Measure ℝ, j<H →
      IsProbabilityMeasure R ∧ klDiv R (gaussianReal 0 1)≠∞ ∧
      (klDiv R (gaussianReal 0 1)).toReal≤e j ∧ q (j+1)≤scalarTransition (a j) R := by
    by_cases hj : j<H
    · letI := hprob j hj
      let y := featureMaximizer (P (j+1))
      have hpos : 0 < ∫ z, (Real.tanh (z y))^2 ∂Q j := by
        rw [← hrec j hj y]
        exact hq (j+1) (by omega)
      obtain ⟨R,hp,hf,hc,ht⟩ := controlled_field_scalar_step (A j) y (Q j) (hfinite j hj) hpos
      refine ⟨R, fun _ => ⟨hp,hf,hc,?_⟩⟩
      rw [ht, ← hrec j hj y]
      exact le_rfl
    · exact ⟨gaussianReal 0 1, fun h => False.elim (hj h)⟩
  choose R hR using hex
  have hp : ∀ j<H, IsProbabilityMeasure (R j) := fun j hj => (hR j hj).1
  have hf : ∀ j<H, klDiv (R j) (gaussianReal 0 1)≠∞ := fun j hj => (hR j hj).2.1
  have hc : ∀ j<H, (klDiv (R j) (gaussianReal 0 1)).toReal≤e j := fun j hj => (hR j hj).2.2.1
  have ht : ∀ j<H, q (j+1)≤scalarTransition (a j) (R j) := fun j hj => (hR j hj).2.2.2
  constructor
  · exact controlled_path_sqrt_entropy H q a e R hε hq hq1 ha haq hp hf hc ht hreadout hnear
  · exact controlled_path_variance_sum H q a e R hε hq hq1 ha haq hp hf hc ht hreadout hnear

#print axioms controlled_field_max_variance_pos
#print axioms controlled_field_occupation
end ConditionalNonpolynomial.Analytic
