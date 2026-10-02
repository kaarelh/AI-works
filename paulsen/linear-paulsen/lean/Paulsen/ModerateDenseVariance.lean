import Paulsen.ExpectedTangentExpansion
import Paulsen.GaussianSoftCount

/-! Most entries in every nonexceptional row retain variance of order d/n². -/

open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators
noncomputable section
namespace Paulsen

def retainedTangentEntryVariance {n d : ℕ} (U : Frame n d) (ρ : ℝ)
    (i j : Fin n) : ℝ :=
  (retainedTangentFactor U ρ * (retainedTangentFactor U ρ).transpose) (i,j) (i,j)

theorem tangentCovarianceEntry_nonneg {n d : ℕ} (U : Frame n d) (i j : Fin n)
    (C : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) (hC : C.PosSemidef) :
    0 ≤ tangentCovarianceEntry U i j C := by
  have h := hC.mul_mul_conjTranspose_same (tangentLiftMatrix U)
  simpa only [tangentCovarianceEntry, LinearMap.coe_mk, AddHom.coe_mk,
    Matrix.conjTranspose_eq_transpose_of_trivial] using h.diag_nonneg (i := (i,j))

theorem tangentCovarianceEntry_base {n d : ℕ} (U : Frame n d) (i j : Fin n) :
    (1/(n:ℝ))*tangentCovarianceEntry U i j (normalizedNormalCovariance U) =
      baseNormalTangentVariance U i j := by
  simp only [normalizedNormalCovariance_base_decomposition, map_sum,
    tangentCovarianceEntry_outer, baseNormalTangentVariance, Matrix.of_apply,
    baseNormalTangent]

theorem retainedTangentEntryVariance_lower {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) (i j : Fin n) (hij : i ≠ j) :
    (rowNormSq U i+rowNormSq U j-2*rowNormSq U i*rowNormSq U j-
        2*(frameProjection U i j)^2)/(n:ℝ) -
      baseNormalTangentVariance U i j - positiveResidualEntryLoss U ρ i j ≤
      retainedTangentEntryVariance U ρ i j := by
  have he : retainedTangentEntryVariance U ρ i j =
      (1/(n:ℝ))*tangentCovarianceEntry U i j (retainedHorizontalProjection U ρ) := by
    rw [retainedTangentEntryVariance, retainedTangentFactor_covariance hU hρ]
    rfl
  rw [he, retainedHorizontalProjection, normalizedHighProjection_decomposition,
    map_sub, map_sub, map_add]
  have hb := tangentCovarianceEntry_base U i j
  have hp : (1/(n:ℝ))*tangentCovarianceEntry U i j (normalizedPositiveResidual U ρ) =
      positiveResidualEntryLoss U ρ i j := rfl
  have hn := mul_nonneg (show (0:ℝ)≤1/(n:ℝ) by positivity)
    (tangentCovarianceEntry_nonneg U i j (normalizedNegativeResidual U ρ)
      (normalizedNegativeResidual_posSemidef U ρ))
  have hu := unconditionedTangent_entry_variance_offDiagonal U i j hij
  change (1/(n:ℝ))*tangentCovarianceEntry U i j (horizontalProjectionMatrix U) = _ at hu
  nlinarith only [hb, hp, hn, hu]

theorem squaredFrameProjection_mul_row_sum_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (i : Fin n) :
    (∑ j, (squaredFrameProjection U * squaredFrameProjection U) i j) ≤ rowNormSq U i := by
  simp only [Matrix.mul_apply]
  rw [Finset.sum_comm]
  calc
    _ = ∑ k, squaredFrameProjection U i k * rowNormSq U k := by
      simp_rw [← Finset.mul_sum, squaredFrameProjection_row_sum hU]
    _ ≤ ∑ k, squaredFrameProjection U i k := Finset.sum_le_sum fun k _ =>
      mul_le_of_le_one_right (sq_nonneg _) (hU.leverage_le_one k)
    _ = _ := squaredFrameProjection_row_sum hU i

