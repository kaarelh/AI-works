import GaussianQuadraticTilt

/-! Exact change from a subcritical Gaussian reference to the standard
Gaussian, with finiteness of every entropy and moment derived internally. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

theorem klDiv_tilted_reference_change_reverse
    {Ω : Type*} [MeasurableSpace Ω] (Q G : Measure Ω)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (V : Ω → ℝ) (hVG : Integrable (fun x => Real.exp (V x)) G)
    (hKL : klDiv Q (G.tilted V) ≠ ∞) (hVQ : Integrable V Q) :
    klDiv Q G ≠ ∞ ∧
      (klDiv Q G).toReal = (klDiv Q (G.tilted V)).toReal +
        (∫ x, V x ∂Q) - Real.log (∫ x, Real.exp (V x) ∂G) := by
  haveI : IsProbabilityMeasure (G.tilted V) := isProbabilityMeasure_tilted hVG
  obtain ⟨hQH,hlogQH⟩ := klDiv_ne_top_iff.mp hKL
  have hQG : Q ≪ G := hQH.trans (tilted_absolutelyContinuous G V)
  have hp : 0 < ∫ x, Real.exp (V x) ∂G := integral_exp_pos hVG
  have hlog : llr Q (G.tilted V) =ᵐ[Q]
      fun x => llr Q G x - V x + Real.log (∫ y, Real.exp (V y) ∂G) := by
    filter_upwards [hQG (toReal_rnDeriv_tilted_right Q G hVG),
      Measure.rnDeriv_pos hQG,hQG (Measure.rnDeriv_lt_top Q G)] with x hx hpos htop
    have hreal : (Q.rnDeriv G x).toReal ≠ 0 :=
      (ENNReal.toReal_pos hpos.ne' htop.ne).ne'
    rw [llr,hx,Real.log_mul (mul_ne_zero (Real.exp_ne_zero _) hp.ne') hreal,
      Real.log_mul (Real.exp_ne_zero _) hp.ne',Real.log_exp]
    change _ = Real.log (Q.rnDeriv G x).toReal - _ + _
    ring
  have hback : llr Q G =ᵐ[Q]
      fun x => llr Q (G.tilted V) x + V x - Real.log (∫ y, Real.exp (V y) ∂G) := by
    filter_upwards [hlog] with x hx
    linarith
  have hlogQG : Integrable (llr Q G) Q :=
    ((hlogQH.add hVQ).sub (integrable_const _)).congr hback.symm
  have hfinite := klDiv_ne_top hQG hlogQG
  exact ⟨hfinite,(klDiv_tilted_reference_change Q G hfinite V hVQ hVG).2⟩

theorem subcritical_gaussian_reference_change
    {I : Type*} [Fintype I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (v : ℝ≥0) (hv : v ≠ 0) (hvone : v ≤ 1)
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 v) ≠ ∞) :
    klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞ ∧
      (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 v)).toReal =
        (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal +
        (Fintype.card I:ℝ)*Real.log (v:ℝ)/2 +
        ((v:ℝ)⁻¹-1)/2 * (∫ x : I → ℝ, ∑ i, x i^2 ∂Q) := by
  classical
  have hvp : 0 < (v:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  have hi := (NeuralGeneralization.RobustEntropyMoments.bounded_variance_gaussian_entropy_second_moment
    (fun _ : I => v) (fun _ => hvone) Q hKL).1
  have hcoord (i : I) : Integrable (fun x : I → ℝ => x i^2) Q := by
    apply hi.mono' (((measurable_pi_apply i).pow_const 2).aestronglyMeasurable)
    filter_upwards [] with x
    rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
    exact Finset.single_le_sum (fun j _ => sq_nonneg (x j)) (Finset.mem_univ i)
  let V := diagonalQuadraticPotential (fun _ : I => (v:ℝ))
  have hVQ : Integrable V Q := by
    apply integrable_finsetSum
    intro i _
    exact ((hcoord i).sub (integrable_const 1)).const_mul _
  have hKL' : klDiv Q ((Measure.pi fun _ : I => gaussianReal 0 1).tilted V) ≠ ∞ := by
    simpa only [V,diagonalQuadratic_tilt_eq_gaussian (fun _ : I => v) (fun _ => hv)] using hKL
  obtain ⟨hfinite,heq⟩ := klDiv_tilted_reference_change_reverse Q
    (Measure.pi fun _ : I => gaussianReal 0 1) V
    (diagonalQuadratic_exp_integrable _ (fun _ => hvp)) hKL' hVQ
  refine ⟨hfinite,?_⟩
  rw [show V=diagonalQuadraticPotential (fun _ : I => (v:ℝ)) from rfl,
    diagonalQuadratic_tilt_eq_gaussian (fun _ : I => v) (fun _ => hv),
    diagonalQuadratic_exp_integral _ (fun _ => hvp),Real.log_exp] at heq
  have hpotential : (∫ x : I → ℝ,diagonalQuadraticPotential (fun _ : I => (v:ℝ)) x ∂Q) =
      (1-(v:ℝ)⁻¹)/2 * ((∫ x : I → ℝ,∑ i,x i^2 ∂Q)-(Fintype.card I:ℝ)) := by
    have he (x : I → ℝ) : diagonalQuadraticPotential (fun _ : I => (v:ℝ)) x =
        (1-(v:ℝ)⁻¹)/2 * ((∑ i,x i^2)-(Fintype.card I:ℝ)) := by
      simp only [diagonalQuadraticPotential,← Finset.mul_sum,Finset.sum_sub_distrib]
      simp
    simp_rw [he]
    rw [integral_const_mul,integral_sub hi (integrable_const _)]
    simp
  rw [hpotential] at heq
  simp only [diagonalQuadraticLogPartition,Finset.sum_const,Finset.card_univ,nsmul_eq_mul] at heq
  linarith

#print axioms subcritical_gaussian_reference_change
end ConditionalNonpolynomial.Analytic
