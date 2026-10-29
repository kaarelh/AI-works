import TwoBallGeometry
import FiniteMaurey

open scoped BigOperators RealInnerProductSpace

namespace BooleanDepthResearch

noncomputable section
set_option linter.unusedSectionVars false

variable {I E F : Type*} [Fintype I]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F] [FiniteDimensional ℝ F]

/-- The linear map with the given incoming row vectors. -/
def rowMap (w : I → E) : E →ₗ[ℝ] EuclideanSpace ℝ I where
  toFun x := WithLp.toLp 2 (fun i ↦ ⟪w i, x⟫)
  map_add' x y := by ext i; simp [inner_add_right]
  map_smul' r x := by ext i; simp [inner_smul_right]

@[simp] lemma rowMap_apply (w : I → E) (x : E) (i : I) : rowMap w x i = ⟪w i, x⟫ := rfl

/-- The linear map with the given outgoing column vectors. -/
def columnMap (v : I → F) : EuclideanSpace ℝ I →ₗ[ℝ] F where
  toFun x := ∑ i, x i • v i
  map_add' x y := by simp [add_smul, Finset.sum_add_distrib]
  map_smul' r x := by simp [Finset.smul_sum, smul_smul]

@[simp] lemma columnMap_apply (v : I → F) (x : EuclideanSpace ℝ I) :
    columnMap v x = ∑ i, x i • v i := rfl

lemma frobeniusSq_rowMap (w : I → E) : frobeniusSq (rowMap w) = ∑ i, ‖w i‖ ^ 2 := by
  let b := stdOrthonormalBasis ℝ E
  rw [frobeniusSq_eq_sum_norm_sq _ b]
  simp_rw [EuclideanSpace.real_norm_sq_eq, rowMap_apply]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  exact b.sum_sq_inner_left (w i)

lemma columnMap_basis (v : I → F) (i : I) :
    columnMap v (EuclideanSpace.basisFun I ℝ i) = v i := by
  classical
  simp [columnMap, EuclideanSpace.basisFun_apply]

lemma frobeniusSq_columnMap (v : I → F) : frobeniusSq (columnMap v) = ∑ i, ‖v i‖ ^ 2 := by
  rw [frobeniusSq_eq_sum_norm_sq _ (EuclideanSpace.basisFun I ℝ)]
  simp only [columnMap_basis]

lemma rowMap_adjoint_basis (W : E →ₗ[ℝ] EuclideanSpace ℝ I) :
    rowMap (fun i ↦ W.adjoint (EuclideanSpace.basisFun I ℝ i)) = W := by
  ext x i
  simp [LinearMap.adjoint_inner_left, EuclideanSpace.basisFun_inner]

lemma columnMap_image_basis (V : EuclideanSpace ℝ I →ₗ[ℝ] F) :
    columnMap (fun i ↦ V (EuclideanSpace.basisFun I ℝ i)) = V := by
  ext x
  simpa [map_sum, map_smul, EuclideanSpace.basisFun_repr] using
    congrArg V ((EuclideanSpace.basisFun I ℝ).sum_repr x)

/-- The importance mass is bounded by the adjacent Frobenius product. -/
lemma importanceMass_le_frobenius (w : I → E) (v : I → F) :
    (∑ i, ‖w i‖ * ‖v i‖) ≤ frobeniusNorm (rowMap w) * frobeniusNorm (columnMap v) := by
  simpa only [frobeniusNorm, frobeniusSq_rowMap, frobeniusSq_columnMap] using
    Real.sum_mul_le_sqrt_mul_sqrt Finset.univ (fun i ↦ ‖w i‖) (fun i ↦ ‖v i‖)

/-- Positive rescaling of a scalar activation. -/
def rescaleActivation (a : ℝ) (φ : ℝ → ℝ) (t : ℝ) : ℝ := a⁻¹ * φ (a * t)

lemma rescaleActivation_zero (a : ℝ) (φ : ℝ → ℝ) (hφ0 : φ 0 = 0) :
    rescaleActivation a φ 0 = 0 := by simp [rescaleActivation, hφ0]

