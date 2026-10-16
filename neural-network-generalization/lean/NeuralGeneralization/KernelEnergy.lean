import NeuralGeneralization.WalshLaplacian

/-!
# Finite kernel energy and tail evaluation inequalities

The energy is expressed in its positive weighted-feature coordinates.
The kernel and every sample Gram matrix are defined explicitly. In the
Walsh specialization the weights are normalized population eigenvalues,
so the population Fourier energy is `sum a_S^2 / lambda_S`.

These are deterministic inequalities used by the exponential lower-bound
paper. They do not supply the neural kernel eigenvalue estimates or the
random-sample Gram event.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators

section Features

variable {ι X κ : Type*} [Fintype ι] [Fintype κ]

def featureEnergy (w a : ι → ℝ) : ℝ := ∑ j, a j ^ 2 / w j

def featureField (φ : ι → X → ℝ) (a : ι → ℝ) (x : X) : ℝ :=
  ∑ j, a j * φ j x

def featureKernel (φ : ι → X → ℝ) (w : ι → ℝ) (x y : X) : ℝ :=
  ∑ j, w j * φ j x * φ j y

def finiteQuadratic (Q : κ → κ → ℝ) (b : κ → ℝ) : ℝ :=
  ∑ i, ∑ j, b i * Q i j * b j

theorem featureEnergy_nonneg (w a : ι → ℝ) (hw : ∀ j, 0 ≤ w j) :
    0 ≤ featureEnergy w a := by
  exact Finset.sum_nonneg (fun j hj => div_nonneg (sq_nonneg _) (hw j))

/-- Weighted finite Cauchy--Schwarz, without introducing square roots. -/
theorem featureEnergy_cauchy (w a b : ι → ℝ) (hw : ∀ j, 0 < w j) :
    (∑ j, a j * b j) ^ 2 ≤ featureEnergy w a * ∑ j, w j * b j ^ 2 := by
  apply Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul Finset.univ
    (f := fun j => a j ^ 2 / w j) (g := fun j => w j * b j ^ 2)
  · intro j hj
    exact div_nonneg (sq_nonneg _) (hw j).le
  · intro j hj
    exact mul_nonneg (hw j).le (sq_nonneg _)
  · intro j hj
    apply le_of_eq
    field_simp [ne_of_gt (hw j)]

theorem featureKernel_quadratic (φ : ι → X → ℝ) (w : ι → ℝ)
    (s : κ → X) (b : κ → ℝ) :
    finiteQuadratic (fun i j => featureKernel φ w (s i) (s j)) b =
      ∑ t, w t * (∑ i, b i * φ t (s i)) ^ 2 := by
  classical
  unfold finiteQuadratic featureKernel
  simp_rw [Finset.mul_sum, Finset.sum_mul]
  calc
    (∑ i, ∑ j, ∑ t, b i * (w t * φ t (s i) * φ t (s j)) * b j) =
        ∑ i, ∑ t, ∑ j, b i * (w t * φ t (s i) * φ t (s j)) * b j := by
      apply Finset.sum_congr rfl
      intro i hi
      rw [Finset.sum_comm]
    _ = ∑ t, ∑ i, ∑ j, b i * (w t * φ t (s i) * φ t (s j)) * b j := by
      rw [Finset.sum_comm]
    _ = ∑ t, w t * (∑ i, b i * φ t (s i)) ^ 2 := by
      apply Finset.sum_congr rfl
      intro t ht
      rw [pow_two]
      simp_rw [Finset.mul_sum, Finset.sum_mul]
      apply Finset.sum_congr rfl
      intro i hi
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j hj
      ring

theorem featureKernel_positiveSemidefinite (φ : ι → X → ℝ) (w : ι → ℝ)
    (hw : ∀ j, 0 ≤ w j) (s : κ → X) (b : κ → ℝ) :
    0 ≤ finiteQuadratic (fun i j => featureKernel φ w (s i) (s j)) b := by
  rw [featureKernel_quadratic]
  exact Finset.sum_nonneg (fun j hj => mul_nonneg (hw j) (sq_nonneg _))