theorem baseNormalTangentVariance_row_sum_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {a : ℝ} (ha : 0<a)
    (hp : ∀ k, a/2≤rowNormSq U k) (i : Fin n) :
    (∑ j, baseNormalTangentVariance U i j) ≤ (32/(a*(n:ℝ)))*rowNormSq U i := by
  calc
    _ ≤ ∑ j, (16/(a*(n:ℝ)))*((frameProjection U i j)^2+
      (squaredFrameProjection U*squaredFrameProjection U) i j) :=
        Finset.sum_le_sum fun j _ => baseNormalTangentVariance_apply_le U ha hp i j
    _ = (16/(a*(n:ℝ)))*(rowNormSq U i+
      ∑ j, (squaredFrameProjection U*squaredFrameProjection U) i j) := by
        rw [← Finset.mul_sum, Finset.sum_add_distrib, hU.projection_row_squares]
    _ ≤ (16/(a*(n:ℝ)))*(rowNormSq U i+rowNormSq U i) := by
      exact mul_le_mul_of_nonneg_left (add_le_add le_rfl
        (squaredFrameProjection_mul_row_sum_le hU i)) (by positivity)
    _ = _ := by ring

def retainedTangentVarianceDeficit {n d : ℕ} (U : Frame n d) (ρ : ℝ)
    (i j : Fin n) : ℝ :=
  (2/(n:ℝ))*(frameProjection U i j)^2 +
    baseNormalTangentVariance U i j + positiveResidualEntryLoss U ρ i j

theorem retainedTangentVarianceDeficit_nonneg {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0<rowNormSq U i) (ρ : ℝ) (i j : Fin n) :
    0 ≤ retainedTangentVarianceDeficit U ρ i j := by
  unfold retainedTangentVarianceDeficit
  apply add_nonneg _ (positiveResidualEntryLoss_nonneg hU hp ρ i j)
  apply add_nonneg (by positivity)
  change 0 ≤ (1/(n:ℝ))*∑ k, (baseNormalTangent U k i j)^2
  exact mul_nonneg (by positivity) (Finset.sum_nonneg fun k _ => sq_nonneg _)

theorem retainedTangentVarianceDeficit_row_sum_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) {a : ℝ} (ha : 0<a)
    (hp : ∀ k, a/2≤rowNormSq U k) (i : Fin n) (hi : rowNormSq U i≤2*a) (ρ : ℝ) :
    (∑ j, retainedTangentVarianceDeficit U ρ i j) ≤
      4*a/(n:ℝ)+64/(n:ℝ)+positiveResidualRowLoss U ρ i := by
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  simp only [retainedTangentVarianceDeficit, Finset.sum_add_distrib,
    ← Finset.mul_sum, hU.projection_row_squares]
  have hb := baseNormalTangentVariance_row_sum_le hU ha hp i
  have h₁ := mul_le_mul_of_nonneg_left hi (show (0:ℝ)≤2/(n:ℝ) by positivity)
  have h₂ := mul_le_mul_of_nonneg_left hi (show (0:ℝ)≤32/(a*(n:ℝ)) by positivity)
  have he : (32/(a*(n:ℝ)))*(2*a)=64/(n:ℝ) := by field_simp; ring
  rw [he] at h₂
  have he₁ : (2/(n:ℝ))*(2*a)=4*a/(n:ℝ) := by ring
  rw [he₁] at h₁
  change _ ≤ _ + positiveResidualRowLoss U ρ i
  change _ + _ + positiveResidualRowLoss U ρ i ≤ _
  nlinarith only [hb, h₁, h₂]

