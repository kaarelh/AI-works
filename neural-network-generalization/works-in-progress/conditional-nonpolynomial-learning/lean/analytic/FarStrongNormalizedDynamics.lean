import FarStrongCanonicalPrefix

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic

namespace CanonicalLayerModel
variable {I J A:Type*} [Fintype I] [Fintype J] [Fintype A]
variable {anchors:A→EuclideanSpace ℝ I} {D:ℝ}

theorem value_sharp_gain (M:CanonicalLayerModel (J:=J) anchors D)
    (u v:EuclideanSpace ℝ I) :
    ‖M.value u-M.value v‖≤Real.sqrt (gaussianEntropyGain D)*‖u-v‖ := by
  change ‖M.output _-M.output _‖≤_
  rw [←M.output.map_sub,M.output.norm_map]
  apply (ConditionalAnalytic.canonicalVector_distance (actualCanonicalSpan M.law M.finiteKL anchors)
    (actualTanhL2 M.law u) (actualTanhL2 M.law v)).trans
  apply (actualTanhL2_sharp_gain M.law M.finiteKL u v).trans
  exact mul_le_mul_of_nonneg_right (Real.sqrt_le_sqrt
    (gaussianEntropyGain_mono ENNReal.toReal_nonneg M.cost_le)) (norm_nonneg _)

@[simp] theorem value_zero (M:CanonicalLayerModel (J:=J) anchors D) : M.value 0=0 := by
  simp only [value,canonicalGaussianMap_zero,map_zero]
end CanonicalLayerModel

variable {I:ℕ→Type*} [∀j,Fintype (I j)] [∀j,DecidableEq (I j)]
variable {K X:Type*} [Fintype K]
variable {anchors:∀j,K→EuclideanSpace ℝ (I j)} {D:ℕ→ℝ} {H:ℕ}

theorem finiteNormalizedMap_nonexpansive
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t:ℝ} (ht:0<t) (j:ℕ) (x y:EuclideanSpace ℝ (I j)) :
    ‖finiteNormalizedMap M t j x-finiteNormalizedMap M t j y‖≤‖x-y‖ := by
  unfold finiteNormalizedMap
  split_ifs with hj
  · have hs := sharpFiniteProduct_pos ht D j
    have hα := sharpFiniteGain_pos ht D j
    have hn := sharpFiniteProduct_pos ht D (j+1)
    rw [←smul_sub,norm_smul,Real.norm_eq_abs,abs_inv,abs_of_pos hn]
    have hh := (M j hj).value_sharp_gain
      (t • (sharpFiniteProduct t D j • x)) (t • (sharpFiniteProduct t D j • y))
    rw [←smul_sub,←smul_sub,norm_smul,norm_smul,Real.norm_eq_abs,Real.norm_eq_abs,
      abs_of_pos ht,abs_of_pos hs] at hh
    have he : Real.sqrt (gaussianEntropyGain (D j))*(t*(sharpFiniteProduct t D j*‖x-y‖))=
        sharpFiniteProduct t D (j+1)*‖x-y‖ := by
      rw [sharpFiniteProduct_succ]
      dsimp [sharpFiniteGain]
      ring
    rw [he] at hh
    exact (mul_le_mul_of_nonneg_left hh (inv_nonneg.mpr hn.le)).trans_eq (by
      rw [←mul_assoc,inv_mul_cancel₀ hn.ne',one_mul])
  · simp

@[simp] theorem finiteNormalizedMap_zero
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    (t:ℝ) (j:ℕ) : finiteNormalizedMap M t j 0=0 := by
  unfold finiteNormalizedMap
  split_ifs <;> simp

theorem finiteNormalizedState_suffix_nonexpansive
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t:ℝ} (ht:0<t) (u:∀j,X→EuclideanSpace ℝ (I j))
    (hrec:∀j (hj:j<H),∀x,u (j+1) x=(M j hj).value (t • u j x))
    (J n:ℕ) (hJn:J≤n) (hnH:n≤H) (x y:X) :
    ‖finiteNormalizedState t D u n x-finiteNormalizedState t D u n y‖≤
      ‖finiteNormalizedState t D u J x-finiteNormalizedState t D u J y‖ := by
  apply Nat.le_induction (P:=fun n _=>n≤H→
    ‖finiteNormalizedState t D u n x-finiteNormalizedState t D u n y‖≤
      ‖finiteNormalizedState t D u J x-finiteNormalizedState t D u J y‖)
    (fun _=>le_rfl) ?_ n hJn hnH
  intro j hj ih hjH
  rw [finiteNormalizedMap_recurrence M ht u hrec j (by omega) x,
    finiteNormalizedMap_recurrence M ht u hrec j (by omega) y]
  exact (finiteNormalizedMap_nonexpansive M ht j _ _).trans (ih (by omega))

theorem finiteNormalizedState_norm
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t:ℝ} (ht:0<t) (u:∀j,X→EuclideanSpace ℝ (I j))
    (hrec:∀j (hj:j<H),∀x,u (j+1) x=(M j hj).value (t • u j x))
    {R:ℝ} (hu:∀x,‖u 0 x‖≤R) :
    ∀j≤H,∀x,‖finiteNormalizedState t D u j x‖≤R := by
  intro j
  induction j with
  | zero => intro _ x; simpa only [finiteNormalizedState,sharpFiniteProduct_zero,inv_one,one_smul] using hu x
  | succ j ih =>
    intro hj x
    rw [finiteNormalizedMap_recurrence M ht u hrec j (by omega) x]
    have hh := finiteNormalizedMap_nonexpansive M ht j (finiteNormalizedState t D u j x) 0
    rw [finiteNormalizedMap_zero,sub_zero,sub_zero] at hh
    exact hh.trans (ih (by omega) x)

theorem finiteNormalizedState_readout_lipschitz
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t:ℝ} (ht:0<t) (u:∀j,X→EuclideanSpace ℝ (I j))
    (hrec:∀j (hj:j<H),∀x,u (j+1) x=(M j hj).value (t • u j x))
    (c:EuclideanSpace ℝ (I H)) (J:ℕ) (hJ:J≤H) (x y:X) :
    |inner ℝ c (u H x)-inner ℝ c (u H y)|≤
      (‖c‖*sharpFiniteProduct t D H)*
        dist (finiteNormalizedState t D u J x) (finiteNormalizedState t D u J y) := by
  rw [←inner_sub_right]
  apply (abs_real_inner_le_norm c (u H x-u H y)).trans
  have hh := finiteNormalizedState_suffix_nonexpansive M ht u hrec J H hJ le_rfl x y
  have hn := sharpFiniteProduct_pos ht D H
  have he : u H x-u H y=sharpFiniteProduct t D H •
      (finiteNormalizedState t D u H x-finiteNormalizedState t D u H y) := by
    simp only [finiteNormalizedState,←smul_sub,smul_smul,mul_inv_cancel₀ hn.ne',one_smul]
  rw [he,norm_smul,Real.norm_eq_abs,abs_of_pos hn,mul_assoc,dist_eq_norm]
  exact mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left hh hn.le) (norm_nonneg _)

#print axioms finiteNormalizedState_readout_lipschitz
#print axioms finiteNormalizedState_norm
end ConditionalNonpolynomial.Analytic