theorem featureField_pairing (φ : ι → X → ℝ) (a : ι → ℝ)
    (s : κ → X) (b : κ → ℝ) :
    (∑ i, b i * featureField φ a (s i)) =
      ∑ j, a j * (∑ i, b i * φ j (s i)) := by
  unfold featureField
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j hj
  apply Finset.sum_congr rfl
  intro i hi
  ring

/-- If the explicitly defined sample Gram quadratic form is at most `G`
times the Euclidean squared norm, every feature field's sampled squared
norm is at most `G` times its coefficient energy. This is the RKHS
evaluation inequality used in the paper, with no normalization by the
sample size. It holds with repeated sample locations. -/
theorem sampled_featureField_square_le (φ : ι → X → ℝ) (w a : ι → ℝ)
    (hw : ∀ j, 0 < w j) (s : κ → X) (G : ℝ) (hG : 0 ≤ G)
    (hGram : ∀ b : κ → ℝ,
      finiteQuadratic (fun i j => featureKernel φ w (s i) (s j)) b ≤
        G * ∑ i, b i ^ 2) :
    (∑ i, featureField φ a (s i) ^ 2) ≤ G * featureEnergy w a := by
  let v : κ → ℝ := fun i => featureField φ a (s i)
  let R : ℝ := ∑ i, v i ^ 2
  have hE : 0 ≤ featureEnergy w a := featureEnergy_nonneg w a (fun j => (hw j).le)
  have hR : 0 ≤ R := Finset.sum_nonneg (fun i hi => sq_nonneg _)
  have hpair : R = ∑ j, a j * (∑ i, v i * φ j (s i)) := by
    simpa only [R, v, pow_two] using featureField_pairing φ a s v
  have hCS := featureEnergy_cauchy w a (fun j => ∑ i, v i * φ j (s i)) hw
  rw [← hpair, ← featureKernel_quadratic φ w s v] at hCS
  have hbound : R ^ 2 ≤ featureEnergy w a * (G * R) :=
    hCS.trans (mul_le_mul_of_nonneg_left (hGram v) hE)
  change R ≤ G * featureEnergy w a
  by_cases hz : R = 0
  · rw [hz]
    exact mul_nonneg hG hE
  · have hRpos : 0 < R := lt_of_le_of_ne hR (Ne.symm hz)
    apply (mul_le_mul_iff_right₀ hRpos).mp
    nlinarith [hbound]

end Features

section Interpolation

variable {ι X κ : Type*} [Fintype ι] [Fintype κ]

/-- Coefficients of a kernel representer on the given sample. -/
def representerCoefficients (φ : ι → X → ℝ) (w : ι → ℝ)
    (s : κ → X) (b : κ → ℝ) (j : ι) : ℝ :=
  w j * ∑ i, b i * φ j (s i)