theorem retainedTangentEntryVariance_lower_density {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) {a : ℝ} (ha : 0<a) (hahalf : a≤1/2)
    (hrows : ∀ i, a/2≤rowNormSq U i ∧ rowNormSq U i≤3*a/2)
    {ρ : ℝ} (hρ : 0≤ρ) (i j : Fin n) (hij : i≠j) :
    a/(4*(n:ℝ))-retainedTangentVarianceDeficit U ρ i j ≤
      retainedTangentEntryVariance U ρ i j := by
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hp (k : Fin n) : rowNormSq U k≤3/4 := by nlinarith [(hrows k).2]
  have hs : a/4≤rowNormSq U i+rowNormSq U j-2*rowNormSq U i*rowNormSq U j := by
    have h₁ := mul_nonneg (rowNormSq_nonneg U i) (sub_nonneg.mpr (hp j))
    have h₂ := mul_nonneg (rowNormSq_nonneg U j) (sub_nonneg.mpr (hp i))
    nlinarith [(hrows i).1, (hrows j).1]
  have hd := div_le_div_of_nonneg_right hs hn'.le
  have ht := retainedTangentEntryVariance_lower hU hρ i j hij
  unfold retainedTangentVarianceDeficit
  calc
    _ = (a/4)/(n:ℝ)-(2*(frameProjection U i j)^2)/(n:ℝ)-
      baseNormalTangentVariance U i j-positiveResidualEntryLoss U ρ i j := by ring
    _ ≤ (rowNormSq U i+rowNormSq U j-2*rowNormSq U i*rowNormSq U j)/(n:ℝ)-
      (2*(frameProjection U i j)^2)/(n:ℝ)-
      baseNormalTangentVariance U i j-positiveResidualEntryLoss U ρ i j := by linarith only [hd]
    _ = (rowNormSq U i+rowNormSq U j-2*rowNormSq U i*rowNormSq U j-
      2*(frameProjection U i j)^2)/(n:ℝ)-
      baseNormalTangentVariance U i j-positiveResidualEntryLoss U ρ i j := by ring
    _ ≤ _ := ht

def retainedTangentVarianceGood {n d : ℕ} (U : Frame n d) (ρ a : ℝ)
    (i : Fin n) : Finset (Fin n) :=
  Finset.univ.filter fun j => i≠j ∧ a/(8*(n:ℝ))≤retainedTangentEntryVariance U ρ i j

theorem retainedTangentVarianceGood_compl_card_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) {a : ℝ} (ha : 0<a) (hahalf : a≤1/2)
    (hrows : ∀ i, a/2≤rowNormSq U i ∧ rowNormSq U i≤3*a/2)
    {ρ : ℝ} (hρ : 0≤ρ) (i : Fin n) :
    (((retainedTangentVarianceGood U ρ a i)ᶜ).card : ℝ) ≤
      1+(4*a/(n:ℝ)+64/(n:ℝ)+positiveResidualRowLoss U ρ i)/(a/(8*(n:ℝ))) := by
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have ht : (0:ℝ)<a/(8*(n:ℝ)) := by positivity
  have hp (k : Fin n) : 0<rowNormSq U k := by linarith [(hrows k).1]
  let S := Finset.univ.filter fun j => a/(8*(n:ℝ))≤retainedTangentVarianceDeficit U ρ i j
  have hsub : (retainedTangentVarianceGood U ρ a i)ᶜ ⊆ insert i S := by
    intro j hj
    by_cases hij : i=j
    · subst j; simp
    · apply Finset.mem_insert_of_mem
      apply Finset.mem_filter.mpr
      refine ⟨Finset.mem_univ _, ?_⟩
      have hv : retainedTangentEntryVariance U ρ i j<a/(8*(n:ℝ)) := by
        apply lt_of_not_ge
        intro h
        exact (Finset.mem_compl.mp hj) (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hij, h⟩)
      have hl := retainedTangentEntryVariance_lower_density hU hn ha hahalf hrows hρ i j hij
      have he : a/(4*(n:ℝ))=2*(a/(8*(n:ℝ))) := by ring
      rw [he] at hl
      linarith
  have hc : (S.card:ℝ)≤
      (4*a/(n:ℝ)+64/(n:ℝ)+positiveResidualRowLoss U ρ i)/(a/(8*(n:ℝ))) := by
    apply (le_div_iff₀ ht).mpr
    calc
      _ = ∑ _j∈S, a/(8*(n:ℝ)) := by simp
      _ ≤ ∑ j∈S, retainedTangentVarianceDeficit U ρ i j :=
        Finset.sum_le_sum fun j hj => (Finset.mem_filter.mp hj).2
      _ ≤ ∑ j, retainedTangentVarianceDeficit U ρ i j :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
          (fun j _ _ => retainedTangentVarianceDeficit_nonneg hU hp ρ i j)
      _ ≤ _ := retainedTangentVarianceDeficit_row_sum_le hU hn ha
        (fun k => (hrows k).1) i (by linarith [(hrows i).2]) ρ
  have hcard := (Finset.card_le_card hsub).trans (Finset.card_insert_le i S)
  have hcard' : (((retainedTangentVarianceGood U ρ a i)ᶜ).card:ℝ)≤(S.card:ℝ)+1 := by
    exact_mod_cast hcard
  linarith

