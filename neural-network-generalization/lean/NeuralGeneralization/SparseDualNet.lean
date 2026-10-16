import NeuralGeneralization.BoundedObservables
import NeuralGeneralization.SparseAtomMGF
import Mathlib.MeasureTheory.Integral.Prod

/-!
# Sparse approximation of the bounded dual objective

The averaging law is the explicit finite atom PMF. The exponential penalty
is derived from its actual IID samples, and the exchange of expectations
is justified by a uniform integrable bound.
-/

noncomputable section

open MeasureTheory
open scoped BigOperators

namespace NeuralGeneralization.SparseDualNet

open BoundedDual BoundedTilt ActualBoundedDual CompressionSampling

variable {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι] [DecidableEq ι] [Nonempty ι]
variable (μ : Measure Ω) [IsProbabilityMeasure μ]
variable [MeasurableSpace (SparseAtoms.Atom ι)] [MeasurableSingletonClass (SparseAtoms.Atom ι)]

omit [Nonempty ι] in
theorem average_partition_le
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {G : ℝ} (hG : 0 < G)
    (lam : ι → ℝ) (hlam : entryL1 lam ≤ G) {s : ℕ} (hs : 0 < s) :
    (∫ a, partition μ (potential T (SparseAtoms.average G s a))
      ∂iidSamples (SparseAtoms.law hG lam hlam) s) ≤
      partition μ (potential T lam) * Real.exp (G ^ 2 / (2 * (s : ℝ))) := by
  let σ := iidSamples (SparseAtoms.law hG lam hlam) s
  let F : (Fin s → SparseAtoms.Atom ι) × Ω → ℝ :=
    fun p => Real.exp (potential T (SparseAtoms.average G s p.1) p.2)
  have hFmeas : Measurable F := by
    apply Measurable.exp
    apply Finset.measurable_fun_sum Finset.univ
    intro i hi
    exact ((measurable_of_finite (fun a => SparseAtoms.average G s a i)).comp measurable_fst).mul
      ((hT i).comp measurable_snd)
  have hFint : Integrable F (σ.prod μ) := by
    apply (integrable_const (Real.exp G)).mono' hFmeas.aestronglyMeasurable
    apply ae_of_all
    intro p
    rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
    apply Real.exp_le_exp.mpr
    exact ((le_abs_self _).trans (potential_bound T hbound _ p.2)).trans
      (SparseAtoms.average_entryL1_le hG.le hs p.1)
  have hpoint (x : Ω) : (∫ a, F (a, x) ∂σ) ≤
      Real.exp (potential T lam x) * Real.exp (G ^ 2 / (2 * (s : ℝ))) := by
    have heq : (fun a => F (a, x)) = fun a => Real.exp (potential T lam x) *
        Real.exp (pairing (SparseAtoms.average G s a - lam) (fun i => T i x)) := by
      funext a
      dsimp only [F]
      rw [← Real.exp_add]
      congr 1
      unfold potential
      rw [pairing_sub_left]
      ring
    rw [heq, integral_const_mul]
    exact mul_le_mul_of_nonneg_left
      (SparseAtoms.average_exp_centered_le hG lam (fun i => T i x) hlam
        (fun i => hbound i x) hs) (Real.exp_pos _).le
  calc
    (∫ a, partition μ (potential T (SparseAtoms.average G s a)) ∂σ) =
        ∫ x, ∫ a, F (a, x) ∂σ ∂μ := integral_integral_swap hFint
    _ ≤ ∫ x, Real.exp (potential T lam x) * Real.exp (G ^ 2 / (2 * (s : ℝ))) ∂μ :=
      integral_mono_ae hFint.integral_prod_right
        ((integrable_exp_of_bounded μ _ (measurable_potential T hT lam)
          (potential_bound T hbound lam)).mul_const _)
        (ae_of_all μ hpoint)
    _ = partition μ (potential T lam) * Real.exp (G ^ 2 / (2 * (s : ℝ))) :=
      integral_mul_const _ _

