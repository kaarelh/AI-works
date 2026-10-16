import NeuralGeneralization.ElementaryTailGram

/-!
# Exact cycle moments of sampled Walsh kernels

The expectation of a kernel cycle with distinct sample indices is the
corresponding spectral power sum. This is an ingredient for a matrix
moment argument, not a claimed operator-norm concentration theorem.
-/

noncomputable section
namespace NeuralGeneralization
namespace WalshKernelMoments

open scoped BigOperators
open MeasureTheory ProbabilityTheory CompressionSampling

/-- Restricting an IID sample to distinct positions gives the exact smaller
IID law. The input values themselves need not be distinct. -/
theorem iid_reindex_map (d n m : ℕ) (e : Fin m → Fin n)
    (he : Function.Injective e) :
    (iidSamples (uniformCubeMeasure d) n).map (fun s j => s (e j)) =
      iidSamples (uniformCubeMeasure d) m := by
  have hi : iIndepFun
      (fun i : Fin n => fun s : Fin n → ClippingCube d => s i)
      (iidSamples (uniformCubeMeasure d) n) :=
    iIndepFun_pi (fun _ => aemeasurable_id)
  have h := (hi.precomp he).map_fun_eq_pi_map
    (fun j => (measurable_pi_apply (e j)).aemeasurable)
  have hm (j : Fin m) :
      (iidSamples (uniformCubeMeasure d) n).map (fun s => s (e j)) =
        uniformCubeMeasure d :=
    (measurePreserving_eval (fun _ : Fin n => uniformCubeMeasure d) (e j)).map_eq
  change (iidSamples (uniformCubeMeasure d) n).map (fun s j => s (e j)) =
    Measure.pi (fun j : Fin m => (iidSamples (uniformCubeMeasure d) n).map
      (fun s => s (e j))) at h
  simp_rw [hm] at h
  exact h

theorem iid_reindex_integral (d n m : ℕ) (e : Fin m → Fin n)
    (he : Function.Injective e) (F : (Fin m → ClippingCube d) → ℝ) :
    (∫ s, F (fun j => s (e j)) ∂iidSamples (uniformCubeMeasure d) n) =
      ∫ s, F s ∂iidSamples (uniformCubeMeasure d) m := by
  have h := integral_map (μ := iidSamples (uniformCubeMeasure d) n)
    (measurable_of_finite (fun s : Fin n → ClippingCube d => fun j => s (e j))).aemeasurable
    (measurable_of_finite F).aestronglyMeasurable
  rw [iid_reindex_map d n m e he] at h
  exact h.symm

/-- Separate the first observation of a literal finite product law. -/
theorem iid_cons_integral (d m : ℕ) (F : (Fin (m+1) → ClippingCube d) → ℝ) :
    (∫ s, F s ∂iidSamples (uniformCubeMeasure d) (m+1)) =
      ∫ x, ∫ s, F (Fin.cons x s) ∂iidSamples (uniformCubeMeasure d) m
        ∂uniformCubeMeasure d := by
  let e := MeasurableEquiv.piFinSuccAbove (fun _ : Fin (m+1) => ClippingCube d) 0
  have hp := measurePreserving_piFinSuccAbove
    (fun _ : Fin (m+1) => uniformCubeMeasure d) 0
  have hi := hp.symm e |>.integral_comp' F
  have he (x : ClippingCube d) (s : Fin m → ClippingCube d) :
      e.symm (x,s) = Fin.cons x s := by
    ext j
    refine Fin.cases ?_ (fun k => ?_) j <;>
      simp [e, MeasurableEquiv.piFinSuccAbove_symm_apply,
        Fin.insertNthEquiv]
  change (∫ s, F s ∂Measure.pi (fun _ : Fin (m+1) => uniformCubeMeasure d)) = _
  rw [← hi, integral_prod _ Integrable.of_finite]
  simp only [he]
  rfl

/-- A path with `m` independent interior vertices and `m+1` kernel edges. -/
def kernelPath {X : Type*} (K : X → X → ℝ) :
    (m : ℕ) → X → X → (Fin m → X) → ℝ
  | 0, x, y, _ => K x y
  | m+1, x, y, s => K x (s 0) * kernelPath K m (s 0) y (fun j => s j.succ)

