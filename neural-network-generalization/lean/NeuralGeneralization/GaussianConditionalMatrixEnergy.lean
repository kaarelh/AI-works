import NeuralGeneralization.GaussianConditionalEnergy
import NeuralGeneralization.GaussianFieldCovariance
import NeuralGeneralization.CovarianceFactor
import NeuralGeneralization.KernelEnergy
import NeuralGeneralization.GaussianConeRadial

/-! Conditional quadratic energy for an actual finite Gaussian linear image.
The proof diagonalizes its covariance and transfers exact exponential moments;
the event being conditioned on remains on the original Gaussian coordinates. -/
noncomputable section
open MeasureTheory ProbabilityTheory Matrix WithLp
open scoped BigOperators RealInnerProductSpace NNReal
namespace NeuralGeneralization
open FiniteDifferential GaussianAngularFields GaussianAngularPrice GaussianFieldTilt

variable {I J : Type*} [Fintype I] [Fintype J]

private theorem matrix_energy_diagonalization (B : I → J → ℝ) (g : ℝ)
    (hGram : ∀ a : I → ℝ, finiteQuadratic (gram B) a ≤ g * ∑ i, a i ^ 2) :
    ∃ (a : I → ℝ) (A : I → I → ℝ),
      (∀ i, 0 ≤ a i) ∧ (∀ i, a i ≤ g) ∧
      (∑ i, a i) = (∑ i, ∑ j, B i j ^ 2) ∧ fieldLaw B = fieldLaw A ∧
      (∀ z : I → ℝ, (∑ i, (fieldLinear A z i)^2) = ∑ i, a i * z i ^ 2) := by
  classical
  let Q : Matrix I I ℝ := gram B
  have hQ : Q.PosSemidef := by
    have hmat : Q = Matrix.of B * (Matrix.of B).conjTranspose := by
      ext i j
      simp only [Q, GaussianAngularPrice.gram, Matrix.mul_apply, Matrix.conjTranspose_apply,
        star_trivial, Matrix.of_apply]
    rw [hmat]
    exact Matrix.posSemidef_self_mul_conjTranspose (Matrix.of B)
  let U : Matrix I I ℝ := hQ.1.eigenvectorUnitary
  let a := hQ.1.eigenvalues
  let A : I → I → ℝ := fun i j => U i j * Real.sqrt (a j)
  have ha (i : I) : 0 ≤ a i := hQ.eigenvalues_nonneg i
  have hbound (i : I) : a i ≤ g := by
    have hh := hGram (hQ.1.eigenvectorBasis i)
    have hn : (∑ j, (hQ.1.eigenvectorBasis i j)^2) = 1 := by
      rw [← EuclideanSpace.real_norm_sq_eq, hQ.1.eigenvectorBasis.orthonormal.1 i]
      norm_num
    have he : finiteQuadratic (gram B) (hQ.1.eigenvectorBasis i) = a i := by
      change _ = hQ.1.eigenvalues i
      rw [hQ.1.eigenvalues_eq i]
      simp only [finiteQuadratic, dotProduct, Matrix.mulVec, star_trivial,
        RCLike.re_to_real, Finset.mul_sum, Q]
      apply Finset.sum_congr rfl
      intro j hj
      apply Finset.sum_congr rfl
      intro k hk
      ring
    rw [hn, he, mul_one] at hh
    exact hh
  have htrace : (∑ i, a i) = ∑ i, ∑ j, B i j^2 := by
    have ht := hQ.1.trace_eq_sum_eigenvalues
    simpa only [RCLike.ofReal_real_eq_id, id_eq, Matrix.trace, Matrix.diag, Q,
      GaussianAngularPrice.gram, pow_two] using ht.symm
  have hgram (i j : I) : gram A i j = gram B i j := by
    have hs : Q = U * Matrix.diagonal a * star U := by
      simpa only [Unitary.conjStarAlgAut_apply, RCLike.ofReal_real_eq_id,
        Function.comp_def, id_eq] using hQ.1.spectral_theorem
    have hentry : Q i j = ∑ k, (U i k * a k) * U j k := by
      rw [hs, Matrix.mul_apply]
      simp only [Matrix.mul_diagonal, Matrix.star_apply, star_trivial]
    change _ = Q i j
    rw [hentry]
    apply Finset.sum_congr rfl
    intro k hk
    dsimp only [A]
    have hsq := Real.sq_sqrt (ha k)
    calc
      U i k * Real.sqrt (a k) * (U j k * Real.sqrt (a k)) =
          (U i k * U j k) * Real.sqrt (a k)^2 := by ring
      _ = _ := by rw [hsq]; ring
  refine ⟨a, A, ha, hbound, htrace, GaussianFieldCovariance.fieldLaw_eq_of_gram_eq B A
    (fun i j => (hgram i j).symm), ?_⟩
  intro z
  have hv : toLp 2 (fieldLinear A z) =
      ∑ j, (Real.sqrt (a j) * z j) • hQ.1.eigenvectorBasis j := by
    ext i
    simp only [WithLp.ofLp_sum, Finset.sum_apply, WithLp.ofLp_smul, Pi.smul_apply,
      smul_eq_mul, fieldLinear_apply, A, U, Matrix.IsHermitian.eigenvectorUnitary_apply]
    apply Finset.sum_congr rfl
    intro j hj
    ring
  have hi := hQ.1.eigenvectorBasis.orthonormal.inner_sum
    (fun j => Real.sqrt (a j) * z j) (fun j => Real.sqrt (a j) * z j) Finset.univ
  rw [← hv, real_inner_self_eq_norm_sq, EuclideanSpace.real_norm_sq_eq] at hi
  rw [hi]
  apply Finset.sum_congr rfl
  intro i hi
  change (Real.sqrt (a i) * z i) * (Real.sqrt (a i) * z i) = _
  calc
    (Real.sqrt (a i) * z i) * (Real.sqrt (a i) * z i) = Real.sqrt (a i)^2 * z i^2 := by ring
    _ = _ := by rw [Real.sq_sqrt (ha i)]

