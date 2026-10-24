import NeuralGeneralization.BatchTwoActivationPeeling
import NeuralGeneralization.BatchTwoActivationCoveredContraction

/-!
# Width-free peeling with arbitrary neuron-specific Lipschitz activations

The scalar cover is paid for once per layer. Its cost is independent of the
number of rows, including when the activations vary with the candidate
network. All norm and exponential-moment conclusions are proved below.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace

namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling ParameterGrid

variable {U J E : Type*} [Nonempty U] [Fintype J] [Nonempty J]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]

def weightedArrayLayer (r : U → J → ℝ) (F : U → J → Fin n → ℝ) :
    U → Fin n → EuclideanSpace ℝ J :=
  fun p i => WithLp.toLp 2 (fun j => r p j * F p j i)

theorem weightedArrayLayer_process_le {n : ℕ} (r : U → J → ℝ)
    (F : U → J → Fin n → ℝ) (hr : ∀ p, (∑ j, r p j^2) ≤ 1)
    {R : ℝ} (hF : ∀ p j i, |F p j i| ≤ R) (ε : Fin n → Bool) :
    vectorProcess (weightedArrayLayer r F) ε ≤
      envelope (fun pj : U × J => ∑ i, cubeCoordinateSign (ε i) * F pj.1 pj.2 i) := by
  let T : U × J → ℝ := fun pj => ∑ i, cubeCoordinateSign (ε i) * F pj.1 pj.2 i
  have hT (pj : U × J) : |T pj| ≤ (n : ℝ)*R := signed_sum_abs_le _ (hF _ _) ε
  have hM := envelope_nonneg T hT
  apply processSup_le
  intro p
  have hcoord (j : J) :
      (∑ i, cubeCoordinateSign (ε i) • weightedArrayLayer r F p i) j = r p j * T (p,j) := by
    simp only [WithLp.ofLp_sum, Finset.sum_apply, WithLp.ofLp_smul, Pi.smul_apply,
      weightedArrayLayer, smul_eq_mul, T]
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  have hsq : ‖∑ i, cubeCoordinateSign (ε i) • weightedArrayLayer r F p i‖^2 ≤ (envelope T)^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    simp_rw [hcoord, mul_pow]
    calc
      _ ≤ ∑ j, r p j^2 * (envelope T)^2 := by
        apply Finset.sum_le_sum
        intro j _
        have hs : T (p,j)^2 ≤ (envelope T)^2 := by
          simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg (T (p,j))) (le_envelope T hT (p,j)) 2
        exact mul_le_mul_of_nonneg_left hs (sq_nonneg _)
      _ = (∑ j, r p j^2) * (envelope T)^2 := by rw [Finset.sum_mul]
      _ ≤ 1 * (envelope T)^2 := mul_le_mul_of_nonneg_right (hr p) (sq_nonneg _)
      _ = _ := one_mul _
  nlinarith [norm_nonneg (∑ i, cubeCoordinateSign (ε i) • weightedArrayLayer r F p i)]

def heterogeneousRowLayer (ψ : U → J → UnitActivation) (r : U → J → ℝ)
    (u : U → J → E) (h : U → Fin n → E) : U → Fin n → EuclideanSpace ℝ J :=
  weightedArrayLayer r (fun p j i => (ψ p j).val ⟪u p j, h p i⟫)

