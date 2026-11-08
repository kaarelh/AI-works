import NeuralGeneralization.OnlineLowerReluWalshIntegral
import NeuralGeneralization.OnlineLowerReluIntegralCopies
import Mathlib.Data.Fintype.BigOperators

/-! # Actual coordinate blocks and simultaneous Fourier-potential balancing -/

noncomputable section
open scoped BigOperators
open MeasureTheory

namespace NeuralGeneralization.OnlineLowerRelu

variable {κ : Type*} [Fintype κ] [DecidableEq κ] {β : κ → Type*}
variable [∀ j, Fintype (β j)]

/-- Reindex a complete family of physical coordinate blocks into `Fin d`. -/
def blockWeights {d : ℕ} (e : ((j : κ) × β j) ≃ Fin d)
    (u : (j : κ) → β j → ℝ) (i : Fin d) : ℝ := u (e.symm i).1 (e.symm i).2

omit [Fintype κ] [DecidableEq κ] [∀ j, Fintype (β j)] in
theorem blockWeights_apply {d : ℕ} (e : ((j : κ) × β j) ≃ Fin d)
    (u : (j : κ) → β j → ℝ) (j : κ) (k : β j) :
    blockWeights e u (e ⟨j, k⟩) = u j k := by
  change (fun z : ((j : κ) × β j) => u z.1 z.2) (e.symm (e ⟨j, k⟩)) = _
  rw [e.symm_apply_apply]

/-- A support selects whole coordinate blocks. -/
def blockSupport {d : ℕ} (e : ((j : κ) × β j) ≃ Fin d)
    (orientation : κ → Bool) : Finset (Fin d) :=
  Finset.univ.filter (fun i => orientation (e.symm i).1 = true)

/-- One independent coordinate is copied across each physical block. -/
def sampledBlockWeights (u : (j : κ) → β j → ℝ) (pick : (j : κ) → β j) :
    (j : κ) → β j → ℝ := fun j _ => u j (pick j)

omit [DecidableEq κ] in
theorem trigProduct_blocks {d : ℕ} (e : ((j : κ) × β j) ≃ Fin d)
    (orientation : κ → Bool) (u : (j : κ) → β j → ℝ) (t : ℝ) :
    trigProduct (blockSupport e orientation) (fun i => t * blockWeights e u i) =
      ∏ j, ∏ k, if orientation j then Real.sin (t * u j k) else Real.cos (t * u j k) := by
  classical
  let f : Fin d → ℝ := fun i =>
    if i ∈ blockSupport e orientation then Real.sin (t * blockWeights e u i)
      else Real.cos (t * blockWeights e u i)
  have h := e.prod_comp f
  rw [Fintype.prod_sigma] at h
  change (∏ i, f i) = _
  calc
    _ = ∏ j, ∏ k, f (e ⟨j, k⟩) := h.symm
    _ = _ := by
      apply Finset.prod_congr rfl
      intro j _
      apply Finset.prod_congr rfl
      intro k _
      dsimp only [f]
      rw [blockWeights_apply]
      simp [blockSupport]

omit [DecidableEq κ] in
theorem abs_trigKernel_blocks {d : ℕ} (e : ((j : κ) × β j) ≃ Fin d)
    (orientation : κ → Bool) (u : (j : κ) → β j → ℝ) (t : ℝ) :
    |trigKernel (blockSupport e orientation) (blockWeights e u) t| =
      (∏ j, ∏ k, |if orientation j then Real.sin (t * u j k) else Real.cos (t * u j k)|) /
        t ^ 2 := by
  unfold trigKernel
  rw [trigProduct_blocks]
  simp only [abs_div, abs_pow, sq_abs, Finset.abs_prod]

/-- Even block sizes prove the fixed-sign property pointwise. -/
theorem sampled_trigKernel_nonneg {d : ℕ} (e : ((j : κ) × β j) ≃ Fin d)
    (orientation : κ → Bool) (u : (j : κ) → β j → ℝ) (pick : (j : κ) → β j)
    (heven : ∀ j, Even (Fintype.card (β j))) (t : ℝ) :
    0 ≤ trigKernel (blockSupport e orientation) (blockWeights e (sampledBlockWeights u pick)) t := by
  unfold trigKernel
  rw [trigProduct_blocks]
  simp only [sampledBlockWeights, Finset.prod_const, Finset.card_univ]
  apply div_nonneg _ (sq_nonneg t)
  exact Finset.prod_nonneg (fun j _ => (heven j).pow_nonneg _)

