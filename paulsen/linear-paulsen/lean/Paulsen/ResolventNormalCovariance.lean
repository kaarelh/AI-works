import Paulsen.SmoothNormalCovariance

/-! Ordinary resolvent filtering of the leverage-normalized tangent covariance.
The historical `Smooth` construction remains available independently. -/
namespace Paulsen
open Matrix
open scoped BigOperators
noncomputable section
namespace Resolvent

/-- Weight of the leverage-normalized normal covariance in the loss decomposition. -/
def baseWeight (ρ : ℝ) : ℝ := 1 / (1 + ρ)

def retainedWeight (ρ μ : ℝ) : ℝ := ρ / (ρ + μ)
def residualWeight (ρ μ : ℝ) : ℝ := baseWeight ρ * Smooth.residualWeight ρ μ

theorem baseWeight_nonneg {ρ : ℝ} (hρ : 0 ≤ ρ) : 0 ≤ baseWeight ρ := by
  unfold baseWeight; positivity

theorem baseWeight_le_one {ρ : ℝ} (hρ : 0 ≤ ρ) : baseWeight ρ ≤ 1 := by
  unfold baseWeight
  apply (div_le_iff₀ (by linarith : 0 < 1 + ρ)).mpr
  linarith

theorem retainedWeight_nonneg {ρ μ : ℝ} (hρ : 0 ≤ ρ) (hμ : 0 ≤ μ) :
    0 ≤ retainedWeight ρ μ := by unfold retainedWeight; positivity

theorem retainedWeight_le_one {ρ μ : ℝ} (hρ : 0 ≤ ρ) (hμ : 0 ≤ μ) :
    retainedWeight ρ μ ≤ 1 := by
  unfold retainedWeight
  exact div_le_one_of_le₀ (by linarith) (add_nonneg hρ hμ)

theorem retainedWeight_eq {ρ μ : ℝ} : retainedWeight ρ μ = ρ / (ρ + μ) := rfl

