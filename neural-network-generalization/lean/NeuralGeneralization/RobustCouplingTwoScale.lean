import NeuralGeneralization.RobustCouplingFinite
import NeuralGeneralization.RobustEntropyMoments
import NeuralGeneralization.GaussianConeRadial

/-!
# Talagrand-free Gaussian activation replacement

The same measurable sequential coupling works at every noise scale. At small
scales a bound using only its two second moments is sufficient; at larger
scales the coordinatewise mismatch bound supplies the width denominator.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set InformationTheory
open scoped ENNReal ProbabilityTheory
namespace NeuralGeneralization.RobustCoupling

variable {Θ : Type*} [MeasurableSpace Θ]

def standardGaussianVector (n : ℕ) : Measure (Fin n → ℝ) :=
  Measure.pi (fun _ => gaussianReal 0 1)

instance standardGaussianVector_probability (n : ℕ) :
    IsProbabilityMeasure (standardGaussianVector n) := by
  unfold standardGaussianVector
  infer_instance

/-- A marginal-only second-moment estimate. No independence between the two
coupled vectors is needed. -/
theorem finiteCouplingKernel_small_scale_error_le
    (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] (θ : Θ)
    (hfinite : klDiv (P θ) (standardGaussianVector n) ≠ ⊤)
    {t : ℝ} (ht : 0 ≤ t) (g : Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (g i)) (hbound : ∀ i x, |g i x| ≤ 1)
    (hLip : ∀ i x y, |g i x - g i y| ≤ t * |x - y|) :
    (∫ p, ∑ i, (g i (p.1 i) - g i (p.2 i)) ^ 2
      ∂finiteCouplingKernel (gaussianReal 0 1) n P θ) ≤
      8 * t ^ 2 * (klDiv (P θ) (standardGaussianVector n)).toReal + 6 * t ^ 2 * n := by
  let J := finiteCouplingKernel (gaussianReal 0 1) n P θ
  let v : (Fin n → ℝ) → ℝ := fun x => ∑ i, x i ^ 2
  let err : ((Fin n → ℝ) × (Fin n → ℝ)) → ℝ :=
    fun p => ∑ i, (g i (p.1 i) - g i (p.2 i)) ^ 2
  have hm : Measurable err := by unfold err; fun_prop
  have hv : Measurable v := by unfold v; fun_prop
  have hnonneg (p) : 0 ≤ err p := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have hb (p) : err p ≤ 4 * n := by
    calc
      _ ≤ ∑ _i : Fin n, (4 : ℝ) := by
        apply Finset.sum_le_sum
        intro i _
        have h1 := abs_le.mp (hbound i (p.1 i))
        have h2 := abs_le.mp (hbound i (p.2 i))
        nlinarith [sq_nonneg (g i (p.1 i) - g i (p.2 i))]
      _ = _ := by simp [mul_comm]
  have hi : Integrable err J := by
    apply (integrable_const (4 * (n : ℝ))).mono' hm.aestronglyMeasurable
    exact Filter.Eventually.of_forall fun p => by
      rw [Real.norm_of_nonneg (hnonneg p)]
      exact hb p
  obtain ⟨hPi, hPm⟩ := RobustEntropyMoments.standard_gaussian_entropy_second_moment (P θ) hfinite
  have hGi : Integrable v (standardGaussianVector n) := by
    exact integrable_finsetSum _ (fun i _ => GaussianConeRadial.integrable_eval_sq i)
  have hGm : (∫ x, v x ∂standardGaussianVector n) = n := by
    simpa [v, standardGaussianVector, GaussianConeRadial.squaredRadius] using
      (GaussianConeRadial.integral_squaredRadius (I := Fin n))
  have hleft : MeasurePreserving Prod.fst J (P θ) :=
    ⟨measurable_fst, finiteCouplingKernel_fst _ _ _ _⟩
  have hright : MeasurePreserving Prod.snd J (standardGaussianVector n) :=
    ⟨measurable_snd, finiteCouplingKernel_snd _ _ _ _⟩
  have hvi : Integrable (fun p => v p.1) J := hleft.integrable_comp_of_integrable hPi
  have hwi : Integrable (fun p => v p.2) J := hright.integrable_comp_of_integrable hGi
  have hpoint (p) : err p ≤ 2 * t ^ 2 * v p.1 + 2 * t ^ 2 * v p.2 := by
    calc
      _ ≤ ∑ i, (2 * t ^ 2 * (p.1 i) ^ 2 + 2 * t ^ 2 * (p.2 i) ^ 2) := by
        apply Finset.sum_le_sum
        intro i _
        have hsq := (sq_le_sq₀ (abs_nonneg _) (mul_nonneg ht (abs_nonneg _))).mpr
          (hLip i (p.1 i) (p.2 i))
        simp only [mul_pow, sq_abs] at hsq
        nlinarith [mul_nonneg (sq_nonneg t) (sq_nonneg (p.1 i + p.2 i))]
      _ = _ := by simp [v, Finset.sum_add_distrib, Finset.mul_sum]
  have hmom := integral_mono hi ((hvi.const_mul _).add (hwi.const_mul _)) hpoint
  have hvl : (∫ p, v p.1 ∂J) = ∫ x, v x ∂P θ := by
    rw [← hleft.map_eq, integral_map measurable_fst.aemeasurable hv.aestronglyMeasurable]
  have hvr : (∫ p, v p.2 ∂J) = ∫ x, v x ∂standardGaussianVector n := by
    rw [← hright.map_eq, integral_map measurable_snd.aemeasurable hv.aestronglyMeasurable]
  have hsum : (∫ p, 2 * t ^ 2 * v p.1 + 2 * t ^ 2 * v p.2 ∂J) =
      2 * t ^ 2 * (∫ x, v x ∂P θ) + 2 * t ^ 2 * n := by
    rw [integral_add (hvi.const_mul _) (hwi.const_mul _), integral_const_mul, integral_const_mul,
      hvl, hvr, hGm]
  change (∫ p, err p ∂J) ≤ ∫ p, 2 * t ^ 2 * v p.1 + 2 * t ^ 2 * v p.2 ∂J at hmom
  rw [hsum] at hmom
  have hh := mul_le_mul_of_nonneg_left hPm (by positivity : 0 ≤ 2 * t ^ 2)
  simp only [Fintype.card_fin] at hh
  change (∫ p, err p ∂J) ≤ _
  dsimp only [v] at hmom
  dsimp only [standardGaussianVector]
  nlinarith