omit [Nonempty ι] in
theorem average_log_partition_le
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {G : ℝ} (hG : 0 < G)
    (lam : ι → ℝ) (hlam : entryL1 lam ≤ G) {s : ℕ} (hs : 0 < s) :
    (∫ a, Real.log (partition μ (potential T (SparseAtoms.average G s a)))
      ∂iidSamples (SparseAtoms.law hG lam hlam) s) ≤
      Real.log (partition μ (potential T lam)) + G ^ 2 / (2 * (s : ℝ)) := by
  let σ := iidSamples (SparseAtoms.law hG lam hlam) s
  let Z : (Fin s → SparseAtoms.Atom ι) → ℝ :=
    fun a => partition μ (potential T (SparseAtoms.average G s a))
  have hZpos (a) : 0 < Z a := partition_pos μ _
    (measurable_potential T hT _) (potential_bound T hbound _)
  have hZlo (a) : Real.exp (-G) ≤ Z a := exp_neg_le_partition μ _
    (measurable_potential T hT _) (fun x =>
      (potential_bound T hbound _ x).trans (SparseAtoms.average_entryL1_le hG.le hs a))
  have hmeanpos : 0 < ∫ a, Z a ∂σ := by
    have h := integral_mono_ae (integrable_const (Real.exp (-G)))
      (show Integrable Z σ from Integrable.of_finite) (ae_of_all σ hZlo)
    have hlo : Real.exp (-G) ≤ ∫ a, Z a ∂σ := by simpa using h
    exact (Real.exp_pos _).trans_le hlo
  have hJ := integral_log_le_log_integral σ Z hZpos Integrable.of_finite
    Integrable.of_finite hmeanpos
  have hE := average_partition_le μ T hT hbound hG lam hlam hs
  have hL := Real.log_le_log hmeanpos hE
  rw [Real.log_mul (partition_pos μ _ (measurable_potential T hT lam)
    (potential_bound T hbound lam)).ne' (Real.exp_ne_zero _), Real.log_exp] at hL
  exact hJ.trans hL

omit [Nonempty ι] [MeasurableSpace (SparseAtoms.Atom ι)] [MeasurableSingletonClass (SparseAtoms.Atom ι)] in
/-- Every dual parameter in the ball has a deterministic sparse competitor
with loss at most G²/(2s). The sparse grid is independent of q and λ. -/
theorem exists_sparse_competitor
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {G : ℝ} (hG : 0 < G)
    (q lam : ι → ℝ) (hlam : entryL1 lam ≤ G) {s : ℕ} (hs : 0 < s) :
    ∃ v : ι → ℝ, v ∈ SparseAtoms.grid G s ∧
      objective μ T q lam ≤ G ^ 2 / (2 * (s : ℝ)) + objective μ T q v := by
  classical
  letI : MeasurableSpace (SparseAtoms.Atom ι) := ⊤
  let σ := iidSamples (SparseAtoms.law hG lam hlam) s
  let D : (Fin s → SparseAtoms.Atom ι) → ℝ :=
    fun a => objective μ T q (SparseAtoms.average G s a)
  have hlog := average_log_partition_le μ T hT hbound hG lam hlam hs
  have hmean := SparseAtoms.integral_average_pairing hG lam q hlam hs
  have hlower : objective μ T q lam - G ^ 2 / (2 * (s : ℝ)) ≤ ∫ a, D a ∂σ := by
    change pairing lam q - Real.log (partition μ (potential T lam)) -
      G ^ 2 / (2 * (s : ℝ)) ≤
      ∫ a, pairing (SparseAtoms.average G s a) q -
        Real.log (partition μ (potential T (SparseAtoms.average G s a))) ∂σ
    rw [integral_sub Integrable.of_finite Integrable.of_finite, hmean]
    linarith
  obtain ⟨a, ha, hmax⟩ := Finset.exists_max_image Finset.univ D Finset.univ_nonempty
  have hupper : (∫ b, D b ∂σ) ≤ D a := by
    have h := integral_mono_ae (show Integrable D σ from Integrable.of_finite)
      (integrable_const (D a)) (ae_of_all σ (fun b => hmax b (Finset.mem_univ b)))
    simpa using h
  refine ⟨SparseAtoms.average G s a, SparseAtoms.average_mem_grid G s a, ?_⟩
  change objective μ T q lam ≤ G ^ 2 / (2 * (s : ℝ)) + D a
  linarith

end NeuralGeneralization.SparseDualNet

end