theorem retainedWeight_add_removed {ρ μ : ℝ} (hρ : 0 ≤ ρ) (hμ : 0 < μ)
    (_hμ1 : μ ≤ 1) : retainedWeight ρ μ + baseWeight ρ * μ + residualWeight ρ μ = 1 := by
  unfold retainedWeight residualWeight baseWeight Smooth.residualWeight
  field_simp [(add_pos_of_nonneg_of_pos hρ hμ).ne', (by linarith : 1 + ρ ≠ 0)]
  ring

theorem residualWeight_nonneg {ρ μ : ℝ} (hρ : 0 ≤ ρ) (hμ : 0 ≤ μ)
    (hμ1 : μ ≤ 1) : 0 ≤ residualWeight ρ μ :=
  mul_nonneg (baseWeight_nonneg hρ) (Smooth.residualWeight_nonneg hρ hμ hμ1)

theorem residualWeight_le_old {ρ μ : ℝ} (hρ : 0 ≤ ρ) (hμ : 0 ≤ μ)
    (hμ1 : μ ≤ 1) : residualWeight ρ μ ≤ Smooth.residualWeight ρ μ := by
  exact mul_le_of_le_one_left (Smooth.residualWeight_nonneg hρ hμ hμ1) (baseWeight_le_one hρ)

theorem residualWeight_le_deficit {ρ μ : ℝ} (hρ : 0 ≤ ρ) (hμ : 0 ≤ μ)
    (hμ1 : μ ≤ 1) : residualWeight ρ μ ≤ 1 - μ :=
  (residualWeight_le_old hρ hμ hμ1).trans (Smooth.residualWeight_le_deficit hρ hμ hμ1)

theorem residualWeight_div_le {ρ μ : ℝ} (hρ : 0 < ρ) (hμ : 0 ≤ μ)
    (hμ1 : μ ≤ 1) : residualWeight ρ μ / μ ≤ (1 - μ) / ρ :=
  (div_le_div_of_nonneg_right (residualWeight_le_old hρ.le hμ hμ1) hμ).trans
    (Smooth.residualWeight_div_le hρ hμ hμ1)

theorem residualWeight_div_sqrt_le {ρ μ : ℝ} (hρ : 0 < ρ) (hμ : 0 ≤ μ)
    (hμ1 : μ ≤ 1) : residualWeight ρ μ / Real.sqrt μ ≤ (1 - μ) / (2 * Real.sqrt ρ) :=
  (div_le_div_of_nonneg_right (residualWeight_le_old hρ.le hμ hμ1) (Real.sqrt_nonneg μ)).trans
    (Smooth.residualWeight_div_sqrt_le hρ hμ hμ1)

def modeSum {n d : ℕ} (U : Frame n d) (w : ℝ → ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  ∑ i ∈ highNormalizedModes U 0, w (normalizedFisherEigenvalue U i) • normalDirectionOuter U i

theorem modeSum_transpose {n d : ℕ} (U : Frame n d) (w : ℝ → ℝ) :
    (modeSum U w).transpose=modeSum U w := by
  unfold modeSum
  simp only [Matrix.transpose_sum,Matrix.transpose_smul]
  apply Finset.sum_congr rfl
  intro i hi
  congr 1
  ext p q
  simp only [normalDirectionOuter,Matrix.transpose_apply,Matrix.vecMulVec_apply]
  ring

theorem modeSum_posSemidef {n d : ℕ} (U : Frame n d) (w : ℝ → ℝ)
    (hw : ∀ μ, 0<μ → 0≤w μ) : (modeSum U w).PosSemidef := by
  apply Matrix.posSemidef_sum
  intro i hi
  exact (normalDirectionOuter_posSemidef U i).smul (hw _ (Finset.mem_filter.mp hi).2)

theorem modeSum_mul {n d : ℕ} (U : Frame n d) (v w : ℝ → ℝ) :
    modeSum U v*modeSum U w=modeSum U (fun μ=>v μ*w μ) := by
  unfold modeSum
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro i hi
  rw [Finset.mul_sum]
  have hip := (Finset.mem_filter.mp hi).2
  simp only [Matrix.smul_mul,Matrix.mul_smul,smul_smul]
  have he : (∑ j ∈ highNormalizedModes U 0,
      (v (normalizedFisherEigenvalue U i)*w (normalizedFisherEigenvalue U j)) •
        (normalDirectionOuter U i*normalDirectionOuter U j)) =
      ∑ j ∈ highNormalizedModes U 0, if i=j then
        (v (normalizedFisherEigenvalue U i)*w (normalizedFisherEigenvalue U i)) •
          normalDirectionOuter U i else 0 := by
    apply Finset.sum_congr rfl
    intro j hj
    rw [normalDirectionOuter_mul U i j hip (Finset.mem_filter.mp hj).2]
    split_ifs with hij
    · subst j; rfl
    · simp
  simp only [mul_comm (w _) (v _)]
  rw [he]
  simp [hi]

theorem modeSum_add {n d : ℕ} (U : Frame n d) (v w : ℝ → ℝ) :
    modeSum U v+modeSum U w=modeSum U (fun μ=>v μ+w μ) := by
  simp only [modeSum,add_smul,Finset.sum_add_distrib]

theorem modeSum_one {n d : ℕ} (U : Frame n d) :
    modeSum U (fun _=>1)=normalizedHighProjection U 0 := by
  simp only [modeSum,one_smul,normalizedHighProjection]

theorem modeSum_identity {n d : ℕ} (U : Frame n d) :
    modeSum U id=normalizedNormalCovariance U := by
  rw [normalizedNormalCovariance_decomposition]
  apply Finset.sum_subset (Finset.subset_univ _)
  intro i _ hi
  have hz : normalizedFisherEigenvalue U i=0 := by
    have hn := normalizedFisherEigenvalue_nonneg U i
    have hh : ¬0<normalizedFisherEigenvalue U i := by
      simpa only [highNormalizedModes,Finset.mem_filter,Finset.mem_univ,true_and] using hi
    linarith
  simp [hz]

theorem horizontal_modeSum {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (w : ℝ→ℝ) :
    horizontalProjectionMatrix U*modeSum U w=modeSum U w := by
  simp only [modeSum,Matrix.mul_sum,Matrix.mul_smul]
  apply Finset.sum_congr rfl
  intro i hi
  congr 1
  rw [normalDirectionOuter,Matrix.mul_vecMulVec,horizontalProjectionMatrix_normalDirection hU]

theorem modeSum_horizontal {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (w : ℝ→ℝ) :
    modeSum U w*horizontalProjectionMatrix U=modeSum U w := by
  have hh := congrArg Matrix.transpose (horizontal_modeSum hU w)
  simpa only [Matrix.transpose_mul,modeSum_transpose,horizontalProjectionMatrix_transpose] using hh

theorem kernel_modeSum {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (w : ℝ→ℝ) :
    retainedHorizontalProjection U 0*modeSum U w=0 := by
  rw [retainedHorizontalProjection,Matrix.sub_mul,horizontal_modeSum hU,←modeSum_one,modeSum_mul]
  simp only [one_mul,sub_self]

theorem modeSum_kernel {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (w : ℝ→ℝ) :
    modeSum U w*retainedHorizontalProjection U 0=0 := by
  have hh := congrArg Matrix.transpose (kernel_modeSum hU w)
  simpa only [Matrix.transpose_mul,modeSum_transpose,retainedHorizontalProjection_transpose,
    Matrix.transpose_zero] using hh

def covariance {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  retainedHorizontalProjection U 0+modeSum U (retainedWeight ρ)

def factorRoot {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  retainedHorizontalProjection U 0+modeSum U (fun μ=>Real.sqrt (retainedWeight ρ μ))

theorem factorRoot_transpose {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    (factorRoot U ρ).transpose=factorRoot U ρ := by
  simp only [factorRoot,Matrix.transpose_add,retainedHorizontalProjection_transpose,modeSum_transpose]

theorem factorRoot_sq {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    {ρ : ℝ} (hρ : 0≤ρ) : factorRoot U ρ*factorRoot U ρ=covariance U ρ := by
  simp only [factorRoot,Matrix.add_mul,Matrix.mul_add,kernel_modeSum hU,modeSum_kernel hU,
    retainedHorizontalProjection_idempotent hU (le_refl 0),zero_add,add_zero,modeSum_mul]
  unfold covariance
  congr 1
  unfold modeSum
  apply Finset.sum_congr rfl
  intro i hi
  dsimp only
  rw [←sq,Real.sq_sqrt (retainedWeight_nonneg hρ (normalizedFisherEigenvalue_nonneg U i))]

theorem covariance_posSemidef {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    {ρ : ℝ} (hρ : 0≤ρ) : (covariance U ρ).PosSemidef :=
  (retainedHorizontalProjection_posSemidef hU (le_refl 0)).add
    (modeSum_posSemidef U _ (fun μ hμ=>retainedWeight_nonneg hρ hμ.le))

theorem covariance_removed {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    horizontalProjectionMatrix U-covariance U ρ=modeSum U (fun μ=>1-retainedWeight ρ μ) := by
  unfold covariance retainedHorizontalProjection
  rw [←modeSum_one]
  have hh : modeSum U (fun _=>1)-modeSum U (retainedWeight ρ)=
      modeSum U (fun μ=>1-retainedWeight ρ μ) := by
    simp only [modeSum,sub_smul,Finset.sum_sub_distrib]
  rw [←hh]
  abel

theorem covariance_le_horizontal {n d : ℕ} (U : Frame n d) {ρ : ℝ} (hρ : 0≤ρ) :
    (horizontalProjectionMatrix U-covariance U ρ).PosSemidef := by
  rw [covariance_removed]
  exact modeSum_posSemidef U _ (fun μ hμ=>sub_nonneg.mpr (retainedWeight_le_one hρ hμ.le))

theorem residual_decomposition {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0<rowNormSq U i) {ρ : ℝ} (hρ : 0≤ρ) :
    horizontalProjectionMatrix U-covariance U ρ=
      baseWeight ρ • normalizedNormalCovariance U+modeSum U (residualWeight ρ) := by
  rw [covariance_removed,←modeSum_identity]
  have hm : baseWeight ρ • modeSum U id = modeSum U (fun μ => baseWeight ρ * μ) := by
    simp only [modeSum, Finset.smul_sum, smul_smul, id_eq]
  rw [hm,modeSum_add]
  unfold modeSum
  apply Finset.sum_congr rfl
  intro i hi
  congr 1
  have hh := retainedWeight_add_removed hρ (Finset.mem_filter.mp hi).2
    (normalizedFisherEigenvalue_le_one hU hp i)
  change 1-retainedWeight ρ (normalizedFisherEigenvalue U i)=
    baseWeight ρ * normalizedFisherEigenvalue U i+residualWeight ρ (normalizedFisherEigenvalue U i)
  linarith


/-- The resolvent loses at most `Ω / ρ`; this gives the expected graph in one comparison. -/
theorem covariance_loss_le_normal {n d : ℕ} (U : Frame n d) {ρ : ℝ} (hρ : 0 < ρ) :
    ((1 / ρ) • normalizedNormalCovariance U -
      (horizontalProjectionMatrix U - covariance U ρ)).PosSemidef := by
  rw [covariance_removed, ← modeSum_identity]
  have he : (1 / ρ) • modeSum U id - modeSum U (fun μ => 1 - retainedWeight ρ μ) =
      modeSum U (fun μ => μ / ρ - (1 - retainedWeight ρ μ)) := by
    simp only [modeSum, Finset.smul_sum, smul_smul, ← Finset.sum_sub_distrib, ← sub_smul, id_eq]
    apply Finset.sum_congr rfl
    intro i hi
    congr 1
    ring
  rw [he]
  apply modeSum_posSemidef
  intro μ hμ
  unfold retainedWeight
  have hd : 0 < ρ + μ := add_pos hρ hμ
  apply (sub_nonneg).mpr
  rw [show 1 - ρ / (ρ + μ) = μ / (ρ + μ) by field_simp; ring]
  exact div_le_div_of_nonneg_left hμ.le hρ (le_of_lt (lt_add_of_pos_right ρ hμ))


def normalizedTangentNoiseFactor {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  (Real.sqrt (n:ℝ))⁻¹ • factorRoot U ρ

theorem normalizedTangentNoiseFactor_transpose {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    (normalizedTangentNoiseFactor U ρ).transpose=normalizedTangentNoiseFactor U ρ := by
  simp only [normalizedTangentNoiseFactor,Matrix.transpose_smul,factorRoot_transpose]

theorem normalizedTangentNoiseFactor_covariance {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0≤ρ) :
    normalizedTangentNoiseFactor U ρ*(normalizedTangentNoiseFactor U ρ).transpose=
      (1/(n:ℝ)) • covariance U ρ := by
  simp only [normalizedTangentNoiseFactor,Matrix.transpose_smul,factorRoot_transpose,
    Matrix.smul_mul,Matrix.mul_smul,smul_smul,factorRoot_sq hU hρ]
  congr 1
  rw [←sq,inv_pow,Real.sq_sqrt (Nat.cast_nonneg n),one_div]

theorem horizontal_factorRoot {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (ρ : ℝ) :
    horizontalProjectionMatrix U*factorRoot U ρ=factorRoot U ρ := by
  simp only [factorRoot,Matrix.mul_add,horizontalProjectionMatrix_retained hU,horizontal_modeSum hU]

theorem normalizedTangentNoiseFactor_horizontal {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (ρ : ℝ) (z : Fin n × Fin d → ℝ) :
    U.transpose*Matrix.of (fun i a=>(normalizedTangentNoiseFactor U ρ*ᵥz) (i,a))=0 := by
  have hh : horizontalProjectionMatrix U*normalizedTangentNoiseFactor U ρ=
      normalizedTangentNoiseFactor U ρ := by
    simp only [normalizedTangentNoiseFactor,Matrix.mul_smul,horizontal_factorRoot hU]
  have hm : Matrix.of (fun i a=>(normalizedTangentNoiseFactor U ρ*ᵥz) (i,a))=
      frameComplementProjection U*Matrix.of (fun i a=>(normalizedTangentNoiseFactor U ρ*ᵥz) (i,a)) := by
    ext i a
    have h := congrArg (fun M=>(M*ᵥz) (i,a)) hh
    rw [←Matrix.mulVec_mulVec,horizontalProjectionMatrix_mulVec] at h
    exact h.symm
  conv_lhs => rw [hm]
  rw [←Matrix.mul_assoc,hU.transpose_mul_frameComplementProjection,Matrix.zero_mul]

theorem one_sub_horizontal_posSemidef {n d : ℕ} {U : Frame n d} (hU : IsParseval U) :
    (1-horizontalProjectionMatrix U).PosSemidef := by
  have hid : (1-horizontalProjectionMatrix U)*(1-horizontalProjectionMatrix U)=
      1-horizontalProjectionMatrix U := by
    simp only [Matrix.sub_mul,Matrix.mul_sub,Matrix.one_mul,Matrix.mul_one,
      horizontalProjectionMatrix_idempotent hU]
    abel
  have hs : (1-horizontalProjectionMatrix U).IsHermitian :=
    Matrix.isHermitian_one.sub (horizontalProjectionMatrix_posSemidef hU).isHermitian
  have hh := Matrix.posSemidef_self_mul_conjTranspose (1-horizontalProjectionMatrix U)
  rw [hs.eq,hid] at hh
  exact hh

theorem covariance_le_one {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    {ρ : ℝ} (hρ : 0≤ρ) : (1-covariance U ρ).PosSemidef := by
  have hh := (one_sub_horizontal_posSemidef hU).add (covariance_le_horizontal U hρ)
  convert hh using 1 <;> abel

theorem factorRoot_pointwise_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    {ρ : ℝ} (hρ : 0≤ρ) (x : EuclideanSpace ℝ (Fin n × Fin d)) :
    ‖Matrix.toEuclideanLin (factorRoot U ρ) x‖^2≤‖x‖^2 := by
  have hh := (covariance_le_one hU hρ).dotProduct_mulVec_nonneg (fun i=>x i)
  have he : (fun i=>x i) ⬝ᵥ (covariance U ρ*ᵥ(fun i=>x i))=
      ‖Matrix.toEuclideanLin (factorRoot U ρ) x‖^2 := by
    rw [←factorRoot_sq hU hρ,←Matrix.mulVec_mulVec]
    conv_lhs => arg 2; arg 1; rw [←factorRoot_transpose U ρ]
    rw [Matrix.dotProduct_mulVec,Matrix.vecMul_transpose]
    rw [EuclideanSpace.real_norm_sq_eq]
    simp only [Matrix.toLpLin_apply,dotProduct,pow_two,WithLp.ofLp_toLp]
  simp only [star_trivial,Matrix.sub_mulVec,Matrix.one_mulVec,dotProduct_sub,he] at hh
  have hn : (fun i=>x i) ⬝ᵥ (fun i=>x i)=‖x‖^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    simp only [dotProduct,pow_two]
  rw [hn] at hh
  linarith

theorem normalizedTangentNoiseFactor_operator_norm_sq_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0≤ρ) :
    ‖(Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ)).toContinuousLinearMap‖^2≤
      1/(n:ℝ) := by
  apply euclidean_operator_norm_sq_le_of_pointwise _ (by positivity)
  intro x
  have he : Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) x=
      (Real.sqrt (n:ℝ))⁻¹ • Matrix.toEuclideanLin (factorRoot U ρ) x := by
    simp only [normalizedTangentNoiseFactor,map_smul,LinearMap.smul_apply]
  rw [he,norm_smul,Real.norm_eq_abs,mul_pow,sq_abs,inv_pow,
    Real.sq_sqrt (Nat.cast_nonneg n)]
  simpa only [one_div] using mul_le_mul_of_nonneg_left (factorRoot_pointwise_le hU hρ x)
    (inv_nonneg.mpr (Nat.cast_nonneg n))

/-- The residual covariance has trace at most the frame rank. -/
theorem residual_trace_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0<rowNormSq U i) {ρ : ℝ} (hρ : 0≤ρ) :
    (modeSum U (residualWeight ρ)).trace≤(d:ℝ) := by
  simp only [modeSum,Matrix.trace_sum,Matrix.trace_smul,smul_eq_mul]
  calc
    _ = ∑ i ∈ highNormalizedModes U 0, residualWeight ρ (normalizedFisherEigenvalue U i) := by
      apply Finset.sum_congr rfl
      intro i hi
      rw [normalDirectionOuter_trace_of_pos U i (Finset.mem_filter.mp hi).2,mul_one]
    _ ≤ ∑ i ∈ highNormalizedModes U 0, (1-normalizedFisherEigenvalue U i) :=
      Finset.sum_le_sum (fun i hi =>residualWeight_le_deficit hρ
        (normalizedFisherEigenvalue_nonneg U i) (normalizedFisherEigenvalue_le_one hU hp i))
    _ ≤ ∑ i, (1-normalizedFisherEigenvalue U i) :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        (fun i _ _ =>sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hp i))
    _ = _ := normalizedFisher_deficit_sum hU hp

end Resolvent
end
end Paulsen