/-- Fully balanced blocks attain their positive Fourier potential exactly. -/
theorem sampled_relu_abs_eq_potential {d r : ℕ} (e : ((j : κ) × β j) ≃ Fin d)
    (orientation : κ → Bool) (u : (j : κ) → β j → ℝ) (pick : (j : κ) → β j)
    (heven : ∀ j, Even (Fintype.card (β j)))
    (hcard : (blockSupport e orientation).card = 2 * r)
    (hsize : 2 ≤ (blockSupport e orientation).card) :
    |walshCoefficients (fun x => max (cubeAffine 0
      (blockWeights e (sampledBlockWeights u pick)) x) 0) (blockSupport e orientation)| =
      supportFourierPotential (blockSupport e orientation) (blockWeights e (sampledBlockWeights u pick)) :=
  relu_walsh_abs_eq_potential_of_nonneg _ hsize hcard _
    (sampled_trigKernel_nonneg e orientation u pick heven)

/-- The weighted positive potential of an actual finite family of block supports. -/
def blockCodePotential {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (u : (j : κ) → β j → ℝ) : ℝ :=
  ∑ v, weight v * supportFourierPotential (blockSupport e (orientation v)) (blockWeights e u)

/-- The actual weighted coefficient mass of an arbitrary affine neuron. -/
def blockCodeMass {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (b : ℝ) (u : (j : κ) → β j → ℝ) : ℝ :=
  ∑ v, weight v * |walshCoefficients (fun x => max (cubeAffine b (blockWeights e u) x) 0)
    (blockSupport e (orientation v))|

theorem blockCodePotential_nonneg {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v, 0 ≤ weight v) (u : (j : κ) → β j → ℝ) :
    0 ≤ blockCodePotential e orientation weight u :=
  Finset.sum_nonneg (fun v _ => mul_nonneg (hw v) (supportFourierPotential_nonneg _ _))

theorem blockCodeMass_le_potential {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v, 0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v, (blockSupport e (orientation v)).card = 2 * r v)
    (hsize : ∀ v, 2 ≤ (blockSupport e (orientation v)).card)
    (b : ℝ) (u : (j : κ) → β j → ℝ) :
    blockCodeMass e orientation weight b u ≤ blockCodePotential e orientation weight u := by
  apply Finset.sum_le_sum
  intro v _
  exact mul_le_mul_of_nonneg_left
    (relu_walsh_abs_le_potential _ (hsize v) (hcard v) _ _) (hw v)

theorem blockCodePotential_sample_eq_mass {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (r : ν → ℕ)
    (hcard : ∀ v, (blockSupport e (orientation v)).card = 2 * r v)
    (hsize : ∀ v, 2 ≤ (blockSupport e (orientation v)).card)
    (heven : ∀ j, Even (Fintype.card (β j)))
    (u : (j : κ) → β j → ℝ) (pick : (j : κ) → β j) :
    blockCodePotential e orientation weight (sampledBlockWeights u pick) =
      blockCodeMass e orientation weight 0 (sampledBlockWeights u pick) := by
  apply Finset.sum_congr rfl
  intro v _
  rw [sampled_relu_abs_eq_potential e (orientation v) u pick heven (hcard v) (hsize v)]

theorem blockCodePotential_abs_weights {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (u : (j : κ) → β j → ℝ) :
    blockCodePotential e orientation weight (fun j k => |u j k|) =
      blockCodePotential e orientation weight u := by
  apply Finset.sum_congr rfl
  intro v _
  change weight v * supportFourierPotential _ (fun i => |blockWeights e u i|) = _
  rw [supportPotential_abs_weights]

theorem block_integrand_factor {d : ℕ} (e : ((j : κ) × β j) ≃ Fin d)
    (orientation : κ → Bool) (weight : ℝ) (u : (j : κ) → β j → ℝ) (t : ℝ) :
    (weight / (2 * fourierAbsConstant * t ^ 2)) *
      (∏ j, ∏ k, |if orientation j then Real.sin (t * u j k) else Real.cos (t * u j k)|) =
    (weight / (2 * fourierAbsConstant)) *
      |trigKernel (blockSupport e orientation) (blockWeights e u) t| := by
  rw [abs_trigKernel_blocks]
  ring

theorem replacement_integrand_factor {d : ℕ} (e : ((j : κ) × β j) ≃ Fin d)
    (orientation : κ → Bool) (weight : ℝ) (u : (j : κ) → β j → ℝ)
    (pick : (j : κ) → β j) (t : ℝ) :
    (weight / (2 * fourierAbsConstant * t ^ 2)) *
      (∏ j, |if orientation j then Real.sin (t * u j (pick j))
        else Real.cos (t * u j (pick j))| ^ Fintype.card (β j)) =
    (weight / (2 * fourierAbsConstant)) *
      |trigKernel (blockSupport e orientation) (blockWeights e (sampledBlockWeights u pick)) t| := by
  rw [abs_trigKernel_blocks]
  simp only [sampledBlockWeights, Finset.prod_const, Finset.card_univ]
  ring

/-- The exact simultaneous square-mean comparison for the physical weighted
Fourier potential. All integrability and coefficient-copy hypotheses are
proved from the actual finite-cube Fourier formula. -/
theorem blockCodePotential_square_le_sample_mean {d : ℕ} {ν : Type*} [Fintype ν]
    [MeasurableSpace ν] [MeasurableSingletonClass ν] [∀ j, Nonempty (β j)]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v, 0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v, (blockSupport e (orientation v)).card = 2 * r v)
    (hsize : ∀ v, 2 ≤ (blockSupport e (orientation v)).card)
    (u : (j : κ) → β j → ℝ) :
    blockCodePotential e orientation weight u ^ 2 ≤
      (∏ j, (Fintype.card (β j) : ℝ)⁻¹) *
        ∑ pick : (j : κ) → β j,
          blockCodePotential e orientation weight (sampledBlockWeights u pick) ^ 2 := by
  classical
  let g : ν → ℝ → ℝ := fun v t => weight v / (2 * fourierAbsConstant * t ^ 2)
  let f : (j : κ) → β j → ν → ℝ → ℝ := fun j k v t =>
    |if orientation v j then Real.sin (t * u j k) else Real.cos (t * u j k)|
  have hS0 (v : ν) : blockSupport e (orientation v) ≠ ∅ := by
    intro h
    have hs := hsize v
    simp [h] at hs
  have he (v : ν) (t : ℝ) : g v t * ∏ j, ∏ k, f j k v t =
      (weight v / (2 * fourierAbsConstant)) *
        |trigKernel (blockSupport e (orientation v)) (blockWeights e u) t| :=
    block_integrand_factor e (orientation v) (weight v) u t
  have hre (pick : (j : κ) → β j) (v : ν) (t : ℝ) :
      g v t * ∏ j, f j (pick j) v t ^ Fintype.card (β j) =
      (weight v / (2 * fourierAbsConstant)) *
        |trigKernel (blockSupport e (orientation v))
          (blockWeights e (sampledBlockWeights u pick)) t| :=
    replacement_integrand_factor e (orientation v) (weight v) u pick t
  have hbm (v : ν) : Measurable (fun t => g v t * ∏ j, ∏ k, f j k v t) := by
    simp_rw [he]
    simpa only [Real.norm_eq_abs] using
      (measurable_trigKernel _ _).norm.const_mul (weight v / (2 * fourierAbsConstant))
  have hbi (v : ν) : Integrable (fun t => g v t * ∏ j, ∏ k, f j k v t) := by
    simp_rw [he]
    exact (integrable_trigKernel_even _ (hS0 v) (hcard v) _).abs.const_mul _
  have hrm (pick : (j : κ) → β j) (v : ν) :
      Measurable (fun t => g v t * ∏ j, f j (pick j) v t ^ Fintype.card (β j)) := by
    simp_rw [hre]
    simpa only [Real.norm_eq_abs] using
      (measurable_trigKernel _ _).norm.const_mul (weight v / (2 * fourierAbsConstant))
  have hri (pick : (j : κ) → β j) (v : ν) :
      Integrable (fun t => g v t * ∏ j, f j (pick j) v t ^ Fintype.card (β j)) := by
    simp_rw [hre]
    exact (integrable_trigKernel_even _ (hS0 v) (hcard v) _).abs.const_mul _
  have hmain := square_sum_integral_all_blocks_replacement g f
    (fun v t => div_nonneg (hw v) (by positivity [fourierAbsConstant_pos]))
    (fun _ _ _ _ => abs_nonneg _) hbm hbi hrm hri
  have hint (v : ν) : (∫ t : ℝ, g v t * ∏ j, ∏ k, f j k v t) =
      weight v * supportFourierPotential (blockSupport e (orientation v)) (blockWeights e u) := by
    simp_rw [he]
    rw [integral_const_mul]
    unfold supportFourierPotential
    ring
  have hrint (pick : (j : κ) → β j) (v : ν) :
      (∫ t : ℝ, g v t * ∏ j, f j (pick j) v t ^ Fintype.card (β j)) =
      weight v * supportFourierPotential (blockSupport e (orientation v))
        (blockWeights e (sampledBlockWeights u pick)) := by
    simp_rw [hre]
    rw [integral_const_mul]
    unfold supportFourierPotential
    ring
  simp_rw [hint, hrint] at hmain
  exact hmain

end NeuralGeneralization.OnlineLowerRelu