/-- Extended-integral small-scale bound, valid even at infinite KL. -/
theorem finiteCouplingKernel_small_scale_lintegral_le
    (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] (θ : Θ)
    {t : ℝ} (ht : 0 < t) (g : Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (g i)) (hbound : ∀ i x, |g i x| ≤ 1)
    (hLip : ∀ i x y, |g i x - g i y| ≤ t * |x - y|) :
    (∫⁻ p, ENNReal.ofReal (coordinateSquaredError g p)
      ∂finiteCouplingKernel (gaussianReal 0 1) n P θ) ≤
      ENNReal.ofReal (8 * t ^ 2) * klDiv (P θ) (standardGaussianVector n) +
        ENNReal.ofReal (6 * t ^ 2 * n) := by
  by_cases hk : klDiv (P θ) (standardGaussianVector n) = ⊤
  · rw [hk, ENNReal.mul_top (ENNReal.ofReal_pos.mpr (by positivity)).ne']
    simp
  · rw [← ofReal_integral_eq_lintegral_ofReal
      (integrable_coordinateSquaredError _ g hg hbound)
      (Filter.Eventually.of_forall (coordinateSquaredError_nonneg g))]
    have h := ENNReal.ofReal_le_ofReal
      (finiteCouplingKernel_small_scale_error_le n P θ hk ht.le g hg hbound hLip)
    rw [ENNReal.ofReal_add (by positivity) (by positivity),
      ENNReal.ofReal_mul (by positivity : 0 ≤ 8 * t ^ 2), ENNReal.ofReal_toReal hk] at h
    exact h

/-- Extended-integral large-scale bound. -/
theorem finiteCouplingKernel_large_scale_lintegral_le
    (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] (θ : Θ)
    {s : ℝ} (hs : 0 < s) (g : Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (g i)) (hbound : ∀ i x, |g i x| ≤ 1) :
    (∫⁻ p, ENNReal.ofReal (coordinateSquaredError g p)
      ∂finiteCouplingKernel (gaussianReal 0 1) n P θ) ≤
      ENNReal.ofReal (4 / s) * klDiv (P θ) (standardGaussianVector n) +
        ENNReal.ofReal (4 * n * s) := by
  by_cases hk : klDiv (P θ) (standardGaussianVector n) = ⊤
  · rw [hk, ENNReal.mul_top (ENNReal.ofReal_pos.mpr (by positivity)).ne']
    simp
  · rw [← ofReal_integral_eq_lintegral_ofReal
      (integrable_coordinateSquaredError _ g hg hbound)
      (Filter.Eventually.of_forall (coordinateSquaredError_nonneg g))]
    have h := ENNReal.ofReal_le_ofReal
      (finiteCouplingKernel_squared_error_le (gaussianReal 0 1) n P θ hk hs g hg hbound)
    have hr : 4 * ((klDiv (P θ) (standardGaussianVector n)).toReal / s + n * s) =
        (4 / s) * (klDiv (P θ) (standardGaussianVector n)).toReal + 4 * n * s := by ring
    change ENNReal.ofReal (∫ p, coordinateSquaredError g p ∂_) ≤
      ENNReal.ofReal (4 * ((klDiv (P θ) (standardGaussianVector n)).toReal / s + n * s)) at h
    rw [hr, ENNReal.ofReal_add (by positivity) (by positivity), ENNReal.ofReal_mul
      (by positivity : 0 ≤ 4 / s), ENNReal.ofReal_toReal hk] at h
    exact h

/-- Elementary numerical step shared by pointwise and averaged entropy budgets. -/
theorem two_scale_error_budget {N R δ t E : ℝ} (hN : 0 ≤ N) (hR : 0 ≤ R)
    (hδ : 0 < δ) (hδ1 : δ ≤ 1) (ht : 0 < t)
    (hsmall : E ≤ 8 * t ^ 2 * R + 6 * t ^ 2 * N)
    (hlarge : E ≤ 4 * (R / δ + N * δ))
    (hbudget : R ≤ N * δ ^ 3 / t ^ 2) : E ≤ 14 * N * δ := by
  have hRt : R * t ^ 2 ≤ N * δ ^ 3 := (le_div_iff₀ (sq_pos_of_pos ht)).mp hbudget
  have hδsq : δ ^ 2 ≤ 1 := by nlinarith
  have hδcube : δ ^ 3 ≤ δ := by nlinarith [mul_le_mul_of_nonneg_left hδsq hδ.le]
  by_cases hscale : t ^ 2 ≤ δ
  · have hNcube := mul_le_mul_of_nonneg_left hδcube hN
    have hNt := mul_le_mul_of_nonneg_left hscale hN
    nlinarith
  · have hRt' := mul_le_mul_of_nonneg_left (le_of_not_ge hscale) hR
    have hRδ : R ≤ N * δ ^ 2 := by nlinarith
    have hquot : R / δ ≤ N * δ := (div_le_iff₀ hδ).mpr (by nlinarith)
    nlinarith [mul_nonneg hN hδ.le]

theorem lintegral_le_affine_kernel_kl
    (μ : Measure Θ) [IsProbabilityMeasure μ] (n : ℕ)
    (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P]
    (F : Θ → ℝ≥0∞) (C B : ℝ≥0∞)
    (hF : ∀ θ, F θ ≤ C * klDiv (P θ) (standardGaussianVector n) + B) :
    (∫⁻ θ, F θ ∂μ) ≤ C * (∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ) + B := by
  have hk : Measurable (fun θ => klDiv (P θ) (standardGaussianVector n)) :=
    RobustEntropy.measurable_kernel_klDiv P (Kernel.const Θ (standardGaussianVector n))
  have hC : Measurable (fun θ => C * klDiv (P θ) (standardGaussianVector n)) :=
    measurable_const.mul hk
  calc
    _ ≤ ∫⁻ θ, C * klDiv (P θ) (standardGaussianVector n) + B ∂μ := lintegral_mono hF
    _ = _ := by
      rw [lintegral_add_left hC, lintegral_const_mul _ hk, lintegral_const]
      simp

/-- Averaged conditional KL suffices: no pointwise entropy-budget assumption
is imposed on the external parameter. The left side is the actual expected
total squared discrepancy of the jointly measurable coupling. -/
theorem finiteCouplingKernel_two_scale_averaged
    (μ : Measure Θ) [IsProbabilityMeasure μ] (n : ℕ)
    (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P]
    {δ t : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1) (ht : 0 < t)
    (g : Θ → Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (fun p : Θ × ℝ => g p.1 i p.2))
    (hbound : ∀ θ i x, |g θ i x| ≤ 1)
    (hLip : ∀ θ i x y, |g θ i x - g θ i y| ≤ t * |x - y|)
    (hbudget : (∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ) ≤
      ENNReal.ofReal (n * δ ^ 3 / t ^ 2)) :
    (∫⁻ θ, ∫⁻ p, ENNReal.ofReal (coordinateSquaredError (g θ) p)
      ∂finiteCouplingKernel (gaussianReal 0 1) n P θ ∂μ) ≤
      ENNReal.ofReal (14 * n * δ) := by
  let R := ∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ
  let E := ∫⁻ θ, ∫⁻ p, ENNReal.ofReal (coordinateSquaredError (g θ) p)
    ∂finiteCouplingKernel (gaussianReal 0 1) n P θ ∂μ
  have hR : R ≠ ⊤ := ne_top_of_le_ne_top ENNReal.ofReal_ne_top hbudget
  have hgθ (θ : Θ) (i : Fin n) : Measurable (g θ i) :=
    (hg i).comp measurable_prodMk_left
  have hsmall : E ≤ ENNReal.ofReal (8 * t ^ 2) * R + ENNReal.ofReal (6 * t ^ 2 * n) :=
    lintegral_le_affine_kernel_kl μ n P _ _ _ (fun θ =>
      finiteCouplingKernel_small_scale_lintegral_le n P θ ht (g θ) (hgθ θ) (hbound θ) (hLip θ))
  have hlarge : E ≤ ENNReal.ofReal (4 / δ) * R + ENNReal.ofReal (4 * n * δ) :=
    lintegral_le_affine_kernel_kl μ n P _ _ _ (fun θ =>
      finiteCouplingKernel_large_scale_lintegral_le n P θ hδ (g θ) (hgθ θ) (hbound θ))
  have hE : E ≠ ⊤ := ne_top_of_le_ne_top (by finiteness) hsmall
  have hsmallR := ENNReal.toReal_mono (by finiteness) hsmall
  rw [ENNReal.toReal_add (by finiteness) (by finiteness), ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (by positivity : 0 ≤ 8 * t ^ 2),
    ENNReal.toReal_ofReal (by positivity : 0 ≤ 6 * t ^ 2 * n)] at hsmallR
  have hlargeR := ENNReal.toReal_mono (by finiteness) hlarge
  rw [ENNReal.toReal_add (by finiteness) (by finiteness), ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (by positivity : 0 ≤ 4 / δ),
    ENNReal.toReal_ofReal (by positivity : 0 ≤ 4 * n * δ)] at hlargeR
  have hbudgetR := ENNReal.toReal_mono ENNReal.ofReal_ne_top hbudget
  rw [ENNReal.toReal_ofReal (by positivity : 0 ≤ (n : ℝ) * δ ^ 3 / t ^ 2)] at hbudgetR
  change R.toReal ≤ _ at hbudgetR
  have hlargeR' : E.toReal ≤ 4 * (R.toReal / δ + n * δ) := by
    calc
      _ ≤ (4 / δ) * R.toReal + 4 * n * δ := hlargeR
      _ = _ := by ring
  have hb := two_scale_error_budget (by positivity : (0 : ℝ) ≤ n) ENNReal.toReal_nonneg
    hδ hδ1 ht hsmallR hlargeR' hbudgetR
  apply (ENNReal.toReal_le_toReal hE ENNReal.ofReal_ne_top).mp
  rw [ENNReal.toReal_ofReal (by positivity : 0 ≤ 14 * (n : ℝ) * δ)]
  exact hb

/-- Affine rescaling of a bounded unit-Lipschitz activation has Lipschitz
constant at most t whenever the residual length is in [0,1]. -/
theorem affine_activation_lipschitz (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ)
    {a t ρ : ℝ} (ht : 0 ≤ t) (hρ : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (x y : ℝ) :
    |φ (a + t * ρ * x) - φ (a + t * ρ * y)| ≤ t * |x - y| := by
  have h := hφ.dist_le_mul (a + t * ρ * x) (a + t * ρ * y)
  simp only [Real.dist_eq, NNReal.coe_one, one_mul] at h
  have heq : a + t * ρ * x - (a + t * ρ * y) = t * ρ * (x - y) := by ring
  rw [heq, abs_mul, abs_of_nonneg (mul_nonneg ht hρ)] at h
  have hm := mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hρ1 ht) (abs_nonneg (x - y))
  simpa using h.trans hm

/-- The concrete offset/residual-scale form used at a network layer. The
coupling remains measurable in all external conditioning parameters. -/
theorem finiteCouplingKernel_activation_replacement
    (μ : Measure Θ) [IsProbabilityMeasure μ] (n : ℕ)
    (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P]
    {δ t : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1) (ht : 0 < t)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hφbound : ∀ z, |φ z| ≤ 1)
    (a : Θ → Fin n → ℝ) (ha : ∀ i, Measurable (fun θ => a θ i))
    (ρ : Θ → ℝ) (hρm : Measurable ρ) (hρ : ∀ θ, 0 ≤ ρ θ) (hρ1 : ∀ θ, ρ θ ≤ 1)
    (hbudget : (∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ) ≤
      ENNReal.ofReal (n * δ ^ 3 / t ^ 2)) :
    (∫⁻ θ, ∫⁻ p, ENNReal.ofReal
      (∑ i, (φ (a θ i + t * ρ θ * p.1 i) - φ (a θ i + t * ρ θ * p.2 i)) ^ 2)
      ∂finiteCouplingKernel (gaussianReal 0 1) n P θ ∂μ) ≤
      ENNReal.ofReal (14 * n * δ) := by
  apply finiteCouplingKernel_two_scale_averaged μ n P hδ hδ1 ht
    (fun θ i z => φ (a θ i + t * ρ θ * z))
  · intro i
    exact hφ.continuous.measurable.comp
      ((ha i).comp measurable_fst |>.add
        ((measurable_const.mul (hρm.comp measurable_fst)).mul measurable_snd))
  · intro θ i z
    exact hφbound _
  · intro θ i x y
    exact affine_activation_lipschitz φ hφ ht.le (hρ θ) (hρ1 θ) x y
  · exact hbudget

theorem finiteCouplingKernel_two_scale_mean_error
    (n : ℕ) (hn : 0 < n) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] (θ : Θ)
    (hfinite : klDiv (P θ) (standardGaussianVector n) ≠ ⊤)
    {δ t : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1) (ht : 0 < t)
    (g : Fin n → ℝ → ℝ) (hg : ∀ i, Measurable (g i))
    (hbound : ∀ i x, |g i x| ≤ 1)
    (hLip : ∀ i x y, |g i x - g i y| ≤ t * |x - y|)
    (hbudget : (klDiv (P θ) (standardGaussianVector n)).toReal ≤ n * δ ^ 3 / t ^ 2) :
    (∫ p, coordinateSquaredError g p ∂finiteCouplingKernel (gaussianReal 0 1) n P θ) / n ≤
      14 * δ := by
  have hsmall := finiteCouplingKernel_small_scale_error_le n P θ hfinite ht.le g hg hbound hLip
  have hlarge := finiteCouplingKernel_squared_error_le (gaussianReal 0 1) n P θ hfinite hδ g hg hbound
  have h := two_scale_error_budget (by positivity : (0 : ℝ) ≤ n) ENNReal.toReal_nonneg
    hδ hδ1 ht hsmall hlarge hbudget
  apply (div_le_iff₀ (by exact_mod_cast hn : (0 : ℝ) < n)).mpr
  exact h.trans_eq (by ring)

