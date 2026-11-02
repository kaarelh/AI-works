import NeuralGeneralization.OneSidedSquaredSampling
import NeuralGeneralization.ParityLowFeatures
import NeuralGeneralization.ElementaryTailGram

/-! The parity-coercivity corollary at the printed D_r log(2D_r)
threshold, with arbitrary failure probability and one event for all polynomials. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory Filter
open scoped BigOperators
namespace NeuralGeneralization
open SquaredSampling

lemma parity_coercivity_of_deviation {d r n : ℕ} (hd : 0<d) (hr : 64*r≤d) (hn : 0<n)
    (s : Fin n → ClippingCube d)
    (hs : empiricalDeviation (uniformCubeMeasure d) n
      (fun x => squaredFeature negativeResponse (WithLp.toLp 2 (parityLowFeatures d r x))) s ≤ 1/8) :
    ∀ c : Fin (lowDimension d r) → ℝ,
      (1/4:ℝ)*(∑ j,c j^2) ≤ (∑ i,squaredResponse (fun t => max 0 (-t))
        (parityLowFeatures d r) c (s i))/(n:ℝ) := by
  apply all_vector_coercivity_of_unit (fun t => max 0 (-t)) (parityLowFeatures d r)
    (by norm_num) (fun t ht x => negativePart_homogeneous t x ht) (1/4) s hn
  rintro ⟨c,hc,hbad⟩
  let u : ProcessVector (lowDimension d r) := WithLp.toLp 2 c
  have hu2 : ‖u‖^2=1 := by simpa only [u,EuclideanSpace.real_norm_sq_eq] using hc
  have hu : ‖u‖≤1 := by nlinarith [norm_nonneg u]
  let v : ProcessUnitBall (lowDimension d r) := ⟨u,by simpa only [Metric.mem_closedBall,dist_zero_right] using hu⟩
  let F := fun x => squaredFeature negativeResponse (WithLp.toLp 2 (parityLowFeatures d r x))
  have he := (((n:ℝ)⁻¹ • sampleSum F s-∫ x,F x ∂uniformCubeMeasure d) :
    C(ProcessUnitBall (lowDimension d r),ℝ)).norm_coe_le_norm v
  have hI : Integrable F (uniformCubeMeasure d) := Integrable.of_finite
  have hE : |(∑ i,squaredResponse (fun t => max 0 (-t)) (parityLowFeatures d r) c (s i))/(n:ℝ)-
      finiteMean (squaredResponse (fun t => max 0 (-t)) (parityLowFeatures d r) c)| ≤ 1/8 := by
    have hh := he.trans hs
    simp only [ContinuousMap.sub_apply,ContinuousMap.smul_apply] at hh
    rw [ContinuousMap.integral_apply hI] at hh
    simp only [sampleSum,ContinuousMap.sum_apply,F,squaredFeature,ContinuousMap.coe_mk,
      negativeResponse,smul_eq_mul,Real.norm_eq_abs] at hh
    rw [uniformCubeMeasure_integral] at hh
    change |(n:ℝ)⁻¹*(∑ i,squaredResponse (fun t => max 0 (-t)) (parityLowFeatures d r) c (s i))-
      finiteMean (squaredResponse (fun t => max 0 (-t)) (parityLowFeatures d r) c)|≤1/8 at hh
    simpa only [div_eq_mul_inv,mul_comm] using hh
  have hp := parityLowFeatures_population_coercivity hd hr c
  rw [hc,mul_one] at hp
  have hN : (0:ℝ)<n := by exact_mod_cast hn
  have hbad' : (∑ i,squaredResponse (fun t => max 0 (-t)) (parityLowFeatures d r) c (s i))/(n:ℝ) < 1/4 :=
    (div_lt_iff₀ hN).mpr (by simpa only [mul_comm] using hbad)
  have hab := (abs_le.mp hE).1
  linarith

/-- A_delta is independent of input dimension, degree, and sample count. -/
theorem parity_squared_sampling_manuscript {δ : ℝ} (hδ : 0<δ) :
    ∃ A : ℝ,0<A ∧ ∀ d r n : ℕ,0<d → 64*r≤d →
      A*(lowDimension d r:ℝ)*Real.log (2*(lowDimension d r:ℝ)) ≤ n →
      1-δ ≤ (Measure.pi (fun _ : Fin n => uniformCubeMeasure d)).real {s |
        ∀ c : Finset (Fin d) → ℝ,(∀ S,c S≠0 → S.card≤r) →
          (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion c x^2) ≤
            (∑ i,(max 0 (-fullParity (s i)*walshExpansion c (s i)))^2)/(n:ℝ)} := by
  obtain ⟨A,hA,hbudget⟩ := arbitrary_squared_sampling_probability (ε:=1/8) (by norm_num) hδ
  refine ⟨A,hA,?_⟩
  intro d r n hd hr hn
  let a : ClippingCube d → ProcessVector (lowDimension d r) :=
    fun x => WithLp.toLp 2 (parityLowFeatures d r x)
  have hrow : ∀ᵐ x ∂uniformCubeMeasure d,‖a x‖^2≤lowDimension d r := by
    filter_upwards with x
    simpa only [a,EuclideanSpace.real_norm_sq_eq] using (parityLowFeatures_row_norm d r x).le
  have hiso (u : ProcessVector (lowDimension d r)) :
      (∫ x,linearEvaluation (a x) u^2 ∂uniformCubeMeasure d)=‖u‖^2 := by
    rw [uniformCubeMeasure_integral,EuclideanSpace.real_norm_sq_eq]
    exact parityLowFeatures_isometry u.ofLp
  have hh := hbudget (lowDimension d r) n (ClippingCube d) (uniformCubeMeasure d)
    inferInstance a (measurable_of_finite _) hrow hiso negativeResponse
    (by norm_num [negativeResponse]) negativePart_lipschitz (lowDimension_pos d r) hn
  have hD : (1:ℝ)≤lowDimension d r := by exact_mod_cast lowDimension_pos d r
  have hp : 0<A*(lowDimension d r:ℝ)*Real.log (2*(lowDimension d r:ℝ)) :=
    mul_pos (mul_pos hA (by positivity)) (Real.log_pos (by linarith))
  have hnpos : 0<n := by exact_mod_cast lt_of_lt_of_le hp hn
  let B := {s : Fin n → ClippingCube d | (1:ℝ)/8 < empiricalDeviation (uniformCubeMeasure d) n
    (fun x => squaredFeature negativeResponse (a x)) s}
  have hBc : 1-δ ≤ (Measure.pi (fun _ : Fin n => uniformCubeMeasure d)).real Bᶜ := by
    rw [probReal_compl_eq_one_sub (Set.toFinite B).measurableSet]
    change 1-δ ≤ 1-_
    linarith only [hh]
  apply hBc.trans (measureReal_mono ?_)
  intro s hs
  have hsmall : empiricalDeviation (uniformCubeMeasure d) n
      (fun x => squaredFeature negativeResponse (a x)) s ≤ 1/8 := le_of_not_gt hs
  exact parityLowFeatures_coercivity_walsh s (1/4) (parity_coercivity_of_deviation hd hr hnpos s hsmall)

end NeuralGeneralization
