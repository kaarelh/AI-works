import NeuralGeneralization.RobustCouplingVector
import NeuralGeneralization.RobustEntropyChain
import Mathlib.MeasureTheory.Constructions.Pi

/-! # Finite-coordinate form of the measurable sequential Pinsker coupling -/
noncomputable section
open MeasureTheory ProbabilityTheory Set InformationTheory
open scoped ENNReal ProbabilityTheory
namespace NeuralGeneralization.RobustCoupling

def prefixEquiv : (n : ℕ) → (Fin n → ℝ) ≃ᵐ RealPrefix n
  | 0 =>
    { toFun := fun _ => ()
      invFun := fun _ i => Fin.elim0 i
      left_inv := by intro x; funext i; exact Fin.elim0 i
      right_inv := by intro x; cases x; rfl
      measurable_toFun := measurable_const
      measurable_invFun := measurable_pi_lambda _ (fun i => Fin.elim0 i) }
  | n + 1 =>
    (MeasurableEquiv.piFinSuccAbove (fun _ : Fin (n + 1) => ℝ) 0).trans
      (MeasurableEquiv.prodComm.trans ((prefixEquiv n).prodCongr (MeasurableEquiv.refl ℝ)))

theorem prefixEquiv_succ_apply (n : ℕ) (x : Fin (n + 1) → ℝ) :
    prefixEquiv (n + 1) x = (prefixEquiv n (fun i => x i.succ), x 0) := by
  simp [prefixEquiv]
  rfl

theorem prefixEquiv_reference (G : Measure ℝ) [IsProbabilityMeasure G] (n : ℕ) :
    MeasurePreserving (prefixEquiv n) (Measure.pi (fun _ : Fin n => G)) (referencePrefix G n) := by
  induction n with
  | zero =>
    refine ⟨(prefixEquiv 0).measurable, ?_⟩
    letI : IsProbabilityMeasure ((Measure.pi (fun _ : Fin 0 => G)).map (prefixEquiv 0)) :=
      Measure.isProbabilityMeasure_map (prefixEquiv 0).measurable.aemeasurable
    exact probability_unit_eq_dirac _
  | succ n ih =>
    exact (ih.prod (MeasurePreserving.id G)).comp
      (Measure.measurePreserving_swap.comp
        (measurePreserving_piFinSuccAbove (fun _ : Fin (n + 1) => G) 0))

theorem mismatchCount_prefixEquiv (n : ℕ) (x y : Fin n → ℝ) :
    mismatchCount n (prefixEquiv n x, prefixEquiv n y) =
      ∑ i, scalarMismatch (x i, y i) := by
  induction n with
  | zero => simp [mismatchCount]
  | succ n ih =>
    rw [prefixEquiv_succ_apply, prefixEquiv_succ_apply]
    change mismatchCount n (prefixEquiv n (fun i => x i.succ),
      prefixEquiv n (fun i => y i.succ)) + scalarMismatch (x 0, y 0) = _
    rw [ih, Fin.sum_univ_succ]
    exact add_comm _ _

variable {Θ : Type*} [MeasurableSpace Θ]

instance prefixMapped_markov (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] :
    IsMarkovKernel (P.map (prefixEquiv n)) := Kernel.IsMarkovKernel.map P (prefixEquiv n).measurable

/-- Jointly measurable coordinatewise coupling, in the ordinary `Fin n → ℝ` encoding. -/
def finiteCouplingKernel (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] :
    Kernel Θ ((Fin n → ℝ) × (Fin n → ℝ)) :=
  (prefixCouplingKernel G n (P.map (prefixEquiv n))).map
    (fun p => ((prefixEquiv n).symm p.1, (prefixEquiv n).symm p.2))

instance finiteCouplingKernel_markov (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] :
    IsMarkovKernel (finiteCouplingKernel G n P) := by
  unfold finiteCouplingKernel
  apply Kernel.IsMarkovKernel.map
  exact ((prefixEquiv n).symm.measurable.comp measurable_fst).prodMk
    ((prefixEquiv n).symm.measurable.comp measurable_snd)

theorem finiteCouplingKernel_fst (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] (θ : Θ) :
    (finiteCouplingKernel G n P θ).map Prod.fst = P θ := by
  rw [finiteCouplingKernel, Kernel.map_apply _ (by fun_prop),
    Measure.map_map measurable_fst (by fun_prop)]
  change (prefixCouplingKernel G n (P.map (prefixEquiv n)) θ).map
    ((prefixEquiv n).symm ∘ Prod.fst) = _
  rw [← Measure.map_map (prefixEquiv n).symm.measurable measurable_fst,
    prefixCouplingKernel_fst, Kernel.map_apply _ (prefixEquiv n).measurable]
  rw [Measure.map_map (prefixEquiv n).symm.measurable (prefixEquiv n).measurable]
  simp

