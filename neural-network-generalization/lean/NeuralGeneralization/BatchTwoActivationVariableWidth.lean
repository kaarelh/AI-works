import NeuralGeneralization.BatchTwoActivationHeterogeneousLayer

/-!
# Peeling simultaneously over variable-width candidate networks

The scalar cover is paid for once per layer. Its cost is independent of the
number of rows, including when the activations vary with the candidate
network. All norm and exponential-moment conclusions are proved below.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace

namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling ParameterGrid

variable {U : Type*} [Nonempty U] {J E : U → Type*}
  [∀ p, Fintype (J p)] [∀ p, Nonempty (J p)]
  [∀ p, NormedAddCommGroup (E p)] [∀ p, InnerProductSpace ℝ (E p)]

local instance : Nonempty (Σ p, J p) := by
  classical
  obtain ⟨p⟩ := ‹Nonempty U›
  exact ⟨⟨p, Classical.choice inferInstance⟩⟩

/-- The feature spaces may have different dimensions for different members
of the class. This is needed to count the union over all learner widths. -/
def dependentVectorProcess {n : ℕ} (h : ∀ p, Fin n → E p) (ε : Fin n → Bool) : ℝ :=
  processSup (fun p => ‖∑ i, cubeCoordinateSign (ε i) • h p i‖)

theorem norm_le_dependentVectorProcess {n : ℕ} (h : ∀ p, Fin n → E p)
    {R : ℝ} (hh : ∀ p i, ‖h p i‖ ≤ R) (ε : Fin n → Bool) (p : U) :
    ‖∑ i, cubeCoordinateSign (ε i) • h p i‖ ≤ dependentVectorProcess h ε :=
  le_processSup _ (fun p => signed_vector_sum_norm_le (h p) (hh p) ε) p

theorem dependentLinearRow_process_le {n : ℕ} (u : ∀ p, J p → E p)
    (h : ∀ p, Fin n → E p) (hu : ∀ p j, ‖u p j‖ ≤ 1)
    {R : ℝ} (hh : ∀ p i, ‖h p i‖ ≤ R) (ε : Fin n → Bool) :
    envelope (fun pj : (Σ p, J p) => ∑ i, cubeCoordinateSign (ε i) * ⟪u pj.1 pj.2,h pj.1 i⟫) ≤
      dependentVectorProcess h ε := by
  apply envelope_le
  intro pj
  have heq : (∑ i, cubeCoordinateSign (ε i) * ⟪u pj.1 pj.2,h pj.1 i⟫) =
      ⟪u pj.1 pj.2, ∑ i, cubeCoordinateSign (ε i) • h pj.1 i⟫ := by
    simp only [inner_sum, real_inner_smul_right]
  rw [heq]
  exact linearRow_abs_le _ (hu _ _) _ (norm_le_dependentVectorProcess h hh ε pj.1)

def dependentWeightedArrayLayer (r : ∀ p, J p → ℝ) (F : ∀ p, J p → Fin n → ℝ) :
    ∀ p, Fin n → EuclideanSpace ℝ (J p) :=
  fun p i => WithLp.toLp 2 (fun j => r p j * F p j i)

theorem dependentWeightedArrayLayer_process_le {n : ℕ} (r : ∀ p, J p → ℝ)
    (F : ∀ p, J p → Fin n → ℝ) (hr : ∀ p, (∑ j, r p j^2) ≤ 1)
    {R : ℝ} (hF : ∀ p j i, |F p j i| ≤ R) (ε : Fin n → Bool) :
    dependentVectorProcess (dependentWeightedArrayLayer r F) ε ≤
      envelope (fun pj : (Σ p, J p) => ∑ i, cubeCoordinateSign (ε i) * F pj.1 pj.2 i) := by
  let T : (Σ p, J p) → ℝ := fun pj => ∑ i, cubeCoordinateSign (ε i) * F pj.1 pj.2 i
  have hT (pj : (Σ p, J p)) : |T pj| ≤ (n : ℝ)*R := signed_sum_abs_le _ (hF _ _) ε
  have hM := envelope_nonneg T hT
  apply processSup_le
  intro p
  have hcoord (j : J p) :
      (∑ i, cubeCoordinateSign (ε i) • dependentWeightedArrayLayer r F p i) j = r p j * T ⟨p,j⟩ := by
    simp only [WithLp.ofLp_sum, Finset.sum_apply, WithLp.ofLp_smul, Pi.smul_apply,
      dependentWeightedArrayLayer, smul_eq_mul, T]
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  have hsq : ‖∑ i, cubeCoordinateSign (ε i) • dependentWeightedArrayLayer r F p i‖^2 ≤ (envelope T)^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    simp_rw [hcoord, mul_pow]
    calc
      _ ≤ ∑ j, r p j^2 * (envelope T)^2 := by
        apply Finset.sum_le_sum
        intro j _
        have hs : T ⟨p,j⟩^2 ≤ (envelope T)^2 := by
          simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg (T ⟨p,j⟩)) (le_envelope T hT ⟨p,j⟩) 2
        exact mul_le_mul_of_nonneg_left hs (sq_nonneg _)
      _ = (∑ j, r p j^2) * (envelope T)^2 := by rw [Finset.sum_mul]
      _ ≤ 1 * (envelope T)^2 := mul_le_mul_of_nonneg_right (hr p) (sq_nonneg _)
      _ = _ := one_mul _
  nlinarith [norm_nonneg (∑ i, cubeCoordinateSign (ε i) • dependentWeightedArrayLayer r F p i)]