lemma rescaleActivation_lipschitz (a : ℝ) (ha : 0 < a) (φ : ℝ → ℝ)
    (hφ : LipschitzWith 1 φ) : LipschitzWith 1 (rescaleActivation a φ) := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  simp only [NNReal.coe_one, one_mul, Real.dist_eq, rescaleActivation, ← mul_sub, abs_mul,
    abs_inv, abs_of_pos ha]
  have h := hφ.dist_le_mul (a * x) (a * y)
  simp only [NNReal.coe_one, one_mul, Real.dist_eq, ← mul_sub, abs_mul, abs_of_pos ha] at h
  have h' := mul_le_mul_of_nonneg_left h (inv_nonneg.mpr ha.le)
  simpa only [← mul_assoc, inv_mul_cancel₀ (ne_of_gt ha), one_mul] using h'

lemma rescaleActivation_abs_le (a : ℝ) (ha : 0 < a) (φ : ℝ → ℝ)
    (hφ0 : φ 0 = 0) (hφ : LipschitzWith 1 φ) (t : ℝ) :
    |rescaleActivation a φ t| ≤ |t| := by
  simpa [Real.dist_eq, rescaleActivation_zero a φ hφ0] using
    (rescaleActivation_lipschitz a ha φ hφ).dist_le_mul t 0