theorem finiteCouplingKernel_snd (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] (θ : Θ) :
    (finiteCouplingKernel G n P θ).map Prod.snd = Measure.pi (fun _ : Fin n => G) := by
  rw [finiteCouplingKernel, Kernel.map_apply _ (by fun_prop),
    Measure.map_map measurable_snd (by fun_prop)]
  change (prefixCouplingKernel G n (P.map (prefixEquiv n)) θ).map
    ((prefixEquiv n).symm ∘ Prod.snd) = _
  rw [← Measure.map_map (prefixEquiv n).symm.measurable measurable_snd,
    prefixCouplingKernel_snd, ← (prefixEquiv_reference G n).map_eq]
  rw [Measure.map_map (prefixEquiv n).symm.measurable (prefixEquiv n).measurable]
  simp

/-- Width-sensitive sequential Pinsker, uniformly and measurably in an external parameter. -/
theorem finiteCouplingKernel_mismatch_le (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] (θ : Θ)
    {s : ℝ} (hs : 0 < s) :
    (∫⁻ p, ∑ i, scalarMismatch (p.1 i, p.2 i) ∂finiteCouplingKernel G n P θ) ≤
      ENNReal.ofReal (1 / s) * klDiv (P θ) (Measure.pi (fun _ : Fin n => G)) +
        n * ENNReal.ofReal s := by
  have hc := prefixCouplingKernel_mismatch_le G n (P.map (prefixEquiv n)) θ hs
  rw [finiteCouplingKernel, Kernel.map_apply _ (by fun_prop),
    lintegral_map (by fun_prop) (by fun_prop)]
  have heq : (fun p : RealPrefix n × RealPrefix n =>
      ∑ i, scalarMismatch ((prefixEquiv n).symm p.1 i, (prefixEquiv n).symm p.2 i)) =
      mismatchCount n := by
    funext p
    simpa using (mismatchCount_prefixEquiv n ((prefixEquiv n).symm p.1)
      ((prefixEquiv n).symm p.2)).symm
  change (∫⁻ p, (∑ i, scalarMismatch ((prefixEquiv n).symm p.1 i,
    (prefixEquiv n).symm p.2 i)) ∂prefixCouplingKernel G n (P.map (prefixEquiv n)) θ) ≤ _
  rw [heq]
  refine hc.trans ?_
  apply add_le_add _ le_rfl
  apply mul_le_mul' le_rfl
  rw [Kernel.map_apply _ (prefixEquiv n).measurable, ← (prefixEquiv_reference G n).map_eq]
  exact NeuralGeneralization.RobustEntropy.klDiv_map_le _ _ (prefixEquiv n).measurable

theorem bounded_squared_le_mismatch (g : ℝ → ℝ) (hbound : ∀ x, |g x| ≤ 1)
    (x y : ℝ) : ENNReal.ofReal ((g x - g y) ^ 2) ≤ 4 * scalarMismatch (x, y) := by
  by_cases hxy : x = y
  · simp [scalarMismatch, hxy]
  · have h1 := abs_le.mp (hbound x)
    have h2 := abs_le.mp (hbound y)
    have hh : (g x - g y) ^ 2 ≤ 4 := by nlinarith [sq_nonneg (g x - g y)]
    simpa [scalarMismatch, hxy] using ENNReal.ofReal_le_ofReal hh

