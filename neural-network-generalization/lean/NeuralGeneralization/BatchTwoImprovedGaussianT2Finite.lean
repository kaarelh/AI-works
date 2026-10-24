import NeuralGeneralization.BatchTwoImprovedGaussianT2Vector
import NeuralGeneralization.RobustCouplingFinite

/-! # Sharp finite-dimensional Gaussian transport in ordinary coordinate form -/
noncomputable section
open MeasureTheory ProbabilityTheory Set InformationTheory
open scoped ENNReal ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedGaussianTransport
open RobustCoupling (RealPrefix referencePrefix prefixEquiv prefixEquiv_succ_apply prefixEquiv_reference)

theorem squaredCost_prefixEquiv (n : ℕ) (x y : Fin n → ℝ) :
    squaredCost n (prefixEquiv n x, prefixEquiv n y) =
      ∑ i, scalarSquaredCost (x i, y i) := by
  induction n with
  | zero => simp [squaredCost]
  | succ n ih =>
    rw [prefixEquiv_succ_apply, prefixEquiv_succ_apply]
    change squaredCost n (prefixEquiv n (fun i => x i.succ),
      prefixEquiv n (fun i => y i.succ)) + scalarSquaredCost (x 0, y 0) = _
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

/-- Dimension-free Talagrand cost with a jointly measurable parameterized
coupling and exact Gaussian marginal. -/
theorem finiteCouplingKernel_squared_le
    (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] (θ : Θ) :
    (∫⁻ p, ∑ i, scalarSquaredCost (p.1 i, p.2 i)
      ∂finiteCouplingKernel (gaussianReal 0 1) n P θ) ≤
      2 * klDiv (P θ) (Measure.pi (fun _ : Fin n => gaussianReal 0 1)) := by
  have hc := prefixCouplingKernel_squared_le n (P.map (prefixEquiv n)) θ
  rw [finiteCouplingKernel, Kernel.map_apply _ (by fun_prop),
    lintegral_map (by fun_prop) (by fun_prop)]
  have heq : (fun p : RealPrefix n × RealPrefix n =>
      ∑ i, scalarSquaredCost ((prefixEquiv n).symm p.1 i, (prefixEquiv n).symm p.2 i)) =
      squaredCost n := by
    funext p
    simpa using (squaredCost_prefixEquiv n ((prefixEquiv n).symm p.1)
      ((prefixEquiv n).symm p.2)).symm
  change (∫⁻ p, (∑ i, scalarSquaredCost ((prefixEquiv n).symm p.1 i,
    (prefixEquiv n).symm p.2 i))
    ∂prefixCouplingKernel (gaussianReal 0 1) n (P.map (prefixEquiv n)) θ) ≤ _
  rw [heq]
  refine hc.trans ?_
  apply mul_le_mul' le_rfl
  rw [Kernel.map_apply _ (prefixEquiv n).measurable,
    ← (prefixEquiv_reference (gaussianReal 0 1) n).map_eq]
  exact NeuralGeneralization.RobustEntropy.klDiv_map_le _ _ (prefixEquiv n).measurable