@[fun_prop] theorem measurable_family_coordinateSquaredError {n : ℕ}
    (g : Θ → Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (fun p : Θ × ℝ => g p.1 i p.2)) :
    Measurable (fun p : Θ × ((Fin n → ℝ) × (Fin n → ℝ)) =>
      ENNReal.ofReal (coordinateSquaredError (g p.1) p.2)) := by
  unfold coordinateSquaredError
  apply Measurable.ennreal_ofReal
  apply Finset.measurable_sum
  intro i _
  exact (((hg i).comp (measurable_fst.prodMk ((measurable_pi_apply i).comp measurable_snd.fst))).sub
    ((hg i).comp (measurable_fst.prodMk ((measurable_pi_apply i).comp measurable_snd.snd)))).pow_const 2

/-- The averaged bound as a single integral under the actual joint law. -/
theorem finiteCouplingKernel_two_scale_joint
    (μ : Measure Θ) [IsProbabilityMeasure μ] (n : ℕ)
    (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P]
    {δ t : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1) (ht : 0 < t)
    (g : Θ → Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (fun p : Θ × ℝ => g p.1 i p.2))
    (hbound : ∀ θ i x, |g θ i x| ≤ 1)
    (hLip : ∀ θ i x y, |g θ i x - g θ i y| ≤ t * |x - y|)
    (hbudget : (∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ) ≤
      ENNReal.ofReal (n * δ ^ 3 / t ^ 2)) :
    (∫⁻ q, ENNReal.ofReal (coordinateSquaredError (g q.1) q.2)
      ∂μ ⊗ₘ finiteCouplingKernel (gaussianReal 0 1) n P) ≤
      ENNReal.ofReal (14 * n * δ) := by
  rw [Measure.lintegral_compProd (measurable_family_coordinateSquaredError g hg)]
  exact finiteCouplingKernel_two_scale_averaged μ n P hδ hδ1 ht g hg hbound hLip hbudget

end NeuralGeneralization.RobustCoupling