/-- The coordinatewise coupling controls any measurable bounded coordinate
observable; the observable may vary between coordinates. -/
theorem finiteCouplingKernel_squared_error_le (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] (θ : Θ)
    (hfinite : klDiv (P θ) (Measure.pi (fun _ : Fin n => G)) ≠ ⊤)
    {s : ℝ} (hs : 0 < s) (g : Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (g i)) (hbound : ∀ i x, |g i x| ≤ 1) :
    (∫ p, ∑ i, (g i (p.1 i) - g i (p.2 i)) ^ 2 ∂finiteCouplingKernel G n P θ) ≤
      4 * ((klDiv (P θ) (Measure.pi (fun _ : Fin n => G))).toReal / s + n * s) := by
  let err : ((Fin n → ℝ) × (Fin n → ℝ)) → ℝ :=
    fun p => ∑ i, (g i (p.1 i) - g i (p.2 i)) ^ 2
  have hm : Measurable err := by unfold err; fun_prop
  have hn (p) : 0 ≤ err p := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have hb (p) : err p ≤ 4 * n := by
    calc
      _ ≤ ∑ _i : Fin n, (4 : ℝ) := by
        apply Finset.sum_le_sum
        intro i _
        have h1 := abs_le.mp (hbound i (p.1 i))
        have h2 := abs_le.mp (hbound i (p.2 i))
        nlinarith [sq_nonneg (g i (p.1 i) - g i (p.2 i))]
      _ = _ := by simp [mul_comm]
  have hi : Integrable err (finiteCouplingKernel G n P θ) := by
    apply (integrable_const (4 * (n : ℝ))).mono' hm.aestronglyMeasurable
    exact Filter.Eventually.of_forall fun p => by
      rw [Real.norm_of_nonneg (hn p)]
      exact hb p
  have hpoint (p) : ENNReal.ofReal (err p) ≤ 4 * ∑ i, scalarMismatch (p.1 i, p.2 i) := by
    dsimp only [err]
    rw [ENNReal.ofReal_sum_of_nonneg (fun i _ => sq_nonneg _), Finset.mul_sum]
    exact Finset.sum_le_sum (fun i _ => bounded_squared_le_mismatch (g i) (hbound i) _ _)
  have hl : ENNReal.ofReal (∫ p, err p ∂finiteCouplingKernel G n P θ) ≤
      4 * (ENNReal.ofReal (1 / s) * klDiv (P θ) (Measure.pi (fun _ : Fin n => G)) +
        n * ENNReal.ofReal s) := by
    rw [ofReal_integral_eq_lintegral_ofReal hi (Filter.Eventually.of_forall hn)]
    calc
      _ ≤ ∫⁻ p, 4 * ∑ i, scalarMismatch (p.1 i, p.2 i) ∂finiteCouplingKernel G n P θ :=
        lintegral_mono hpoint
      _ = 4 * ∫⁻ p, ∑ i, scalarMismatch (p.1 i, p.2 i) ∂finiteCouplingKernel G n P θ :=
        lintegral_const_mul _ (by fun_prop)
      _ ≤ _ := mul_le_mul' le_rfl (finiteCouplingKernel_mismatch_le G n P θ hs)
  have hr := ENNReal.toReal_mono (by finiteness) hl
  rw [ENNReal.toReal_ofReal (integral_nonneg hn), ENNReal.toReal_mul,
    ENNReal.toReal_add (by finiteness) (by finiteness), ENNReal.toReal_mul,
    ENNReal.toReal_mul, ENNReal.toReal_ofReal (one_div_pos.mpr hs).le,
    ENNReal.toReal_ofReal hs.le] at hr
  simpa [err, div_eq_mul_inv, mul_comm] using hr

/-- Averaging over coordinates gives the essential width denominator. -/
theorem finiteCouplingKernel_mean_squared_error_le (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (hn : 0 < n) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] (θ : Θ)
    (hfinite : klDiv (P θ) (Measure.pi (fun _ : Fin n => G)) ≠ ⊤)
    {s : ℝ} (hs : 0 < s) (g : Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (g i)) (hbound : ∀ i x, |g i x| ≤ 1) :
    (∫ p, ∑ i, (g i (p.1 i) - g i (p.2 i)) ^ 2 ∂finiteCouplingKernel G n P θ) / n ≤
      4 * ((klDiv (P θ) (Measure.pi (fun _ : Fin n => G))).toReal / (n * s) + s) := by
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  apply (div_le_iff₀ hn').mpr
  refine (finiteCouplingKernel_squared_error_le G n P θ hfinite hs g hg hbound).trans_eq ?_
  field_simp

/-- Total coordinatewise squared discrepancy. -/
def coordinateSquaredError {n : ℕ} (g : Fin n → ℝ → ℝ)
    (p : (Fin n → ℝ) × (Fin n → ℝ)) : ℝ :=
  ∑ i, (g i (p.1 i) - g i (p.2 i)) ^ 2

@[fun_prop] theorem measurable_coordinateSquaredError {n : ℕ} (g : Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (g i)) : Measurable (coordinateSquaredError g) := by
  unfold coordinateSquaredError
  fun_prop

theorem coordinateSquaredError_nonneg {n : ℕ} (g : Fin n → ℝ → ℝ) (p) :
    0 ≤ coordinateSquaredError g p := Finset.sum_nonneg (fun i _ => sq_nonneg _)

theorem coordinateSquaredError_le {n : ℕ} (g : Fin n → ℝ → ℝ)
    (hbound : ∀ i x, |g i x| ≤ 1) (p) : coordinateSquaredError g p ≤ 4 * n := by
  calc
    _ ≤ ∑ _i : Fin n, (4 : ℝ) := by
      apply Finset.sum_le_sum
      intro i _
      have h1 := abs_le.mp (hbound i (p.1 i))
      have h2 := abs_le.mp (hbound i (p.2 i))
      nlinarith [sq_nonneg (g i (p.1 i) - g i (p.2 i))]
    _ = _ := by simp [mul_comm]

theorem integrable_coordinateSquaredError {n : ℕ}
    (μ : Measure ((Fin n → ℝ) × (Fin n → ℝ))) [IsFiniteMeasure μ]
    (g : Fin n → ℝ → ℝ) (hg : ∀ i, Measurable (g i))
    (hbound : ∀ i x, |g i x| ≤ 1) : Integrable (coordinateSquaredError g) μ := by
  apply (integrable_const (4 * (n : ℝ))).mono'
    (measurable_coordinateSquaredError g hg).aestronglyMeasurable
  exact Filter.Eventually.of_forall fun p => by
    rw [Real.norm_of_nonneg (coordinateSquaredError_nonneg g p)]
    exact coordinateSquaredError_le g hbound p

end NeuralGeneralization.RobustCoupling