/-- The same adjacent Frobenius product for every sample, including repeated indices. -/
theorem sampled_frobenius_product {m : ℕ} (hm : 0 < m) (u : Fin m → E) (d : Fin m → F)
    (hu : ∀ j, ‖u j‖ = 1) (hd : ∀ j, ‖d j‖ = 1) (A : ℝ) (hA : 0 ≤ A) :
    frobeniusNorm (rowMap u) * frobeniusNorm (columnMap (fun j ↦ (A / m) • d j)) = A := by
  have hmR : (m : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.ne_of_gt hm)
  apply (sq_eq_sq₀ (mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)) hA).mp
  change (frobeniusNorm (rowMap u) * frobeniusNorm (columnMap (fun j ↦ (A / m) • d j))) ^ 2 = A ^ 2
  rw [mul_pow, frobeniusNorm_sq, frobeniusNorm_sq, frobeniusSq_rowMap, frobeniusSq_columnMap]
  simp only [hu, hd, norm_smul, Real.norm_eq_abs, mul_one, sq_abs, one_pow,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  field_simp

/-- A unit row or column direction. -/
def unitDirection {G : Type*} [NormedAddCommGroup G] [NormedSpace ℝ G] (v : G) : G := ‖v‖⁻¹ • v

lemma norm_unitDirection {G : Type*} [NormedAddCommGroup G] [NormedSpace ℝ G]
    (v : G) (hv : v ≠ 0) : ‖unitDirection v‖ = 1 := by
  rw [unitDirection, norm_smul, Real.norm_eq_abs, abs_inv, abs_of_nonneg (norm_nonneg _)]
  exact inv_mul_cancel₀ (norm_ne_zero_iff.mpr hv)

/-- The unaveraged importance-sampling feature. -/
def importanceAtom (A : ℝ) (w : E) (v : F) (φ : ℝ → ℝ) (x : E) : F :=
  (A * rescaleActivation ‖w‖ φ ⟪unitDirection w, x⟫) • unitDirection v

lemma importanceAtom_norm_le (A : ℝ) (hA : 0 ≤ A) (w : E) (hw : w ≠ 0)
    (v : F) (hv : v ≠ 0) (φ : ℝ → ℝ) (hφ0 : φ 0 = 0) (hφ : LipschitzWith 1 φ)
    (x : E) : ‖importanceAtom A w v φ x‖ ≤ A * ‖x‖ := by
  rw [importanceAtom, norm_smul, Real.norm_eq_abs, norm_unitDirection v hv, mul_one,
    abs_mul, abs_of_nonneg hA]
  apply mul_le_mul_of_nonneg_left _ hA
  apply (rescaleActivation_abs_le ‖w‖ (norm_pos_iff.mpr hw) φ hφ0 hφ _).trans
  simpa only [norm_unitDirection w hw, one_mul] using abs_real_inner_le_norm (unitDirection w) x

lemma importanceAtom_unbiased (A : ℝ) (hA : A ≠ 0) (w : E) (hw : w ≠ 0)
    (v : F) (hv : v ≠ 0) (φ : ℝ → ℝ) (x : E) :
    (‖w‖ * ‖v‖ / A) • importanceAtom A w v φ x = φ ⟪w, x⟫ • v := by
  have ha : ‖w‖ ≠ 0 := norm_ne_zero_iff.mpr hw
  have hb : ‖v‖ ≠ 0 := norm_ne_zero_iff.mpr hv
  have harg : ‖w‖ * ⟪unitDirection w, x⟫ = ⟪w, x⟫ := by
    simp [unitDirection, real_inner_smul_left, ha]
  rw [importanceAtom, rescaleActivation, harg]
  simp only [unitDirection, smul_smul]
  congr 1
  field_simp

/-- Apply scalar activations coordinatewise. -/
def coordinateActivation (φ : I → ℝ → ℝ) (x : EuclideanSpace ℝ I) : EuclideanSpace ℝ I :=
  WithLp.toLp 2 (fun i ↦ φ i (x i))

@[simp] lemma coordinateActivation_apply (φ : I → ℝ → ℝ) (x : EuclideanSpace ℝ I) (i : I) :
    coordinateActivation φ x i = φ i (x i) := rfl

lemma two_layer_eval (w : I → E) (v : I → F) (φ : I → ℝ → ℝ) (x : E) :
    columnMap v (coordinateActivation φ (rowMap w x)) = ∑ i, φ i ⟪w i, x⟫ • v i := rfl

/-- Full one-step Maurey compression for active neurons. The width is exactly m,
the adjacent Frobenius product never increases, and the same sampled neurons
approximate every input in the finite set. Zero-contribution neurons can first
be deleted, as shown by `zero_neuron_contribution` below. -/
theorem maurey_two_layer_compression {K : Type*} [Fintype K] [Nonempty K] [Nonempty I]
    (w : I → E) (v : I → F) (hw : ∀ i, w i ≠ 0) (hv : ∀ i, v i ≠ 0)
    (φ : I → ℝ → ℝ) (hφ0 : ∀ i, φ i 0 = 0) (hφ : ∀ i, LipschitzWith 1 (φ i))
    (x : K → E) (R ε : ℝ) (hR : 0 < R) (hε : 0 < ε) (hx : ∀ k, ‖x k‖ ≤ R)
    (m : ℕ) (hm : 0 < m)
    (hbudget : 64 * ((∑ i, ‖w i‖ * ‖v i‖) * R) ^ 2 *
      (1 + Real.log (Fintype.card K)) ≤ (m : ℝ) * ε ^ 2) :
    ∃ (W' : E →ₗ[ℝ] EuclideanSpace ℝ (Fin m))
      (V' : EuclideanSpace ℝ (Fin m) →ₗ[ℝ] F) (ψ : Fin m → ℝ → ℝ),
      (∀ j, ψ j 0 = 0) ∧ (∀ j, LipschitzWith 1 (ψ j)) ∧
      frobeniusNorm W' * frobeniusNorm V' ≤
        frobeniusNorm (rowMap w) * frobeniusNorm (columnMap v) ∧
      ∀ k, ‖V' (coordinateActivation ψ (W' (x k))) -
        columnMap v (coordinateActivation φ (rowMap w (x k)))‖ < ε := by
  classical
  let A : ℝ := ∑ i, ‖w i‖ * ‖v i‖
  have hA : 0 < A := Finset.sum_pos
    (fun i _ ↦ mul_pos (norm_pos_iff.mpr (hw i)) (norm_pos_iff.mpr (hv i))) Finset.univ_nonempty
  let p : I → ℝ := fun i ↦ ‖w i‖ * ‖v i‖ / A
  have hp0 : ∀ i, 0 ≤ p i := fun i ↦ div_nonneg
    (mul_nonneg (norm_nonneg _) (norm_nonneg _)) hA.le
  have hp : ∑ i, p i = 1 := by
    dsimp [p]
    rw [← Finset.sum_div]
    exact div_self (ne_of_gt hA)
  let Y : K → I → F := fun k i ↦ importanceAtom A (w i) (v i) (φ i) (x k)
  have hY : ∀ k i, ‖Y k i‖ ≤ A * R := by
    intro k i
    exact (importanceAtom_norm_le A hA.le (w i) (hw i) (v i) (hv i) (φ i) (hφ0 i)
      (hφ i) (x k)).trans (mul_le_mul_of_nonneg_left (hx k) hA.le)
  obtain ⟨s, hs⟩ := FiniteProbability.finite_input_maurey p hp0 hp Y (A * R) ε
    (mul_pos hA hR) hε hY m hm hbudget
  let u : Fin m → E := fun j ↦ unitDirection (w (s j))
  let d : Fin m → F := fun j ↦ unitDirection (v (s j))
  let ψ : Fin m → ℝ → ℝ := fun j ↦ rescaleActivation ‖w (s j)‖ (φ (s j))
  refine ⟨rowMap u, columnMap (fun j ↦ (A / m) • d j), ψ, ?_, ?_, ?_, ?_⟩
  · intro j
    exact rescaleActivation_zero _ _ (hφ0 (s j))
  · intro j
    exact rescaleActivation_lipschitz _ (norm_pos_iff.mpr (hw (s j))) _ (hφ (s j))
  · rw [sampled_frobenius_product hm u d
      (fun j ↦ norm_unitDirection _ (hw (s j)))
      (fun j ↦ norm_unitDirection _ (hv (s j))) A hA.le]
    exact importanceMass_le_frobenius w v
  · intro k
    have hold : FiniteProbability.vectorAvg p (Y k) =
        columnMap v (coordinateActivation φ (rowMap w (x k))) := by
      rw [two_layer_eval]
      apply Finset.sum_congr rfl
      intro i _
      exact importanceAtom_unbiased A (ne_of_gt hA) (w i) (hw i) (v i) (hv i) (φ i) (x k)
    have hnew : columnMap (fun j ↦ (A / m) • d j)
        (coordinateActivation ψ (rowMap u (x k))) = (m : ℝ)⁻¹ • ∑ j, Y k (s j) := by
      rw [two_layer_eval, Finset.smul_sum]
      apply Finset.sum_congr rfl
      intro j _
      dsimp [u, d, ψ, Y, importanceAtom]
      simp only [smul_smul]
      congr 1
      ring
    rw [hnew, ← hold]
    exact hs k

/-- Removing a zero incoming row or a zero outgoing column changes no output. -/
lemma zero_neuron_contribution (w : E) (v : F) (φ : ℝ → ℝ) (hφ0 : φ 0 = 0)
    (hzero : w = 0 ∨ v = 0) (x : E) : φ ⟪w, x⟫ • v = 0 := by
  rcases hzero with rfl | rfl <;> simp [hφ0]

lemma rescaleActivation_lipschitz_nonneg (a : ℝ) (ha : 0 ≤ a) (φ : ℝ → ℝ)
    (hφ : LipschitzWith 1 φ) : LipschitzWith 1 (rescaleActivation a φ) := by
  rcases eq_or_lt_of_le ha with rfl | ha
  · apply LipschitzWith.of_dist_le_mul
    intro x y
    simp [rescaleActivation]
  · exact rescaleActivation_lipschitz a ha φ hφ

lemma norm_unitDirection_le {G : Type*} [NormedAddCommGroup G] [NormedSpace ℝ G]
    (v : G) : ‖unitDirection v‖ ≤ 1 := by
  by_cases hv : v = 0
  · simp [hv, unitDirection]
  · exact (norm_unitDirection v hv).le

lemma importanceAtom_norm_le_all (A : ℝ) (hA : 0 ≤ A) (w : E) (v : F)
    (φ : ℝ → ℝ) (hφ0 : φ 0 = 0) (hφ : LipschitzWith 1 φ) (x : E) :
    ‖importanceAtom A w v φ x‖ ≤ A * ‖x‖ := by
  by_cases hw : w = 0
  · simp [importanceAtom, hw, rescaleActivation, mul_nonneg hA (norm_nonneg x)]
  by_cases hv : v = 0
  · simp [importanceAtom, hv, unitDirection, mul_nonneg hA (norm_nonneg x)]
  exact importanceAtom_norm_le A hA w hw v hv φ hφ0 hφ x

lemma importanceAtom_unbiased_all (A : ℝ) (hA : A ≠ 0) (w : E) (v : F)
    (φ : ℝ → ℝ) (hφ0 : φ 0 = 0) (x : E) :
    (‖w‖ * ‖v‖ / A) • importanceAtom A w v φ x = φ ⟪w, x⟫ • v := by
  by_cases hw : w = 0
  · simp [hw, hφ0]
  by_cases hv : v = 0
  · simp [hv]
  exact importanceAtom_unbiased A hA w hw v hv φ x

lemma sampled_frobenius_product_le {m : ℕ} (hm : 0 < m) (u : Fin m → E) (d : Fin m → F)
    (hu : ∀ j, ‖u j‖ ≤ 1) (hd : ∀ j, ‖d j‖ ≤ 1) (A : ℝ) (hA : 0 ≤ A) :
    frobeniusNorm (rowMap u) * frobeniusNorm (columnMap (fun j ↦ (A / m) • d j)) ≤ A := by
  have hmR : (m : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.ne_of_gt hm)
  have hrow : frobeniusSq (rowMap u) ≤ m := by
    rw [frobeniusSq_rowMap]
    calc
      _ ≤ ∑ _ : Fin m, (1 : ℝ) := Finset.sum_le_sum fun j _ ↦ by
        nlinarith [norm_nonneg (u j), hu j]
      _ = _ := by simp
  have hcol : frobeniusSq (columnMap (fun j ↦ (A / m) • d j)) ≤ (m : ℝ) * (A / m) ^ 2 := by
    rw [frobeniusSq_columnMap]
    calc
      _ ≤ ∑ _ : Fin m, (A / m) ^ 2 := by
        apply Finset.sum_le_sum
        intro j _
        rw [norm_smul, mul_pow, Real.norm_eq_abs, sq_abs]
        have hj : ‖d j‖ ^ 2 ≤ 1 := by nlinarith [norm_nonneg (d j), hd j]
        simpa using mul_le_mul_of_nonneg_left hj (sq_nonneg (A / m))
      _ = _ := by simp
  apply (sq_le_sq₀ (mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)) hA).mp
  change (frobeniusNorm (rowMap u) * frobeniusNorm (columnMap (fun j ↦ (A / m) • d j))) ^ 2 ≤ A ^ 2
  rw [mul_pow, frobeniusNorm_sq, frobeniusNorm_sq]
  apply (mul_le_mul hrow hcol (frobeniusSq_nonneg _) (Nat.cast_nonneg m)).trans_eq
  field_simp