/-- Every finite Gaussian linear image has an integrable squared norm. -/
theorem integrable_gaussian_matrix_energy (B : I → J → ℝ) :
    Integrable (fun z => ∑ i, (fieldLinear B z i)^2) (standardLaw J) := by
  apply integrable_finsetSum
  intro i hi
  have hm : MemLp (fun z => fieldLinear B z i) 2 (standardLaw J) := by
    have h := memLp_finsetSum' Finset.univ (fun j (_ : j ∈ Finset.univ) =>
      (GaussianConeRadial.memLp_eval j).const_mul (B i j))
    have hf : (∑ j, (fun z : J → ℝ => B i j * z j)) = fun z => fieldLinear B z i := by
      ext z
      simp only [Finset.sum_apply, fieldLinear_apply]
    rw [hf] at h
    exact h
  exact hm.integrable_sq

/-- The same quadratic observable is integrable under any positive event. -/
theorem integrable_cond_gaussian_matrix_energy (B : I → J → ℝ)
    (E : Set (J → ℝ)) (hE : standardLaw J E ≠ 0) :
    Integrable (fun z => ∑ i, (fieldLinear B z i)^2) (cond (standardLaw J) E) :=
  (integrable_gaussian_matrix_energy B).restrict.smul_measure (ENNReal.inv_ne_top.mpr hE)