def dependentHeterogeneousRowLayer (ψ : ∀ p, J p → UnitActivation) (r : ∀ p, J p → ℝ)
    (u : ∀ p, J p → E p) (h : ∀ p, Fin n → E p) : ∀ p, Fin n → EuclideanSpace ℝ (J p) :=
  dependentWeightedArrayLayer r (fun p j i => (ψ p j).val ⟪u p j, h p i⟫)

/-- The scalar activation-cover cost enters just once, with no dependence
on the learner width or the number of neuron-specific choices. -/
theorem dependentHeterogeneousRowLayer_exp_peeling {n q : ℕ} (hq : 0 < q)
    (ψ : ∀ p, J p → UnitActivation) (r : ∀ p, J p → ℝ)
    (u : ∀ p, J p → E p) (h : ∀ p, Fin n → E p)
    (hr : ∀ p, (∑ j, r p j^2) ≤ 1) (hu : ∀ p j, ‖u p j‖ ≤ 1)
    {R : ℝ} (hR : 0 < R) (hh : ∀ p i, ‖h p i‖ ≤ R) (a : ℝ) (ha : 0 ≤ a) :
    finiteMean (fun ε : Fin n → Bool => Real.exp (a * dependentVectorProcess (dependentHeterogeneousRowLayer ψ r u h) ε)) ≤
      2 * (Fintype.card (ActivationCode q) : ℝ) *
        Real.exp (a * ((n : ℝ) * (4*R/(q : ℝ)))) *
        finiteMean (fun ε : Fin n → Bool => Real.exp (a * dependentVectorProcess h ε)) := by
  letI : Nonempty (GridInt q) := ⟨⟨0, by simp⟩⟩
  letI : Nonempty (ActivationCode q) := ⟨fun _ => Classical.choice inferInstance⟩
  have hscalar (p : U) (j : J p) (i : Fin n) : |(ψ p j).val ⟪u p j,h p i⟫| ≤ R := by
    have hp := activation_abs_le (ψ p j).property ⟪u p j,h p i⟫
    simp only [one_mul] at hp
    exact hp.trans (linearRow_abs_le _ (hu _ _) _ (hh _ _))
  have hfirst := finiteMean_mono (fun ε : Fin n → Bool => Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_left
      (dependentWeightedArrayLayer_process_le r (fun p j i => (ψ p j).val ⟪u p j,h p i⟫) hr hscalar ε) ha))
  have hcontract := covered_rademacher_exp_contraction n
    (fun pj : (Σ p, J p) => (ψ pj.1 pj.2).val)
    (fun code : ActivationCode q => (activationRepresentative R q code).val)
    (fun code => (activationRepresentative R q code).property.1)
    (fun code x y => by simpa only [one_mul] using (activationRepresentative R q code).property.2 x y)
    (fun pj : (Σ p, J p) => fun i => ⟪u pj.1 pj.2,h pj.1 i⟫)
    (fun pj i => linearRow_abs_le _ (hu _ _) _ (hh _ _))
    (fun pj : (Σ p, J p) => activationCode R q (ψ pj.1 pj.2))
    (fun pj i => activationRepresentative_covers hR hq (ψ pj.1 pj.2) _
      (linearRow_abs_le _ (hu _ _) _ (hh _ _))) a ha
  have hlast := finiteMean_mono (fun ε : Fin n → Bool => Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_left (dependentLinearRow_process_le u h hu hh ε) ha))
  exact hfirst.trans (hcontract.trans (mul_le_mul_of_nonneg_left hlast (by positivity)))

end NeuralGeneralization.BatchTwoActivation