/-- Full one-step compression, including zero rows, columns, and zero maps. -/
theorem maurey_two_layer_compression_all {K : Type*} [Fintype K] [Nonempty K]
    (w : I → E) (v : I → F) (φ : I → ℝ → ℝ)
    (hφ0 : ∀ i, φ i 0 = 0) (hφ : ∀ i, LipschitzWith 1 (φ i))
    (x : K → E) (R ε : ℝ) (hR : 0 < R) (hε : 0 < ε) (hx : ∀ k, ‖x k‖ ≤ R)
    (m : ℕ) (hm : 0 < m)
    (hbudget : 64 * ((∑ i, ‖w i‖ * ‖v i‖) * R) ^ 2 *
      (1 + Real.log (Fintype.card K)) ≤ (m : ℝ) * ε ^ 2) :
    ∃ (W' : E →ₗ[ℝ] EuclideanSpace ℝ (Fin m))
      (V' : EuclideanSpace ℝ (Fin m) →ₗ[ℝ] F) (ψ : Fin m → ℝ → ℝ),
      (∀ j, ψ j 0 = 0) ∧ (∀ j, LipschitzWith 1 (ψ j)) ∧
      frobeniusNorm W' * frobeniusNorm V' ≤
        frobeniusNorm (rowMap w) * frobeniusNorm (columnMap v) ∧
      ∀ k, ‖V' (coordinateActivation ψ (W' (x k))) -
        columnMap v (coordinateActivation φ (rowMap w (x k)))‖ < ε := by
  classical
  let A : ℝ := ∑ i, ‖w i‖ * ‖v i‖
  have hA0 : 0 ≤ A := Finset.sum_nonneg fun i _ ↦ mul_nonneg (norm_nonneg _) (norm_nonneg _)
  rcases eq_or_lt_of_le hA0 with hAz | hA
  · have hzero : ∀ i, w i = 0 ∨ v i = 0 := by
      intro i
      have hle : ‖w i‖ * ‖v i‖ ≤ A := Finset.single_le_sum
        (fun j _ ↦ mul_nonneg (norm_nonneg (w j)) (norm_nonneg (v j))) (Finset.mem_univ i)
      have hp : ‖w i‖ * ‖v i‖ = 0 := le_antisymm (by linarith) (by positivity)
      rcases mul_eq_zero.mp hp with hw | hv
      · exact Or.inl (norm_eq_zero.mp hw)
      · exact Or.inr (norm_eq_zero.mp hv)
    have hold : ∀ y : E, columnMap v (coordinateActivation φ (rowMap w y)) = 0 := by
      intro y
      rw [two_layer_eval]
      exact Finset.sum_eq_zero fun i _ ↦ zero_neuron_contribution (w i) (v i) (φ i) (hφ0 i) (hzero i) y
    refine ⟨rowMap (fun _ : Fin m ↦ (0 : E)), columnMap (fun _ : Fin m ↦ (0 : F)),
      (fun _ _ ↦ 0), (fun _ ↦ rfl), ?_, ?_, ?_⟩
    · intro j
      exact LipschitzWith.of_dist_le_mul fun _ _ ↦ by simp
    · simp only [frobeniusNorm, frobeniusSq_rowMap, frobeniusSq_columnMap, norm_zero,
        zero_pow (by norm_num : (2 : ℕ) ≠ 0), Finset.sum_const_zero, Real.sqrt_zero, zero_mul]
      positivity
    · intro k
      rw [hold]
      simpa [columnMap] using hε
  · let p : I → ℝ := fun i ↦ ‖w i‖ * ‖v i‖ / A
    have hp0 : ∀ i, 0 ≤ p i := fun i ↦ div_nonneg
      (mul_nonneg (norm_nonneg _) (norm_nonneg _)) hA.le
    have hp : ∑ i, p i = 1 := by
      dsimp [p]
      rw [← Finset.sum_div]
      exact div_self (ne_of_gt hA)
    let Y : K → I → F := fun k i ↦ importanceAtom A (w i) (v i) (φ i) (x k)
    have hY : ∀ k i, ‖Y k i‖ ≤ A * R := by
      intro k i
      exact (importanceAtom_norm_le_all A hA.le (w i) (v i) (φ i) (hφ0 i) (hφ i) (x k)).trans
        (mul_le_mul_of_nonneg_left (hx k) hA.le)
    obtain ⟨s, hs⟩ := FiniteProbability.finite_input_maurey p hp0 hp Y (A * R) ε
      (mul_pos hA hR) hε hY m hm hbudget
    let u : Fin m → E := fun j ↦ unitDirection (w (s j))
    let d : Fin m → F := fun j ↦ unitDirection (v (s j))
    let ψ : Fin m → ℝ → ℝ := fun j ↦ rescaleActivation ‖w (s j)‖ (φ (s j))
    refine ⟨rowMap u, columnMap (fun j ↦ (A / m) • d j), ψ, ?_, ?_, ?_, ?_⟩
    · intro j
      exact rescaleActivation_zero _ _ (hφ0 (s j))
    · intro j
      exact rescaleActivation_lipschitz_nonneg _ (norm_nonneg _) _ (hφ (s j))
    · exact (sampled_frobenius_product_le hm u d
        (fun _ ↦ norm_unitDirection_le _) (fun _ ↦ norm_unitDirection_le _) A hA.le).trans
        (importanceMass_le_frobenius w v)
    · intro k
      have hold : FiniteProbability.vectorAvg p (Y k) =
          columnMap v (coordinateActivation φ (rowMap w (x k))) := by
        rw [two_layer_eval]
        apply Finset.sum_congr rfl
        intro i _
        exact importanceAtom_unbiased_all A (ne_of_gt hA) (w i) (v i) (φ i) (hφ0 i) (x k)
      have hnew : columnMap (fun j ↦ (A / m) • d j)
          (coordinateActivation ψ (rowMap u (x k))) = (m : ℝ)⁻¹ • ∑ j, Y k (s j) := by
        rw [two_layer_eval, Finset.smul_sum]
        apply Finset.sum_congr rfl
        intro j _
        dsimp [u, d, ψ, Y, importanceAtom]
        simp only [smul_smul]
        congr 1
        ring
      rw [hnew, ← hold]
      exact hs k