theorem walsh_integral_comp {d : ℕ} (w v : Finset (Fin d) → ℝ)
    (x y : ClippingCube d) :
    (∫ z, walshKernel w x z * walshKernel v z y ∂uniformCubeMeasure d) =
      walshKernel (fun S => w S * v S) x y := by
  rw [uniformCubeMeasure_integral, uniformCubeMean, walshKernel_comp]
  have hc : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 := by positivity
  exact mul_div_cancel_left₀ _ hc

/-- Exact path expectation. Repeated input values remain included. -/
theorem kernelPath_integral {d : ℕ} (w : Finset (Fin d) → ℝ)
    (m : ℕ) (x y : ClippingCube d) :
    (∫ s, kernelPath (walshKernel w) m x y s
      ∂iidSamples (uniformCubeMeasure d) m) =
      walshKernel (fun S => w S ^ (m+1)) x y := by
  induction m generalizing x y with
  | zero => simp [kernelPath]
  | succ m ih =>
      rw [iid_cons_integral]
      simp only [kernelPath, Fin.cons_zero, Fin.cons_succ]
      simp_rw [integral_const_mul, ih]
      rw [walsh_integral_comp]
      congr 1
      funext S
      rw [pow_succ]
      ring

/-- A cyclic product with one observation at each vertex. -/
def kernelCycle {X : Type*} (K : X → X → ℝ) (m : ℕ)
    (s : Fin (m+1) → X) : ℝ :=
  kernelPath K m (s 0) (s 0) (fun j => s j.succ)

theorem walshKernel_diagonal {d : ℕ} (w : Finset (Fin d) → ℝ)
    (x : ClippingCube d) : walshKernel w x x = ∑ S, w S := by
  unfold walshKernel featureKernel
  apply Finset.sum_congr rfl
  intro S _
  have h := walshCharacter_sq S x
  calc
    _ = w S * (walshCharacter S x ^ 2) := by ring
    _ = w S := by rw [h, mul_one]

/-- The exact cycle moment is the spectral power sum. -/
theorem kernelCycle_integral {d : ℕ} (w : Finset (Fin d) → ℝ) (m : ℕ) :
    (∫ s, kernelCycle (walshKernel w) m s
      ∂iidSamples (uniformCubeMeasure d) (m+1)) =
      ∑ S, w S ^ (m+1) := by
  rw [iid_cons_integral]
  simp only [kernelCycle, Fin.cons_zero, Fin.cons_succ]
  change (∫ x, (∫ s, kernelPath (walshKernel w) m x x s
    ∂iidSamples (uniformCubeMeasure d) m) ∂uniformCubeMeasure d) = _
  simp_rw [kernelPath_integral, walshKernel_diagonal]
  simp

/-- Distinct *sample positions* give a spectral cycle even when the sampling
scheme permits collisions among their cube values. -/
theorem sampled_kernelCycle_integral {d : ℕ} (w : Finset (Fin d) → ℝ)
    (n m : ℕ) (e : Fin (m+1) → Fin n) (he : Function.Injective e) :
    (∫ s, kernelCycle (walshKernel w) m (fun j => s (e j))
      ∂iidSamples (uniformCubeMeasure d) n) =
      ∑ S, w S ^ (m+1) := by
  rw [iid_reindex_integral d n (m+1) e he, kernelCycle_integral]

/-- Spectral power sums of order at least two are bounded using just the
largest eigenvalue and the spectral second moment. -/
theorem spectral_power_sum_le {d : ℕ} (w : Finset (Fin d) → ℝ)
    (ℓ : ℝ) (hw : ∀ S, 0 ≤ w S) (hℓ : ∀ S, w S ≤ ℓ) (m : ℕ) :
    (∑ S, w S ^ (m+2)) ≤ ℓ ^ m * ∑ S, w S ^ 2 := by
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro S _
  rw [pow_add]
  exact mul_le_mul_of_nonneg_right
    (pow_le_pow_left₀ (hw S) (hℓ S) m) (sq_nonneg _)

end WalshKernelMoments
end NeuralGeneralization
