import NeuralGeneralization.RobustCompressionRows

/-! # Deterministic bounds for the actual sampled active feature vector -/
noncomputable section
open Matrix
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionActiveFeature
open RobustCompressionClipping RobustCompressionRows RobustCompressionCovariance
variable {N m q : ℕ}

/-- Uniform coordinate errors of size a/(q+1) imply Euclidean error at most a. -/
theorem norm_le_of_coordinate_bound (v : EuclideanSpace ℝ (Fin q))
    {a : ℝ} (ha : 0 ≤ a) (hv : ∀ j, |v j| ≤ a / ((q : ℝ)+1)) : ‖v‖ ≤ a := by
  have hb : 0 ≤ a / ((q : ℝ)+1) := by positivity
  have hqb : (q : ℝ) * (a / ((q : ℝ)+1)) ≤ a := by
    rw [← mul_div_assoc]
    apply (div_le_iff₀ (by positivity : 0 < (q : ℝ)+1)).mpr
    nlinarith [Nat.cast_nonneg (α := ℝ) q]
  have hba : a / ((q : ℝ)+1) ≤ a := by
    apply (div_le_iff₀ (by positivity : 0 < (q : ℝ)+1)).mpr
    nlinarith [Nat.cast_nonneg (α := ℝ) q]
  have hs : ‖v‖^2 ≤ (q : ℝ)*(a/((q : ℝ)+1))^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    calc
      _ ≤ ∑ _j : Fin q, (a/((q : ℝ)+1))^2 := by
        apply Finset.sum_le_sum
        intro j hj
        nlinarith [hv j, abs_nonneg (v j), sq_abs (v j)]
      _ = _ := by simp
  have hh := mul_le_mul hqb hba hb ha
  apply (sq_le_sq₀ (norm_nonneg v) ha).mp
  nlinarith

