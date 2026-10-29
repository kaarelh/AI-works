import GaussianParitySeedLaw

/-! Identification of the actual Gaussian affine pushforwards and reference
invariance under the explicit sign transformations used by the Fourier seed. -/

noncomputable section
open scoped BigOperators NNReal
open MeasureTheory ProbabilityTheory NeuralGeneralization

namespace ConditionalNonpolynomial.Analytic

theorem standardGaussian_affine_map {I : Type*} [Fintype I] (b : I → ℝ) (σ : ℝ) :
    (Measure.pi fun _ : I => gaussianReal 0 1).map (fun z i => b i + σ*z i) =
      Measure.pi (fun i => gaussianReal (b i) (NNReal.mk (σ^2) (sq_nonneg σ))) := by
  rw [Measure.pi_map_pi (f := fun i (z : ℝ) => b i+σ*z) (fun _ => (by fun_prop))]
  congr 1
  funext i
  have hfun : (fun z : ℝ => b i + σ*z) = (fun z => b i+z) ∘ (fun z => σ*z) := rfl
  rw [hfun, ← Measure.map_map (by fun_prop) (by fun_prop), gaussianReal_map_const_mul,
    gaussianReal_map_const_add]
  simp

theorem productGaussian_sign_map {I : Type*} [Fintype I] (v : ℝ≥0)
    (c : I → ℝ) (hc : ∀ i, c i ^ 2 = 1) :
    (Measure.pi fun _ : I => gaussianReal 0 v).map (fun z i => c i*z i) =
      Measure.pi (fun _ : I => gaussianReal 0 v) := by
  rw [Measure.pi_map_pi (fun _ => (by fun_prop))]
  congr 1
  funext i
  rw [gaussianReal_map_const_mul]
  have hcNN : NNReal.mk (c i ^ 2) (sq_nonneg (c i)) = 1 := by
    apply NNReal.eq
    exact hc i
  simp [hcNN]

variable {d : ℕ}

theorem symmetrizedTanhWeights_gaussian_map (S : Finset (Fin d)) (u : ClippingCube d)
    (v : ℝ≥0) :
    (Measure.pi fun _ : Option (Fin d) => gaussianReal 0 v).map
      (symmetrizedTanhWeights S u) =
    Measure.pi (fun _ : Option (Fin d) => gaussianReal 0 v) := by
  let c : Option (Fin d) → ℝ := fun i => match i with
    | none => walshCharacter S u
    | some j => walshCharacter S u * cubeCoordinateSign (u j)
  have hc (i : Option (Fin d)) : c i ^ 2 = 1 := by
    cases i <;> simp [c, mul_pow, walshCharacter_sq, cubeCoordinateSign_sq]
  have hfun : symmetrizedTanhWeights S u = fun z i => c i*z i := by
    funext z i
    cases i <;> rfl
  rw [hfun]
  exact productGaussian_sign_map v c hc

theorem signedTanhWeights_gaussian_map (a : ℝ) (v : ℝ≥0) :
    (Measure.pi fun _ : Option (Fin d) => gaussianReal 0 v).map
      (fun w i => (if a < 0 then (-1 : ℝ) else 1)*w i) =
    Measure.pi (fun _ : Option (Fin d) => gaussianReal 0 v) := by
  apply productGaussian_sign_map
  intro i
  split_ifs <;> norm_num

/-- The reference prior's actual tanh second moment is constant on the cube. -/
theorem gaussianReference_tanh_constant_diagonal (v : ℝ≥0) (x y : ClippingCube d) :
    (∫ w, tanhCubeFeature w x ^ 2 ∂(Measure.pi fun _ : Option (Fin d) => gaussianReal 0 v)) =
      ∫ w, tanhCubeFeature w y ^ 2 ∂(Measure.pi fun _ : Option (Fin d) => gaussianReal 0 v) := by
  have hcommon (x : ClippingCube d) :
      (∫ w, tanhCubeFeature w x ^ 2 ∂(Measure.pi fun _ : Option (Fin d) => gaussianReal 0 v)) =
        ∫ w, tanhCubeFeature w (fun _ => true) ^ 2
          ∂(Measure.pi fun _ : Option (Fin d) => gaussianReal 0 v) := by
    let μ : Measure (Option (Fin d) → ℝ) := Measure.pi fun _ => gaussianReal 0 v
    have hmap := symmetrizedTanhWeights_gaussian_map (∅ : Finset (Fin d)) x v
    have hm : Measurable (symmetrizedTanhWeights (∅ : Finset (Fin d)) x) := by
      apply measurable_pi_lambda
      intro i
      cases i <;> simp only [symmetrizedTanhWeights] <;> fun_prop
    have h := integral_map (μ := μ) hm.aemeasurable
      ((measurable_tanhCubeFeature (fun _ : Fin d => true)).pow_const 2).aestronglyMeasurable
    have hprod : cubeProduct x (fun _ => true) = x := by
      funext i
      cases hx : x i <;> simp [cubeProduct, hx]
    rw [hmap] at h
    simp only [tanhCubeFeature_symmetrizedWeights, walshSymmetrizedFeature,
      walshCharacter, Finset.prod_empty, one_mul, hprod] at h
    exact h.symm
  exact (hcommon x).trans (hcommon y).symm

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.standardGaussian_affine_map
#print axioms ConditionalNonpolynomial.Analytic.symmetrizedTanhWeights_gaussian_map
#print axioms ConditionalNonpolynomial.Analytic.gaussianReference_tanh_constant_diagonal
