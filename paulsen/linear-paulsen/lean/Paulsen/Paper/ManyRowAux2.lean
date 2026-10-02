import Paulsen.Paper.ManyRowAuxMoments

/-!
# Helpers for `Paulsen.Paper.ManyRow`: the noise subspaces

* `m = dim 𝓔 - dim 𝓕 ≤ d(d+1)/2`: the global constraint map takes values in symmetric
  matrices, which are determined by their upper triangle;
* `dim (𝓔 ⊖ 𝓕) = dim 𝓔 - dim 𝓕`;
* the row covariance bound `E (z_i·v)² ≤ n⁻¹ (‖v‖² - (e_i·v)²)`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen Module
open scoped BigOperators

noncomputable section

theorem mrx_gauss_sum (d : ℕ) : 2 * ∑ k ∈ Finset.range d, (k + 1) = d * (d + 1) := by
  induction d with
  | zero => simp
  | succ d ih => rw [Finset.sum_range_succ, mul_add, ih]; ring

/-- `2 · #{(i,j) : i ≤ j} = d(d+1)`. -/
theorem mrx_two_card_upper (d : ℕ) :
    2 * Fintype.card {p : Fin d × Fin d // p.1 ≤ p.2} = d * (d + 1) := by
  rw [Fintype.card_subtype, Finset.card_filter, Fintype.sum_prod_type, Finset.sum_comm]
  have h (j : Fin d) : (∑ i : Fin d, if i ≤ j then 1 else 0) = j.val + 1 := by
    rw [← Finset.card_filter]
    have : Finset.univ.filter (fun i : Fin d => i ≤ j) = Finset.Iic j := by
      ext i; simp
    rw [this, Fin.card_Iic]
  simp_rw [h]
  rw [Fin.sum_univ_eq_sum_range (fun k => k + 1) d]
  exact mrx_gauss_sum d

/-- The codimension `m = dim 𝓔 - dim 𝓕` is at most `dim Sym_d = d(d+1)/2`. -/
theorem mrx_codim_le_sym {n d : ℕ} (X : Frame n d) :
    finrank ℝ (globalTangentSpace X) ≤ finrank ℝ (rowTangentSpace X) ∧
    2 * (finrank ℝ (rowTangentSpace X) - finrank ℝ (globalTangentSpace X)) ≤ d * (d + 1) := by
  refine ⟨Submodule.finrank_mono (globalTangentSpace_le_rowTangentSpace X), ?_⟩
  let f := (globalTangentMap X).comp (rowTangentSpace X).subtype
  let U := {p : Fin d × Fin d // p.1 ≤ p.2}
  let up : Matrix (Fin d) (Fin d) ℝ →ₗ[ℝ] (U → ℝ) :=
    { toFun := fun M p => M p.1.1 p.1.2
      map_add' := fun _ _ => rfl
      map_smul' := fun _ _ => rfl }
  let g := up.comp f
  have hsymm (z : rowTangentSpace X) (i j : Fin d) : f z i j = f z j i := by
    change (X.transpose * frameOfVector z.val + (frameOfVector z.val).transpose * X) i j =
      (X.transpose * frameOfVector z.val + (frameOfVector z.val).transpose * X) j i
    simp only [Matrix.add_apply, Matrix.mul_apply, Matrix.transpose_apply]
    rw [add_comm]
    congr 1 <;> apply Finset.sum_congr rfl <;> intro k _ <;> ring
  have hkerg : LinearMap.ker g = LinearMap.ker f := by
    ext z
    simp only [LinearMap.mem_ker]
    constructor
    · intro hz
      ext i j
      rcases le_total i j with hij | hij
      · have := congrFun hz ⟨(i, j), hij⟩
        simpa [g, up] using this
      · have := congrFun hz ⟨(j, i), hij⟩
        rw [hsymm]
        simpa [g, up] using this
    · intro hz
      simp [g, hz]
  have hker : LinearMap.ker f = (globalTangentSpace X).comap (rowTangentSpace X).subtype := by
    ext z
    change (globalTangentMap X) z.val = 0 ↔
      z.val ∈ rowTangentSpace X ∧ (globalTangentMap X) z.val = 0
    exact ⟨fun h => ⟨z.property, h⟩, fun h => h.2⟩
  have hdim : finrank ℝ (LinearMap.ker g) = finrank ℝ (globalTangentSpace X) := by
    rw [hkerg, hker]
    exact (Submodule.comapSubtypeEquivOfLe (globalTangentSpace_le_rowTangentSpace X)).finrank_eq
  have hrank := g.finrank_range_add_finrank_ker
  rw [hdim] at hrank
  have hrange : finrank ℝ (LinearMap.range g) ≤ Fintype.card U := by
    have h := (LinearMap.range g).finrank_le
    simpa only [finrank_fintype_fun_eq_card] using h
  have hc : 2 * Fintype.card U = d * (d + 1) := mrx_two_card_upper d
  omega

/-- `dim (𝓔 ⊖ 𝓕) = dim 𝓔 - dim 𝓕`. -/
theorem mrx_removed_finrank {n d : ℕ} (X : Frame n d) :
    finrank ℝ (globalTangentSpace X) + finrank ℝ (removedTangentSpace X) =
      finrank ℝ (rowTangentSpace X) := by
  have hdim := Submodule.finrank_add_inf_finrank_orthogonal
    (globalTangentSpace_le_rowTangentSpace X)
  exact hdim

/-- Row covariance of the conditioned noise:
`E (z_i·v)² = n⁻¹ ‖Π_𝓕 (δ_i ⊗ v)‖² ≤ n⁻¹ ‖Π_𝓔 (δ_i ⊗ v)‖² = n⁻¹ (‖v‖² - (e_i·v)²)`. -/
theorem mrx_conditioned_row_sq {n d : ℕ} (hn : 0 < n) (hd : 0 < d) (X : Frame n d)
    (hX : IsEqualNorm X) (i : Fin n) (v : Fin d → ℝ) :
    Integrable (fun g => (∑ j, conditionedNoise X g i j * v j) ^ 2)
      (stdGaussian (FrameVector n d)) ∧
    ∫ g, (∑ j, conditionedNoise X g i j * v j) ^ 2 ∂stdGaussian (FrameVector n d) ≤
      (1 / (n : ℝ)) * (vectorNormSq v -
        (∑ j, X i j / Real.sqrt ((d : ℝ) / n) * v j) ^ 2) := by
  set a : ℝ := (d : ℝ) / n with ha_def
  have ha : 0 < a := by positivity
  set w : FrameVector n d := WithLp.toLp 2 (fun p => if p.1 = i then v p.2 else 0) with hw
  set F := globalTangentSpace X
  set E := rowTangentSpace X
  have hlin (g : FrameVector n d) : ∑ j, conditionedNoise X g i j * v j =
      innerSL ℝ ((1 / Real.sqrt (n : ℝ)) • F.starProjection w) g := by
    rw [innerSL_apply_apply, real_inner_smul_left, Submodule.inner_starProjection_left_eq_right]
    have : conditionedNoise X g = frameOfVector ((1 / Real.sqrt (n : ℝ)) • F.starProjection g) := by
      unfold conditionedNoise
      rw [tangentNoiseFactor_apply]
    rw [this]
    simp only [frameOfVector, PiLp.smul_apply, smul_eq_mul, PiLp.inner_apply, Real.inner_apply, hw,
      Fintype.sum_prod_type, Finset.mul_sum]
    rw [Finset.sum_eq_single i]
    · simp only [if_true]
      apply Finset.sum_congr rfl; intro j _; ring
    · intro b _ hb; simp [hb]
    · simp
  simp_rw [hlin]
  refine ⟨(IsGaussian.memLp_dual _ (innerSL ℝ _) 2 (by norm_num)).integrable_sq, ?_⟩
  rw [integral_sq_dual_stdGaussian, innerSL_apply_norm, norm_smul, mul_pow, Real.norm_eq_abs,
    abs_of_nonneg (by positivity), div_pow, one_pow, Real.sq_sqrt (Nat.cast_nonneg n)]
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  -- `Π_𝓕 = Π_𝓕 Π_𝓔`
  have hFE : F.starProjection w = F.starProjection (E.starProjection w) := by
    have h := Submodule.starProjection_comp_starProjection_of_le
      (globalTangentSpace_le_rowTangentSpace X)
    exact (congrArg (fun T : FrameVector n d →L[ℝ] FrameVector n d => T w) h).symm
  have hle : ‖F.starProjection w‖ ≤ ‖E.starProjection w‖ := by
    rw [hFE]
    exact F.norm_starProjection_apply_le _
  have hE : ‖E.starProjection w‖ ^ 2 = vectorNormSq v -
      (∑ j, X i j / Real.sqrt a * v j) ^ 2 := by
    rw [rowTangentProjection_apply X ha hX, EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type]
    rw [Finset.sum_eq_single i]
    · simp only [hw, if_true]
      set s := ∑ j, X i j * v j with hs
      have hxi : ∑ j, X i j ^ 2 = a := hX i
      have hsq : (∑ j, X i j / Real.sqrt a * v j) ^ 2 = s ^ 2 / a := by
        have : ∑ j, X i j / Real.sqrt a * v j = s / Real.sqrt a := by
          rw [hs, Finset.sum_div]; apply Finset.sum_congr rfl; intro j _; ring
        rw [this, div_pow, Real.sq_sqrt ha.le]
      rw [hsq]
      have hexp : ∑ x, (v x - s / a * X i x) ^ 2 =
          ∑ x, v x ^ 2 - 2 * (s / a) * ∑ x, X i x * v x + (s / a) ^ 2 * ∑ x, X i x ^ 2 := by
        rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
        apply Finset.sum_congr rfl; intro j _; ring
      rw [hexp, ← hs, hxi]
      unfold vectorNormSq
      field_simp
      ring
    · intro b _ hb
      simp only [hw, if_neg hb, zero_sub]
      apply Finset.sum_eq_zero; intro j _
      simp
    · simp
  rw [← hE]
  exact pow_le_pow_left₀ (norm_nonneg _) hle 2

end

end Paulsen.Paper