theorem retainedTangentVarianceGood_compl_fraction_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 1000000≤d) (hdn : d≤n)
    (hdensity : (d:ℝ)/(n:ℝ)≤1/2)
    (hrows : ∀ i, ((d:ℝ)/(n:ℝ))/2≤rowNormSq U i ∧
      rowNormSq U i≤3*((d:ℝ)/(n:ℝ))/2)
    {ρ : ℝ} (hρ : 0≤ρ) (i : Fin n)
    (hi : positiveResidualRowLoss U ρ i≤((d:ℝ)/(n:ℝ))/1000000) :
    (((retainedTangentVarianceGood U ρ ((d:ℝ)/(n:ℝ)) i)ᶜ).card:ℝ)/(n:ℝ)≤1/1000 := by
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hd' : (1000000:ℝ)≤d := by exact_mod_cast hd
  have hdpos : (0:ℝ)<d := by linarith
  have hdn' : (d:ℝ)≤n := by exact_mod_cast hdn
  have hc := retainedTangentVarianceGood_compl_card_le hU hn
    (show (0:ℝ)<(d:ℝ)/(n:ℝ) by positivity) hdensity hrows hρ i
  have hc' : (((retainedTangentVarianceGood U ρ ((d:ℝ)/(n:ℝ)) i)ᶜ).card:ℝ) ≤
      33+512*(n:ℝ)/d+(n:ℝ)/125000 := by
    calc
      _ ≤ 1+(4*((d:ℝ)/(n:ℝ))/(n:ℝ)+64/(n:ℝ)+
        positiveResidualRowLoss U ρ i)/(((d:ℝ)/(n:ℝ))/(8*(n:ℝ))) := hc
      _ ≤ 1+(4*((d:ℝ)/(n:ℝ))/(n:ℝ)+64/(n:ℝ)+
        ((d:ℝ)/(n:ℝ))/1000000)/(((d:ℝ)/(n:ℝ))/(8*(n:ℝ))) := by gcongr
      _ = _ := by field_simp; ring
  have hnlarge : (1000000:ℝ)≤n := hd'.trans hdn'
  have h₁ : (33:ℝ)/(n:ℝ)≤33/1000000 := by
    exact div_le_div_of_nonneg_left (by norm_num) (by norm_num) hnlarge
  have h₂ : (512:ℝ)/(d:ℝ)≤512/1000000 := by
    exact div_le_div_of_nonneg_left (by norm_num) (by norm_num) hd'
  have hh := div_le_div_of_nonneg_right hc' hn'.le
  have he : (33+512*(n:ℝ)/d+(n:ℝ)/125000)/(n:ℝ)=
      33/(n:ℝ)+512/(d:ℝ)+1/125000 := by field_simp
  rw [he] at hh
  linarith

