import ScalarSubcriticalCost

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators NNReal
namespace ConditionalNonpolynomial.Analytic

/-- Finite critical Gaussian entropy implies finite entropy relative to every
nondegenerate centered Gaussian; the exact reference correction is quadratic. -/
theorem scalar_critical_reference_change
    (Q : Measure ℝ) [IsProbabilityMeasure Q] (v : ℝ≥0)
    (hv : v≠0) (hKL : klDiv Q (gaussianReal 0 1)≠∞) :
    klDiv Q (gaussianReal 0 v)≠∞ ∧
    (klDiv Q (gaussianReal 0 v)).toReal=
      (klDiv Q (gaussianReal 0 1)).toReal+Real.log (v:ℝ)/2+
      ((v:ℝ)⁻¹-1)/2*(∫x:ℝ,x^2 ∂Q) := by
  let e := MeasurableEquiv.funUnique Unit ℝ
  let Q' := Q.map e.symm
  haveI : IsProbabilityMeasure Q' := Measure.isProbabilityMeasure_map e.symm.measurable.aemeasurable
  have hm (w : ℝ≥0) : (gaussianReal 0 w).map e.symm=
      Measure.pi fun _:Unit=>gaussianReal 0 w :=
    (MeasurePreserving.symm e (measurePreserving_funUnique (gaussianReal 0 w) Unit)).map_eq
  have hkl (w : ℝ≥0) : klDiv Q' (Measure.pi fun _:Unit=>gaussianReal 0 w)=
      klDiv Q (gaussianReal 0 w) := by
    rw [←hm]
    exact control_kl_measurableEquiv Q (gaussianReal 0 w) e.symm
  have hf : klDiv Q' (Measure.pi fun _:Unit=>gaussianReal 0 1)≠∞ := by rwa [hkl]
  have hvp : 0<(v:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  let V := diagonalQuadraticPotential (fun _:Unit=>(v:ℝ))
  have hVQ : Integrable V Q' := by
    apply integrable_finsetSum
    intro i _
    exact ((gaussian_coordinate_second_moment_integrable Q' hf i).sub (integrable_const 1)).const_mul _
  have hh := klDiv_tilted_reference_change Q'
    (Measure.pi fun _:Unit=>gaussianReal 0 1) hf V hVQ
    (diagonalQuadratic_exp_integrable _ (fun _=>hvp))
  have hfinite : klDiv Q (gaussianReal 0 v)≠∞ := by
    have h := hh.1
    rw [show V=diagonalQuadraticPotential (fun _:Unit=>(v:ℝ)) from rfl,
      diagonalQuadratic_tilt_eq_gaussian (fun _:Unit=>v) (fun _=>hv),hkl] at h
    exact h
  refine ⟨hfinite,?_⟩
  have heq := hh.2
  rw [show V=diagonalQuadraticPotential (fun _:Unit=>(v:ℝ)) from rfl,
    diagonalQuadratic_tilt_eq_gaussian (fun _:Unit=>v) (fun _=>hv),hkl,hkl,
    diagonalQuadratic_exp_integral _ (fun _=>hvp),Real.log_exp] at heq
  have hi := scalar_gaussian_second_moment_integrable Q hKL
  have hmean : (∫x:Unit→ℝ,diagonalQuadraticPotential (fun _:Unit=>(v:ℝ)) x ∂Q')=
      (1-(v:ℝ)⁻¹)/2*((∫z:ℝ,z^2 ∂Q)-1) := by
    rw [show Q'=Q.map e.symm from rfl,integral_map_equiv]
    simp only [diagonalQuadraticPotential,Finset.univ_unique,Finset.sum_singleton]
    change (∫z:ℝ,(1-(v:ℝ)⁻¹)/2*(z^2-1) ∂Q)=_
    rw [integral_const_mul,integral_sub hi (integrable_const 1)]
    simp
  rw [hmean] at heq
  simp only [diagonalQuadraticLogPartition,Finset.univ_unique,Finset.sum_singleton] at heq
  linarith

#print axioms scalar_critical_reference_change
end ConditionalNonpolynomial.Analytic