/-- Every coordinatewise Lipschitz observable obeys the same sharp transport
estimate. Boundedness of the activation is not needed for this step. -/
theorem finiteCouplingKernel_lipschitz_cost_le
    (n : ℕ) (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P] (θ : Θ)
    {t : ℝ} (ht : 0 ≤ t) (g : Fin n → ℝ → ℝ)
    (hLip : ∀ i x y, |g i x-g i y| ≤ t*|x-y|) :
    (∫⁻ p, ENNReal.ofReal (∑ i, (g i (p.1 i)-g i (p.2 i))^2)
      ∂finiteCouplingKernel (gaussianReal 0 1) n P θ) ≤
      ENNReal.ofReal (2*t^2) *
        klDiv (P θ) (Measure.pi (fun _ : Fin n => gaussianReal 0 1)) := by
  have hpoint (p : (Fin n → ℝ) × (Fin n → ℝ)) :
      ENNReal.ofReal (∑ i, (g i (p.1 i)-g i (p.2 i))^2) ≤
        ENNReal.ofReal (t^2) * ∑ i, scalarSquaredCost (p.1 i,p.2 i) := by
    rw [ENNReal.ofReal_sum_of_nonneg (fun i _ => sq_nonneg _), Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    have hsq := (sq_le_sq₀ (abs_nonneg _) (mul_nonneg ht (abs_nonneg _))).mpr
      (hLip i (p.1 i) (p.2 i))
    simp only [mul_pow, sq_abs] at hsq
    simpa only [scalarSquaredCost, ← ENNReal.ofReal_mul (sq_nonneg t)] using
      ENNReal.ofReal_le_ofReal hsq
  calc
    _ ≤ ∫⁻ p, ENNReal.ofReal (t^2) * ∑ i, scalarSquaredCost (p.1 i,p.2 i)
        ∂finiteCouplingKernel (gaussianReal 0 1) n P θ := lintegral_mono hpoint
    _ = ENNReal.ofReal (t^2) * ∫⁻ p, ∑ i, scalarSquaredCost (p.1 i,p.2 i)
        ∂finiteCouplingKernel (gaussianReal 0 1) n P θ :=
      lintegral_const_mul _ (by fun_prop)
    _ ≤ ENNReal.ofReal (t^2) * (2 *
        klDiv (P θ) (Measure.pi (fun _ : Fin n => gaussianReal 0 1))) :=
      mul_le_mul' le_rfl (finiteCouplingKernel_squared_le n P θ)
    _ = _ := by rw [ENNReal.ofReal_mul (by norm_num : (0:ℝ) ≤ 2)]; simp; ring

/-- The averaged conditional bound has linear, rather than cubic, dependence
on the permitted squared error. This is the sharp active-direction primitive. -/
theorem finiteCouplingKernel_averaged
    (μ : Measure Θ) [IsProbabilityMeasure μ] (n : ℕ)
    (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P]
    {δ t : ℝ} (hδ : 0 ≤ δ) (ht : 0 < t)
    (g : Θ → Fin n → ℝ → ℝ)
    (hLip : ∀ θ i x y, |g θ i x-g θ i y| ≤ t*|x-y|)
    (hbudget : (∫⁻ θ, klDiv (P θ) (Measure.pi (fun _ : Fin n => gaussianReal 0 1)) ∂μ) ≤
      ENNReal.ofReal (n*δ/t^2)) :
    (∫⁻ θ, ∫⁻ p, ENNReal.ofReal (∑ i, (g θ i (p.1 i)-g θ i (p.2 i))^2)
      ∂finiteCouplingKernel (gaussianReal 0 1) n P θ ∂μ) ≤
      ENNReal.ofReal (2*n*δ) := by
  have hm : Measurable (fun θ => klDiv (P θ)
      (Measure.pi (fun _ : Fin n => gaussianReal 0 1))) :=
    RobustEntropy.measurable_kernel_klDiv P (Kernel.const Θ _)
  calc
    _ ≤ ∫⁻ θ, ENNReal.ofReal (2*t^2) * klDiv (P θ)
        (Measure.pi (fun _ : Fin n => gaussianReal 0 1)) ∂μ := by
      apply lintegral_mono
      intro θ
      exact finiteCouplingKernel_lipschitz_cost_le n P θ ht.le (g θ) (hLip θ)
    _ = ENNReal.ofReal (2*t^2) * ∫⁻ θ, klDiv (P θ)
        (Measure.pi (fun _ : Fin n => gaussianReal 0 1)) ∂μ := lintegral_const_mul _ hm
    _ ≤ ENNReal.ofReal (2*t^2) * ENNReal.ofReal (n*δ/t^2) := mul_le_mul' le_rfl hbudget
    _ = _ := by
      rw [← ENNReal.ofReal_mul (by positivity : 0 ≤ 2*t^2)]
      congr 1
      field_simp

end NeuralGeneralization.BatchTwoImprovedGaussianTransport