theorem heterogeneousRowLayer_norm_le (ψ : J → UnitActivation) (r : J → ℝ)
    (u : J → E) (h : E) (hr : (∑ j, r j^2) ≤ 1) (hu : ∀ j, ‖u j‖ ≤ 1) :
    ‖(WithLp.toLp 2 (fun j => r j * (ψ j).val ⟪u j,h⟫) : EuclideanSpace ℝ J)‖ ≤ ‖h‖ := by
  have hscalar (j : J) : |(ψ j).val ⟪u j,h⟫| ≤ ‖h‖ := by
    have hp := activation_abs_le (ψ j).property ⟪u j,h⟫
    simp only [one_mul] at hp
    exact hp.trans (linearRow_abs_le _ (hu j) h le_rfl)
  have hsq : ‖(WithLp.toLp 2 (fun j => r j * (ψ j).val ⟪u j,h⟫) : EuclideanSpace ℝ J)‖^2 ≤ ‖h‖^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    simp only [PiLp.toLp_apply, mul_pow]
    calc
      _ ≤ ∑ j, r j^2 * ‖h‖^2 := by
        apply Finset.sum_le_sum
        intro j _
        have hp := pow_le_pow_left₀ (abs_nonneg ((ψ j).val ⟪u j,h⟫)) (hscalar j) 2
        simp only [sq_abs] at hp
        exact mul_le_mul_of_nonneg_left hp (sq_nonneg _)
      _ = (∑ j, r j^2) * ‖h‖^2 := by rw [Finset.sum_mul]
      _ ≤ 1 * ‖h‖^2 := mul_le_mul_of_nonneg_right hr (sq_nonneg _)
      _ = _ := one_mul _
  nlinarith [norm_nonneg h,
    norm_nonneg (WithLp.toLp 2 (fun j => r j * (ψ j).val ⟪u j,h⟫) : EuclideanSpace ℝ J)]

/-- The scalar activation-cover cost enters just once, with no dependence
on the learner width or the number of neuron-specific choices. -/
theorem heterogeneousRowLayer_exp_peeling {n q : ℕ} (hq : 0 < q)
    (ψ : U → J → UnitActivation) (r : U → J → ℝ)
    (u : U → J → E) (h : U → Fin n → E)
    (hr : ∀ p, (∑ j, r p j^2) ≤ 1) (hu : ∀ p j, ‖u p j‖ ≤ 1)
    {R : ℝ} (hR : 0 < R) (hh : ∀ p i, ‖h p i‖ ≤ R) (a : ℝ) (ha : 0 ≤ a) :
    finiteMean (fun ε : Fin n → Bool => Real.exp (a * vectorProcess (heterogeneousRowLayer ψ r u h) ε)) ≤
      2 * (Fintype.card (ActivationCode q) : ℝ) *
        Real.exp (a * ((n : ℝ) * (4*R/(q : ℝ)))) *
        finiteMean (fun ε : Fin n → Bool => Real.exp (a * vectorProcess h ε)) := by
  letI : Nonempty (GridInt q) := ⟨⟨0, by simp⟩⟩
  letI : Nonempty (ActivationCode q) := ⟨fun _ => Classical.choice inferInstance⟩
  have hscalar (p : U) (j : J) (i : Fin n) : |(ψ p j).val ⟪u p j,h p i⟫| ≤ R := by
    have hp := activation_abs_le (ψ p j).property ⟪u p j,h p i⟫
    simp only [one_mul] at hp
    exact hp.trans (linearRow_abs_le _ (hu _ _) _ (hh _ _))
  have hfirst := finiteMean_mono (fun ε : Fin n → Bool => Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_left
      (weightedArrayLayer_process_le r (fun p j i => (ψ p j).val ⟪u p j,h p i⟫) hr hscalar ε) ha))
  have hcontract := covered_rademacher_exp_contraction n
    (fun pj : U × J => (ψ pj.1 pj.2).val)
    (fun code : ActivationCode q => (activationRepresentative R q code).val)
    (fun code => (activationRepresentative R q code).property.1)
    (fun code x y => by simpa only [one_mul] using (activationRepresentative R q code).property.2 x y)
    (fun pj : U × J => fun i => ⟪u pj.1 pj.2,h pj.1 i⟫)
    (fun pj i => linearRow_abs_le _ (hu _ _) _ (hh _ _))
    (fun pj : U × J => activationCode R q (ψ pj.1 pj.2))
    (fun pj i => activationRepresentative_covers hR hq (ψ pj.1 pj.2) _
      (linearRow_abs_le _ (hu _ _) _ (hh _ _))) a ha
  have hlast := finiteMean_mono (fun ε : Fin n → Bool => Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_left (linearRow_process_le u h hu hh ε) ha))
  exact hfirst.trans (hcontract.trans (mul_le_mul_of_nonneg_left hlast (by positivity)))

end NeuralGeneralization.BatchTwoActivation