/-- The loss due solely to dividing an empirical mean by sqrt(1+a) is ≤a. -/
theorem normalization_error {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (y : E) {a : ℝ} (ha : 0 ≤ a) (hy : ‖y‖^2 ≤ 1+a) :
    ‖(Real.sqrt (1+a))⁻¹ • y - y‖ ≤ a := by
  let s := Real.sqrt (1+a)
  have hs : 1 ≤ s := by
    apply (Real.le_sqrt (by norm_num) (by positivity)).mpr
    nlinarith
  have hsp : 0 < s := lt_of_lt_of_le zero_lt_one hs
  have hs2 : s^2 = 1+a := Real.sq_sqrt (by positivity)
  have hy' : ‖y‖ ≤ s := (sq_le_sq₀ (norm_nonneg y) hsp.le).mp (by simpa [hs2] using hy)
  have hir : s⁻¹ ≤ 1 := (inv_le_one₀ hsp).mpr hs
  have him : s⁻¹ * s = 1 := inv_mul_cancel₀ hsp.ne'
  have heq : s⁻¹ • y - y = (s⁻¹ - 1) • y := by rw [sub_smul, one_smul]
  change ‖s⁻¹ • y - y‖ ≤ a
  rw [heq, norm_smul, Real.norm_eq_abs, abs_of_nonpos (sub_nonpos.mpr hir)]
  have hh := mul_le_mul_of_nonneg_left hy' (by linarith : 0 ≤ -(s⁻¹ - 1))
  nlinarith

/-- Norm control from the actual sampled-source quadratic bound. -/
theorem sampledActive_norm_le_one [NeZero m]
    (c : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (h : Fin N → ℝ) (hh : ∀ i, |h i| ≤ 1) {a : ℝ} (ha : 0 ≤ a)
    (hquad : ∀ v : EuclideanSpace ℝ (Fin q),
      (∑ j, ⟪c (I j), v⟫^2) / (m : ℝ) ≤ (1+a)*‖v‖^2) :
    ‖sampledActive c I h a‖ ≤ 1 := by
  have hy := feature_mean_norm_sq_le (fun j => c (I j)) (fun j => h (I j))
    (fun j => hh (I j)) (by positivity : 0 ≤ 1+a) hquad
  have hs : 0 < Real.sqrt (1+a) := Real.sqrt_pos.mpr (by positivity)
  have hs2 := Real.sq_sqrt (show 0 ≤ 1+a by positivity)
  have hyn : ‖finiteAverage (fun j => h (I j) • c (I j))‖ ≤ Real.sqrt (1+a) :=
    (sq_le_sq₀ (norm_nonneg _) hs.le).mp (by simpa [hs2] using hy)
  unfold sampledActive
  rw [norm_smul, norm_inv, Real.norm_eq_abs, abs_of_pos hs]
  calc
    _ ≤ (Real.sqrt (1+a))⁻¹ * Real.sqrt (1+a) :=
      mul_le_mul_of_nonneg_left hyn (inv_nonneg.mpr hs.le)
    _ = 1 := inv_mul_cancel₀ hs.ne'

/-- Entrywise control of the empirical mean plus clipping gives the paper's
q/T+2a active-feature error. The vector is the literal sampledActive definition. -/
theorem sampledActive_error [NeZero m]
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (h : Fin N → ℝ) (hh : ∀ i, |h i| ≤ 1)
    {a T : ℝ} (ha : 0 ≤ a) (hT : 0 < T)
    (htrace : (∑ i, ‖u i‖^2) / (N : ℝ) ≤ q)
    (hquad : ∀ v : EuclideanSpace ℝ (Fin q),
      (∑ j, ⟪wholeClip T (u (I j)), v⟫^2) / (m : ℝ) ≤ (1+a)*‖v‖^2)
    (hmean : ∀ k, |(finiteAverage (fun j => h (I j) • wholeClip T (u (I j))) -
      finiteAverage (fun i => h i • wholeClip T (u i))) k| ≤ a/((q : ℝ)+1)) :
    ‖sampledActive (fun i => wholeClip T (u i)) I h a -
        finiteAverage (fun i => h i • u i)‖ ≤ (q : ℝ)/T + 2*a := by
  let y := finiteAverage (fun j => h (I j) • wholeClip T (u (I j)))
  let z := finiteAverage (fun i => h i • wholeClip T (u i))
  let v := finiteAverage (fun i => h i • u i)
  have hy := feature_mean_norm_sq_le (fun j => wholeClip T (u (I j)))
    (fun j => h (I j)) (fun j => hh (I j)) (by positivity : 0 ≤ 1+a) hquad
  have hn : ‖(Real.sqrt (1+a))⁻¹ • y - y‖ ≤ a := normalization_error y ha hy
  have he : ‖y-z‖ ≤ a := norm_le_of_coordinate_bound (y-z) ha hmean
  have hc : ‖z-v‖ ≤ (q : ℝ)/T := by
    rw [norm_sub_rev]
    exact (clipped_average_error u h hh T hT).trans (div_le_div_of_nonneg_right htrace hT.le)
  change ‖(Real.sqrt (1+a))⁻¹ • y - v‖ ≤ _
  calc
    _ ≤ ‖(Real.sqrt (1+a))⁻¹ • y - y‖ + ‖y-v‖ := norm_sub_le_norm_sub_add_norm_sub _ _ _
    _ ≤ a + (‖y-z‖ + ‖z-v‖) := add_le_add hn (norm_sub_le_norm_sub_add_norm_sub _ _ _)
    _ ≤ a + (a + (q : ℝ)/T) := by gcongr
    _ = _ := by ring

/-- The coordinate Gram matrix is exactly the empirical quadratic form. -/
theorem gram_quadratic_eq {r : ℕ} (c : Fin r → EuclideanSpace ℝ (Fin q))
    (v : EuclideanSpace ℝ (Fin q)) :
    (∑ j, ∑ k, v j * ((∑ i, c i j * c i k) / (r : ℝ)) * v k) =
      (∑ i, ⟪c i, v⟫^2) / (r : ℝ) := by
  let C : Matrix (Fin r) (Fin q) ℝ := fun i j => c i j
  let M : Matrix (Fin q) (Fin q) ℝ := (r : ℝ)⁻¹ • (C.transpose * C)
  have hM : ∀ j k, M j k = (∑ i, c i j * c i k) / (r : ℝ) := by
    intro j k
    simp [M, C, Matrix.mul_apply, Matrix.smul_apply, div_eq_mul_inv, mul_comm]
  have hCv : ∀ i, (C *ᵥ (WithLp.ofLp v)) i = ⟪c i, v⟫ := by
    intro i
    simp [Matrix.mulVec, dotProduct, EuclideanSpace.inner_eq_star_dotProduct, C, mul_comm]
  calc
    _ = (WithLp.ofLp v) ⬝ᵥ (M *ᵥ (WithLp.ofLp v)) := by
      simp only [dotProduct, Matrix.mulVec, Finset.mul_sum, hM, mul_assoc]
    _ = (r : ℝ)⁻¹ * ((WithLp.ofLp v) ⬝ᵥ ((C.transpose * C) *ᵥ (WithLp.ofLp v))) := by
      simp only [M, Matrix.smul_mulVec, dotProduct_smul, smul_eq_mul]
    _ = _ := by
      rw [← Matrix.mulVec_mulVec, Matrix.dotProduct_transpose_mulVec]
      simp only [dotProduct, hCv, pow_two, div_eq_mul_inv, mul_comm]

/-- The entrywise good Gram event implies the precise quadratic estimate
needed for normalization. The source covariance is allowed to be singular. -/
theorem sampled_quadratic_of_good_gram
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    {a T : ℝ} (ha : 0 ≤ a)
    (hu : ∀ v : EuclideanSpace ℝ (Fin q),
      (∑ i, ⟪u i, v⟫^2) / (N : ℝ) ≤ ‖v‖^2)
    (hgram : ∀ j k,
      |(∑ i, wholeClip T (u (I i)) j * wholeClip T (u (I i)) k) / (m : ℝ) -
        (∑ i, wholeClip T (u i) j * wholeClip T (u i) k) / (N : ℝ)| ≤
      a / ((q : ℝ)+1)) :
    ∀ v : EuclideanSpace ℝ (Fin q),
      (∑ j, ⟪wholeClip T (u (I j)), v⟫^2) / (m : ℝ) ≤ (1+a)*‖v‖^2 := by
  let G : Fin q → Fin q → ℝ := fun j k =>
    (∑ i, wholeClip T (u (I i)) j * wholeClip T (u (I i)) k) / (m : ℝ)
  let G₀ : Fin q → Fin q → ℝ := fun j k =>
    (∑ i, wholeClip T (u i) j * wholeClip T (u i) k) / (N : ℝ)
  have hG₀ : ∀ v : Fin q → ℝ, ∑ j, ∑ k, v j * G₀ j k * v k ≤ ∑ j, v j^2 := by
    intro v
    have hc := (clipped_secondMoment_le u T (WithLp.toLp 2 v)).trans (hu (WithLp.toLp 2 v))
    have he := gram_quadratic_eq (fun i => wholeClip T (u i)) (WithLp.toLp 2 v)
    simpa only [WithLp.ofLp_toLp, EuclideanSpace.real_norm_sq_eq] using he.trans_le hc
  intro v
  have hg := gram_upper_of_entrywise G G₀ ha hgram hG₀ (WithLp.ofLp v)
  have he := gram_quadratic_eq (fun i => wholeClip T (u (I i))) v
  simpa only [EuclideanSpace.real_norm_sq_eq] using he.symm.trans_le hg

/-- Both active-feature conclusions for the actual clipped and sampled source
bank, with the concrete entrywise good-event assumptions. -/
theorem sampledActive_bounds [NeZero m]
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (h : Fin N → ℝ) (hh : ∀ i, |h i| ≤ 1)
    {a T : ℝ} (ha : 0 ≤ a) (hT : 0 < T)
    (hu : ∀ v : EuclideanSpace ℝ (Fin q),
      (∑ i, ⟪u i, v⟫^2) / (N : ℝ) ≤ ‖v‖^2)
    (htrace : (∑ i, ‖u i‖^2) / (N : ℝ) ≤ q)
    (hgram : ∀ j k,
      |(∑ i, wholeClip T (u (I i)) j * wholeClip T (u (I i)) k) / (m : ℝ) -
        (∑ i, wholeClip T (u i) j * wholeClip T (u i) k) / (N : ℝ)| ≤
      a / ((q : ℝ)+1))
    (hmean : ∀ k, |(finiteAverage (fun j => h (I j) • wholeClip T (u (I j))) -
      finiteAverage (fun i => h i • wholeClip T (u i))) k| ≤ a/((q : ℝ)+1)) :
    ‖sampledActive (fun i => wholeClip T (u i)) I h a‖ ≤ 1 ∧
    ‖sampledActive (fun i => wholeClip T (u i)) I h a -
      finiteAverage (fun i => h i • u i)‖ ≤ (q : ℝ)/T + 2*a := by
  have hquad := sampled_quadratic_of_good_gram u I ha hu hgram
  exact ⟨sampledActive_norm_le_one _ I h hh ha hquad,
    sampledActive_error u I h hh ha hT htrace hquad hmean⟩

end NeuralGeneralization.RobustCompressionActiveFeature