/-- One-step compression stated directly for arbitrary rectangular linear maps,
with sample budget expressed in the conventional adjacent Frobenius product. -/
theorem maurey_linear_pair {K : Type*} [Fintype K] [Nonempty K]
    (W : E →ₗ[ℝ] EuclideanSpace ℝ I) (V : EuclideanSpace ℝ I →ₗ[ℝ] F)
    (φ : I → ℝ → ℝ) (hφ0 : ∀ i, φ i 0 = 0) (hφ : ∀ i, LipschitzWith 1 (φ i))
    (x : K → E) (R ε : ℝ) (hR : 0 < R) (hε : 0 < ε) (hx : ∀ k, ‖x k‖ ≤ R)
    (m : ℕ) (hm : 0 < m)
    (hbudget : 64 * (frobeniusNorm W * frobeniusNorm V * R) ^ 2 *
      (1 + Real.log (Fintype.card K)) ≤ (m : ℝ) * ε ^ 2) :
    ∃ (W' : E →ₗ[ℝ] EuclideanSpace ℝ (Fin m))
      (V' : EuclideanSpace ℝ (Fin m) →ₗ[ℝ] F) (ψ : Fin m → ℝ → ℝ),
      (∀ j, ψ j 0 = 0) ∧ (∀ j, LipschitzWith 1 (ψ j)) ∧
      frobeniusNorm W' * frobeniusNorm V' ≤ frobeniusNorm W * frobeniusNorm V ∧
      ∀ k, ‖V' (coordinateActivation ψ (W' (x k))) - V (coordinateActivation φ (W (x k)))‖ < ε := by
  let w : I → E := fun i ↦ W.adjoint (EuclideanSpace.basisFun I ℝ i)
  let v : I → F := fun i ↦ V (EuclideanSpace.basisFun I ℝ i)
  have hW : rowMap w = W := rowMap_adjoint_basis W
  have hV : columnMap v = V := columnMap_image_basis V
  have hmass : ∑ i, ‖w i‖ * ‖v i‖ ≤ frobeniusNorm W * frobeniusNorm V := by
    simpa only [hW, hV] using importanceMass_le_frobenius w v
  have hmass0 : 0 ≤ ∑ i, ‖w i‖ * ‖v i‖ :=
    Finset.sum_nonneg fun i _ ↦ mul_nonneg (norm_nonneg _) (norm_nonneg _)
  have hB0 : 0 ≤ frobeniusNorm W * frobeniusNorm V := mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  have hN1 : (1 : ℝ) ≤ Fintype.card K := by exact_mod_cast Fintype.card_pos
  have hL0 : 0 ≤ 1 + Real.log (Fintype.card K) := by linarith [Real.log_nonneg hN1]
  have hb : 64 * ((∑ i, ‖w i‖ * ‖v i‖) * R) ^ 2 *
      (1 + Real.log (Fintype.card K)) ≤ (m : ℝ) * ε ^ 2 := by
    apply le_trans _ hbudget
    apply mul_le_mul_of_nonneg_right _ hL0
    apply mul_le_mul_of_nonneg_left _ (by norm_num)
    exact (sq_le_sq₀ (mul_nonneg hmass0 hR.le) (mul_nonneg hB0 hR.le)).mpr
      (mul_le_mul_of_nonneg_right hmass hR.le)
  simpa only [hW, hV] using maurey_two_layer_compression_all w v φ hφ0 hφ x R ε hR hε hx m hm hb

#print axioms maurey_linear_pair

#print axioms maurey_two_layer_compression

end
end BooleanDepthResearch