theorem representer_field (φ : ι → X → ℝ) (w : ι → ℝ)
    (s : κ → X) (b : κ → ℝ) (x : X) :
    featureField φ (representerCoefficients φ w s b) x =
      ∑ i, b i * featureKernel φ w (s i) x := by
  unfold featureField representerCoefficients featureKernel
  simp_rw [Finset.mul_sum, Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i hi
  apply Finset.sum_congr rfl
  intro j hj
  ring

/-- The energy of a kernel representer is its sample Gram quadratic form.
No invertibility or distinctness of the sample is needed. -/
theorem representer_energy (φ : ι → X → ℝ) (w : ι → ℝ)
    (hw : ∀ j, w j ≠ 0) (s : κ → X) (b : κ → ℝ) :
    featureEnergy w (representerCoefficients φ w s b) =
      finiteQuadratic (fun i j => featureKernel φ w (s i) (s j)) b := by
  rw [featureKernel_quadratic]
  unfold featureEnergy representerCoefficients
  apply Finset.sum_congr rfl
  intro j hj
  field_simp [hw j]

theorem representer_pairing (φ : ι → X → ℝ) (w a : ι → ℝ)
    (hw : ∀ j, w j ≠ 0) (s : κ → X) (b : κ → ℝ) :
    (∑ j, a j * representerCoefficients φ w s b j / w j) =
      ∑ i, b i * featureField φ a (s i) := by
  rw [featureField_pairing]
  unfold representerCoefficients
  apply Finset.sum_congr rfl
  intro j hj
  field_simp [hw j]

/-- Exact Pythagorean identity for an interpolating kernel representer.
The sole interpolation premise is equality of the two fields at the
sample; minimum energy is derived from it. -/
theorem interpolating_representer_pythagoras (φ : ι → X → ℝ) (w a : ι → ℝ)
    (hw : ∀ j, w j ≠ 0) (s : κ → X) (b : κ → ℝ)
    (hfit : ∀ i, featureField φ a (s i) =
      featureField φ (representerCoefficients φ w s b) (s i)) :
    featureEnergy w a = featureEnergy w (representerCoefficients φ w s b) +
      featureEnergy w (fun j => a j - representerCoefficients φ w s b j) := by
  let c := representerCoefficients φ w s b
  have hcross : (∑ j, a j * c j / w j) = featureEnergy w c := by
    calc
      (∑ j, a j * c j / w j) = ∑ i, b i * featureField φ a (s i) :=
        representer_pairing φ w a hw s b
      _ = ∑ i, b i * featureField φ c (s i) := by
        apply Finset.sum_congr rfl
        intro i hi
        rw [hfit i]
      _ = ∑ j, c j * c j / w j := (representer_pairing φ w c hw s b).symm
      _ = featureEnergy w c := by simp only [featureEnergy, pow_two]
  have hexpand : featureEnergy w (fun j => a j - c j) =
      featureEnergy w a + featureEnergy w c - 2 * ∑ j, a j * c j / w j := by
    unfold featureEnergy
    rw [Finset.mul_sum, ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro j hj
    ring
  change featureEnergy w a = featureEnergy w c + featureEnergy w (fun j => a j - c j)
  rw [hexpand, hcross]
  ring

theorem interpolating_representer_minimum_energy (φ : ι → X → ℝ) (w a : ι → ℝ)
    (hw : ∀ j, 0 < w j) (s : κ → X) (b : κ → ℝ)
    (hfit : ∀ i, featureField φ a (s i) =
      featureField φ (representerCoefficients φ w s b) (s i)) :
    finiteQuadratic (fun i j => featureKernel φ w (s i) (s j)) b ≤
      featureEnergy w a := by
  rw [← representer_energy φ w (fun j => ne_of_gt (hw j)) s b]
  rw [interpolating_representer_pythagoras φ w a (fun j => ne_of_gt (hw j)) s b hfit]
  exact le_add_of_nonneg_right (featureEnergy_nonneg _ _ (fun j => (hw j).le))

end Interpolation

section Projection

variable {ι X : Type*} [Fintype ι]

def maskCoefficients (A : Finset ι) (a : ι → ℝ) (j : ι) : ℝ := by
  classical
  exact if j ∈ A then a j else 0

theorem featureEnergy_mask_le (w a : ι → ℝ) (hw : ∀ j, 0 ≤ w j)
    (A : Finset ι) : featureEnergy w (maskCoefficients A a) ≤ featureEnergy w a := by
  classical
  apply Finset.sum_le_sum
  intro j hj
  by_cases hA : j ∈ A
  · simp [maskCoefficients, hA]
  · simpa [maskCoefficients, hA] using div_nonneg (sq_nonneg (a j)) (hw j)

theorem featureEnergy_decomposition [DecidableEq ι] (w a : ι → ℝ) (A : Finset ι) :
    featureEnergy w a = featureEnergy w (maskCoefficients A a) +
      featureEnergy w (maskCoefficients (Finset.univ \ A) a) := by
  classical
  unfold featureEnergy
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  by_cases hA : j ∈ A <;> simp [maskCoefficients, hA]

theorem featureField_decomposition [DecidableEq ι] (φ : ι → X → ℝ) (a : ι → ℝ)
    (A : Finset ι) (x : X) :
    featureField φ a x = featureField φ (maskCoefficients A a) x +
      featureField φ (maskCoefficients (Finset.univ \ A) a) x := by
  classical
  unfold featureField
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  by_cases hA : j ∈ A <;> simp [maskCoefficients, hA]

theorem masked_coefficients_square_le_energy (w a : ι → ℝ)
    (hw : ∀ j, 0 < w j) (A : Finset ι) (ell : ℝ) (hell : 0 ≤ ell)
    (hmax : ∀ j ∈ A, w j ≤ ell) :
    (∑ j, maskCoefficients A a j ^ 2) ≤ ell * featureEnergy w a := by
  classical
  unfold featureEnergy
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro j hj
  by_cases hA : j ∈ A
  · simp only [maskCoefficients, if_pos hA]
    calc
      a j ^ 2 = w j * (a j ^ 2 / w j) := by field_simp [ne_of_gt (hw j)]
      _ ≤ ell * (a j ^ 2 / w j) :=
        mul_le_mul_of_nonneg_right (hmax j hA) (div_nonneg (sq_nonneg _) (hw j).le)
  · simp only [maskCoefficients, if_neg hA, zero_pow (by norm_num : 2 ≠ 0)]
    exact mul_nonneg hell (div_nonneg (sq_nonneg _) (hw j).le)

end Projection

section WalshTails

variable {d : ℕ}

theorem uniformCubeMean_walshExpansion_sq (a : Finset (Fin d) → ℝ) :
    uniformCubeMean (fun x => walshExpansion a x ^ 2) = ∑ S, a S ^ 2 := by
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold uniformCubeMean
  rw [walshExpansion_parseval]
  field_simp [hM]

/-- Population tail bound in normalized Walsh coordinates. For the
paper's cutoff use `A = {S : r < |S|}` and `ell = lambda_(r+1)`. -/
theorem walsh_tail_population_square_le (w a : Finset (Fin d) → ℝ)
    (hw : ∀ S, 0 < w S) (A : Finset (Finset (Fin d)))
    (ell : ℝ) (hell : 0 ≤ ell) (hmax : ∀ S ∈ A, w S ≤ ell) :
    uniformCubeMean (fun x => walshExpansion (maskCoefficients A a) x ^ 2) ≤
      ell * featureEnergy w a := by
  rw [uniformCubeMean_walshExpansion_sq]
  exact masked_coefficients_square_le_energy w a hw A ell hell hmax

def restrictedWalshFeature (A : Finset (Finset (Fin d)))
    (S : Finset (Fin d)) (x : ClippingCube d) : ℝ :=
  if S ∈ A then walshCharacter S x else 0

def walshTailKernel (A : Finset (Finset (Fin d))) (w : Finset (Fin d) → ℝ)
    (x y : ClippingCube d) : ℝ :=
  ∑ S ∈ A, w S * walshCharacter S x * walshCharacter S y

theorem featureField_restrictedWalsh (A : Finset (Finset (Fin d)))
    (a : Finset (Fin d) → ℝ) (x : ClippingCube d) :
    featureField (restrictedWalshFeature A) a x =
      walshExpansion (maskCoefficients A a) x := by
  classical
  unfold featureField walshExpansion
  apply Finset.sum_congr rfl
  intro S hS
  by_cases hA : S ∈ A <;> simp [restrictedWalshFeature, maskCoefficients, hA]

theorem featureKernel_restrictedWalsh (A : Finset (Finset (Fin d)))
    (w : Finset (Fin d) → ℝ) (x y : ClippingCube d) :
    featureKernel (restrictedWalshFeature A) w x y = walshTailKernel A w x y := by
  classical
  unfold featureKernel walshTailKernel
  have hterm (S : Finset (Fin d)) :
      w S * restrictedWalshFeature A S x * restrictedWalshFeature A S y =
        if S ∈ A then w S * walshCharacter S x * walshCharacter S y else 0 := by
    by_cases hA : S ∈ A <;> simp [restrictedWalshFeature, hA]
  simp_rw [hterm]
  exact Fintype.sum_ite_mem A _

/-- Exact sampled tail evaluation bound using the full field's energy.
The assumption is the quadratic-form bound for the explicitly defined
tail Gram matrix, as supplied by the paper's separate random-matrix
argument. Samples may repeat. -/
theorem walsh_tail_sample_square_le {κ : Type*} [Fintype κ]
    (w a : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (A : Finset (Finset (Fin d))) (s : κ → ClippingCube d)
    (G : ℝ) (hG : 0 ≤ G)
    (hGram : ∀ b : κ → ℝ,
      finiteQuadratic (fun i j => walshTailKernel A w (s i) (s j)) b ≤
        G * ∑ i, b i ^ 2) :
    (∑ i, walshExpansion (maskCoefficients A a) (s i) ^ 2) ≤
      G * featureEnergy w a := by
  have h := sampled_featureField_square_le (restrictedWalshFeature A) w a hw s G hG
    (by simpa only [featureKernel_restrictedWalsh] using hGram)
  simpa only [featureField_restrictedWalsh] using h

end WalshTails

section GaussianPrecision

variable {d : ℕ}

/-- Dual Walsh orthogonality: the character sum is the identity kernel
times the number of cube inputs. -/
theorem walshCharacter_dual_orthogonal (x y : ClippingCube d) :
    (∑ S : Finset (Fin d), walshCharacter S x * walshCharacter S y) =
      if x = y then (Fintype.card (ClippingCube d) : ℝ) else 0 := by
  classical
  by_cases hxy : x = y
  · subst y
    simp only [ite_true, ← pow_two, walshCharacter_sq, Finset.sum_const,
      Finset.card_univ, nsmul_eq_mul, mul_one]
    simp [ClippingCube, Fintype.card_pi]
  · rw [if_neg hxy]
    have hprod : (∑ S : Finset (Fin d), walshCharacter S x * walshCharacter S y) =
        ∏ i, (cubeCoordinateSign (x i) * cubeCoordinateSign (y i) + 1) := by
      unfold walshCharacter
      simp_rw [← Finset.prod_mul_distrib]
      symm
      simpa using Fintype.prod_add
        (fun i => cubeCoordinateSign (x i) * cubeCoordinateSign (y i))
        (fun _ => (1 : ℝ))
    rw [hprod]
    obtain ⟨i, hi⟩ := Function.ne_iff.mp hxy
    apply Finset.prod_eq_zero (Finset.mem_univ i)
    cases hx : x i <;> cases hy : y i <;> simp_all [cubeCoordinateSign]

def walshCoefficients (P : ClippingCube d → ℝ) (S : Finset (Fin d)) : ℝ :=
  uniformCubeMean (fun x => P x * walshCharacter S x)

theorem walshExpansion_pairing (a : Finset (Fin d) → ℝ) (S : Finset (Fin d)) :
    (∑ x : ClippingCube d, walshExpansion a x * walshCharacter S x) =
      (Fintype.card (ClippingCube d) : ℝ) * a S := by
  classical
  unfold walshExpansion
  simp_rw [Finset.sum_mul]
  rw [Finset.sum_comm]
  calc
    (∑ T, ∑ x : ClippingCube d, a T * walshCharacter T x * walshCharacter S x) =
        ∑ T, a T * (∑ x : ClippingCube d, walshCharacter T x * walshCharacter S x) := by
      apply Finset.sum_congr rfl
      intro T hT
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro x hx
      ring
    _ = a S * (Fintype.card (ClippingCube d) : ℝ) := by
      simp_rw [walshCharacter_orthogonal, mul_ite, mul_zero]
      simp
    _ = _ := mul_comm _ _

theorem walshExpansion_coefficients (P : ClippingCube d → ℝ) (x : ClippingCube d) :
    walshExpansion (walshCoefficients P) x = P x := by
  classical
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold walshExpansion walshCoefficients uniformCubeMean
  simp_rw [div_mul_eq_mul_div, Finset.sum_mul]
  rw [← Finset.sum_div, Finset.sum_comm]
  have hinner (y : ClippingCube d) :
      (∑ S : Finset (Fin d), P y * walshCharacter S y * walshCharacter S x) =
        P y * (∑ S : Finset (Fin d), walshCharacter S y * walshCharacter S x) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro S hS
    ring
  simp_rw [hinner, walshCharacter_dual_orthogonal, mul_ite, mul_zero]
  simp

def walshKernel (w : Finset (Fin d) → ℝ) (x y : ClippingCube d) : ℝ :=
  featureKernel walshCharacter w x y

theorem walshKernel_symm (w : Finset (Fin d) → ℝ) (x y : ClippingCube d) :
    walshKernel w x y = walshKernel w y x := by
  unfold walshKernel featureKernel
  apply Finset.sum_congr rfl
  intro S hS
  ring

theorem walshKernel_eq_expansion (w : Finset (Fin d) → ℝ) (x y : ClippingCube d) :
    walshKernel w x y = walshExpansion (fun S => w S * walshCharacter S x) y := rfl

theorem walshKernel_comp (w v : Finset (Fin d) → ℝ) (x y : ClippingCube d) :
    (∑ z : ClippingCube d, walshKernel w x z * walshKernel v z y) =
      (Fintype.card (ClippingCube d) : ℝ) * walshKernel (fun S => w S * v S) x y := by
  calc
    (∑ z : ClippingCube d, walshKernel w x z * walshKernel v z y) =
        ∑ z : ClippingCube d,
          walshExpansion (fun S => w S * walshCharacter S x) z *
          walshExpansion (fun S => v S * walshCharacter S y) z := by
      apply Finset.sum_congr rfl
      intro z hz
      rw [walshKernel_symm v z y, walshKernel_eq_expansion, walshKernel_eq_expansion]
    _ = (Fintype.card (ClippingCube d) : ℝ) *
        ∑ S, (w S * walshCharacter S x) * (v S * walshCharacter S y) :=
      walshExpansion_inner _ _
    _ = _ := by
      congr 1
      apply Finset.sum_congr rfl
      intro S hS
      ring

/-- The explicit inverse covariance kernel. The `M²` is essential:
`w S` is a normalized population eigenvalue, whereas the covariance
matrix eigenvalue is `M * w S`. -/
def walshPrecisionKernel (w : Finset (Fin d) → ℝ) (x y : ClippingCube d) : ℝ :=
  walshKernel (fun S => 1 / ((Fintype.card (ClippingCube d) : ℝ) ^ 2 * w S)) x y

theorem walshKernel_precision_mul (w : Finset (Fin d) → ℝ) (hw : ∀ S, w S ≠ 0)
    (x y : ClippingCube d) :
    (∑ z : ClippingCube d, walshKernel w x z * walshPrecisionKernel w z y) =
      if x = y then (1 : ℝ) else 0 := by
  classical
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold walshPrecisionKernel
  rw [walshKernel_comp]
  have hker : walshKernel
      (fun S => w S * (1 / ((Fintype.card (ClippingCube d) : ℝ) ^ 2 * w S))) x y =
      (1 / (Fintype.card (ClippingCube d) : ℝ) ^ 2) *
        ∑ S : Finset (Fin d), walshCharacter S x * walshCharacter S y := by
    unfold walshKernel featureKernel
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro S hS
    field_simp [hM, hw S]
  rw [hker, walshCharacter_dual_orthogonal]
  by_cases hxy : x = y
  · simp only [if_pos hxy]
    field_simp [hM]
  · simp only [if_neg hxy, mul_zero]

/-- The full precision quadratic form equals the normalized Walsh
coefficient energy. The inverse identity is proved above. -/
theorem walshPrecision_energy_expansion (w a : Finset (Fin d) → ℝ)
    (hw : ∀ S, w S ≠ 0) :
    finiteQuadratic (walshPrecisionKernel w) (walshExpansion a) = featureEnergy w a := by
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold walshPrecisionKernel walshKernel
  rw [show (fun x y : ClippingCube d => featureKernel walshCharacter
      (fun S => 1 / ((Fintype.card (ClippingCube d) : ℝ) ^ 2 * w S)) x y) =
      (fun x y : ClippingCube d => featureKernel walshCharacter
        (fun S => 1 / ((Fintype.card (ClippingCube d) : ℝ) ^ 2 * w S)) (id x) (id y)) from rfl]
  rw [featureKernel_quadratic]
  simp only [id_eq]
  simp_rw [walshExpansion_pairing]
  unfold featureEnergy
  apply Finset.sum_congr rfl
  intro S hS
  field_simp [hM, hw S]

theorem walshPrecision_energy (w : Finset (Fin d) → ℝ) (P : ClippingCube d → ℝ)
    (hw : ∀ S, w S ≠ 0) :
    finiteQuadratic (walshPrecisionKernel w) P = featureEnergy w (walshCoefficients P) := by
  have hP : walshExpansion (walshCoefficients P) = P :=
    funext (walshExpansion_coefficients P)
  simpa only [hP] using walshPrecision_energy_expansion w (walshCoefficients P) hw

end GaussianPrecision

section FunctionProjections

variable {d : ℕ}

def walshProjection (A : Finset (Finset (Fin d))) (P : ClippingCube d → ℝ)
    (x : ClippingCube d) : ℝ :=
  walshExpansion (maskCoefficients A (walshCoefficients P)) x

theorem walshProjection_decomposition (A : Finset (Finset (Fin d)))
    (P : ClippingCube d → ℝ) (x : ClippingCube d) :
    P x = walshProjection A P x + walshProjection (Finset.univ \ A) P x := by
  rw [← walshExpansion_coefficients P x]
  exact featureField_decomposition walshCharacter (walshCoefficients P) A x

/-- Exact low/high energy decomposition of an arbitrary cube function,
expressed using the actual inverse covariance quadratic form. -/
theorem walshProjection_precision_decomposition (w : Finset (Fin d) → ℝ)
    (hw : ∀ S, w S ≠ 0) (A : Finset (Finset (Fin d)))
    (P : ClippingCube d → ℝ) :
    finiteQuadratic (walshPrecisionKernel w) P =
      finiteQuadratic (walshPrecisionKernel w) (walshProjection A P) +
      finiteQuadratic (walshPrecisionKernel w) (walshProjection (Finset.univ \ A) P) := by
  rw [walshPrecision_energy w P hw]
  unfold walshProjection
  rw [walshPrecision_energy_expansion w _ hw, walshPrecision_energy_expansion w _ hw]
  exact featureEnergy_decomposition w (walshCoefficients P) A

theorem walshProjection_population_square_le (w : Finset (Fin d) → ℝ)
    (hw : ∀ S, 0 < w S) (A : Finset (Finset (Fin d))) (P : ClippingCube d → ℝ)
    (ell : ℝ) (hell : 0 ≤ ell) (hmax : ∀ S ∈ A, w S ≤ ell) :
    uniformCubeMean (fun x => walshProjection A P x ^ 2) ≤
      ell * finiteQuadratic (walshPrecisionKernel w) P := by
  rw [walshPrecision_energy w P (fun S => ne_of_gt (hw S))]
  exact walsh_tail_population_square_le w (walshCoefficients P) hw A ell hell hmax

theorem walshProjection_sample_square_le {κ : Type*} [Fintype κ]
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (A : Finset (Finset (Fin d))) (P : ClippingCube d → ℝ)
    (s : κ → ClippingCube d) (G : ℝ) (hG : 0 ≤ G)
    (hGram : ∀ b : κ → ℝ,
      finiteQuadratic (fun i j => walshTailKernel A w (s i) (s j)) b ≤
        G * ∑ i, b i ^ 2) :
    (∑ i, walshProjection A P (s i) ^ 2) ≤
      G * finiteQuadratic (walshPrecisionKernel w) P := by
  rw [walshPrecision_energy w P (fun S => ne_of_gt (hw S))]
  exact walsh_tail_sample_square_le w (walshCoefficients P) hw A s G hG hGram

end FunctionProjections

end NeuralGeneralization