/-- A trace/operator bound for the actual conditioned Gaussian linear image.
The covariance hypothesis permits singular matrices and repeated rows. -/
theorem conditional_gaussian_matrix_energy (B : I → J → ℝ) (g : ℝ) (hg : 0 < g)
    (hGram : ∀ a : I → ℝ, finiteQuadratic (gram B) a ≤ g * ∑ i, a i^2)
    (E : Set (J → ℝ)) (hE : standardLaw J E ≠ 0) :
    (∫ z, (∑ i, (fieldLinear B z i)^2) ∂cond (standardLaw J) E) ≤
      2 * (∑ i, ∑ j, B i j^2) + 4*g*Real.log (1 / (standardLaw J).real E) := by
  classical
  obtain ⟨a, A, ha, hab, htrace, hlaw, hnorm⟩ := matrix_energy_diagonalization B g hGram
  let T : ℝ := ∑ i, ∑ j, B i j^2
  let s : ℝ := 1 / (4*g)
  have hs : 0 < s := by dsimp [s]; positivity
  have hscale (i : I) : 2*s*a i ≤ 1/2 := by
    have hid : 2*s*a i = a i/(2*g) := by dsimp [s]; ring
    rw [hid]
    apply (div_le_iff₀ (by positivity : 0 < 2*g)).mpr
    linarith [hab i]
  let H : (I → ℝ) → ℝ := fun x => Real.exp (s * ((∑ i, x i^2) - T))
  have hH : Measurable H := by dsimp [H]; fun_prop
  have hfun (z : I → ℝ) : H (fieldLinear A z) =
      Real.exp (s * (∑ i, a i * (z i^2 - (1 : ℝ≥0)))) := by
    dsimp [H]
    rw [hnorm]
    dsimp only [T]
    rw [← htrace]
    congr 2
    simp only [NNReal.coe_one, mul_sub, mul_one, Finset.sum_sub_distrib]
  have heA : Integrable (fun z => H (fieldLinear A z)) (standardLaw I) := by
    simp_rw [hfun]
    exact GaussianTail.integrable_exp_sum_centered_gaussian_squares
      (fun _ : I => 1) a s (fun i => by simpa using (hscale i).trans_lt (by norm_num))
  have he : Integrable H (fieldLaw B) := by
    rw [hlaw]
    exact (integrable_map_measure hH.aestronglyMeasurable
      (fieldLinear A).continuous.measurable.aemeasurable).mpr heA
  have heB : Integrable (fun z => H (fieldLinear B z)) (standardLaw J) :=
    (integrable_map_measure hH.aestronglyMeasurable
      (fieldLinear B).continuous.measurable.aemeasurable).mp he
  have hmgf : (∫ z, H (fieldLinear B z) ∂standardLaw J) ≤
      Real.exp (4*s^2*∑ i, a i^2) := by
    rw [← integral_fieldLaw B H hH, hlaw, integral_fieldLaw A H hH]
    simp_rw [hfun]
    simpa only [NNReal.coe_one, one_pow, mul_one, mgf, standardLaw] using
      GaussianTail.mgf_sum_centered_gaussian_squares_le (fun _ : I => 1) a s
        (fun i => by simpa using hscale i)
  have hQ : Integrable (fun z => (∑ i, (fieldLinear B z i)^2) - T) (standardLaw J) :=
    (integrable_gaussian_matrix_energy B).sub (integrable_const T)
  have hcenter := conditional_expectation_le_of_exponential_moment (standardLaw J)
    (fun z => (∑ i, (fieldLinear B z i)^2) - T) s (4*s^2*∑ i, a i^2)
    hs hQ heB hmgf E hE
  letI : IsProbabilityMeasure (cond (standardLaw J) E) := cond_isProbabilityMeasure hE
  rw [integral_sub (integrable_cond_gaussian_matrix_energy B E hE) (integrable_const T)] at hcenter
  simp only [integral_const, probReal_univ, one_smul] at hcenter
  have hsum : (∑ i, a i^2) ≤ g*T := by
    dsimp only [T]
    rw [← htrace, Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i hi
    nlinarith [mul_le_mul_of_nonneg_right (hab i) (ha i)]
  have hscaled : 4*s*(∑ i, a i^2) ≤ T := by
    have hh := mul_le_mul_of_nonneg_left hsum (show 0 ≤ 4*s by positivity)
    have hid : 4*s*(g*T) = T := by dsimp [s]; field_simp
    rwa [hid] at hh
  have hid : (4*s^2*(∑ i, a i^2) + Real.log (1/(standardLaw J).real E))/s =
      4*s*(∑ i, a i^2) + 4*g*Real.log (1/(standardLaw J).real E) := by
    dsimp [s]
    field_simp
  rw [hid] at hcenter
  change _ ≤ 2*T + _
  linarith

end NeuralGeneralization