theorem retainedTangentRow_coordinate_norm_sq {n d : ℕ} (U : Frame n d)
    (ρ t : ℝ) (i j : Fin n) :
    ‖(EuclideanSpace.proj j).comp
      (t • (Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i)).toContinuousLinearMap)‖^2 =
      t^2*retainedTangentEntryVariance U ρ i j := by
  have he : (EuclideanSpace.proj j).comp
      (t • (Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i)).toContinuousLinearMap) =
      innerSL ℝ (WithLp.toLp 2 (fun p => t*retainedTangentFactor U ρ (i,j) p)) := by
    ext g
    simp only [ContinuousLinearMap.comp_apply, _root_.smul_apply,
      EuclideanSpace.coe_proj, PiLp.smul_apply, smul_eq_mul, LinearMap.coe_toContinuousLinearMap',
      Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, innerSL_apply_apply,
      PiLp.inner_apply, Real.inner_apply, Finset.mul_sum, mul_assoc]
    rfl
  rw [he, innerSL_apply_norm, EuclideanSpace.real_norm_sq_eq]
  change (∑ p, (t*retainedTangentFactor U ρ (i,j) p)^2)=_
  simp only [mul_pow, ← Finset.mul_sum]
  simp only [retainedTangentEntryVariance, Matrix.mul_apply, Matrix.transpose_apply, pow_two]

/-- A concrete count tail for each row of the retained tangent, valid after any
deterministic shift. The variance and covariance assumptions are discharged. -/
theorem retainedTangentRow_smallCoordinate_tail {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) {ρ a t h u : ℝ}
    (hρ : 0≤ρ) (ha : 0<a) (ht : 0<t) (hh : 0<h) (hu : 0≤u)
    (m : EuclideanSpace ℝ (Fin n)) (i : Fin n) :
    (stdGaussian (FrameVector n d)).real {g |
      Real.exp 1 * (h/Real.sqrt (2*(t^2*a/(8*(n:ℝ))))+
        (((retainedTangentVarianceGood U ρ a i)ᶜ).card:ℝ)/(n:ℝ)+u) ≤
      smallCoordinateFraction h (m+t • Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g)} ≤
      Real.exp (-(u^2*h^2*(n:ℝ))/(2*Real.pi^2*(2*t^2/(n:ℝ)))) := by
  have hn : (0:ℝ)<n := Nat.cast_pos.mpr (NeZero.pos n)
  let C := t • (Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i)).toContinuousLinearMap
  have hC : ‖C‖^2≤2*t^2/(n:ℝ) := by
    dsimp [C]
    rw [norm_smul, Real.norm_eq_abs, abs_of_pos ht, mul_pow]
    have hc := mul_le_mul_of_nonneg_left
      (retainedTangentRowFactor_operator_norm_sq_le hU hρ i) (sq_nonneg t)
    exact hc.trans_eq (by ring)
  have hv : ∀ j∈retainedTangentVarianceGood U ρ a i,
      t^2*a/(8*(n:ℝ))≤‖(EuclideanSpace.proj j).comp C‖^2 := by
    intro j hj
    rw [show C=t • (Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i)).toContinuousLinearMap
      from rfl, retainedTangentRow_coordinate_norm_sq]
    have hj' := (Finset.mem_filter.mp hj).2.2
    have hm := mul_le_mul_of_nonneg_left hj' (sq_nonneg t)
    calc
      _ = t^2*(a/(8*(n:ℝ))) := by ring
      _ ≤ _ := hm
  have hb := affineGaussian_smallCoordinateFraction_tail_covariance hh
    (show (0:ℝ)<t^2*a/(8*(n:ℝ)) by positivity)
    (show (0:ℝ)<2*t^2/(n:ℝ) by positivity) m C hC
    (retainedTangentVarianceGood U ρ a i) hv hu
  simpa only [Fintype.card_fin, C, _root_.smul_apply, LinearMap.coe_toContinuousLinearMap'] using hb

end Paulsen
